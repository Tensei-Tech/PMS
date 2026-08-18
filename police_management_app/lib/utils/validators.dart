// lib/utils/validators.dart
// Centralized form validators with user-friendly error messages.

class AppValidators {
  /// Full name: required, at least 2 words
  static String? fullName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().split(' ').length < 2) return 'Please enter your full name';
    return null;
  }

  /// Required field validator — general purpose
  static String? required(String? v, [String fieldName = 'This field']) {
    if (v == null || v.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  /// Email validator — standard public or government domains.
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email address is required';
    final value = v.trim();
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!regex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  /// Registration / login email — allows Gmail, Yahoo, gov.in, etc.
  static String? govtEmail(String? v) => email(v);

  /// 10-digit mobile number
  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Mobile number is required';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return 'Enter a valid 10-digit mobile number';
    return null;
  }

  /// Username: alphanumeric, 4-20 chars
  static String? username(String? v) {
    if (v == null || v.trim().isEmpty) return 'Username is required';
    if (v.trim().length < 4) return 'Username must be at least 4 characters';
    if (v.trim().length > 20) return 'Username must be at most 20 characters';
    if (!RegExp(r'^[a-zA-Z0-9_\.]+$').hasMatch(v.trim())) {
      return 'Username can only contain letters, numbers, _ and .';
    }
    return null;
  }

  /// Password: min 8 chars
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  /// Confirm password
  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != original) return 'Passwords do not match';
    return null;
  }

  /// 6-digit PIN
  static String? pin(String? v) {
    if (v == null || v.isEmpty) return 'PIN is required';
    if (v.length != 6) return 'PIN must be exactly 6 digits';
    if (!RegExp(r'^\d{6}$').hasMatch(v)) return 'PIN must contain only digits';
    return null;
  }

  /// Landline number: at least 8 digits
  static String? landline(String? v) {
    if (v == null || v.trim().isEmpty) return 'Landline number is required';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return 'Enter a valid landline number';
    return null;
  }

  /// Login identifier: email or username
  static String? loginId(String? v) {
    if (v == null || v.trim().isEmpty) return 'Username or email is required';
    return null;
  }
}
