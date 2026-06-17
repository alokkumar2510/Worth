import 'dart:async';
import 'package:drift/drift.dart';
import 'package:collection/collection.dart';
import '../../../../database/database.dart';
import '../../../../core/calculation/net_worth_service.dart';

class GamificationEvent {
  final String type; // 'milestone' | 'achievement'
  final String id;
  final String title;
  final String description;
  final DateTime date;

  GamificationEvent({
    required this.type,
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });
}

class GamificationEngine {
  final AppDatabase? _db;
  final _eventController = StreamController<GamificationEvent>.broadcast();

  GamificationEngine(this._db);

  Stream<GamificationEvent> get events => _eventController.stream;

  void dispose() {
    _eventController.close();
  }

  /// Evaluates milestones and achievements using the active Drift connection.
  Future<void> evaluateAll() async {
    final db = _db;
    if (db == null) return;

    try {
      // 1. Fetch current status
      final netWorthData = await NetWorthService(db).calculateNetWorth();
      final currentNetWorth = netWorthData.netWorth;
      final currentAssets = netWorthData.assets;
      final currentLiabilities = netWorthData.liabilities;
      final investedCapital = netWorthData.investedCapital;

      final accounts = await db.select(db.accounts).get();
      final activeAccountsCount = accounts.where((a) => a.isArchived == 0 && a.type != 'credit').length;

      final investments = await db.select(db.investments).get();
      final activeInvestmentsCount = investments.where((i) => i.isArchived == 0).length;

      final goals = await db.select(db.goals).get();
      final activeGoals = goals.where((g) => g.isArchived == 0).toList();
      final goalsCompletedCount = activeGoals.where((g) => g.currentAmount >= g.targetAmount).length;

      final transactions = await db.select(db.transactions).get();
      final snapshots = await db.select(db.snapshots).get();

      // Peak liabilities
      double peakLiabilities = currentLiabilities;
      for (final s in snapshots) {
        if (s.liabilities > peakLiabilities) {
          peakLiabilities = s.liabilities;
        }
      }

      // First liability cleared / repayment count
      final repayTxs = transactions.where((t) => t.type == 'repay_money' && t.voidedTransactionId == null).toList();
      final hasRepayTx = repayTxs.isNotEmpty;

      // Receivables recovered
      final recoverTxs = transactions.where((t) => t.type == 'recover_money' && t.voidedTransactionId == null).toList();
      final totalRecovered = recoverTxs.fold<double>(0.0, (sum, t) => sum + t.amount);

      // Days tracked
      final dates = [
        ...transactions.map((t) => t.transactionDate),
        ...snapshots.map((s) => s.snapshotDate),
        ...accounts.map((a) => a.createdAt),
      ];
      int daysTracked = 0;
      if (dates.isNotEmpty) {
        final earliest = dates.reduce((a, b) => a.isBefore(b) ? a : b);
        daysTracked = DateTime.now().difference(earliest).inDays;
      }

      // 12 Consecutive monthly reviews
      int maxConsecutiveMonths = 0;
      if (snapshots.isNotEmpty) {
        final sortedDates = snapshots.map((s) => s.snapshotDate).toList()..sort();
        final monthKeys = sortedDates.map((d) => DateTime(d.year, d.month)).toSet().toList()..sort();

        int currentStreak = 1;
        maxConsecutiveMonths = 1;
        for (int i = 1; i < monthKeys.length; i++) {
          final prev = monthKeys[i - 1];
          final curr = monthKeys[i];
          final expectedNext = DateTime(prev.year, prev.month + 1);
          if (curr.year == expectedNext.year && curr.month == expectedNext.month) {
            currentStreak++;
            if (currentStreak > maxConsecutiveMonths) {
              maxConsecutiveMonths = currentStreak;
            }
          } else if (curr.isAfter(expectedNext)) {
            currentStreak = 1;
          }
        }
      }

      // Fetch achievements, progress, and milestones from DB
      final dbAchievements = await db.select(db.achievements).get();
      final dbProgress = await db.select(db.achievementProgress).get();
      final dbMilestones = await db.select(db.milestones).get();

      final now = DateTime.now().toUtc();
      final List<GamificationEvent> newEvents = [];

      await db.transaction(() async {
        // --- MILESTONES EVALUATION ---
        // Sort milestones by amount to ensure proper daysSincePrevious calculation
        final sortedMilestones = List<Milestone>.from(dbMilestones)
          ..sort((a, b) => a.amount.compareTo(b.amount));

        for (int i = 0; i < sortedMilestones.length; i++) {
          final milestone = sortedMilestones[i];
          if (milestone.dateAchieved == null && currentNetWorth >= milestone.amount) {
            // Unlocked milestone!
            DateTime achievedDate = now;

            // Find days since previous achieved milestone
            int? daysSincePrev;
            final prevMilestone = sortedMilestones
                .take(i)
                .toList()
                .reversed
                .firstWhereOrNull((m) => m.dateAchieved != null);

            if (prevMilestone != null && prevMilestone.dateAchieved != null) {
              daysSincePrev = achievedDate.difference(prevMilestone.dateAchieved!).inDays;
            }

            // Update in DB
            await (db.update(db.milestones)..where((tbl) => tbl.id.equals(milestone.id)))
                .write(MilestonesCompanion(
              dateAchieved: Value<DateTime?>(achievedDate),
              daysSincePrevious: Value<int?>(daysSincePrev),
              netWorthAtAchievement: Value<double?>(currentNetWorth),
              updatedAt: Value<DateTime>(achievedDate),
            ));

            // Mark as achieved in our local copy for subsequent checks
            sortedMilestones[i] = milestone.copyWith(
              dateAchieved: Value<DateTime?>(achievedDate),
              daysSincePrevious: Value<int?>(daysSincePrev),
              netWorthAtAchievement: Value<double?>(currentNetWorth),
            );

            final formattedAmount = milestone.amount >= 100000
                ? '₹${(milestone.amount / 100000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}L'
                : '₹${milestone.amount.toInt()}';

            newEvents.add(GamificationEvent(
              type: 'milestone',
              id: milestone.id,
              title: '$formattedAmount Net Worth',
              description: 'Achieved net worth milestone of $formattedAmount.',
              date: achievedDate,
            ));
          }
        }

        // --- ACHIEVEMENTS EVALUATION ---
        // Helper to update progress and unlock achievements
        Future<void> evaluateAch({
          required String id,
          required double currentProgress,
          required double targetProgress,
          required bool isUnlockedCondition,
        }) async {
          final ach = dbAchievements.firstWhereOrNull((a) => a.id == id);
          if (ach == null) return;

          // Check if progress needs updating
          final prog = dbProgress.firstWhereOrNull((p) => p.achievementId == id);
          if (prog != null) {
            if (prog.currentValue != currentProgress || prog.targetValue != targetProgress) {
              await (db.update(db.achievementProgress)..where((tbl) => tbl.id.equals(prog.id)))
                  .write(AchievementProgressCompanion(
                currentValue: Value(currentProgress),
                targetValue: Value(targetProgress),
                updatedAt: Value(now),
              ));
            }
          }

          // Check if achievement unlocked status needs updating
          if (ach.unlockedStatus == 0 && isUnlockedCondition) {
            await (db.update(db.achievements)..where((tbl) => tbl.id.equals(id)))
                .write(AchievementsCompanion(
              unlockedStatus: const Value(1),
              dateUnlocked: Value(now),
              updatedAt: Value(now),
            ));

            newEvents.add(GamificationEvent(
              type: 'achievement',
              id: ach.id,
              title: ach.title,
              description: ach.description,
              date: now,
            ));
          }
        }

        // 1. Wealth Building
        await evaluateAch(
          id: 'wb_first_asset',
          currentProgress: activeAccountsCount.toDouble(),
          targetProgress: 1.0,
          isUnlockedCondition: activeAccountsCount > 0,
        );
        await evaluateAch(
          id: 'wb_assets_10',
          currentProgress: activeAccountsCount.toDouble(),
          targetProgress: 10.0,
          isUnlockedCondition: activeAccountsCount >= 10,
        );
        await evaluateAch(
          id: 'wb_nw_positive',
          currentProgress: currentNetWorth,
          targetProgress: 0.01,
          isUnlockedCondition: currentNetWorth > 0,
        );
        await evaluateAch(
          id: 'wb_nw_100k',
          currentProgress: currentNetWorth,
          targetProgress: 100000.0,
          isUnlockedCondition: currentNetWorth >= 100000.0,
        );
        await evaluateAch(
          id: 'wb_nw_500k',
          currentProgress: currentNetWorth,
          targetProgress: 500000.0,
          isUnlockedCondition: currentNetWorth >= 500000.0,
        );
        await evaluateAch(
          id: 'wb_nw_1m',
          currentProgress: currentNetWorth,
          targetProgress: 1000000.0,
          isUnlockedCondition: currentNetWorth >= 1000000.0,
        );

        // 2. Investment
        await evaluateAch(
          id: 'inv_first',
          currentProgress: activeInvestmentsCount.toDouble(),
          targetProgress: 1.0,
          isUnlockedCondition: activeInvestmentsCount > 0,
        );
        await evaluateAch(
          id: 'inv_count_10',
          currentProgress: activeInvestmentsCount.toDouble(),
          targetProgress: 10.0,
          isUnlockedCondition: activeInvestmentsCount >= 10,
        );
        await evaluateAch(
          id: 'inv_total_100k',
          currentProgress: investedCapital,
          targetProgress: 100000.0,
          isUnlockedCondition: investedCapital >= 100000.0,
        );
        await evaluateAch(
          id: 'inv_total_500k',
          currentProgress: investedCapital,
          targetProgress: 500000.0,
          isUnlockedCondition: investedCapital >= 500000.0,
        );

        // 3. Debt Management
        await evaluateAch(
          id: 'debt_first_clear',
          currentProgress: hasRepayTx ? 1.0 : 0.0,
          targetProgress: 1.0,
          isUnlockedCondition: hasRepayTx,
        );
        await evaluateAch(
          id: 'debt_reduced_50',
          currentProgress: peakLiabilities > 0 && currentLiabilities <= peakLiabilities * 0.5 ? 1.0 : 0.0,
          targetProgress: 1.0,
          isUnlockedCondition: peakLiabilities > 0 && currentLiabilities <= peakLiabilities * 0.5,
        );
        await evaluateAch(
          id: 'debt_free',
          currentProgress: currentLiabilities == 0 && peakLiabilities > 0 ? 1.0 : 0.0,
          targetProgress: 1.0,
          isUnlockedCondition: currentLiabilities == 0 && peakLiabilities > 0,
        );

        // 4. Receivables
        await evaluateAch(
          id: 'rec_first_recovery',
          currentProgress: recoverTxs.isNotEmpty ? 1.0 : 0.0,
          targetProgress: 1.0,
          isUnlockedCondition: recoverTxs.isNotEmpty,
        );
        await evaluateAch(
          id: 'rec_total_10k',
          currentProgress: totalRecovered,
          targetProgress: 10000.0,
          isUnlockedCondition: totalRecovered >= 10000.0,
        );
        await evaluateAch(
          id: 'rec_total_100k',
          currentProgress: totalRecovered,
          targetProgress: 100000.0,
          isUnlockedCondition: totalRecovered >= 100000.0,
        );

        // 5. Consistency
        await evaluateAch(
          id: 'con_30_days',
          currentProgress: daysTracked.toDouble(),
          targetProgress: 30.0,
          isUnlockedCondition: daysTracked >= 30,
        );
        await evaluateAch(
          id: 'con_90_days',
          currentProgress: daysTracked.toDouble(),
          targetProgress: 90.0,
          isUnlockedCondition: daysTracked >= 90,
        );
        await evaluateAch(
          id: 'con_365_days',
          currentProgress: daysTracked.toDouble(),
          targetProgress: 365.0,
          isUnlockedCondition: daysTracked >= 365,
        );
        await evaluateAch(
          id: 'con_12_reviews',
          currentProgress: maxConsecutiveMonths.toDouble(),
          targetProgress: 12.0,
          isUnlockedCondition: maxConsecutiveMonths >= 12,
        );

        // 6. Goals
        await evaluateAch(
          id: 'goal_first_create',
          currentProgress: activeGoals.length.toDouble(),
          targetProgress: 1.0,
          isUnlockedCondition: activeGoals.isNotEmpty,
        );
        await evaluateAch(
          id: 'goal_first_complete',
          currentProgress: goalsCompletedCount.toDouble(),
          targetProgress: 1.0,
          isUnlockedCondition: goalsCompletedCount >= 1,
        );
        await evaluateAch(
          id: 'goal_count_5',
          currentProgress: goalsCompletedCount.toDouble(),
          targetProgress: 5.0,
          isUnlockedCondition: goalsCompletedCount >= 5,
        );
      });

      // Dispatch events after transaction succeeds
      for (final event in newEvents) {
        _eventController.add(event);
      }
    } catch (e, stack) {
      // Avoid breaking app operations due to engine issues
      print('Gamification Engine Error: $e');
      print(stack);
    }
  }
}
