// lib/utils/pin_crypto.dart
// PBKDF2-HMAC-SHA256 PIN hashing utility.
// Never store or transmit raw PINs — always hash with a per-user salt.

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class PinCrypto {
  // PBKDF2 iteration count — optimized for UI responsiveness on Web (runs in milliseconds)
  static const int _iterations = 1000;
  static const int _saltLengthBytes = 32;
  static const int _keyLengthBytes = 32;

  /// Generates a cryptographically secure random salt (hex-encoded, 64 chars).
  static String generateSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(_saltLengthBytes, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Hashes a PIN using PBKDF2-HMAC-SHA256 with the given salt.
  /// Returns a hex-encoded hash string (64 chars).
  static String hashPin(String pin, String salt) {
    assert(pin.isNotEmpty, 'PIN must not be empty');
    assert(salt.isNotEmpty, 'Salt must not be empty');

    final saltBytes = _hexToBytes(salt);
    final pinBytes = utf8.encode(pin);

    // PBKDF2 manual implementation using HMAC-SHA256
    final derivedKey = _pbkdf2HmacSha256(pinBytes, saltBytes, _iterations, _keyLengthBytes);
    return _bytesToHex(derivedKey);
  }

  /// Verifies a PIN against a stored hash + salt.
  /// Returns true if the PIN matches.
  static bool verifyPin(String inputPin, String storedHash, String storedSalt, [int iterations = _iterations]) {
    if (inputPin.isEmpty || storedHash.isEmpty || storedSalt.isEmpty) return false;
    final saltBytes = _hexToBytes(storedSalt);
    final pinBytes = utf8.encode(inputPin);
    final derivedKey = _pbkdf2HmacSha256(pinBytes, saltBytes, iterations, _keyLengthBytes);
    final computedHash = _bytesToHex(derivedKey);
    // Constant-time comparison to prevent timing attacks
    return _constantTimeEquals(computedHash, storedHash);
  }

  // ── Private PBKDF2 implementation ─────────────────────────────────────────

  static List<int> _pbkdf2HmacSha256(
    List<int> password,
    List<int> salt,
    int iterations,
    int keyLength,
  ) {
    final hmac = Hmac(sha256, password);
    final blocks = (keyLength / 32).ceil();
    final result = <int>[];

    for (var block = 1; block <= blocks; block++) {
      // U1 = PRF(Password, Salt || INT(block))
      final saltWithBlock = [
        ...salt,
        (block >> 24) & 0xFF,
        (block >> 16) & 0xFF,
        (block >> 8) & 0xFF,
        block & 0xFF,
      ];
      var u = hmac.convert(saltWithBlock).bytes;
      var xorResult = List<int>.from(u);

      // U2 ... Ui = PRF(Password, U(i-1)); XOR all together
      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < xorResult.length; j++) {
          xorResult[j] ^= u[j];
        }
      }
      result.addAll(xorResult);
    }

    return result.sublist(0, keyLength);
  }

  static List<int> _hexToBytes(String hex) {
    final result = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return result;
  }

  static String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Constant-time string comparison to prevent timing attacks.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Run hashing on an isolate (off the main thread) — avoids UI jank.
  /// Use this version in `auth_provider.dart`.
  static Future<String> hashPinAsync(String pin, String salt) async {
    return compute(_isolateHash, {'pin': pin, 'salt': salt});
  }

  static Future<bool> verifyPinAsync(
    String inputPin,
    String storedHash,
    String storedSalt, [
    int iterations = _iterations,
  ]) async {
    return compute(
      _isolateVerify,
      {
        'pin': inputPin,
        'hash': storedHash,
        'salt': storedSalt,
        'iterations': iterations.toString(),
      },
    );
  }
}

// Top-level functions required by `compute` (must not be closures).
String _isolateHash(Map<String, String> args) {
  return PinCrypto.hashPin(args['pin']!, args['salt']!);
}

bool _isolateVerify(Map<String, String> args) {
  final iterations = args.containsKey('iterations')
      ? int.parse(args['iterations']!)
      : PinCrypto._iterations;
  return PinCrypto.verifyPin(args['pin']!, args['hash']!, args['salt']!, iterations);
}
