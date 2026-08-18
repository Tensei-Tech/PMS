import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import 'form_paper_page.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';

/// Draft Ground of Arrest — 12-page BNSS reference & notice templates.
class DraftGroundOfArrestFormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const DraftGroundOfArrestFormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<DraftGroundOfArrestFormView> createState() =>
      DraftGroundOfArrestFormViewState();
}

class DraftGroundOfArrestFormViewState extends State<DraftGroundOfArrestFormView> {
  int? get _activeSection {
    final s = widget.formSection?.toLowerCase().trim() ?? '';
    if (s.isEmpty) return null;
    if (s.contains('pcr') || s.contains('police custody')) return 3;
    if (s.contains('reason of arrest') || s.contains('reason for arrest')) {
      return 2;
    }
    if (s.contains('ground of arrest')) return 1;
    return null;
  }

  bool get _showSectionI => _activeSection == null || _activeSection == 1;
  bool get _showSectionII => _activeSection == null || _activeSection == 2;
  bool get _showSectionIII => _activeSection == null || _activeSection == 3;

  // Shared case / accused fields (pages 9–11)
  final _accusedNameCtrl = TextEditingController();
  final _accusedAgeCtrl = TextEditingController();
  final _accusedAddressCtrl = TextEditingController();
  final _psNameCtrl = TextEditingController();
  final _crNoCtrl = TextEditingController();
  final _bnsSectionCtrl = TextEditingController();
  final _arrestDateCtrl = TextEditingController();
  final _arrestTimeCtrl = TextEditingController();
  final _briefFactsCtrl = TextEditingController();

  // Page 9 — Ground of Arrest u/s 47 BNSS
  bool _goaG1 = false;
  bool _goaG2 = false;
  bool _goaG3 = false;
  bool _goaG4 = false;
  bool _goaG5 = false;
  bool _goaG6 = false;
  bool _goaG7 = false;
  final _goaWitnessNameCtrl = TextEditingController();
  final _goaCoAccusedCtrl = TextEditingController();
  final _goaKinNameCtrl = TextEditingController();
  final _goaFooterDateCtrl = TextEditingController();
  final _goaOfficerNameCtrl = TextEditingController();
  final _goaOfficerRankCtrl = TextEditingController();
  final _goaAccusedSigCtrl = TextEditingController();

  // Page 10 — Relative notice u/s 48 BNSS
  final _s48RelativeNameCtrl = TextEditingController();
  final _s48RelativeAgeCtrl = TextEditingController();
  final _s48RelativeAddressCtrl = TextEditingController();
  final _s48RelationshipCtrl = TextEditingController();
  final _s48CustodyPsCtrl = TextEditingController();
  bool _s48G1 = false;
  bool _s48G2 = false;
  bool _s48G3 = false;
  bool _s48G5 = false;
  bool _s48G6 = false;
  final _s48WitnessNameCtrl = TextEditingController();
  final _s48CoAccusedCtrl = TextEditingController();
  final _s48DateCtrl = TextEditingController();
  final _s48PlaceCtrl = TextEditingController();
  final _s48OfficerSigCtrl = TextEditingController();
  final _s48RelativeSigCtrl = TextEditingController();

  // Page 11 — Reason of Arrest u/s 35(1)(b) BNSS
  bool _roaR1 = false;
  bool _roaR2 = false;
  bool _roaR3 = false;
  bool _roaR4 = false;
  bool _roaR5 = false;
  final _roaDateCtrl = TextEditingController();
  final _roaPlaceCtrl = TextEditingController();
  final _roaOfficerSigCtrl = TextEditingController();
  final _roaAccusedSigCtrl = TextEditingController();

