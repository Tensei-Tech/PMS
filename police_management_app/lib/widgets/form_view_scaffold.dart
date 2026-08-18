import 'package:flutter/material.dart';

import 'a4_zoomable_view.dart';

/// Outer scaffold shared by bilingual form views: zoom + padding + read-only guard.
class FormViewScaffold extends StatelessWidget {
  final bool readOnly;
  final List<Widget> children;

  const FormViewScaffold({
    super.key,
    required this.readOnly,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return A4ZoomableView(
      child: AbsorbPointer(
        absorbing: readOnly,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
