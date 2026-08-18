// lib/utils/pdf_unicode_fonts.dart
// Embeds Open Sans in PDFs so em dash, Devanagari, and other Unicode text render (not Helvetica).

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfUnicodeFonts {
  PdfUnicodeFonts._();

  static Future<pw.ThemeData> openSansTheme() async {
    final base = await PdfGoogleFonts.openSansRegular();
    final bold = await PdfGoogleFonts.openSansBold();
    final italic = await PdfGoogleFonts.openSansItalic();
    return pw.ThemeData.withFont(
      base: base,
      bold: bold,
      italic: italic,
    );
  }
}
