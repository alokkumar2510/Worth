import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/accounts.dart';
import 'tables/people.dart';
import 'tables/investments.dart';
import 'tables/investment_lots.dart';
import 'tables/investment_lot_consumptions.dart';
import 'tables/transactions.dart';
import 'tables/expected_income.dart';
import 'tables/goals.dart';
import 'tables/goal_milestones.dart';
import 'tables/snapshots.dart';
import 'tables/settings.dart';
import 'tables/audit_logs.dart';
import 'tables/balance_caches.dart';
import 'tables/definitions.dart';
import 'tables/adjustments.dart';
import 'tables/milestones.dart';
import 'tables/achievements.dart';
import 'tables/achievement_progress.dart';
import 'tables/mtf_positions.dart';
import 'tables/sips.dart';
import 'tables/daily_check_ins.dart';
import 'tables/sync_queue.dart';
import 'tables/portfolio_histories.dart';
import 'tables/portfolio_snapshots.dart';
import 'tables/recovery_allocations.dart';
import 'tables/recovery_destinations.dart';
import 'tables/receivable_activities.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Accounts,
  People,
  Investments,
  InvestmentLots,
  InvestmentLotConsumptions,
  Transactions,
  ExpectedIncomes,
  Goals,
  GoalMilestones,
  Snapshots,
  Settings,
  AuditLogs,
  AccountBalanceCaches,
  PersonBalanceCaches,
  InvestmentBalanceCaches,
  Definitions,
  Adjustments,
  Milestones,
  Achievements,
  AchievementProgress,
  MtfPositions,
  Sips,
  DailyCheckIns,
  SyncQueues,
  PortfolioHistories,
  PortfolioSnapshots,
  RecoveryAllocations,
  RecoveryDestinations,
  ReceivableActivities,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 19; // Bumped for photoPath column in People

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createSearchIndexAndViews();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Create newly added tables in schema v2
            await m.createTable(goalMilestones);
            await m.createTable(definitions);
            
            // Re-generate indices and views
            await _createSearchIndexAndViews();
          }
          if (from < 3) {
            // Add syncStatus column to all sync-able tables
            await m.addColumn(accounts, accounts.syncStatus);
            await m.addColumn(people, people.syncStatus);
            await m.addColumn(investments, investments.syncStatus);
            await m.addColumn(investmentLots, investmentLots.syncStatus);
            await m.addColumn(transactions, transactions.syncStatus);
            await m.addColumn(expectedIncomes, expectedIncomes.syncStatus);
            await m.addColumn(goals, goals.syncStatus);
            
            // Snapshots needs both updatedAt and syncStatus
            await m.addColumn(snapshots, snapshots.updatedAt);
            await m.addColumn(snapshots, snapshots.syncStatus);
          }
          if (from < 4) {
            await m.createTable(adjustments);
          }
          if (from < 5) {
            await m.createTable(milestones);
            await m.createTable(achievements);
            await m.createTable(achievementProgress);
          }
          if (from < 6) {
            await m.createTable(mtfPositions);
          }
          if (from < 7) {
            await m.addColumn(mtfPositions, mtfPositions.interestStartDate);
            await m.createTable(sips);
          }
          if (from < 8) {
            await m.createTable(dailyCheckIns);
          }
          if (from < 9) {
            await m.addColumn(investments, investments.purchaseDate);
            await m.addColumn(investments, investments.purchaseTime);
          }
          if (from < 10) {
            await m.createTable(syncQueues);
            // Accounts
            await m.addColumn(accounts, accounts.lastSyncedAt);
            await m.addColumn(accounts, accounts.deviceId);
            // People
            await m.addColumn(people, people.lastSyncedAt);
            await m.addColumn(people, people.deviceId);
            // Investments
            await m.addColumn(investments, investments.lastSyncedAt);
            await m.addColumn(investments, investments.deviceId);
            // InvestmentLots
            await m.addColumn(investmentLots, investmentLots.lastSyncedAt);
            await m.addColumn(investmentLots, investmentLots.deviceId);
            // Transactions
            await m.addColumn(transactions, transactions.lastSyncedAt);
            await m.addColumn(transactions, transactions.deviceId);
            // ExpectedIncomes
            await m.addColumn(expectedIncomes, expectedIncomes.lastSyncedAt);
            await m.addColumn(expectedIncomes, expectedIncomes.deviceId);
            // Goals
            await m.addColumn(goals, goals.lastSyncedAt);
            await m.addColumn(goals, goals.deviceId);
            // Snapshots
            await m.addColumn(snapshots, snapshots.lastSyncedAt);
            await m.addColumn(snapshots, snapshots.deviceId);
            // Adjustments
            await m.addColumn(adjustments, adjustments.updatedAt);
            await m.addColumn(adjustments, adjustments.lastSyncedAt);
            await m.addColumn(adjustments, adjustments.deviceId);
            // MtfPositions
            await m.addColumn(mtfPositions, mtfPositions.lastSyncedAt);
            await m.addColumn(mtfPositions, mtfPositions.deviceId);
            // Sips
            await m.addColumn(sips, sips.lastSyncedAt);
            await m.addColumn(sips, sips.deviceId);
            // Settings
            await m.addColumn(settings, settings.createdAt);
            await m.addColumn(settings, settings.updatedAt);
            await m.addColumn(settings, settings.syncStatus);
            await m.addColumn(settings, settings.lastSyncedAt);
            await m.addColumn(settings, settings.deviceId);
          }
          if (from < 11) {
            await m.addColumn(mtfPositions, mtfPositions.purchaseDate);
            await m.addColumn(mtfPositions, mtfPositions.purchaseTime);
          }
          if (from < 12) {
            // Accounts
            await m.addColumn(accounts, accounts.deletedAt);
            await m.addColumn(accounts, accounts.deletedBy);
            // People
            await m.addColumn(people, people.deletedAt);
            await m.addColumn(people, people.deletedBy);
            // Investments
            await m.addColumn(investments, investments.deletedAt);
            await m.addColumn(investments, investments.deletedBy);
            // MtfPositions
            await m.addColumn(mtfPositions, mtfPositions.deletedAt);
            await m.addColumn(mtfPositions, mtfPositions.deletedBy);
            // ExpectedIncomes
            await m.addColumn(expectedIncomes, expectedIncomes.deletedAt);
            await m.addColumn(expectedIncomes, expectedIncomes.deletedBy);
            // Goals
            await m.addColumn(goals, goals.deletedAt);
            await m.addColumn(goals, goals.deletedBy);
            // Transactions
            await m.addColumn(transactions, transactions.deletedAt);
            await m.addColumn(transactions, transactions.deletedBy);
            // Sips
            await m.addColumn(sips, sips.deletedAt);
            await m.addColumn(sips, sips.deletedBy);
          }
          if (from < 13) {
            await m.createTable(portfolioHistories);
            await m.createTable(portfolioSnapshots);
          }
          if (from < 14) {
            await m.createTable(recoveryAllocations);
            await m.createTable(recoveryDestinations);
          }
          if (from < 15) {
            await m.addColumn(accounts, accounts.fundingSource);
            await m.addColumn(accounts, accounts.fundingLiabilityId);
            await m.addColumn(accounts, accounts.fundingDetails);

            await m.addColumn(investments, investments.fundingSource);
            await m.addColumn(investments, investments.fundingLiabilityId);
            await m.addColumn(investments, investments.fundingDetails);

            await m.addColumn(transactions, transactions.fundingSource);
            await m.addColumn(transactions, transactions.fundingLiabilityId);
            await m.addColumn(transactions, transactions.fundingDetails);

            await m.addColumn(investmentLots, investmentLots.fundingSource);
            await m.addColumn(investmentLots, investmentLots.fundingLiabilityId);
            await m.addColumn(investmentLots, investmentLots.fundingDetails);
          }
          if (from < 16) {
            await m.addColumn(sips, sips.importMode);
            await m.addColumn(sips, sips.completedInstallmentsOverride);
            await m.addColumn(sips, sips.worthCreationDate);
          }
          if (from < 17) {
            await m.addColumn(people, people.type);
          }
          if (from < 18) {
            await m.addColumn(people, people.whatsApp);
            await m.addColumn(people, people.dueDate);
            await m.addColumn(people, people.borrowDate);
            await m.addColumn(people, people.upiId);
            await m.addColumn(people, people.bankName);
            await m.addColumn(people, people.accountHolderName);

            await m.createTable(receivableActivities);
          }
          if (from < 19) {
            await m.addColumn(people, people.photoPath);
          }
        },
      );

  Future<void> _createSearchIndexAndViews() async {
    // Create SQLite FTS5 virtual table for search
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS search_index USING fts5(
        entity_type,
        entity_id,
        searchable_text
      );
    ''');

    // Create SQLite Views for derived financial positions
    await customStatement('''
      CREATE VIEW IF NOT EXISTS assets_view AS
      SELECT 
        (SELECT COALESCE(SUM(cash_balance), 0) FROM account_balance_caches JOIN accounts ON accounts.id = account_balance_caches.account_id WHERE accounts.type != 'credit' AND accounts.is_archived = 0) +
        (SELECT COALESCE(SUM(receivable_balance), 0) FROM person_balance_caches JOIN people ON people.id = person_balance_caches.person_id WHERE people.is_archived = 0) +
        (SELECT COALESCE(SUM(invested_capital), 0) FROM investment_balance_caches JOIN investments ON investments.id = investment_balance_caches.investment_id WHERE investments.is_archived = 0) AS total_assets;
    ''');

    await customStatement('''
      CREATE VIEW IF NOT EXISTS liabilities_view AS
      SELECT 
        (SELECT COALESCE(SUM(liability_balance), 0) FROM person_balance_caches JOIN people ON people.id = person_balance_caches.person_id WHERE people.is_archived = 0) +
        (SELECT COALESCE(SUM(liability_balance), 0) FROM account_balance_caches JOIN accounts ON accounts.id = account_balance_caches.account_id WHERE accounts.type = 'credit' AND accounts.is_archived = 0) AS total_liabilities;
    ''');

    await customStatement('''
      CREATE VIEW IF NOT EXISTS receivables_view AS
      SELECT 
        person_id, 
        receivable_balance 
      FROM person_balance_caches 
      WHERE receivable_balance > 0;
    ''');

    // Create indexes for performance
    await customStatement('CREATE INDEX IF NOT EXISTS idx_tx_date ON transactions(transaction_date);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_tx_type ON transactions(type);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_tx_from_account ON transactions(from_account_id, transaction_date);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_tx_to_account ON transactions(to_account_id, transaction_date);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_tx_person ON transactions(person_id, transaction_date);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_tx_investment ON transactions(investment_id, transaction_date);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_people_name ON people(name);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_accounts_name ON accounts(name);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_investments_type ON investments(type);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_expected_income_status ON expected_incomes(status);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_snapshots_date ON snapshots(snapshot_date);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_lots_investment ON investment_lots(investment_id, purchase_date);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_lot_consumptions_sell ON investment_lot_consumptions(sell_transaction_id);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_milestones_goal ON goal_milestones(goal_id);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_definitions_term ON definitions(term);');
  }
}

LazyDatabase openDatabaseConnection(String password) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'worth_db_v3.db'));
    return NativeDatabase(file);
  });
}

typedef Person = PeopleData;
typedef PersonBalanceCacheData = PersonBalanceCache;
