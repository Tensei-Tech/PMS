import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'marathi_text_renderer.dart';
import 'form_io_terminology.dart';
import '../widgets/form_section_utils.dart';

Future<void> previewHousePropertySearchSeizurePdf(
  BuildContext context,
  Map<String, dynamic> doc,
) async {
  final bytes = await generateHousePropertySearchSeizurePdf(doc);
  if (!context.mounted) return;
  final fileName =
      'House_Property_Search_Seizure_${DateTime.now().millisecondsSinceEpoch}.pdf';
  try {
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } else {
      await Printing.layoutPdf(onLayout: (_) async => bytes, name: fileName);
    }
  } catch (_) {
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }
}

Future<Uint8List> generateHousePropertySearchSeizurePdf(
    Map<String, dynamic> doc) async {
  final pdf = pw.Document();
  final loraRegular = await PdfGoogleFonts.loraRegular();
  final loraBold = await PdfGoogleFonts.loraBold();
  final cache = await _preRenderAllMarathi(doc);

  const knownSectionIds = {'Search Seizure Form', 'Search Seizure Panchanama'};
  final activeSection = doc['formSection']?.toString();

  bool showsSection(String sectionId) => showsFormSection(
        activeSection: activeSection,
        sectionId: sectionId,
        knownSectionIds: knownSectionIds,
      );

  final englishStyle = pw.TextStyle(font: loraRegular, fontSize: 8, color: PdfColors.black);
  final englishBold = pw.TextStyle(font: loraBold, fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.black);
  final headerStyle = pw.TextStyle(font: loraBold, fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.black);
  final valueStyle = pw.TextStyle(font: loraRegular, fontSize: 8, color: PdfColors.blue900);

  pw.Widget renderText(String key, String? val, pw.TextStyle engStyle) {
    final text = val?.trim() ?? '';
    if (text.isEmpty) return pw.SizedBox();
    if (containsDevanagari(text) && cache.has(key)) {
      return cache.img(key);
    }
    return pw.Text(text, style: engStyle);
  }

  pw.Widget mLbl(String key) {
    if (cache.has(key)) return cache.img(key);
    return pw.SizedBox();
  }

  pw.Widget underlineField(String valKey, String fallback, {bool expanded = false, double? width}) {
    final child = pw.Container(
      width: expanded ? null : (width ?? 60),
      padding: const pw.EdgeInsets.only(left: 4, right: 4, bottom: 2),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
      ),
      child: renderText(valKey, fallback, valueStyle),
    );
    return expanded ? pw.Expanded(child: child) : child;
  }

  pw.Widget inlineField(String enLabel, String mKey, String valKey, String fallback,
      {double? width, bool expanded = false}) {
    return pw.Row(
      mainAxisSize: expanded ? pw.MainAxisSize.max : pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(enLabel, style: englishBold),
            mLbl(mKey),
          ],
        ),
        underlineField(valKey, fallback, width: width, expanded: expanded),
      ],
    );
  }

  pw.Widget wideField(String enLabel, String mKey, String valKey, String fallback) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(enLabel, style: englishBold),
              mLbl(mKey),
            ],
          ),
          underlineField(valKey, fallback, expanded: true),
        ],
      ),
    );
  }

  pw.Widget multiline(String enLabel, String mKey, String textKey, String? text,
      {int minLines = 3}) {
    final content = text?.trim() ?? '';
    final lines = _splitTextIntoLines(content, 90);
    final count = lines.length > minLines ? lines.length : minLines;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(enLabel, style: englishBold),
        mLbl(mKey),
        pw.SizedBox(height: 2),
        for (var i = 0; i < count; i++)
          pw.Container(
            width: double.infinity,
            margin: const pw.EdgeInsets.only(bottom: 2),
            padding: const pw.EdgeInsets.only(left: 4, bottom: 1),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
            ),
            child: i < lines.length
                ? renderText('${textKey}_$i', lines[i], valueStyle)
                : pw.SizedBox(height: 10),
          ),
      ],
    );
  }

  pw.Widget witnessBlock(String num, String l1Key, String l2Key, String l3Key, String sigKey) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('$num) ', style: englishBold),
                  underlineField(l1Key, doc[l1Key]?.toString() ?? '', expanded: true),
                ],
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 16),
                child: underlineField(l2Key, doc[l2Key]?.toString() ?? '', expanded: true),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 16),
                child: underlineField(l3Key, doc[l3Key]?.toString() ?? '', expanded: true),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('$num) ', style: englishBold),
              underlineField(sigKey, doc[sigKey]?.toString() ?? '', expanded: true),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget ioBlock() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Signature of Investigation Officer', style: englishBold),
        mLbl('lbl_io_header'),
        pw.SizedBox(height: 4),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Name: ', style: englishBold),
            mLbl('lbl_io_name'),
            underlineField('val_ioName', doc['ioName']?.toString() ?? '', expanded: true),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
            inlineField('Rank: ', 'lbl_io_rank', 'val_ioRank', doc['ioRank']?.toString() ?? '',
                width: 60),
            pw.SizedBox(width: 8),
            inlineField('Number if any: ', 'lbl_io_no', 'val_ioNo', doc['ioNo']?.toString() ?? '',
                width: 60),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Posting and Address: ', style: englishBold),
            mLbl('lbl_io_posting'),
            underlineField('val_ioPosting', doc['ioPosting']?.toString() ?? '', expanded: true),
          ],
        ),
      ],
    );
  }

  // PAGE 1 — Title
  if (showsSection('Search Seizure Form')) {
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (_) => pw.Column(
        children: [
          pw.Spacer(flex: 2),
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text('HOUSE/PROPERTY SEARCH', style: headerStyle),
                pw.Text('& SEIZURI FORM', style: headerStyle),
                pw.SizedBox(height: 8),
                cache.has('title_mr')
                    ? cache.img('title_mr')
                    : pw.Text('घरझडती पंचनामा/ मालमत्ता शोध व जप्तीचा पंचनामा',
                        style: englishStyle),
              ],
            ),
          ),
          pw.Spacer(flex: 3),
          pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Text('M.R.W', style: englishBold),
          ),
        ],
      ),
    ),
  );

  // PAGE 2 — Sections 1–10
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text('HOUSE/PROPERTY SEARCH & SEIZURI FORM',
                    style: headerStyle.copyWith(fontSize: 12),
                    textAlign: pw.TextAlign.center),
                mLbl('title_mr'),
                pw.SizedBox(height: 4),
                pw.Text('(Search/Production/Recovery U/s 185 B.N.S.S. 2023)',
                    style: englishBold, textAlign: pw.TextAlign.center),
                mLbl('lbl_statute'),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: pw.WrapCrossAlignment.end,
            children: [
              inlineField('1.Dist : ', 'lbl_dist', 'val_dist', doc['dist']?.toString() ?? '',
                  width: 55),
              inlineField('P.S: ', 'lbl_ps', 'val_ps', doc['ps']?.toString() ?? '', width: 55),
              inlineField('Year : ', 'lbl_year', 'val_year', doc['year']?.toString() ?? '',
                  width: 35),
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  inlineField('FIR No : ', 'lbl_fir', 'val_firNo', doc['firNo']?.toString() ?? '',
                      width: 40),
                  pw.Text('/20', style: englishBold),
                  underlineField('val_firYearSuffix', doc['firYearSuffix']?.toString() ?? '',
                      width: 22),
                ],
              ),
              inlineField('Date : ', 'lbl_header_date', 'val_headerDate',
                  doc['headerDate']?.toString() ?? '',
                  width: 55),
            ],
          ),
          pw.SizedBox(height: 6),
          wideField('2. Act and Section : ', 'lbl_act', 'val_actSections',
              doc['actSections']?.toString() ?? ''),
          multiline(
            '3. Nature of property seized/Recover: Stolen/Unclaimed/Unlawful procession/Involved/Intestate.',
            'lbl_nature',
            'nature',
            doc['natureProperty']?.toString(),
            minLines: 2,
          ),
          pw.SizedBox(height: 4),
          wideField('4. Name And Address of accused : ', 'lbl_accused', 'val_accusedNameAddress',
              doc['accusedNameAddress']?.toString() ?? ''),
          wideField('(a) Place from where seized/recovered :- ', 'lbl_place_seized',
              'val_placeSeized', doc['placeSeized']?.toString() ?? ''),
          multiline('(b) Description of the place of seizure/recovery : ', 'lbl_place_desc',
              'placeDesc', doc['placeDescription']?.toString(),
              minLines: 2),
          pw.SizedBox(height: 4),
          pw.Text('5. Person form whom seized :-', style: englishBold),
          mLbl('lbl_person_header'),
          pw.SizedBox(height: 2),
          wideField('Professional Receiver of Stolen Property: - Yes/No.', 'lbl_prof_receiver',
              'val_profReceiver', doc['profReceiver']?.toString() ?? ''),
          pw.Row(
            children: [
              inlineField('Name : - ', 'lbl_person_name', 'val_personName',
                  doc['personName']?.toString() ?? '',
                  width: 70),
              pw.SizedBox(width: 6),
              inlineField('Father\'s/Husband\'s Name : ', 'lbl_person_father', 'val_personFather',
                  doc['personFather']?.toString() ?? '',
                  width: 70),
              inlineField('Sex- ', 'lbl_person_sex', 'val_personSex', doc['personSex']?.toString() ?? '',
                  width: 40),
            ],
          ),
          pw.Row(
            children: [
              inlineField('Age : ', 'lbl_person_age', 'val_personAge', doc['personAge']?.toString() ?? '',
                  width: 35),
              pw.SizedBox(width: 6),
              inlineField('Occupation : ', 'lbl_person_occ', 'val_personOccupation',
                  doc['personOccupation']?.toString() ?? '',
                  width: 60),
              inlineField('Address : ', 'lbl_person_addr', 'val_personAddress',
                  doc['personAddress']?.toString() ?? '',
                  width: 80),
            ],
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 8),
            child: underlineField('val_personAddressLine2', doc['personAddressLine2']?.toString() ?? '',
                expanded: true),
          ),
          multiline(
            '6. Action taken/recommended for disposal of perishable property: -',
            'lbl_perishable',
            'perishable',
            doc['perishableDisposal']?.toString(),
            minLines: 2,
          ),
          multiline(
            '7. Action taken/recommended for keeping of valuable property :-',
            'lbl_valuable',
            'valuable',
            doc['valuableKeeping']?.toString(),
            minLines: 2,
          ),
          wideField('8. Identification repuired :- Yes / No.', 'lbl_identification',
              'val_identificationRequired', doc['identificationRequired']?.toString() ?? ''),
          wideField(
            '9. Details of property seized/recovered (Use prescribed form (8) and attach): ',
            'lbl_property_details',
            'val_propertyDetails',
            doc['propertyDetails']?.toString() ?? '',
          ),
          wideField('(1) (Attach separate sheet, if required) :- ', 'lbl_property_attach',
              'val_propertyDetailsAttach', doc['propertyDetailsAttach']?.toString() ?? ''),
          multiline('10. Circumstances/Grounds for seizures :-', 'lbl_circumstances', 'circumstances',
              doc['circumstances']?.toString(),
              minLines: 2),
          pw.Spacer(),
          pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Text('M.R.W', style: englishBold),
          ),
        ],
      ),
    ),
  );
  }

  // PAGE 3 — Sections 11–16
  if (showsSection('Search Seizure Panchanama')) {
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '11) The above mentioned properties were seized in accordance with the provisions of law in the presence of the below said witnesses** and a copy of the seizure memo was given to the person/occupant of the place from whom seized.',
            style: englishStyle,
          ),
          mLbl('lbl_s11'),
          pw.SizedBox(height: 6),
          pw.Text(
            '12) The following properties were packed and/of sealed and the signature of the below said witnesses obtained thereon or on the body of the property.',
            style: englishStyle,
          ),
          mLbl('lbl_s12'),
          pw.SizedBox(height: 4),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FixedColumnWidth(40),
              1: const pw.FlexColumnWidth(),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Column(
                      children: [
                        pw.Text('Sr.No.', style: englishBold, textAlign: pw.TextAlign.center),
                        mLbl('lbl_sr_no'),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Property/ मालमत्ता', style: englishBold,
                        textAlign: pw.TextAlign.center),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('1', style: englishBold),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: _linedPropertyCell(cache, doc['propertyPacked']?.toString() ?? '',
                        valueStyle, englishStyle),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              inlineField('13) Property seized : (a) Date : ', 'lbl_seize_date', 'val_seizeDate',
                  doc['seizeDate']?.toString() ?? '',
                  width: 55),
              pw.SizedBox(width: 6),
              inlineField('(b) Time : ', 'lbl_seize_time_from', 'val_seizeTimeFrom',
                  doc['seizeTimeFrom']?.toString() ?? '',
                  width: 40),
              inlineField('To : ', 'lbl_seize_time_to', 'val_seizeTimeTo',
                  doc['seizeTimeTo']?.toString() ?? '',
                  width: 40),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text('14) witness — / Signature:', style: englishBold),
          mLbl('lbl_witness_header'),
          pw.SizedBox(height: 4),
          witnessBlock('1', 'witness1Line1', 'witness1Line2', 'witness1Line3', 'witness1Sig'),
          pw.SizedBox(height: 4),
          witnessBlock('2', 'witness2Line1', 'witness2Line2', 'witness2Line3', 'witness2Sig'),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    inlineField('15) शिक्याचा नमुना :- Date : ', 'lbl_seal_date', 'val_sealSampleDate',
                        doc['sealSampleDate']?.toString() ?? '',
                        width: 55),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('16) Signature of person from whom seized : ',
                                style: englishBold),
                            mLbl('lbl_seized_sig'),
                          ],
                        ),
                        underlineField('val_seizedPersonSig',
                            doc['seizedPersonSig']?.toString() ?? '',
                            expanded: true),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(child: ioBlock()),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '** In case the property is seized from such a place that no receipt is required to be given to anybody this portion of the sentence should be struck off.',
            style: englishStyle.copyWith(fontStyle: pw.FontStyle.italic),
          ),
          mLbl('lbl_footnote'),
          pw.Spacer(),
          pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Text('M.R.W', style: englishBold),
          ),
        ],
      ),
    ),
  );
  }

  return pdf.save();
}

