import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart' as db;
import '../calculation/net_worth_service.dart';
import 'mock_database.dart';
import 'app_providers.dart';

import '../../features/accounts/domain/entities/account.dart' as domain;
import '../../features/investments/domain/entities/investment.dart' as domain;
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
    _ref.read(mockDatabaseProvider.notifier).addAccount(
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
    _ref.read(mockDatabaseProvider.notifier).voidTransaction(id);
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
      ),
    );
  } else {
    final db = ref.watch(realDatabaseProvider);
    final calc = ref.watch(realFinancialCalculatorServiceProvider);
    
    // Reactive stream trigger: emit values whenever transaction log changes
    return db.select(db.transactions).watch().asyncMap((_) async {
      final assets = await calc.calculateAssets();
      final liabilities = await calc.calculateLiabilities();
      final netWorth = await calc.calculateNetWorth();
      final invested = await calc.calculateInvestmentPrincipal();
      return NetWorthData(
        assets: assets,
        liabilities: liabilities,
        netWorth: netWorth,
        investedCapital: invested,
      );
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
