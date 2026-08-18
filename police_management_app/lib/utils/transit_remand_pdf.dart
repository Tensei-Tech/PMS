import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> previewTransitRemandPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) async {
  final bytes = await generateTransitRemandPdf(doc);
  if (!context.mounted) return;
  final fileName = 'Transit_Remand_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

Future<Uint8List> generateTransitRemandPdf(Map<String, dynamic> doc) async {
  final pdf = pw.Document();
  final loraRegular = await PdfGoogleFonts.loraRegular();
  final loraBold = await PdfGoogleFonts.loraBold();
  final devanagari = await PdfGoogleFonts.notoSansDevanagariRegular();

  final body = pw.TextStyle(font: loraRegular, fontSize: 10);
  final bold = pw.TextStyle(font: loraBold, fontSize: 12, fontWeight: pw.FontWeight.bold);
  final mr = pw.TextStyle(font: devanagari, fontSize: 9);

  String v(String key) => doc[key]?.toString().trim() ?? '';

  pw.Widget row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 160, child: pw.Text(label, style: bold)),
          pw.Expanded(child: pw.Text(value.isEmpty ? '—' : value, style: body)),
        ],
      ),
    );
  }

  final isEnglish = v('variant') == 'english' ||
      v('formSection').toLowerCase().contains('english');

  if (isEnglish) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Requisition to Transit Remand', style: bold),
            pw.Text('ट्रान्झिट रिमांड अर्ज', style: mr),
            pw.SizedBox(height: 10),
            row('Outward / Date', '${v('eOutwardNo')} / ${v('eDate')}'),
            row('Police Station', v('ePsName')),
            row('To Court', '${v('eCourtToLine1')} ${v('eCourtToLine2')}'),
            row('Report by', '${v('eReportByName')} (${v('eReportByRank')})'),
            row('FIR / Sections', '${v('eFirNo')} ${v('eIpcSections')}'),
            row('Complainant', '${v('eComplainantName')}, ${v('eComplainantAge')}'),
            row('Accused 1', '${v('eAccused1Name')} ${v('eAccused1Details')}'),
            row('Arrested', v('eArrestedName')),
            row('Arrest PS / SD', '${v('eArrestPs')} ${v('eSdNo')}'),
            row('Court / Hours', '${v('eCourtName')} — ${v('eRemandHours')} hrs'),
            row('Summary', v('eIncidentSummary')),
          ],
        ),
      ),
    );
  } else {
    final section = v('formSection').toLowerCase();
    final showP1 = section.isEmpty ||
        (!section.contains('page 2') && !section.contains('police assist'));
    final showP2 = section.isEmpty ||
        section.contains('page 2') ||
        section.contains('police assist');

    if (showP1) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Requisition to Transit Remand', style: bold),
              pw.SizedBox(height: 10),
              row('Court', '${v('m1CourtName')} ${v('m1CourtCity')} ${v('m1CourtState')}'),
              row('PS', '${v('m1PsName')} ${v('m1PsCity')}'),
              row('CR No.', '${v('m1CrNo')} ${v('m1CrSections')}'),
              row('Accused', '${v('m1AccusedName')} (${v('m1AccusedAge')})'),
              row('Address', v('m1AccusedAddress')),
              row('Arrest', '${v('m1ArrestDateTime')} at ${v('m1ArrestPlace')}'),
              row('Remand', '${v('m1RemandFrom')} for ${v('m1RemandDays')} days'),
              row('Produce at', v('m1ProduceCourt')),
              row('Officer', '${v('m1OfficerName')} ${v('m1OfficerRank')}'),
            ],
          ),
        ),
      );
    }
    if (showP2) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Police Assistance Request', style: bold),
              pw.SizedBox(height: 10),
              row('To PS', v('m2RecipientPs')),
              row('Ref CR', '${v('m2RefCrNo')} ${v('m2RefSections')}'),
              row('Wanted accused', '${v('m2AccusedName')} (${v('m2AccusedAge')})'),
              row('Address', v('m2AccusedAddress')),
              row('Officer', '${v('m2OfficerName')} ${v('m2OfficerPs')}'),
            ],
          ),
        ),
      );
    }
  }

  return pdf.save();
}
