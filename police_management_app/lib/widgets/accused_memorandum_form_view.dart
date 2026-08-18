import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bilingual_field.dart';
import 'form_paper_page.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';
import 'form_io_signature_block.dart';
import 'responsive_field_row.dart';
import 'form_section_utils.dart';

class AccusedMemorandumFormView extends StatefulWidget {
  final bool readOnly;
  final Map<String, dynamic>? existingRecord;
  final String? formSection;
  final String? pageRange;

  const AccusedMemorandumFormView({
    super.key,
    this.readOnly = false,
    this.existingRecord,
    this.formSection,
    this.pageRange,
  });

  @override
  State<AccusedMemorandumFormView> createState() =>
      AccusedMemorandumFormViewState();
}

class AccusedMemorandumFormViewState extends State<AccusedMemorandumFormView> {
  static const kPartI = 'Accused Part I';
  static const kPartII = 'Accused Part II';
  static const _knownSectionIds = {kPartI, kPartII};

  bool _shows(String sectionId) => showsFormSection(
        activeSection: widget.formSection,
        sectionId: sectionId,
        knownSectionIds: _knownSectionIds,
      );

  bool get _showAll => showsAllFormSections(
        activeSection: widget.formSection,
        knownSectionIds: _knownSectionIds,
      );
  // Section 1
  final _distCtrl = TextEditingController();
  final _psCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _firNoCtrl = TextEditingController();
  final _firYearSuffixCtrl = TextEditingController(
    text: DateTime.now().year.toString().substring(2),
  );
  final _headerDateCtrl = TextEditingController();

  // Section 2
  final _accusedNameCtrl = TextEditingController();
  final _accusedAgeCtrl = TextEditingController();
  final _accusedSexCtrl = TextEditingController();

  // Section 3
  final _arrestDateCtrl = TextEditingController();
  final _arrestTimeCtrl = TextEditingController();

  // Section 4
  final _memorandumCtrl = TextEditingController();

  // Section 5
  final _memPlaceCtrl = TextEditingController();
  final _memDateCtrl = TextEditingController();
  final _memTimeFromCtrl = TextEditingController();
  final _memTimeToCtrl = TextEditingController();

  // Section 6 — Panchas (page 2)
  final _panch1Line1Ctrl = TextEditingController();
  final _panch1Line2Ctrl = TextEditingController();
  final _panch2Line1Ctrl = TextEditingController();
  final _panch2Line2Ctrl = TextEditingController();
  final _panch1SigCtrl = TextEditingController();
  final _panch2SigCtrl = TextEditingController();

  // Section 7 — IO (page 2)
  final _ioNameCtrl = TextEditingController();
  final _ioRankCtrl = TextEditingController();
  final _ioNoCtrl = TextEditingController();
  final _ioPostingCtrl = TextEditingController();

  // Section 8
  final _furtherPanchanamaCtrl = TextEditingController();
  final _furtherDateCtrl = TextEditingController();
  final _furtherTimeFromCtrl = TextEditingController();
  final _furtherTimeToCtrl = TextEditingController();

