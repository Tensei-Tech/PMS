// lib/utils/ad_form_pdf_helper.dart
// PDF export for Accidental Death (A.D) — all fields from [data] map dynamically.

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'dynamic_map_pdf.dart';
import 'pdf_unicode_fonts.dart';

class AdFormPdfHelper {
  AdFormPdfHelper._();

  static String _plain(dynamic v) {
    final s = DynamicMapPdf.disp(v);
    return s == DynamicMapPdf.emptyDisplay ? '' : s;
  }

  /// Opens the system print / share PDF sheet for this AD payload.
  static Future<void> generateAndPreview(Map<String, dynamic> data) async {
    final theme = await PdfUnicodeFonts.openSansTheme();

    final adNoRaw = _plain(data['adNo']);
    final adNo = adNoRaw.isEmpty ? 'AD' : adNoRaw;
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        maxPages: 200,
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) {
          return [
            DynamicMapPdf.pmsNavyHeaderBand(
              amberSubtitle:
                  'Accidental Death (A.D) — form record · AD No. $adNo',
            ),
            pw.SizedBox(height: 16),
            DynamicMapPdf.sectionHeader('Complete form record (all fields)'),
            ...DynamicMapPdf.buildAdFormMapPdfBody(data),
            pw.SizedBox(height: 24),
            DynamicMapPdf.confidentialFooterRow(
              generatedText:
                  'Police Management System · A.D module · ${DateTime.now().year}',
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'AD_${adNo.replaceAll(RegExp(r'[^\w\-]+'), '_')}.pdf',
    );
  }
}
