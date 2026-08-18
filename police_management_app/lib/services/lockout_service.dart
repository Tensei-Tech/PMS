// lib/services/lockout_service.dart
// Brute-force protection: tracks failed PIN attempts and enforces time-based lockouts.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum LockoutState { allowed, locked }

class LockoutStatus {
  final LockoutState state;

  /// Remaining lockout duration. Null when [state] == [LockoutState.allowed].
  final Duration? remainingDuration;

  /// Total lifetime failed attempts (used for escalating lockout tiers).
  final int totalFailures;

  const LockoutStatus._({
    required this.state,
    this.remainingDuration,
    required this.totalFailures,
  });

  factory LockoutStatus.allowed(int totalFailures) =>
      LockoutStatus._(state: LockoutState.allowed, totalFailures: totalFailures);

  factory LockoutStatus.locked(Duration remaining, int totalFailures) =>
      LockoutStatus._(
        state: LockoutState.locked,
        remainingDuration: remaining,
        totalFailures: totalFailures,
      );

  bool get isLocked => state == LockoutState.locked;

  /// Human-readable remaining time (e.g., "14m 32s").
  String get remainingLabel {
    final r = remainingDuration;
    if (r == null || r.inSeconds <= 0) return '';
    final m = r.inMinutes;
    final s = r.inSeconds % 60;
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}

class LockoutService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions.defaultOptions,
  );

  // Storage keys
  static const _keyFailedAttempts = 'lockout_failed_attempts';
  static const _keyLockoutUntil = 'lockout_until_epoch_ms';
  static const _keyTotalFailures = 'lockout_total_failures';

  // Lockout tiers (number of consecutive failures → lockout duration in minutes)
  static const _tiers = <int, int>{
    5: 15,   // 5 failures  → 15 minutes
    8: 30,   // 8 failures  → 30 minutes
    10: 60,  // 10 failures → 60 minutes
  };

  // After this many total lifetime failures, require full Firebase re-auth
  static const int fullReauthThreshold = 20;

  /// Check current lockout status. Call before allowing any PIN attempt.
  Future<LockoutStatus> checkStatus() async {
    final totalStr = await _storage.read(key: _keyTotalFailures) ?? '0';
    final total = int.tryParse(totalStr) ?? 0;

    final lockoutUntilStr = await _storage.read(key: _keyLockoutUntil);
    if (lockoutUntilStr != null) {
      final lockoutUntilMs = int.tryParse(lockoutUntilStr) ?? 0;
      final lockoutUntil = DateTime.fromMillisecondsSinceEpoch(lockoutUntilMs);
      final now = DateTime.now();
      if (now.isBefore(lockoutUntil)) {
        return LockoutStatus.locked(lockoutUntil.difference(now), total);
      }
      // Lockout expired — clear it but keep total failures
      await _storage.delete(key: _keyLockoutUntil);
      await _storage.delete(key: _keyFailedAttempts);
    }

    return LockoutStatus.allowed(total);
  }

  /// Record a failed attempt. Returns updated [LockoutStatus].
  Future<LockoutStatus> recordFailedAttempt() async {
    // Increment consecutive failures
    final failedStr = await _storage.read(key: _keyFailedAttempts) ?? '0';
    final failed = (int.tryParse(failedStr) ?? 0) + 1;
    await _storage.write(key: _keyFailedAttempts, value: failed.toString());

    // Increment total lifetime failures
    final totalStr = await _storage.read(key: _keyTotalFailures) ?? '0';
    final total = (int.tryParse(totalStr) ?? 0) + 1;
    await _storage.write(key: _keyTotalFailures, value: total.toString());

    // Check if we hit a lockout tier
    int? lockoutMinutes;
    for (final tier in _tiers.entries) {
      if (failed >= tier.key) {
        lockoutMinutes = tier.value;
      }
    }

    if (lockoutMinutes != null) {
      final lockoutUntil = DateTime.now().add(Duration(minutes: lockoutMinutes));
      await _storage.write(
        key: _keyLockoutUntil,
        value: lockoutUntil.millisecondsSinceEpoch.toString(),
      );
      return LockoutStatus.locked(Duration(minutes: lockoutMinutes), total);
    }

    return LockoutStatus.allowed(total);
  }

  /// Call on successful authentication — resets consecutive attempt counter.
  /// Does NOT reset total lifetime failures (used for escalating tiers).
  Future<void> recordSuccess() async {
    await _storage.delete(key: _keyFailedAttempts);
    await _storage.delete(key: _keyLockoutUntil);
  }

  /// Full reset — only call on full logout / account reset.
  Future<void> resetAll() async {
    await _storage.delete(key: _keyFailedAttempts);
    await _storage.delete(key: _keyLockoutUntil);
    await _storage.delete(key: _keyTotalFailures);
  }

  /// Whether the account requires full Firebase re-authentication
  /// due to excessive total failures.
  Future<bool> requiresFullReauth() async {
    final totalStr = await _storage.read(key: _keyTotalFailures) ?? '0';
    final total = int.tryParse(totalStr) ?? 0;
    return total >= fullReauthThreshold;
  }
}
