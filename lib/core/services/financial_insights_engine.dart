import 'dart:math';
import 'package:drift/drift.dart';
import '../../database/database.dart' as db;
import 'notification_service.dart';

/// Generates randomised, data-filtered financial insight notifications.
///
/// Rules:
///   - Called once per day by WorkManager — never on app launch.
///   - Schedules 2–5 notifications between 09:00 AM and 09:00 PM.
///   - Minimum 90-minute gap between notifications.
///   - Only includes insights where the underlying data exists.
///   - Cancels previous day's insights (IDs 9000–9099) before scheduling.
class FinancialInsightsEngine {
  final db.AppDatabase _database;
  final NotificationService _notificationService;
  final _rng = Random();

  static const int _insightIdBase = 9000;
  static const int _insightIdMax  = 9099;
  static const int _minPerDay = 2;
  static const int _maxPerDay = 5;

  // Delivery window: 09:00 AM → 09:00 PM
  static const int _windowStartHour = 9;
  static const int _windowEndHour   = 21;

  // Minimum minutes between two consecutive notifications
  static const int _minGapMinutes = 90;

  FinancialInsightsEngine(this._database, this._notificationService);

  /// Main entry point — called by WorkManager background task.
  Future<void> scheduleRandomDailyInsights({bool respectUserPrefs = true}) async {
    // Cancel any leftover insights from previous day
    for (int id = _insightIdBase; id <= _insightIdMax; id++) {
      await _notificationService.cancelNotification(id);
    }

    final currency = await _getCurrency();
    final now = DateTime.now();

    // Build the pool of applicable insight messages
    final pool = await _buildInsightPool(currency, now);
    if (pool.isEmpty) return;

    // How many to send today (2–5, capped by pool size)
    final count = min(_rng.nextInt(_maxPerDay - _minPerDay + 1) + _minPerDay,
        pool.length);

    // Pick `count` unique insights
    final selected = _pickRandom(pool, count);

    // Generate delivery times within the window with minimum gap
    final times = _generateDeliveryTimes(now, count);

    // Schedule each insight
    for (int i = 0; i < selected.length; i++) {
      final insight = selected[i];
      final deliveryTime = times[i];

      await _notificationService.scheduleNotification(
        id: _insightIdBase + i,
        title: insight.title,
        body: insight.body,
        scheduledDateTime: deliveryTime,
        type: 'insight',
        channelId: kChannelInsights,
      );
    }
  }

  // ── Build insight pool from live database ──────────────────────────────────

