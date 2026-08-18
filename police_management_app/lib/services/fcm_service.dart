// lib/services/fcm_service.dart
// Firebase Cloud Messaging wrapper — permissions, token, foreground stream.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/notification_service.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  FirebaseMessaging? get _messaging {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        return FirebaseMessaging.instance;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  bool _initialized = false;
  String? _token;

  /// The current FCM device token (null until initialize() completes).
  String? get token => _token;

  /// Stream controller that re-broadcasts foreground messages so the UI layer
  /// (NotificationProvider) can subscribe without importing firebase_messaging.
  final StreamController<RemoteMessage> _foregroundController =
      StreamController<RemoteMessage>.broadcast();

  /// Foreground message stream for the provider to listen to.
  Stream<RemoteMessage> get onForegroundMessage => _foregroundController.stream;

  /// Completer to allow awaiting initialization from outside.
  final Completer<void> _initCompleter = Completer<void>();

  /// Future that completes when FCM is fully initialized.
  Future<void> get initialized => _initCompleter.future;

  /// Call once after Firebase.initializeApp completes.
  Future<void> initialize() async {
    if (_initialized) return;

    final msg = _messaging;
    if (msg == null) {
      _initialized = true;
      if (!_initCompleter.isCompleted) _initCompleter.complete();
      debugPrint('[FCM] Skipping initialization on unsupported platform');
      return;
    }

    try {
      // ── 1. Request permissions (Android 13+ / iOS / Web) ──────────────────
      final settings = await msg.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
      debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[FCM] ⚠️ Notification permission denied by user');
      }

      // ── 2. Get device token ───────────────────────────────────────────────
      await _fetchAndStoreToken();

      // ── 3. Listen for token refreshes ─────────────────────────────────────
      msg.onTokenRefresh.listen((newToken) {
        debugPrint('[FCM] Token refreshed: $newToken');
        _token = newToken;
        _saveTokenToFirestore(newToken);
      });

      // ── 4. Foreground messages ────────────────────────────────────────────
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM] Foreground message: ${message.notification?.title}');
        final notification = message.notification;
        if (notification != null) {
          NotificationService().showImmediate(
            id: message.hashCode,
            title: notification.title ?? 'New Notification',
            body: notification.body ?? '',
          );
        }
        _foregroundController.add(message);
      });

      // ── 5. Notification tap while app was in background ───────────────────
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint(
            '[FCM] Opened from background: ${message.notification?.title}');
        _foregroundController.add(message);
      });

      // ── 6. Check if app was opened from a terminated-state notification ───
      final initialMessage = await msg.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
            '[FCM] Opened from terminated: ${initialMessage.notification?.title}');
        _foregroundController.add(initialMessage);
      }

      _initialized = true;
      if (!_initCompleter.isCompleted) _initCompleter.complete();
      debugPrint('[FCM] ✅ Service initialized successfully');
    } catch (e, stack) {
      debugPrint('[FCM] ❌ Initialization failed: $e');
      debugPrint('[FCM] Stack: $stack');
      if (!_initCompleter.isCompleted) _initCompleter.complete();
    }
  }

  /// Fetch FCM token and save to Firestore for the current user.
  Future<void> _fetchAndStoreToken() async {
    final msg = _messaging;
    if (msg == null) return;
    try {
      final token = await msg.getToken(
        vapidKey: kIsWeb ? 'YOUR_VAPID_KEY_HERE_REPLACE_ME' : null,
      );
      _token = token;

      debugPrint(
          '╔══════════════════════════════════════════════════════════╗');
      debugPrint(
          '║  FCM DEVICE TOKEN (copy for Firebase Console testing):  ║');
      debugPrint(
          '╠══════════════════════════════════════════════════════════╣');
      debugPrint('║  $token');
      debugPrint(
          '╚══════════════════════════════════════════════════════════╝');

      if (token != null) {
        await _saveTokenToFirestore(token);
      } else {
        debugPrint('[FCM] ⚠️ Token is null — push notifications will not work');
      }
    } catch (e) {
      debugPrint('[FCM] ❌ Token retrieval failed: $e');
    }
  }

  /// Save the FCM token to the current user's Firestore document.
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[FCM] No logged-in user — skipping token save');
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase(),
      }, SetOptions(merge: true));

      debugPrint('[FCM] ✅ Token saved to Firestore for user: ${user.uid}');
    } catch (e) {
      debugPrint('[FCM] ⚠️ Failed to save token to Firestore: $e');
    }
  }

  /// Manually refresh and re-save the token (call after login).
  Future<String?> refreshToken() async {
    await _fetchAndStoreToken();
    return _token;
  }

  /// Delete the token (call on logout to stop receiving notifications).
  Future<void> deleteToken() async {
    final msg = _messaging;
    if (msg == null) return;
    try {
      await msg.deleteToken();
      _token = null;
      debugPrint('[FCM] Token deleted');
    } catch (e) {
      debugPrint('[FCM] Token deletion failed: $e');
    }
  }

  /// Dispose the stream controller (call from app dispose if needed).
  void dispose() {
    _foregroundController.close();
  }
}
