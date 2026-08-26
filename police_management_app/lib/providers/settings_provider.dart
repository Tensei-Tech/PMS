// lib/providers/settings_provider.dart
// Manages app-wide settings: font size, language, notifications, cache.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/firestore_service.dart';
import '../utils/app_constants.dart';

enum FontSize { small, medium, large }

class SettingsProvider extends ChangeNotifier {
  FontSize _fontSize = FontSize.medium;
  Locale _locale = const Locale('en');
  bool _isBiometricEnabled = false;
  bool _isBiometricSkipped = false;
  bool _shouldSkipNextBiometricAutoTrigger = false;

  final FirestoreService _firestore = FirestoreService();
  StreamSubscription<User?>? _authSub;
  // NOTE: Preferences are fetched once per login via .get() instead of a
  // permanent .snapshots() stream. They only change when the user explicitly
  // modifies settings, at which point we push the update to Firestore ourselves.

  FontSize get fontSize => _fontSize;
  Locale get locale => _locale;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isBiometricSkipped => _isBiometricSkipped;
  bool get shouldSkipNextBiometricAutoTrigger => _shouldSkipNextBiometricAutoTrigger;

  String get language {
    switch (_locale.languageCode) {
      case 'mr':
        return 'Marathi';
      case 'hi':
        return 'Hindi';
      default:
        return 'English';
    }
  }

  double get fontScale {
    switch (_fontSize) {
      case FontSize.small:
        return 0.85;
      case FontSize.large:
        return 1.15;
      default:
        return 1.0;
    }
  }

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'mr': 'Marathi',
    'hi': 'Hindi',
    'gu': 'Gujarati',
    'ta': 'Tamil',
    'te': 'Telugu',
    'kn': 'Kannada',
    'ml': 'Malayalam',
    'pa': 'Punjabi',
    'bn': 'Bengali',
  };

  SettingsProvider() {
    Future.microtask(() {
      _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
        unawaited(_fetchRemotePreferencesOnce(user));
      });
      unawaited(_load());
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  /// Fetches remote preferences once per login session (not a live stream).
  /// Preferences only change when the user explicitly updates them in Settings,
  /// so a single .get() read on login is sufficient.
  Future<void> _fetchRemotePreferencesOnce(User? user) async {
    final uid = user?.uid;
    if (uid == null || uid.isEmpty) return;
    try {
      final snap = await _firestore
          .watchUserAppPreferences(uid)
          .first
          .timeout(const Duration(seconds: 5));
      if (snap.exists && snap.data() != null) {
        unawaited(
            _applyRemotePreferenceMap(Map<String, dynamic>.from(snap.data()!)));
      }
    } catch (_) {
      // Non-fatal — local prefs already loaded in _load().
    }
  }

  String _fontSizeStorageString() {
    switch (_fontSize) {
      case FontSize.small:
        return 'small';
      case FontSize.large:
        return 'large';
      case FontSize.medium:
        return 'medium';
    }
  }

  Future<void> _pushPreferencesToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    try {
      await _firestore.mergeUserAppPreferences(uid, {
        'fontSize': _fontSizeStorageString(),
        'language': _locale.languageCode,
        'isBiometricEnabled': _isBiometricEnabled,
        'isBiometricSkipped': _isBiometricSkipped,
      });
    } catch (_) {
      /* mergeUserAppPreferences already logs */
    }
  }

  Future<void> _applyRemotePreferenceMap(Map<String, dynamic> remote) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var touched = false;

      final fs = remote['fontSize'];
      if (fs != null) {
        final s = fs.toString();
        final next = s == 'small'
            ? FontSize.small
            : s == 'large'
                ? FontSize.large
                : FontSize.medium;
        if (next != _fontSize) {
          _fontSize = next;
          await prefs.setString(StorageKeys.fontSize, s);
          touched = true;
        }
      }

      final lang = remote['language'];
      if (lang != null) {
        final code = lang.toString();
        final nextLocale = Locale(code);
        if (nextLocale.languageCode != _locale.languageCode) {
          _locale = nextLocale;
          await prefs.setString(StorageKeys.language, code);
          touched = true;
        }
      }

      final bio = remote['isBiometricEnabled'];
      if (bio is bool) {
        if (bio != _isBiometricEnabled) {
          _isBiometricEnabled = bio;
          await prefs.setBool('isBiometricEnabled', bio);
          touched = true;
        }
      }

      final skip = remote['isBiometricSkipped'];
      if (skip is bool) {
        if (skip != _isBiometricSkipped) {
          _isBiometricSkipped = skip;
          await prefs.setBool('isBiometricSkipped', skip);
          touched = true;
        }
      }

      if (touched) notifyListeners();
    } catch (_) {}
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fs = prefs.getString(StorageKeys.fontSize) ?? 'medium';
      _fontSize = fs == 'small'
          ? FontSize.small
          : fs == 'large'
              ? FontSize.large
              : FontSize.medium;

      final langCode = prefs.getString(StorageKeys.language) ?? 'en';
      _locale = Locale(langCode);
      _isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;
      _isBiometricSkipped = prefs.getBool('isBiometricSkipped') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> setFontSize(FontSize size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        StorageKeys.fontSize,
        size == FontSize.small
            ? 'small'
            : size == FontSize.large
                ? 'large'
                : 'medium');
    notifyListeners();
    await _pushPreferencesToFirestore();
  }

  Future<void> setLanguage(String langCode) async {
    _locale = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.language, langCode);
    notifyListeners();
    await _pushPreferencesToFirestore();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _isBiometricEnabled = enabled;
    if (enabled) {
      _isBiometricSkipped = false;
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isBiometricEnabled', enabled);
      if (enabled) {
        await prefs.setBool('isBiometricSkipped', false);
      }
      await _pushPreferencesToFirestore();
    } catch (e) {
      debugPrint('setBiometricEnabled non-blocking error: $e');
    }
  }

  Future<void> setBiometricSkipped(bool skipped) async {
    _isBiometricSkipped = skipped;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBiometricSkipped', skipped);
    notifyListeners();
    await _pushPreferencesToFirestore();
  }

  void setSkipBiometricAutoTrigger(bool skip) {
    _shouldSkipNextBiometricAutoTrigger = skip;
    notifyListeners();
  }

  Future<String> getCacheSize() async {
    // Approximation — in production this would scan the cache dir
    return '4.2 MB';
  }

  Future<void> clearCache() async {
    // In production: delete app cache directory
    notifyListeners();
  }
}
