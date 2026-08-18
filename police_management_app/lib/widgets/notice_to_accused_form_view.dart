import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import 'form_controller_utils.dart';
import 'form_paper_page.dart';
import 'form_signature_helpers.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';

/// Notice to Accused (page 37).
class NoticeToAccusedFormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const NoticeToAccusedFormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<NoticeToAccusedFormView> createState() => NoticeToAccusedFormViewState();
}

class NoticeToAccusedFormViewState extends State<NoticeToAccusedFormView> {
  late final Map<String, TextEditingController> _fields;

  @override
  void initState() {
    super.initState();
    _fields = {
      'outwardNo': TextEditingController(),
      'outwardYear': TextEditingController(text: '2025'),
      'policeStation': TextEditingController(),
      'taluka': TextEditingController(),
      'district': TextEditingController(),
      'noticeDate': TextEditingController(),
      'accusedNameAddress': TextEditingController(),
      'crNo': TextEditingController(),
      'section': TextEditingController(),
      'subject': TextEditingController(),
      'noticeBody': TextEditingController(),
      'accusedSig': TextEditingController(),
      'accusedDate': TextEditingController(),
      'ioName': TextEditingController(),
      'ioRank': TextEditingController(),
      'ioNo': TextEditingController(),
      'ioPosting': TextEditingController(),
    };
  }

  @override
  void dispose() {
    disposeControllers(_fields.values);
    super.dispose();
  }

  Map<String, dynamic> collectData() {
    return {
      'formSection': widget.formSection ?? '',
      'pageRange': widget.pageRange ?? '',
      ...collectFromControllers(_fields),
    };
  }

  void hydrateFrom(Map<String, dynamic> data) {
    hydrateControllers(data, _fields);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final serif = FormTypography.serifStyle();
    final marathi = FormTypography.marathiLabelStyle();

    return FormViewScaffold(
      readOnly: widget.readOnly,
      children: [
        FormPaperPage(
          formLabel: widget.pageRange,
          children: [
            Center(
              child: Column(
                children: [
                  Text('NOTICE TO ACCUSED', style: serif.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('आरोपीस सूचनापत्र', style: marathi.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            buildNoticeHeaderFields(
              serif: serif,
              marathiLabel: marathi,
              outwardNoCtrl: _fields['outwardNo']!,
              outwardYearCtrl: _fields['outwardYear']!,
              policeStationCtrl: _fields['policeStation']!,
              talukaCtrl: _fields['taluka']!,
              districtCtrl: _fields['district']!,
              noticeDateCtrl: _fields['noticeDate']!,
              toNameAddressCtrl: _fields['accusedNameAddress']!,
            ),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'CR No.', marathiLabel: 'गु.र.क्र.', controller: _fields['crNo']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Section', marathiLabel: 'कलम', controller: _fields['section']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            BilingualMultilineField(
              label: 'Subject',
              marathiLabel: 'विषय',
              controller: _fields['subject']!,
              minLines: 2,
              serifStyle: serif,
              marathiLabelStyle: marathi,
            ),
            BilingualMultilineField(
              label: 'Notice body',
              marathiLabel: 'सूचनेचा मजकूर',
              controller: _fields['noticeBody']!,
              minLines: 10,
              serifStyle: serif,
              marathiLabelStyle: marathi,
            ),
            const SizedBox(height: 16),
            FormAccusedIoSignatureRow(
              accusedSigCtrl: _fields['accusedSig']!,
              accusedNameCtrl: _fields['accusedNameAddress']!,
              accusedDateCtrl: _fields['accusedDate']!,
              ioNameCtrl: _fields['ioName']!,
              ioRankCtrl: _fields['ioRank']!,
              ioNoCtrl: _fields['ioNo']!,
              ioPostingCtrl: _fields['ioPosting']!,
              serifStyle: serif,
              marathiLabelStyle: marathi,
            ),
            const SizedBox(height: 16),
            FormMrwFooter(serifStyle: serif),
          ],
        ),
      ],
    );
  }
}