pw.Widget _linedPropertyCell(
  MarathiImageCache cache,
  String text,
  pw.TextStyle valueStyle,
  pw.TextStyle englishStyle,
) {
  final lines = _splitTextIntoLines(text, 85);
  final count = lines.length > 6 ? lines.length : 6;
  return pw.Column(
    children: List.generate(count, (i) {
      final line = i < lines.length ? lines[i] : '';
      return pw.Container(
        width: double.infinity,
        margin: const pw.EdgeInsets.only(bottom: 2),
        padding: const pw.EdgeInsets.only(left: 4, bottom: 1),
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
        ),
        child: line.isNotEmpty
            ? (containsDevanagari(line) && cache.has('propertyPacked_$i')
                ? cache.img('propertyPacked_$i')
                : pw.Text(line, style: valueStyle))
            : pw.SizedBox(height: 10),
      );
    }),
  );
}

List<String> _splitTextIntoLines(String text, int maxChars) {
  if (text.isEmpty) return [];
  final paragraphs = text.split('\n');
  final result = <String>[];
  for (final para in paragraphs) {
    if (para.isEmpty) {
      result.add('');
      continue;
    }
    final words = para.split(' ');
    var currentLine = '';
    for (final word in words) {
      if (currentLine.isEmpty) {
        currentLine = word;
      } else if ('$currentLine $word'.length <= maxChars) {
        currentLine = '$currentLine $word';
      } else {
        result.add(currentLine);
        currentLine = word;
      }
    }
    if (currentLine.isNotEmpty) result.add(currentLine);
  }
  return result;
}

