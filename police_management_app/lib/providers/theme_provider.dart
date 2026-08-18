import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ThemeProvider — always returns light mode.
/// Dark theme has been removed. This provider is kept for API compatibility
/// (isDark is always false, themeMode is always ThemeMode.light).
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  // Always light — dark mode removed per ISSUE 1.
  ThemeMode get themeMode => ThemeMode.light;
  bool get isDark => false;

  ThemeProvider() {
    _clearDarkPref();
  }

  /// Clears any previously stored dark preference so the app never reverts.
  Future<void> _clearDarkPref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, 'light');
  }

  /// No-op — kept for API compatibility (callers that still call toggleTheme).
  Future<void> toggleTheme() async {}

  /// No-op — kept for API compatibility (callers that still call setTheme).
  Future<void> setTheme(ThemeMode mode) async {}
}
