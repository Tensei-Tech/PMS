import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'marathi_text_renderer.dart';

Future<void> previewBnssFormPdf(
  BuildContext context,
  Map<String, dynamic> doc, {
  required String filePrefix,
  required String titleEn,
  required String titleMr,
  required List<BnssPdfSection> sections,
}) async {
  final bytes = await generateBnssFormPdf(
    doc,
    titleEn: titleEn,
    titleMr: titleMr,
    sections: sections,
  );
  if (!context.mounted) return;
  final fileName = '${filePrefix}_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

class BnssPdfSection {
  final String id;
  final String headingEn;
  final String headingMr;
  final List<String> fieldKeys;
  final Map<String, String> labels;

  const BnssPdfSection({
    required this.id,
    required this.headingEn,
    required this.headingMr,
    this.fieldKeys = const [],
    this.labels = const {},
  });
}

Future<Uint8List> generateBnssFormPdf(
  Map<String, dynamic> doc, {
  required String titleEn,
  required String titleMr,
  required List<BnssPdfSection> sections,
}) async {
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
  final active = v('formSection');

  bool showSection(String id) {
    if (active.isEmpty) return true;
    if (sections.every((s) => s.id != active)) return true;
    return active == id;
  }

  pw.Widget row(String en, String mrLabel, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(en, style: bold),
          if (mrLabel.isNotEmpty) pw.Text(mrLabel, style: mr),
          pw.Text(value.isEmpty ? '—' : value, style: body),
        ],
      ),
    );
  }

  for (final section in sections) {
    if (!showSection(section.id)) continue;
    final keys = section.fieldKeys.isNotEmpty
        ? section.fieldKeys
        : doc.keys
            .where((k) =>
                k != 'formSection' && k != 'pageRange' && k != 'noticeType')
            .cast<String>()
            .toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(child: pw.Text(titleEn, style: title)),
            pw.Center(child: pw.Text(titleMr, style: mrBold)),
            pw.SizedBox(height: 8),
            pw.Text(section.headingEn, style: bold),
            pw.Text(section.headingMr, style: mr),
            pw.SizedBox(height: 10),
            for (final key in keys)
              row(
                section.labels[key] ?? key,
                section.labels['${key}_mr'] ?? '',
                v(key),
              ),
          ],
        ),
      ),
    );
  }

  return pdf.save();
}

Future<Uint8List> generateMinimalMarathiFormPdf(
  Map<String, dynamic> doc, {
  required String titleMr,
  required String titleEn,
  required List<String> fieldKeys,
  Map<String, String> labels = const {},
}) async {
  final pdf = pw.Document();
  final loraBold = await PdfGoogleFonts.loraBold();
  final devanagari = await PdfGoogleFonts.notoSansDevanagariRegular();

  final bold = pw.TextStyle(font: loraBold, fontSize: 12, fontWeight: pw.FontWeight.bold);
  final value = pw.TextStyle(font: devanagari, fontSize: 10, color: PdfColors.blue900);

  final cache = MarathiImageCache();
  await cache.add(
    'title',
    titleMr,
    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  );

  String v(String key) => doc[key]?.toString().trim() ?? '';

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (cache.has('title')) cache.img('title') else pw.Text(titleMr, style: bold),
          pw.Text(titleEn, style: bold),
          pw.SizedBox(height: 12),
          for (final key in fieldKeys) ...[
            pw.Text(labels[key] ?? key, style: bold),
            pw.Text(v(key).isEmpty ? '—' : v(key), style: value),
            pw.SizedBox(height: 6),
          ],
        ],
      ),
    ),
  );

  return pdf.save();
}

Future<void> previewMinimalMarathiFormPdf(
  BuildContext context,
  Map<String, dynamic> doc, {
  required String filePrefix,
  required String titleMr,
  required String titleEn,
  required List<String> fieldKeys,
  Map<String, String> labels = const {},
}) async {
  final bytes = await generateMinimalMarathiFormPdf(
    doc,
    titleMr: titleMr,
    titleEn: titleEn,
    fieldKeys: fieldKeys,
    labels: labels,
  );
  if (!context.mounted) return;
  final fileName = '${filePrefix}_${DateTime.now().millisecondsSinceEpoch}.pdf';
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
