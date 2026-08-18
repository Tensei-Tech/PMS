// lib/widgets/standalone_form_layout.dart
// Back-compat wrappers — prefer `import '../widgets/base_form/base_form.dart'`.

import 'package:flutter/material.dart';

import 'base_form/base_form.dart';

export 'base_form/base_form.dart';

/// Legacy alias for [BaseFormContent].
class StandaloneFormLayout extends StatelessWidget {
  const StandaloneFormLayout({
    super.key,
    required this.child,
    this.maxWidth = BaseFormStyles.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  static Widget scrollContent({
    required List<Widget> children,
    double maxWidth = BaseFormStyles.maxContentWidth,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.stretch,
  }) =>
      BaseFormContent.scrollSections(
        children: children,
        maxWidth: maxWidth,
        crossAxisAlignment: crossAxisAlignment,
      );

  @override
  Widget build(BuildContext context) {
    return BaseFormContent(maxWidth: maxWidth, child: child);
  }
}

/// Legacy alias for [StandardFormFieldRow].
typedef StandaloneFormFieldRow = StandardFormFieldRow;

const double kStandaloneFormMaxWidth = BaseFormStyles.maxContentWidth;
