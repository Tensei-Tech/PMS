import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'form_io_terminology.dart';

Future<void> previewReasonOfArrestPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) async {
  final bytes = await generateReasonOfArrestPdf(doc);
  if (!context.mounted) return;
  final fileName =
      'Reason_of_Arrest_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

Future<Uint8List> generateReasonOfArrestPdf(Map<String, dynamic> doc) async {
  final pdf = pw.Document();
  final loraRegular = await PdfGoogleFonts.loraRegular();
  final loraBold = await PdfGoogleFonts.loraBold();
  final devanagari = await PdfGoogleFonts.notoSansDevanagariRegular();
  final devanagariBold = await PdfGoogleFonts.notoSansDevanagariBold();

  final body = pw.TextStyle(font: loraRegular, fontSize: 10);
  final bold = pw.TextStyle(font: loraBold, fontSize: 11, fontWeight: pw.FontWeight.bold);
  final title = pw.TextStyle(font: loraBold, fontSize: 14, fontWeight: pw.FontWeight.bold);
  final mr = pw.TextStyle(font: devanagari, fontSize: 9);
  final mrBold = pw.TextStyle(font: devanagariBold, fontSize: 10);

  String v(String key) => doc[key]?.toString().trim() ?? '';

  pw.Widget row(String en, String mrLabel, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(en, style: bold),
          pw.Text(mrLabel, style: mr),
          pw.Text(value.isEmpty ? '—' : value, style: body),
        ],
      ),
    );
  }

  final section = v('formSection').toLowerCase();
  final showMain =
      section.isEmpty || (section.contains('main') && !section.contains('continuation'));
  final showCont = section.isEmpty || section.contains('continuation');

  if (showMain) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text('NOTICE — Section 35(1)(b)(ii) BNSS', style: title),
            ),
            pw.Center(child: pw.Text('सूचनापत्र', style: mrBold)),
            pw.SizedBox(height: 12),
            row('Outward No.', 'जावक क्र.', '${v('outwardNo')}/${v('outwardYear')}'),
            row('Police Station', 'पोलीस स्टेशन', v('policeStation')),
            row('To', 'प्रति', v('accusedNameAddress')),
            row('CR No.', 'ग.र.क्र.', v('subjectCrNo')),
            row('Section / BNS', 'कलम', '${v('subjectSection')} ${v('subjectBns')}'),
            row('IO', 'तपासी अधिकारी', v('ioName')),
            row('Brief description', 'संक्षिप्त विवरण', v('briefDescription')),
            pw.SizedBox(height: 8),
            pw.Text('Reasons for Arrest', style: bold),
            for (var i = 1; i <= 5; i++) row('Reason $i', '$i.', v('reason$i')),
          ],
        ),
      ),
    );
  }

  if (showCont) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            row('Relative informed', 'नातेवाईक', '${v('relativeName')} ${v('relativeAddress')} ${v('relativePhone')}'),
            row('Accused sig / date', 'आरोपी', '${v('accusedSig')} ${v('accusedDateTime')}'),
            row('IO sig / rank / PS', FormIoTerminology.officer, '${v('ioSig')} ${v('ioNameRank')} ${v('ioPs')}'),
          ],
        ),
      ),
    );
  }

  return pdf.save();
}
