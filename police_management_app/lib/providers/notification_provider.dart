// lib/providers/notification_provider.dart
// State management for FCM push notifications — badge count + notification list.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/fcm_service.dart';

/// Single notification item stored in memory.
class NotificationItem {
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });
}

/// Provider that owns the notification list and badge count.
/// Listens to [FcmService.onForegroundMessage] to auto-add incoming messages.
class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  StreamSubscription<RemoteMessage>? _fcmSub;

  /// All stored notifications, newest first.
  List<NotificationItem> get notifications =>
      List.unmodifiable(_notifications.reversed);

  /// Number of unread notifications (displayed as the badge count).
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Start listening to the FCM foreground stream.
  /// Call this once from main.dart after FcmService.initialize().
  void startListening() {
    _fcmSub?.cancel();
    _fcmSub = FcmService().onForegroundMessage.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? 'Notification';
    final body = notification?.body ?? message.data['body'] ?? '';

    addNotification(title: title, body: body);
  }

  /// Manually add a notification (also used by background handler if needed).
  void addNotification({required String title, required String body}) {
    _notifications.add(NotificationItem(
      title: title,
      body: body,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Mark all notifications as read — resets the badge count to 0.
  void clearBadge() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  /// Remove all stored notifications.
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _fcmSub?.cancel();
    super.dispose();
  }
}
