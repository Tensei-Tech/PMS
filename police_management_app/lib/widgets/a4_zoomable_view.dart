import 'package:flutter/material.dart';

import 'form_layout.dart';

/// Mobile-friendly zoom/pan wrapper for A4-style form content.
///
/// The child is always laid out at a fixed [FormLayout.maxPaperWidth] canvas so
/// multi-column tabular forms keep their desktop layout. On narrow viewports an
/// [InteractiveViewer] provides fit-to-screen initial scale plus pinch-zoom and pan.
class A4ZoomableView extends StatefulWidget {
  final Widget child;
  const A4ZoomableView({super.key, required this.child});

  @override
  State<A4ZoomableView> createState() => _A4ZoomableViewState();
}

class _A4ZoomableViewState extends State<A4ZoomableView> {
  final TransformationController _transformCtrl = TransformationController();
  bool _initializedScale = false;
  double _lastViewportWidth = 0;

  /// When set, single-finger pan is disabled so InteractiveViewer does not
  /// compete with tap-to-focus / typing gestures.
  bool _editingText = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocusChange);
    _transformCtrl.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    final focus = FocusManager.instance.primaryFocus;
    final editing = _isEditableTextFocus(focus);
    if (editing == _editingText || !mounted) return;
    setState(() => _editingText = editing);
  }

  bool _isEditableTextFocus(FocusNode? focus) {
    final ctx = focus?.context;
    if (ctx == null) return false;
    if (ctx.widget is EditableText) return true;
    return ctx.findAncestorStateOfType<EditableTextState>() != null;
  }

  void _applyCenteredScale(double viewportWidth, double scale) {
    _transformCtrl.value = FormLayout.centeredFitTransform(
      viewportWidth: viewportWidth,
      contentWidth: FormLayout.maxPaperWidth,
      scale: scale,
    );
  }

  void _applyCenteredFitScale(double viewportWidth) {
    _applyCenteredScale(viewportWidth, FormLayout.fitScaleFor(viewportWidth));
    _initializedScale = true;
    _lastViewportWidth = viewportWidth;
  }

  void _ensureInitialTransform(double viewportWidth) {
    if (_initializedScale &&
        (viewportWidth - _lastViewportWidth).abs() <= 1) {
      return;
    }
    _applyCenteredFitScale(viewportWidth);
  }

  /// Snap back if a gesture ends below the fit-scale floor (zoom-out cap only).
  void _clampZoomScale(double viewportWidth) {
    final minS = FormLayout.minZoomScale(viewportWidth);
    final current = _transformCtrl.value.getMaxScaleOnAxis();
    if (current >= minS) return;
    _applyCenteredScale(viewportWidth, minS);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final viewportHeight = constraints.maxHeight;
        final isWide = viewportWidth >= FormLayout.wideBreakpoint;

        final fixedCanvas = SizedBox(
          width: FormLayout.maxPaperWidth,
          child: widget.child,
        );

        // Desktop / wide: plain vertical scroll, no zoom/pan.
        if (isWide) {
          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: FormLayout.desktopOuterPadding(),
                child: fixedCanvas,
              ),
            ),
          );
        }

        _ensureInitialTransform(viewportWidth);

        final minZoom = FormLayout.minZoomScale(viewportWidth);

        // Full-width host so InteractiveViewer has correct viewport bounds.
        // topLeft: initial horizontal centering lives ONLY in [centeredFitTransform]
        // (the matrix). topCenter here would double-offset and push content right.
        return SizedBox(
          width: double.infinity,
          height: viewportHeight.isFinite ? viewportHeight : null,
          child: InteractiveViewer(
            constrained: false,
            transformationController: _transformCtrl,
            alignment: Alignment.topLeft,
            clipBehavior: Clip.none,
            panEnabled: !_editingText,
            scaleEnabled: true,
            minScale: minZoom,
            maxScale: FormLayout.maxZoomScale,
            onInteractionEnd: (_) => _clampZoomScale(viewportWidth),
            boundaryMargin: const EdgeInsets.all(64),
            child: fixedCanvas,
          ),
        );
      },
    );
  }
}
