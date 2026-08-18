import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import '../utils/form_io_terminology.dart';

/// Standard Investigation Officer signature + stamp block ending a form section.
class FormIoSignatureBlock extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController rankCtrl;
  final TextEditingController numberCtrl;
  final TextEditingController postingCtrl;
  final TextStyle serifStyle;
  final TextStyle marathiLabelStyle;
  final String englishLabel;
  final String marathiLabel;

  const FormIoSignatureBlock({
    super.key,
    required this.nameCtrl,
    required this.rankCtrl,
    required this.numberCtrl,
    required this.postingCtrl,
    required this.serifStyle,
    required this.marathiLabelStyle,
    this.englishLabel = FormIoTerminology.englishSignatureHeader,
    this.marathiLabel = FormIoTerminology.signatureHeader,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BilingualSectionHeader(
          label: englishLabel,
          marathiLabel: marathiLabel,
          serifStyle: serifStyle,
          marathiLabelStyle: marathiLabelStyle,
        ),
        const SizedBox(height: 8),
        BilingualField(
          label: 'Name :- ',
          marathiLabel: FormIoTerminology.name,
          controller: nameCtrl,
          serifStyle: serifStyle,
          marathiLabelStyle: marathiLabelStyle,
        ),
        const SizedBox(height: 8),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Rank :- ',
              marathiLabel: FormIoTerminology.rank,
              controller: rankCtrl,
              serifStyle: serifStyle,
              marathiLabelStyle: marathiLabelStyle,
            ),
            BilingualField(
              label: 'Number if any :- ',
              marathiLabel: FormIoTerminology.badgeNo,
              controller: numberCtrl,
              serifStyle: serifStyle,
              marathiLabelStyle: marathiLabelStyle,
            ),
          ],
        ),
        const SizedBox(height: 8),
        BilingualWideField(
          label: 'Posting and Address :- ',
          marathiLabel: FormIoTerminology.posting,
          controller: postingCtrl,
          serifStyle: serifStyle,
          marathiLabelStyle: marathiLabelStyle,
        ),
      ],
    );
  }
}
