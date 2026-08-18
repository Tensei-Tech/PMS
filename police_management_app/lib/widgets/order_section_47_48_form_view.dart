import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import 'form_controller_utils.dart';
import 'form_paper_page.dart';
import 'form_section_utils.dart';
import 'form_signature_helpers.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';

class OrderSection4748FormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const OrderSection4748FormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<OrderSection4748FormView> createState() => OrderSection4748FormViewState();
}

class OrderSection4748FormViewState extends State<OrderSection4748FormView> {
  static const kOrderMain = 'Order Main';
  static const kNotice47 = 'Notice BNSS 47(1)';
  static const kNotice48 = 'Notice BNSS 48';
  static const _knownSectionIds = {kOrderMain, kNotice47, kNotice48};

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
      'orderNo': TextEditingController(),
      'orderDate': TextEditingController(),
      'policeStation': TextEditingController(),
      'taluka': TextEditingController(),
      'district': TextEditingController(),
      'accusedName': TextEditingController(),
      'crNo': TextEditingController(),
      'section': TextEditingController(),
      'orderBody': TextEditingController(),
      'shoName': TextEditingController(),
      'shoRank': TextEditingController(),
      'shoPs': TextEditingController(),
      'n47OutwardNo': TextEditingController(),
      'n47OutwardYear': TextEditingController(text: '2025'),
      'n47Date': TextEditingController(),
      'n47To': TextEditingController(),
      'n47Subject': TextEditingController(),
      'n47Body': TextEditingController(),
      'n47AccusedSig': TextEditingController(),
      'n47AccusedName': TextEditingController(),
      'n47AccusedDate': TextEditingController(),
      'n47IoName': TextEditingController(),
      'n47IoRank': TextEditingController(),
      'n47IoNo': TextEditingController(),
      'n47IoPosting': TextEditingController(),
      'n48OutwardNo': TextEditingController(),
      'n48OutwardYear': TextEditingController(text: '2025'),
      'n48Date': TextEditingController(),
      'n48To': TextEditingController(),
      'n48Subject': TextEditingController(),
      'n48Body': TextEditingController(),
      'n48RelativeSig': TextEditingController(),
      'n48RelativeName': TextEditingController(),
      'n48RelativeDate': TextEditingController(),
      'n48IoName': TextEditingController(),
      'n48IoRank': TextEditingController(),
      'n48IoNo': TextEditingController(),
      'n48IoPosting': TextEditingController(),
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

