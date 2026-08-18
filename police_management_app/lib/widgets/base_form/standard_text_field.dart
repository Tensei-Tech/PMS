// lib/widgets/base_form/standard_text_field.dart

import 'package:flutter/material.dart';

import 'base_form_styles.dart';

/// Unified text field for standalone data-entry forms.
class StandardTextField extends StatelessWidget {
  const StandardTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType keyboardType;
  final bool readOnly;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      validator: validator,
      textAlign: TextAlign.start,
      style: BaseFormStyles.fieldTextStyle,
      decoration: BaseFormStyles.inputDecoration(
        label,
        hintText: hint,
        suffixIcon: suffixIcon,
      ).copyWith(
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: BaseFormStyles.labelColor)
            : null,
      ),
    );
  }
}
