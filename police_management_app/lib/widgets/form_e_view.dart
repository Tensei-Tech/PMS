import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'form_paper_page.dart';
import 'form_view_scaffold.dart';

class FormEView extends StatefulWidget {
  final Map<String, dynamic>? existingRecord;
  final bool readOnly;

  const FormEView({
    super.key,
    this.existingRecord,
    this.readOnly = false,
  });

  @override
  State<FormEView> createState() => FormEViewState();
}

class FormEViewState extends State<FormEView> {
  // Controllers for 18 fields
  final _ctrl1 = TextEditingController(); // पोलीस स्टेशन
  final _ctrl2 = TextEditingController(); // तक्रार दाखल करणाऱ्याचे नांव व पत्ता
  final _ctrl3 = TextEditingController(); // गुन्हा घडला ते शहर अथवा गांव ई.
  final _ctrl4 = TextEditingController(); // गुन्हा घडल्याची तारीख
  final _ctrl5 = TextEditingController(); // अप क्रमांक व कलम
  final _ctrl6 = TextEditingController(); // चोरीस गेलेल्या मालमत्तेची किंमत
  final _ctrl7 = TextEditingController(); // परत मिळालेल्या मालमत्तेची किंमत...
  final _ctrl8 = TextEditingController(); // ज्याच्यावर हल्ला करण्यात आला...
  final _ctrl9 = TextEditingController(); // गुन्ह्याच्या जागी पोहचण्याकरीता...
  final _ctrl10 = TextEditingController(); // गुन्हा करण्यासाठी वापरलेली रीत
  final _ctrl11 = TextEditingController(); // गुन्हा करण्यासाठी वापरलेले साधन
  final _ctrl12 = TextEditingController(); // दिवसाचा वेळ
  final _ctrl13 = TextEditingController(); // साथीदार
  final _ctrl14 = TextEditingController(); // वाहन
  final _ctrl15 = TextEditingController(); // विशीष्ट निदर्शक खुण
  final _ctrl16 = TextEditingController(); // शैली
  final _ctrl17 = TextEditingController(); // रचुन सांगीतलेली हकीकत...
  final _ctrl18 = TextEditingController(); // गुन्ह्यासंबंधीत थोडक्यात हकीकत

  @override
  void initState() {
    super.initState();
    if (widget.existingRecord != null) {
      hydrateFrom(widget.existingRecord!);
    }
  }

  void hydrateFrom(Map<String, dynamic> doc) {
    _ctrl1.text = doc['field1'] ?? '';
    _ctrl2.text = doc['field2'] ?? '';
    _ctrl3.text = doc['field3'] ?? '';
    _ctrl4.text = doc['field4'] ?? '';
    _ctrl5.text = doc['field5'] ?? '';
    _ctrl6.text = doc['field6'] ?? '';
    _ctrl7.text = doc['field7'] ?? '';
    _ctrl8.text = doc['field8'] ?? '';
    _ctrl9.text = doc['field9'] ?? '';
    _ctrl10.text = doc['field10'] ?? '';
    _ctrl11.text = doc['field11'] ?? '';
    _ctrl12.text = doc['field12'] ?? '';
    _ctrl13.text = doc['field13'] ?? '';
    _ctrl14.text = doc['field14'] ?? '';
    _ctrl15.text = doc['field15'] ?? '';
    _ctrl16.text = doc['field16'] ?? '';
    _ctrl17.text = doc['field17'] ?? '';
    _ctrl18.text = doc['field18'] ?? '';
  }

