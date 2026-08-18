// lib/utils/notification_service.dart
// Wrapper around flutter_local_notifications for calendar notifications.

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool get _isSupported => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  /// Call once at app startup
  Future<void> initialize() async {
    if (_initialized || !_isSupported) return;

    // Major section: timezone init (required for zoned schedules)
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // flutter_local_notifications newer APIs prefer named-only parameters.
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request Android 13+ permission
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
        
    await androidPlugin?.requestNotificationsPermission();

    // Create high importance notification channels for Android 8.0+
    if (androidPlugin != null) {
      const generalChannel = AndroidNotificationChannel(
        'police_general',
        'General Alerts',
        description: 'General alerts and updates',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      
      const dutyChannel = AndroidNotificationChannel(
        'police_notifications',
        'Duty Notifications',
        description: 'Notifications for upcoming duties and tasks',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await androidPlugin.createNotificationChannel(generalChannel);
      await androidPlugin.createNotificationChannel(dutyChannel);
      debugPrint('[NotificationService] Created Android notification channels');
    }

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Future: deep-link to the notification's calendar date
  }

  /// Schedule a notification at [scheduledTime]
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (!_isSupported) return;
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _toTZDateTime(scheduledTime),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'police_notifications',
          'Duty Notifications',
          channelDescription: 'Notifications for upcoming duties and tasks',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Show an immediate notification
  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isSupported) return;
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'police_general',
          'General Alerts',
          channelDescription: 'General alerts and updates',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Cancel a scheduled notification by id
  Future<void> cancelNotification(int id) async {
    if (!_isSupported) return;
    await _plugin.cancel(id: id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_isSupported) return;
    await _plugin.cancelAll();
  }

  // Helper: convert DateTime to TZDateTime using local time zone
  tz.TZDateTime _toTZDateTime(DateTime dt) {
    return tz.TZDateTime.from(dt, tz.local);
  }
}
