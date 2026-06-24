import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart' show NativeDatabase;
import '../../database/database.dart' as db;
import 'notification_service.dart';
import 'financial_insights_engine.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WorkManager Task Names
// ─────────────────────────────────────────────────────────────────────────────
const kTaskDailyInsights   = 'worth_daily_insights';
const kTaskDailyReminders  = 'worth_daily_reminders';

// ─────────────────────────────────────────────────────────────────────────────
// Background Dispatcher
//
// This function runs in a SEPARATE ISOLATE when WorkManager wakes the app.
// It must be a top-level @pragma('vm:entry-point') function.
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
void backgroundNotificationDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      // Open a fresh DB connection in this isolate
      final database = db.AppDatabase(
        db.openDatabaseConnection('worth_secure_encryption_password_key_v1'),
      );

      final notificationService = NotificationService();
      await notificationService.requestPermissions();

      switch (taskName) {
        case kTaskDailyInsights:
          final engine = FinancialInsightsEngine(database, notificationService);
          await engine.scheduleRandomDailyInsights();
          break;

        case kTaskDailyReminders:
          await _runDailyReminders(database, notificationService);
          break;
      }

      await database.close();
    } catch (e) {
      debugPrint('[WorkManager] Background task "$taskName" error: $e');
      return Future.value(false); // Workmanager will retry
    }

    return Future.value(true);
  });
}

/// Runs reminder checks in the background.
/// Uses scheduleSystemNotification so nothing fires as an in-app popup.
Future<void> _runDailyReminders(
  db.AppDatabase database,
  NotificationService notificationService,
) async {
  final now = DateTime.now();
  final currency = await _getCurrency(database);

  // ── Goals approaching deadline ─────────────────────────────────────────────
  try {
    final goals = await (database.select(database.goals)
          ..where((t) => t.isArchived.equals(0)))
        .get();
    for (final goal in goals) {
      if (goal.currentAmount >= goal.targetAmount) continue;
      if (goal.deadline == null) continue;
      final daysLeft = goal.deadline!.difference(now).inDays;
      if (daysLeft >= 0 && daysLeft <= 7) {
        final remaining = goal.targetAmount - goal.currentAmount;
        await notificationService.showSystemNotification(
          id: 6000 + goal.id.hashCode.abs() % 999,
          title: 'Goal Deadline in $daysLeft days',
          body: '"${goal.name}" needs $currency${_fmt(remaining)} more.',
          type: 'goal',
          channelId: kChannelReminders,
        );
      }
    }
  } catch (_) {}

  // ── Credit card dues ───────────────────────────────────────────────────────
  try {
    final ccRows = await (database.select(database.accountBalanceCaches).join([
      innerJoin(
        database.accounts,
        database.accounts.id.equalsExp(database.accountBalanceCaches.accountId),
      ),
    ])
          ..where(database.accounts.type.equals('credit') &
              database.accountBalanceCaches.liabilityBalance.isBiggerThanValue(0.0)))
        .get();
    for (final row in ccRows) {
      final account = row.readTable(database.accounts);
      final cache   = row.readTable(database.accountBalanceCaches);
      await notificationService.showSystemNotification(
        id: 7100 + account.id.hashCode.abs() % 99,
        title: 'Credit Card Due',
        body: '${account.name}: $currency${_fmt(cache.liabilityBalance)} outstanding.',
        type: 'liability',
        channelId: kChannelReminders,
      );
    }
  } catch (_) {}

  // ── Outstanding receivables ────────────────────────────────────────────────
  try {
    final recRows = await (database.select(database.personBalanceCaches).join([
      innerJoin(
        database.people,
        database.people.id.equalsExp(database.personBalanceCaches.personId),
      ),
    ])
          ..where(database.people.isArchived.equals(0) &
              database.personBalanceCaches.receivableBalance.isBiggerThanValue(0.0)))
        .get();
    for (final row in recRows) {
      final person = row.readTable(database.people);
      final cache  = row.readTable(database.personBalanceCaches);
      await notificationService.showSystemNotification(
        id: 3000 + person.id.hashCode.abs() % 999,
        title: 'Pending Receivable',
        body: '${person.name} owes you $currency${_fmt(cache.receivableBalance)}.',
        type: 'receivable',
        channelId: kChannelReminders,
      );
    }
  } catch (_) {}
}

// ─────────────────────────────────────────────────────────────────────────────
// WorkManagerService — registration helper called once on app startup
// ─────────────────────────────────────────────────────────────────────────────
class WorkManagerService {
  /// Call once from app.dart _initServices().
  static Future<void> initialize() async {
    await Workmanager().initialize(
      backgroundNotificationDispatcher,
      isInDebugMode: false,
    );

    // Daily insight notifications (every 24 hours)
    await Workmanager().registerPeriodicTask(
      kTaskDailyInsights,
      kTaskDailyInsights,
      frequency: const Duration(hours: 24),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 30),
    );

    // Reminders — runs every 12 hours
    await Workmanager().registerPeriodicTask(
      kTaskDailyReminders,
      kTaskDailyReminders,
      frequency: const Duration(hours: 12),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }
}

// ── Private helpers ────────────────────────────────────────────────────────────

Future<String> _getCurrency(db.AppDatabase database) async {
  try {
    final list = await database.select(database.settings).get();
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
