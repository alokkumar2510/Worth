import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart' show GlobalKey, NavigatorState;
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:collection/collection.dart';
import '../../features/calendar/domain/services/calendar_notification_engine.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notification Channel IDs
// ─────────────────────────────────────────────────────────────────────────────
const kChannelInsights   = 'worth_insights';
const kChannelReminders  = 'worth_reminders';
const kChannelSystem     = 'worth_system';

// ─────────────────────────────────────────────────────────────────────────────
// Notification ID ranges
//   9000–9099  → financial insights (daily random)
//   1000–1099  → check-in reminders
//   2000–2999  → SIP reminders
//   3000–3999  → receivable reminders
//   4000–4099  → IPO reminders
//   5000–5099  → MTF reminders
//   6000–6999  → goal deadline reminders
//   7000–7099  → backup/system alerts
//   8000–8099  → sync alerts
//  31000–31999 → receivable follow-up offsets
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// AppNotification model — kept for optional read-only notification history
// ─────────────────────────────────────────────────────────────────────────────
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'type': type,
    'isRead': isRead,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// NotificationService
//
// Design goals:
//   1. ALL notifications are posted to the Android status bar (system tray).
//   2. NOTHING shows as an in-app popup/snackbar/dialog.
//   3. Tapping a notification deep-links to the correct screen.
//   4. Works when the app is closed, minimized, screen locked, or restarted.
// ─────────────────────────────────────────────────────────────────────────────
class NotificationService {
  final _uuid = const Uuid();
  final List<AppNotification> _notifications = [];

  // Navigator key for deep-link routing on notification tap
  static GlobalKey<NavigatorState>? navigatorKey;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    _init();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Read-only notification history (no UI popups).
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  /// Silent stream kept for compatibility — no longer drives any UI popup.
  final StreamController<AppNotification> _historyController =
      StreamController<AppNotification>.broadcast();
  Stream<AppNotification> get notificationStream => _historyController.stream;

  /// Request Android notification permission (Android 13+).
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  // ── Core: Show a system notification immediately ───────────────────────────
  /// Posts a notification to the Android status bar right now.
  /// Does NOT show any in-app widget. Works when app is in background.
  Future<void> showNotification({
    required String title,
    required String body,
    required String type,
    int? id,
    String channelId = kChannelReminders,
  }) async {
    final notifId = id ?? title.hashCode.abs() % 8999;
    _addToHistory(title: title, body: body, type: type);
    await _postToStatusBar(
      id: notifId,
      title: title,
      body: body,
      channelId: channelId,
      payload: type,
    );
  }

  /// Alias for showNotification — explicit naming for background callers.
  Future<void> showSystemNotification({
    required int id,
    required String title,
    required String body,
    required String type,
    String channelId = kChannelReminders,
  }) => showNotification(
    title: title,
    body: body,
    type: type,
    id: id,
    channelId: channelId,
  );

