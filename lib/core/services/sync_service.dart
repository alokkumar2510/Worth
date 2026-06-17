import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drift/drift.dart';
import '../../database/database.dart';
import 'network_monitor.dart';
import 'conflict_resolver.dart';

class SyncService {
  final AppDatabase _db;
  final NetworkMonitor _networkMonitor;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;
  bool _isProcessingQueue = false;

  SyncService(this._db, this._networkMonitor);

  void start() {
    try {
      // 1. Listen for connectivity changes
      _connectivitySubscription = _networkMonitor.isConnectedStream.listen((connected) {
        if (connected) {
          processQueue();
          pullRemoteChanges();
        }
      });

      // Run initial check
      processQueue();
      pullRemoteChanges();
    } catch (e) {
      print('[SyncService] Failed to start: $e');
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
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

  Account _mapAccount(Map<String, dynamic> data) {
    return Account(
      id: data['id'] as String,
      name: data['name'] as String,
      type: data['type'] as String,
      notes: data['notes'] as String?,
      isArchived: data['isArchived'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      syncStatus: 'synced',
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
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
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      syncStatus: 'synced',
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
      deviceId: data['deviceId'] as String?,
    );
  }

  Investment _mapInvestment(Map<String, dynamic> data) {
    return Investment(
      id: data['id'] as String,
      name: data['name'] as String,
      type: data['type'] as String,
      symbol: data['symbol'] as String?,
      marketValue: (data['marketValue'] as num?)?.toDouble(),
      marketValueUpdatedAt: (data['marketValueUpdatedAt'] as Timestamp?)?.toDate(),
      isArchived: data['isArchived'] as int? ?? 0,
      notes: data['notes'] as String?,
      purchaseDate: (data['purchaseDate'] as Timestamp?)?.toDate(),
      purchaseTime: data['purchaseTime'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      syncStatus: 'synced',
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
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
      purchaseDate: (data['purchaseDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      syncStatus: 'synced',
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
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
      transactionDate: (data['transactionDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      syncStatus: 'synced',
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
      deviceId: data['deviceId'] as String?,
    );
  }

  ExpectedIncome _mapExpectedIncome(Map<String, dynamic> data) {
    return ExpectedIncome(
      id: data['id'] as String,
      source: data['source'] as String,
      amount: (data['amount'] as num).toDouble(),
      status: data['status'] as String,
      expectedDate: (data['expectedDate'] as Timestamp?)?.toDate(),
      receivedTransactionId: data['receivedTransactionId'] as String?,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      syncStatus: 'synced',
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
      deviceId: data['deviceId'] as String?,
    );
  }

  Goal _mapGoal(Map<String, dynamic> data) {
    return Goal(
      id: data['id'] as String,
      name: data['name'] as String,
      targetAmount: (data['targetAmount'] as num).toDouble(),
      currentAmount: (data['currentAmount'] as num).toDouble(),
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      notes: data['notes'] as String?,
      isArchived: data['isArchived'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      syncStatus: 'synced',
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
      deviceId: data['deviceId'] as String?,
    );
  }

  Snapshot _mapSnapshot(Map<String, dynamic> data) {
    return Snapshot(
      id: data['id'] as String,
      snapshotDate: (data['snapshotDate'] as Timestamp).toDate(),
      netWorth: (data['netWorth'] as num).toDouble(),
      assets: (data['assets'] as num).toDouble(),
      liabilities: (data['liabilities'] as num).toDouble(),
      receivables: (data['receivables'] as num? ?? 0.0).toDouble(),
      investedCapital: (data['investedCapital'] as num).toDouble(),
      expectedIncome: (data['expectedIncome'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      syncStatus: 'synced',
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
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
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      syncStatus: 'synced',
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
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
      openingDate: (data['openingDate'] as Timestamp).toDate(),
      interestStartDate: (data['interestStartDate'] as Timestamp).toDate(),
      purchaseDate: (data['purchaseDate'] as Timestamp?)?.toDate(),
      purchaseTime: data['purchaseTime'] as String?,
      closedDate: (data['closedDate'] as Timestamp?)?.toDate(),
      isClosed: data['isClosed'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      syncStatus: 'synced',
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
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
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      autoCreate: data['autoCreate'] as int? ?? 0,
      isActive: data['isActive'] as int? ?? 1,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      syncStatus: 'synced',
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
      deviceId: data['deviceId'] as String?,
    );
  }

  Setting _mapSetting(Map<String, dynamic> data) {
    return Setting(
      key: data['key'] as String,
      value: data['value'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      syncStatus: 'synced',
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
      deviceId: data['deviceId'] as String?,
    );
  }
}
