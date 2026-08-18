import 'package:flutter/material.dart';

/// Shared layout constants for bilingual paper-style form views.
abstract final class FormLayout {
  /// Fixed canvas width — tabular / multi-column forms must never shrink below this.
  static const double maxPaperWidth = 900;
  static const double wideBreakpoint = 900;

  static const double desktopOuterMargin = 24;

  /// Original InteractiveViewer zoom-in ceiling (absolute scale, not fit-relative).
  static const double maxZoomScale = 4.0;

  static const double paperPadding = 32;

  /// Scale that fits the full paper width inside a narrow viewport (with gutters).
  static double fitScaleFor(double viewportWidth) {
    if (viewportWidth >= wideBreakpoint) return 1.0;
    const gutter = 16.0;
    final available = viewportWidth - gutter * 2;
    return (available / maxPaperWidth).clamp(0.25, 1.0);
  }

  /// Lowest allowed zoom: default fit-to-screen (no thumbnail shrink).
  static double minZoomScale(double viewportWidth) => fitScaleFor(viewportWidth);

  /// Initial transform: scale to [scale] and center the canvas horizontally.
  static Matrix4 centeredFitTransform({
    required double viewportWidth,
    required double contentWidth,
    required double scale,
  }) {
    final centerX = contentWidth / 2;
    return Matrix4.identity()
      ..translateByDouble(viewportWidth / 2, 0, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-centerX, 0, 0, 1);
  }

  static EdgeInsets desktopOuterPadding() =>
      const EdgeInsets.fromLTRB(desktopOuterMargin, 16, desktopOuterMargin, 24);
}
