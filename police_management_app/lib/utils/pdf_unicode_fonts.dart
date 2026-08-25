// lib/utils/pdf_unicode_fonts.dart
// Caches Unicode & Marathi fonts in memory so PDFs generate instantly (<100ms) without repeated network font downloads.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfUnicodeFonts {
  PdfUnicodeFonts._();

  static pw.ThemeData? _cachedOpenSansTheme;
  static pw.Font? _cachedLoraRegular;
  static pw.Font? _cachedLoraBold;
  static pw.Font? _cachedDevanagariRegular;
  static pw.Font? _cachedDevanagariBold;
  static pw.Font? _cachedInterRegular;
  static pw.Font? _cachedInterBold;
  static pw.Font? _cachedInterItalic;
  static pw.Font? _cachedInterBoldItalic;
  static pw.Font? _cachedOpenSansRegular;
  static pw.Font? _cachedOpenSansBold;
  static pw.Font? _cachedOpenSansItalic;

  static Future<pw.Font> loraRegular() async =>
      _cachedLoraRegular ??= await PdfGoogleFonts.loraRegular();

  static Future<pw.Font> loraBold() async =>
      _cachedLoraBold ??= await PdfGoogleFonts.loraBold();

  static Future<pw.Font> devanagariRegular() async =>
      _cachedDevanagariRegular ??= await PdfGoogleFonts.notoSansDevanagariRegular();

  static Future<pw.Font> devanagariBold() async =>
      _cachedDevanagariBold ??= await PdfGoogleFonts.notoSansDevanagariBold();

  static Future<pw.Font> interRegular() async =>
      _cachedInterRegular ??= await PdfGoogleFonts.interRegular();

  static Future<pw.Font> interBold() async =>
      _cachedInterBold ??= await PdfGoogleFonts.interBold();

  static Future<pw.Font> interItalic() async =>
      _cachedInterItalic ??= await PdfGoogleFonts.interItalic();

  static Future<pw.Font> interBoldItalic() async =>
      _cachedInterBoldItalic ??= await PdfGoogleFonts.interBoldItalic();

  static Future<pw.Font> openSansRegular() async =>
      _cachedOpenSansRegular ??= await PdfGoogleFonts.openSansRegular();

  static Future<pw.Font> openSansBold() async =>
      _cachedOpenSansBold ??= await PdfGoogleFonts.openSansBold();

  static Future<pw.Font> openSansItalic() async =>
      _cachedOpenSansItalic ??= await PdfGoogleFonts.openSansItalic();

  static Future<pw.ThemeData> openSansTheme() async {
    if (_cachedOpenSansTheme != null) return _cachedOpenSansTheme!;

    final results = await Future.wait([
      openSansRegular(),
      openSansBold(),
      openSansItalic(),
    ]);

    _cachedOpenSansTheme = pw.ThemeData.withFont(
      base: results[0],
      bold: results[1],
      italic: results[2],
    );
    return _cachedOpenSansTheme!;
  }

  /// Asynchronously preloads fonts in the background on startup
  /// so PDF generation never blocks on network font downloads.
  static void prefetch() {
    unawaited(Future.wait([
      openSansRegular(),
      openSansBold(),
      openSansItalic(),
      loraRegular(),
      loraBold(),
      devanagariRegular(),
      devanagariBold(),
    ]).then<void>((_) {
      if (kDebugMode) debugPrint('[PdfUnicodeFonts] All PDF fonts pre-cached.');
    }).catchError((e) {
      debugPrint('[PdfUnicodeFonts] Font prefetch warning: $e');
    }));
  }
}

