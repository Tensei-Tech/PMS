import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bilingual_field.dart';
import 'form_paper_page.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';
import 'responsive_field_row.dart';

class CrimespotSeizureFormView extends StatefulWidget {
  final bool readOnly;
  const CrimespotSeizureFormView({super.key, this.readOnly = false});

  @override
  State<CrimespotSeizureFormView> createState() =>
      CrimespotSeizureFormViewState();
}

class CrimespotSeizureFormViewState extends State<CrimespotSeizureFormView> {
  // --- Controllers ---
  final _campNoCtrl = TextEditingController();
  final _dateDayCtrl = TextEditingController();
  final _dateMonthCtrl = TextEditingController();
  final _dateYearCtrl = TextEditingController(
      text: DateTime.now().year.toString().substring(2));
  final _panch1NameCtrl = TextEditingController();
  final _panch2NameCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _ioNameCtrl = TextEditingController();
  final _panchSig1Ctrl = TextEditingController();
  final _panchSig2Ctrl = TextEditingController();

  @override
  void dispose() {
    _campNoCtrl.dispose();
    _dateDayCtrl.dispose();
    _dateMonthCtrl.dispose();
    _dateYearCtrl.dispose();
    _panch1NameCtrl.dispose();
    _panch2NameCtrl.dispose();
    _bodyCtrl.dispose();
    _ioNameCtrl.dispose();
    _panchSig1Ctrl.dispose();
    _panchSig2Ctrl.dispose();
    super.dispose();
  }

  /// Collects the current state of all form inputs into a Map.
  Map<String, dynamic> collectData() {
    return {
      'campNo': _campNoCtrl.text.trim(),
      'dateDay': _dateDayCtrl.text.trim(),
      'dateMonth': _dateMonthCtrl.text.trim(),
      'dateYear': _dateYearCtrl.text.trim(),
      'panch1Name': _panch1NameCtrl.text.trim(),
      'panch2Name': _panch2NameCtrl.text.trim(),
      'body': _bodyCtrl.text.trim(),
      'ioName': _ioNameCtrl.text.trim(),
      'panchSig1': _panchSig1Ctrl.text.trim(),
      'panchSig2': _panchSig2Ctrl.text.trim(),
    };
  }

  /// Hydrates the form controllers from an existing database map.
  void hydrateFrom(Map<String, dynamic> data) {
    setState(() {
      _campNoCtrl.text = data['campNo']?.toString() ?? '';
      _dateDayCtrl.text = data['dateDay']?.toString() ?? '';
      _dateMonthCtrl.text = data['dateMonth']?.toString() ?? '';
      _dateYearCtrl.text = data['dateYear']?.toString() ?? '';
      _panch1NameCtrl.text = data['panch1Name']?.toString() ?? '';
      _panch2NameCtrl.text = data['panch2Name']?.toString() ?? '';
      _bodyCtrl.text = data['body']?.toString() ?? '';
      _ioNameCtrl.text = data['ioName']?.toString() ?? '';
      _panchSig1Ctrl.text = data['panchSig1']?.toString() ?? '';
      _panchSig2Ctrl.text = data['panchSig2']?.toString() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle serifStyle = FormTypography.serifStyle();
    final TextStyle marathiLabelStyle = FormTypography.marathiLabelStyle();

    return FormViewScaffold(
      readOnly: widget.readOnly,
      children: [
        FormPaperPage(
          children: [
            // --- FORM HEADER & TOP RIGHT ---
            ResponsiveFieldRow(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 2, child: SizedBox()), // Spacer left
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Text(
                      'घटनास्थळ जप्ती पंचनामा',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveFieldRow(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('कंप :', style: marathiLabelStyle.copyWith(fontSize: 12)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: BilingualSimpleUnderlineInput(
                              controller: _campNoCtrl,
                              serifStyle: serifStyle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('दिनांक :- ', style: marathiLabelStyle.copyWith(fontSize: 12)),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 35,
                            child: BilingualSimpleUnderlineInput(
                              controller: _dateDayCtrl,
                              serifStyle: serifStyle,
                            ),
                          ),
                          Text(' / ', style: serifStyle),
                          SizedBox(
                            width: 35,
                            child: BilingualSimpleUnderlineInput(
                              controller: _dateMonthCtrl,
                              serifStyle: serifStyle,
                            ),
                          ),
                          Text(' / २०', style: marathiLabelStyle.copyWith(fontSize: 12)),
                          SizedBox(
                            width: 35,
                            child: BilingualSimpleUnderlineInput(
                              controller: _dateYearCtrl,
                              serifStyle: serifStyle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- PANCH NAMES ---
            ResponsiveFieldRow(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 12),
                  child: Text('पंच नांव', style: marathiLabelStyle.copyWith(fontSize: 12)),
                ),
                Expanded(
                  child: Column(
                    children: [
                      ResponsiveFieldRow(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(': १)', style: marathiLabelStyle.copyWith(fontSize: 12)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: BilingualSimpleUnderlineInput(
                              controller: _panch1NameCtrl,
                              serifStyle: serifStyle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ResponsiveFieldRow(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('  २)', style: marathiLabelStyle.copyWith(fontSize: 12)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: BilingualSimpleUnderlineInput(
                              controller: _panch2NameCtrl,
                              serifStyle: serifStyle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- PANCHANAMA BODY ---
            BilingualDynamicLinedTextField(
              controller: _bodyCtrl,
              minLines: 45, // Increased to natively stretch the container to A4 proportions
              serifStyle: serifStyle,
            ),
            const SizedBox(height: 32),

            // --- SIGNATURE BLOCK ---
            const SizedBox(height: 16),
            ResponsiveFieldRow(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Investigating Officer
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('तपासी अंमलदार', style: marathiLabelStyle.copyWith(fontSize: 12)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 200,
                        child: BilingualSimpleUnderlineInput(
                          controller: _ioNameCtrl,
                          serifStyle: serifStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                // Right: Panch Signatures
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveFieldRow(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('पंच सही :- १) ', style: marathiLabelStyle.copyWith(fontSize: 12)),
                          Expanded(
                            child: BilingualSimpleUnderlineInput(
                              controller: _panchSig1Ctrl,
                              serifStyle: serifStyle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ResponsiveFieldRow(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('              २) ', style: marathiLabelStyle.copyWith(fontSize: 12)),
                          Expanded(
                            child: BilingualSimpleUnderlineInput(
                              controller: _panchSig2Ctrl,
                              serifStyle: serifStyle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- FOOTER ---
            FormMrwFooter(serifStyle: serifStyle),
          ],
        ),
      ],
    );
  }
}
