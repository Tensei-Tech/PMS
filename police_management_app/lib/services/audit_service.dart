// lib/services/audit_service.dart
// Append-only audit log for all security-critical events.
// Writes to Firestore `audit_logs` — no client can read/update/delete entries.

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// All auditable event types in the system.
enum AuditEvent {
  loginSuccess,
  loginFailed,
  biometricLoginSuccess,
  biometricLoginFailed,
  pinChanged,
  pinChangeFailed,
  pinVerifySuccess,
  pinVerifyFailed,
  sessionLocked,
  sessionUnlocked,
  logout,
  fullLogout,
  lockoutTriggered,
  registrationSuccess,
  registrationFailed,
  caseCreated,
  caseUpdated,
  caseDeleted,
  adminAction,
}

extension AuditEventName on AuditEvent {
  String get name {
    switch (this) {
      case AuditEvent.loginSuccess: return 'login_success';
      case AuditEvent.loginFailed: return 'login_failed';
      case AuditEvent.biometricLoginSuccess: return 'biometric_login_success';
      case AuditEvent.biometricLoginFailed: return 'biometric_login_failed';
      case AuditEvent.pinChanged: return 'pin_changed';
      case AuditEvent.pinChangeFailed: return 'pin_change_failed';
      case AuditEvent.pinVerifySuccess: return 'pin_verify_success';
      case AuditEvent.pinVerifyFailed: return 'pin_verify_failed';
      case AuditEvent.sessionLocked: return 'session_locked';
      case AuditEvent.sessionUnlocked: return 'session_unlocked';
      case AuditEvent.logout: return 'logout';
      case AuditEvent.fullLogout: return 'full_logout';
      case AuditEvent.lockoutTriggered: return 'lockout_triggered';
      case AuditEvent.registrationSuccess: return 'registration_success';
      case AuditEvent.registrationFailed: return 'registration_failed';
      case AuditEvent.caseCreated: return 'case_created';
      case AuditEvent.caseUpdated: return 'case_updated';
      case AuditEvent.caseDeleted: return 'case_deleted';
      case AuditEvent.adminAction: return 'admin_action';
    }
  }
}

class AuditService {
  static final AuditService _instance = AuditService._internal();
  factory AuditService() => _instance;
  AuditService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  static const String _colAuditLogs = 'audit_logs';

  /// Log a security event. Fails silently in production to avoid crashing the app.
  Future<void> log(
    AuditEvent event, {
    String? uid,
    Map<String, dynamic>? metadata,
  }) async {
    // No audit logging in debug mode (avoids polluting the dev database)
    if (kDebugMode) return;

    try {
      final entry = <String, dynamic>{
        'event': event.name,
        'uid': uid ?? 'anonymous',
        'timestamp': FieldValue.serverTimestamp(),
        'platform': _getPlatform(),
        if (metadata != null) ...metadata,
      };
      await _db.collection(_colAuditLogs).add(entry);
    } catch (_) {
      // Intentionally silent — audit log failure must never block the main flow
    }
  }

  String _getPlatform() {
    if (kIsWeb) return 'web';
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
    } catch (_) {}
    return 'unknown';
  }
}
