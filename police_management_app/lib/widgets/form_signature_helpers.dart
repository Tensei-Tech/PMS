import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import 'form_io_signature_block.dart';

/// SHO / Station House Officer signature block.
class FormShoSignatureBlock extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController rankCtrl;
  final TextEditingController psCtrl;
  final TextStyle serifStyle;
  final TextStyle marathiLabelStyle;

  const FormShoSignatureBlock({
    super.key,
    required this.nameCtrl,
    required this.rankCtrl,
    required this.psCtrl,
    required this.serifStyle,
    required this.marathiLabelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BilingualSectionHeader(
          label: 'Signature of Station House Officer :-',
          marathiLabel: 'पोलीस ठाणेदाराची सही',
          serifStyle: serifStyle,
          marathiLabelStyle: marathiLabelStyle,
        ),
        const SizedBox(height: 8),
        BilingualField(
          label: 'Name :- ',
          marathiLabel: 'नांव',
          controller: nameCtrl,
          serifStyle: serifStyle,
          marathiLabelStyle: marathiLabelStyle,
        ),
        const SizedBox(height: 8),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Rank :- ',
              marathiLabel: 'पद',
              controller: rankCtrl,
              serifStyle: serifStyle,
              marathiLabelStyle: marathiLabelStyle,
            ),
            BilingualField(
              label: 'Police Station :- ',
              marathiLabel: 'पोलीस स्टेशन',
              controller: psCtrl,
              serifStyle: serifStyle,
              marathiLabelStyle: marathiLabelStyle,
            ),
          ],
        ),
      ],
    );
  }
}

/// Medical Officer signature block.
class FormMedicalOfficerSignatureBlock extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController designationCtrl;
  final TextEditingController hospitalCtrl;
  final TextStyle serifStyle;
  final TextStyle marathiLabelStyle;

  const FormMedicalOfficerSignatureBlock({
    super.key,
    required this.nameCtrl,
    required this.designationCtrl,
    required this.hospitalCtrl,
    required this.serifStyle,
    required this.marathiLabelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BilingualSectionHeader(
          label: 'Signature of Medical Officer :-',
          marathiLabel: 'वैद्यकीय अधिकाऱ्याची सही',
          serifStyle: serifStyle,
          marathiLabelStyle: marathiLabelStyle,
        ),
        const SizedBox(height: 8),
        BilingualField(
          label: 'Name :- ',
          marathiLabel: 'नांव',
          controller: nameCtrl,
          serifStyle: serifStyle,
          marathiLabelStyle: marathiLabelStyle,
        ),
        const SizedBox(height: 8),
        BilingualField(
          label: 'Designation :- ',
          marathiLabel: 'पद',
          controller: designationCtrl,
          serifStyle: serifStyle,
          marathiLabelStyle: marathiLabelStyle,
        ),
        const SizedBox(height: 8),
        BilingualWideField(
          label: 'Hospital / Dispensary :- ',
          marathiLabel: 'रुग्णालय / दवाखाना',
          controller: hospitalCtrl,
          serifStyle: serifStyle,
          marathiLabelStyle: marathiLabelStyle,
        ),
      ],
    );
  }
}

/// Accused acknowledgement + I.O. signature side-by-side.
class FormAccusedIoSignatureRow extends StatelessWidget {
  final TextEditingController accusedSigCtrl;
  final TextEditingController accusedNameCtrl;
  final TextEditingController accusedDateCtrl;
  final TextEditingController ioNameCtrl;
  final TextEditingController ioRankCtrl;
  final TextEditingController ioNoCtrl;
  final TextEditingController ioPostingCtrl;
  final TextStyle serifStyle;
  final TextStyle marathiLabelStyle;

  const FormAccusedIoSignatureRow({
    super.key,
    required this.accusedSigCtrl,
    required this.accusedNameCtrl,
    required this.accusedDateCtrl,
    required this.ioNameCtrl,
    required this.ioRankCtrl,
    required this.ioNoCtrl,
    required this.ioPostingCtrl,
    required this.serifStyle,
    required this.marathiLabelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BilingualSectionHeader(
                label: 'Accused signature / acknowledgement',
                marathiLabel: 'आरोपीची सही / पोच',
                serifStyle: serifStyle,
                marathiLabelStyle: marathiLabelStyle,
              ),
              const SizedBox(height: 8),
              BilingualField(
                label: 'Signature :- ',
                marathiLabel: 'सही',
                controller: accusedSigCtrl,
                serifStyle: serifStyle,
                marathiLabelStyle: marathiLabelStyle,
              ),
              BilingualField(
                label: 'Name :- ',
                marathiLabel: 'नांव',
                controller: accusedNameCtrl,
                serifStyle: serifStyle,
                marathiLabelStyle: marathiLabelStyle,
              ),
              BilingualField(
                label: 'Date & time :- ',
                marathiLabel: 'दिनांक व वेळ',
                controller: accusedDateCtrl,
                serifStyle: serifStyle,
                marathiLabelStyle: marathiLabelStyle,
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: FormIoSignatureBlock(
            nameCtrl: ioNameCtrl,
            rankCtrl: ioRankCtrl,
            numberCtrl: ioNoCtrl,
            postingCtrl: ioPostingCtrl,
            serifStyle: serifStyle,
            marathiLabelStyle: marathiLabelStyle,
          ),
        ),
      ],
    );
  }
}

/// Relative acknowledgement + I.O. signature side-by-side.
class FormRelativeIoSignatureRow extends StatelessWidget {
  final TextEditingController relativeSigCtrl;
  final TextEditingController relativeNameCtrl;
  final TextEditingController relativeDateCtrl;
  final TextEditingController ioNameCtrl;
  final TextEditingController ioRankCtrl;
  final TextEditingController ioNoCtrl;
  final TextEditingController ioPostingCtrl;
  final TextStyle serifStyle;
  final TextStyle marathiLabelStyle;

