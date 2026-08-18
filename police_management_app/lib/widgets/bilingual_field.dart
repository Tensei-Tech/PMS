import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'responsive_field_row.dart';

/// Canonical bilingual form field styling (Crime Detail Form reference).
/// All forms must use these widgets — do not copy-paste field helpers locally.

class BilingualSimpleUnderlineInput extends StatelessWidget {
  final TextEditingController controller;
  final TextStyle serifStyle;
  final String? hintText;

  const BilingualSimpleUnderlineInput({
    super.key,
    required this.controller,
    required this.serifStyle,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.start,
      scrollPhysics: const NeverScrollableScrollPhysics(),
      scrollPadding: EdgeInsets.zero,
      maxLines: 1,
      style: serifStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade900,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.only(bottom: 4, top: 2),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black54, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 1.5),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black54, width: 0.8),
        ),
        hintText: hintText,
        hintStyle: serifStyle.copyWith(
          color: Colors.grey.shade400,
          fontSize: 11,
        ),
      ),
    );
  }
}

class BilingualField extends StatelessWidget {
  final String label;
  final String marathiLabel;
  final TextEditingController controller;
  final TextStyle serifStyle;
  final TextStyle marathiLabelStyle;
  final bool showMarathiLabel;

  const BilingualField({
    super.key,
    required this.label,
    required this.marathiLabel,
    required this.controller,
    required this.serifStyle,
    required this.marathiLabelStyle,
    this.showMarathiLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label.isNotEmpty)
          Text(label, style: serifStyle),
        if (showMarathiLabel && marathiLabel.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(marathiLabel, style: marathiLabelStyle),
        ],
        const SizedBox(height: 4),
        BilingualSimpleUnderlineInput(
          controller: controller,
          serifStyle: serifStyle,
        ),
      ],
    );
  }
}

class BilingualWideField extends StatelessWidget {
  final String label;
  final String marathiLabel;
  final TextEditingController controller;
  final TextStyle serifStyle;
  final TextStyle marathiLabelStyle;

  const BilingualWideField({
    super.key,
    required this.label,
    required this.marathiLabel,
    required this.controller,
    required this.serifStyle,
    required this.marathiLabelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$label ', style: serifStyle),
        const SizedBox(height: 2),
        Text(marathiLabel, style: marathiLabelStyle),
        const SizedBox(height: 4),
        BilingualSimpleUnderlineInput(
          controller: controller,
          serifStyle: serifStyle,
        ),
      ],
    );
  }
}

class BilingualDynamicLinedTextField extends StatelessWidget {
  final TextEditingController controller;
  final int minLines;
  final TextStyle serifStyle;
  final TextStyle? marathiLabelStyle;

  const BilingualDynamicLinedTextField({
    super.key,
    required this.controller,
    required this.minLines,
    required this.serifStyle,
    this.marathiLabelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final TextStyle textStyle = serifStyle.copyWith(
              fontSize: 14,
              height: 1.71,
              color: Colors.blue.shade900,
              fontWeight: FontWeight.bold,
            );

            final textWidth = constraints.maxWidth - 8;

            int lines = minLines;
            if (value.text.isNotEmpty) {
              final textPainter = TextPainter(
                text: TextSpan(text: value.text, style: textStyle),
                textDirection: TextDirection.ltr,
              );
              textPainter.layout(maxWidth: textWidth);
              final count = textPainter.computeLineMetrics().length;
              if (count > minLines) {
                lines = count;
              }
            }

            return Stack(
              children: [
                Column(
                  children: List.generate(
                    lines,
                    (index) => Container(
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black87, width: 1)),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: controller,
                  textAlign: TextAlign.start,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: textStyle,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class BilingualMultilineField extends StatelessWidget {
  final String label;
  final String marathiLabel;
  final TextEditingController controller;
  final int minLines;
  final TextStyle serifStyle;
  final TextStyle marathiLabelStyle;

  const BilingualMultilineField({
    super.key,
    required this.label,
    required this.marathiLabel,
    required this.controller,
    required this.minLines,
    required this.serifStyle,
    required this.marathiLabelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: serifStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        if (marathiLabel.isNotEmpty)
          Text(
            marathiLabel,
            style: marathiLabelStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 8),
        BilingualDynamicLinedTextField(
          controller: controller,
          minLines: minLines,
          serifStyle: serifStyle,
          marathiLabelStyle: marathiLabelStyle,
        ),
      ],
    );
  }
}

class BilingualSectionHeader extends StatelessWidget {
  final String label;
  final String marathiLabel;
  final TextStyle serifStyle;
  final TextStyle marathiLabelStyle;

  const BilingualSectionHeader({
    super.key,
    required this.label,
    required this.marathiLabel,
    required this.serifStyle,
    required this.marathiLabelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: serifStyle),
          Text(
            marathiLabel,
            style: marathiLabelStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class BilingualFieldRow extends StatelessWidget {
  final List<Widget> fields;

  const BilingualFieldRow({
    super.key,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveFieldRow(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < fields.length; i++) ...[
          if (i > 0) const SizedBox(width: 24),
          Expanded(child: fields[i]),
        ],
      ],
    );
  }
}

class BilingualNumberedMethodField extends StatelessWidget {
  final String number;
  final TextEditingController controller;
  final TextStyle serifStyle;

  const BilingualNumberedMethodField({
    super.key,
    required this.number,
    required this.controller,
    required this.serifStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$number : ',
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        BilingualSimpleUnderlineInput(
          controller: controller,
          serifStyle: serifStyle,
        ),
      ],
    );
  }
}
