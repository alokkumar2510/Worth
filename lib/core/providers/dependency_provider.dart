import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../database/database.dart' as db;
import '../calculation/net_worth_service.dart';
import 'mock_database.dart';
import 'app_providers.dart';

import '../../features/accounts/domain/entities/account.dart' as domain;
import '../../features/investments/domain/entities/investment.dart' as domain;
import '../../features/investments/domain/entities/sip.dart' as domain;
import '../../features/expected_income/domain/entities/expected_income.dart' as domain;
import '../../features/goals/domain/entities/goal.dart' as domain;
import '../../features/transactions/domain/entities/transaction.dart' as domain;
import '../../features/reports/domain/entities/snapshot.dart' as domain;

// --- Mock Mode Configuration Provider ---
// Defaults to false to run the entire app on the real SQLite/Drift database
final mockModeProvider = StateProvider<bool>((ref) {
  return false; 
});

// --- Database Connection Passphrase Provider ---
final databasePassphraseProvider = Provider<String>((ref) {
  return 'worth_secure_local_database_encryption_key_v1';
});

// --- Core Database Provider ---
final databaseProvider = Provider<db.AppDatabase?>((ref) {
  final isMock = ref.watch(mockModeProvider);
  if (isMock) return null;
  return ref.watch(realDatabaseProvider);
});

// --- Repository Providers (Delegating/Mock Interface wrappers for UI compatibility) ---

class MockAccountRepository {
  final Ref _ref;
  MockAccountRepository(this._ref);

  Future<void> insertAccount(db.AccountsCompanion companion) async {
    await _ref.read(mockDatabaseProvider.notifier).addAccount(
      companion.name.value,
      companion.type.value,
      companion.notes.value,
      0.0,
    );
  }
}

final accountRepositoryProvider = Provider<MockAccountRepository>((ref) {
  return MockAccountRepository(ref);
});

class MockTransactionRepository {
  final Ref _ref;
  MockTransactionRepository(this._ref);
}

final transactionRepositoryProvider = Provider<MockTransactionRepository>((ref) {
  return MockTransactionRepository(ref);
});

class MockTransactionService {
  final Ref _ref;
  MockTransactionService(this._ref);

  Future<void> addTransaction({
    required String type,
    required double amount,
    String? category,
    String? fromAccountId,
    String? toAccountId,
    String? personId,
    String? investmentId,
    String? notes,
    required DateTime date,
  }) async {
    await _ref.read(mockDatabaseProvider.notifier).addTransaction(
      type: type,
      amount: amount,
      category: category,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      personId: personId,
      investmentId: investmentId,
      notes: notes,
      date: date,
    );
  }

  Future<void> voidTransaction(String id) async {
    await _ref.read(mockDatabaseProvider.notifier).voidTransaction(id);
  }
}

final transactionServiceProvider = Provider<MockTransactionService>((ref) {
  return MockTransactionService(ref);
});

// --- Reactive State Streams Providers (Switching between Mock In-Memory & Real Drift SQLite) ---

final netWorthProvider = StreamProvider<NetWorthData>((ref) {
  final isMock = ref.watch(mockModeProvider);
  if (isMock) {
    final dbState = ref.watch(mockDatabaseProvider);
    return Stream.value(
      NetWorthData(
        assets: dbState.totalAssets,
        liabilities: dbState.totalLiabilities,
        netWorth: dbState.netWorth,
        investedCapital: dbState.totalInvestedCapital,
        debtFundedAssets: dbState.debtFundedAssets,
        selfFundedAssets: dbState.selfFundedAssets,
        fundingSourceBreakdown: dbState.fundingSourceBreakdown,
      ),
    );
  } else {
    final database = ref.watch(realDatabaseProvider);
    
    // Watch database updates for any table except 'snapshots' to avoid infinite recursive loop
    final dbUpdates = database.tableUpdates().where((updates) {
      return updates.any((update) => update.table != 'snapshots');
    });

    Stream<void> watchDatabaseChanges() async* {
      yield null; // Initial emit
      await for (final _ in dbUpdates) {
        yield null;
      }
    }

    return watchDatabaseChanges().asyncMap((_) async {
      final netWorthData = await NetWorthService(database).calculateNetWorth();

      // Automatically update today's snapshot in real SQLite database
      try {
        final now = DateTime.now();
        final todayMidnight = DateTime(now.year, now.month, now.day);
        
        final pendingIncome = await (database.select(database.expectedIncomes)..where((tbl) => tbl.status.equals('pending'))).get();
        final double expectedIncomeVal = pendingIncome.fold(0.0, (sum, inc) => sum + inc.amount);

        final personBalances = await database.select(database.personBalanceCaches).get();
        double receivables = 0.0;
        for (final cache in personBalances) {
          receivables += cache.receivableBalance;
        }

        final snapshotId = 'snapshot_today_${todayMidnight.year}_${todayMidnight.month}_${todayMidnight.day}';
        final existing = await (database.select(database.snapshots)..where((tbl) => tbl.id.equals(snapshotId))).getSingleOrNull();

        final companion = db.SnapshotsCompanion(
          id: Value(snapshotId),
          snapshotDate: Value(todayMidnight),
          netWorth: Value(netWorthData.netWorth),
          assets: Value(netWorthData.assets),
          liabilities: Value(netWorthData.liabilities),
          receivables: Value(receivables),
          investedCapital: Value(netWorthData.investedCapital),
          expectedIncome: Value(expectedIncomeVal),
          createdAt: Value(existing?.createdAt ?? now),
          updatedAt: Value(now),
          syncStatus: const Value('pending'),
        );

        if (existing != null) {
          await (database.update(database.snapshots)..where((tbl) => tbl.id.equals(snapshotId))).write(companion);
        } else {
          await database.into(database.snapshots).insert(companion);
        }
      } catch (e) {
        // Safe-guard to avoid blocking the stream in case of any database exceptions
      }

      return netWorthData;
    });
  }
});