  const FormRelativeIoSignatureRow({
    super.key,
    required this.relativeSigCtrl,
    required this.relativeNameCtrl,
    required this.relativeDateCtrl,
    required this.ioNameCtrl,
    required this.ioRankCtrl,
    required this.ioNoCtrl,
    required this.ioPostingCtrl,
    required this.serifStyle,
    required this.marathiLabelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BilingualSectionHeader(
                label: 'Relative / friend signature',
                marathiLabel: 'नातेवाईक / मित्राची सही',
                serifStyle: serifStyle,
                marathiLabelStyle: marathiLabelStyle,
              ),
              const SizedBox(height: 8),
              BilingualField(
                label: 'Signature :- ',
                marathiLabel: 'सही',
                controller: relativeSigCtrl,
                serifStyle: serifStyle,
                marathiLabelStyle: marathiLabelStyle,
              ),
              BilingualField(
                label: 'Name :- ',
                marathiLabel: 'नांव',
                controller: relativeNameCtrl,
                serifStyle: serifStyle,
                marathiLabelStyle: marathiLabelStyle,
              ),
              BilingualField(
                label: 'Date & time :- ',
                marathiLabel: 'दिनांक व वेळ',
                controller: relativeDateCtrl,
                serifStyle: serifStyle,
                marathiLabelStyle: marathiLabelStyle,
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: FormIoSignatureBlock(
            nameCtrl: ioNameCtrl,
            rankCtrl: ioRankCtrl,
            numberCtrl: ioNoCtrl,
            postingCtrl: ioPostingCtrl,
            serifStyle: serifStyle,
            marathiLabelStyle: marathiLabelStyle,
          ),
        ),
      ],
    );
  }
}

/// Panch names + signatures (two panchas).
Widget buildPanchSignatureSection({
  required TextStyle serifStyle,
  required TextStyle marathiLabelStyle,
  required TextEditingController p1l1,
  required TextEditingController p1l2,
  required TextEditingController p2l1,
  required TextEditingController p2l2,
  required TextEditingController sig1,
  required TextEditingController sig2,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BilingualSectionHeader(
              label: 'Name and Address of Panchas:-',
              marathiLabel: 'पंचाचे नांव व पत्ता',
              serifStyle: serifStyle,
              marathiLabelStyle: marathiLabelStyle,
            ),
            const SizedBox(height: 8),
            BilingualNumberedMethodField(number: '1', controller: p1l1, serifStyle: serifStyle),
            BilingualNumberedMethodField(number: '', controller: p1l2, serifStyle: serifStyle),
            const SizedBox(height: 12),
            BilingualNumberedMethodField(number: '2', controller: p2l1, serifStyle: serifStyle),
            BilingualNumberedMethodField(number: '', controller: p2l2, serifStyle: serifStyle),
          ],
        ),
      ),
      const SizedBox(width: 32),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BilingualSectionHeader(
              label: 'Signature :-',
              marathiLabel: 'सह्या',
              serifStyle: serifStyle,
              marathiLabelStyle: marathiLabelStyle,
            ),
            const SizedBox(height: 8),
            BilingualNumberedMethodField(number: '1', controller: sig1, serifStyle: serifStyle),
            const SizedBox(height: 12),
            BilingualNumberedMethodField(number: '2', controller: sig2, serifStyle: serifStyle),
          ],
        ),
      ),
    ],
  );
}

/// Standard notice header fields shared across BNSS notices.
Widget buildNoticeHeaderFields({
  required TextStyle serif,
  required TextStyle marathiLabel,
  required TextEditingController outwardNoCtrl,
  required TextEditingController outwardYearCtrl,
  required TextEditingController policeStationCtrl,
  required TextEditingController talukaCtrl,
  required TextEditingController districtCtrl,
  required TextEditingController noticeDateCtrl,
  required TextEditingController toNameAddressCtrl,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      BilingualFieldRow(
        fields: [
          BilingualField(
            label: 'Outward No.',
            marathiLabel: 'जावक क्रमांक',
            controller: outwardNoCtrl,
            serifStyle: serif,
            marathiLabelStyle: marathiLabel,
          ),
          BilingualField(
            label: 'Year',
            marathiLabel: 'वर्ष',
            controller: outwardYearCtrl,
            serifStyle: serif,
            marathiLabelStyle: marathiLabel,
          ),
        ],
      ),
      const SizedBox(height: 12),
      BilingualField(
        label: 'Police Station',
        marathiLabel: 'पोलीस स्टेशन',
        controller: policeStationCtrl,
        serifStyle: serif,
        marathiLabelStyle: marathiLabel,
      ),
      BilingualFieldRow(
        fields: [
          BilingualField(
            label: 'Taluka',
            marathiLabel: 'ता.',
            controller: talukaCtrl,
            serifStyle: serif,
            marathiLabelStyle: marathiLabel,
          ),
          BilingualField(
            label: 'District',
            marathiLabel: 'जिल्हा',
            controller: districtCtrl,
            serifStyle: serif,
            marathiLabelStyle: marathiLabel,
          ),
        ],
      ),
      BilingualField(
        label: 'Date',
        marathiLabel: 'दिनांक',
        controller: noticeDateCtrl,
        serifStyle: serif,
        marathiLabelStyle: marathiLabel,
      ),
      const SizedBox(height: 12),
      BilingualMultilineField(
        label: 'To — Name & Address',
        marathiLabel: 'प्रति, नाव व पत्ता',
        controller: toNameAddressCtrl,
        serifStyle: serif,
        marathiLabelStyle: marathiLabel,
        minLines: 2,
      ),
    ],
  );
}
