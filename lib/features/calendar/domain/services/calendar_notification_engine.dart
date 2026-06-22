import '../../../../core/providers/mock_database.dart';
import '../../../../core/services/notification_service.dart';
import 'calendar_engine.dart';

class CalendarNotificationEngine {
  static Future<void> scheduleCalendarReminders({
    required dynamic dbState,
    required NotificationService notificationService,
  }) async {
    final prefOnDue = dbState.notificationPrefCalendarOnDue as bool;
    final pref1Day = dbState.notificationPrefCalendar1Day as bool;
    final pref3Days = dbState.notificationPrefCalendar3Days as bool;
    final pref7Days = dbState.notificationPrefCalendar7Days as bool;

    if (!(dbState.notificationsEnabled as bool)) return;

    final now = DateTime.now();
    // Compile all events for the next 14 days
    final upcomingEvents = CalendarEngine.compileAllEvents(
      dbState: dbState as MockDatabaseState,
      startRange: now,
      endRange: now.add(const Duration(days: 14)),
    );

    for (final event in upcomingEvents) {
      if (event.deletedAt != null || event.status == 'Cancelled') continue;

      final eventDate = event.date;
      final currency = dbState.currency;
      final amountStr = '${currency}${event.amount.toStringAsFixed(0)}';

      // Schedule "On Due Date" reminder at 9:00 AM
      if (prefOnDue) {
        final triggerTime = DateTime(eventDate.year, eventDate.month, eventDate.day, 9, 0);
        if (triggerTime.isAfter(now)) {
          final id = _getNotificationId(event.id, 0);
          await notificationService.scheduleNotification(
            id: id,
            title: 'Financial Event Due Today',
            body: '${event.title} of $amountStr is due today.',
            scheduledDateTime: triggerTime,
            type: _getNotificationType(event.category),
          );
        }
      }

      // Schedule "1 Day Before" reminder at 10:00 AM
      if (pref1Day) {
        final triggerTime = DateTime(eventDate.year, eventDate.month, eventDate.day - 1, 10, 0);
        if (triggerTime.isAfter(now)) {
          final id = _getNotificationId(event.id, 1);
          await notificationService.scheduleNotification(
            id: id,
            title: 'Financial Event Due Tomorrow',
            body: '${event.title} of $amountStr is due tomorrow.',
            scheduledDateTime: triggerTime,
            type: _getNotificationType(event.category),
          );
        }
      }

      // Schedule "3 Days Before" reminder at 10:00 AM
      if (pref3Days) {
        final triggerTime = DateTime(eventDate.year, eventDate.month, eventDate.day - 3, 10, 0);
        if (triggerTime.isAfter(now)) {
          final id = _getNotificationId(event.id, 3);
          await notificationService.scheduleNotification(
            id: id,
            title: 'Financial Event Approaching (3 Days)',
            body: '${event.title} of $amountStr is due in 3 days.',
            scheduledDateTime: triggerTime,
            type: _getNotificationType(event.category),
          );
        }
      }

      // Schedule "7 Days Before" reminder at 10:00 AM
      if (pref7Days) {
        final triggerTime = DateTime(eventDate.year, eventDate.month, eventDate.day - 7, 10, 0);
        if (triggerTime.isAfter(now)) {
          final id = _getNotificationId(event.id, 7);
          await notificationService.scheduleNotification(
            id: id,
            title: 'Financial Event Approaching (7 Days)',
            body: '${event.title} of $amountStr is due in 7 days.',
            scheduledDateTime: triggerTime,
            type: _getNotificationType(event.category),
          );
        }
      }
    }
  }

  static int _getNotificationId(String eventId, int offsetDays) {
    return (eventId.hashCode + offsetDays) & 0x7FFFFFFF;
  }

  static String _getNotificationType(String category) {
    switch (category) {
      case 'Income':
        return 'expected_income';
      case 'Investment':
        return 'investment';
      case 'Liability':
        return 'liability';
      case 'Receivables':
        return 'receivable';
      case 'Goals':
        return 'goal';
      default:
        return 'general';
    }
  }
}
