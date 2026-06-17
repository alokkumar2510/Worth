import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../database/database.dart' as db;
import '../../../../core/providers/mock_database.dart';
import '../../../../core/providers/dependency_provider.dart';

class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final int daysSinceLastActivity;
  final DateTime? lastActiveDate;

  StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.daysSinceLastActivity,
    this.lastActiveDate,
  });
}

class StreakEngine {
  final db.AppDatabase? _db;
  final Ref? _ref;

  StreakEngine(this._db, [this._ref]);

  /// Calculates the streak based on a list of active local dates (midnight).
  StreakInfo calculateStreak(List<DateTime> activeDates) {
    if (activeDates.isEmpty) {
      return StreakInfo(
        currentStreak: 0,
        longestStreak: 0,
        daysSinceLastActivity: 0,
        lastActiveDate: null,
      );
    }

    // 1. Normalize dates to midnight local time and remove duplicates
    final Set<DateTime> uniqueDates = activeDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    // 2. Sort dates in ascending order
    final List<DateTime> sortedDates = uniqueDates.toList()..sort();

    // 3. Calculate longest streak
    int maxStreak = 0;
    int currentRun = 0;
    DateTime? prevDate;

    for (final date in sortedDates) {
      if (prevDate == null) {
        currentRun = 1;
      } else {
        final difference = date.difference(prevDate).inDays;
        if (difference == 1) {
          currentRun++;
        } else if (difference > 1) {
          maxStreak = math.max(maxStreak, currentRun);
          currentRun = 1;
        }
      }
      prevDate = date;
    }
    maxStreak = math.max(maxStreak, currentRun);

    // 4. Calculate current streak
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    int currentStreak = 0;
    DateTime checkDate;

    if (uniqueDates.contains(today)) {
      checkDate = today;
    } else if (uniqueDates.contains(yesterday)) {
      checkDate = yesterday;
    } else {
      // Streak broken
      final lastActive = sortedDates.last;
      final daysSince = today.difference(lastActive).inDays;
      return StreakInfo(
        currentStreak: 0,
        longestStreak: maxStreak,
        daysSinceLastActivity: daysSince,
        lastActiveDate: lastActive,
      );
    }

    // Go backwards day by day to count consecutive days
    while (uniqueDates.contains(checkDate)) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    final lastActive = sortedDates.last;
    final daysSince = today.difference(lastActive).inDays;

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: maxStreak,
      daysSinceLastActivity: daysSince,
      lastActiveDate: lastActive,
    );
  }

  /// Calculates streak directly from Drift transactions database
  Future<StreakInfo> getStreakInfo() async {
    if (_ref != null && _ref!.read(mockModeProvider)) {
      final dbState = _ref!.read(mockDatabaseProvider);
      final activeDates = dbState.transactions.map((t) => t.transactionDate.toLocal()).toList();
      return calculateStreak(activeDates);
    }

    final db = _db;
    if (db == null) {
      return StreakInfo(
        currentStreak: 0,
        longestStreak: 0,
        daysSinceLastActivity: 0,
      );
    }

    try {
      // Select all transactions that are not voided
      final txs = await (db.select(db.transactions)
            ..where((tbl) => tbl.voidedTransactionId.isNull()))
          .get();

      final activeDates = txs.map((t) => t.transactionDate.toLocal()).toList();
      return calculateStreak(activeDates);
    } catch (_) {
      return StreakInfo(
        currentStreak: 0,
        longestStreak: 0,
        daysSinceLastActivity: 0,
      );
    }
  }
}
