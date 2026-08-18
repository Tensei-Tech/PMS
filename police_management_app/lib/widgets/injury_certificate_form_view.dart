import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import 'form_controller_utils.dart';
import 'form_paper_page.dart';
import 'form_signature_helpers.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';

/// Injury Certificate (page 31) — ends at Medical Officer signature.
class InjuryCertificateFormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const InjuryCertificateFormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<InjuryCertificateFormView> createState() =>
      InjuryCertificateFormViewState();
}

class InjuryCertificateFormViewState extends State<InjuryCertificateFormView> {
  late final Map<String, TextEditingController> _fields;

  @override
  void initState() {
    super.initState();
    _fields = {
      'certificateNo': TextEditingController(),
      'date': TextEditingController(),
      'hospital': TextEditingController(),
      'patientName': TextEditingController(),
      'patientAge': TextEditingController(),
      'patientSex': TextEditingController(),
      'patientAddress': TextEditingController(),
      'broughtBy': TextEditingController(),
      'examDateTime': TextEditingController(),
      'injuryDescription': TextEditingController(),
      'weaponUsed': TextEditingController(),
      'opinion': TextEditingController(),
      'moName': TextEditingController(),
      'moDesignation': TextEditingController(),
      'moHospital': TextEditingController(),
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
                  Text('INJURY CERTIFICATE', style: serif.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('जखम प्रमाणपत्र', style: marathi.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Certificate No.', marathiLabel: 'प्रमाणपत्र क्र.', controller: _fields['certificateNo']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Date', marathiLabel: 'दिनांक', controller: _fields['date']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            BilingualField(label: 'Hospital', marathiLabel: 'रुग्णालय', controller: _fields['hospital']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualWideField(label: 'Patient name & address', marathiLabel: 'रुग्णाचे नाव व पत्ता', controller: _fields['patientName']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Age', marathiLabel: 'वय', controller: _fields['patientAge']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Sex', marathiLabel: 'लिंग', controller: _fields['patientSex']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            BilingualField(label: 'Brought by', marathiLabel: 'कोणी आणले', controller: _fields['broughtBy']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualField(label: 'Examination date & time', marathiLabel: 'तपासणी दिनांक व वेळ', controller: _fields['examDateTime']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualMultilineField(
              label: 'Description of injuries',
              marathiLabel: 'जखमांचे वर्णन',
              controller: _fields['injuryDescription']!,
              minLines: 8,
              serifStyle: serif,
              marathiLabelStyle: marathi,
            ),
            BilingualField(label: 'Weapon / cause', marathiLabel: 'हत्यार / कारण', controller: _fields['weaponUsed']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualMultilineField(
              label: 'Medical opinion',
              marathiLabel: 'वैद्यकीय मत',
              controller: _fields['opinion']!,
              minLines: 4,
              serifStyle: serif,
              marathiLabelStyle: marathi,
            ),
            const SizedBox(height: 24),
            FormMedicalOfficerSignatureBlock(
              nameCtrl: _fields['moName']!,
              designationCtrl: _fields['moDesignation']!,
              hospitalCtrl: _fields['moHospital']!,
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
