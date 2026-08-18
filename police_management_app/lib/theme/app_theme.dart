// lib/theme/app_theme.dart
// Material Design 3 theme with police-grade professional color palette.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color Palette ─────────────────────────────────────────────────────────────
class AppColors {
  // Primary navy (M3 spec: #1A237E deep navy)
  static const Color navyDark = Color(0xFF0D1B3E);
  static const Color navyMid = Color(0xFF1A237E);
  static const Color navyLight = Color(0xFF283593);
  static const Color navyAccent = Color(0xFF3949AB); // lighter for hover/states

  // Cyan accent (Issue 11: #00BCD4)
  static const Color cyanPrimary = Color(0xFF00BCD4);
  static const Color cyanLight = Color(0xFF4DD0E1);
  static const Color cyanDark = Color(0xFF00838F);

  // Gold accent (professional police badge gold)
  static const Color goldPrimary = Color(0xFFFFB300); // Issue 11: #FFB300
  static const Color goldLight = Color(0xFFFFCA28);
  static const Color goldDark = Color(0xFFFF8F00);
  static const Color goldAccent = Color(0xFFFFD740);

  // Semantic colors
  static const Color successGreen = Color(0xFF00C853);
  static const Color warningOrange = Color(0xFFFF6D00);
  static const Color dangerRed = Color(0xFFD50000);
  static const Color infoBlue = Color(0xFF0288D1);

  // Light mode surfaces
  static const Color lightBg = Color(0xFFF0F4FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF0D1B3E);
  static const Color lightSubText = Color(0xFF546E7A);
  static const Color lightBorder = Color(0xFFCFD8DC);

  // Dark mode surfaces
  static const Color darkBg = Color(0xFF050D1A);
  static const Color darkSurface = Color(0xFF0A1628);
  static const Color darkCard = Color(0xFF0F1F3D);
  static const Color darkText = Color(0xFFE8EAF6);
  static const Color darkSubText = Color(0xFF90A4AE);
  static const Color darkBorder = Color(0xFF1A2D5A);

  // Gradient helpers
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [navyMid, navyDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldLight, goldPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [cyanLight, cyanPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ── Spacing ───────────────────────────────────────────────────────────────────
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// ── Border Radius ─────────────────────────────────────────────────────────────
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
  static const double full = 100.0;

  static BorderRadius get cardRadius =>
      BorderRadius.circular(lg);
  static BorderRadius get buttonRadius =>
      BorderRadius.circular(md);
  static BorderRadius get inputRadius =>
      BorderRadius.circular(md);
}

// ── Theme ─────────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData lightTheme({double fontScale = 1.0}) {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navyMid,
        brightness: Brightness.light,
        primary: AppColors.navyMid,
        secondary: AppColors.cyanPrimary,
        tertiary: AppColors.goldPrimary,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onSecondary: AppColors.navyDark,
        onSurface: AppColors.lightText,
        error: AppColors.dangerRed,
      ),
      scaffoldBackgroundColor: AppColors.lightBg,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: _buildTextTheme(AppColors.lightText, AppColors.lightSubText, fontScale),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.lightText,
        ),
        iconTheme: const IconThemeData(color: AppColors.lightText),
        actionsIconTheme: const IconThemeData(color: AppColors.lightText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyMid,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navyMid,
          side: const BorderSide(color: AppColors.navyMid),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: _buildInputTheme(
        fillColor: const Color(0xFFF8FAFF),
        textColor: AppColors.lightText,
        borderColor: AppColors.lightBorder,
        focusColor: AppColors.navyMid,
        labelColor: AppColors.navyLight,
        hintColor: AppColors.lightSubText,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 2,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.lightBorder, thickness: 1),
      switchTheme: SwitchThemeData(
        thumbColor:
            WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
                ? AppColors.navyMid
                : Colors.grey.shade400),
        trackColor:
            WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
                ? AppColors.navyMid.withValues(alpha: 0.4)
                : Colors.grey.shade300),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.navyMid,
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.lightText),
        subtitleTextStyle: GoogleFonts.poppins(
            fontSize: 12, color: AppColors.lightSubText),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary, double scale) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
          fontSize: 32 * scale, fontWeight: FontWeight.w800, color: primary),
      displayMedium: GoogleFonts.poppins(
          fontSize: 28 * scale, fontWeight: FontWeight.w700, color: primary),
      headlineLarge: GoogleFonts.poppins(
          fontSize: 24 * scale, fontWeight: FontWeight.w700, color: primary),
      headlineMedium: GoogleFonts.poppins(
          fontSize: 20 * scale, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: GoogleFonts.poppins(
          fontSize: 18 * scale, fontWeight: FontWeight.w600, color: primary),
      titleLarge: GoogleFonts.poppins(
          fontSize: 16 * scale, fontWeight: FontWeight.w600, color: primary),
      titleMedium: GoogleFonts.poppins(
          fontSize: 14 * scale, fontWeight: FontWeight.w500, color: primary),
      titleSmall: GoogleFonts.poppins(
          fontSize: 13 * scale, fontWeight: FontWeight.w500, color: secondary),
      bodyLarge: GoogleFonts.poppins(
          fontSize: 15 * scale, fontWeight: FontWeight.w400, color: primary),
      bodyMedium: GoogleFonts.poppins(
          fontSize: 13 * scale, fontWeight: FontWeight.w400, color: secondary),
      bodySmall: GoogleFonts.poppins(
          fontSize: 11 * scale, fontWeight: FontWeight.w400, color: secondary),
      labelLarge: GoogleFonts.poppins(
          fontSize: 14 * scale, fontWeight: FontWeight.w600, color: Colors.white),
    );
  }

  static InputDecorationTheme _buildInputTheme({
    required Color fillColor,
    required Color textColor,
    required Color borderColor,
    required Color focusColor,
    required Color labelColor,
    required Color hintColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: focusColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.dangerRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.dangerRed, width: 2),
      ),
      hintStyle: GoogleFonts.poppins(color: hintColor, fontSize: 14),
      labelStyle:
          GoogleFonts.poppins(color: labelColor, fontSize: 14, fontWeight: FontWeight.w500),
      errorStyle: GoogleFonts.poppins(
          color: AppColors.dangerRed, fontSize: 12, fontWeight: FontWeight.w500),
      prefixIconColor: labelColor,
      suffixIconColor: hintColor,
    );
  }

  /// Smooth page route with fade+slide transition
  static Route<T> fadeSlideRoute<T>({required Widget page}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.05);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