  // ── Core: Schedule a future system notification ────────────────────────────
  /// Schedules a notification to appear at [scheduledDateTime].
  /// Works even when the app is not running.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    required String type,
    String channelId = kChannelReminders,
  }) async {
    try {
      final tzDate = tz.TZDateTime.from(scheduledDateTime, tz.local);
      if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) return;

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        _buildDetails(channelId),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: type,
      );
    } catch (_) {}
  }

  /// Alias with clearer naming for non-immediate scheduled notifications.
  Future<void> scheduleSystemNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    required String type,
    String channelId = kChannelReminders,
  }) => scheduleNotification(
    id: id,
    title: title,
    body: body,
    scheduledDateTime: scheduledDateTime,
    type: type,
    channelId: channelId,
  );

  // ── Batch future reminders based on db state ───────────────────────────────
  Future<void> scheduleFutureReminders(dynamic dbState) async {
    await cancelAll();

    final now = DateTime.now();
    final currency = dbState.currency ?? '₹';

    // 1. Daily Check-in (next 7 days at 8:00 PM)
    for (int i = 1; i <= 7; i++) {
      final scheduledTime =
          DateTime(now.year, now.month, now.day + i, 20, 0);
      await scheduleNotification(
        id: 1000 + i,
        title: 'Daily Financial Check-in',
        body: 'Keep your wealth records accurate. Log today\'s activity in Worth.',
        scheduledDateTime: scheduledTime,
        type: 'check_in',
        channelId: kChannelReminders,
      );
    }

    // 2. SIP Reminders
    final List<dynamic> sips = (dbState.sips as List<dynamic>?) ?? [];
    final List<dynamic> investments =
        (dbState.investments as List<dynamic>?) ?? [];
    for (final sip in sips) {
      final nextDate = _getNextSipOccurrenceWithinWeek(sip, now);
      if (nextDate != null) {
        final scheduledTime = DateTime(
            nextDate.year, nextDate.month, nextDate.day, 9, 0);
        final inv =
            investments.firstWhereOrNull((i) => i.id == sip.investmentId);
        final name = inv?.name ?? 'Investment';
        await scheduleNotification(
          id: 2000 + (sip.id as Object).hashCode,
          title: 'SIP Reminder',
          body: 'Your SIP for "$name" is scheduled for today.',
          scheduledDateTime: scheduledTime,
          type: 'sip',
          channelId: kChannelReminders,
        );
      }
    }

    // 3. Receivable follow-ups
    final List<dynamic> people = (dbState.people as List<dynamic>?) ?? [];
    for (final person in people) {
      if (person.isArchived == 0) {
        final double outstanding =
            (dbState.getPersonReceivableBalance(person.id) as num).toDouble();
        if (outstanding > 0) {
          final nextSunday = _getNextDayOfWeek(now, DateTime.sunday);
          final weeklyTime = DateTime(
              nextSunday.year, nextSunday.month, nextSunday.day, 11, 0);
          await scheduleNotification(
            id: 3000 + (person.id as Object).hashCode,
            title: 'Receivable Recovery Reminder',
            body: '${person.name} owes you $currency${outstanding.toStringAsFixed(0)}.',
            scheduledDateTime: weeklyTime,
            type: 'receivable',
            channelId: kChannelReminders,
          );

          // Offset-based follow-ups
          final borrowDate =
              (person.borrowDate as DateTime?) ?? (person.createdAt as DateTime);
          for (final offset in [7, 15, 30, 60, 90]) {
            final scheduledDateTime = borrowDate
                .add(Duration(days: offset))
                .copyWith(hour: 10, minute: 0, second: 0);
            if (scheduledDateTime.isAfter(now)) {
              final labels = {
                7: 'Gentle Reminder',
                15: 'Follow-up Reminder',
                30: 'Urgent Reminder',
                60: 'High Priority',
                90: 'Escalated',
              };
              await scheduleNotification(
                id: 31000 + (person.id as Object).hashCode + offset,
                title: 'Receivable: ${labels[offset]}',
                body: '${person.name} owes you $currency${outstanding.toStringAsFixed(0)} (pending $offset days).',
                scheduledDateTime: scheduledDateTime,
                type: 'receivable',
                channelId: kChannelReminders,
              );
            }
          }
        }
      }
    }

    // 4. Goal deadline reminders
    final List<dynamic> goals = (dbState.goals as List<dynamic>?) ?? [];
    for (final goal in goals) {
      final double currentAmount = (goal.currentAmount as num).toDouble();
      final double targetAmount = (goal.targetAmount as num).toDouble();
      final DateTime? deadline = goal.deadline as DateTime?;
      if (currentAmount < targetAmount && deadline != null) {
        final scheduled = deadline
            .subtract(const Duration(days: 1))
            .copyWith(hour: 10, minute: 0, second: 0);
        if (scheduled.isAfter(now)) {
          await scheduleNotification(
            id: 6000 + (goal.id as Object).hashCode,
            title: 'Goal Deadline Approaching',
            body: 'Your goal "${goal.name}" is due tomorrow! $currency${(targetAmount - currentAmount).toStringAsFixed(0)} needed.',
            scheduledDateTime: scheduled,
            type: 'goal',
            channelId: kChannelReminders,
          );
        }
      }
    }

    // 5. MTF Interest (next Friday 6:00 PM)
    final List<dynamic> activeMtf =
        ((dbState.mtfPositions as List<dynamic>?) ?? [])
            .where((p) => p.isClosed == 0)
            .toList();
    if (activeMtf.isNotEmpty) {
      final nextFriday = _getNextDayOfWeek(now, DateTime.friday);
      await scheduleNotification(
        id: 5000,
        title: 'MTF Interest Review',
        body: 'Check accrued interest on your active Margin Trading Facility positions.',
        scheduledDateTime:
            DateTime(nextFriday.year, nextFriday.month, nextFriday.day, 18, 0),
        type: 'investment',
        channelId: kChannelReminders,
      );
    }

    // 6. IPO Settlement (next Tuesday 12:00 PM)
    final List<dynamic> activeIpo =
        ((dbState.ipoPools as List<dynamic>?) ?? [])
            .where((p) =>
                p.status != 'Archived' && p.settlementStatus != 'Settled')
            .toList();
    if (activeIpo.isNotEmpty) {
      final nextTuesday = _getNextDayOfWeek(now, DateTime.tuesday);
      await scheduleNotification(
        id: 4000,
        title: 'IPO Settlement Reminder',
        body: 'Active IPO pools with pending contributor settlements. Review in the Settlement Center.',
        scheduledDateTime: DateTime(
            nextTuesday.year, nextTuesday.month, nextTuesday.day, 12, 0),
        type: 'expected_income',
        channelId: kChannelReminders,
      );
    }

    // 7. Configurable Calendar Reminders
    await CalendarNotificationEngine.scheduleCalendarReminders(
      dbState: dbState,
      notificationService: this,
    );
  }

  // ── History helpers ────────────────────────────────────────────────────────
  void markAsRead(String id) {
    try {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) _notifications[index].isRead = true;
    } catch (_) {}
  }

  void markAllAsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
  }

  void clearAll() => _notifications.clear();

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  void dispose() {
    _historyController.close();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _init() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    } catch (_) {}

    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    await _plugin.initialize(
      const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: _onTap,
    );

    // Create all notification channels on Android
    await _createChannels();
  }

  Future<void> _createChannels() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return;

    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        kChannelInsights,
        'Financial Insights',
        description: 'Random daily financial insights about your portfolio.',
        importance: Importance.defaultImportance,
        enableVibration: false,
        playSound: false,
      ),
    );

    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        kChannelReminders,
        'Smart Reminders',
        description: 'SIP, credit card, receivable, and goal reminders.',
        importance: Importance.high,
      ),
    );

    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        kChannelSystem,
        'System Alerts',
        description: 'Backup completions, sync status, and app updates.',
        importance: Importance.low,
        enableVibration: false,
        playSound: false,
      ),
    );
  }

  NotificationDetails _buildDetails(String channelId) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        _channelName(channelId),
        importance: channelId == kChannelReminders
            ? Importance.high
            : channelId == kChannelSystem
                ? Importance.low
                : Importance.defaultImportance,
        priority: channelId == kChannelReminders
            ? Priority.high
            : Priority.defaultPriority,
        icon: '@mipmap/launcher_icon',
        styleInformation: const BigTextStyleInformation(''),
      ),
    );
  }

  String _channelName(String id) {
    switch (id) {
      case kChannelInsights:
        return 'Financial Insights';
      case kChannelSystem:
        return 'System Alerts';
      default:
        return 'Smart Reminders';
    }
  }

  Future<void> _postToStatusBar({
    required int id,
    required String title,
    required String body,
    required String channelId,
    String? payload,
  }) async {
    try {
      await _plugin.show(
        id,
        title,
        body,
        _buildDetails(channelId),
        payload: payload,
      );
    } catch (_) {}
  }

  void _addToHistory({
    required String title,
    required String body,
    required String type,
  }) {
    final n = AppNotification(
      id: _uuid.v4(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
    );
    _notifications.insert(0, n);
    // Emit to stream for optional history screen — NOT for in-app popups
    _historyController.add(n);
  }

  void _onTap(NotificationResponse response) {
    final payload = response.payload ?? '';
    final nav = navigatorKey?.currentState;
    if (nav == null) return;

    // Deep-link routing by notification type/payload
    switch (payload) {
      case 'sip':
        nav.pushNamed('/sip');
        break;
      case 'receivable':
        nav.pushNamed('/portfolio');
        break;
      case 'liability':
        nav.pushNamed('/portfolio');
        break;
      case 'goal':
        nav.pushNamed('/portfolio');
        break;
      case 'backup':
        nav.pushNamed('/settings/backup_restore');
        break;
      case 'sync':
        nav.pushNamed('/settings/sync_center');
        break;
      case 'insight':
      case 'dashboard':
        nav.pushNamed('/dashboard');
        break;
      case 'check_in':
        nav.pushNamed('/dashboard');
        break;
      default:
        nav.pushNamed('/dashboard');
        break;
    }
  }

  DateTime _getNextDayOfWeek(DateTime from, int dayOfWeek) {
    int daysToAdd = dayOfWeek - from.weekday;
    if (daysToAdd <= 0) daysToAdd += 7;
    return from.add(Duration(days: daysToAdd));
  }

  DateTime? _getNextSipOccurrenceWithinWeek(dynamic sip, DateTime from) {
    for (int i = 0; i < 7; i++) {
      final day = from.add(Duration(days: i));
      if (sip.frequency == 'weekly') {
        if (day.weekday == sip.sipDate) return day;
      } else if (sip.frequency == 'monthly') {
        if (day.day == sip.sipDate) return day;
      }
    }
    return null;
  }
}
