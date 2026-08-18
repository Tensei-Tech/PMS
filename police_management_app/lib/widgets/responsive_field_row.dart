import 'package:flutter/material.dart';

class ResponsiveFieldRow extends StatelessWidget {
  final List<Widget> children;
  final double breakpoint;
  final CrossAxisAlignment crossAxisAlignment;

  const ResponsiveFieldRow({
    super.key,
    required this.children,
    this.breakpoint = 600.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    // Reverted the stacking logic as per user request:
    // Fields should always render in their original desktop layout/positions (Row).
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}
