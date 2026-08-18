import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import 'form_controller_utils.dart';
import 'form_io_signature_block.dart';
import 'form_paper_page.dart';
import 'form_signature_helpers.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';

/// Panch Notice u/s 179 or 189 BNSS - I.O. signature + receipt acknowledgement.
class BnssPanchNoticeFormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;
  final String? initialNoticeType;

  const BnssPanchNoticeFormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
    this.initialNoticeType,
  });

  @override
  State<BnssPanchNoticeFormView> createState() => BnssPanchNoticeFormViewState();
}

class BnssPanchNoticeFormViewState extends State<BnssPanchNoticeFormView> {
  String get _effectiveNoticeType {
    final fromSection = widget.formSection?.trim() ?? '';
    if (fromSection.contains('189')) return '189';
    if (fromSection.contains('179')) return '179';
    return widget.initialNoticeType?.trim() ?? '179';
  }

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
      'toNameAddress': TextEditingController(),
      'crNo': TextEditingController(),
      'section': TextEditingController(),
      'subject': TextEditingController(),
      'noticeBody': TextEditingController(),
      'appearanceDate': TextEditingController(),
      'appearanceTime': TextEditingController(),
      'appearancePlace': TextEditingController(),
      'ioName': TextEditingController(),
      'ioRank': TextEditingController(),
      'ioNo': TextEditingController(),
      'ioPosting': TextEditingController(),
      'receiptName': TextEditingController(),
      'receiptDate': TextEditingController(),
      'receiptSig': TextEditingController(),
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
      'noticeType': _effectiveNoticeType,
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
    final section = _effectiveNoticeType == '189' ? '189' : '179';

    return FormViewScaffold(
      readOnly: widget.readOnly,
      children: [
        FormPaperPage(
          formLabel: widget.pageRange,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'PANCH NOTICE — Section $section BNSS',
                    style: serif.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'पंच सूचनापत्र — कलम $section भा.न्या.स.',
                    style: marathi.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
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
              toNameAddressCtrl: _fields['toNameAddress']!,
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
              minLines: 8,
              serifStyle: serif,
              marathiLabelStyle: marathi,
            ),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Appearance date', marathiLabel: 'हजर दिनांक', controller: _fields['appearanceDate']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Time', marathiLabel: 'वेळ', controller: _fields['appearanceTime']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            BilingualField(label: 'Place', marathiLabel: 'ठिकाण', controller: _fields['appearancePlace']!, serifStyle: serif, marathiLabelStyle: marathi),
            const SizedBox(height: 16),
            FormIoSignatureBlock(
              nameCtrl: _fields['ioName']!,
              rankCtrl: _fields['ioRank']!,
              numberCtrl: _fields['ioNo']!,
              postingCtrl: _fields['ioPosting']!,
              serifStyle: serif,
              marathiLabelStyle: marathi,
            ),
            const SizedBox(height: 16),
            BilingualSectionHeader(
              label: 'Receipt / acknowledgement',
              marathiLabel: 'पोच पावती',
              serifStyle: serif,
              marathiLabelStyle: marathi,
            ),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Received by', marathiLabel: 'प्राप्तकर्ता', controller: _fields['receiptName']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Date', marathiLabel: 'दिनांक', controller: _fields['receiptDate']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            BilingualField(label: 'Signature', marathiLabel: 'सही', controller: _fields['receiptSig']!, serifStyle: serif, marathiLabelStyle: marathi),
            const SizedBox(height: 16),
            FormMrwFooter(serifStyle: serif),
          ],
        ),
      ],
    );
  }
}