Future<MarathiImageCache> _preRenderAllMarathi(Map<String, dynamic> doc) async {
  final cache = MarathiImageCache();
  final marathiLabelStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 8,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  final valueStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 8,
    fontWeight: FontWeight.bold,
    color: Colors.blue.shade900,
  );
  await GoogleFonts.pendingFonts();

  Future<void> addLbl(String key, String text, {double maxWidth = 500}) async {
    await cache.add(key, text, marathiLabelStyle, maxWidth: maxWidth);
  }

  Future<void> addVal(String key, String? val, {double maxWidth = 500}) async {
    final text = val?.trim() ?? '';
    if (containsDevanagari(text)) {
      await cache.add(key, text, valueStyle, maxWidth: maxWidth);
    }
  }

  await addLbl('title_mr', 'घरझडती पंचनामा/ मालमत्ता शोध व जप्तीचा पंचनामा');
  await addLbl('lbl_statute',
      '(कलम १८५ भारतीय नागरी संरक्षण अधिनियम २०२३ अन्वये झडती/हजर करणे/परत मिळविणे)');
  await addLbl('lbl_dist', 'जिल्हा');
  await addLbl('lbl_ps', 'पोलीस स्टेशन');
  await addLbl('lbl_year', 'वर्ष');
  await addLbl('lbl_fir', 'पहिली खबर क्र.');
  await addLbl('lbl_header_date', 'तारीख');
  await addLbl('lbl_act', 'अधिनियम व कलमे');
  await addLbl('lbl_nature', 'जप्त केलेल्या / मिळालेल्या मालमत्तेचे स्वरूप');
  await addLbl('lbl_accused', 'आरोपीचे नांव व पत्ता');
  await addLbl('lbl_place_seized', 'जेथुन जप्त केली / परत मिळवली ती जागा');
  await addLbl('lbl_place_desc', 'जप्तीच्या परत मिळवल्याच्या जागेचे वर्णन /चतु सिमा');
  await addLbl('lbl_person_header', 'कोणाकडून जप्त केली');
  await addLbl('lbl_prof_receiver', 'चोरीचा माल घेणारा धंदेवाईक :- होय/ नाही');
  await addLbl('lbl_person_name', 'नांव');
  await addLbl('lbl_person_father', 'वडील/ पतीचे नांव');
  await addLbl('lbl_person_sex', 'लिंग');
  await addLbl('lbl_person_age', 'वय');
  await addLbl('lbl_person_occ', 'व्यवसाय');
  await addLbl('lbl_person_addr', 'पत्ता');
  await addLbl('lbl_perishable', 'नाशवंत मालमत्तेच्या विल्हेवाटीसाठी केलेली शिफारस / केलेली कार्यवाही');
  await addLbl('lbl_valuable', 'मौल्यवान मालमत्ता ठेवण्यासाठी केलेली शिफारस / केलेली कार्यवाही');
  await addLbl('lbl_identification', 'ओळख पटवावी लागली काय :- होय/ नाही');
  await addLbl('lbl_property_details', 'जप्त केलेल्या / परत मिळालेल्या मालाचे वर्णन');
  await addLbl('lbl_property_attach', 'आवश्यक असल्यास स्वतंत्र कागद जोडा');
  await addLbl('lbl_circumstances', 'जप्तीची परिस्थिती/ कारणे');
  await addLbl('lbl_s11',
      'वरील मालमत्ता खालील साक्षीदारांच्या समक्ष कायद्याच्या तरतुदीनुसार जप्त केली व ज्यांच्याकडून जप्त केली त्यांना/ त्या ठिकाणी राहणाऱ्यास जप्तीच्या पंचनाम्याची प्रत देण्यात आली.');
  await addLbl('lbl_s12', 'खालील मालमत्ता पोत्यात बंद/शिक्का मारून खालील साक्षीदारांची सही घेण्यात आली.');
  await addLbl('lbl_sr_no', 'अनु.क्र');
  await addLbl('lbl_seize_date', 'जप्त केलेली मालमत्ता दिनांक');
  await addLbl('lbl_seize_time_from', 'वेळ');
  await addLbl('lbl_seize_time_to', 'ते');
  await addLbl('lbl_witness_header', 'साक्षीदारांचे नांव व पत्ता / सह्या');
  await addLbl('lbl_seal_date', 'दिनांक');
  await addLbl('lbl_seized_sig', 'ज्यांच्याकडून माल जप्त केला त्याची सही');
  await addLbl('lbl_io_header', FormIoTerminology.signatureHeader);
  await addLbl('lbl_io_name', FormIoTerminology.name);
  await addLbl('lbl_io_rank', FormIoTerminology.rank);
  await addLbl('lbl_io_no', FormIoTerminology.badgeNo);
  await addLbl('lbl_io_posting', FormIoTerminology.posting);
  await addLbl('lbl_footnote',
      'जर मालमत्ता अशा ठिकाणीून जप्त केली की कोणालाही पावती देण्याची आवश्यकता नसेल तर वाक्याचा हा भाग काढून टाकावा.');

  const valueKeys = [
    'dist', 'ps', 'year', 'firNo', 'firYearSuffix', 'headerDate', 'actSections',
    'natureProperty', 'accusedNameAddress', 'placeSeized', 'placeDescription',
    'profReceiver', 'personName', 'personFather', 'personSex', 'personAge',
    'personOccupation', 'personAddress', 'personAddressLine2', 'perishableDisposal',
    'valuableKeeping', 'identificationRequired', 'propertyDetails', 'propertyDetailsAttach',
    'circumstances', 'propertyPacked', 'seizeDate', 'seizeTimeFrom', 'seizeTimeTo',
    'witness1Line1', 'witness1Line2', 'witness1Line3', 'witness1Sig',
    'witness2Line1', 'witness2Line2', 'witness2Line3', 'witness2Sig',
    'sealSampleDate', 'seizedPersonSig', 'ioName', 'ioRank', 'ioNo', 'ioPosting',
  ];
  for (final key in valueKeys) {
    await addVal('val_$key', doc[key]?.toString());
  }

  for (final entry in [
    ('nature', doc['natureProperty']?.toString() ?? ''),
    ('placeDesc', doc['placeDescription']?.toString() ?? ''),
    ('perishable', doc['perishableDisposal']?.toString() ?? ''),
    ('valuable', doc['valuableKeeping']?.toString() ?? ''),
    ('circumstances', doc['circumstances']?.toString() ?? ''),
    ('propertyPacked', doc['propertyPacked']?.toString() ?? ''),
  ]) {
    final lines = _splitTextIntoLines(entry.$2, 90);
    for (var i = 0; i < lines.length; i++) {
      if (containsDevanagari(lines[i])) {
        await cache.add('${entry.$1}_$i', lines[i], valueStyle, maxWidth: 480);
      }
    }
  }

  return cache;
}
