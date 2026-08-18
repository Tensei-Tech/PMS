import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> previewInterrogationFormPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) async {
  final bytes = await generateInterrogationFormPdf(doc);
  if (!context.mounted) return;
  final fileName = 'Interrogation_Form_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

int? _activePart(String section) {
  final s = section.toLowerCase().trim();
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

Future<Uint8List> generateInterrogationFormPdf(Map<String, dynamic> doc) async {
  final pdf = pw.Document();
  final loraRegular = await PdfGoogleFonts.loraRegular();
  final loraBold = await PdfGoogleFonts.loraBold();

  final body = pw.TextStyle(font: loraRegular, fontSize: 10);
  final bold = pw.TextStyle(font: loraBold, fontSize: 11, fontWeight: pw.FontWeight.bold);
  final title = pw.TextStyle(font: loraBold, fontSize: 14, fontWeight: pw.FontWeight.bold);

  String v(String key) => doc[key]?.toString().trim() ?? '';

  pw.Widget row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 180, child: pw.Text(label, style: bold)),
          pw.Expanded(child: pw.Text(value.isEmpty ? '—' : value, style: body)),
        ],
      ),
    );
  }

  pw.Widget listSection(String heading, List<String> labels, String listKey) {
    final raw = doc[listKey];
    final values = raw is List ? raw.map((e) => e?.toString() ?? '').toList() : <String>[];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(heading, style: title),
        pw.SizedBox(height: 8),
        for (var i = 0; i < labels.length; i++)
          row(labels[i], i < values.length ? values[i] : ''),
      ],
    );
  }

  const familyLabels = [
    '11. Occupation',
    '12. Parents',
    '13. Children',
    '14. Siblings',
    '15. In-laws (sister/brother)',
    '16. Mother/Father-in-law',
    '17. Brother/Sister-in-law',
    '18. Maternal uncle/aunt',
    '19. Paternal uncle/aunt',
    '20. Cousin',
    '21. Aunt/Uncle',
  ];

  const idHistoryLabels = [
    '22. Education / computer knowledge',
    '23. Previous workplace address',
    '24. Aadhaar',
    '25. PAN',
    '26. Driving licence',
    '27. Ration card',
    '28. Property estimate',
    '29. Prior convictions',
    '30. Accomplices in this crime',
  ];

  const crimeLabels = [
    '31. Places of stay',
    '32. Crime scene / building / origin',
    '33. Vehicles used',
    '34. Weapons used',
    '35. Direction of approach',
    '36. Direction of escape',
    '37. Modus operandi',
    '38. Stolen property info',
    '39. Identifying officers',
    '40. Advisories',
  ];

  final part = _activePart(v('formSection'));
  final showI = part == null || part == 1;
  final showII = part == null || part == 2;
  final showIII = part == null || part == 3;
  final showIV = part == null || part == 4;
  final showV = part == null || part == 5;

  if (showI) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Center(
            child: pw.Text('Interrogation Report (Chaukashi Ahaval)', style: title),
          ),
          pw.SizedBox(height: 12),
          row('Police Station', v('ps')),
          row('G.R. No.', v('gurNo')),
          row('Section', v('kalam')),
          row('I.O. Name & Rank', v('ioName')),
          row('Accused Name', v('accusedName')),
          row('Arrest Date & Time', v('arrestDateTime')),
          row('DOB / Place / Age', v('dobPlaceAge')),
          pw.SizedBox(height: 6),
          pw.Text('Physical Description', style: bold),
          pw.Text(v('physicalDescription').isEmpty ? '—' : v('physicalDescription'), style: body),
          pw.SizedBox(height: 6),
          row('Identification Marks', v('idMarks')),
          row('Address / Mobile', v('address')),
          row('Religion', v('dharma')),
          row('Caste', v('jati')),
        ],
      ),
    );
  }

  if (showII) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [listSection('Family Background', familyLabels, 'familyRows')],
      ),
    );
  }

  if (showIII) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [listSection('Education, ID & History', idHistoryLabels, 'idHistoryRows')],
      ),
    );
  }

  if (showIV) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          listSection('Crime Method & Logistics', crimeLabels, 'crimeRows'),
          pw.SizedBox(height: 16),
          pw.Text('Investigating Officer', style: bold),
          row('Name', v('ioSigName')),
          row('Rank', v('ioSigRank')),
          row('Code No.', v('ioSigCode')),
          row('Posting', v('ioSigPosting')),
        ],
      ),
    );
  }

  if (showV) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Additional Details — Point 37', style: title),
            pw.SizedBox(height: 12),
            pw.Text(
              v('additionalPoint37').isEmpty ? '—' : v('additionalPoint37'),
              style: body,
            ),
          ],
        ),
      ),
    );
  }

  return pdf.save();
}
