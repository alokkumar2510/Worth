import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../database/database.dart';
import '../../database/seeder.dart';
import '../calculation/balance_cache_service.dart';
import '../providers/app_providers.dart';
import '../providers/dependency_provider.dart';
import 'search_index_service.dart';
import 'network_monitor.dart';
import 'conflict_resolver.dart';
import 'cloudinary_service.dart';
import '../../features/auth/providers/auth_providers.dart';

class SyncService {
  final Ref _ref;
  final AppDatabase _db;
  final NetworkMonitor _networkMonitor;
  final BalanceCacheService _balanceCacheService;
  final SearchIndexService _searchIndexService;
  final FirebaseAuth? _authOverride;
  final FirebaseFirestore? _firestoreOverride;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _authSubscription;
  bool _isSyncing = false;
  bool _isProcessingQueue = false;

  SyncService(
    this._ref,
    this._db,
    this._networkMonitor,
    this._balanceCacheService,
    this._searchIndexService, {
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _authOverride = auth,
       _firestoreOverride = firestore;

  void start() {
    try {
      // 1. Listen for connectivity changes
      _connectivitySubscription = _networkMonitor.isConnectedStream.listen((connected) {
        if (connected) {
          processQueue();
          pullRemoteChanges();
        }
      });

      // 2. Listen for auth state changes
      _authSubscription = _auth.authStateChanges().listen((user) async {
        if (user != null) {
          _runAuthSync(user);
        }
      });

      // Run initial check
      _runInitialSync();
    } catch (e) {
      print('[SyncService] Failed to start: $e');
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _authSubscription?.cancel();
  }

  Future<void> _runAuthSync(User user) async {
    final isLocalEmpty = await isLocalDatabaseEmpty();
    if (isLocalEmpty) {
      final cloudCount = await getCloudRecordCount(user.uid);
      if (cloudCount > 0) {
        _ref.read(isRestoringProvider.notifier).state = true;
        try {
          print('[SyncService] Auth change: Local empty but cloud has data. Auto restoring...');
          await manualRestore();
        } catch (e) {
          print('[SyncService] Auto restore failed: $e');
        } finally {
          _ref.read(isRestoringProvider.notifier).state = false;
        }
        return;
      }
    }
    await forceSync();
  }

  Future<void> _runInitialSync() async {
    final user = _auth.currentUser;
    if (user != null) {
      final isLocalEmpty = await isLocalDatabaseEmpty();
      if (isLocalEmpty) {
        final cloudCount = await getCloudRecordCount(user.uid);
        if (cloudCount > 0) {
          _ref.read(isRestoringProvider.notifier).state = true;
          try {
            print('[SyncService] Startup check: Local empty but cloud has data. Auto restoring...');
            await manualRestore();
          } catch (e) {
            print('[SyncService] Startup auto restore failed: $e');
          } finally {
            _ref.read(isRestoringProvider.notifier).state = false;
          }
          return;
        }
      }
    }
    await processQueue();
    await pullRemoteChanges();
  }


  /// Queues a mutation to be synchronized with Firebase.
  Future<void> queueOperation({
    required String entityType,
    required String entityId,
    required String operation, // 'upsert' | 'delete'
  }) async {
    final now = DateTime.now().toUtc();
    final queueItem = SyncQueuesCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      status: const Value('pending'),
      createdAt: Value(now),
      updatedAt: Value(now),
      attempts: const Value(0),
    );
    await _db.into(_db.syncQueues).insert(queueItem);
    
    // Process queue immediately in the background
    _triggerQueueProcessing();
  }

  void _triggerQueueProcessing() {
    Future.microtask(() => processQueue());
  }

  /// Processes all pending sync queue items.
  Future<void> processQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final connected = await _networkMonitor.isConnected;
      if (!connected) return;

      final uid = user.uid;

      // Fetch unsynced items chronologically
      final pendingItems = await (_db.select(_db.syncQueues)
            ..where((tbl) => tbl.status.equals('pending') | tbl.status.equals('retrying') | tbl.status.equals('failed'))
            ..orderBy([(tbl) => OrderingTerm(expression: tbl.id, mode: OrderingMode.asc)]))
          .get();

      for (final item in pendingItems) {
        // Mark as syncing
        await (_db.update(_db.syncQueues)..where((tbl) => tbl.id.equals(item.id)))
            .write(SyncQueuesCompanion(
              status: const Value('syncing'),
              updatedAt: Value(DateTime.now().toUtc()),
            ));

        try {
          if (item.operation == 'delete') {
            await _deleteRemoteEntity(uid, item.entityType, item.entityId);
          } else {
            await _uploadLocalEntity(uid, item.entityType, item.entityId);
          }

          // Mark as synced
          await (_db.update(_db.syncQueues)..where((tbl) => tbl.id.equals(item.id)))
              .write(SyncQueuesCompanion(
                status: const Value('synced'),
                updatedAt: Value(DateTime.now().toUtc()),
              ));
        } catch (e) {
          final attempts = item.attempts + 1;
          final isFailedPermanently = attempts >= 3;
          final newStatus = isFailedPermanently ? 'failed' : 'retrying';

          await (_db.update(_db.syncQueues)..where((tbl) => tbl.id.equals(item.id)))
              .write(SyncQueuesCompanion(
                status: Value(newStatus),
                attempts: Value(attempts),
                errorMessage: Value(e.toString()),
                updatedAt: Value(DateTime.now().toUtc()),
              ));
        }
      }
    } catch (e) {
      print('[SyncService] Queue processing error: $e');
    } finally {
      _isProcessingQueue = false;
    }
  }

  /// Pulls remote changes from Firebase and resolves conflicts using ConflictResolver.
  Future<void> pullRemoteChanges() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final connected = await _networkMonitor.isConnected;
      if (!connected) return;

      final uid = user.uid;