  // Page 12 — PCR reasons
  bool _pcr1 = false;
  bool _pcr2 = false;
  bool _pcr3 = false;
  bool _pcr4 = false;
  bool _pcr5 = false;
  bool _pcr6 = false;
  bool _pcr7 = false;
  final _pcrOtherCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _accusedNameCtrl,
      _accusedAgeCtrl,
      _accusedAddressCtrl,
      _psNameCtrl,
      _crNoCtrl,
      _bnsSectionCtrl,
      _arrestDateCtrl,
      _arrestTimeCtrl,
      _briefFactsCtrl,
      _goaWitnessNameCtrl,
      _goaCoAccusedCtrl,
      _goaKinNameCtrl,
      _goaFooterDateCtrl,
      _goaOfficerNameCtrl,
      _goaOfficerRankCtrl,
      _goaAccusedSigCtrl,
      _s48RelativeNameCtrl,
      _s48RelativeAgeCtrl,
      _s48RelativeAddressCtrl,
      _s48RelationshipCtrl,
      _s48CustodyPsCtrl,
      _s48WitnessNameCtrl,
      _s48CoAccusedCtrl,
      _s48DateCtrl,
      _s48PlaceCtrl,
      _s48OfficerSigCtrl,
      _s48RelativeSigCtrl,
      _roaDateCtrl,
      _roaPlaceCtrl,
      _roaOfficerSigCtrl,
      _roaAccusedSigCtrl,
      _pcrOtherCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> collectData() {
    return {
      'formSection': widget.formSection ?? '',
      'pageRange': widget.pageRange ?? '',
      'accusedName': _accusedNameCtrl.text.trim(),
      'accusedAge': _accusedAgeCtrl.text.trim(),
      'accusedAddress': _accusedAddressCtrl.text.trim(),
      'psName': _psNameCtrl.text.trim(),
      'crNo': _crNoCtrl.text.trim(),
      'bnsSection': _bnsSectionCtrl.text.trim(),
      'arrestDate': _arrestDateCtrl.text.trim(),
      'arrestTime': _arrestTimeCtrl.text.trim(),
      'briefFacts': _briefFactsCtrl.text.trim(),
      'goaG1': _goaG1,
      'goaG2': _goaG2,
      'goaG3': _goaG3,
      'goaG4': _goaG4,
      'goaG5': _goaG5,
      'goaG6': _goaG6,
      'goaG7': _goaG7,
      'goaWitnessName': _goaWitnessNameCtrl.text.trim(),
      'goaCoAccused': _goaCoAccusedCtrl.text.trim(),
      'goaKinName': _goaKinNameCtrl.text.trim(),
      'goaFooterDate': _goaFooterDateCtrl.text.trim(),
      'goaOfficerName': _goaOfficerNameCtrl.text.trim(),
      'goaOfficerRank': _goaOfficerRankCtrl.text.trim(),
      'goaAccusedSig': _goaAccusedSigCtrl.text.trim(),
      's48RelativeName': _s48RelativeNameCtrl.text.trim(),
      's48RelativeAge': _s48RelativeAgeCtrl.text.trim(),
      's48RelativeAddress': _s48RelativeAddressCtrl.text.trim(),
      's48Relationship': _s48RelationshipCtrl.text.trim(),
      's48CustodyPs': _s48CustodyPsCtrl.text.trim(),
      's48G1': _s48G1,
      's48G2': _s48G2,
      's48G3': _s48G3,
      's48G5': _s48G5,
      's48G6': _s48G6,
      's48WitnessName': _s48WitnessNameCtrl.text.trim(),
      's48CoAccused': _s48CoAccusedCtrl.text.trim(),
      's48Date': _s48DateCtrl.text.trim(),
      's48Place': _s48PlaceCtrl.text.trim(),
      's48OfficerSig': _s48OfficerSigCtrl.text.trim(),
      's48RelativeSig': _s48RelativeSigCtrl.text.trim(),
      'roaR1': _roaR1,
      'roaR2': _roaR2,
      'roaR3': _roaR3,
      'roaR4': _roaR4,
      'roaR5': _roaR5,
      'roaDate': _roaDateCtrl.text.trim(),
      'roaPlace': _roaPlaceCtrl.text.trim(),
      'roaOfficerSig': _roaOfficerSigCtrl.text.trim(),
      'roaAccusedSig': _roaAccusedSigCtrl.text.trim(),
      'pcr1': _pcr1,
      'pcr2': _pcr2,
      'pcr3': _pcr3,
      'pcr4': _pcr4,
      'pcr5': _pcr5,
      'pcr6': _pcr6,
      'pcr7': _pcr7,
      'pcrOther': _pcrOtherCtrl.text.trim(),
    };
  }

