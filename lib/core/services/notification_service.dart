import 'dart:async';
import 'package:uuid/uuid.dart';

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

  // Active notifications stream for reactive UI toasts/overlays
  Stream<AppNotification> get notificationStream => _controller.stream;

  // Retrieve notification history
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  // Trigger a local notification
  void showNotification({
    required String title,
    required String body,
    required String type,
  }) {
    final notification = AppNotification(
      id: _uuid.v4(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
    );

    _notifications.insert(0, notification);
    _controller.add(notification);
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
