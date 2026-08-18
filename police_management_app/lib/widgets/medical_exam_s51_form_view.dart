import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import 'form_controller_utils.dart';
import 'form_io_signature_block.dart';
import 'form_paper_page.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';

/// Medical Examination Request u/s 51 BNSS (page 33).
class MedicalExamS51FormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const MedicalExamS51FormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<MedicalExamS51FormView> createState() => MedicalExamS51FormViewState();
}

class MedicalExamS51FormViewState extends State<MedicalExamS51FormView> {
  late final Map<String, TextEditingController> _fields;

  @override
  void initState() {
    super.initState();
    _fields = {
      'letterNo': TextEditingController(),
      'date': TextEditingController(),
      'policeStation': TextEditingController(),
      'crNo': TextEditingController(),
      'section': TextEditingController(),
      'toHospital': TextEditingController(),
      'toDoctor': TextEditingController(),
      'accusedName': TextEditingController(),
      'accusedAge': TextEditingController(),
      'accusedSex': TextEditingController(),
      'accusedAddress': TextEditingController(),
      'arrestDate': TextEditingController(),
      'requestBody': TextEditingController(),
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
                  Text('MEDICAL EXAMINATION REQUEST — Section 51 BNSS', style: serif.copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('वैद्यकीय तपासणी विनंती — कलम ५१ भा.न्या.स.', style: marathi.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Letter No.', marathiLabel: 'पत्र क्र.', controller: _fields['letterNo']!, serifStyle: serif, marathiLabelStyle: marathi),
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
            BilingualField(label: 'To — Hospital', marathiLabel: 'प्रति — रुग्णालय', controller: _fields['toHospital']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualField(label: 'Medical Officer', marathiLabel: 'वैद्यकीय अधिकारी', controller: _fields['toDoctor']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualWideField(label: 'Accused name & address', marathiLabel: 'आरोपीचे नाव व पत्ता', controller: _fields['accusedName']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Age', marathiLabel: 'वय', controller: _fields['accusedAge']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Sex', marathiLabel: 'लिंग', controller: _fields['accusedSex']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            BilingualField(label: 'Arrest date', marathiLabel: 'अटक दिनांक', controller: _fields['arrestDate']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualMultilineField(
              label: 'Request details',
              marathiLabel: 'विनंती तपशील',
              controller: _fields['requestBody']!,
              minLines: 8,
              serifStyle: serif,
              marathiLabelStyle: marathi,
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