  Map<String, dynamic> collectData() {
    return {
      'field1': _ctrl1.text.trim(),
      'field2': _ctrl2.text.trim(),
      'field3': _ctrl3.text.trim(),
      'field4': _ctrl4.text.trim(),
      'field5': _ctrl5.text.trim(),
      'field6': _ctrl6.text.trim(),
      'field7': _ctrl7.text.trim(),
      'field8': _ctrl8.text.trim(),
      'field9': _ctrl9.text.trim(),
      'field10': _ctrl10.text.trim(),
      'field11': _ctrl11.text.trim(),
      'field12': _ctrl12.text.trim(),
      'field13': _ctrl13.text.trim(),
      'field14': _ctrl14.text.trim(),
      'field15': _ctrl15.text.trim(),
      'field16': _ctrl16.text.trim(),
      'field17': _ctrl17.text.trim(),
      'field18': _ctrl18.text.trim(),
    };
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _ctrl3.dispose();
    _ctrl4.dispose();
    _ctrl5.dispose();
    _ctrl6.dispose();
    _ctrl7.dispose();
    _ctrl8.dispose();
    _ctrl9.dispose();
    _ctrl10.dispose();
    _ctrl11.dispose();
    _ctrl12.dispose();
    _ctrl13.dispose();
    _ctrl14.dispose();
    _ctrl15.dispose();
    _ctrl16.dispose();
    _ctrl17.dispose();
    _ctrl18.dispose();
    super.dispose();
  }

