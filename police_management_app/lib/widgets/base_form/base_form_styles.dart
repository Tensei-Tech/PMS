// lib/widgets/base_form/base_form_styles.dart
// Shared visual tokens for standalone data-entry forms (not Forms-tile paper views).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

/// Global "CSS" for standalone module forms (AD, Missing, NC, etc.).
abstract final class BaseFormStyles {
  static const double maxContentWidth = 800;

  static const Color pageBg = Color(0xFFF4F7F9);
  static const Color inputBg = Color(0xFFF8FAFC);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color labelColor = Color(0xFF64748B);
  static const Color fieldTextColor = Color(0xFF1E293B);
  static const Color accent = Color(0xFF0EA5E9);

  static TextStyle get fieldTextStyle => GoogleFonts.poppins(
        fontSize: 12,
        color: fieldTextColor,
      );

  static TextStyle get labelStyle => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: labelColor,
        letterSpacing: 0.3,
      );

  static InputDecoration inputDecoration(
    String label, {
    Widget? suffixIcon,
    String? hintText,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: labelStyle,
        floatingLabelStyle: labelStyle.copyWith(
          fontSize: 11,
          color: accent,
        ),
        filled: true,
        fillColor: inputBg,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
      );

  static String formatDateDdMmYyyy(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static DateTime? parseDateDdMmYyyy(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final p = s.split('/');
    if (p.length != 3) return null;
    final d = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final y = int.tryParse(p[2]);
    if (d == null || m == null || y == null) return null;
    try {
      final dt = DateTime(y, m, d);
      if (dt.year != y || dt.month != m || dt.day != d) return null;
      return dt;
    } catch (_) {
      return null;
    }
  }
}
