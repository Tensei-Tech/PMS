import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import 'form_controller_utils.dart';
import 'form_io_signature_block.dart';
import 'form_paper_page.dart';
import 'form_signature_helpers.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';

/// Nil House Search Panchanama (page 32).
class NilHouseSearchFormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const NilHouseSearchFormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<NilHouseSearchFormView> createState() => NilHouseSearchFormViewState();
}

class NilHouseSearchFormViewState extends State<NilHouseSearchFormView> {
  late final Map<String, TextEditingController> _fields;

  @override
  void initState() {
    super.initState();
    _fields = {
      'campNo': TextEditingController(),
      'date': TextEditingController(),
      'policeStation': TextEditingController(),
      'crNo': TextEditingController(),
      'section': TextEditingController(),
      'searchAddress': TextEditingController(),
      'ownerName': TextEditingController(),
      'searchBody': TextEditingController(),
      'panch1Line1': TextEditingController(),
      'panch1Line2': TextEditingController(),
      'panch2Line1': TextEditingController(),
      'panch2Line2': TextEditingController(),
      'panch1Sig': TextEditingController(),
      'panch2Sig': TextEditingController(),
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
                  Text('NIL HOUSE SEARCH PANCHANAMA', style: serif.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('घर शोध पंचनामा — निरर्थक', style: marathi.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Camp No.', marathiLabel: 'कंप क्र.', controller: _fields['campNo']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Date', marathiLabel: 'दिनांक', controller: _fields['date']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            BilingualField(label: 'Police Station', marathiLabel: 'पोलीस स्टेशन', controller: _fields['policeStation']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'CR No.', marathiLabel: 'गु.र.क्र.', controller: _fields['crNo']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Section', marathiLabel: 'कलम', controller: _fields['section']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            BilingualWideField(label: 'Search address', marathiLabel: 'शोध घेतलेले ठिकाण', controller: _fields['searchAddress']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualField(label: 'Owner / occupant', marathiLabel: 'मालक / भोगवटादार', controller: _fields['ownerName']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualMultilineField(
              label: 'Panchanama body — nothing found',
              marathiLabel: 'पंचनामा — काही सापडले नाही',
              controller: _fields['searchBody']!,
              minLines: 12,
              serifStyle: serif,
              marathiLabelStyle: marathi,
            ),
            const SizedBox(height: 16),
            buildPanchSignatureSection(
              serifStyle: serif,
              marathiLabelStyle: marathi,
              p1l1: _fields['panch1Line1']!,
              p1l2: _fields['panch1Line2']!,
              p2l1: _fields['panch2Line1']!,
              p2l2: _fields['panch2Line2']!,
              sig1: _fields['panch1Sig']!,
              sig2: _fields['panch2Sig']!,
            ),
            const SizedBox(height: 24),
            FormIoSignatureBlock(
              nameCtrl: _fields['ioName']!,
              rankCtrl: _fields['ioRank']!,
              numberCtrl: _fields['ioNo']!,
              postingCtrl: _fields['ioPosting']!,
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
