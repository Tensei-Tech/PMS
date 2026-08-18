import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'form_layout.dart';

/// A4 paper-styled page container shared across bilingual form views.
class FormPaperPage extends StatelessWidget {
  final List<Widget> children;
  final String? formLabel;
  final CrossAxisAlignment crossAxisAlignment;

  const FormPaperPage({
    super.key,
    required this.children,
    this.formLabel,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: FormLayout.maxPaperWidth,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFA),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      padding: const EdgeInsets.all(FormLayout.paperPadding),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (formLabel != null)
            Align(
              alignment: Alignment.topRight,
              child: Text(
                formLabel!,
                style: GoogleFonts.lora(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  color: Colors.black87,
                ),
              ),
            ),
          if (formLabel != null) const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