final activeAccountsProvider = StreamProvider<List<domain.Account>>((ref) {
  final isMock = ref.watch(mockModeProvider);
  if (isMock) {
    final dbState = ref.watch(mockDatabaseProvider);
    final list = dbState.accounts.where((a) => a.isArchived == 0).map((a) => domain.Account(
      id: a.id,
      name: a.name,
      type: a.type,
      notes: a.notes,
      isArchived: a.isArchived,
      createdAt: a.createdAt,
      updatedAt: a.updatedAt,
    )).toList();
    return Stream.value(list);
  } else {
    return ref.watch(realAccountRepositoryProvider)
        .watchAllAccounts()
        .map((list) => list.where((a) => a.isArchived == 0).toList());
  }
});

final activePeopleProvider = StreamProvider<List<db.Person>>((ref) {
  final isMock = ref.watch(mockModeProvider);
  if (isMock) {
    final dbState = ref.watch(mockDatabaseProvider);
    final list = dbState.people.where((p) => p.isArchived == 0).toList();
    return Stream.value(list);
  } else {
    return ref.watch(realPersonRepositoryProvider).watchActivePeople();
  }
});

final activeInvestmentsProvider = StreamProvider<List<domain.Investment>>((ref) {
  final isMock = ref.watch(mockModeProvider);
  if (isMock) {
    final dbState = ref.watch(mockDatabaseProvider);
    final list = dbState.investments.where((i) => i.isArchived == 0).map((i) => domain.Investment(
      id: i.id,
      name: i.name,
      type: i.type,
      symbol: i.symbol,
      marketValue: i.marketValue,
      marketValueUpdatedAt: i.marketValueUpdatedAt,
      isArchived: i.isArchived,
      notes: i.notes,
      createdAt: i.createdAt,
      updatedAt: i.updatedAt,
    )).toList();
    return Stream.value(list);
  } else {
    return ref.watch(realInvestmentRepositoryProvider)
        .watchAllInvestments()
        .map((list) => list.where((i) => i.isArchived == 0).toList());
  }
});

final pendingExpectedIncomesProvider = StreamProvider<List<domain.ExpectedIncome>>((ref) {
  final isMock = ref.watch(mockModeProvider);
  if (isMock) {
    final dbState = ref.watch(mockDatabaseProvider);
    final list = dbState.expectedIncomes.where((i) => i.status == 'pending').map((i) => domain.ExpectedIncome(
      id: i.id,
      source: i.source,
      amount: i.amount,
      status: i.status,
      expectedDate: i.expectedDate,
      receivedTransactionId: i.receivedTransactionId,
      notes: i.notes,
      createdAt: i.createdAt,
      updatedAt: i.updatedAt,
    )).toList();
    return Stream.value(list);
  } else {
    return ref.watch(realExpectedIncomeRepositoryProvider).watchPendingIncome();
  }
});

final activeGoalsProvider = StreamProvider<List<domain.Goal>>((ref) {
  final isMock = ref.watch(mockModeProvider);
  if (isMock) {
    final dbState = ref.watch(mockDatabaseProvider);
    final list = dbState.goals.where((g) => g.isArchived == 0).map((g) => domain.Goal(
      id: g.id,
      name: g.name,
      targetAmount: g.targetAmount,
      currentAmount: g.currentAmount,
      deadline: g.deadline,
      notes: g.notes,
      isArchived: g.isArchived,
      createdAt: g.createdAt,
      updatedAt: g.updatedAt,
    )).toList();
    return Stream.value(list);
  } else {
    return ref.watch(realGoalRepositoryProvider)
        .watchAllGoals()
        .map((list) => list.where((g) => g.isArchived == 0).toList());
  }
});