  void hydrateFrom(Map<String, dynamic> data) {
    void setCtrl(TextEditingController c, String key) {
      c.text = data[key]?.toString() ?? '';
    }

    void setBool(void Function(bool) setter, String key) {
      final v = data[key];
      if (v is bool) setter(v);
    }

    setCtrl(_accusedNameCtrl, 'accusedName');
    setCtrl(_accusedAgeCtrl, 'accusedAge');
    setCtrl(_accusedAddressCtrl, 'accusedAddress');
    setCtrl(_psNameCtrl, 'psName');
    setCtrl(_crNoCtrl, 'crNo');
    setCtrl(_bnsSectionCtrl, 'bnsSection');
    setCtrl(_arrestDateCtrl, 'arrestDate');
    setCtrl(_arrestTimeCtrl, 'arrestTime');
    setCtrl(_briefFactsCtrl, 'briefFacts');
    setBool((v) => _goaG1 = v, 'goaG1');
    setBool((v) => _goaG2 = v, 'goaG2');
    setBool((v) => _goaG3 = v, 'goaG3');
    setBool((v) => _goaG4 = v, 'goaG4');
    setBool((v) => _goaG5 = v, 'goaG5');
    setBool((v) => _goaG6 = v, 'goaG6');
    setBool((v) => _goaG7 = v, 'goaG7');
    setCtrl(_goaWitnessNameCtrl, 'goaWitnessName');
    setCtrl(_goaCoAccusedCtrl, 'goaCoAccused');
    setCtrl(_goaKinNameCtrl, 'goaKinName');
    setCtrl(_goaFooterDateCtrl, 'goaFooterDate');
    setCtrl(_goaOfficerNameCtrl, 'goaOfficerName');
    setCtrl(_goaOfficerRankCtrl, 'goaOfficerRank');
    setCtrl(_goaAccusedSigCtrl, 'goaAccusedSig');
    setCtrl(_s48RelativeNameCtrl, 's48RelativeName');
    setCtrl(_s48RelativeAgeCtrl, 's48RelativeAge');
    setCtrl(_s48RelativeAddressCtrl, 's48RelativeAddress');
    setCtrl(_s48RelationshipCtrl, 's48Relationship');
    setCtrl(_s48CustodyPsCtrl, 's48CustodyPs');
    setBool((v) => _s48G1 = v, 's48G1');
    setBool((v) => _s48G2 = v, 's48G2');
    setBool((v) => _s48G3 = v, 's48G3');
    setBool((v) => _s48G5 = v, 's48G5');
    setBool((v) => _s48G6 = v, 's48G6');
    setCtrl(_s48WitnessNameCtrl, 's48WitnessName');
    setCtrl(_s48CoAccusedCtrl, 's48CoAccused');
    setCtrl(_s48DateCtrl, 's48Date');
    setCtrl(_s48PlaceCtrl, 's48Place');
    setCtrl(_s48OfficerSigCtrl, 's48OfficerSig');
    setCtrl(_s48RelativeSigCtrl, 's48RelativeSig');
    setBool((v) => _roaR1 = v, 'roaR1');
    setBool((v) => _roaR2 = v, 'roaR2');
    setBool((v) => _roaR3 = v, 'roaR3');
    setBool((v) => _roaR4 = v, 'roaR4');
    setBool((v) => _roaR5 = v, 'roaR5');
    setCtrl(_roaDateCtrl, 'roaDate');
    setCtrl(_roaPlaceCtrl, 'roaPlace');
    setCtrl(_roaOfficerSigCtrl, 'roaOfficerSig');
    setCtrl(_roaAccusedSigCtrl, 'roaAccusedSig');
    setBool((v) => _pcr1 = v, 'pcr1');
    setBool((v) => _pcr2 = v, 'pcr2');
    setBool((v) => _pcr3 = v, 'pcr3');
    setBool((v) => _pcr4 = v, 'pcr4');
    setBool((v) => _pcr5 = v, 'pcr5');
    setBool((v) => _pcr6 = v, 'pcr6');
    setBool((v) => _pcr7 = v, 'pcr7');
    setCtrl(_pcrOtherCtrl, 'pcrOther');
    if (mounted) setState(() {});
  }

