import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../database/database.dart' as db;
import '../calculation/financial_calculator_service.dart';
import '../calculation/balance_cache_service.dart';
import '../calculation/fifo_lot_service.dart';
import '../services/search_index_service.dart';
import '../calculation/transaction_service.dart';
import '../calculation/transaction_validator.dart';
import '../calculation/transaction_processor.dart';

// Import domain entities
import '../../features/accounts/domain/entities/account.dart';
import '../../features/assets/domain/entities/asset.dart';
import '../../features/liabilities/domain/entities/liability.dart';
import '../../features/receivables/domain/entities/receivable.dart';
import '../../features/expected_income/domain/entities/expected_income.dart';
import '../../features/investments/domain/entities/investment.dart';
import '../../features/investments/domain/entities/investment_lot.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/goals/domain/entities/goal.dart';
import '../../features/reports/domain/entities/snapshot.dart';
import '../../features/achievements/domain/services/gamification_engine.dart';
import '../../features/achievements/domain/services/achievement_queue_service.dart';
import '../../features/achievements/presentation/controllers/milestone_celebration_controller.dart';
import 'mock_database.dart';

// Import repositories
import '../../features/accounts/domain/repositories/account_repository.dart';
import '../../features/accounts/data/repositories/account_repository_impl.dart';
import '../../features/assets/domain/repositories/asset_repository.dart';
import '../../features/assets/data/repositories/asset_repository_impl.dart';
import '../../features/liabilities/domain/repositories/liability_repository.dart';
import '../../features/liabilities/data/repositories/liability_repository_impl.dart';
import '../../features/receivables/domain/repositories/receivable_repository.dart';
import '../../features/receivables/data/repositories/receivable_repository_impl.dart';
import '../../features/expected_income/domain/repositories/expected_income_repository.dart';
import '../../features/expected_income/data/repositories/expected_income_repository_impl.dart';
import '../../features/investments/domain/repositories/investment_repository.dart';
import '../../features/investments/data/repositories/investment_repository_impl.dart';
import '../../features/investments/domain/repositories/sip_repository.dart';
import '../../features/investments/data/repositories/sip_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/goals/domain/repositories/goal_repository.dart';
import '../../features/goals/data/repositories/goal_repository_impl.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../database/repositories/person_repository.dart';

// Import Dashboard, Reports, Search, and Backup features/services
import '../calculation/chart_data_generator.dart';
import '../services/snapshot_service.dart';
import '../services/encryption_service.dart';
import '../services/export_service.dart';
import '../services/import_service.dart';
import '../services/backup_service.dart';
import '../services/investment_service.dart';
import '../services/receivables_service.dart';
import '../services/liabilities_service.dart';
import '../services/expected_income_service.dart';
import '../services/goal_service.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';
import '../services/reminder_scheduler.dart';
import '../services/network_monitor.dart';
import '../services/sync_service.dart';
import '../../features/checkins/presentation/providers/check_in_providers.dart';

import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/services/dashboard_service.dart';
import '../../features/dashboard/domain/entities/dashboard_data.dart';

import '../../features/reports/domain/services/report_service.dart';

import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/services/search_service.dart';

// ==========================================
// 1. Core Database & Base Utility Providers
// ==========================================

final realDatabaseProvider = Provider<db.AppDatabase>((ref) {
  // Lazily opens encrypted Native connection. Password managed securely via encryption keys
  final connection = db.openDatabaseConnection('worth_secure_encryption_password_key_v1');
  return db.AppDatabase(connection);
});

// ==========================================
// 2. Core Clean Repository Providers
// ==========================================

final realAccountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(realDatabaseProvider));
});

final realAssetRepositoryProvider = Provider<AssetRepository>((ref) {
  return AssetRepositoryImpl(ref.watch(realDatabaseProvider));
});

final realLiabilityRepositoryProvider = Provider<LiabilityRepository>((ref) {
  return LiabilityRepositoryImpl(ref.watch(realDatabaseProvider));
});

final realReceivableRepositoryProvider = Provider<ReceivableRepository>((ref) {
  return ReceivableRepositoryImpl(ref.watch(realDatabaseProvider));
});

