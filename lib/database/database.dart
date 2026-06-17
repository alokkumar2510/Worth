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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 5; // Bumping version for Gamification tables

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
