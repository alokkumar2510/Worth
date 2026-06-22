import 'dart:async';
import 'dart:io' show Platform;
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:collection/collection.dart';
import '../../features/calendar/domain/services/calendar_notification_engine.dart';


class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type; // 'goal' | 'liability' | 'receivable' | 'expected_income' | 'general'
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

class NotificationService {
  final _uuid = const Uuid();
  final List<AppNotification> _notifications = [];
  final StreamController<AppNotification> _controller = StreamController<AppNotification>.broadcast();
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService() {
    _initLocalNotifications();
  }

  // Active notifications stream for reactive UI toasts/overlays
  Stream<AppNotification> get notificationStream => _controller.stream;

  // Retrieve notification history
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  Future<void> _initLocalNotifications() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    } catch (_) {}

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click if needed
      },
    );
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  // Trigger a local notification immediately
  Future<void> showNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    final notification = AppNotification(
      id: _uuid.v4(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
    );

    _notifications.insert(0, notification);
    _controller.add(notification);

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'worth_alerts',
        'Worth Alerts',
        channelDescription: 'Alerts and reminders for Worth',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await _localNotificationsPlugin.show(
        notification.id.hashCode,
        title,
        body,
        platformChannelSpecifics,
        payload: type,
      );
    } catch (_) {}
  }

  // Pre-schedule local notifications for the background
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    required String type,
  }) async {
    try {
      final tzScheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);
      if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        return; // past date
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'worth_reminders',
        'Worth Reminders',
        channelDescription: 'Scheduled reminders for Worth',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _localNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: type,
      );
    } catch (_) {}
  }

  // Schedule all future reminders based on current database state
  Future<void> scheduleFutureReminders(dynamic dbState) async {
    await cancelAll();

    final now = DateTime.now();
    final currency = dbState.currency ?? '₹';

    // 1. Daily Check-in (next 7 days at 8:00 PM)
    for (int i = 1; i <= 7; i++) {
      final scheduledTime = DateTime(now.year, now.month, now.day + i, 20, 0); // 8:00 PM
      await scheduleNotification(
        id: 1000 + i,
        title: 'Daily Financial Check-in',
        body: 'Keep your wealth records accurate. Take a moment to log today\'s activity in Worth.',
        scheduledDateTime: scheduledTime,
        type: 'check_in',
      );
    }

    // 2. SIP Reminders
    final List<dynamic> sips = (dbState.sips as List<dynamic>?) ?? [];
    final List<dynamic> investments = (dbState.investments as List<dynamic>?) ?? [];
    for (final sip in sips) {
      final nextDate = _getNextSipOccurrenceWithinWeek(sip, now);
      if (nextDate != null) {
        final scheduledTime = DateTime(nextDate.year, nextDate.month, nextDate.day, 9, 0); // 9:00 AM
        final inv = investments.firstWhereOrNull((i) => i.id == sip.investmentId);
        final name = inv?.name ?? 'Investment';
        await scheduleNotification(
          id: 2000 + (sip.id as Object).hashCode,
          title: 'SIP Reminder',
          body: 'Your SIP for "$name" is scheduled for today. Make sure to fund it.',
          scheduledDateTime: scheduledTime,
          type: 'investment',
        );
      }
    }

    // 3. Receivable Recovery Reminder
    final List<dynamic> people = (dbState.people as List<dynamic>?) ?? [];
    for (final person in people) {
      if (person.isArchived == 0) {
        final double outstanding = (dbState.getPersonReceivableBalance(person.id) as num).toDouble();
        if (outstanding > 0) {
          // Sunday at 11:00 AM (Weekly check-in)
          final nextSunday = _getNextDayOfWeek(now, DateTime.sunday);
          final weeklyTime = DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 11, 0);
          await scheduleNotification(
            id: 3000 + (person.id as Object).hashCode,
            title: 'Receivable Recovery Reminder',
            body: 'Friendly reminder: ${person.name} owes you $currency${outstanding.toStringAsFixed(0)}. Consider reaching out today.',
            scheduledDateTime: weeklyTime,
            type: 'receivable',
          );

          // Offset-based follow-up scheduler (7, 15, 30, 60, 90 days after borrow date)
          final borrowDate = (person.borrowDate as DateTime?) ?? (person.createdAt as DateTime);
          final offsets = [7, 15, 30, 60, 90];
          for (final offset in offsets) {
            final scheduledTime = borrowDate.add(Duration(days: offset));
            final scheduledDateTime = DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day, 10, 0); // 10:00 AM
            
            if (scheduledDateTime.isAfter(now)) {
              final notifId = 31000 + (person.id as Object).hashCode + offset;
              String stageLabel = '';
              if (offset == 7) stageLabel = 'Gentle Reminder';
              if (offset == 15) stageLabel = 'Follow-up Reminder';
              if (offset == 30) stageLabel = 'Urgent Reminder';
              if (offset == 60) stageLabel = 'High Priority';
              if (offset == 90) stageLabel = 'Escalated';

              await scheduleNotification(
                id: notifId,
                title: 'Receivable: $stageLabel',
                body: '${person.name} owes you $currency${outstanding.toStringAsFixed(0)} (pending for $offset days). Send a reminder now.',
                scheduledDateTime: scheduledDateTime,
                type: 'receivable',
              );
            }
          }
        }
      }
    }

    // 4. Goal Reminders
    final List<dynamic> goals = (dbState.goals as List<dynamic>?) ?? [];
    for (final goal in goals) {
      final double currentAmount = (goal.currentAmount as num).toDouble();
      final double targetAmount = (goal.targetAmount as num).toDouble();
      final DateTime? deadline = goal.deadline as DateTime?;
      if (currentAmount < targetAmount && deadline != null) {
        final reminderTime = deadline.subtract(const Duration(days: 1));
        final scheduledTime = DateTime(reminderTime.year, reminderTime.month, reminderTime.day, 10, 0); // 10:00 AM
        if (scheduledTime.isAfter(now)) {
          await scheduleNotification(
            id: 6000 + (goal.id as Object).hashCode,
            title: 'Goal Deadline Approaching',
            body: 'Your goal "${goal.name}" is due tomorrow! You need $currency${(targetAmount - currentAmount).toStringAsFixed(0)} more.',
            scheduledDateTime: scheduledTime,
            type: 'goal',
          );
        }
      }
    }

    // 5. MTF Interest Reminder (every Friday at 6:00 PM)
    final List<dynamic> activeMtf = ((dbState.mtfPositions as List<dynamic>?) ?? []).where((p) => p.isClosed == 0).toList();
    if (activeMtf.isNotEmpty) {
      final nextFriday = _getNextDayOfWeek(now, DateTime.friday);
      final scheduledTime = DateTime(nextFriday.year, nextFriday.month, nextFriday.day, 18, 0);
      await scheduleNotification(
        id: 5000,
        title: 'MTF Interest Review',
        body: 'Check accrued interest on your active Margin Trading Facility (MTF) positions.',
        scheduledDateTime: scheduledTime,
        type: 'investment',
      );
    }

    // 6. IPO Settlement Reminders (every Tuesday at 12:00 PM)
    final List<dynamic> activeIpo = ((dbState.ipoPools as List<dynamic>?) ?? []).where((p) => p.status != 'Archived' && p.settlementStatus != 'Settled').toList();
    if (activeIpo.isNotEmpty) {
      final nextTuesday = _getNextDayOfWeek(now, DateTime.tuesday);
      final scheduledTime = DateTime(nextTuesday.year, nextTuesday.month, nextTuesday.day, 12, 0);
      await scheduleNotification(
        id: 4000,
        title: 'IPO Settlement Reminder',
        body: 'You have active IPO pools with pending contributor settlements. Review them in the Settlement Center.',
        scheduledDateTime: scheduledTime,
        type: 'expected_income',
      );
    }

    // 7. Configurable Calendar Reminders (1 Day, 3 Days, 7 Days, On Due Date)
    await CalendarNotificationEngine.scheduleCalendarReminders(
      dbState: dbState,
      notificationService: this,
    );
  }

  DateTime _getNextDayOfWeek(DateTime from, int dayOfWeek) {
    int daysToAdd = dayOfWeek - from.weekday;
    if (daysToAdd <= 0) {
      daysToAdd += 7;
    }
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

  // Cancel scheduled notification
  Future<void> cancelNotification(int id) async {
    await _localNotificationsPlugin.cancel(id);
  }

  // Cancel all scheduled notifications
  Future<void> cancelAll() async {
    await _localNotificationsPlugin.cancelAll();
  }

  // Mark notification as read
  void markAsRead(String id) {
    try {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index].isRead = true;
      }
    } catch (_) {}
  }

  // Mark all notifications as read
  void markAllAsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
  }

  // Clear notification history
  void clearAll() {
    _notifications.clear();
  }

  void dispose() {
    _controller.close();
  }
}
