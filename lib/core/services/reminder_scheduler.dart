import 'dart:async';
import 'package:drift/drift.dart';
import '../../database/database.dart' as db;
import 'notification_service.dart';

class ReminderScheduler {
  final db.AppDatabase _db;
  final NotificationService _notificationService;
  final Future<void> Function()? onCheck;
  Timer? _timer;

  ReminderScheduler(this._db, this._notificationService, {this.onCheck});

  // Starts the scheduler to run checks immediately and then periodically (e.g., every 12 hours)
  void start() {
    _timer?.cancel();
    
    // Run initial scan on startup
    checkAndTriggerReminders();

    // Schedule scan every 12 hours
    _timer = Timer.periodic(const Duration(hours: 12), (_) {
      checkAndTriggerReminders();
    });
  }

  // Stop background timer
  void stop() {
    _timer?.cancel();
  }

  // Scan database and trigger notifications
  Future<void> checkAndTriggerReminders() async {
    try {
      if (onCheck != null) {
        await onCheck!();
      }
      await _checkGoals();
      await _checkLiabilities();
      await _checkReceivables();
      await _checkExpectedIncome();
    } catch (_) {
      // Graceful error isolation in background processes
    }
  }

  // 1. Check Goal Deadlines
  Future<void> _checkGoals() async {
    final goals = await (_db.select(_db.goals)..where((tbl) => tbl.isArchived.equals(0))).get();
    final now = DateTime.now();
    final currency = await _getCurrency();

    for (final goal in goals) {
      if (goal.currentAmount >= goal.targetAmount) continue;
      
      if (goal.deadline != null) {
        final difference = goal.deadline!.difference(now);
        final daysLeft = difference.inDays;

        if (daysLeft >= 0 && daysLeft <= 7) {
          final remaining = goal.targetAmount - goal.currentAmount;
          _notificationService.showNotification(
            title: 'Goal Target Approaching',
            body: 'Your goal "${goal.name}" is due in $daysLeft days. You need $currency${remaining.toStringAsFixed(2)} to complete it.',
            type: 'goal',
          );
        }
      }
    }
  }

  // 2. Check Liabilities (Credit Cards & Debts)
  Future<void> _checkLiabilities() async {
    final currency = await _getCurrency();
    // Check person liabilities (debts owed to others)
    final debts = await (_db.select(_db.personBalanceCaches).join([
      innerJoin(_db.people, _db.people.id.equalsExp(_db.personBalanceCaches.personId)),
    ])..where(_db.people.isArchived.equals(0) & _db.personBalanceCaches.liabilityBalance.isBiggerThanValue(0.0))).get();

    for (final row in debts) {
      final person = row.readTable(_db.people);
      final cache = row.readTable(_db.personBalanceCaches);
      _notificationService.showNotification(
        title: 'Outstanding Debt Reminder',
        body: 'You have an outstanding liability of $currency${cache.liabilityBalance.toStringAsFixed(2)} owed to ${person.name}.',
        type: 'liability',
      );
    }

    // Check credit cards with balance
    final creditCards = await (_db.select(_db.accountBalanceCaches).join([
      innerJoin(_db.accounts, _db.accounts.id.equalsExp(_db.accountBalanceCaches.accountId)),
    ])..where(_db.accounts.type.equals('credit') & _db.accounts.isArchived.equals(0) & _db.accountBalanceCaches.liabilityBalance.isBiggerThanValue(0.0))).get();

    for (final row in creditCards) {
      final account = row.readTable(_db.accounts);
      final cache = row.readTable(_db.accountBalanceCaches);
      _notificationService.showNotification(
        title: 'Credit Card Payment Reminder',
        body: 'Your credit card "${account.name}" has outstanding dues of $currency${cache.liabilityBalance.toStringAsFixed(2)}.',
        type: 'liability',
      );
    }
  }

  // 3. Check Receivables (Lent Money Outstanding)
  Future<void> _checkReceivables() async {
    final currency = await _getCurrency();
    final receivables = await (_db.select(_db.personBalanceCaches).join([
      innerJoin(_db.people, _db.people.id.equalsExp(_db.personBalanceCaches.personId)),
    ])..where(_db.people.isArchived.equals(0) & _db.personBalanceCaches.receivableBalance.isBiggerThanValue(0.0))).get();

    for (final row in receivables) {
      final person = row.readTable(_db.people);
      final cache = row.readTable(_db.personBalanceCaches);
      _notificationService.showNotification(
        title: 'Receivable Follow-up Alert',
        body: '${person.name} owes you $currency${cache.receivableBalance.toStringAsFixed(2)}. Consider reaching out for recovery.',
        type: 'receivable',
      );
    }
  }

  // 4. Check Expected Income Milestones
  Future<void> _checkExpectedIncome() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currency = await _getCurrency();
    
    final expectedIncomes = await (_db.select(_db.expectedIncomes)
          ..where((tbl) => (tbl as db.$ExpectedIncomesTable).status.equals('pending')))
        .get();

    for (final inc in expectedIncomes) {
      if (inc.expectedDate != null) {
        final expectedDate = DateTime(
          inc.expectedDate!.year,
          inc.expectedDate!.month,
          inc.expectedDate!.day,
        );

        final daysDiff = expectedDate.difference(today).inDays;

        if (daysDiff == 0) {
          _notificationService.showNotification(
            title: 'Expected Income Today',
            body: 'Income of $currency${inc.amount} from "${inc.source}" is scheduled to be received today.',
            type: 'expected_income',
          );
        } else if (daysDiff < 0) {
          _notificationService.showNotification(
            title: 'Overdue Expected Income',
            body: 'Income of $currency${inc.amount} from "${inc.source}" was scheduled for ${-daysDiff} days ago but is still pending.',
            type: 'expected_income',
          );
        }
      }
    }
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
