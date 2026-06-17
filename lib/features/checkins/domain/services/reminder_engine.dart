import 'package:drift/drift.dart';
import '../../../../database/database.dart' as db;
import '../../../../core/services/notification_service.dart';

class ReminderEngine {
  final db.AppDatabase _db;
  final NotificationService _notificationService;

  ReminderEngine(this._db, this._notificationService);

  /// Checks the scheduled slots and triggers notifications if criteria are met.
  Future<void> checkAndTrigger() async {
    try {
      final settingsList = await _db.select(_db.settings).get();
      final settingsMap = {for (var s in settingsList) s.key: s.value};

      final isEnabled = settingsMap['checkInEnabled'] != 'false';
      if (!isEnabled) return;

      final timesString = settingsMap['checkInTimes'] ?? '10:00,14:00,19:00,22:00';
      final times = timesString.split(',').map((t) => t.trim()).toList();

      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Find if we are currently in a scheduled reminder slot (within 15 min window)
      String? activeSlot;
      for (final timeStr in times) {
        final parts = timeStr.split(':');
        if (parts.length != 2) continue;
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour == null || minute == null) continue;

        final slotTime = DateTime(now.year, now.month, now.day, hour, minute);
        final diff = now.difference(slotTime).inMinutes;

        if (diff >= 0 && diff <= 15) {
          activeSlot = timeStr;
          break;
        }
      }

      if (activeSlot == null) return;

      // Prevent duplicate triggering in this slot today
      final slotKey = '${todayStr}_$activeSlot';
      final lastTriggered = settingsMap['lastTriggeredCheckIn'];
      if (lastTriggered == slotKey) return;

      // Query latest transaction (if any exists)
      final allTxs = await (_db.select(_db.transactions)
            ..where((tbl) => tbl.voidedTransactionId.isNull())
            ..orderBy([(tbl) => OrderingTerm(expression: tbl.transactionDate, mode: OrderingMode.desc)])
            ..limit(1))
          .get();

      DateTime? lastTxTime;
      if (allTxs.isNotEmpty) {
        lastTxTime = allTxs.first.transactionDate.toLocal();
      }

      // SMART REMINDERS: Skip if user added transaction in the last 3 hours
      if (lastTxTime != null) {
        final difference = now.difference(lastTxTime);
        if (difference.inHours < 3) {
          return;
        }
      }

      // Customize content based on time of day
      String title = 'Daily Financial Check-in';
      String body = 'Have you recorded today\'s financial activity yet?';
      final hour = now.hour;

      if (hour < 12) {
        body = 'Have you recorded today\'s financial activity yet?';
      } else if (hour < 17) {
        body = 'Take a moment to update your transactions.';
      } else if (hour < 21) {
        body = 'Keep your wealth records accurate. Log today\'s transactions.';
      } else {
        body = 'Before ending your day, make sure all transactions are recorded.';
      }

      _notificationService.showNotification(
        title: title,
        body: body,
        type: 'check_in',
      );

      // Save triggered state to database settings
      await _db.into(_db.settings).insertOnConflictUpdate(
            db.SettingsCompanion(
              key: const Value('lastTriggeredCheckIn'),
              value: Value(slotKey),
            ),
          );
    } catch (_) {
      // Graceful error isolation
    }
  }
}
