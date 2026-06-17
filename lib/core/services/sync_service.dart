import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drift/drift.dart';
import '../../database/database.dart';
import 'network_monitor.dart';

class SyncService {
  final AppDatabase _db;
  final NetworkMonitor _networkMonitor;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _dbUpdateSubscription;
  bool _isSyncing = false;
  Timer? _debounceTimer;

  SyncService(this._db, this._networkMonitor);

  void start() {
    try {
      // 1. Listen for connectivity changes
      _connectivitySubscription = _networkMonitor.isConnectedStream.listen((connected) {
        if (connected) {
          syncAll();
        }
      });

      // 2. Listen for database updates to trigger sync
      _dbUpdateSubscription = _db.tableUpdates().listen((updates) {
        _triggerDebouncedSync();
      });

      // Run initial sync check
      syncAll();
    } catch (e) {
      print('[SyncService] Failed to start: $e');
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _dbUpdateSubscription?.cancel();
    _debounceTimer?.cancel();
  }

  void _triggerDebouncedSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 5), () {
      syncAll();
    });
  }

  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _isSyncing = false;
        return;
      }

      final connected = await _networkMonitor.isConnected;
      if (!connected) {
        _isSyncing = false;
        return;
      }

      final uid = user.uid;
      await _syncAccounts(uid);
      await _syncPeople(uid);
      await _syncInvestments(uid);
      await _syncInvestmentLots(uid);
      await _syncTransactions(uid);
      await _syncExpectedIncomes(uid);
      await _syncGoals(uid);
      await _syncSnapshots(uid);
      await _syncAdjustments(uid);
    } catch (e) {
      // Sync failed silently, will retry on next trigger
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncAccounts(String userId) async {
    final unsynced = await (_db.select(_db.accounts)
          ..where((tbl) => tbl.syncStatus.equals('pending') | tbl.syncStatus.equals('failed')))
        .get();

    for (final row in unsynced) {
      try {
        final collectionName = row.type == 'credit' ? 'liabilities' : 'accounts';
        final docRef = _firestore.collection('users').doc(userId).collection(collectionName).doc(row.id);

        final docSnap = await docRef.get();
        if (docSnap.exists) {
          final data = docSnap.data()!;
          final remoteUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
          if (row.updatedAt.isBefore(remoteUpdatedAt)) {
            final updatedRow = row.copyWith(
              name: data['name'] as String,
              type: data['type'] as String,
              notes: Value(data['notes'] as String?),
              isArchived: data['isArchived'] as int,
              createdAt: (data['createdAt'] as Timestamp).toDate(),
              updatedAt: remoteUpdatedAt,
              syncStatus: 'synced',
            );
            await _db.update(_db.accounts).replace(updatedRow);
            continue;
          }
        }

        await docRef.set({
          'id': row.id,
          'name': row.name,
          'type': row.type,
          'notes': row.notes,
          'isArchived': row.isArchived,
          'createdAt': docSnap.exists ? (docSnap.data()!['createdAt'] ?? FieldValue.serverTimestamp()) : FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await (_db.update(_db.accounts)..where((tbl) => tbl.id.equals(row.id)))
            .write(AccountsCompanion(syncStatus: const Value('synced')));
      } catch (e) {
        await (_db.update(_db.accounts)..where((tbl) => tbl.id.equals(row.id)))
            .write(AccountsCompanion(syncStatus: const Value('failed')));
      }
    }
  }

  Future<void> _syncPeople(String userId) async {
    final unsynced = await (_db.select(_db.people)
          ..where((tbl) => tbl.syncStatus.equals('pending') | tbl.syncStatus.equals('failed')))
        .get();

    for (final row in unsynced) {
      try {
        final docRef = _firestore.collection('users').doc(userId).collection('receivables').doc(row.id);

        final docSnap = await docRef.get();
        if (docSnap.exists) {
          final data = docSnap.data()!;
          final remoteUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
          if (row.updatedAt.isBefore(remoteUpdatedAt)) {
            final updatedRow = row.copyWith(
              name: data['name'] as String,
              phone: Value(data['phone'] as String?),
              notes: Value(data['notes'] as String?),
              isArchived: data['isArchived'] as int,
              createdAt: (data['createdAt'] as Timestamp).toDate(),
              updatedAt: remoteUpdatedAt,
              syncStatus: 'synced',
            );
            await _db.update(_db.people).replace(updatedRow);
            continue;
          }
        }

        await docRef.set({
          'id': row.id,
          'name': row.name,
          'phone': row.phone,
          'notes': row.notes,
          'isArchived': row.isArchived,
          'createdAt': docSnap.exists ? (docSnap.data()!['createdAt'] ?? FieldValue.serverTimestamp()) : FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await (_db.update(_db.people)..where((tbl) => tbl.id.equals(row.id)))
            .write(PeopleCompanion(syncStatus: const Value('synced')));
      } catch (e) {
        await (_db.update(_db.people)..where((tbl) => tbl.id.equals(row.id)))
            .write(PeopleCompanion(syncStatus: const Value('failed')));
      }
    }
  }

  Future<void> _syncInvestments(String userId) async {
    final unsynced = await (_db.select(_db.investments)
          ..where((tbl) => tbl.syncStatus.equals('pending') | tbl.syncStatus.equals('failed')))
        .get();

    for (final row in unsynced) {
      try {
        final docRef = _firestore.collection('users').doc(userId).collection('investments').doc(row.id);

        final docSnap = await docRef.get();
        if (docSnap.exists) {
          final data = docSnap.data()!;
          final remoteUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
          if (row.updatedAt.isBefore(remoteUpdatedAt)) {
            final updatedRow = row.copyWith(
              name: data['name'] as String,
              type: data['type'] as String,
              symbol: Value(data['symbol'] as String?),
              marketValue: Value(data['marketValue'] != null ? (data['marketValue'] as num).toDouble() : null),
              marketValueUpdatedAt: Value(data['marketValueUpdatedAt'] != null
                  ? (data['marketValueUpdatedAt'] as Timestamp).toDate()
                  : null),
              isArchived: data['isArchived'] as int,
              notes: Value(data['notes'] as String?),
              createdAt: (data['createdAt'] as Timestamp).toDate(),
              updatedAt: remoteUpdatedAt,
              syncStatus: 'synced',
            );
            await _db.update(_db.investments).replace(updatedRow);
            continue;
          }
        }

        await docRef.set({
          'id': row.id,
          'name': row.name,
          'type': row.type,
          'symbol': row.symbol,
          'marketValue': row.marketValue,
          'marketValueUpdatedAt':
              row.marketValueUpdatedAt != null ? Timestamp.fromDate(row.marketValueUpdatedAt!) : null,
          'isArchived': row.isArchived,
          'notes': row.notes,
          'createdAt': docSnap.exists ? (docSnap.data()!['createdAt'] ?? FieldValue.serverTimestamp()) : FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await (_db.update(_db.investments)..where((tbl) => tbl.id.equals(row.id)))
            .write(InvestmentsCompanion(syncStatus: const Value('synced')));
      } catch (e) {
        await (_db.update(_db.investments)..where((tbl) => tbl.id.equals(row.id)))
            .write(InvestmentsCompanion(syncStatus: const Value('failed')));
      }
    }
  }

  Future<void> _syncInvestmentLots(String userId) async {
    final unsynced = await (_db.select(_db.investmentLots)
          ..where((tbl) => tbl.syncStatus.equals('pending') | tbl.syncStatus.equals('failed')))
        .get();

    for (final row in unsynced) {
      try {
        final docRef = _firestore.collection('users').doc(userId).collection('investment_lots').doc(row.id);

        final docSnap = await docRef.get();
        if (docSnap.exists) {
          final data = docSnap.data()!;
          final remoteUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
          if (row.updatedAt.isBefore(remoteUpdatedAt)) {
            final updatedRow = row.copyWith(
              investmentId: data['investmentId'] as String,
              buyTransactionId: data['buyTransactionId'] as String,
              unitsPurchased: (data['unitsPurchased'] as num).toDouble(),
              unitsRemaining: (data['unitsRemaining'] as num).toDouble(),
              costPerUnit: (data['costPerUnit'] as num).toDouble(),
              purchaseDate: (data['purchaseDate'] as Timestamp).toDate(),
              createdAt: (data['createdAt'] as Timestamp).toDate(),
              updatedAt: remoteUpdatedAt,
              syncStatus: 'synced',
            );
            await _db.update(_db.investmentLots).replace(updatedRow);
            continue;
          }
        }

        await docRef.set({
          'id': row.id,
          'investmentId': row.investmentId,
          'buyTransactionId': row.buyTransactionId,
          'unitsPurchased': row.unitsPurchased,
          'unitsRemaining': row.unitsRemaining,
          'costPerUnit': row.costPerUnit,
          'purchaseDate': Timestamp.fromDate(row.purchaseDate),
          'createdAt': docSnap.exists ? (docSnap.data()!['createdAt'] ?? FieldValue.serverTimestamp()) : FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await (_db.update(_db.investmentLots)..where((tbl) => tbl.id.equals(row.id)))
            .write(InvestmentLotsCompanion(syncStatus: const Value('synced')));
      } catch (e) {
        await (_db.update(_db.investmentLots)..where((tbl) => tbl.id.equals(row.id)))
            .write(InvestmentLotsCompanion(syncStatus: const Value('failed')));
      }
    }
  }

  Future<void> _syncTransactions(String userId) async {
    final unsynced = await (_db.select(_db.transactions)
          ..where((tbl) => tbl.syncStatus.equals('pending') | tbl.syncStatus.equals('failed')))
        .get();

    for (final row in unsynced) {
      try {
        final docRef = _firestore.collection('users').doc(userId).collection('transactions').doc(row.id);

        final docSnap = await docRef.get();
        if (docSnap.exists) {
          final data = docSnap.data()!;
          final remoteUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
          if (row.updatedAt.isBefore(remoteUpdatedAt)) {
            final updatedRow = row.copyWith(
              type: data['type'] as String,
              amount: (data['amount'] as num).toDouble(),
              category: Value(data['category'] as String?),
              fromAccountId: Value(data['fromAccountId'] as String?),
              toAccountId: Value(data['toAccountId'] as String?),
              personId: Value(data['personId'] as String?),
              investmentId: Value(data['investmentId'] as String?),
              voidedTransactionId: Value(data['voidedTransactionId'] as String?),
              notes: Value(data['notes'] as String?),
              pricePerUnit: Value(data['pricePerUnit'] != null ? (data['pricePerUnit'] as num).toDouble() : null),
              units: Value(data['units'] != null ? (data['units'] as num).toDouble() : null),
              transactionDate: (data['transactionDate'] as Timestamp).toDate(),
              createdAt: (data['createdAt'] as Timestamp).toDate(),
              updatedAt: remoteUpdatedAt,
              syncStatus: 'synced',
            );
            await _db.update(_db.transactions).replace(updatedRow);
            continue;
          }
        }

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
          'createdAt': docSnap.exists ? (docSnap.data()!['createdAt'] ?? FieldValue.serverTimestamp()) : FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await (_db.update(_db.transactions)..where((tbl) => tbl.id.equals(row.id)))
            .write(TransactionsCompanion(syncStatus: const Value('synced')));
      } catch (e) {
        await (_db.update(_db.transactions)..where((tbl) => tbl.id.equals(row.id)))
            .write(TransactionsCompanion(syncStatus: const Value('failed')));
      }
    }
  }

  Future<void> _syncExpectedIncomes(String userId) async {
    final unsynced = await (_db.select(_db.expectedIncomes)
          ..where((tbl) => tbl.syncStatus.equals('pending') | tbl.syncStatus.equals('failed')))
        .get();

    for (final row in unsynced) {
      try {
        final docRef = _firestore.collection('users').doc(userId).collection('expected_income').doc(row.id);

        final docSnap = await docRef.get();
        if (docSnap.exists) {
          final data = docSnap.data()!;
          final remoteUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
          if (row.updatedAt.isBefore(remoteUpdatedAt)) {
            final updatedRow = row.copyWith(
              source: data['source'] as String,
              amount: (data['amount'] as num).toDouble(),
              status: data['status'] as String,
              expectedDate: Value(data['expectedDate'] != null ? (data['expectedDate'] as Timestamp).toDate() : null),
              receivedTransactionId: Value(data['receivedTransactionId'] as String?),
              notes: Value(data['notes'] as String?),
              createdAt: (data['createdAt'] as Timestamp).toDate(),
              updatedAt: remoteUpdatedAt,
              syncStatus: 'synced',
            );
            await _db.update(_db.expectedIncomes).replace(updatedRow);
            continue;
          }
        }

        await docRef.set({
          'id': row.id,
          'source': row.source,
          'amount': row.amount,
          'status': row.status,
          'expectedDate': row.expectedDate != null ? Timestamp.fromDate(row.expectedDate!) : null,
          'receivedTransactionId': row.receivedTransactionId,
          'notes': row.notes,
          'createdAt': docSnap.exists ? (docSnap.data()!['createdAt'] ?? FieldValue.serverTimestamp()) : FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await (_db.update(_db.expectedIncomes)..where((tbl) => tbl.id.equals(row.id)))
            .write(ExpectedIncomesCompanion(syncStatus: const Value('synced')));
      } catch (e) {
        await (_db.update(_db.expectedIncomes)..where((tbl) => tbl.id.equals(row.id)))
            .write(ExpectedIncomesCompanion(syncStatus: const Value('failed')));
      }
    }
  }

  Future<void> _syncGoals(String userId) async {
    final unsynced = await (_db.select(_db.goals)
          ..where((tbl) => tbl.syncStatus.equals('pending') | tbl.syncStatus.equals('failed')))
        .get();

    for (final row in unsynced) {
      try {
        final docRef = _firestore.collection('users').doc(userId).collection('goals').doc(row.id);

        final docSnap = await docRef.get();
        if (docSnap.exists) {
          final data = docSnap.data()!;
          final remoteUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
          if (row.updatedAt.isBefore(remoteUpdatedAt)) {
            final updatedRow = row.copyWith(
              name: data['name'] as String,
              targetAmount: (data['targetAmount'] as num).toDouble(),
              currentAmount: (data['currentAmount'] as num).toDouble(),
              deadline: Value(data['deadline'] != null ? (data['deadline'] as Timestamp).toDate() : null),
              notes: Value(data['notes'] as String?),
              isArchived: data['isArchived'] as int,
              createdAt: (data['createdAt'] as Timestamp).toDate(),
              updatedAt: remoteUpdatedAt,
              syncStatus: 'synced',
            );
            await _db.update(_db.goals).replace(updatedRow);
            continue;
          }
        }

        await docRef.set({
          'id': row.id,
          'name': row.name,
          'targetAmount': row.targetAmount,
          'currentAmount': row.currentAmount,
          'deadline': row.deadline != null ? Timestamp.fromDate(row.deadline!) : null,
          'notes': row.notes,
          'isArchived': row.isArchived,
          'createdAt': docSnap.exists ? (docSnap.data()!['createdAt'] ?? FieldValue.serverTimestamp()) : FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await (_db.update(_db.goals)..where((tbl) => tbl.id.equals(row.id)))
            .write(GoalsCompanion(syncStatus: const Value('synced')));
      } catch (e) {
        await (_db.update(_db.goals)..where((tbl) => tbl.id.equals(row.id)))
            .write(GoalsCompanion(syncStatus: const Value('failed')));
      }
    }
  }

  Future<void> _syncSnapshots(String userId) async {
    final unsynced = await (_db.select(_db.snapshots)
          ..where((tbl) => tbl.syncStatus.equals('pending') | tbl.syncStatus.equals('failed')))
        .get();

    for (final row in unsynced) {
      try {
        final docRef = _firestore.collection('users').doc(userId).collection('snapshots').doc(row.id);

        final docSnap = await docRef.get();
        if (docSnap.exists) {
          final data = docSnap.data()!;
          final remoteUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
          if (row.updatedAt.isBefore(remoteUpdatedAt)) {
            final updatedRow = row.copyWith(
              snapshotDate: (data['snapshotDate'] as Timestamp).toDate(),
              netWorth: (data['netWorth'] as num).toDouble(),
              assets: (data['assets'] as num).toDouble(),
              liabilities: (data['liabilities'] as num).toDouble(),
              receivables: (data['receivables'] as num).toDouble(),
              investedCapital: (data['investedCapital'] as num).toDouble(),
              expectedIncome: (data['expectedIncome'] as num).toDouble(),
              createdAt: (data['createdAt'] as Timestamp).toDate(),
              updatedAt: remoteUpdatedAt,
              syncStatus: 'synced',
            );
            await _db.update(_db.snapshots).replace(updatedRow);
            continue;
          }
        }

        await docRef.set({
          'id': row.id,
          'snapshotDate': Timestamp.fromDate(row.snapshotDate),
          'netWorth': row.netWorth,
          'assets': row.assets,
          'liabilities': row.liabilities,
          'receivables': row.receivables,
          'investedCapital': row.investedCapital,
          'expectedIncome': row.expectedIncome,
          'createdAt': docSnap.exists ? (docSnap.data()!['createdAt'] ?? FieldValue.serverTimestamp()) : FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await (_db.update(_db.snapshots)..where((tbl) => tbl.id.equals(row.id)))
            .write(SnapshotsCompanion(syncStatus: const Value('synced')));
      } catch (e) {
        await (_db.update(_db.snapshots)..where((tbl) => tbl.id.equals(row.id)))
            .write(SnapshotsCompanion(syncStatus: const Value('failed')));
      }
    }
  }

  Future<void> _syncAdjustments(String userId) async {
    final unsynced = await (_db.select(_db.adjustments)
          ..where((tbl) => tbl.syncStatus.equals('pending') | tbl.syncStatus.equals('failed')))
        .get();

    for (final row in unsynced) {
      try {
        final docRef = _firestore.collection('users').doc(userId).collection('adjustments').doc(row.id);

        final docSnap = await docRef.get();
        if (docSnap.exists) {
          final data = docSnap.data()!;
          final updatedRow = row.copyWith(
            syncStatus: 'synced',
          );
          await _db.update(_db.adjustments).replace(updatedRow);
          continue;
        }

        await docRef.set({
          'id': row.id,
          'entityType': row.entityType,
          'entityId': row.entityId,
          'oldAmount': row.oldAmount,
          'newAmount': row.newAmount,
          'adjustedAmount': row.adjustedAmount,
          'reason': row.reason,
          'createdAt': Timestamp.fromDate(row.createdAt),
        });

        await (_db.update(_db.adjustments)..where((tbl) => tbl.id.equals(row.id)))
            .write(AdjustmentsCompanion(syncStatus: const Value('synced')));
      } catch (e) {
        await (_db.update(_db.adjustments)..where((tbl) => tbl.id.equals(row.id)))
            .write(AdjustmentsCompanion(syncStatus: const Value('failed')));
      }
    }
  }
}
