import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> previewDraftGroundOfArrestPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) async {
  final bytes = await generateDraftGroundOfArrestPdf(doc);
  if (!context.mounted) return;
  final fileName =
      'Draft_Ground_of_Arrest_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

int? _activeSection(String section) {
  final s = section.toLowerCase().trim();
  if (s.isEmpty) return null;
  if (s.contains('pcr') || s.contains('police custody')) return 3;
  if (s.contains('reason of arrest') || s.contains('reason for arrest')) {
    return 2;
  }
  if (s.contains('ground of arrest')) return 1;
  return null;
}

Future<Uint8List> generateDraftGroundOfArrestPdf(
  Map<String, dynamic> doc,
) async {
  final pdf = pw.Document();
  final loraRegular = await PdfGoogleFonts.loraRegular();
  final loraBold = await PdfGoogleFonts.loraBold();
  final devanagari = await PdfGoogleFonts.notoSansDevanagariRegular();
  final devanagariBold = await PdfGoogleFonts.notoSansDevanagariBold();

  final body = pw.TextStyle(font: loraRegular, fontSize: 10);
  final bold = pw.TextStyle(font: loraBold, fontSize: 11, fontWeight: pw.FontWeight.bold);
  final title = pw.TextStyle(font: loraBold, fontSize: 14, fontWeight: pw.FontWeight.bold);
  final mr = pw.TextStyle(font: devanagari, fontSize: 9);
  final mrBold = pw.TextStyle(font: devanagariBold, fontSize: 10, fontWeight: pw.FontWeight.bold);

  String v(String key) => doc[key]?.toString().trim() ?? '';
  bool b(String key) => doc[key] == true;

  pw.Widget row(String labelEn, String labelMr, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(labelEn, style: bold),
          pw.Text(labelMr, style: mr),
          pw.SizedBox(height: 2),
          pw.Text(value.isEmpty ? '—' : value, style: body),
        ],
      ),
    );
  }

  pw.Widget checkRow(String labelEn, String labelMr, bool checked) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(checked ? '[✓] ' : '[ ] ', style: bold),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(labelEn, style: body),
                pw.Text(labelMr, style: mr),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final section = _activeSection(v('formSection'));
  final showI = section == null || section == 1;
  final showII = section == null || section == 2;
  final showIII = section == null || section == 3;

  if (showI) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Ground of Arrest — Reference', style: title),
            pw.Text('अटकेचा आधार — संदर्भ', style: mrBold),
            pw.SizedBox(height: 12),
            pw.Text(
              'BNSS 2023 Sections 47, 48, 35(1)(b) and Supreme Court judgments '
              '(Pankaj Bansal 2023, Prabir Purkayastha 2024, Vihaan Kumar 2025, '
              'Mihir Shah 2025) require written Grounds and Reasons of Arrest.',
              style: body,
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Section 47: Grounds of Arrest must detail specific evidence, not merely cite a section.',
              style: body,
            ),
            pw.Text(
              'Section 35(1)(b): Five specific reasons mandatory for offences ≤7 years.',
              style: body,
            ),
            pw.Text(
              'Section 48: Relatives/friends must be informed in writing.',
              style: body,
            ),
          ],
        ),
      ),
    );
  }

  if (showII) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Reason of Arrest — Reference', style: title),
            pw.Text('अटकेचे कारणे — संदर्भ', style: mrBold),
            pw.SizedBox(height: 12),
            pw.Text('Ground vs Reason vs PCR:', style: bold),
            pw.Text('• Ground (S.47): Prima facie evidence — all offences', style: body),
            pw.Text('• Reason (S.35(1)(b)): 5 specific reasons — ≤7 yr offences', style: body),
            pw.Text('• PCR (S.187): Custody necessity — all offences', style: body),
            pw.SizedBox(height: 12),
            pw.Text('Record at: accused notice, relative notice, station diary, arrest panchanama col. 8, remand report, case diary.', style: body),
          ],
        ),
      ),
    );
  }

  if (showIII) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Ground of Arrest (Section 47 BNSS)', style: title),
            pw.Text('अटकेचा आधार (कलम ४७ BNSS)', style: mrBold),
            pw.SizedBox(height: 10),
            row('Accused name', 'अटक केलेल्या आरोपीचे नाव', v('accusedName')),
            row('Age / Address', 'वय / पत्ता', '${v('accusedAge')} / ${v('accusedAddress')}'),
            row('PS / CR No. / BNS', 'ठाणे / ग.र.क्र. / कलम', '${v('psName')} / ${v('crNo')} / ${v('bnsSection')}'),
            row('Arrest date/time', 'अटक दिनांक/वेळ', '${v('arrestDate')} ${v('arrestTime')}'),
            row('Brief facts', 'गुन्ह्याची हकीकत', v('briefFacts')),
            pw.SizedBox(height: 8),
            pw.Text('Grounds of Arrest:', style: bold),
            checkRow('FIR allegations', 'FIR मधील आरोप', b('goaG1')),
            checkRow('Eyewitness', 'साक्षीदार', b('goaG2')),
            checkRow('CCTV/digital', 'CCTV/डिजिटल', b('goaG3')),
            checkRow('Recovery', 'जप्ती', b('goaG4')),
            checkRow('Confession', 'कबुली', b('goaG5')),
            checkRow('Co-accused', 'सह-आरोपी', b('goaG6')),
            checkRow('CDR location', 'CDR', b('goaG7')),
            row('Witness name', 'साक्षीदाराचे नाव', v('goaWitnessName')),
            row('Co-accused name', 'सह-आरोपीचे नाव', v('goaCoAccused')),
            row('Kin informed', 'नातेवाईक', v('goaKinName')),
            row('Officer', 'पोलीस अधिकारी', '${v('goaOfficerName')} ${v('goaOfficerRank')}'),
            row('Date', 'दिनांक', v('goaFooterDate')),
          ],
        ),
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Relative Notice (Section 48 BNSS)', style: title),
            pw.Text('नातेवाईक/मित्रांसाठी नोटीस (कलम ४८)', style: mrBold),
            pw.SizedBox(height: 10),
            row('Relative name', 'नातेवाईकाचे नाव', v('s48RelativeName')),
            row('Age / Address', 'वय / पत्ता', '${v('s48RelativeAge')} / ${v('s48RelativeAddress')}'),
            row('Relationship', 'नाते', v('s48Relationship')),
            row('Detention PS', 'ठेवण्याचे ठाणे', v('s48CustodyPs')),
            checkRow('FIR mention', 'FIR', b('s48G1')),
            checkRow('Eyewitness', 'साक्षीदार', b('s48G2')),
            checkRow('CCTV', 'CCTV', b('s48G3')),
            checkRow('Confession', 'कबुली', b('s48G5')),
            checkRow('Co-accused', 'सह-आरोपी', b('s48G6')),
            row('Date / Place', 'दिनांक / ठिकाण', '${v('s48Date')} / ${v('s48Place')}'),
          ],
        ),
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Reason of Arrest (Section 35(1)(b))', style: title),
            pw.Text('अटकेचे कारणे (कलम ३५(१)(ब))', style: mrBold),
            pw.SizedBox(height: 10),
            checkRow('Prevent further crimes', 'पुढील गुन्हे टाळणे', b('roaR1')),
            checkRow('Proper investigation', 'योग्य तपास', b('roaR2')),
            checkRow('Prevent evidence tampering', 'पुरावे रोखणे', b('roaR3')),
            checkRow('Prevent witness inducement', 'साक्षीदार रोखणे', b('roaR4')),
            checkRow('Ensure court presence', 'न्यायालयात उपस्थिती', b('roaR5')),
            row('Date / Place', 'दिनांक / ठिकाण', '${v('roaDate')} / ${v('roaPlace')}'),
            pw.SizedBox(height: 16),
            pw.Text('Reasons for PCR', style: title),
            pw.Text('पोलिस कोठडीची कारणे', style: mrBold),
            pw.SizedBox(height: 8),
            checkRow('Weapon seizure pending', 'हत्यार जप्त', b('pcr1')),
            checkRow('Ascertain motive', 'हेतू', b('pcr2')),
            checkRow('Identify co-accused', 'सह-आरोपी', b('pcr3')),
            checkRow('Recover stolen property', 'माल जप्त', b('pcr4')),
            checkRow('Seize vehicle', 'वाहन जप्त', b('pcr5')),
            checkRow('Seize clothing', 'कपडे जप्त', b('pcr6')),
            checkRow('Blood sample pending', 'ब्लड सॅम्पल', b('pcr7')),
            row('Other', 'इत्यादी', v('pcrOther')),
          ],
        ),
      ),
    );
  }

  return pdf.save();
}
