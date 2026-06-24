import 'dart:async';
import 'dart:math';
import 'package:drift/drift.dart';
import '../../database/database.dart' as db;
import 'notification_service.dart';

/// Scans the database and schedules real OS notifications.
///
/// IMPORTANT: All notifications are SCHEDULED via flutter_local_notifications
/// (never shown immediately as in-app popups). This means users are not
/// interrupted while actively using the app.
class ReminderScheduler {
  final db.AppDatabase _db;
  final NotificationService _notificationService;
  final Future<void> Function()? onCheck;
  final Future<void> Function()? onCheckIn;
  Timer? _timer;
  Timer? _checkInTimer;

  final _rng = Random();

  ReminderScheduler(this._db, this._notificationService,
      {this.onCheck, this.onCheckIn});

  /// Starts periodic background scans.
  void start() {
    _timer?.cancel();
    _checkInTimer?.cancel();

    // Run initial scan on startup (schedules future notifications, no immediate popups)
    checkAndTriggerReminders();
    _triggerCheckIn();

    // Re-schedule every 12 hours
    _timer = Timer.periodic(const Duration(hours: 12), (_) {
      checkAndTriggerReminders();
    });

    // Check-in trigger every 15 minutes
    _checkInTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _triggerCheckIn();
    });
  }

  void stop() {
    _timer?.cancel();
    _checkInTimer?.cancel();
  }

  Future<void> _triggerCheckIn() async {
    try {
      if (onCheckIn != null) await onCheckIn!();
    } catch (_) {}
  }

  /// Scans database and schedules notifications for upcoming events.
  /// Nothing fires immediately — all notifications are scheduled in the future.
  Future<void> checkAndTriggerReminders() async {
    try {
      if (onCheck != null) await onCheck!();
      await _checkGoals();
      await _checkLiabilities();
      await _checkReceivables();
      await _checkExpectedIncome();
    } catch (_) {}
  }

  // ── Goal Deadline Reminders ────────────────────────────────────────────────

  Future<void> _checkGoals() async {
    final goals = await (_db.select(_db.goals)
          ..where((tbl) => tbl.isArchived.equals(0)))
        .get();
    final now = DateTime.now();
    final currency = await _getCurrency();

    for (final goal in goals) {
      if (goal.currentAmount >= goal.targetAmount) continue;
      if (goal.deadline == null) continue;

      final daysLeft = goal.deadline!.difference(now).inDays;
      if (daysLeft >= 0 && daysLeft <= 7) {
        final remaining = goal.targetAmount - goal.currentAmount;
        // Schedule 30–120 minutes from now so it appears in the status bar soon,
        // but never as an in-app popup
        await _notificationService.scheduleSystemNotification(
          id: 6000 + goal.id.hashCode.abs() % 999,
          title: 'Goal Deadline in $daysLeft days',
          body: '"${goal.name}" needs $currency${remaining.toStringAsFixed(0)} more to complete.',
          scheduledDateTime: _nearFuture(),
          type: 'goal',
          channelId: kChannelReminders,
        );
      }
    }
  }

  // ── Liability & Credit Card Reminders ─────────────────────────────────────

  Future<void> _checkLiabilities() async {
    final currency = await _getCurrency();

    // Debts owed to others
    final debts = await (_db.select(_db.personBalanceCaches).join([
      innerJoin(_db.people,
          _db.people.id.equalsExp(_db.personBalanceCaches.personId)),
    ])
          ..where(_db.people.isArchived.equals(0) &
              _db.personBalanceCaches.liabilityBalance.isBiggerThanValue(0.0)))
        .get();

    for (final row in debts) {
      final person = row.readTable(_db.people);
      final cache = row.readTable(_db.personBalanceCaches);
      await _notificationService.scheduleSystemNotification(
        id: 7000 + person.id.hashCode.abs() % 99,
        title: 'Outstanding Debt Reminder',
        body: 'You have $currency${cache.liabilityBalance.toStringAsFixed(0)} outstanding to ${person.name}.',
        scheduledDateTime: _nearFuture(),
        type: 'liability',
        channelId: kChannelReminders,
      );
    }

    // Credit card dues
    final creditCards = await (_db.select(_db.accountBalanceCaches).join([
      innerJoin(_db.accounts,
          _db.accounts.id.equalsExp(_db.accountBalanceCaches.accountId)),
    ])
          ..where(_db.accounts.type.equals('credit') &
              _db.accounts.isArchived.equals(0) &
              _db.accountBalanceCaches.liabilityBalance.isBiggerThanValue(0.0)))
        .get();

    for (final row in creditCards) {
      final account = row.readTable(_db.accounts);
      final cache = row.readTable(_db.accountBalanceCaches);
      await _notificationService.scheduleSystemNotification(
        id: 7100 + account.id.hashCode.abs() % 99,
        title: 'Credit Card Payment Due',
        body: '${account.name}: $currency${cache.liabilityBalance.toStringAsFixed(0)} outstanding.',
        scheduledDateTime: _nearFuture(),
        type: 'liability',
        channelId: kChannelReminders,
      );
    }
  }

  // ── Receivable Reminders ───────────────────────────────────────────────────

  Future<void> _checkReceivables() async {
    final currency = await _getCurrency();
    final receivables = await (_db.select(_db.personBalanceCaches).join([
      innerJoin(_db.people,
          _db.people.id.equalsExp(_db.personBalanceCaches.personId)),
    ])
          ..where(_db.people.isArchived.equals(0) &
              _db.personBalanceCaches.receivableBalance.isBiggerThanValue(0.0)))
        .get();

    for (final row in receivables) {
      final person = row.readTable(_db.people);
      final cache = row.readTable(_db.personBalanceCaches);
      await _notificationService.scheduleSystemNotification(
        id: 3000 + person.id.hashCode.abs() % 999,
        title: 'Receivable Follow-up',
        body: '${person.name} owes you $currency${cache.receivableBalance.toStringAsFixed(0)}.',
        scheduledDateTime: _nearFuture(),
        type: 'receivable',
        channelId: kChannelReminders,
      );
    }
  }

  // ── Expected Income Reminders ──────────────────────────────────────────────

  Future<void> _checkExpectedIncome() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currency = await _getCurrency();

    final expectedIncomes = await (_db.select(_db.expectedIncomes)
          ..where((tbl) =>
              (tbl as db.$ExpectedIncomesTable).status.equals('pending')))
        .get();

    for (final inc in expectedIncomes) {
      if (inc.expectedDate == null) continue;
      final expected = DateTime(
          inc.expectedDate!.year, inc.expectedDate!.month, inc.expectedDate!.day);
      final daysDiff = expected.difference(today).inDays;

      if (daysDiff == 0 || daysDiff < 0) {
        await _notificationService.scheduleSystemNotification(
          id: 8000 + inc.id.hashCode.abs() % 99,
          title: daysDiff == 0 ? 'Expected Income Today' : 'Overdue Expected Income',
          body: 'Income of $currency${inc.amount} from "${inc.source}" '
              '${daysDiff == 0 ? 'is due today' : 'was due ${-daysDiff} days ago'}.',
          scheduledDateTime: _nearFuture(),
          type: 'expected_income',
          channelId: kChannelReminders,
        );
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns a time 30–90 minutes from now — ensures notifications never
  /// appear immediately while the user is actively in the app.
  DateTime _nearFuture() {
    final delayMinutes = 30 + _rng.nextInt(60);
    return DateTime.now().add(Duration(minutes: delayMinutes));
  }

  Future<String> _getCurrency() async {
    try {
      final settingsList = await _db.select(_db.settings).get();
      final settingsMap = {for (var s in settingsList) s.key: s.value};
      return settingsMap['currency'] ?? '₹';
    } catch (_) {
      return '₹';
    }
  }
}
