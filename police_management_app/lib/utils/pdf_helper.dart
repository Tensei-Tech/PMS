// lib/utils/pdf_helper.dart
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../modules/core/models/base_record.dart';
import 'dynamic_map_pdf.dart';
import 'module_pdf_helper.dart';
import 'pdf_unicode_fonts.dart';

class PdfHelper {
  static Future<void> generateCasePdf(ModuleRecord caseData) async {
    final moduleDisplay = caseData.firestoreCategoryDisplayName;
    if (await ModulePdfHelper.printCommonFormStoredPdf(caseData)) {
      return;
    }

    if (caseData.moduleKey == 'ad') {
      await ModulePdfHelper.generatePdf(caseData);
      return;
    }

    final theme = await PdfUnicodeFonts.openSansTheme();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        maxPages: 200,
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            DynamicMapPdf.pmsNavyHeaderBand(
              amberSubtitle: '$moduleDisplay - Official Case Report',
            ),
            pw.SizedBox(height: 20),
            pw.Row(children: [
              pw.Expanded(
                child: DynamicMapPdf.summaryStatBox(
                    'Case Number', caseData.caseNumber),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: DynamicMapPdf.summaryStatBox('Status', caseData.status),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child:
                    DynamicMapPdf.summaryStatBox('Priority', caseData.priority),
              ),
            ]),
            pw.SizedBox(height: 16),
            ...DynamicMapPdf.buildModuleRecordPdfBody(caseData, moduleDisplay),
            pw.SizedBox(height: 24),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Reference: ${caseData.id}',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey600),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(
                        width: 120,
                        decoration: const pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide()))),
                    pw.SizedBox(height: 4),
                    pw.Text('Authorized Signature',
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            DynamicMapPdf.confidentialFooterRow(
              generatedText:
                  'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Case_${caseData.caseNumber.replaceAll('/', '_')}.pdf',
    );
  }
}