final realExpectedIncomeRepositoryProvider = Provider<ExpectedIncomeRepository>((ref) {
  return ExpectedIncomeRepositoryImpl(ref.watch(realDatabaseProvider));
});

final realInvestmentRepositoryProvider = Provider<InvestmentRepository>((ref) {
  return InvestmentRepositoryImpl(ref.watch(realDatabaseProvider));
});

final realSipRepositoryProvider = Provider<SipRepository>((ref) {
  return SipRepositoryImpl(ref.watch(realDatabaseProvider));
});

final realTransactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.watch(realDatabaseProvider));
});

final realGoalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl(ref.watch(realDatabaseProvider));
});

final realReportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(ref.watch(realDatabaseProvider));
});

final realPersonRepositoryProvider = Provider<PersonRepository>((ref) {
  return PersonRepository(ref.watch(realDatabaseProvider));
});

// ==========================================
// 3. Clean Engine & Calculation Services
// ==========================================

final realFinancialCalculatorServiceProvider = Provider<FinancialCalculatorService>((ref) {
  return FinancialCalculatorService(ref.watch(realDatabaseProvider));
});

final realBalanceCacheServiceProvider = Provider<BalanceCacheService>((ref) {
  return BalanceCacheService(ref.watch(realDatabaseProvider));
});

final realFifoLotServiceProvider = Provider<FifoLotService>((ref) {
  return FifoLotService(ref.watch(realDatabaseProvider));
});

final realSearchIndexServiceProvider = Provider<SearchIndexService>((ref) {
  return SearchIndexService(ref.watch(realDatabaseProvider));
});

final realTransactionValidatorProvider = Provider<TransactionValidator>((ref) {
  return TransactionValidator();
});

final realTransactionProcessorProvider = Provider<TransactionProcessor>((ref) {
  return TransactionProcessor(
    ref.watch(realDatabaseProvider),
    ref.watch(realBalanceCacheServiceProvider),
    ref.watch(realFifoLotServiceProvider),
    ref.watch(realSearchIndexServiceProvider),
  );
});

final realTransactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService(
    ref.watch(realDatabaseProvider),
    ref.watch(realTransactionValidatorProvider),
    ref.watch(realTransactionProcessorProvider),
  );
});

// --- Dashboard System Providers ---
final realDashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(realDatabaseProvider));
});

final realDashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(ref.watch(realDashboardRepositoryProvider));
});

// --- Reports Engine Providers ---
final realSnapshotServiceProvider = Provider<SnapshotService>((ref) {
  return SnapshotService(ref);
});

final realInvestmentServiceProvider = Provider<InvestmentService>((ref) {
  return InvestmentService(ref);
});

final realReceivablesServiceProvider = Provider<ReceivablesService>((ref) {
  return ReceivablesService(ref);
});

final realLiabilitiesServiceProvider = Provider<LiabilitiesService>((ref) {
  return LiabilitiesService(ref);
});

final realExpectedIncomeServiceProvider = Provider<ExpectedIncomeService>((ref) {
  return ExpectedIncomeService(ref);
});

final realGoalServiceProvider = Provider<GoalService>((ref) {
  return GoalService(ref);
});

final realAnalyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.watch(realDatabaseProvider));
});

final realNotificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  ref.onDispose(() => service.dispose());
  return service;
});

final realReminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return ReminderScheduler(
    ref.watch(realDatabaseProvider),
    ref.watch(realNotificationServiceProvider),
    onCheck: () async {
      await ref.read(mockDatabaseProvider.notifier).runAutoInterestAccrual();
      await ref.read(mockDatabaseProvider.notifier).runAutoSipProcessing();
      final dbState = ref.read(mockDatabaseProvider);
      await ref.read(realNotificationServiceProvider).scheduleFutureReminders(dbState);
    },
    onCheckIn: () async {
      await ref.read(checkInReminderEngineProvider).checkAndTrigger();
    },
  );
});

final realChartDataGeneratorProvider = Provider<ChartDataGenerator>((ref) {
  return ChartDataGenerator(ref.watch(realDatabaseProvider));
});

final realReportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(
    ref.watch(realSnapshotServiceProvider),
    ref.watch(realChartDataGeneratorProvider),
  );
});

// --- Global Search System Providers ---
final realSearchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepositoryImpl(ref.watch(realDatabaseProvider));
});

final realSearchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(ref.watch(realSearchRepositoryProvider));
});

// --- Offline Backup System Providers ---
final realEncryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

final realExportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref.watch(realDatabaseProvider));
});

final realImportServiceProvider = Provider<ImportService>((ref) {
  return ImportService(
    ref.watch(realDatabaseProvider),
    ref.watch(realBalanceCacheServiceProvider),
    ref.watch(realSearchIndexServiceProvider),
  );
});

final realBackupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    ref.watch(realExportServiceProvider),
    ref.watch(realImportServiceProvider),
    ref.watch(realEncryptionServiceProvider),
  );
});

final networkMonitorProvider = Provider<NetworkMonitor>((ref) {
  return NetworkMonitor();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.watch(realDatabaseProvider),
    ref.watch(networkMonitorProvider),
  );
});

final gamificationEngineProvider = Provider<GamificationEngine>((ref) {
  final db = ref.watch(realDatabaseProvider);
  final engine = GamificationEngine(db);
  ref.onDispose(() => engine.dispose());
  return engine;
});

final achievementQueueServiceProvider = Provider<AchievementQueueService>((ref) {
  final service = AchievementQueueService();
  ref.onDispose(() => service.dispose());
  return service;
});

final milestoneCelebrationControllerProvider = Provider<MilestoneCelebrationController>((ref) {
  final queueService = ref.watch(achievementQueueServiceProvider);
  final engine = ref.watch(gamificationEngineProvider);
  final controller = MilestoneCelebrationController(queueService, engine);
  ref.onDispose(() => controller.dispose());
  return controller;
});

// ==========================================
// 4. Feature States & Notifiers
// ==========================================

// --- Dashboard Feature ---
class DashboardState {
  final double netWorth;
  final double assets;
  final double liabilities;
  final double investedCapital;
  final double expectedIncome;
  final List<Transaction> recentTransactions;

  DashboardState({
    required this.netWorth,
    required this.assets,
    required this.liabilities,
    required this.investedCapital,
    required this.expectedIncome,
    required this.recentTransactions,
  });
}

class DashboardNotifier extends AsyncNotifier<DashboardState> {
  @override
  FutureOr<DashboardState> build() async {
    final calc = ref.watch(realFinancialCalculatorServiceProvider);
    final txRepo = ref.watch(realTransactionRepositoryProvider);

    final netWorth = await calc.calculateNetWorth();
    final assets = await calc.calculateAssets();
    final liabilities = await calc.calculateLiabilities();
    final investedCapital = await calc.calculateInvestmentPrincipal();
    final expectedIncome = await calc.calculateExpectedIncome();
    final recent = await txRepo.getTransactionsPaginated(5, null, null);

    return DashboardState(
      netWorth: netWorth,
      assets: assets,
      liabilities: liabilities,
      investedCapital: investedCapital,
      expectedIncome: expectedIncome,
      recentTransactions: recent,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => build());
  }
}

final dashboardNotifierProvider = AsyncNotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});

// --- Assets Feature ---
class AssetsState {
  final List<Asset> assets;
  final double totalAssets;
  AssetsState({required this.assets, required this.totalAssets});
}

class AssetsNotifier extends AsyncNotifier<AssetsState> {
  @override
  FutureOr<AssetsState> build() async {
    final repo = ref.watch(realAssetRepositoryProvider);
    final calc = ref.watch(realFinancialCalculatorServiceProvider);

    final assets = await repo.getAllAssets();
    final total = await calc.calculateAssets();

    return AssetsState(assets: assets, totalAssets: total);
  }

  Future<void> addAsset(Asset asset) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(realAssetRepositoryProvider).createAsset(asset);
    });
    ref.invalidateSelf();
  }

  Future<void> archiveAsset(String id) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(realAssetRepositoryProvider).deleteAsset(id);
    });
    ref.invalidateSelf();
  }
}

final assetsNotifierProvider = AsyncNotifierProvider<AssetsNotifier, AssetsState>(() {
  return AssetsNotifier();
});

// --- Liabilities Feature ---
class LiabilitiesState {
  final List<Liability> liabilities;
  final double totalLiabilities;
  LiabilitiesState({required this.liabilities, required this.totalLiabilities});
}

