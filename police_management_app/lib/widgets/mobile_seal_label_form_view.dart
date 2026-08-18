import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import 'form_controller_utils.dart';
import 'form_io_signature_block.dart';
import 'form_paper_page.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';

/// Mobile seal label (page 46).
class MobileSealLabelFormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const MobileSealLabelFormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<MobileSealLabelFormView> createState() => MobileSealLabelFormViewState();
}

class MobileSealLabelFormViewState extends State<MobileSealLabelFormView> {
  late final Map<String, TextEditingController> _fields;

  @override
  void initState() {
    super.initState();
    _fields = {
      'labelNo': TextEditingController(),
      'date': TextEditingController(),
      'policeStation': TextEditingController(),
      'crNo': TextEditingController(),
      'section': TextEditingController(),
      'mobileMake': TextEditingController(),
      'mobileModel': TextEditingController(),
      'imei1': TextEditingController(),
      'imei2': TextEditingController(),
      'simNo': TextEditingController(),
      'seizedFrom': TextEditingController(),
      'seizedDate': TextEditingController(),
      'remarks': TextEditingController(),
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
                  Text('MOBILE SEAL LABEL', style: serif.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('मोबाईल शिक्का लेबल', style: marathi.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Label No.', marathiLabel: 'लेबल क्र.', controller: _fields['labelNo']!, serifStyle: serif, marathiLabelStyle: marathi),
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
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Make', marathiLabel: 'कंपनी', controller: _fields['mobileMake']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Model', marathiLabel: 'मॉडेल', controller: _fields['mobileModel']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'IMEI 1', marathiLabel: 'IMEI १', controller: _fields['imei1']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'IMEI 2', marathiLabel: 'IMEI २', controller: _fields['imei2']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            BilingualField(label: 'SIM No.', marathiLabel: 'SIM क्र.', controller: _fields['simNo']!, serifStyle: serif, marathiLabelStyle: marathi),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Seized from', marathiLabel: 'जप्त केले', controller: _fields['seizedFrom']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Seized date', marathiLabel: 'जप्त दिनांक', controller: _fields['seizedDate']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            BilingualMultilineField(
              label: 'Remarks',
              marathiLabel: 'शेरा',
              controller: _fields['remarks']!,
              minLines: 3,
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
