import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bilingual_field.dart';
import 'form_paper_page.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';
import '../utils/form_io_terminology.dart';
import 'responsive_field_row.dart';

/// चौकशी अहवाल — Interrogation Report (7 pages, Marathi).
class InterrogationFormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const InterrogationFormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<InterrogationFormView> createState() => InterrogationFormViewState();
}

class InterrogationFormViewState extends State<InterrogationFormView> {
  int? get _activePart {
    final s = widget.formSection?.toLowerCase().trim() ?? '';
    if (s.isEmpty) return null;
    if (s.contains('part v') || s.contains('additional')) return 5;
    if (s.contains('part iv') || s.contains('crime method') || s.contains('logistics')) {
      return 4;
    }
    if (s.contains('part iii') || s.contains('education') || s.contains('id & history')) {
      return 3;
    }
    if (s.contains('part ii') || s.contains('family')) return 2;
    if (s.contains('part i') || s.contains('personal')) return 1;
    return null;
  }

  bool get _showPartI => _activePart == null || _activePart == 1;
  bool get _showPartII => _activePart == null || _activePart == 2;
  bool get _showPartIII => _activePart == null || _activePart == 3;
  bool get _showPartIV => _activePart == null || _activePart == 4;
  bool get _showPartV => _activePart == null || _activePart == 5;

  // Part I — Page 1
  final _psCtrl = TextEditingController();
  final _gurNoCtrl = TextEditingController();
  final _kalamCtrl = TextEditingController();
  final _ioCtrl = TextEditingController();
  final _accusedCtrl = TextEditingController();
  final _arrestDtCtrl = TextEditingController();
  final _dobPlaceAgeCtrl = TextEditingController();
  final _physicalCtrl = TextEditingController();
  final _idMarksCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _dharmaCtrl = TextEditingController();
  final _jatiCtrl = TextEditingController();

  // Part II — Pages 2–3 (rows 11–21)
  late final List<TextEditingController> _familyRows =
      List.generate(11, (_) => TextEditingController());

  // Part III — Page 4 (rows 22–30)
  late final List<TextEditingController> _idHistoryRows =
      List.generate(9, (_) => TextEditingController());

  // Part IV — Pages 5–6 (rows 31–40)
  late final List<TextEditingController> _crimeRows =
      List.generate(10, (_) => TextEditingController());
  final _ioSigNameCtrl = TextEditingController();
  final _ioSigRankCtrl = TextEditingController();
  final _ioSigCodeCtrl = TextEditingController();
  final _ioSigPostingCtrl = TextEditingController();

  // Part V — Page 7
  final _additional37Ctrl = TextEditingController();

  static const _familyLabels = [
    '११. व्यवसाय/काम व यापुर्वीचा व्यवसाय',
    '१२. वडीलाचे/आईचे नांव, वय, पत्ता, व्यवसाय, फोन व इतर माहिती',
    '१३. मुले/मुलीचे नांव, वय, पत्ता, व्यवसाय, फोन व इतर माहिती',
    '१४. भावाचे/बहीणीचे नांव, वय, पत्ता, व्यवसाय, फोन व इतर माहिती',
    '१५. बहीण/भाऊजीचे नांव, वय, पत्ता, व्यवसाय, फोन व इतर माहिती',
    '१६. सासू/सासऱ्याचे नांव, वय, पत्ता, व्यवसाय, फोन व इतर माहिती',
    '१७. मेव्हणा/मेव्हणीचे नांव, वय, पत्ता, व्यवसाय, फोन व इतर माहिती',
    '१८. मामा/मामीचे नांव, वय, पत्ता, व्यवसाय, फोन व इतर माहिती',
    '१९. काका/मावशीचे नांव, वय, पत्ता, व्यवसाय, फोन व इतर माहिती',
    '२०. चुलता/चुलतीचे नांव, वय, पत्ता, व्यवसाय, फोन व इतर माहिती',
    '२१. आत्याचे/मामाचे नांव, वय, पत्ता, व्यवसाय, फोन व इतर माहिती',
  ];