class LiabilitiesNotifier extends AsyncNotifier<LiabilitiesState> {
  @override
  FutureOr<LiabilitiesState> build() async {
    final repo = ref.watch(realLiabilityRepositoryProvider);
    final calc = ref.watch(realFinancialCalculatorServiceProvider);

    final list = await repo.getAllLiabilities();
    final total = await calc.calculateLiabilities();

    return LiabilitiesState(liabilities: list, totalLiabilities: total);
  }

  Future<void> addLiability(Liability liability) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(realLiabilityRepositoryProvider).createLiability(liability);
    });
    ref.invalidateSelf();
  }

  Future<void> archiveLiability(String id) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(realLiabilityRepositoryProvider).deleteLiability(id);
    });
    ref.invalidateSelf();
  }
}

final liabilitiesNotifierProvider = AsyncNotifierProvider<LiabilitiesNotifier, LiabilitiesState>(() {
  return LiabilitiesNotifier();
});

// --- Investments Feature ---
class InvestmentsState {
  final List<Investment> investments;
  final double principal;
  final double marketValue;
  final double realizedGain;
  final double unrealizedGain;

  InvestmentsState({
    required this.investments,
    required this.principal,
    required this.marketValue,
    required this.realizedGain,
    required this.unrealizedGain,
  });
}

class InvestmentsNotifier extends AsyncNotifier<InvestmentsState> {
  @override
  FutureOr<InvestmentsState> build() async {
    final repo = ref.watch(realInvestmentRepositoryProvider);
    final calc = ref.watch(realFinancialCalculatorServiceProvider);

    final list = await repo.getAllInvestments();
    final principal = await calc.calculateInvestmentPrincipal();
    final realized = await calc.calculateRealizedGain();
    final unrealized = await calc.calculateUnrealizedGain();
    final marketValue = principal + unrealized;

    return InvestmentsState(
      investments: list,
      principal: principal,
      marketValue: marketValue,
      realizedGain: realized,
      unrealizedGain: unrealized,
    );
  }

  Future<void> addInvestment(Investment investment) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(realInvestmentRepositoryProvider).createInvestment(investment);
    });
    ref.invalidateSelf();
  }

  Future<void> updateMarketPrice(String id, double price) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(realInvestmentRepositoryProvider).updateMarketValue(id, price);
    });
    ref.invalidateSelf();
  }
}

final investmentsNotifierProvider = AsyncNotifierProvider<InvestmentsNotifier, InvestmentsState>(() {
  return InvestmentsNotifier();
});

// --- Receivables Feature ---
class ReceivablesState {
  final List<Receivable> receivables;
  final double totalReceivable;
  ReceivablesState({required this.receivables, required this.totalReceivable});
}

class ReceivablesNotifier extends AsyncNotifier<ReceivablesState> {
  @override
  FutureOr<ReceivablesState> build() async {
    final repo = ref.watch(realReceivableRepositoryProvider);
    final calc = ref.watch(realFinancialCalculatorServiceProvider);

    final list = await repo.getAllReceivables();
    final total = await calc.calculateReceivables();

    return ReceivablesState(receivables: list, totalReceivable: total);
  }

  Future<void> addReceivable(Receivable receivable) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(realReceivableRepositoryProvider).createReceivable(receivable);
    });
    ref.invalidateSelf();
  }
}

final receivablesNotifierProvider = AsyncNotifierProvider<ReceivablesNotifier, ReceivablesState>(() {
  return ReceivablesNotifier();
});

// --- Expected Income Feature ---
class ExpectedIncomeState {
  final List<ExpectedIncome> items;
  final double totalExpected;
  ExpectedIncomeState({required this.items, required this.totalExpected});
}

class ExpectedIncomeNotifier extends AsyncNotifier<ExpectedIncomeState> {
  @override
  FutureOr<ExpectedIncomeState> build() async {
    final repo = ref.watch(realExpectedIncomeRepositoryProvider);
    final calc = ref.watch(realFinancialCalculatorServiceProvider);

    final list = await repo.getPendingIncome();
    final total = await calc.calculateExpectedIncome();

    return ExpectedIncomeState(items: list, totalExpected: total);
  }

