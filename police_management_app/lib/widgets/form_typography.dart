import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Canonical form typography (Lora + Noto Sans Devanagari).
class FormTypography {
  static TextStyle serifStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color color = Colors.black87,
  }) {
    return GoogleFonts.lora(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle marathiLabelStyle({
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.bold,
    Color color = Colors.black87,
  }) {
    return GoogleFonts.notoSansDevanagari(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
