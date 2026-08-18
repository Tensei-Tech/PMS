// lib/widgets/base_form/standard_form_field_row.dart

import 'package:flutter/material.dart';

/// Groups related fields in a row; stacks on narrow widths.
class StandardFormFieldRow extends StatelessWidget {
  const StandardFormFieldRow({
    super.key,
    required this.children,
    this.spacing = 16,
    this.stackBelowWidth = 520,
  });

  final List<Widget> children;
  final double spacing;
  final double stackBelowWidth;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    if (children.length == 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: children.first,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < stackBelowWidth;
        if (stack) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) SizedBox(height: spacing / 2),
                  children[i],
                ],
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(width: spacing),
                Expanded(child: children[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}