      // Fetch all collections and sync them
      await _pullCollection(uid, 'accounts', _db.accounts, (data) => _mapAccount(data));
      await _pullCollection(uid, 'liabilities', _db.accounts, (data) => _mapAccount(data));
      await _pullCollection(uid, 'receivables', _db.people, (data) => _mapPerson(data));
      await _pullCollection(uid, 'investments', _db.investments, (data) => _mapInvestment(data));
      await _pullCollection(uid, 'investment_lots', _db.investmentLots, (data) => _mapInvestmentLot(data));
      await _pullCollection(uid, 'transactions', _db.transactions, (data) => _mapTransaction(data));
      await _pullCollection(uid, 'expected_income', _db.expectedIncomes, (data) => _mapExpectedIncome(data));
      await _pullCollection(uid, 'goals', _db.goals, (data) => _mapGoal(data));
      await _pullCollection(uid, 'snapshots', _db.snapshots, (data) => _mapSnapshot(data));
      await _pullCollection(uid, 'adjustments', _db.adjustments, (data) => _mapAdjustment(data));
      await _pullCollection(uid, 'mtf_positions', _db.mtfPositions, (data) => _mapMtfPosition(data));
      await _pullCollection(uid, 'sips', _db.sips, (data) => _mapSip(data));
      await _pullCollection(uid, 'settings', _db.settings, (data) => _mapSetting(data));
    } catch (e) {
      print('[SyncService] Pull changes error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pullCollection<T extends Table, D extends DataClass>(
    String uid,
    String collectionName,
    TableInfo<T, D> table,
    D Function(Map<String, dynamic> data) mapper,
  ) async {
    try {
      final querySnap = await _firestore.collection('users').doc(uid).collection(collectionName).get();
      
      for (final doc in querySnap.docs) {
        final remoteData = doc.data();
        final remoteEntity = mapper(remoteData);
        final id = doc.id;

        final localRow = await _getLocalRow(table, id);
        
        if (localRow == null) {
          await _insertLocalRow(table, remoteEntity);
        } else {
          final DateTime? localUpdatedAt = _getUpdatedAt(localRow);
          final DateTime? remoteUpdatedAt = _getUpdatedAt(remoteEntity);

          if (ConflictResolver.shouldRemoteOverrideLocal(
            localUpdatedAt: localUpdatedAt,
            remoteUpdatedAt: remoteUpdatedAt,
          )) {
            await _updateLocalRow(table, remoteEntity);
          } else if (localUpdatedAt != null && remoteUpdatedAt != null && localUpdatedAt.isAfter(remoteUpdatedAt)) {
            // Local is newer: queue to upload
            await queueOperation(
              entityType: _getEntityTypeFromCollection(collectionName),
              entityId: id,
              operation: 'upsert',
            );
          }
        }
      }
    } catch (e) {
      print('[SyncService] Failed to pull collection $collectionName: $e');
    }
  }

  Future<void> _deleteRemoteEntity(String uid, String entityType, String entityId) async {
    final collectionName = _getCollectionName(entityType, null);
    final docRef = _firestore.collection('users').doc(uid).collection(collectionName).doc(entityId);
    await docRef.delete();
  }

  Future<void> _uploadLocalEntity(String uid, String entityType, String entityId) async {
    switch (entityType) {
      case 'account':
        final row = await (_db.select(_db.accounts)..where((tbl) => tbl.id.equals(entityId))).getSingleOrNull();
        if (row != null) {
          final collectionName = row.type == 'credit' ? 'liabilities' : 'accounts';
          final docRef = _firestore.collection('users').doc(uid).collection(collectionName).doc(row.id);
          await docRef.set({
            'id': row.id,
            'name': row.name,
            'type': row.type,
            'notes': row.notes,
            'isArchived': row.isArchived,
            'createdAt': Timestamp.fromDate(row.createdAt),
            'updatedAt': Timestamp.fromDate(row.updatedAt),
            'syncStatus': 'synced',
            'deviceId': row.deviceId,
            'lastSyncedAt': FieldValue.serverTimestamp(),
          });
          await (_db.update(_db.accounts)..where((tbl) => tbl.id.equals(row.id)))
              .write(AccountsCompanion(
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(DateTime.now().toUtc()),
              ));
        }
        break;

      case 'person':
        final row = await (_db.select(_db.people)..where((tbl) => tbl.id.equals(entityId))).getSingleOrNull();
        if (row != null) {
          final docRef = _firestore.collection('users').doc(uid).collection('receivables').doc(row.id);
          await docRef.set({
            'id': row.id,
            'name': row.name,
            'phone': row.phone,
            'notes': row.notes,
            'isArchived': row.isArchived,
            'type': row.type,
            'createdAt': Timestamp.fromDate(row.createdAt),
            'updatedAt': Timestamp.fromDate(row.updatedAt),
            'syncStatus': 'synced',
            'deviceId': row.deviceId,
            'lastSyncedAt': FieldValue.serverTimestamp(),
          });
          await (_db.update(_db.people)..where((tbl) => tbl.id.equals(row.id)))
              .write(PeopleCompanion(
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(DateTime.now().toUtc()),
              ));
        }
        break;

      case 'investment':
        final row = await (_db.select(_db.investments)..where((tbl) => tbl.id.equals(entityId))).getSingleOrNull();
        if (row != null) {
          final docRef = _firestore.collection('users').doc(uid).collection('investments').doc(row.id);
          await docRef.set({
            'id': row.id,
            'name': row.name,
            'type': row.type,
            'symbol': row.symbol,
            'marketValue': row.marketValue,
            'marketValueUpdatedAt': row.marketValueUpdatedAt != null ? Timestamp.fromDate(row.marketValueUpdatedAt!) : null,
            'isArchived': row.isArchived,
            'notes': row.notes,
            'purchaseDate': row.purchaseDate != null ? Timestamp.fromDate(row.purchaseDate!) : null,
            'purchaseTime': row.purchaseTime,
            'createdAt': Timestamp.fromDate(row.createdAt),
            'updatedAt': Timestamp.fromDate(row.updatedAt),
            'syncStatus': 'synced',
            'deviceId': row.deviceId,
            'lastSyncedAt': FieldValue.serverTimestamp(),
          });
          await (_db.update(_db.investments)..where((tbl) => tbl.id.equals(row.id)))
              .write(InvestmentsCompanion(
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(DateTime.now().toUtc()),
              ));
        }
        break;

      case 'investment_lot':
        final row = await (_db.select(_db.investmentLots)..where((tbl) => tbl.id.equals(entityId))).getSingleOrNull();
        if (row != null) {
          final docRef = _firestore.collection('users').doc(uid).collection('investment_lots').doc(row.id);
          await docRef.set({
            'id': row.id,
            'investmentId': row.investmentId,
            'buyTransactionId': row.buyTransactionId,
            'unitsPurchased': row.unitsPurchased,
            'unitsRemaining': row.unitsRemaining,
            'costPerUnit': row.costPerUnit,
            'purchaseDate': Timestamp.fromDate(row.purchaseDate),
            'createdAt': Timestamp.fromDate(row.createdAt),
            'updatedAt': Timestamp.fromDate(row.updatedAt),
            'syncStatus': 'synced',
            'deviceId': row.deviceId,
            'lastSyncedAt': FieldValue.serverTimestamp(),
          });
          await (_db.update(_db.investmentLots)..where((tbl) => tbl.id.equals(row.id)))
              .write(InvestmentLotsCompanion(
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(DateTime.now().toUtc()),
              ));
        }
        break;

      case 'transaction':
        final row = await (_db.select(_db.transactions)..where((tbl) => tbl.id.equals(entityId))).getSingleOrNull();
        if (row != null) {
          final docRef = _firestore.collection('users').doc(uid).collection('transactions').doc(row.id);
          await docRef.set({
            'id': row.id,
            'type': row.type,
            'amount': row.amount,
            'category': row.category,
            'fromAccountId': row.fromAccountId,
            'toAccountId': row.toAccountId,
            'personId': row.personId,
            'investmentId': row.investmentId,
            'voidedTransactionId': row.voidedTransactionId,
            'notes': row.notes,
            'pricePerUnit': row.pricePerUnit,
            'units': row.units,
            'transactionDate': Timestamp.fromDate(row.transactionDate),
            'createdAt': Timestamp.fromDate(row.createdAt),
            'updatedAt': Timestamp.fromDate(row.updatedAt),
            'syncStatus': 'synced',
            'deviceId': row.deviceId,
            'lastSyncedAt': FieldValue.serverTimestamp(),
          });
          await (_db.update(_db.transactions)..where((tbl) => tbl.id.equals(row.id)))
              .write(TransactionsCompanion(
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(DateTime.now().toUtc()),
              ));
        }
        break;

      case 'expected_income':
        final row = await (_db.select(_db.expectedIncomes)..where((tbl) => tbl.id.equals(entityId))).getSingleOrNull();
        if (row != null) {
          final docRef = _firestore.collection('users').doc(uid).collection('expected_income').doc(row.id);
          await docRef.set({
            'id': row.id,
            'source': row.source,
            'amount': row.amount,
            'status': row.status,
            'expectedDate': row.expectedDate != null ? Timestamp.fromDate(row.expectedDate!) : null,
            'receivedTransactionId': row.receivedTransactionId,
            'notes': row.notes,
            'createdAt': Timestamp.fromDate(row.createdAt),
            'updatedAt': Timestamp.fromDate(row.updatedAt),
            'syncStatus': 'synced',
            'deviceId': row.deviceId,
            'lastSyncedAt': FieldValue.serverTimestamp(),
          });
          await (_db.update(_db.expectedIncomes)..where((tbl) => tbl.id.equals(row.id)))
              .write(ExpectedIncomesCompanion(
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(DateTime.now().toUtc()),
              ));
        }
        break;

      case 'goal':
        final row = await (_db.select(_db.goals)..where((tbl) => tbl.id.equals(entityId))).getSingleOrNull();
        if (row != null) {
          final docRef = _firestore.collection('users').doc(uid).collection('goals').doc(row.id);
          await docRef.set({
            'id': row.id,
            'name': row.name,
            'targetAmount': row.targetAmount,
            'currentAmount': row.currentAmount,
            'deadline': row.deadline != null ? Timestamp.fromDate(row.deadline!) : null,
            'notes': row.notes,
            'isArchived': row.isArchived,
            'createdAt': Timestamp.fromDate(row.createdAt),
            'updatedAt': Timestamp.fromDate(row.updatedAt),
            'syncStatus': 'synced',
            'deviceId': row.deviceId,
            'lastSyncedAt': FieldValue.serverTimestamp(),
          });
          await (_db.update(_db.goals)..where((tbl) => tbl.id.equals(row.id)))
              .write(GoalsCompanion(
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(DateTime.now().toUtc()),
              ));
        }
        break;

      case 'snapshot':
        final row = await (_db.select(_db.snapshots)..where((tbl) => tbl.id.equals(entityId))).getSingleOrNull();
        if (row != null) {
          final docRef = _firestore.collection('users').doc(uid).collection('snapshots').doc(row.id);
          await docRef.set({
            'id': row.id,
            'snapshotDate': Timestamp.fromDate(row.snapshotDate),
            'netWorth': row.netWorth,
            'assets': row.assets,
            'liabilities': row.liabilities,
            'receivables': row.receivables,
            'investedCapital': row.investedCapital,
            'expectedIncome': row.expectedIncome,
            'createdAt': Timestamp.fromDate(row.createdAt),
            'updatedAt': Timestamp.fromDate(row.updatedAt),
            'syncStatus': 'synced',
            'deviceId': row.deviceId,
            'lastSyncedAt': FieldValue.serverTimestamp(),
          });
          await (_db.update(_db.snapshots)..where((tbl) => tbl.id.equals(row.id)))
              .write(SnapshotsCompanion(
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(DateTime.now().toUtc()),
              ));
        }
        break;

      case 'adjustment':
        final row = await (_db.select(_db.adjustments)..where((tbl) => tbl.id.equals(entityId))).getSingleOrNull();
        if (row != null) {
          final docRef = _firestore.collection('users').doc(uid).collection('adjustments').doc(row.id);
          await docRef.set({
            'id': row.id,
            'entityType': row.entityType,
            'entityId': row.entityId,
            'oldAmount': row.oldAmount,
            'newAmount': row.newAmount,
            'adjustedAmount': row.adjustedAmount,
            'reason': row.reason,
            'createdAt': Timestamp.fromDate(row.createdAt),
            'updatedAt': row.updatedAt != null ? Timestamp.fromDate(row.updatedAt!) : null,
            'syncStatus': 'synced',
            'deviceId': row.deviceId,
            'lastSyncedAt': FieldValue.serverTimestamp(),
          });
          await (_db.update(_db.adjustments)..where((tbl) => tbl.id.equals(row.id)))
              .write(AdjustmentsCompanion(
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(DateTime.now().toUtc()),
              ));
        }
        break;

      case 'mtf_position':
        final row = await (_db.select(_db.mtfPositions)..where((tbl) => tbl.id.equals(entityId))).getSingleOrNull();
        if (row != null) {
          final docRef = _firestore.collection('users').doc(uid).collection('mtf_positions').doc(row.id);
          await docRef.set({
            'id': row.id,
            'investmentId': row.investmentId,
            'broker': row.broker,
            'instrument': row.instrument,
            'units': row.units,
            'averagePrice': row.averagePrice,
            'ownCapital': row.ownCapital,
            'borrowedCapital': row.borrowedCapital,
            'interestRate': row.interestRate,
            'openingDate': Timestamp.fromDate(row.openingDate),
            'interestStartDate': Timestamp.fromDate(row.interestStartDate),
            'purchaseDate': row.purchaseDate != null ? Timestamp.fromDate(row.purchaseDate!) : null,
            'purchaseTime': row.purchaseTime,
            'closedDate': row.closedDate != null ? Timestamp.fromDate(row.closedDate!) : null,
            'isClosed': row.isClosed,
            'createdAt': Timestamp.fromDate(row.createdAt),
            'updatedAt': Timestamp.fromDate(row.updatedAt),
            'syncStatus': 'synced',
            'deviceId': row.deviceId,
            'lastSyncedAt': FieldValue.serverTimestamp(),
          });
          await (_db.update(_db.mtfPositions)..where((tbl) => tbl.id.equals(row.id)))
              .write(MtfPositionsCompanion(
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(DateTime.now().toUtc()),
              ));
        }
        break;

      case 'sip':
        final row = await (_db.select(_db.sips)..where((tbl) => tbl.id.equals(entityId))).getSingleOrNull();
        if (row != null) {
          final docRef = _firestore.collection('users').doc(uid).collection('sips').doc(row.id);
          await docRef.set({
            'id': row.id,
            'investmentId': row.investmentId,
            'amount': row.amount,
            'frequency': row.frequency,
            'sipDate': row.sipDate,
            'startDate': Timestamp.fromDate(row.startDate),
            'endDate': row.endDate != null ? Timestamp.fromDate(row.endDate!) : null,
            'autoCreate': row.autoCreate,
            'isActive': row.isActive,
            'importMode': row.importMode,
            'completedInstallmentsOverride': row.completedInstallmentsOverride,
            'worthCreationDate': row.worthCreationDate != null ? Timestamp.fromDate(row.worthCreationDate!) : null,
            'createdAt': Timestamp.fromDate(row.createdAt),
            'updatedAt': Timestamp.fromDate(row.updatedAt),
            'syncStatus': 'synced',
            'deviceId': row.deviceId,
            'lastSyncedAt': FieldValue.serverTimestamp(),
          });
          await (_db.update(_db.sips)..where((tbl) => tbl.id.equals(row.id)))
              .write(SipsCompanion(
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(DateTime.now().toUtc()),
              ));
        }
        break;

      case 'setting':
        final row = await (_db.select(_db.settings)..where((tbl) => tbl.key.equals(entityId))).getSingleOrNull();
        if (row != null) {
          final docRef = _firestore.collection('users').doc(uid).collection('settings').doc(row.key);
          await docRef.set({
            'key': row.key,
            'value': row.value,
            'createdAt': row.createdAt != null ? Timestamp.fromDate(row.createdAt!) : null,
            'updatedAt': row.updatedAt != null ? Timestamp.fromDate(row.updatedAt!) : null,
            'syncStatus': 'synced',
            'deviceId': row.deviceId,
            'lastSyncedAt': FieldValue.serverTimestamp(),
          });
          await (_db.update(_db.settings)..where((tbl) => tbl.key.equals(row.key)))
              .write(SettingsCompanion(
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(DateTime.now().toUtc()),
              ));
        }
        break;
    }
  }

  String _getCollectionName(String entityType, String? rowType) {
    switch (entityType) {
      case 'account':
        return rowType == 'credit' ? 'liabilities' : 'accounts';
      case 'person':
        return 'receivables';
      case 'investment':
        return 'investments';
      case 'investment_lot':
        return 'investment_lots';
      case 'transaction':
        return 'transactions';
      case 'expected_income':
        return 'expected_income';
      case 'goal':
        return 'goals';
      case 'snapshot':
        return 'snapshots';
      case 'adjustment':
        return 'adjustments';
      case 'mtf_position':
        return 'mtf_positions';
      case 'sip':
        return 'sips';
      case 'setting':
        return 'settings';
      default:
        return entityType;
    }
  }

  String _getEntityTypeFromCollection(String collectionName) {
    switch (collectionName) {
      case 'accounts':
      case 'liabilities':
        return 'account';
      case 'receivables':
        return 'person';
      case 'investments':
        return 'investment';
      case 'investment_lots':
        return 'investment_lot';
      case 'transactions':
        return 'transaction';
      case 'expected_income':
        return 'expected_income';
      case 'goals':
        return 'goal';
      case 'snapshots':
        return 'snapshot';
      case 'adjustments':
        return 'adjustment';
      case 'mtf_positions':
        return 'mtf_position';
      case 'sips':
        return 'sip';
      case 'settings':
        return 'setting';
      default:
        return collectionName;
    }
  }

  Future<dynamic> _getLocalRow(TableInfo table, String keyOrId) async {
    if (table.tableName == 'settings') {
      return await (_db.select(_db.settings)..where((tbl) => tbl.key.equals(keyOrId))).getSingleOrNull();
    }
    if (table == _db.accounts) {
      return await (_db.select(_db.accounts)..where((tbl) => tbl.id.equals(keyOrId))).getSingleOrNull();
    } else if (table == _db.people) {
      return await (_db.select(_db.people)..where((tbl) => tbl.id.equals(keyOrId))).getSingleOrNull();
    } else if (table == _db.investments) {
      return await (_db.select(_db.investments)..where((tbl) => tbl.id.equals(keyOrId))).getSingleOrNull();
    } else if (table == _db.investmentLots) {
      return await (_db.select(_db.investmentLots)..where((tbl) => tbl.id.equals(keyOrId))).getSingleOrNull();
    } else if (table == _db.transactions) {
      return await (_db.select(_db.transactions)..where((tbl) => tbl.id.equals(keyOrId))).getSingleOrNull();
    } else if (table == _db.expectedIncomes) {
      return await (_db.select(_db.expectedIncomes)..where((tbl) => tbl.id.equals(keyOrId))).getSingleOrNull();
    } else if (table == _db.goals) {
      return await (_db.select(_db.goals)..where((tbl) => tbl.id.equals(keyOrId))).getSingleOrNull();
    } else if (table == _db.snapshots) {
      return await (_db.select(_db.snapshots)..where((tbl) => tbl.id.equals(keyOrId))).getSingleOrNull();
    } else if (table == _db.adjustments) {
      return await (_db.select(_db.adjustments)..where((tbl) => tbl.id.equals(keyOrId))).getSingleOrNull();
    } else if (table == _db.mtfPositions) {
      return await (_db.select(_db.mtfPositions)..where((tbl) => tbl.id.equals(keyOrId))).getSingleOrNull();
    } else if (table == _db.sips) {
      return await (_db.select(_db.sips)..where((tbl) => tbl.id.equals(keyOrId))).getSingleOrNull();
    }
    return null;
  }

  Future<void> _insertLocalRow(TableInfo table, dynamic entity) async {
    if (table == _db.accounts) {
      await _db.into(_db.accounts).insert(entity as Account, mode: InsertMode.insertOrReplace);
    } else if (table == _db.people) {
      await _db.into(_db.people).insert(entity as Person, mode: InsertMode.insertOrReplace);
    } else if (table == _db.investments) {
      await _db.into(_db.investments).insert(entity as Investment, mode: InsertMode.insertOrReplace);
    } else if (table == _db.investmentLots) {
      await _db.into(_db.investmentLots).insert(entity as InvestmentLot, mode: InsertMode.insertOrReplace);
    } else if (table == _db.transactions) {
      await _db.into(_db.transactions).insert(entity as Transaction, mode: InsertMode.insertOrReplace);
    } else if (table == _db.expectedIncomes) {
      await _db.into(_db.expectedIncomes).insert(entity as ExpectedIncome, mode: InsertMode.insertOrReplace);
    } else if (table == _db.goals) {
      await _db.into(_db.goals).insert(entity as Goal, mode: InsertMode.insertOrReplace);
    } else if (table == _db.snapshots) {
      await _db.into(_db.snapshots).insert(entity as Snapshot, mode: InsertMode.insertOrReplace);
    } else if (table == _db.adjustments) {
      await _db.into(_db.adjustments).insert(entity as Adjustment, mode: InsertMode.insertOrReplace);
    } else if (table == _db.mtfPositions) {
      await _db.into(_db.mtfPositions).insert(entity as MtfPosition, mode: InsertMode.insertOrReplace);
    } else if (table == _db.sips) {
      await _db.into(_db.sips).insert(entity as Sip, mode: InsertMode.insertOrReplace);
    } else if (table == _db.settings) {
      await _db.into(_db.settings).insert(entity as Setting, mode: InsertMode.insertOrReplace);
    }
  }

  Future<void> _updateLocalRow(TableInfo table, dynamic entity) async {
    await _insertLocalRow(table, entity);
  }

  DateTime? _getUpdatedAt(dynamic entity) {
    if (entity is Account) return entity.updatedAt;
    if (entity is Person) return entity.updatedAt;
    if (entity is Investment) return entity.updatedAt;
    if (entity is InvestmentLot) return entity.updatedAt;
    if (entity is Transaction) return entity.updatedAt;
    if (entity is ExpectedIncome) return entity.updatedAt;
    if (entity is Goal) return entity.updatedAt;
    if (entity is Snapshot) return entity.updatedAt;
    if (entity is Adjustment) return entity.updatedAt;
    if (entity is MtfPosition) return entity.updatedAt;
    if (entity is Sip) return entity.updatedAt;
    if (entity is Setting) return entity.updatedAt;
    return null;
  }

  // --- Collection Mappers ---

  DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else {
      return DateTime.now().toUtc();
    }
  }

  DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    return _parseDateTime(value);
  }

  Account _mapAccount(Map<String, dynamic> data) {
    return Account(
      id: data['id'] as String,
      name: data['name'] as String,
      type: data['type'] as String,
      notes: data['notes'] as String?,
      isArchived: data['isArchived'] as int? ?? 0,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      syncStatus: 'synced',
      lastSyncedAt: _parseNullableDateTime(data['lastSyncedAt']),
      deviceId: data['deviceId'] as String?,
    );
  }

  Person _mapPerson(Map<String, dynamic> data) {
    return Person(
      id: data['id'] as String,
      name: data['name'] as String,
      phone: data['phone'] as String?,
      notes: data['notes'] as String?,
      isArchived: data['isArchived'] as int? ?? 0,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      syncStatus: 'synced',
      lastSyncedAt: _parseNullableDateTime(data['lastSyncedAt']),
      deviceId: data['deviceId'] as String?,
      type: data['type'] as String? ?? 'personal_loan',
    );
  }

  Investment _mapInvestment(Map<String, dynamic> data) {
    return Investment(
      id: data['id'] as String,
      name: data['name'] as String,
      type: data['type'] as String,
      symbol: data['symbol'] as String?,
      marketValue: (data['marketValue'] as num?)?.toDouble(),
      marketValueUpdatedAt: _parseNullableDateTime(data['marketValueUpdatedAt']),
      isArchived: data['isArchived'] as int? ?? 0,
      notes: data['notes'] as String?,
      purchaseDate: _parseNullableDateTime(data['purchaseDate']),
      purchaseTime: data['purchaseTime'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      syncStatus: 'synced',
      lastSyncedAt: _parseNullableDateTime(data['lastSyncedAt']),
      deviceId: data['deviceId'] as String?,
    );
  }

  InvestmentLot _mapInvestmentLot(Map<String, dynamic> data) {
    return InvestmentLot(
      id: data['id'] as String,
      investmentId: data['investmentId'] as String,
      buyTransactionId: data['buyTransactionId'] as String,
      unitsPurchased: (data['unitsPurchased'] as num).toDouble(),
      unitsRemaining: (data['unitsRemaining'] as num).toDouble(),
      costPerUnit: (data['costPerUnit'] as num).toDouble(),
      purchaseDate: _parseDateTime(data['purchaseDate']),
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      syncStatus: 'synced',
      lastSyncedAt: _parseNullableDateTime(data['lastSyncedAt']),
      deviceId: data['deviceId'] as String?,
    );
  }

  Transaction _mapTransaction(Map<String, dynamic> data) {
    return Transaction(
      id: data['id'] as String,
      type: data['type'] as String,
      amount: (data['amount'] as num).toDouble(),
      category: data['category'] as String?,
      fromAccountId: data['fromAccountId'] as String?,
      toAccountId: data['toAccountId'] as String?,
      personId: data['personId'] as String?,
      investmentId: data['investmentId'] as String?,
      voidedTransactionId: data['voidedTransactionId'] as String?,
      notes: data['notes'] as String?,
      pricePerUnit: (data['pricePerUnit'] as num?)?.toDouble(),
      units: (data['units'] as num?)?.toDouble(),
      transactionDate: _parseDateTime(data['transactionDate']),
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      syncStatus: 'synced',
      lastSyncedAt: _parseNullableDateTime(data['lastSyncedAt']),
      deviceId: data['deviceId'] as String?,
    );
  }

  ExpectedIncome _mapExpectedIncome(Map<String, dynamic> data) {
    return ExpectedIncome(
      id: data['id'] as String,
      source: data['source'] as String,
      amount: (data['amount'] as num).toDouble(),
      status: data['status'] as String,
      expectedDate: _parseNullableDateTime(data['expectedDate']),
      receivedTransactionId: data['receivedTransactionId'] as String?,
      notes: data['notes'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      syncStatus: 'synced',
      lastSyncedAt: _parseNullableDateTime(data['lastSyncedAt']),
      deviceId: data['deviceId'] as String?,
    );
  }

  Goal _mapGoal(Map<String, dynamic> data) {
    return Goal(
      id: data['id'] as String,
      name: data['name'] as String,
      targetAmount: (data['targetAmount'] as num).toDouble(),
      currentAmount: (data['currentAmount'] as num).toDouble(),
      deadline: _parseNullableDateTime(data['deadline']),
      notes: data['notes'] as String?,
      isArchived: data['isArchived'] as int? ?? 0,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      syncStatus: 'synced',
      lastSyncedAt: _parseNullableDateTime(data['lastSyncedAt']),
      deviceId: data['deviceId'] as String?,
    );
  }

  Snapshot _mapSnapshot(Map<String, dynamic> data) {
    return Snapshot(
      id: data['id'] as String,
      snapshotDate: _parseDateTime(data['snapshotDate']),
      netWorth: (data['netWorth'] as num).toDouble(),
      assets: (data['assets'] as num).toDouble(),
      liabilities: (data['liabilities'] as num).toDouble(),
      receivables: (data['receivables'] as num? ?? 0.0).toDouble(),
      investedCapital: (data['investedCapital'] as num).toDouble(),
      expectedIncome: (data['expectedIncome'] as num).toDouble(),
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      syncStatus: 'synced',
      lastSyncedAt: _parseNullableDateTime(data['lastSyncedAt']),
      deviceId: data['deviceId'] as String?,
    );
  }

  Adjustment _mapAdjustment(Map<String, dynamic> data) {
    return Adjustment(
      id: data['id'] as String,
      entityType: data['entityType'] as String,
      entityId: data['entityId'] as String,
      oldAmount: (data['oldAmount'] as num).toDouble(),
      newAmount: (data['newAmount'] as num).toDouble(),
      adjustedAmount: (data['adjustedAmount'] as num).toDouble(),
      reason: data['reason'] as String,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseNullableDateTime(data['updatedAt']),
      syncStatus: 'synced',
      lastSyncedAt: _parseNullableDateTime(data['lastSyncedAt']),
      deviceId: data['deviceId'] as String?,
    );
  }

  MtfPosition _mapMtfPosition(Map<String, dynamic> data) {
    return MtfPosition(
      id: data['id'] as String,
      investmentId: data['investmentId'] as String,
      broker: data['broker'] as String,
      instrument: data['instrument'] as String,
      units: (data['units'] as num).toDouble(),
      averagePrice: (data['averagePrice'] as num).toDouble(),
      ownCapital: (data['ownCapital'] as num).toDouble(),
      borrowedCapital: (data['borrowedCapital'] as num).toDouble(),
      interestRate: (data['interestRate'] as num).toDouble(),
      openingDate: _parseDateTime(data['openingDate']),
      interestStartDate: _parseDateTime(data['interestStartDate']),
      purchaseDate: _parseNullableDateTime(data['purchaseDate']),
      purchaseTime: data['purchaseTime'] as String?,
      closedDate: _parseNullableDateTime(data['closedDate']),
      isClosed: data['isClosed'] as int? ?? 0,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      syncStatus: 'synced',
      lastSyncedAt: _parseNullableDateTime(data['lastSyncedAt']),
      deviceId: data['deviceId'] as String?,
    );
  }

  Sip _mapSip(Map<String, dynamic> data) {
    return Sip(
      id: data['id'] as String,
      investmentId: data['investmentId'] as String,
      amount: (data['amount'] as num).toDouble(),
      frequency: data['frequency'] as String,
      sipDate: data['sipDate'] as int,
      startDate: _parseDateTime(data['startDate']),
      endDate: _parseNullableDateTime(data['endDate']),
      autoCreate: data['autoCreate'] as int? ?? 0,
      isActive: data['isActive'] as int? ?? 1,
      importMode: data['importMode'] as String? ?? 'paid',
      completedInstallmentsOverride: data['completedInstallmentsOverride'] as int? ?? 0,
      worthCreationDate: _parseNullableDateTime(data['worthCreationDate']),
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      syncStatus: 'synced',
      lastSyncedAt: _parseNullableDateTime(data['lastSyncedAt']),
      deviceId: data['deviceId'] as String?,
    );
  }

  Setting _mapSetting(Map<String, dynamic> data) {
    return Setting(
      key: data['key'] as String,
      value: data['value'] as String?,
      createdAt: _parseNullableDateTime(data['createdAt']),
      updatedAt: _parseNullableDateTime(data['updatedAt']),
      syncStatus: 'synced',
      lastSyncedAt: _parseNullableDateTime(data['lastSyncedAt']),
      deviceId: data['deviceId'] as String?,
    );
  }

  Future<bool> isLocalDatabaseEmpty() async {
    final accountsCount = await _db.select(_db.accounts).get().then((l) => l.length);
    final transactionsCount = await _db.select(_db.transactions).get().then((l) => l.length);
    final investmentsCount = await _db.select(_db.investments).get().then((l) => l.length);
    final peopleCount = await _db.select(_db.people).get().then((l) => l.length);
    final expectedIncomesCount = await _db.select(_db.expectedIncomes).get().then((l) => l.length);
    final goalsCount = await _db.select(_db.goals).get().then((l) => l.length);
    final mtfPositionsCount = await _db.select(_db.mtfPositions).get().then((l) => l.length);
    final sipsCount = await _db.select(_db.sips).get().then((l) => l.length);
    
    return (accountsCount == 0 &&
            transactionsCount == 0 &&
            investmentsCount == 0 &&
            peopleCount == 0 &&
            expectedIncomesCount == 0 &&
            goalsCount == 0 &&
            mtfPositionsCount == 0 &&
            sipsCount == 0);
  }

  Future<int> getCloudRecordCount(String uid) async {
    final collections = [
      'accounts',
      'liabilities',
      'receivables',
      'investments',
      'investment_lots',
      'transactions',
      'expected_income',
      'goals',
      'snapshots',
      'adjustments',
      'mtf_positions',
      'sips',
      'settings'
    ];
    
    int totalCount = 0;
    for (final col in collections) {
      try {
        final countSnap = await _firestore
            .collection('users')
            .doc(uid)
            .collection(col)
            .count()
            .get();
        totalCount += countSnap.count ?? 0;
      } catch (e) {
        print('[SyncService] Failed to count collection $col: $e');
      }
    }
    return totalCount;
  }

  Future<void> clearLocalDataBeforeRestore() async {
    await _db.transaction(() async {
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.investmentLotConsumptions).go();
      await _db.delete(_db.investmentLots).go();
      await _db.delete(_db.investments).go();
      await _db.delete(_db.accounts).go();
      await _db.delete(_db.people).go();
      await _db.delete(_db.expectedIncomes).go();
      await _db.delete(_db.goals).go();
      await _db.delete(_db.goalMilestones).go();
      await _db.delete(_db.snapshots).go();
      await _db.delete(_db.settings).go();
      await _db.delete(_db.auditLogs).go();
      await _db.delete(_db.adjustments).go();
      await _db.delete(_db.accountBalanceCaches).go();
      await _db.delete(_db.personBalanceCaches).go();
      await _db.delete(_db.investmentBalanceCaches).go();
      await _db.delete(_db.mtfPositions).go();
      await _db.delete(_db.sips).go();
      await _db.delete(_db.dailyCheckIns).go();
      await _db.delete(_db.syncQueues).go();
    });
  }
  Future<void> _uploadBackupToStorage(String uid) async {
    try {
      print('[SyncService] Uploading database backup to Cloudinary...');
      final backupService = _ref.read(realBackupServiceProvider);
      final passphrase = _ref.read(databasePassphraseProvider);
      final encryptedJson = await backupService.exportBackup(passphrase);
      
      final secureUrl = await _ref.read(cloudinaryServiceProvider).uploadBackupString(
        backupJson: encryptedJson,
        userId: uid,
      );
      
      // Save backup metadata in Firestore settings
      await _firestore.collection('users').doc(uid).collection('settings').doc('backupMetadata').set({
        'key': 'backupMetadata',
        'value': jsonEncode({
          'backupUrl': secureUrl,
          'uploadedAt': DateTime.now().toUtc().toIso8601String(),
        }),
        'updatedAt': FieldValue.serverTimestamp(),
        'syncStatus': 'synced',
      });
      print('[SyncService] Database backup uploaded to Cloudinary successfully. URL saved in Firestore.');
    } catch (e) {
      print('[SyncService] Failed to upload backup to Cloudinary: $e');
    }
  }

  Future<void> manualRestore() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final uid = user.uid;

    await clearLocalDataBeforeRestore();
    await seedDatabaseIfEmpty(_db);

    // Try downloading and restoring from Cloudinary
    bool storageRestoreSuccess = false;
    try {
      print('[SyncService] Attempting to restore from Cloudinary...');
      final doc = await _firestore.collection('users').doc(uid).collection('settings').doc('backupMetadata').get();
      if (doc.exists && doc.data() != null) {
        final metaString = doc.data()!['value'] as String?;
        if (metaString != null) {
          final meta = jsonDecode(metaString);
          final backupUrl = meta['backupUrl'] as String?;
          if (backupUrl != null) {
            print('[SyncService] Downloading backup from Cloudinary URL: $backupUrl');
            final response = await http.get(Uri.parse(backupUrl));
            if (response.statusCode == 200) {
              final encryptedJson = response.body;
              final backupService = _ref.read(realBackupServiceProvider);
              final passphrase = _ref.read(databasePassphraseProvider);
              await backupService.restoreBackup(encryptedJson, passphrase);
              print('[SyncService] Cloudinary restore complete.');
              storageRestoreSuccess = true;
            } else {
              print('[SyncService] Failed to download backup file: status ${response.statusCode}');
            }
          }
        }
      }
    } catch (e) {
      print('[SyncService] Cloudinary restore failed/not found: $e. Falling back to Firestore pull...');
    }

    if (!storageRestoreSuccess) {
      await pullRemoteChanges();
    }
    await _balanceCacheService.rebuildCache();
    await _searchIndexService.rebuildIndex();

    // Trigger lazy snapshot generation/backfilling after restore completes
    try {
      final snapshotService = _ref.read(realSnapshotServiceProvider);
      await snapshotService.triggerLazySnapshots();
      print('[SyncService] Lazy snapshots backfilled successfully after restore.');
    } catch (e) {
      print('[SyncService] Failed to generate snapshots after restore: $e');
    }
  }

  Future<void> forceSync() async {
    final connected = await _networkMonitor.isConnected;
    if (!connected) return;
    await processQueue();
    await pullRemoteChanges();

    final user = _auth.currentUser;
    if (user != null) {
      await _uploadBackupToStorage(user.uid);
    }
  }

  Future<void> forceBackupNow() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final uid = user.uid;

    // 1. Upload accounts
    final accounts = await _db.select(_db.accounts).get();
    for (final row in accounts) {
      final collectionName = row.type == 'credit' ? 'liabilities' : 'accounts';
      await _firestore.collection('users').doc(uid).collection(collectionName).doc(row.id).set({
        'id': row.id,
        'name': row.name,
        'type': row.type,
        'notes': row.notes,
        'isArchived': row.isArchived,
        'createdAt': Timestamp.fromDate(row.createdAt),
        'updatedAt': Timestamp.fromDate(row.updatedAt),
        'syncStatus': 'synced',
        'deviceId': row.deviceId,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      });
      await (_db.update(_db.accounts)..where((tbl) => tbl.id.equals(row.id)))
          .write(AccountsCompanion(
            syncStatus: const Value('synced'),
            lastSyncedAt: Value(DateTime.now().toUtc()),
          ));
    }
    
    // 2. Upload people (receivables)
    final people = await _db.select(_db.people).get();
    for (final row in people) {
      await _firestore.collection('users').doc(uid).collection('receivables').doc(row.id).set({
        'id': row.id,
        'name': row.name,
        'phone': row.phone,
        'notes': row.notes,
        'isArchived': row.isArchived,
        'createdAt': Timestamp.fromDate(row.createdAt),
        'updatedAt': Timestamp.fromDate(row.updatedAt),
        'syncStatus': 'synced',
        'deviceId': row.deviceId,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      });
      await (_db.update(_db.people)..where((tbl) => tbl.id.equals(row.id)))
          .write(PeopleCompanion(
            syncStatus: const Value('synced'),
            lastSyncedAt: Value(DateTime.now().toUtc()),
          ));
    }
    
    // 3. Upload investments
    final investments = await _db.select(_db.investments).get();
    for (final row in investments) {
      await _firestore.collection('users').doc(uid).collection('investments').doc(row.id).set({
        'id': row.id,
        'name': row.name,
        'type': row.type,
        'symbol': row.symbol,
        'marketValue': row.marketValue,
        'marketValueUpdatedAt': row.marketValueUpdatedAt != null ? Timestamp.fromDate(row.marketValueUpdatedAt!) : null,
        'isArchived': row.isArchived,
        'notes': row.notes,
        'purchaseDate': row.purchaseDate != null ? Timestamp.fromDate(row.purchaseDate!) : null,
        'purchaseTime': row.purchaseTime,
        'createdAt': Timestamp.fromDate(row.createdAt),
        'updatedAt': Timestamp.fromDate(row.updatedAt),
        'syncStatus': 'synced',
        'deviceId': row.deviceId,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      });
      await (_db.update(_db.investments)..where((tbl) => tbl.id.equals(row.id)))
          .write(InvestmentsCompanion(
            syncStatus: const Value('synced'),
            lastSyncedAt: Value(DateTime.now().toUtc()),
          ));
    }

    // 4. Upload investment lots
    final lots = await _db.select(_db.investmentLots).get();
    for (final row in lots) {
      await _firestore.collection('users').doc(uid).collection('investment_lots').doc(row.id).set({
        'id': row.id,
        'investmentId': row.investmentId,
        'buyTransactionId': row.buyTransactionId,
        'unitsPurchased': row.unitsPurchased,
        'unitsRemaining': row.unitsRemaining,
        'costPerUnit': row.costPerUnit,
        'purchaseDate': Timestamp.fromDate(row.purchaseDate),
        'createdAt': Timestamp.fromDate(row.createdAt),
        'updatedAt': Timestamp.fromDate(row.updatedAt),
        'syncStatus': 'synced',
        'deviceId': row.deviceId,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      });
      await (_db.update(_db.investmentLots)..where((tbl) => tbl.id.equals(row.id)))
          .write(InvestmentLotsCompanion(
            syncStatus: const Value('synced'),
            lastSyncedAt: Value(DateTime.now().toUtc()),
          ));
    }

    // 5. Upload transactions
    final transactions = await _db.select(_db.transactions).get();
    for (final row in transactions) {
      await _firestore.collection('users').doc(uid).collection('transactions').doc(row.id).set({
        'id': row.id,
        'type': row.type,
        'amount': row.amount,
        'category': row.category,
        'fromAccountId': row.fromAccountId,
        'toAccountId': row.toAccountId,
        'personId': row.personId,
        'investmentId': row.investmentId,
        'voidedTransactionId': row.voidedTransactionId,
        'notes': row.notes,
        'pricePerUnit': row.pricePerUnit,
        'units': row.units,
        'transactionDate': Timestamp.fromDate(row.transactionDate),
        'createdAt': Timestamp.fromDate(row.createdAt),
        'updatedAt': Timestamp.fromDate(row.updatedAt),
        'syncStatus': 'synced',
        'deviceId': row.deviceId,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      });
      await (_db.update(_db.transactions)..where((tbl) => tbl.id.equals(row.id)))
          .write(TransactionsCompanion(
            syncStatus: const Value('synced'),
            lastSyncedAt: Value(DateTime.now().toUtc()),
          ));
    }

    // 6. Upload expected incomes
    final incomes = await _db.select(_db.expectedIncomes).get();
    for (final row in incomes) {
      await _firestore.collection('users').doc(uid).collection('expected_income').doc(row.id).set({
        'id': row.id,
        'source': row.source,
        'amount': row.amount,
        'status': row.status,
        'expectedDate': row.expectedDate != null ? Timestamp.fromDate(row.expectedDate!) : null,
        'receivedTransactionId': row.receivedTransactionId,
        'notes': row.notes,
        'createdAt': Timestamp.fromDate(row.createdAt),
        'updatedAt': Timestamp.fromDate(row.updatedAt),
        'syncStatus': 'synced',
        'deviceId': row.deviceId,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      });
      await (_db.update(_db.expectedIncomes)..where((tbl) => tbl.id.equals(row.id)))
          .write(ExpectedIncomesCompanion(
            syncStatus: const Value('synced'),
            lastSyncedAt: Value(DateTime.now().toUtc()),
          ));
    }

    // 7. Upload goals
    final goals = await _db.select(_db.goals).get();
    for (final row in goals) {
      await _firestore.collection('users').doc(uid).collection('goals').doc(row.id).set({
        'id': row.id,
        'name': row.name,
        'targetAmount': row.targetAmount,
        'currentAmount': row.currentAmount,
        'deadline': row.deadline != null ? Timestamp.fromDate(row.deadline!) : null,
        'notes': row.notes,
        'isArchived': row.isArchived,
        'createdAt': Timestamp.fromDate(row.createdAt),
        'updatedAt': Timestamp.fromDate(row.updatedAt),
        'syncStatus': 'synced',
        'deviceId': row.deviceId,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      });
      await (_db.update(_db.goals)..where((tbl) => tbl.id.equals(row.id)))
          .write(GoalsCompanion(
            syncStatus: const Value('synced'),
            lastSyncedAt: Value(DateTime.now().toUtc()),
          ));
    }

    // 8. Upload snapshots
    final snapshots = await _db.select(_db.snapshots).get();
    for (final row in snapshots) {
      await _firestore.collection('users').doc(uid).collection('snapshots').doc(row.id).set({
        'id': row.id,
        'snapshotDate': Timestamp.fromDate(row.snapshotDate),
        'netWorth': row.netWorth,
        'assets': row.assets,
        'liabilities': row.liabilities,
        'receivables': row.receivables,
        'investedCapital': row.investedCapital,
        'expectedIncome': row.expectedIncome,
        'createdAt': Timestamp.fromDate(row.createdAt),
        'updatedAt': Timestamp.fromDate(row.updatedAt),
        'syncStatus': 'synced',
        'deviceId': row.deviceId,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      });
      await (_db.update(_db.snapshots)..where((tbl) => tbl.id.equals(row.id)))
          .write(SnapshotsCompanion(
            syncStatus: const Value('synced'),
            lastSyncedAt: Value(DateTime.now().toUtc()),
          ));
    }

    // 9. Upload adjustments
    final adjustments = await _db.select(_db.adjustments).get();
    for (final row in adjustments) {
      await _firestore.collection('users').doc(uid).collection('adjustments').doc(row.id).set({
        'id': row.id,
        'entityType': row.entityType,
        'entityId': row.entityId,
        'oldAmount': row.oldAmount,
        'newAmount': row.newAmount,
        'adjustedAmount': row.adjustedAmount,
        'reason': row.reason,
        'createdAt': Timestamp.fromDate(row.createdAt),
        'updatedAt': row.updatedAt != null ? Timestamp.fromDate(row.updatedAt!) : null,
        'syncStatus': 'synced',
        'deviceId': row.deviceId,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      });
      await (_db.update(_db.adjustments)..where((tbl) => tbl.id.equals(row.id)))
          .write(AdjustmentsCompanion(
            syncStatus: const Value('synced'),
            lastSyncedAt: Value(DateTime.now().toUtc()),
          ));
    }

    // 10. Upload mtf positions
    final mtfList = await _db.select(_db.mtfPositions).get();
    for (final row in mtfList) {
      await _firestore.collection('users').doc(uid).collection('mtf_positions').doc(row.id).set({
        'id': row.id,
        'investmentId': row.investmentId,
        'broker': row.broker,
        'instrument': row.instrument,
        'units': row.units,
        'averagePrice': row.averagePrice,
        'ownCapital': row.ownCapital,
        'borrowedCapital': row.borrowedCapital,
        'interestRate': row.interestRate,
        'openingDate': Timestamp.fromDate(row.openingDate),
        'interestStartDate': Timestamp.fromDate(row.interestStartDate),
        'purchaseDate': row.purchaseDate != null ? Timestamp.fromDate(row.purchaseDate!) : null,
        'purchaseTime': row.purchaseTime,
        'closedDate': row.closedDate != null ? Timestamp.fromDate(row.closedDate!) : null,
        'isClosed': row.isClosed,
        'createdAt': Timestamp.fromDate(row.createdAt),
        'updatedAt': Timestamp.fromDate(row.updatedAt),
        'syncStatus': 'synced',
        'deviceId': row.deviceId,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      });
      await (_db.update(_db.mtfPositions)..where((tbl) => tbl.id.equals(row.id)))
          .write(MtfPositionsCompanion(
            syncStatus: const Value('synced'),
            lastSyncedAt: Value(DateTime.now().toUtc()),
          ));
    }

    // 11. Upload sips
    final sips = await _db.select(_db.sips).get();
    for (final row in sips) {
      await _firestore.collection('users').doc(uid).collection('sips').doc(row.id).set({
        'id': row.id,
        'investmentId': row.investmentId,
        'amount': row.amount,
        'frequency': row.frequency,
        'sipDate': row.sipDate,
        'startDate': Timestamp.fromDate(row.startDate),
        'endDate': row.endDate != null ? Timestamp.fromDate(row.endDate!) : null,
        'autoCreate': row.autoCreate,
        'isActive': row.isActive,
        'createdAt': Timestamp.fromDate(row.createdAt),
        'updatedAt': Timestamp.fromDate(row.updatedAt),
        'syncStatus': 'synced',
        'deviceId': row.deviceId,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      });
      await (_db.update(_db.sips)..where((tbl) => tbl.id.equals(row.id)))
          .write(SipsCompanion(
            syncStatus: const Value('synced'),
            lastSyncedAt: Value(DateTime.now().toUtc()),
          ));
    }

    // 12. Upload settings
    final settings = await _db.select(_db.settings).get();
    for (final row in settings) {
      await _firestore.collection('users').doc(uid).collection('settings').doc(row.key).set({
        'key': row.key,
        'value': row.value,
        'createdAt': row.createdAt != null ? Timestamp.fromDate(row.createdAt!) : null,
        'updatedAt': row.updatedAt != null ? Timestamp.fromDate(row.updatedAt!) : null,
        'syncStatus': 'synced',
        'deviceId': row.deviceId,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      });
      await (_db.update(_db.settings)..where((tbl) => tbl.key.equals(row.key)))
          .write(SettingsCompanion(
            syncStatus: const Value('synced'),
            lastSyncedAt: Value(DateTime.now().toUtc()),
          ));
    }
    await _uploadBackupToStorage(uid);
  }
}