  Future<List<_Insight>> _buildInsightPool(
      String currency, DateTime now) async {
    final pool = <_Insight>[];

    // ── Net worth data
    try {
      final caches = await _database.select(_database.accountBalanceCaches).get();
      double totalCash = 0;
      double totalDebt = 0;
      for (final c in caches) {
        totalCash += c.cashBalance;
        totalDebt += c.liabilityBalance;
      }
      final netWorth = totalCash - totalDebt;

      pool.add(_Insight(
        title: 'Your Net Worth Today',
        body: 'Your current net worth is $currency${_fmt(netWorth)}.',
      ));

      if (totalCash > 0 && totalDebt > 0) {
        final debtRatio = (totalDebt / (totalCash + totalDebt) * 100).round();
        pool.add(_Insight(
          title: 'Debt-to-Assets Ratio',
          body: 'Debt-funded positions represent $debtRatio% of your total assets.',
        ));
      }
    } catch (_) {}

    // ── Receivables
    try {
      final receivables = await (_database.select(_database.personBalanceCaches)
            ..where((t) => t.receivableBalance.isBiggerThanValue(0.0)))
          .get();
      if (receivables.isNotEmpty) {
        final total = receivables.fold(0.0,
            (sum, r) => sum + r.receivableBalance);
        pool.add(_Insight(
          title: 'Pending Receivables',
          body: 'You have $currency${_fmt(total)} in outstanding receivables.',
        ));
      }
    } catch (_) {}

    // ── SIPs — next due
    try {
      final sips = await (_database.select(_database.sips)
            ..where((t) => t.isActive.equals(1)))
          .get();
      if (sips.isNotEmpty) {
        final next = sips
            .where((s) => s.nextDueDate != null)
            .toList()
          ..sort((a, b) => a.nextDueDate!.compareTo(b.nextDueDate!));
        if (next.isNotEmpty) {
          final sip = next.first;
          final days = sip.nextDueDate!.difference(now).inDays;
          final daysStr = days == 0 ? 'today' : 'in $days day${days == 1 ? '' : 's'}';
          pool.add(_Insight(
            title: 'Upcoming SIP',
            body: 'Your SIP of $currency${_fmt(sip.amount)} is due $daysStr.',
          ));
        }
      }
    } catch (_) {}

    // ── Credit card dues
    try {
      final ccRows = await (_database.select(_database.accountBalanceCaches).join([
        innerJoin(
          _database.accounts,
          _database.accounts.id.equalsExp(_database.accountBalanceCaches.accountId),
        ),
      ])
            ..where(_database.accounts.type.equals('credit') &
                _database.accountBalanceCaches.liabilityBalance.isBiggerThanValue(0.0)))
          .get();
      if (ccRows.isNotEmpty) {
        final total = ccRows.fold(
          0.0,
          (sum, r) => sum + r.readTable(_database.accountBalanceCaches).liabilityBalance,
        );
        pool.add(_Insight(
          title: 'Credit Card Payment Due',
          body: 'Your total credit card outstanding is $currency${_fmt(total)}.',
        ));
      }
    } catch (_) {}

    // ── Last backup age
    try {
      final settingsList = await _database.select(_database.settings).get();
      final settingsMap = {for (var s in settingsList) s.key: s.value};
      final lastBackupStr = settingsMap['lastBackupDate'];
      if (lastBackupStr != null) {
        final lastBackup = DateTime.tryParse(lastBackupStr);
        if (lastBackup != null) {
          final daysAgo = now.difference(lastBackup).inDays;
          if (daysAgo <= 7) {
            pool.add(_Insight(
              title: 'Backup Status',
              body: 'Your last Worth backup was $daysAgo day${daysAgo == 1 ? '' : 's'} ago. All data is safe.',
            ));
          }
        }
      }
    } catch (_) {}

    // ── Investments portfolio value
    try {
      final invCaches = await _database.select(_database.investmentBalanceCaches).get();
      if (invCaches.isNotEmpty) {
        double totalCapital = 0;
        double totalUnits = 0;
        for (final c in invCaches) {
          totalCapital += c.investedCapital;
          totalUnits   += c.unitsHeld;
        }
        if (totalCapital > 0) {
          // Use invested capital as net worth contribution metric
          pool.add(_Insight(
            title: 'Investment Portfolio',
            body: 'Total invested capital: $currency${_fmt(totalCapital)} across ${invCaches.length} investments.',
          ));
        }
      }
    } catch (_) {}

    return pool;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<_Insight> _pickRandom(List<_Insight> pool, int count) {
    final shuffled = List<_Insight>.from(pool)..shuffle(_rng);
    return shuffled.take(count).toList();
  }

  List<DateTime> _generateDeliveryTimes(DateTime now, int count) {
    final today = DateTime(now.year, now.month, now.day);
    final windowStart = today.add(Duration(hours: _windowStartHour));
    final windowEnd   = today.add(Duration(hours: _windowEndHour));

    final times = <DateTime>[];
    DateTime cursor = windowStart;

    for (int i = 0; i < count; i++) {
      final remaining = count - i - 1;
      final latest = windowEnd
          .subtract(Duration(minutes: _minGapMinutes * remaining));

      final maxMinutesFromCursor = latest.difference(cursor).inMinutes;
      if (maxMinutesFromCursor <= 0) {
        times.add(cursor);
        cursor = cursor.add(Duration(minutes: _minGapMinutes));
      } else {
        final offset = _rng.nextInt(maxMinutesFromCursor + 1);
        final delivery = cursor.add(Duration(minutes: offset));
        times.add(delivery);
        cursor = delivery.add(Duration(minutes: _minGapMinutes));
      }
    }

    // If times are in the past (e.g. engine ran after window start), push to future
    return times.map((t) => t.isBefore(now) ? now.add(const Duration(minutes: 30)) : t).toList();
  }

  Future<String> _getCurrency() async {
    try {
      final list = await _database.select(_database.settings).get();
      return {for (var s in list) s.key: s.value}['currency'] ?? '₹';
    } catch (_) {
      return '₹';
    }
  }

  String _fmt(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(2)} Cr';
    if (v >= 100000)   return '${(v / 100000).toStringAsFixed(2)} L';
    if (v >= 1000)     return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _Insight {
  final String title;
  final String body;
  const _Insight({required this.title, required this.body});
}