  static const _idHistoryLabels = [
    '२२. शिक्षण/शाळा/कॉलेज (पत्ता) व संगणक ज्ञान',
    '२३. नोकरीस असल्यास पूर्वीचे कार्यालयाचा पत्ता',
    '२४. आधारकार्ड क्रमांक',
    '२५. पॅनकार्ड क्रमांक',
    '२६. वाहन परवाना',
    '२७. रेशन कार्ड',
    '२८. मालमत्ता (अंदाजे)',
    '२९. यापुर्वी झालेली शिक्षा (पोलीस ठाणे, गु.नो.क्र, कलम, साथीदार)',
    '३०. या गुन्ह्यातील साथीदारांची नावे, पत्ता, मोबाईल नंबर',
  ];

  static const _crimeLabels = [
    '३१. बसण्याच्या-उठण्याच्या जागा',
    '३२. गुन्ह्याचे ठिकाण/इमारत — माहिती मिळालेली उगमस्थाने (रेखी)',
    '३३. गुन्हा करतेवेळी वापरलेली वाहने',
    '३४. गुन्हा करतेवेळी वापरलेली हत्यारे (काठी, कटवणी, पक्कड, इ.)',
    '३५. गुन्हा करतेवेळी येण्याची दिशा व रस्ते',
    '३६. गुन्हा करून जातेवेळीची दिशा व रस्ते',
    '३७. गुन्हा करण्याची पद्धत',
    '३८. चोरलेल्या मुद्देमालाबाबत आरोपीने सांगितलेली माहिती',
    '३९. आरोपीस ओळखणारे पोलीस अधिकारी/अंमलदार, पोलीस पाटील',
    '४०. Advisories',
  ];

  @override
  void dispose() {
    for (final c in [
      _psCtrl,
      _gurNoCtrl,
      _kalamCtrl,
      _ioCtrl,
      _accusedCtrl,
      _arrestDtCtrl,
      _dobPlaceAgeCtrl,
      _physicalCtrl,
      _idMarksCtrl,
      _addressCtrl,
      _dharmaCtrl,
      _jatiCtrl,
      _ioSigNameCtrl,
      _ioSigRankCtrl,
      _ioSigCodeCtrl,
      _ioSigPostingCtrl,
      _additional37Ctrl,
      ..._familyRows,
      ..._idHistoryRows,
      ..._crimeRows,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> collectData() {
    return {
      'formSection': widget.formSection ?? '',
      'pageRange': widget.pageRange ?? '',
      'ps': _psCtrl.text.trim(),
      'gurNo': _gurNoCtrl.text.trim(),
      'kalam': _kalamCtrl.text.trim(),
      'ioName': _ioCtrl.text.trim(),
      'accusedName': _accusedCtrl.text.trim(),
      'arrestDateTime': _arrestDtCtrl.text.trim(),
      'dobPlaceAge': _dobPlaceAgeCtrl.text.trim(),
      'physicalDescription': _physicalCtrl.text.trim(),
      'idMarks': _idMarksCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'dharma': _dharmaCtrl.text.trim(),
      'jati': _jatiCtrl.text.trim(),
      'familyRows': _familyRows.map((c) => c.text.trim()).toList(),
      'idHistoryRows': _idHistoryRows.map((c) => c.text.trim()).toList(),
      'crimeRows': _crimeRows.map((c) => c.text.trim()).toList(),
      'ioSigName': _ioSigNameCtrl.text.trim(),
      'ioSigRank': _ioSigRankCtrl.text.trim(),
      'ioSigCode': _ioSigCodeCtrl.text.trim(),
      'ioSigPosting': _ioSigPostingCtrl.text.trim(),
      'additionalPoint37': _additional37Ctrl.text.trim(),
    };
  }

  void hydrateFrom(Map<String, dynamic> data) {
    setState(() {
      void set(TextEditingController c, String key) {
        c.text = data[key]?.toString() ?? '';
      }

      set(_psCtrl, 'ps');
      set(_gurNoCtrl, 'gurNo');
      set(_kalamCtrl, 'kalam');
      set(_ioCtrl, 'ioName');
      set(_accusedCtrl, 'accusedName');
      set(_arrestDtCtrl, 'arrestDateTime');
      set(_dobPlaceAgeCtrl, 'dobPlaceAge');
      set(_physicalCtrl, 'physicalDescription');
      set(_idMarksCtrl, 'idMarks');
      set(_addressCtrl, 'address');
      set(_dharmaCtrl, 'dharma');
      set(_jatiCtrl, 'jati');
      set(_ioSigNameCtrl, 'ioSigName');
      set(_ioSigRankCtrl, 'ioSigRank');
      set(_ioSigCodeCtrl, 'ioSigCode');
      set(_ioSigPostingCtrl, 'ioSigPosting');
      set(_additional37Ctrl, 'additionalPoint37');

      _hydrateList(data['familyRows'], _familyRows);
      _hydrateList(data['idHistoryRows'], _idHistoryRows);
      _hydrateList(data['crimeRows'], _crimeRows);
    });
  }

  void _hydrateList(dynamic raw, List<TextEditingController> ctrls) {
    if (raw is! List) return;
    for (var i = 0; i < ctrls.length && i < raw.length; i++) {
      ctrls[i].text = raw[i]?.toString() ?? '';
    }
  }

  TextStyle _marathiLabel() => GoogleFonts.notoSansDevanagari(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      );

  Widget _sectionTitle(String text, TextStyle serif) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          style: serif.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  Widget _labeledField(
    String label,
    TextEditingController controller,
    TextStyle serif, {
    int minLines = 1,
    TextStyle? labelStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label.isNotEmpty)
            Text(label, style: labelStyle ?? serif.copyWith(fontSize: 11)),
          if (label.isNotEmpty) const SizedBox(height: 4),
          if (minLines > 1)
            BilingualDynamicLinedTextField(
              controller: controller,
              minLines: minLines,
              serifStyle: serif,
            )
          else
            BilingualSimpleUnderlineInput(
              controller: controller,
              serifStyle: serif,
            ),
        ],
      ),
    );
  }