  // Section 9 — Panchas (page 3)
  final _furtherPanch1Line1Ctrl = TextEditingController();
  final _furtherPanch1Line2Ctrl = TextEditingController();
  final _furtherPanch2Line1Ctrl = TextEditingController();
  final _furtherPanch2Line2Ctrl = TextEditingController();
  final _furtherPanch1SigCtrl = TextEditingController();
  final _furtherPanch2SigCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingRecord != null) {
      hydrateFrom(widget.existingRecord!);
    }
  }

  @override
  void dispose() {
    _distCtrl.dispose();
    _psCtrl.dispose();
    _yearCtrl.dispose();
    _firNoCtrl.dispose();
    _firYearSuffixCtrl.dispose();
    _headerDateCtrl.dispose();
    _accusedNameCtrl.dispose();
    _accusedAgeCtrl.dispose();
    _accusedSexCtrl.dispose();
    _arrestDateCtrl.dispose();
    _arrestTimeCtrl.dispose();
    _memorandumCtrl.dispose();
    _memPlaceCtrl.dispose();
    _memDateCtrl.dispose();
    _memTimeFromCtrl.dispose();
    _memTimeToCtrl.dispose();
    _panch1Line1Ctrl.dispose();
    _panch1Line2Ctrl.dispose();
    _panch2Line1Ctrl.dispose();
    _panch2Line2Ctrl.dispose();
    _panch1SigCtrl.dispose();
    _panch2SigCtrl.dispose();
    _ioNameCtrl.dispose();
    _ioRankCtrl.dispose();
    _ioNoCtrl.dispose();
    _ioPostingCtrl.dispose();
    _furtherPanchanamaCtrl.dispose();
    _furtherDateCtrl.dispose();
    _furtherTimeFromCtrl.dispose();
    _furtherTimeToCtrl.dispose();
    _furtherPanch1Line1Ctrl.dispose();
    _furtherPanch1Line2Ctrl.dispose();
    _furtherPanch2Line1Ctrl.dispose();
    _furtherPanch2Line2Ctrl.dispose();
    _furtherPanch1SigCtrl.dispose();
    _furtherPanch2SigCtrl.dispose();
    super.dispose();
  }

  void hydrateFrom(Map<String, dynamic> data) {
    setState(() {
      _distCtrl.text = data['dist']?.toString() ?? '';
      _psCtrl.text = data['ps']?.toString() ?? '';
      _yearCtrl.text = data['year']?.toString() ?? '';
      _firNoCtrl.text = data['firNo']?.toString() ?? '';
      _firYearSuffixCtrl.text = data['firYearSuffix']?.toString() ?? '';
      _headerDateCtrl.text = data['headerDate']?.toString() ?? '';
      _accusedNameCtrl.text = data['accusedName']?.toString() ?? '';
      _accusedAgeCtrl.text = data['accusedAge']?.toString() ?? '';
      _accusedSexCtrl.text = data['accusedSex']?.toString() ?? '';
      _arrestDateCtrl.text = data['arrestDate']?.toString() ?? '';
      _arrestTimeCtrl.text = data['arrestTime']?.toString() ?? '';
      _memorandumCtrl.text = data['memorandum']?.toString() ?? '';
      _memPlaceCtrl.text = data['memPlace']?.toString() ?? '';
      _memDateCtrl.text = data['memDate']?.toString() ?? '';
      _memTimeFromCtrl.text = data['memTimeFrom']?.toString() ?? '';
      _memTimeToCtrl.text = data['memTimeTo']?.toString() ?? '';
      _panch1Line1Ctrl.text = data['panch1Line1']?.toString() ?? '';
      _panch1Line2Ctrl.text = data['panch1Line2']?.toString() ?? '';
      _panch2Line1Ctrl.text = data['panch2Line1']?.toString() ?? '';
      _panch2Line2Ctrl.text = data['panch2Line2']?.toString() ?? '';
      _panch1SigCtrl.text = data['panch1Sig']?.toString() ?? '';
      _panch2SigCtrl.text = data['panch2Sig']?.toString() ?? '';
      _ioNameCtrl.text = data['ioName']?.toString() ?? '';
      _ioRankCtrl.text = data['ioRank']?.toString() ?? '';
      _ioNoCtrl.text = data['ioNo']?.toString() ?? '';
      _ioPostingCtrl.text = data['ioPosting']?.toString() ?? '';
      _furtherPanchanamaCtrl.text = data['furtherPanchanama']?.toString() ?? '';
      _furtherDateCtrl.text = data['furtherDate']?.toString() ?? '';
      _furtherTimeFromCtrl.text = data['furtherTimeFrom']?.toString() ?? '';
      _furtherTimeToCtrl.text = data['furtherTimeTo']?.toString() ?? '';
      _furtherPanch1Line1Ctrl.text = data['furtherPanch1Line1']?.toString() ?? '';
      _furtherPanch1Line2Ctrl.text = data['furtherPanch1Line2']?.toString() ?? '';
      _furtherPanch2Line1Ctrl.text = data['furtherPanch2Line1']?.toString() ?? '';
      _furtherPanch2Line2Ctrl.text = data['furtherPanch2Line2']?.toString() ?? '';
      _furtherPanch1SigCtrl.text = data['furtherPanch1Sig']?.toString() ?? '';
      _furtherPanch2SigCtrl.text = data['furtherPanch2Sig']?.toString() ?? '';
    });
  }

  Map<String, dynamic> collectData() {
    return {
      'dist': _distCtrl.text.trim(),
      'ps': _psCtrl.text.trim(),
      'year': _yearCtrl.text.trim(),
      'firNo': _firNoCtrl.text.trim(),
      'firYearSuffix': _firYearSuffixCtrl.text.trim(),
      'headerDate': _headerDateCtrl.text.trim(),
      'accusedName': _accusedNameCtrl.text.trim(),
      'accusedAge': _accusedAgeCtrl.text.trim(),
      'accusedSex': _accusedSexCtrl.text.trim(),
      'arrestDate': _arrestDateCtrl.text.trim(),
      'arrestTime': _arrestTimeCtrl.text.trim(),
      'memorandum': _memorandumCtrl.text.trim(),
      'memPlace': _memPlaceCtrl.text.trim(),
      'memDate': _memDateCtrl.text.trim(),
      'memTimeFrom': _memTimeFromCtrl.text.trim(),
      'memTimeTo': _memTimeToCtrl.text.trim(),
      'panch1Line1': _panch1Line1Ctrl.text.trim(),
      'panch1Line2': _panch1Line2Ctrl.text.trim(),
      'panch2Line1': _panch2Line1Ctrl.text.trim(),
      'panch2Line2': _panch2Line2Ctrl.text.trim(),
      'panch1Sig': _panch1SigCtrl.text.trim(),
      'panch2Sig': _panch2SigCtrl.text.trim(),
      'ioName': _ioNameCtrl.text.trim(),
      'ioRank': _ioRankCtrl.text.trim(),
      'ioNo': _ioNoCtrl.text.trim(),
      'ioPosting': _ioPostingCtrl.text.trim(),
      'furtherPanchanama': _furtherPanchanamaCtrl.text.trim(),
      'furtherDate': _furtherDateCtrl.text.trim(),
      'furtherTimeFrom': _furtherTimeFromCtrl.text.trim(),
      'furtherTimeTo': _furtherTimeToCtrl.text.trim(),
      'furtherPanch1Line1': _furtherPanch1Line1Ctrl.text.trim(),
      'furtherPanch1Line2': _furtherPanch1Line2Ctrl.text.trim(),
      'furtherPanch2Line1': _furtherPanch2Line1Ctrl.text.trim(),
      'furtherPanch2Line2': _furtherPanch2Line2Ctrl.text.trim(),
      'furtherPanch1Sig': _furtherPanch1SigCtrl.text.trim(),
      'furtherPanch2Sig': _furtherPanch2SigCtrl.text.trim(),
      'formSection': widget.formSection ?? '',
      'pageRange': widget.pageRange ?? '',
    };
  }

  Widget _panchTwoLineEntry({
    required String number,
    required TextEditingController line1,
    required TextEditingController line2,
    required TextStyle serifStyle,
  }) {
    return Column(
      children: [
        BilingualNumberedMethodField(
          number: number,
          controller: line1,
          serifStyle: serifStyle,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: BilingualSimpleUnderlineInput(
            controller: line2,
            serifStyle: serifStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildIoSignatureBlock({
    required TextStyle serifStyle,
    required TextStyle marathiLabelStyle,
  }) {
    return FormIoSignatureBlock(
      nameCtrl: _ioNameCtrl,
      rankCtrl: _ioRankCtrl,
      numberCtrl: _ioNoCtrl,
      postingCtrl: _ioPostingCtrl,
      serifStyle: serifStyle,
      marathiLabelStyle: marathiLabelStyle,
    );
  }

  Widget _buildPanchSignatureSection({
    required TextStyle serifStyle,
    required TextStyle marathiLabelStyle,
    required TextEditingController p1l1,
    required TextEditingController p1l2,
    required TextEditingController p2l1,
    required TextEditingController p2l2,
    required TextEditingController sig1,
    required TextEditingController sig2,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BilingualSectionHeader(
                label: 'Name and Address of Panchas:-',
                marathiLabel: 'पंचाचे नांव व पत्ता',
                serifStyle: serifStyle,
                marathiLabelStyle: marathiLabelStyle,
              ),
              const SizedBox(height: 8),
              _panchTwoLineEntry(
                number: '1',
                line1: p1l1,
                line2: p1l2,
                serifStyle: serifStyle,
              ),
              const SizedBox(height: 12),
              _panchTwoLineEntry(
                number: '2',
                line1: p2l1,
                line2: p2l2,
                serifStyle: serifStyle,
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BilingualSectionHeader(
                label: 'Signature :-',
                marathiLabel: 'सह्या',
                serifStyle: serifStyle,
                marathiLabelStyle: marathiLabelStyle,
              ),
              const SizedBox(height: 8),
              BilingualNumberedMethodField(
                number: '1',
                controller: sig1,
                serifStyle: serifStyle,
              ),
              const SizedBox(height: 12),
              BilingualNumberedMethodField(
                number: '2',
                controller: sig2,
                serifStyle: serifStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle serifStyle = FormTypography.serifStyle();
    final TextStyle marathiLabelStyle = FormTypography.marathiLabelStyle();

    return FormViewScaffold(
      readOnly: widget.readOnly,
      children: [
        if (_shows(kPartI))
              FormPaperPage(
                formLabel: widget.pageRange ?? 'Page 47',
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Accused Memorandum Form',
                          style: serifStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            decoration: TextDecoration.underline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '(आरोपीचे निवेदन पंचनामा)',
                          style: GoogleFonts.notoSansDevanagari(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '( Panchanama u/s 23 (2) Bhartiya Saksh Adhiniyam, 2023',
                          style: serifStyle.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'कलम २३ (२) भारतीय साक्ष अधिनियम २०२३ )',
                          style: marathiLabelStyle.copyWith(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1) District / P.S. / Year / FIR / Date
                  ResponsiveFieldRow(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 18,
                        child: BilingualField(
                          label: '1) District: ',
                          marathiLabel: 'जिल्हा',
                          controller: _distCtrl,
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 18,
                        child: BilingualField(
                          label: 'P.S.: ',
                          marathiLabel: 'पोलीस स्टेशन',
                          controller: _psCtrl,
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 10,
                        child: BilingualField(
                          label: 'Year: ',
                          marathiLabel: 'वर्ष',
                          controller: _yearCtrl,
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 22,
                        child: ResponsiveFieldRow(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: BilingualField(
                                label: 'FIR No: ',
                                marathiLabel: 'पहिली खबर क्र.',
                                controller: _firNoCtrl,
                                serifStyle: serifStyle,
                                marathiLabelStyle: marathiLabelStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2, left: 2, right: 2),
                              child: Text('/20', style: serifStyle),
                            ),
                            SizedBox(
                              width: 35,
                              child: BilingualSimpleUnderlineInput(
                                controller: _firYearSuffixCtrl,
                                serifStyle: serifStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 18,
                        child: BilingualField(
                          label: 'Date: ',
                          marathiLabel: 'तारीख',
                          controller: _headerDateCtrl,
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2) Accused name / age / sex
                  BilingualWideField(
                    label: '2) Name Of Accused: ',
                    marathiLabel: 'आरोपीचे नांव व पत्ता',
                    controller: _accusedNameCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualFieldRow(
                    fields: [
                      BilingualField(
                        label: 'Age: ',
                        marathiLabel: 'वय',
                        controller: _accusedAgeCtrl,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      BilingualField(
                        label: 'Sex: ',
                        marathiLabel: 'लिंग',
                        controller: _accusedSexCtrl,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3) Arrest date/time
                  BilingualSectionHeader(
                    label: '3) Date and Time of Arrest :-',
                    marathiLabel: 'अटकेची तारीख व वेळ',
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 8),
                  BilingualFieldRow(
                    fields: [
                      BilingualField(
                        label: 'Date: ',
                        marathiLabel: 'तारीख',
                        controller: _arrestDateCtrl,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      BilingualField(
                        label: 'Time: ',
                        marathiLabel: 'वेळ',
                        controller: _arrestTimeCtrl,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 4) Memorandum
                  BilingualMultilineField(
                    label: '4) Memorandum made by Accused :-',
                    marathiLabel: 'आरोपीने केलेले निवेदन',
                    controller: _memorandumCtrl,
                    minLines: 18,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 20),

                  // 5) Place / date / time
                  BilingualWideField(
                    label: '5) Place of Memorandum: ',
                    marathiLabel: 'पंचनाम्याचे ठिकाण',
                    controller: _memPlaceCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualFieldRow(
                    fields: [
                      BilingualField(
                        label: 'Date: ',
                        marathiLabel: 'तारीख',
                        controller: _memDateCtrl,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      BilingualField(
                        label: 'Time: ',
                        marathiLabel: 'वेळ',
                        controller: _memTimeFromCtrl,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      BilingualField(
                        label: 'To: ',
                        marathiLabel: 'ते',
                        controller: _memTimeToCtrl,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 6) Panchas
                  BilingualSectionHeader(
                    label: '6)',
                    marathiLabel: 'पंच व सह्या',
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 8),
                  _buildPanchSignatureSection(
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                    p1l1: _panch1Line1Ctrl,
                    p1l2: _panch1Line2Ctrl,
                    p2l1: _panch2Line1Ctrl,
                    p2l2: _panch2Line2Ctrl,
                    sig1: _panch1SigCtrl,
                    sig2: _panch2SigCtrl,
                  ),
                  const SizedBox(height: 24),

                  // 7) Accused sig + IO
                  BilingualSectionHeader(
                    label: '7)',
                    marathiLabel: 'सही',
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: BilingualSectionHeader(
                          label: 'Accused Signature and Thump',
                          marathiLabel: 'आरोपीची सही व अंगठा',
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(child: _buildIoSignatureBlock(
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FormMrwFooter(serifStyle: serifStyle),
                ],
              ),
        if (_shows(kPartI) && (_shows(kPartII) || _showAll))
              const SizedBox(height: 24),

        if (_shows(kPartII))
              FormPaperPage(
                formLabel: widget.pageRange ?? 'Page 48',
                children: [
                  BilingualMultilineField(
                    label: '8) Details of Further Panchanama:-',
                    marathiLabel: 'पंचनाम्याचा पुढील भाग',
                    controller: _furtherPanchanamaCtrl,
                    minLines: 18,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualFieldRow(
                    fields: [
                      BilingualField(
                        label: 'Date: ',
                        marathiLabel: 'तारीख',
                        controller: _furtherDateCtrl,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      BilingualField(
                        label: 'Time: ',
                        marathiLabel: 'वेळ',
                        controller: _furtherTimeFromCtrl,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      BilingualField(
                        label: 'To: ',
                        marathiLabel: 'ते',
                        controller: _furtherTimeToCtrl,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 9) Panchas
                  BilingualSectionHeader(
                    label: '9)',
                    marathiLabel: 'पंच व सह्या',
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 8),
                  _buildPanchSignatureSection(
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                    p1l1: _furtherPanch1Line1Ctrl,
                    p1l2: _furtherPanch1Line2Ctrl,
                    p2l1: _furtherPanch2Line1Ctrl,
                    p2l2: _furtherPanch2Line2Ctrl,
                    sig1: _furtherPanch1SigCtrl,
                    sig2: _furtherPanch2SigCtrl,
                  ),
                  const SizedBox(height: 24),

                  // 10) Accused sig + IO
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BilingualSectionHeader(
                              label: '10) Accused Signature and Thump',
                              marathiLabel: 'आरोपीची सही व अंगठा',
                              serifStyle: serifStyle,
                              marathiLabelStyle: marathiLabelStyle,
                            ),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(child: _buildIoSignatureBlock(
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FormMrwFooter(serifStyle: serifStyle),
                ],
              ),
            ],
    );
  }
}