  Widget _refText(String text, TextStyle serif, {TextStyle? marathi}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: marathi ?? serif.copyWith(fontSize: 12, fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget _checkboxRow(
    String en,
    String mr,
    bool value,
    ValueChanged<bool?> onChanged,
    TextStyle serif,
    TextStyle marathi,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: widget.readOnly ? null : onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(en, style: serif.copyWith(fontSize: 12)),
                Text(mr, style: marathi.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedCaseHeader(
    TextStyle serif,
    TextStyle marathi,
    TextStyle marathiLabel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BilingualField(
          label: 'Name of arrested accused',
          marathiLabel: 'अटक केलेल्या आरोपीचे नाव',
          controller: _accusedNameCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Age',
              marathiLabel: 'वय',
              controller: _accusedAgeCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Address',
              marathiLabel: 'पत्ता',
              controller: _accusedAddressCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        const SizedBox(height: 12),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Police Station',
              marathiLabel: 'पोलीस ठाणे',
              controller: _psNameCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Crime Register No.',
              marathiLabel: 'गुन्हा रजिस्टर क्र.',
              controller: _crNoCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        const SizedBox(height: 12),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'BNS Section',
              marathiLabel: 'BNS कलम',
              controller: _bnsSectionCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Arrest date / time',
              marathiLabel: 'अटक दिनांक / वेळ',
              controller: _arrestDateCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        const SizedBox(height: 8),
        BilingualField(
          label: 'Arrest time (if separate)',
          marathiLabel: 'अटक वेळ',
          controller: _arrestTimeCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        BilingualMultilineField(
          label: 'Brief facts of the crime',
          marathiLabel: 'गुन्ह्याची थोडक्यात हकीकत',
          controller: _briefFactsCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
          minLines: 3,
        ),
      ],
    );
  }

  Widget _buildSectionI(TextStyle serif, TextStyle marathi, TextStyle marathiLabel) {
    return FormPaperPage(
      formLabel: widget.pageRange ?? 'Pages 1–4',
      children: [
        BilingualSectionHeader(
          label: 'Ground of Arrest — Reference (Pages 1–4)',
          marathiLabel: 'अटकेचा आधार — संदर्भ',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        Center(
          child: Column(
            children: [
              Text(
                'अटकेचा आधार (Ground of Arrest)',
                style: marathi.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                'अटकेचे कारणे (Reason of Arrest)',
                style: marathi.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              Text(
                'पोलिस कोठडीची कारणे (Reason for PCR)',
                style: marathi.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _refText(
          'प्रस्तावना: व्यक्ती स्वातंत्र्य हे लोकशाहीचे मूलभूत अधिकार आहे. '
          'भारतीय संविधानाच्या कलम २१ व २२ आणि BNSS २०२३ अंतर्गत अटकेचा '
          'लेखी आधार देणे बंधनकारक आहे.',
          serif,
          marathi: marathi,
        ),
        BilingualSectionHeader(
          label: 'Supreme Court Judgments',
          marathiLabel: 'माननीय सर्वोच्च न्यायालयाचे न्यायनिर्णय',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        _refText('१) Pankaj Bansal vs. Union of India (2023)', serif),
        _refText('२) Prabir Purkayastha vs. N.C.T. Delhi (2024)', serif),
        _refText('३) Vihaan Kumar vs. State of Haryana (2025)', serif),
        _refText('४) Mihir Rajesh Shah vs. State of Maharashtra (2025)', serif),
        const SizedBox(height: 8),
        _refText(
          'लेखी अटकेचा आधार देणे हे संविधानिक अधिकार आहे. '
          'केवळ मौखिक माहिती पुरेशी नाही.',
          serif,
          marathi: marathi,
        ),
        BilingualSectionHeader(
          label: 'Section 47 BNSS — Grounds of Arrest',
          marathiLabel: 'कलम ४७ BNSS — अटकेचा आधार',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        _refText(
          'वॉरंटशिवाय अटक करताना पोलीस अधिकारीने त्वरित लेखी स्वरूपात '
          'अटकेचा आधार (Grounds of Arrest) देणे आवश्यक आहे. केवळ कलम '
          'उल्लेख करणे पुरेसे नाही — गुन्हा व पुराव्याचे ठोस तपशील '
          'द्यावे लागतात.',
          serif,
          marathi: marathi,
        ),
        BilingualSectionHeader(
          label: 'Section 35(1)(b) BNSS — Reason of Arrest',
          marathiLabel: 'कलम ३५(१)(ब) BNSS — अटकेचे कारण',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        _refText(
          '७ वर्षांपेक्षा कमी शिक्षा असलेल्या गुन्ह्यांसाठी अटकेची '
          'विशिष्ट कारणे (Reasons of Arrest) डायरीमध्ये लेखी नोंद '
          'करणे बंधनकारक:',
          serif,
          marathi: marathi,
        ),
        _refText('१) पुढील गुन्हे टाळण्यासाठी', serif, marathi: marathi),
        _refText('२) योग्य तपासासाठी', serif, marathi: marathi),
        _refText('३) पुरावे नष्ट/बदल होण्यास रोखण्यासाठी', serif, marathi: marathi),
        _refText('४) साक्षीदारांना धमकवणे/प्रलोभन देणे रोखण्यासाठी', serif, marathi: marathi),
        _refText('५) न्यायालयात उपस्थिती सुनिश्चित करण्यासाठी', serif, marathi: marathi),
        BilingualSectionHeader(
          label: 'Section 48 BNSS — Informing Relatives',
          marathiLabel: 'कलम ४८ BNSS — नातेवाईकांना माहिती',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        _refText(
          'अटक झाल्यावर नातेवाईक/मित्र/नामनिर्देशित व्यक्तीला अटक व '
          'ठेवण्याचे ठिकाण लेखी कळवणे बंधनकारक. स्टेशन डायरीमध्ये '
          'नोंद घेणे आवश्यक.',
          serif,
          marathi: marathi,
        ),
      ],
    );
  }

  Widget _buildSectionII(TextStyle serif, TextStyle marathi, TextStyle marathiLabel) {
    return FormPaperPage(
      formLabel: widget.pageRange ?? 'Pages 5–8',
      children: [
        BilingualSectionHeader(
          label: 'Reason of Arrest — Reference (Pages 5–8)',
          marathiLabel: 'अटकेचे कारणे — संदर्भ',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        _refText(
          'Vihaan Kumar (2025): अटकेचा आधार व कारणे स्पष्ट लेखी स्वरूपात '
          'आरोपीला समजेल अशा भाषेत द्यावे. २-तासांचा नियम — रिमांड '
          'आधी लेखी आधार देणे आवश्यक.',
          serif,
          marathi: marathi,
        ),
        BilingualSectionHeader(
          label: 'Difference: Ground vs Reason vs PCR',
          marathiLabel: 'अटकेचा आधार, कारणे व PCR यामधील फरक',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.black54, width: 0.8),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade200),
              children: [
                _tableCell('Ground of Arrest\n(कलम ४७)', serif, bold: true),
                _tableCell('Reason of Arrest\n(कलम ३५(१)(ब))', serif, bold: true),
                _tableCell('Reason for PCR\n(कलम १८७)', serif, bold: true),
              ],
            ),
            TableRow(
              children: [
                _tableCell(
                  'Prima facie evidence\n(FIR, CCTV, witness, confession, CDR…)',
                  serif,
                ),
                _tableCell(
                  '5 specific reasons\n(≤7 yr offences only)',
                  serif,
                ),
                _tableCell(
                  'PCR necessity\n(weapon seizure, recovery, motive…)',
                  serif,
                ),
              ],
            ),
            TableRow(
              children: [
                _tableCell('All offences', serif),
                _tableCell('≤7 years punishment', serif),
                _tableCell('All offences', serif),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        BilingualSectionHeader(
          label: 'Where to record Ground & Reason',
          marathiLabel: 'अटकेचा आधार/कारणे कोठे नमूद करावे',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        _refText('१) आरोपीला लेखी अटकेचा आधार (कलम ४७)', serif, marathi: marathi),
        _refText('२) नातेवाईक/मित्रांना लेखी माहिती (कलम ४८)', serif, marathi: marathi),
        _refText('३) अटकेचे कारण लेखी (कलम ३५(१)(ब))', serif, marathi: marathi),
        _refText('४) स्टेशन डायरी', serif, marathi: marathi),
        _refText('५) अटक पंचनामा — कॉलम ८', serif, marathi: marathi),
        _refText('६) रिमांड रिपोर्ट', serif, marathi: marathi),
        _refText('७) केस डायरी', serif, marathi: marathi),
      ],
    );
  }

  Widget _tableCell(String text, TextStyle serif, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: serif.copyWith(
          fontSize: 11,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPage9(TextStyle serif, TextStyle marathi, TextStyle marathiLabel) {
    return FormPaperPage(
      formLabel: 'Page 9',
      children: [
        BilingualSectionHeader(
          label: 'Ground of Arrest (Section 47 BNSS)',
          marathiLabel: 'अटकेचा आधार (कलम ४७ BNSS)',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 8),
        _refText(
          '(As per BNSS 2023 Section 47, Article 22(1) and Supreme Court guidelines)',
          serif.copyWith(fontSize: 10, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
        _buildSharedCaseHeader(serif, marathi, marathiLabel),
        const SizedBox(height: 16),
        Text('Grounds of Arrest / अटकेचे आधार',
            style: serif.copyWith(fontWeight: FontWeight.bold)),
        _checkboxRow(
          '1. Allegations in FIR by complainant',
          '१. FIR मधील फिर्यादीचे आरोप',
          _goaG1,
          (v) => setState(() => _goaG1 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '2. Eyewitness statement establishes involvement',
          '२. डोळ्यांनी पाहणाऱ्या साक्षीदाराचे विधान',
          _goaG2,
          (v) => setState(() => _goaG2 = v ?? false),
          serif,
          marathi,
        ),
        BilingualField(
          label: 'Eyewitness name',
          marathiLabel: 'साक्षीदाराचे नाव',
          controller: _goaWitnessNameCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        _checkboxRow(
          '3. CCTV / digital evidence establishes involvement',
          '३. CCTV / डिजिटल पुरावा',
          _goaG3,
          (v) => setState(() => _goaG3 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '4. Recovery of weapon/stolen property from accused',
          '४. हत्यार/माल जप्ती',
          _goaG4,
          (v) => setState(() => _goaG4 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '5. Accused confessed to the crime',
          '५. आरोपीने कबुली दिली',
          _goaG5,
          (v) => setState(() => _goaG5 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '6. Co-accused named this accused',
          '६. सह-आरोपीने नाव सांगितले',
          _goaG6,
          (v) => setState(() => _goaG6 = v ?? false),
          serif,
          marathi,
        ),
        BilingualField(
          label: 'Co-accused name',
          marathiLabel: 'सह-आरोपीचे नाव',
          controller: _goaCoAccusedCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        _checkboxRow(
          '7. Mobile CDR location near crime scene',
          '७. CDR लोकेशन पुरावा',
          _goaG7,
          (v) => setState(() => _goaG7 = v ?? false),
          serif,
          marathi,
        ),
        const SizedBox(height: 12),
        BilingualField(
          label: 'Relative/friend informed (name)',
          marathiLabel: 'माहिती दिलेले नातेवाईक/मित्र',
          controller: _goaKinNameCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 16),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Date',
              marathiLabel: 'दिनांक',
              controller: _goaFooterDateCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Police officer name & rank',
              marathiLabel: 'पोलीस अधिकारी नाव, हुद्दा',
              controller: _goaOfficerNameCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualField(
          label: 'Officer rank / stamp',
          marathiLabel: 'हुद्दा / शिक्का',
          controller: _goaOfficerRankCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualField(
          label: 'Accused signature / thumb',
          marathiLabel: 'आरोपीचे नाव, सही, अंगठा',
          controller: _goaAccusedSigCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
      ],
    );
  }

  Widget _buildPage10(TextStyle serif, TextStyle marathi, TextStyle marathiLabel) {
    return FormPaperPage(
      formLabel: 'Page 10',
      children: [
        BilingualSectionHeader(
          label: 'Arrest Notice for Relative/Friend (Section 48 BNSS)',
          marathiLabel: 'नातेवाईक/मित्रांसाठी अटकेची नोटीस (कलम ४८ BNSS)',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        BilingualField(
          label: 'Relative / friend name',
          marathiLabel: 'नातेवाईक/मित्राचे नाव',
          controller: _s48RelativeNameCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Age',
              marathiLabel: 'वय',
              controller: _s48RelativeAgeCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Address',
              marathiLabel: 'पत्ता',
              controller: _s48RelativeAddressCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualField(
          label: 'Relationship with accused',
          marathiLabel: 'आरोपीशी असलेले नाते',
          controller: _s48RelationshipCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        _buildSharedCaseHeader(serif, marathi, marathiLabel),
        BilingualField(
          label: 'Place of detention (police station)',
          marathiLabel: 'ठेवण्याचे ठिकाण (पोलीस ठाणे)',
          controller: _s48CustodyPsCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        Text('Grounds of Arrest / अटकेचे आधार',
            style: serif.copyWith(fontWeight: FontWeight.bold)),
        _checkboxRow(
          '1. Crime mentioned in FIR',
          '१. FIR मध्ये गुन्ह्याचा उल्लेख',
          _s48G1,
          (v) => setState(() => _s48G1 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '2. Eyewitness establishes involvement',
          '२. साक्षीदाराचे विधान',
          _s48G2,
          (v) => setState(() => _s48G2 = v ?? false),
          serif,
          marathi,
        ),
        BilingualField(
          label: 'Eyewitness name',
          marathiLabel: 'साक्षीदाराचे नाव',
          controller: _s48WitnessNameCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        _checkboxRow(
          '3. CCTV / digital records',
          '३. CCTV / डिजिटल रेकॉर्ड',
          _s48G3,
          (v) => setState(() => _s48G3 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '5. Accused confessed',
          '५. आरोपीने कबुली दिली',
          _s48G5,
          (v) => setState(() => _s48G5 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '6. Co-accused named this accused',
          '६. सह-आरोपीने नाव सांगितले',
          _s48G6,
          (v) => setState(() => _s48G6 = v ?? false),
          serif,
          marathi,
        ),
        BilingualField(
          label: 'Co-accused name',
          marathiLabel: 'सह-आरोपीचे नाव',
          controller: _s48CoAccusedCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Date',
              marathiLabel: 'दिनांक',
              controller: _s48DateCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Place',
              marathiLabel: 'ठिकाण',
              controller: _s48PlaceCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Police officer signature',
              marathiLabel: 'पोलीस अधिकारी नाव, सही, शिक्का',
              controller: _s48OfficerSigCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Relative/friend signature',
              marathiLabel: 'नातेवाईक/मित्र सही, अंगठा',
              controller: _s48RelativeSigCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPage11(TextStyle serif, TextStyle marathi, TextStyle marathiLabel) {
    return FormPaperPage(
      formLabel: 'Page 11',
      children: [
        BilingualSectionHeader(
          label: 'Reason of Arrest (Section 35(1)(b) BNSS)',
          marathiLabel: 'अटकेचे कारणे [कलम ३५(१)(ब) BNSS]',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        _buildSharedCaseHeader(serif, marathi, marathiLabel),
        const SizedBox(height: 12),
        Text('Reasons for Arrest / अटकेची कारणे',
            style: serif.copyWith(fontWeight: FontWeight.bold)),
        _checkboxRow(
          '1. To prevent further crimes',
          '१. पुढील गुन्हे टाळण्यासाठी',
          _roaR1,
          (v) => setState(() => _roaR1 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '2. For proper investigation',
          '२. योग्य तपासासाठी',
          _roaR2,
          (v) => setState(() => _roaR2 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '3. To prevent tampering with evidence',
          '३. पुरावे नष्ट/बदल होण्यास रोखण्यासाठी',
          _roaR3,
          (v) => setState(() => _roaR3 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '4. To prevent threatening/inducing witnesses',
          '४. साक्षीदारांना धमकवणे/प्रलोभन देणे रोखण्यासाठी',
          _roaR4,
          (v) => setState(() => _roaR4 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '5. To ensure presence in court',
          '५. न्यायालयात उपस्थिती सुनिश्चित करण्यासाठी',
          _roaR5,
          (v) => setState(() => _roaR5 = v ?? false),
          serif,
          marathi,
        ),
        const SizedBox(height: 12),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Date',
              marathiLabel: 'दिनांक',
              controller: _roaDateCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Place',
              marathiLabel: 'ठिकाण',
              controller: _roaPlaceCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Police officer signature',
              marathiLabel: 'पोलीस अधिकारी नाव, सही, शिक्का',
              controller: _roaOfficerSigCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Accused signature / thumb',
              marathiLabel: 'आरोपीचे नाव, सही, अंगठा',
              controller: _roaAccusedSigCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPage12(TextStyle serif, TextStyle marathi, TextStyle marathiLabel) {
    return FormPaperPage(
      formLabel: 'Page 12',
      children: [
        BilingualSectionHeader(
          label: 'Reasons for Police Custody (PCR)',
          marathiLabel: 'पोलिस कोठडीची कारणे (PCR)',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        _checkboxRow(
          '1. Weapon used in crime yet to be seized',
          '१) गुन्ह्यात वापरलेले हत्यार जप्त करणे बाकी',
          _pcr1,
          (v) => setState(() => _pcr1 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '2. To ascertain motive behind the crime',
          '२) गुन्हा करण्यामागील हेतू माहित करावयाचा',
          _pcr2,
          (v) => setState(() => _pcr2 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '3. To identify other co-accused',
          '३) अजून कोणी आरोपी आहेत का याची माहिती',
          _pcr3,
          (v) => setState(() => _pcr3 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '4. To recover stolen cash/gold ornaments',
          '४) चोरी गेलेली रक्कम, सोन्याचे अलंकार जप्त',
          _pcr4,
          (v) => setState(() => _pcr4 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '5. To seize vehicle used in crime',
          '५) गुन्ह्यात वापरलेले वाहन जप्त',
          _pcr5,
          (v) => setState(() => _pcr5 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '6. To seize accused clothing',
          '६) आरोपीचे कपडे जप्त',
          _pcr6,
          (v) => setState(() => _pcr6 = v ?? false),
          serif,
          marathi,
        ),
        _checkboxRow(
          '7. Blood sample yet to be taken',
          '७) आरोपीचे ब्लड सॅम्पल घेणे बाकी',
          _pcr7,
          (v) => setState(() => _pcr7 = v ?? false),
          serif,
          marathi,
        ),
        BilingualMultilineField(
          label: '8. Other (specify)',
          marathiLabel: '८) इत्यादी',
          controller: _pcrOtherCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
          minLines: 2,
        ),
      ],
    );
  }

  Widget _buildSectionIII(TextStyle serif, TextStyle marathi, TextStyle marathiLabel) {
    return Column(
      children: [
        _buildPage9(serif, marathi, marathiLabel),
        const SizedBox(height: 24),
        _buildPage10(serif, marathi, marathiLabel),
        const SizedBox(height: 24),
        _buildPage11(serif, marathi, marathiLabel),
        const SizedBox(height: 24),
        _buildPage12(serif, marathi, marathiLabel),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final serif = FormTypography.serifStyle();
    final marathi = FormTypography.marathiLabelStyle(fontWeight: FontWeight.normal);
    final marathiLabel = FormTypography.marathiLabelStyle();

    final pages = <Widget>[];
    if (_showSectionI) {
      pages.add(_buildSectionI(serif, marathi, marathiLabel));
      pages.add(const SizedBox(height: 24));
    }
    if (_showSectionII) {
      pages.add(_buildSectionII(serif, marathi, marathiLabel));
      pages.add(const SizedBox(height: 24));
    }
    if (_showSectionIII) {
      pages.add(_buildSectionIII(serif, marathi, marathiLabel));
    }

    return FormViewScaffold(
      readOnly: widget.readOnly,
      children: pages,
    );
  }
}