final allTransactionsProvider = StreamProvider<List<domain.Transaction>>((ref) {
  final isMock = ref.watch(mockModeProvider);
  if (isMock) {
    final dbState = ref.watch(mockDatabaseProvider);
    final list = dbState.transactions.map((t) => domain.Transaction(
      id: t.id,
      type: t.type,
      amount: t.amount,
      category: t.category,
      fromAccountId: t.fromAccountId,
      toAccountId: t.toAccountId,
      personId: t.personId,
      investmentId: t.investmentId,
      voidedTransactionId: t.voidedTransactionId,
      notes: t.notes,
      pricePerUnit: t.pricePerUnit,
      units: t.units,
      transactionDate: t.transactionDate,
      createdAt: t.createdAt,
      updatedAt: t.updatedAt,
    )).toList();
    return Stream.value(list);
  } else {
    return ref.watch(realTransactionRepositoryProvider).watchAllTransactions();
  }
});

final allSnapshotsProvider = StreamProvider<List<domain.Snapshot>>((ref) {
  final isMock = ref.watch(mockModeProvider);
  if (isMock) {
    final dbState = ref.watch(mockDatabaseProvider);
    final list = dbState.snapshots.map((s) => domain.Snapshot(
      id: s.id,
      snapshotDate: s.snapshotDate,
      netWorth: s.netWorth,
      assets: s.assets,
      liabilities: s.liabilities,
      receivables: s.receivables,
      investedCapital: s.investedCapital,
      expectedIncome: s.expectedIncome,
      createdAt: s.createdAt,
      updatedAt: s.createdAt,
      syncStatus: 'synced',
    )).toList();
    return Stream.value(list);
  } else {
    return ref.watch(realReportRepositoryProvider).watchAllSnapshots();
  }
});

final activeSipsProvider = StreamProvider<List<domain.Sip>>((ref) {
  final isMock = ref.watch(mockModeProvider);
  if (isMock) {
    final dbState = ref.watch(mockDatabaseProvider);
    final list = dbState.sips.map((s) => domain.Sip(
      id: s.id,
      investmentId: s.investmentId,
      amount: s.amount,
      frequency: s.frequency,
      sipDate: s.sipDate,
      startDate: s.startDate,
      endDate: s.endDate,
      autoCreate: s.autoCreate,
      isActive: s.isActive,
      createdAt: s.createdAt,
      updatedAt: s.updatedAt,
      syncStatus: s.syncStatus,
    )).toList();
    return Stream.value(list);
  } else {
    final db = ref.watch(realDatabaseProvider);
    return db.select(db.sips).watch().map((list) => list.map((entity) => domain.Sip(
      id: entity.id,
      investmentId: entity.investmentId,
      amount: entity.amount,
      frequency: entity.frequency,
      sipDate: entity.sipDate,
      startDate: entity.startDate,
      endDate: entity.endDate,
      autoCreate: entity.autoCreate,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
    )).toList());
  }
});

class MockSipService {
  final Ref _ref;
  MockSipService(this._ref);

  Future<void> addSip({
    required String investmentId,
    required double amount,
    required String frequency,
    required int sipDate,
    required DateTime startDate,
    DateTime? endDate,
    required int autoCreate,
  }) async {
    await _ref.read(mockDatabaseProvider.notifier).addSip(
      investmentId: investmentId,
      amount: amount,
      frequency: frequency,
      sipDate: sipDate,
      startDate: startDate,
      endDate: endDate,
      autoCreate: autoCreate,
    );
  }

  Future<void> editSip(domain.Sip sip) async {
    final dbSip = db.Sip(
      id: sip.id,
      investmentId: sip.investmentId,
      amount: sip.amount,
      frequency: sip.frequency,
      sipDate: sip.sipDate,
      startDate: sip.startDate,
      endDate: sip.endDate,
      autoCreate: sip.autoCreate,
      isActive: sip.isActive,
      createdAt: sip.createdAt,
      updatedAt: sip.updatedAt,
      syncStatus: sip.syncStatus,
    );
    await _ref.read(mockDatabaseProvider.notifier).editSip(dbSip);
  }

  Future<void> deleteSip(String id) async {
    await _ref.read(mockDatabaseProvider.notifier).deleteSip(id);
  }

  Future<void> toggleSipActive(String id) async {
    await _ref.read(mockDatabaseProvider.notifier).toggleSipActive(id);
  }
}

final sipServiceProvider = Provider<MockSipService>((ref) {
  return MockSipService(ref);
});

