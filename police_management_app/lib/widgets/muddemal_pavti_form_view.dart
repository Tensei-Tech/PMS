import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import 'form_controller_utils.dart';
import 'form_io_signature_block.dart';
import 'form_paper_page.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';

/// Muddemal Pavti / property receipt (page 45).
class MuddemalPavtiFormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const MuddemalPavtiFormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<MuddemalPavtiFormView> createState() => MuddemalPavtiFormViewState();
}

class MuddemalPavtiFormViewState extends State<MuddemalPavtiFormView> {
  late final Map<String, TextEditingController> _fields;

  @override
  void initState() {
    super.initState();
    _fields = {
      'receiptNo': TextEditingController(),
      'date': TextEditingController(),
      'policeStation': TextEditingController(),
      'crNo': TextEditingController(),
      'section': TextEditingController(),
      'accusedName': TextEditingController(),
      'propertyDescription': TextEditingController(),
      'propertyValue': TextEditingController(),
      'seizedFrom': TextEditingController(),
      'seizedDate': TextEditingController(),
      'depositedWith': TextEditingController(),
      'witness1': TextEditingController(),
      'witness2': TextEditingController(),
      'receiverName': TextEditingController(),
      'receiverSig': TextEditingController(),
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
                  Text('MUDDEMAL PAVTI', style: serif.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('मुद्देमाल पावती', style: marathi.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Receipt No.', marathiLabel: 'पावती क्र.', controller: _fields['receiptNo']!, serifStyle: serif, marathiLabelStyle: marathi),
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
            BilingualField(label: 'Accused name', marathiLabel: 'आरोपीचे नाव', controller: _fields['accusedName']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualMultilineField(
              label: 'Property description',
              marathiLabel: 'मुद्देमाल वर्णन',
              controller: _fields['propertyDescription']!,
              minLines: 6,
              serifStyle: serif,
              marathiLabelStyle: marathi,
            ),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Value', marathiLabel: 'मूल्य', controller: _fields['propertyValue']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Seized from', marathiLabel: 'जप्त केले', controller: _fields['seizedFrom']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Seized date', marathiLabel: 'जप्त दिनांक', controller: _fields['seizedDate']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Deposited with', marathiLabel: 'सोपवले', controller: _fields['depositedWith']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Witness 1', marathiLabel: 'साक्षी १', controller: _fields['witness1']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Witness 2', marathiLabel: 'साक्षी २', controller: _fields['witness2']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Receiver name', marathiLabel: 'प्राप्तकर्ता', controller: _fields['receiverName']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Signature', marathiLabel: 'सही', controller: _fields['receiverSig']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
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
            FormMrwFooter(serifStyle: serif),
          ],
        ),
      ],
    );
  }
}
