import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'marathi_text_renderer.dart';
import '../widgets/form_section_utils.dart';

Future<void> previewFinalReportPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) async {
  final bytes = await generateFinalReportPdf(doc);
  if (!context.mounted) return;
  final fileName =
      'Final_Report_Form_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

Future<Uint8List> generateFinalReportPdf(Map<String, dynamic> doc) async {
  final pdf = pw.Document();
  final loraRegular = await PdfGoogleFonts.loraRegular();
  final loraBold = await PdfGoogleFonts.loraBold();
  final cache = await _preRenderAllMarathi(doc);

  const knownSectionIds = {
    'Final Report Part I',
    'Final Report Part II',
    'Final Report Part III',
  };
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

  pw.Widget val(String key, String? text) {
    final t = text?.trim() ?? '';
    if (t.isEmpty) return pw.SizedBox();
    if (containsDevanagari(t) && cache.has(key)) return cache.img(key);
    return pw.Text(t, style: valueStyle);
  }

  pw.Widget field(String label, String key, String? fallback) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(label, style: englishBold),
          pw.Expanded(
            child: pw.Container(
              decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
              padding: const pw.EdgeInsets.only(left: 4, bottom: 1),
              child: val(key, fallback),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget multiline(String label, String key, String? text, {int lines = 4}) {
    final content = text?.trim() ?? '';
    final split = _splitLines(content, 90);
    final count = split.length > lines ? split.length : lines;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: englishBold),
        pw.SizedBox(height: 2),
        for (var i = 0; i < count; i++)
          pw.Container(
            width: double.infinity,
            margin: const pw.EdgeInsets.only(bottom: 2),
            padding: const pw.EdgeInsets.only(left: 4, bottom: 1),
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
            child: i < split.length ? val('${key}_$i', split[i]) : pw.SizedBox(height: 10),
          ),
      ],
    );
  }

  // PAGE 1
  if (showsSection('Final Report Part I')) {
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(child: pw.Text('FINAL REPORT FORM', style: headerStyle)),
          pw.SizedBox(height: 4),
          pw.Center(child: cache.has('title_mr') ? cache.img('title_mr') : pw.Text('अंतिम अहवाल नमुना', style: englishStyle)),
          pw.SizedBox(height: 4),
          pw.Center(child: pw.Text('( UNDER SECTION 193 B.N.S.S.2023 )', style: englishBold)),
          pw.SizedBox(height: 10),
          field('1.Dist: ', 'val_dist', doc['dist']?.toString()),
          field('P.S: ', 'val_ps', doc['ps']?.toString()),
          field('Year: ', 'val_year', doc['year']?.toString()),
          field('FIR No: ', 'val_firNo', doc['firNo']?.toString()),
          field('Date: ', 'val_headerDate', doc['headerDate']?.toString()),
          field('2. Final Report/Charge Sheet No. ', 'val_reportNo', doc['reportNo']?.toString()),
          field('3. Date: ', 'val_reportDate', doc['reportDate']?.toString()),
          field('4. Act: ', 'val_act', doc['act']?.toString()),
          field('Section: ', 'val_section', doc['section']?.toString()),
          multiline('5. Type of Final Form / Report:', 'reportType', doc['reportType']?.toString(), lines: 2),
          multiline('6. If F.R. Unoccured:', 'frUnoccurred', doc['frUnoccurred']?.toString(), lines: 2),
          field('7. If Charge Sheeted: ', 'val_chargeSheeted', doc['chargeSheeted']?.toString()),
          field('Original/Supplementary: ', 'val_origSupp', doc['originalSupplementary']?.toString()),
          field('8. Name of I.O: ', 'val_ioName', doc['ioName']?.toString()),
          field('Rank: ', 'val_ioRank', doc['ioRank']?.toString()),
          field('No: ', 'val_ioNo', doc['ioNo']?.toString()),
          field('P.S: ', 'val_ioPs', doc['ioPs']?.toString()),
          field('9.(a) Complainant: ', 'val_complainantName', doc['complainantName']?.toString()),
          field('(b) Father/Husband: ', 'val_complainantFather', doc['complainantFather']?.toString()),
          pw.SizedBox(height: 6),
          pw.Text('10. Properties recovered/seized:', style: englishBold),
          pw.SizedBox(height: 4),
          for (var i = 1; i <= 2; i++) ...[
            pw.Text('$i.', style: englishBold),
            field('  Description: ', 'val_prop${i}Desc', doc['prop${i}Desc']?.toString()),
            field('  Value: ', 'val_prop${i}Value', doc['prop${i}Value']?.toString()),
            field('  Reg No: ', 'val_prop${i}Reg', doc['prop${i}Reg']?.toString()),
            field('  From: ', 'val_prop${i}From', doc['prop${i}From']?.toString()),
            field('  Disposal: ', 'val_prop${i}Disposal', doc['prop${i}Disposal']?.toString()),
          ],
          pw.Spacer(),
          pw.Align(alignment: pw.Alignment.bottomRight, child: pw.Text('M.R.W', style: englishBold)),
        ],
      ),
    ),
  );
  }

  // PAGE 2 — Form 5-B
  if (showsSection('Final Report Part II')) {
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Align(alignment: pw.Alignment.topRight, child: pw.Text('Form : 5-B', style: englishBold)),
          pw.SizedBox(height: 6),
          pw.Text('11. Particulars of accused charge-sheeted:', style: englishBold),
          field('(i) Name: ', 'val_accName', doc['accName']?.toString()),
          field('Where verified: ', 'val_accNameVerified', doc['accNameVerified']?.toString()),
          field('(ii) Father/Husband: ', 'val_accFather', doc['accFather']?.toString()),
          field('(iii) DOB: ', 'val_accDob', doc['accDob']?.toString()),
          field('Age: ', 'val_accAge', doc['accAge']?.toString()),
          field('(iv) Sex: ', 'val_accSex', doc['accSex']?.toString()),
          field('(v) Nationality: ', 'val_accNationality', doc['accNationality']?.toString()),
          field('(vi) Passport: ', 'val_accPassport', doc['accPassport']?.toString()),
          field('(vii) Religion: ', 'val_accReligion', doc['accReligion']?.toString()),
          field('(viii) SC/ST: ', 'val_accScSt', doc['accScSt']?.toString()),
          field('(ix) Occupation: ', 'val_accOccupation', doc['accOccupation']?.toString()),
          field('(x) Address: ', 'val_accAddress', doc['accAddress']?.toString()),
          field('(xi) Prov. Criminal No: ', 'val_accProvCriminalNo', doc['accProvCriminalNo']?.toString()),
          field('(xii) Regular Criminal No: ', 'val_accRegularCriminalNo', doc['accRegularCriminalNo']?.toString()),
          field('(xiii) Arrest Date: ', 'val_accArrestDate', doc['accArrestDate']?.toString()),
          field('(xiv) Bail Date: ', 'val_accBailDate', doc['accBailDate']?.toString()),
          field('(xv) Forwarded to court: ', 'val_accForwardedCourt', doc['accForwardedCourt']?.toString()),
          field('(xvi) Acts & Sections: ', 'val_accActsSections', doc['accActsSections']?.toString()),
          field('(xvii) Bailers: ', 'val_accBailers', doc['accBailers']?.toString()),
          field('(xviii) Prev convictions: ', 'val_accPrevConvictions', doc['accPrevConvictions']?.toString()),
          field('(xix) Status: ', 'val_accStatus', doc['accStatus']?.toString()),
          multiline('12. Not charge-sheeted:', 'notChargeSheeted', doc['notChargeSheeted']?.toString(), lines: 2),
          pw.Spacer(),
          pw.Align(alignment: pw.Alignment.bottomRight, child: pw.Text('M.R.W', style: englishBold)),
        ],
      ),
    ),
  );
  }

  // PAGE 3
  if (showsSection('Final Report Part III')) {
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('13. Verified witnesses:', style: englishBold),
          pw.SizedBox(height: 4),
          for (var i = 1; i <= 7; i++) ...[
            pw.Text('$i.', style: englishBold),
            field('  Name: ', 'val_witness${i}Name', doc['witness${i}Name']?.toString()),
            field('  Age: ', 'val_witness${i}Age', doc['witness${i}Age']?.toString()),
            field('  Occupation: ', 'val_witness${i}Occupation', doc['witness${i}Occupation']?.toString()),
            field('  Address: ', 'val_witness${i}Address', doc['witness${i}Address']?.toString()),
            pw.SizedBox(height: 2),
          ],
          multiline('14. False FIR action:', 'falseFirAction', doc['falseFirAction']?.toString(), lines: 3),
          field('15. Lab analysis: ', 'val_labAnalysis', doc['labAnalysis']?.toString()),
          pw.Spacer(),
          pw.Align(alignment: pw.Alignment.bottomRight, child: pw.Text('M.R.W', style: englishBold)),
        ],
      ),
    ),
  );

  // PAGE 4 — Form 5-E
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Align(alignment: pw.Alignment.topRight, child: pw.Text('Form : 5-E', style: englishBold)),
          pw.SizedBox(height: 6),
          multiline('16. Brief Facts:', 'briefFacts', doc['briefFacts']?.toString(), lines: 10),
          field('17. Refer Notice Served: ', 'val_referNoticeServed', doc['referNoticeServed']?.toString()),
          field('Date: ', 'val_referNoticeDate', doc['referNoticeDate']?.toString()),
          field('18. Dispatched on: ', 'val_dispatchedOn', doc['dispatchedOn']?.toString()),
          pw.SizedBox(height: 8),
          pw.Text('SHO:', style: englishBold),
          field('Name: ', 'val_shoName', doc['shoName']?.toString()),
          field('Rank: ', 'val_shoRank', doc['shoRank']?.toString()),
          field('No: ', 'val_shoNo', doc['shoNo']?.toString()),
          field('P.S: ', 'val_shoPs', doc['shoPs']?.toString()),
          pw.SizedBox(height: 6),
          pw.Text('Submitting I.O:', style: englishBold),
          field('Name: ', 'val_submitIoName', doc['submitIoName']?.toString()),
          field('Rank: ', 'val_submitIoRank', doc['submitIoRank']?.toString()),
          field('No: ', 'val_submitIoNo', doc['submitIoNo']?.toString()),
          field('P.S: ', 'val_submitIoPs', doc['submitIoPs']?.toString()),
          pw.Spacer(),
          pw.Align(alignment: pw.Alignment.bottomRight, child: pw.Text('M.R.W', style: englishBold)),
        ],
      ),
    ),
  );
  }

  return pdf.save();
}

