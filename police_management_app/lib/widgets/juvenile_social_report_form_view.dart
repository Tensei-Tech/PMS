import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import 'form_controller_utils.dart';
import 'form_io_signature_block.dart';
import 'form_paper_page.dart';
import 'form_section_utils.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';

/// Juvenile Social Background Report (pages 65–69).
class JuvenileSocialReportFormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const JuvenileSocialReportFormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<JuvenileSocialReportFormView> createState() =>
      JuvenileSocialReportFormViewState();
}

class JuvenileSocialReportFormViewState extends State<JuvenileSocialReportFormView> {
  static const kPartI = 'Juvenile Social Part I';
  static const kPartII = 'Juvenile Social Part II';
  static const kPartIII = 'Juvenile Social Part III';
  static const kPartIV = 'Juvenile Social Part IV';
  static const kPartV = 'Juvenile Social Part V';
  static const _knownSectionIds = {kPartI, kPartII, kPartIII, kPartIV, kPartV};

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
      'reportNo': TextEditingController(),
      'reportDate': TextEditingController(),
      'policeStation': TextEditingController(),
      'crNo': TextEditingController(),
      'section': TextEditingController(),
      'juvenileName': TextEditingController(),
      'juvenileAge': TextEditingController(),
      'juvenileSex': TextEditingController(),
      'juvenileAddress': TextEditingController(),
      'guardianName': TextEditingController(),
      'guardianAddress': TextEditingController(),
      'familyBackground': TextEditingController(),
      'educationDetails': TextEditingController(),
      'economicStatus': TextEditingController(),
      'socialEnvironment': TextEditingController(),
      'previousHistory': TextEditingController(),
      'neighbourhoodReport': TextEditingController(),
      'schoolReport': TextEditingController(),
      'recommendations': TextEditingController(),
      'probationOfficerName': TextEditingController(),
      'probationOfficerSig': TextEditingController(),
      'probationOfficerDate': TextEditingController(),
      'ioName': TextEditingController(),
      'ioRank': TextEditingController(),
      'ioNo': TextEditingController(),
      'ioPosting': TextEditingController(),
      'shoName': TextEditingController(),
      'shoRank': TextEditingController(),
      'shoPs': TextEditingController(),
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

