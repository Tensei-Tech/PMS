import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import 'form_controller_utils.dart';
import 'form_paper_page.dart';
import 'form_section_utils.dart';
import 'form_signature_helpers.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';

/// Notice u/s 35(3) BNSS — pages 40 & 42 (main + continuation).
class NoticeSection35FormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const NoticeSection35FormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<NoticeSection35FormView> createState() => NoticeSection35FormViewState();
}

class NoticeSection35FormViewState extends State<NoticeSection35FormView> {
  static const kMain = 'Notice Section 35 Main';
  static const kContinuation = 'Notice Section 35 Continuation';
  static const _knownSectionIds = {kMain, kContinuation};

  bool _shows(String id) => showsFormSection(
        activeSection: widget.formSection,
        sectionId: id,
        knownSectionIds: _knownSectionIds,
      );

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
      'rightsInfo': TextEditingController(),
      'legalAidInfo': TextEditingController(),
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

  Widget _buildMain(TextStyle serif, TextStyle marathi) {
    return FormPaperPage(
      formLabel: widget.pageRange,
      children: [
        Center(
          child: Column(
            children: [
              Text('NOTICE — Section 35(3) BNSS', style: serif.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('सूचनापत्र — कलम ३५(३) भा.न्या.स.', style: marathi.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
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
          minLines: 10,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
      ],
    );
  }

  Widget _buildContinuation(TextStyle serif, TextStyle marathi) {
    return FormPaperPage(
      formLabel: widget.pageRange,
      children: [
        BilingualMultilineField(
          label: 'Rights of arrested person',
          marathiLabel: 'अटक आरोपीचे हक्क',
          controller: _fields['rightsInfo']!,
          minLines: 8,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        BilingualMultilineField(
          label: 'Legal aid information',
          marathiLabel: 'कायदेशीर मदत माहिती',
          controller: _fields['legalAidInfo']!,
          minLines: 6,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        const SizedBox(height: 16),
        FormAccusedIoSignatureRow(
          accusedSigCtrl: _fields['accusedSig']!,
          accusedNameCtrl: _fields['toNameAddress']!,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final serif = FormTypography.serifStyle();
    final marathi = FormTypography.marathiLabelStyle();
    final pages = <Widget>[];
    if (_shows(kMain)) pages.add(_buildMain(serif, marathi));
    if (_shows(kMain) && _shows(kContinuation)) pages.add(const SizedBox(height: 24));
    if (_shows(kContinuation)) pages.add(_buildContinuation(serif, marathi));
    return FormViewScaffold(readOnly: widget.readOnly, children: pages);
  }
}