  Widget _buildPartI(TextStyle serif, TextStyle marathi) {
    return FormPaperPage(
      formLabel: 'Part I — Pages 1–2',
      children: [
        Center(
          child: Column(
            children: [
              Text(
                '-:: चौकशी अहवाल ::-',
                style: marathi.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              Text(
                'स्थानिक गुन्हे शाखा',
                style: marathi.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ResponsiveFieldRow(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _labeledField('१. पोलीस ठाणे', _psCtrl, serif, labelStyle: marathi)),
            Expanded(child: _labeledField('गुरनं', _gurNoCtrl, serif, labelStyle: marathi)),
            Expanded(child: _labeledField('कलम', _kalamCtrl, serif, labelStyle: marathi)),
          ],
        ),
        _labeledField('३. तपासी अधिकाऱ्याचे नांव व हुद्दा', _ioCtrl, serif, labelStyle: marathi),
        _labeledField('४. गुन्हेगाराचे नांव व टोपण नांव', _accusedCtrl, serif, labelStyle: marathi),
        _labeledField('५. अटक तारीख व वेळ', _arrestDtCtrl, serif, labelStyle: marathi),
        _labeledField('६. जन्म तारीख, जन्मठिकाण, वय', _dobPlaceAgeCtrl, serif, labelStyle: marathi),
        _sectionTitle('७. चेहरे पट्टी माहिती', serif),
        _labeledField(
          'उंची, बांधा, केस, भुवया, कपाळ, डोळे, दृष्टी, नाक, ओठ, छाती, बोटे, हनुवटी, कान, चेहरा, वर्ण, दाढी, मिशा, भाषा, गाल, पोशाख, व्यसन',
          _physicalCtrl,
          serif,
          minLines: 6,
          labelStyle: marathi,
        ),
        _labeledField('८. ओळखीच्या खुणा (तीळ, मार, जखम, गोंदण, अपंगत्व)', _idMarksCtrl, serif, minLines: 2, labelStyle: marathi),
        _labeledField('९. सध्याचा/मुळ पत्ता, मोबाईल नंबर', _addressCtrl, serif, minLines: 3, labelStyle: marathi),
        ResponsiveFieldRow(
          children: [
            Expanded(child: _labeledField('१०. धर्म', _dharmaCtrl, serif, labelStyle: marathi)),
            Expanded(child: _labeledField('जात', _jatiCtrl, serif, labelStyle: marathi)),
          ],
        ),
      ],
    );
  }

  Widget _buildPartII(TextStyle serif, TextStyle marathi) {
    return FormPaperPage(
      formLabel: 'Part II — Pages 2–3',
      children: [
        _sectionTitle('कुटुंबीय माहिती (१२–२१)', serif),
        for (var i = 0; i < _familyLabels.length; i++)
          _labeledField(_familyLabels[i], _familyRows[i], serif, minLines: i == 0 ? 2 : 4, labelStyle: marathi),
      ],
    );
  }

  Widget _buildPartIII(TextStyle serif, TextStyle marathi) {
    return FormPaperPage(
      formLabel: 'Part III — Page 4',
      children: [
        _sectionTitle('शिक्षण, ओळखपत्रे व इतिहास (२२–३०)', serif),
        for (var i = 0; i < _idHistoryLabels.length; i++)
          _labeledField(
            _idHistoryLabels[i],
            _idHistoryRows[i],
            serif,
            minLines: i >= 7 ? 5 : (i <= 1 ? 3 : 1),
            labelStyle: marathi,
          ),
      ],
    );
  }

  Widget _buildPartIV(TextStyle serif, TextStyle marathi) {
    return FormPaperPage(
      formLabel: 'Part IV — Pages 5–6',
      children: [
        _sectionTitle('गुन्ह्याची पद्धत व तपशील (३१–४०)', serif),
        for (var i = 0; i < _crimeLabels.length; i++)
          _labeledField(_crimeLabels[i], _crimeRows[i], serif, minLines: 4, labelStyle: marathi),
        const SizedBox(height: 16),
        _sectionTitle('${FormIoTerminology.officer} — ${FormIoTerminology.signature}', serif),
        ResponsiveFieldRow(
          children: [
            Expanded(child: _labeledField(FormIoTerminology.name, _ioSigNameCtrl, serif, labelStyle: marathi)),
            Expanded(child: _labeledField(FormIoTerminology.rank, _ioSigRankCtrl, serif, labelStyle: marathi)),
          ],
        ),
        ResponsiveFieldRow(
          children: [
            Expanded(child: _labeledField(FormIoTerminology.badgeNo, _ioSigCodeCtrl, serif, labelStyle: marathi)),
            Expanded(child: _labeledField(FormIoTerminology.posting, _ioSigPostingCtrl, serif, labelStyle: marathi)),
          ],
        ),
        FormMrwFooter(serifStyle: serif, fontSize: 10),
      ],
    );
  }

  Widget _buildPartV(TextStyle serif, TextStyle marathi) {
    return FormPaperPage(
      formLabel: 'Part V — Page 7',
      children: [
        Center(
          child: Text(
            'मुद्दा क्रमांक ३७ ची अधिक माहिती',
            style: marathi.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'गुन्हा करण्याची पद्धत, रेखी, कार्यप्रणाली, मालाची विल्हेवाट व इतर उपयुक्त माहिती',
          style: marathi.copyWith(fontSize: 11),
        ),
        const SizedBox(height: 12),
        BilingualDynamicLinedTextField(
          controller: _additional37Ctrl,
          minLines: 28,
          serifStyle: serif,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final serif = FormTypography.serifStyle();
    final marathi = _marathiLabel();

    return FormViewScaffold(
      readOnly: widget.readOnly,
      children: [
        if (_showPartI) _buildPartI(serif, marathi),
        if (_showPartI && (_showPartII || _showPartIII || _showPartIV || _showPartV))
          const SizedBox(height: 24),
        if (_showPartII) _buildPartII(serif, marathi),
        if (_showPartII && (_showPartIII || _showPartIV || _showPartV))
          const SizedBox(height: 24),
        if (_showPartIII) _buildPartIII(serif, marathi),
        if (_showPartIII && (_showPartIV || _showPartV)) const SizedBox(height: 24),
        if (_showPartIV) _buildPartIV(serif, marathi),
        if (_showPartIV && _showPartV) const SizedBox(height: 24),
        if (_showPartV) _buildPartV(serif, marathi),
      ],
    );
  }
}