  Widget _partI(TextStyle serif, TextStyle marathi) {
    return FormPaperPage(
      formLabel: widget.pageRange,
      children: [
        Center(
          child: Column(
            children: [
              Text('JUVENILE SOCIAL BACKGROUND REPORT', style: serif.copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
              Text('बालगुन्हेगार सामाजिक पार्श्वभूमी अहवाल', style: marathi.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BilingualFieldRow(
          fields: [
            BilingualField(label: 'Report No.', marathiLabel: 'अहवाल क्र.', controller: _fields['reportNo']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualField(label: 'Date', marathiLabel: 'दिनांक', controller: _fields['reportDate']!, serifStyle: serif, marathiLabelStyle: marathi),
          ],
        ),
        BilingualField(label: 'Police Station', marathiLabel: 'पोलीस स्टेशन', controller: _fields['policeStation']!, serifStyle: serif, marathiLabelStyle: marathi),
        BilingualFieldRow(
          fields: [
            BilingualField(label: 'CR No.', marathiLabel: 'गु.र.क्र.', controller: _fields['crNo']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualField(label: 'Section', marathiLabel: 'कलम', controller: _fields['section']!, serifStyle: serif, marathiLabelStyle: marathi),
          ],
        ),
        BilingualWideField(label: 'Juvenile name & address', marathiLabel: 'बालगुन्हेगाराचे नाव व पत्ता', controller: _fields['juvenileName']!, serifStyle: serif, marathiLabelStyle: marathi),
        BilingualFieldRow(
          fields: [
            BilingualField(label: 'Age', marathiLabel: 'वय', controller: _fields['juvenileAge']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualField(label: 'Sex', marathiLabel: 'लिंग', controller: _fields['juvenileSex']!, serifStyle: serif, marathiLabelStyle: marathi),
          ],
        ),
        BilingualField(label: 'Guardian name', marathiLabel: 'पालकाचे नाव', controller: _fields['guardianName']!, serifStyle: serif, marathiLabelStyle: marathi),
        BilingualWideField(label: 'Guardian address', marathiLabel: 'पालकाचा पत्ता', controller: _fields['guardianAddress']!, serifStyle: serif, marathiLabelStyle: marathi),
      ],
    );
  }

  Widget _partII(TextStyle serif, TextStyle marathi) {
    return FormPaperPage(
      formLabel: widget.pageRange,
      children: [
        BilingualMultilineField(
          label: 'Family background',
          marathiLabel: 'कौटुंबिक पार्श्वभूमी',
          controller: _fields['familyBackground']!,
          minLines: 10,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        BilingualMultilineField(
          label: 'Education details',
          marathiLabel: 'शैक्षणिक तपशील',
          controller: _fields['educationDetails']!,
          minLines: 6,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        BilingualMultilineField(
          label: 'Economic status',
          marathiLabel: 'आर्थिक स्थिती',
          controller: _fields['economicStatus']!,
          minLines: 4,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
      ],
    );
  }

  Widget _partIII(TextStyle serif, TextStyle marathi) {
    return FormPaperPage(
      formLabel: widget.pageRange,
      children: [
        BilingualMultilineField(
          label: 'Social environment',
          marathiLabel: 'सामाजिक वातावरण',
          controller: _fields['socialEnvironment']!,
          minLines: 8,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        BilingualMultilineField(
          label: 'Previous history',
          marathiLabel: 'पूर्व इतिहास',
          controller: _fields['previousHistory']!,
          minLines: 6,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
      ],
    );
  }

  Widget _partIV(TextStyle serif, TextStyle marathi) {
    return FormPaperPage(
      formLabel: widget.pageRange,
      children: [
        BilingualMultilineField(
          label: 'Neighbourhood report',
          marathiLabel: 'शेजारी अहवाल',
          controller: _fields['neighbourhoodReport']!,
          minLines: 6,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        BilingualMultilineField(
          label: 'School report',
          marathiLabel: 'शाळा अहवाल',
          controller: _fields['schoolReport']!,
          minLines: 6,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        BilingualMultilineField(
          label: 'Recommendations',
          marathiLabel: 'शिफारसी',
          controller: _fields['recommendations']!,
          minLines: 6,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
      ],
    );
  }

  Widget _partV(TextStyle serif, TextStyle marathi) {
    return FormPaperPage(
      formLabel: widget.pageRange,
      children: [
        BilingualSectionHeader(
          label: 'Probation Officer / Social Worker',
          marathiLabel: 'प्रबेशन अधिकारी / समाजसेवक',
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(label: 'Name', marathiLabel: 'नाव', controller: _fields['probationOfficerName']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualField(label: 'Date', marathiLabel: 'दिनांक', controller: _fields['probationOfficerDate']!, serifStyle: serif, marathiLabelStyle: marathi),
          ],
        ),
        BilingualField(label: 'Signature', marathiLabel: 'सही', controller: _fields['probationOfficerSig']!, serifStyle: serif, marathiLabelStyle: marathi),
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
          label: 'Station House Officer',
          marathiLabel: 'पोलीस ठाणेदार',
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(label: 'Name', marathiLabel: 'नाव', controller: _fields['shoName']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualField(label: 'Rank', marathiLabel: 'पद', controller: _fields['shoRank']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualField(label: 'P.S.', marathiLabel: 'पोलीस स्टेशन', controller: _fields['shoPs']!, serifStyle: serif, marathiLabelStyle: marathi),
          ],
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
    final parts = <(String, Widget Function(TextStyle, TextStyle))>[
      (kPartI, _partI),
      (kPartII, _partII),
      (kPartIII, _partIII),
      (kPartIV, _partIV),
      (kPartV, _partV),
    ];
    final pages = <Widget>[];
    for (var i = 0; i < parts.length; i++) {
      final (id, builder) = parts[i];
      if (!_shows(id)) continue;
      if (pages.isNotEmpty) pages.add(const SizedBox(height: 24));
      pages.add(builder(serif, marathi));
    }
    return FormViewScaffold(readOnly: widget.readOnly, children: pages);
  }
}
