import 'package:drift/drift.dart';
import 'database.dart';

/// Seeds the AppDatabase with default settings, milestones, and achievements only if the database is brand new.
Future<void> seedDatabaseIfEmpty(AppDatabase db) async {
  // Check if settings have already been initialized
  final settingsList = await db.select(db.settings).get();
  if (settingsList.isNotEmpty) {
    return; // Already initialized — nothing to do.
  }

  // Insert default app settings, milestones, and achievements
  await db.transaction(() async {
    // Settings
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'currency', value: const Value('₹')));
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'themeMode', value: const Value('dark')));
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'appLockEnabled', value: const Value('false')));
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'appLockPin', value: const Value('')));
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'appLockTimeout', value: const Value('0')));

    final now = DateTime.now().toUtc();
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'user_created_at', value: Value(now.toIso8601String())));

    // Default Milestones
    final defaultMilestones = [
      1000.0,
      5000.0,
      10000.0,
      25000.0,
      50000.0,
      100000.0,
      250000.0,
      500000.0,
      1000000.0,
      2500000.0,
      5000000.0,
      10000000.0,
    ];
    
    final uniqueMilestones = defaultMilestones.toSet().toList()..sort();
    for (final amount in uniqueMilestones) {
      await db.into(db.milestones).insert(
        MilestonesCompanion.insert(
          id: 'milestone_${amount.toInt()}',
          amount: amount,
          isManual: const Value(0),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    // Default Achievements
    final defaultAchievements = [
      // Wealth Building
      _ach('wb_first_asset', 'First Asset Added', 'Add your first wealth asset container.', 'wealth_building'),
      _ach('wb_assets_10', '10 Assets Tracked', 'Track 10 active wealth assets simultaneously.', 'wealth_building'),
      _ach('wb_nw_positive', 'Net Worth Positive', 'Cross above zero into positive net worth.', 'wealth_building'),
      _ach('wb_nw_100k', '₹100K Net Worth', 'Accumulate ₹100,000 in net worth.', 'wealth_building'),
      _ach('wb_nw_500k', '₹500K Net Worth', 'Accumulate ₹500,000 in net worth.', 'wealth_building'),
      _ach('wb_nw_1m', '₹1M Net Worth', 'Accumulate ₹1,000,000 in net worth.', 'wealth_building'),
      // Investment
      _ach('inv_first', 'First Investment', 'Make your first investment purchase.', 'investment'),
      _ach('inv_count_10', '10 Investments Added', 'Add 10 investments to your portfolio.', 'investment'),
      _ach('inv_total_100k', 'Invested ₹100K', 'Reach ₹100,000 in total invested capital principal.', 'investment'),
      _ach('inv_total_500k', 'Invested ₹500K', 'Reach ₹500,000 in total invested capital principal.', 'investment'),
      // Debt Management
      _ach('debt_first_clear', 'First Liability Cleared', 'Pay off a liability in full.', 'debt_management'),
      _ach('debt_reduced_50', 'Debt Reduced By 50%', 'Reduce your total liabilities by 50% from its peak.', 'debt_management'),
      _ach('debt_free', 'Debt Free', 'Achieve zero outstanding liabilities.', 'debt_management'),
      // Receivables
      _ach('rec_first_recovery', 'First Recovery', 'Recover money owed from a borrower.', 'receivables'),
      _ach('rec_total_10k', 'Recovered ₹10K', 'Recover ₹10,000 in total receivables.', 'receivables'),
      _ach('rec_total_100k', 'Recovered ₹100K', 'Recover ₹100,000 in total receivables.', 'receivables'),
      // Consistency
      _ach('con_30_days', 'Tracked 30 Days', 'Maintain records for 30 days.', 'consistency'),
      _ach('con_90_days', 'Tracked 90 Days', 'Maintain records for 90 days.', 'consistency'),
      _ach('con_365_days', 'Tracked 365 Days', 'Maintain records for 365 days.', 'consistency'),
      _ach('con_12_reviews', '12 Consecutive Reviews', 'Log 12 consecutive monthly snapshots.', 'consistency'),
      // Goals
      _ach('goal_first_create', 'First Goal Created', 'Set a passive milestone wealth goal.', 'goals'),
      _ach('goal_first_complete', 'First Goal Completed', 'Achieve 100% of a milestone goal.', 'goals'),
      _ach('goal_count_5', '5 Goals Completed', 'Complete 5 milestone goals.', 'goals'),
    ];

    for (final ach in defaultAchievements) {
      await db.into(db.achievements).insert(ach);
    }

    // Default Achievement Progress rows
    final progressRows = [
      _prog('wb_assets_10', 0.0, 10.0),
      _prog('wb_nw_100k', 0.0, 100000.0),
      _prog('wb_nw_500k', 0.0, 500000.0),
      _prog('wb_nw_1m', 0.0, 1000000.0),
      _prog('inv_count_10', 0.0, 10.0),
      _prog('inv_total_100k', 0.0, 100000.0),
      _prog('inv_total_500k', 0.0, 500000.0),
      _prog('rec_total_10k', 0.0, 10000.0),
      _prog('rec_total_100k', 0.0, 100000.0),
      _prog('con_30_days', 0.0, 30.0),
      _prog('con_90_days', 0.0, 90.0),
      _prog('con_365_days', 0.0, 365.0),
      _prog('con_12_reviews', 0.0, 12.0),
      _prog('goal_count_5', 0.0, 5.0),
    ];

    for (final prog in progressRows) {
      await db.into(db.achievementProgress).insert(prog);
    }
  });
}

AchievementsCompanion _ach(String id, String title, String desc, String category) {
  final now = DateTime.now().toUtc();
  return AchievementsCompanion.insert(
    id: id,
    title: title,
    description: desc,
    category: category,
    unlockedStatus: const Value(0),
    createdAt: now,
    updatedAt: now,
  );
}

AchievementProgressCompanion _prog(String achId, double cur, double tar) {
  return AchievementProgressCompanion.insert(
    id: 'prog_$achId',
    achievementId: achId,
    currentValue: cur,
    targetValue: tar,
    updatedAt: DateTime.now().toUtc(),
  );
}