  Widget _buildOrderMain(TextStyle serif, TextStyle marathi) {
    return FormPaperPage(
      formLabel: widget.pageRange,
      children: [
        Center(
          child: Column(
            children: [
              Text('ORDER — Sections 47 & 48 BNSS', style: serif.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('आदेश — कलम ४७ व ४८ भा.न्या.स.', style: marathi.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BilingualFieldRow(
          fields: [
            BilingualField(label: 'Order No.', marathiLabel: 'आदेश क्र.', controller: _fields['orderNo']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualField(label: 'Date', marathiLabel: 'दिनांक', controller: _fields['orderDate']!, serifStyle: serif, marathiLabelStyle: marathi),
          ],
        ),
        BilingualField(label: 'Police Station', marathiLabel: 'पोलीस स्टेशन', controller: _fields['policeStation']!, serifStyle: serif, marathiLabelStyle: marathi),
        BilingualFieldRow(
          fields: [
            BilingualField(label: 'Taluka', marathiLabel: 'ता.', controller: _fields['taluka']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualField(label: 'District', marathiLabel: 'जिल्हा', controller: _fields['district']!, serifStyle: serif, marathiLabelStyle: marathi),
          ],
        ),
        BilingualField(label: 'Accused name', marathiLabel: 'आरोपीचे नाव', controller: _fields['accusedName']!, serifStyle: serif, marathiLabelStyle: marathi),
        BilingualFieldRow(
          fields: [
            BilingualField(label: 'CR No.', marathiLabel: 'गु.र.क्र.', controller: _fields['crNo']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualField(label: 'Section', marathiLabel: 'कलम', controller: _fields['section']!, serifStyle: serif, marathiLabelStyle: marathi),
          ],
        ),
        const SizedBox(height: 12),
        BilingualMultilineField(
          label: 'Order details',
          marathiLabel: 'आदेशाचा तपशील',
          controller: _fields['orderBody']!,
          minLines: 12,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        const SizedBox(height: 24),
        FormShoSignatureBlock(
          nameCtrl: _fields['shoName']!,
          rankCtrl: _fields['shoRank']!,
          psCtrl: _fields['shoPs']!,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        const SizedBox(height: 16),
        FormMrwFooter(serifStyle: serif),
      ],
    );
  }

  Widget _buildNotice47(TextStyle serif, TextStyle marathi) {
    return FormPaperPage(
      formLabel: widget.pageRange,
      children: [
        Center(
          child: Column(
            children: [
              Text('NOTICE u/s 47(1) BNSS', style: serif.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('सूचनापत्र — कलम ४७(१) भा.न्या.स.', style: marathi.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        buildNoticeHeaderFields(
          serif: serif,
          marathiLabel: marathi,
          outwardNoCtrl: _fields['n47OutwardNo']!,
          outwardYearCtrl: _fields['n47OutwardYear']!,
          policeStationCtrl: _fields['policeStation']!,
          talukaCtrl: _fields['taluka']!,
          districtCtrl: _fields['district']!,
          noticeDateCtrl: _fields['n47Date']!,
          toNameAddressCtrl: _fields['n47To']!,
        ),
        BilingualMultilineField(
          label: 'Subject / grounds',
          marathiLabel: 'विषय / आधार',
          controller: _fields['n47Subject']!,
          minLines: 2,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        BilingualMultilineField(
          label: 'Notice body',
          marathiLabel: 'सूचनेचा मजकूर',
          controller: _fields['n47Body']!,
          minLines: 8,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        const SizedBox(height: 16),
        FormAccusedIoSignatureRow(
          accusedSigCtrl: _fields['n47AccusedSig']!,
          accusedNameCtrl: _fields['n47AccusedName']!,
          accusedDateCtrl: _fields['n47AccusedDate']!,
          ioNameCtrl: _fields['n47IoName']!,
          ioRankCtrl: _fields['n47IoRank']!,
          ioNoCtrl: _fields['n47IoNo']!,
          ioPostingCtrl: _fields['n47IoPosting']!,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        const SizedBox(height: 16),
        FormMrwFooter(serifStyle: serif),
      ],
    );
  }

  Widget _buildNotice48(TextStyle serif, TextStyle marathi) {
    return FormPaperPage(
      formLabel: widget.pageRange,
      children: [
        Center(
          child: Column(
            children: [
              Text('NOTICE u/s 48 BNSS', style: serif.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('सूचनापत्र — कलम ४८ भा.न्या.स.', style: marathi.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        buildNoticeHeaderFields(
          serif: serif,
          marathiLabel: marathi,
          outwardNoCtrl: _fields['n48OutwardNo']!,
          outwardYearCtrl: _fields['n48OutwardYear']!,
          policeStationCtrl: _fields['policeStation']!,
          talukaCtrl: _fields['taluka']!,
          districtCtrl: _fields['district']!,
          noticeDateCtrl: _fields['n48Date']!,
          toNameAddressCtrl: _fields['n48To']!,
        ),
        BilingualMultilineField(
          label: 'Subject — intimation of arrest to relative',
          marathiLabel: 'विषय — नातेवाईकास अटकेची सूचना',
          controller: _fields['n48Subject']!,
          minLines: 2,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        BilingualMultilineField(
          label: 'Notice body',
          marathiLabel: 'सूचनेचा मजकूर',
          controller: _fields['n48Body']!,
          minLines: 8,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        const SizedBox(height: 16),
        FormRelativeIoSignatureRow(
          relativeSigCtrl: _fields['n48RelativeSig']!,
          relativeNameCtrl: _fields['n48RelativeName']!,
          relativeDateCtrl: _fields['n48RelativeDate']!,
          ioNameCtrl: _fields['n48IoName']!,
          ioRankCtrl: _fields['n48IoRank']!,
          ioNoCtrl: _fields['n48IoNo']!,
          ioPostingCtrl: _fields['n48IoPosting']!,
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
    if (_shows(kOrderMain)) pages.add(_buildOrderMain(serif, marathi));
    if (_shows(kOrderMain) && (_shows(kNotice47) || _shows(kNotice48))) {
      pages.add(const SizedBox(height: 24));
    }
    if (_shows(kNotice47)) pages.add(_buildNotice47(serif, marathi));
    if (_shows(kNotice47) && _shows(kNotice48)) pages.add(const SizedBox(height: 24));
    if (_shows(kNotice48)) pages.add(_buildNotice48(serif, marathi));
    return FormViewScaffold(readOnly: widget.readOnly, children: pages);
  }
}
