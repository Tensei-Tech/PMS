import 'package:flutter/material.dart';

/// Serial-number cell for form tables.
class FormTableSrNoCell extends StatelessWidget {
  final int index;
  final TextStyle style;

  const FormTableSrNoCell({
    super.key,
    required this.index,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '${index + 1}',
        style: style.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

/// Bottom-right "M.R.W" footer used on form pages.
class FormMrwFooter extends StatelessWidget {
  final TextStyle serifStyle;
  final double fontSize;
  final Alignment alignment;

  const FormMrwFooter({
    super.key,
    required this.serifStyle,
    this.fontSize = 10,
    this.alignment = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Text(
        'M.R.W',
        style: serifStyle.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