  TableRow _buildTableRow({
    required String srNo,
    required String englishLabel,
    required String marathiLabel,
    required TextEditingController controller,
    required TextStyle englishStyle,
    required TextStyle marathiStyle,
    int? minLines,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(srNo, style: englishStyle, textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (englishLabel.trim().isNotEmpty) Text(englishLabel, style: englishStyle.copyWith(fontWeight: FontWeight.bold)),
              Text(marathiLabel, style: marathiStyle),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controller,
            minLines: minLines ?? 1,
            maxLines: minLines != null ? null : 1,
            style: englishStyle,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle marathiStyle = GoogleFonts.notoSansDevanagari(
      fontSize: 13,
      color: Colors.black87,
    );

    final TextStyle marathiHeaderStyle = GoogleFonts.notoSansDevanagari(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    final TextStyle englishHeaderStyle = GoogleFonts.lora(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    final TextStyle englishStyle = GoogleFonts.lora(
      fontSize: 15,
      color: Colors.black87,
      fontWeight: FontWeight.w500,
    );

    return FormViewScaffold(
      readOnly: widget.readOnly,
      children: [
        FormPaperPage(
          children: [
            // --- HEADER ---
            Center(
              child: Column(
                children: [
                  Text(
                    'FORM "E"',
                    style: englishHeaderStyle,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black87, style: BorderStyle.solid)),
                    ),
                    child: Text(
                      'मोडस ऑपरेंडी ब्युरोला पुरविण्यात',
                      style: marathiHeaderStyle,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black87, style: BorderStyle.solid)),
                    ),
                    child: Text(
                      'यावयाची माहिती',
                      style: marathiHeaderStyle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- FIELDS ---
            Table(
              border: TableBorder.all(color: Colors.black87, width: 1.0),
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(3),
              },
              children: [
                _buildTableRow(srNo: '1.', englishLabel: 'Police Station: ', marathiLabel: 'पोलीस स्टेशन', controller: _ctrl1, englishStyle: englishStyle, marathiStyle: marathiStyle),
                _buildTableRow(srNo: '2.', englishLabel: 'Name and Address of Complainant: ', marathiLabel: 'तक्रार दाखल करणाऱ्याचे नांव व पत्ता', controller: _ctrl2, englishStyle: englishStyle, marathiStyle: marathiStyle, minLines: 2),
                _buildTableRow(srNo: '3.', englishLabel: 'City or Village of Crime: ', marathiLabel: 'गुन्हा घडला ते शहर अथवा गांव ई.', controller: _ctrl3, englishStyle: englishStyle, marathiStyle: marathiStyle, minLines: 2),
                _buildTableRow(srNo: '4.', englishLabel: 'Date of Crime: ', marathiLabel: 'गुन्हा घडल्याची तारीख', controller: _ctrl4, englishStyle: englishStyle, marathiStyle: marathiStyle),
                _buildTableRow(srNo: '5.', englishLabel: 'Crime No. & Section: ', marathiLabel: 'अप क्रमांक व कलम', controller: _ctrl5, englishStyle: englishStyle, marathiStyle: marathiStyle),
                _buildTableRow(srNo: '6.', englishLabel: 'Value of Stolen Property: ', marathiLabel: 'चोरीस गेलेल्या मालमत्तेची किंमत', controller: _ctrl6, englishStyle: englishStyle, marathiStyle: marathiStyle, minLines: 2),
                _buildTableRow(srNo: '7.', englishLabel: 'Value of Recovered Property: ', marathiLabel: 'परत मिळालेल्या मालमत्तेची किंमत (मालमत्ता कोणाकडून व कोणत्या ठिकाणी परत मिळाली)', controller: _ctrl7, englishStyle: englishStyle, marathiStyle: marathiStyle, minLines: 3),
                _buildTableRow(srNo: '8.', englishLabel: 'Class of Person/Property Attacked: ', marathiLabel: 'ज्याच्यावर हल्ला करण्यात आला त्या ईसमाचा अथवा मिळकतीचा वर्ग', controller: _ctrl8, englishStyle: englishStyle, marathiStyle: marathiStyle, minLines: 3),
                _buildTableRow(srNo: '9.', englishLabel: 'Means used to reach Crime Scene: ', marathiLabel: 'गुन्ह्याच्या जागी पोहचण्याकरीता उपयोगात आणलेले साधन', controller: _ctrl9, englishStyle: englishStyle, marathiStyle: marathiStyle, minLines: 2),
                _buildTableRow(srNo: '10.', englishLabel: 'Method used to commit crime: ', marathiLabel: 'गुन्हा करण्यासाठी वापरलेली रीत', controller: _ctrl10, englishStyle: englishStyle, marathiStyle: marathiStyle),
                _buildTableRow(srNo: '11.', englishLabel: 'Instrument Used: ', marathiLabel: 'गुन्हा करण्यासाठी वापरलेले साधन', controller: _ctrl11, englishStyle: englishStyle, marathiStyle: marathiStyle, minLines: 2),
                _buildTableRow(srNo: '12.', englishLabel: 'Time of Day: ', marathiLabel: 'दिवसाचा वेळ', controller: _ctrl12, englishStyle: englishStyle, marathiStyle: marathiStyle),
                _buildTableRow(srNo: '13.', englishLabel: 'Accomplices: ', marathiLabel: 'साथीदार', controller: _ctrl13, englishStyle: englishStyle, marathiStyle: marathiStyle),
                _buildTableRow(srNo: '14.', englishLabel: 'Vehicle: ', marathiLabel: 'वाहन', controller: _ctrl14, englishStyle: englishStyle, marathiStyle: marathiStyle),
                _buildTableRow(srNo: '15.', englishLabel: 'Specific Identification Mark: ', marathiLabel: 'विशीष्ट निदर्शक खुण', controller: _ctrl15, englishStyle: englishStyle, marathiStyle: marathiStyle),
                _buildTableRow(srNo: '16.', englishLabel: 'Style/Modus Operandi: ', marathiLabel: 'शैली', controller: _ctrl16, englishStyle: englishStyle, marathiStyle: marathiStyle),
                _buildTableRow(srNo: '17.', englishLabel: 'Fabricated Story / Motive: ', marathiLabel: 'रचुन सांगीतलेली हकीकत, गुन्ह्याकरण्याबाबत केलेले हेतुनिवेदन', controller: _ctrl17, englishStyle: englishStyle, marathiStyle: marathiStyle, minLines: 3),
                _buildTableRow(srNo: '18.', englishLabel: 'Brief Facts of the Case: ', marathiLabel: 'गुन्ह्यासंबंधीत थोडक्यात हकीकत', controller: _ctrl18, englishStyle: englishStyle, marathiStyle: marathiStyle, minLines: 15),
              ],
            ),
          ],
        ),
      ],
    );
  }
}