import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import 'form_controller_utils.dart';
import 'form_io_signature_block.dart';
import 'form_paper_page.dart';
import 'form_signature_helpers.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';

/// §8 Further Panchanama (compendium page 28) — ends at I.O. signature.
class PanchanamaContinuationFormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const PanchanamaContinuationFormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<PanchanamaContinuationFormView> createState() =>
      PanchanamaContinuationFormViewState();
}

class PanchanamaContinuationFormViewState
    extends State<PanchanamaContinuationFormView> {
  late final Map<String, TextEditingController> _fields;

  @override
  void initState() {
    super.initState();
    _fields = {
      'dist': TextEditingController(),
      'ps': TextEditingController(),
      'firNo': TextEditingController(),
      'firYearSuffix': TextEditingController(
        text: DateTime.now().year.toString().substring(2),
      ),
      'headerDate': TextEditingController(),
      'furtherPanchanama': TextEditingController(),
      'furtherDate': TextEditingController(),
      'furtherTimeFrom': TextEditingController(),
      'furtherTimeTo': TextEditingController(),
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
                  Text(
                    '8) Details of Further Panchanama',
                    style: serif.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'पंचनाम्याचा पुढील भाग',
                    style: marathi.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'District', marathiLabel: 'जिल्हा', controller: _fields['dist']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'P.S.', marathiLabel: 'पोलीस स्टेशन', controller: _fields['ps']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'FIR No.', marathiLabel: 'पहिली खबर क्र.', controller: _fields['firNo']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Date', marathiLabel: 'दिनांक', controller: _fields['headerDate']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            const SizedBox(height: 12),
            BilingualMultilineField(
              label: 'Further Panchanama details',
              marathiLabel: 'पंचनाम्याचा पुढील भाग',
              controller: _fields['furtherPanchanama']!,
              minLines: 18,
              serifStyle: serif,
              marathiLabelStyle: marathi,
            ),
            BilingualFieldRow(
              fields: [
                BilingualField(label: 'Date', marathiLabel: 'तारीख', controller: _fields['furtherDate']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'Time from', marathiLabel: 'वेळ', controller: _fields['furtherTimeFrom']!, serifStyle: serif, marathiLabelStyle: marathi),
                BilingualField(label: 'To', marathiLabel: 'ते', controller: _fields['furtherTimeTo']!, serifStyle: serif, marathiLabelStyle: marathi),
              ],
            ),
            const SizedBox(height: 20),
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
