import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;

/// Holds the result of rendering text as a PNG image.
class RenderedText {
  final Uint8List bytes;
  final double width;
  final double height;

  RenderedText({required this.bytes, required this.width, required this.height});

  bool get isEmpty => bytes.isEmpty;
  bool get isNotEmpty => bytes.isNotEmpty;
}

/// Renders a text string to a high-resolution PNG image using Flutter's
/// Skia/HarfBuzz engine. This ensures correct Devanagari rendering
/// with proper matras, conjuncts, and half-letters that the `pdf`
/// package cannot do natively.
Future<RenderedText> renderTextToImage(
  String text, {
  required TextStyle style,
  double maxWidth = 500,
  double pixelRatio = 3.0,
  TextAlign textAlign = TextAlign.left,
}) async {
  if (text.trim().isEmpty) {
    return RenderedText(bytes: Uint8List(0), width: 0, height: 0);
  }

  final textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textAlign: textAlign,
  );
  textPainter.layout(maxWidth: maxWidth);

  // For center/right alignment, use maxWidth so text is properly positioned
  final w = (textAlign != TextAlign.left && maxWidth.isFinite)
      ? maxWidth
      : textPainter.width;
  final h = textPainter.height;

  if (w <= 0 || h <= 0) {
    return RenderedText(bytes: Uint8List(0), width: 0, height: 0);
  }

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(pixelRatio);
  textPainter.paint(canvas, Offset.zero);

  final picture = recorder.endRecording();
  final image = await picture.toImage(
    (w * pixelRatio).ceil(),
    (h * pixelRatio).ceil(),
  );

  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  return RenderedText(
    bytes: byteData!.buffer.asUint8List(),
    width: w,
    height: h,
  );
}

/// Cache for pre-rendered Marathi text images used in PDF generation.
class MarathiImageCache {
  final Map<String, RenderedText> _cache = {};
  final double pixelRatio;

  MarathiImageCache({this.pixelRatio = 3.0});

  /// Pre-render text and store with the given key.
  Future<void> add(
    String key,
    String text,
    TextStyle style, {
    double maxWidth = 500,
    TextAlign textAlign = TextAlign.left,
  }) async {
    if (text.trim().isEmpty) return;
    _cache[key] = await renderTextToImage(
      text,
      style: style,
      maxWidth: maxWidth,
      pixelRatio: pixelRatio,
      textAlign: textAlign,
    );
  }

  /// Get a `pw.Image` widget for a pre-rendered text.
  pw.Widget img(String key, {double? width, double? height}) {
    final data = _cache[key];
    if (data == null || data.isEmpty) return pw.SizedBox(width: 0, height: 0);

    final w = width ?? data.width;
    final scale = data.width > 0 ? w / data.width : 1.0;
    return pw.Image(
      pw.MemoryImage(data.bytes),
      width: w,
      height: height ?? (data.height * scale),
    );
  }

  /// Check if a key exists and has image data.
  bool has(String key) =>
      _cache.containsKey(key) && (_cache[key]?.isNotEmpty ?? false);

  /// Get raw rendered text data.
  RenderedText? get(String key) => _cache[key];
}

/// Check if a string contains Devanagari characters (U+0900–U+097F).
bool containsDevanagari(String text) {
  return text.runes.any((r) => r >= 0x0900 && r <= 0x097F);
}