  Future<void> addExpectedIncome(ExpectedIncome item) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(realExpectedIncomeRepositoryProvider).saveExpectedIncome(item);
    });
    ref.invalidateSelf();
  }

  Future<void> markReceived(String id, String toAccountId) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(realExpectedIncomeRepositoryProvider).markAsReceived(id, toAccountId);
    });
    ref.invalidateSelf();
  }

  Future<void> markExpired(String id) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(realExpectedIncomeRepositoryProvider).markAsExpired(id);
    });
    ref.invalidateSelf();
  }
}

final expectedIncomeNotifierProvider = AsyncNotifierProvider<ExpectedIncomeNotifier, ExpectedIncomeState>(() {
  return ExpectedIncomeNotifier();
});

// --- Transactions Feature ---
class TransactionsState {
  final List<Transaction> transactions;
  TransactionsState({required this.transactions});
}

class TransactionsNotifier extends AsyncNotifier<TransactionsState> {
  @override
  FutureOr<TransactionsState> build() async {
    final repo = ref.watch(realTransactionRepositoryProvider);
    final list = await repo.getAllTransactions();
    return TransactionsState(transactions: list);
  }

  Future<void> recordTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      // Map domain entity to db companion
      final companion = db.TransactionsCompanion(
        id: Value(transaction.id),
        type: Value(transaction.type),
        amount: Value(transaction.amount),
        category: Value(transaction.category),
        fromAccountId: Value(transaction.fromAccountId),
        toAccountId: Value(transaction.toAccountId),
        personId: Value(transaction.personId),
        investmentId: Value(transaction.investmentId),
        notes: Value(transaction.notes),
        transactionDate: Value(transaction.transactionDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      await ref.read(realTransactionServiceProvider).createTransaction(companion);
    });
    ref.invalidateSelf();
    ref.invalidate(dashboardNotifierProvider);
  }

  Future<void> voidOriginalTransaction(String originalTxId) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(realTransactionServiceProvider).voidTransaction(originalTxId);
    });
    ref.invalidateSelf();
    ref.invalidate(dashboardNotifierProvider);
  }
}

final transactionsNotifierProvider = AsyncNotifierProvider<TransactionsNotifier, TransactionsState>(() {
  return TransactionsNotifier();
});

// --- Goals Feature ---
class GoalsState {
  final List<Goal> goals;
  GoalsState({required this.goals});
}

class GoalsNotifier extends AsyncNotifier<GoalsState> {
  @override
  FutureOr<GoalsState> build() async {
    final repo = ref.watch(realGoalRepositoryProvider);
    final list = await repo.getAllGoals();
    return GoalsState(goals: list);
  }

  Future<void> addGoal(Goal goal) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(realGoalRepositoryProvider).createGoal(goal);
    });
    ref.invalidateSelf();
  }

  Future<void> archiveGoal(String id) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(realGoalRepositoryProvider).deleteGoal(id);
    });
    ref.invalidateSelf();
  }
}

final goalsNotifierProvider = AsyncNotifierProvider<GoalsNotifier, GoalsState>(() {
  return GoalsNotifier();
});

// --- Reports Feature ---
class ReportsState {
  final List<Snapshot> snapshots;
  final Map<String, double> assetAllocation;
  final Map<String, double> liabilityAllocation;

  ReportsState({
    required this.snapshots,
    required this.assetAllocation,
    required this.liabilityAllocation,
  });
}

class ReportsNotifier extends AsyncNotifier<ReportsState> {
  @override
  FutureOr<ReportsState> build() async {
    final repo = ref.watch(realReportRepositoryProvider);
    
    final snapshots = await repo.getAllSnapshots();
    final assetsAlloc = await repo.getAssetAllocation();
    final liabilityAlloc = await repo.getLiabilityAllocation();

    return ReportsState(
      snapshots: snapshots,
      assetAllocation: assetsAlloc,
      liabilityAllocation: liabilityAlloc,
    );
  }

  Future<void> recordSnapshot(Snapshot snapshot) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(realReportRepositoryProvider).createSnapshot(snapshot);
    });
    ref.invalidateSelf();
  }
}

final reportsNotifierProvider = AsyncNotifierProvider<ReportsNotifier, ReportsState>(() {
  return ReportsNotifier();
});