List<String> _splitLines(String text, int maxChars) {
  if (text.isEmpty) return [];
  final result = <String>[];
  for (final para in text.split('\n')) {
    if (para.isEmpty) {
      result.add('');
      continue;
    }
    var line = '';
    for (final word in para.split(' ')) {
      if (line.isEmpty) {
        line = word;
      } else if ('$line $word'.length <= maxChars) {
        line = '$line $word';
      } else {
        result.add(line);
        line = word;
      }
    }
    if (line.isNotEmpty) result.add(line);
  }
  return result;
}

Future<MarathiImageCache> _preRenderAllMarathi(Map<String, dynamic> doc) async {
  final cache = MarathiImageCache();
  final labelStyle = GoogleFonts.notoSansDevanagari(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black);
  final valueStyle = GoogleFonts.notoSansDevanagari(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue.shade900);
  await GoogleFonts.pendingFonts();
  await cache.add('title_mr', 'अंतिम अहवाल नमुना', labelStyle);

  Future<void> addVal(String key, String? v) async {
    final t = v?.trim() ?? '';
    if (containsDevanagari(t)) await cache.add(key, t, valueStyle, maxWidth: 480);
  }

  final keys = [
    'dist', 'ps', 'year', 'firNo', 'headerDate', 'reportNo', 'reportDate', 'act', 'section',
    'chargeSheeted', 'originalSupplementary', 'ioName', 'ioRank', 'ioNo', 'ioPs',
    'complainantName', 'complainantFather', 'accName', 'accFather', 'accAddress', 'labAnalysis',
    'shoName', 'shoRank', 'shoPs', 'submitIoName', 'submitIoRank', 'submitIoPs',
  ];
  for (final k in keys) {
    await addVal('val_$k', doc[k]?.toString());
  }
  for (var i = 1; i <= 2; i++) {
    for (final col in ['Desc', 'Value', 'Reg', 'From', 'Disposal']) {
      await addVal('val_prop$i$col', doc['prop$i$col']?.toString());
    }
  }
  for (var i = 1; i <= 7; i++) {
    for (final col in ['Name', 'Age', 'Occupation', 'Address']) {
      await addVal('val_witness$i$col', doc['witness$i$col']?.toString());
    }
  }
  for (final entry in [
    ('reportType', doc['reportType']?.toString() ?? ''),
    ('frUnoccurred', doc['frUnoccurred']?.toString() ?? ''),
    ('notChargeSheeted', doc['notChargeSheeted']?.toString() ?? ''),
    ('falseFirAction', doc['falseFirAction']?.toString() ?? ''),
    ('briefFacts', doc['briefFacts']?.toString() ?? ''),
  ]) {
    final lines = _splitLines(entry.$2, 90);
    for (var i = 0; i < lines.length; i++) {
      if (containsDevanagari(lines[i])) {
        await cache.add('${entry.$1}_$i', lines[i], valueStyle, maxWidth: 480);
      }
    }
  }
  return cache;
}
