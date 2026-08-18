// lib/utils/module_pdf_helper.dart
// Generates official PDF reports for any module record.
// Reuses the existing pdf/printing packages.

import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../modules/core/models/base_record.dart';
import 'ad_firestore_payload.dart';
import 'app_constants.dart';
import 'common_form_module.dart';
import 'common_form_pdf.dart';
import 'crime_detail_pdf.dart';
import 'property_seizure_pdf.dart';
import 'dynamic_map_pdf.dart';
import 'pdf_unicode_fonts.dart';

class ModulePdfHelper {
  static const String _kNcFormExtraFieldsKey = 'ncForm';
  static const String _kMissingFormExtraFieldsKey = 'missingForm';

  /// When [_kNcFormExtraFieldsKey] is present — NC standalone form map + extraMap PDF.
  static Future<bool> printNcFormStoredPdf(ModuleRecord record) async {
    if (record.moduleKey != 'nc') return false;
    final displayName = record.firestoreCategoryDisplayName;
    final nested = record.extraFields[_kNcFormExtraFieldsKey];
    if (nested is! Map) return false;
    final ncMap = Map<String, dynamic>.from(nested);
    final extra = Map<String, dynamic>.from(record.extraFields)
      ..remove(_kNcFormExtraFieldsKey);
    final sub = record.subCategory?.trim() ?? '';
    final formSubtitle = sub.isEmpty
        ? '$displayName — Khakhi Diary · Maharashtra Police'
        : '$sub · $displayName — Khakhi Diary · Maharashtra Police';
    final bytes = await generateFormPdf(
      ncMap,
      extraMap: extra,
      formTitle: '${displayName.toUpperCase()} FORM',
      formSubtitle: formSubtitle,
    );
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name:
          '${displayName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    return true;
  }

  /// When [_kMissingFormExtraFieldsKey] is present — Missing standalone form map + extraMap PDF.
  static Future<bool> printMissingFormStoredPdf(ModuleRecord record) async {
    if (record.moduleKey != 'missing') return false;
    final displayName = record.firestoreCategoryDisplayName;
    final nested = record.extraFields[_kMissingFormExtraFieldsKey];
    if (nested is! Map) return false;
    final missingMap = Map<String, dynamic>.from(nested);
    final extra = Map<String, dynamic>.from(record.extraFields)
      ..remove(_kMissingFormExtraFieldsKey);
    final sub = record.subCategory?.trim() ?? '';
    final formSubtitle = sub.isEmpty
        ? '$displayName — Khakhi Diary · Maharashtra Police'
        : '$sub · $displayName — Khakhi Diary · Maharashtra Police';
    final bytes = await generateFormPdf(
      missingMap,
      extraMap: extra,
      formTitle: '${displayName.toUpperCase()} FORM',
      formSubtitle: formSubtitle,
    );
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name:
          '${displayName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    return true;
  }

  /// When [kCommonFormExtraFieldsKey] is present — full CommonForm §1–§17 + extraMap PDF.
  /// Returns `true` if the share/print sheet was shown.
  static Future<bool> printCommonFormStoredPdf(ModuleRecord record) async {
    final displayName = record.firestoreCategoryDisplayName;
    final nested = record.extraFields[kCommonFormExtraFieldsKey];
    if (nested is! Map) return false;
    final commonMap = Map<String, dynamic>.from(nested);

    Uint8List bytes;
    if (record.subCategory == 'Crime Detail Form') {
      bytes = await generateCrimeDetailPdf(commonMap);
    } else if (record.subCategory == 'Property & Seizure Form') {
      bytes = await generatePropertySeizurePdf(commonMap);
    } else {
      final extra = Map<String, dynamic>.from(record.extraFields)
        ..remove(kCommonFormExtraFieldsKey);
      final sub = record.subCategory?.trim() ?? '';
      final formSubtitle = sub.isEmpty
          ? '$displayName — Khakhi Diary · Maharashtra Police'
          : '$sub · $displayName — Khakhi Diary · Maharashtra Police';
      bytes = await generateFormPdf(
        commonMap,
        extraMap: extra,
        formTitle: '${displayName.toUpperCase()} FORM',
        formSubtitle: formSubtitle,
      );
    }

    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name:
          '${displayName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    return true;
  }

  /// Generates and previews a PDF for any ModuleRecord.
  /// Generates and previews a PDF for any ModuleRecord (titles use [ModuleRecord.firestoreCategoryDisplayName]).
  static Future<void> generatePdf(ModuleRecord record) async {
    final displayName = record.firestoreCategoryDisplayName;
    if (await printNcFormStoredPdf(record)) return;
    if (await printMissingFormStoredPdf(record)) return;
    if (await printCommonFormStoredPdf(record)) return;

    if (record.moduleKey == 'ad') {
      await _generateAdFullFormPdf(record, displayName);
      return;
    }

    final theme = await PdfUnicodeFonts.openSansTheme();
    final doc = pw.Document();
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        maxPages: 200,
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return [
            DynamicMapPdf.pmsNavyHeaderBand(
              amberSubtitle: '$displayName - Official Case Report',
            ),
            pw.SizedBox(height: 20),
            pw.Row(children: [
              pw.Expanded(
                  child: DynamicMapPdf.summaryStatBox(
                      'Case Number', record.caseNumber)),
              pw.SizedBox(width: 12),
              pw.Expanded(
                  child: DynamicMapPdf.summaryStatBox('Status', record.status)),
              pw.SizedBox(width: 12),
              pw.Expanded(
                  child: DynamicMapPdf.summaryStatBox(
                      'Priority', record.priority)),
            ]),
            pw.SizedBox(height: 16),
            ...DynamicMapPdf.buildModuleRecordPdfBody(record, displayName),
            pw.SizedBox(height: 24),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(children: [
                  pw.Container(
                      width: 120,
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide()))),
                  pw.SizedBox(height: 4),
                  pw.Text('Investigating Officer',
                      style: const pw.TextStyle(fontSize: 10)),
                ]),
                pw.Column(children: [
                  pw.Container(
                      width: 120,
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide()))),
                  pw.SizedBox(height: 4),
                  pw.Text('Station Head / SHO',
                      style: const pw.TextStyle(fontSize: 10)),
                ]),
              ],
            ),
            pw.SizedBox(height: 16),
            DynamicMapPdf.confidentialFooterRow(
                generatedText: 'Generated: $now'),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  /// A.D: load `ad_forms` / `ad_drafts` + hub merge, then emit every field dynamically.
  static Future<void> _generateAdFullFormPdf(
      ModuleRecord record, String moduleName) async {
    final adNo = AdFirestorePayload.adNoFromRecord(record);
    var form = await AdFirestorePayload.loadFormMapByAdNo(adNo);
    form = AdFirestorePayload.mergeHubIntoForm(form, record);

    final theme = await PdfUnicodeFonts.openSansTheme();
    final doc = pw.Document();
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        maxPages: 200,
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return [
            DynamicMapPdf.pmsNavyHeaderBand(
              amberSubtitle: '$moduleName — A.D form (all fields)',
            ),
            pw.SizedBox(height: 20),
            pw.Row(children: [
              pw.Expanded(
                  child: DynamicMapPdf.summaryStatBox('AD No.',
                      adNo.isEmpty ? DynamicMapPdf.emptyDisplay : adNo)),
              pw.SizedBox(width: 12),
              pw.Expanded(
                  child: DynamicMapPdf.summaryStatBox('Status', record.status)),
              pw.SizedBox(width: 12),
              pw.Expanded(
                  child: DynamicMapPdf.summaryStatBox(
                      'Priority', record.priority)),
            ]),
            pw.SizedBox(height: 16),
            DynamicMapPdf.sectionHeader('Complete saved A.D form record'),
            ...DynamicMapPdf.buildAdFormMapPdfBody(form),
            pw.SizedBox(height: 24),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(children: [
                  pw.Container(
                      width: 120,
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide()))),
                  pw.SizedBox(height: 4),
                  pw.Text('Investigating Officer',
                      style: const pw.TextStyle(fontSize: 10)),
                ]),
                pw.Column(children: [
                  pw.Container(
                      width: 120,
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide()))),
                  pw.SizedBox(height: 4),
                  pw.Text('Station Head / SHO',
                      style: const pw.TextStyle(fontSize: 10)),
                ]),
              ],
            ),
            pw.SizedBox(height: 16),
            DynamicMapPdf.confidentialFooterRow(
                generatedText: 'Generated: $now'),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  static Future<void> generateSummaryReportPdf(
      Map<String, int> counts, String title, String dateRange) async {
    final theme = await PdfUnicodeFonts.openSansTheme();
    final doc = pw.Document();
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    doc.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration:
                    const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1A2A4A)),
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('POLICE MANAGEMENT SYSTEM',
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text('$title - $dateRange',
                          style: const pw.TextStyle(
                              color: PdfColor.fromInt(0xFFFFC107),
                              fontSize: 11)),
                    ]),
              ),
              pw.SizedBox(height: 24),

              pw.Text('Summary of Registered Cases',
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(0xFF1A2A4A))),
              pw.SizedBox(height: 12),

              // Table header
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                child: pw.Row(children: [
                  pw.Expanded(
                      child: pw.Text('CATEGORY',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10))),
                  pw.Container(
                      width: 80,
                      child: pw.Text('COUNT',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10),
                          textAlign: pw.TextAlign.right)),
                ]),
              ),

              // Table rows
              ...counts.entries.map((e) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    decoration: const pw.BoxDecoration(
                        border: pw.Border(
                            bottom: pw.BorderSide(color: PdfColors.grey300))),
                    child: pw.Row(children: [
                      pw.Expanded(
                          child: pw.Text(e.key,
                              style: const pw.TextStyle(fontSize: 11))),
                      pw.Container(
                          width: 80,
                          child: pw.Text('${e.value}',
                              style: pw.TextStyle(
                                  fontSize: 11, fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.right)),
                    ]),
                  )),

              pw.SizedBox(height: 32),
              pw.Text('Report Details',
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700)),
              pw.SizedBox(height: 8),
              pw.Text(
                  'This report contains a consolidated count of all cases registered in the selected month across all modules, including Section I to V, Section VI, and all other crime categories up to Coin.',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey600)),

              pw.Spacer(),

              // Footer
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        top: pw.BorderSide(color: PdfColors.grey300))),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Generated: $now',
                        style: const pw.TextStyle(
                            fontSize: 9, color: PdfColors.grey600)),
                    pw.Text('CONFIDENTIAL - Police Use Only',
                        style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey600,
                            fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  /// Generates a structured table PDF for the Monthly Report as requested.
  static Future<void> generateMonthlyTablePdf(
    String monthYear,
    List<Map<String, dynamic>> tableData,
  ) async {
    final theme = await PdfUnicodeFonts.openSansTheme();
    final doc = pw.Document();
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        maxPages: 200,
        theme: theme,
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return [
            // Header
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(15),
              decoration:
                  const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1A2A4A)),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('POLICE MANAGEMENT SYSTEM',
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('Monthly Report - $monthYear',
                        style: const pw.TextStyle(
                            color: PdfColor.fromInt(0xFFFFC107), fontSize: 12)),
                  ]),
            ),
            pw.SizedBox(height: 20),

            // Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _headerCell('N'),
                    _headerCell('Heads'),
                    _headerCell('Current Month\n(R|D)'),
                    _headerCell('Previous Month\n(R|D)'),
                    _headerCell('Same Month LY\n(R|D)'),
                    _headerCell('Year Current\n(R|D)'),
                    _headerCell('Year Previous\n(R|D)'),
                    _headerCell('Variation'),
                  ],
                ),
                // Data Rows
                ...tableData.map((row) {
                  final isTotal = row['Heads'] == 'TOTAL';
                  String rd(String rKey, String dKey) =>
                      '${row[rKey] ?? 0}|${row[dKey] ?? 0}';
                  return pw.TableRow(
                    decoration: isTotal
                        ? const pw.BoxDecoration(color: PdfColors.grey100)
                        : null,
                    children: [
                      _dataCell(row['N']?.toString() ?? '', isBold: isTotal),
                      _dataCell(row['Heads']?.toString() ?? '',
                          alignLeft: true, isBold: isTotal),
                      _dataCell(rd('cm_R', 'cm_D'), isBold: isTotal),
                      _dataCell(rd('pm_R', 'pm_D'), isBold: isTotal),
                      _dataCell(rd('smly_R', 'smly_D'), isBold: isTotal),
                      _dataCell(rd('yc_R', 'yc_D'), isBold: isTotal),
                      _dataCell(rd('yp_R', 'yp_D'), isBold: isTotal),
                      _dataCell(row['variation']?.toString() ?? '0',
                          isBold: isTotal),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 30),
            pw.Text('Generated: $now',
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (_) async => doc.save(),
        name: 'Monthly_Report_${monthYear.replaceAll(' ', '_')}.pdf');
  }

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Center(
        child: pw.Text(text,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
      ),
    );
  }

  static pw.Widget _dataCell(String text,
      {bool alignLeft = false, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Align(
        alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
        child: pw.Text(text,
            style: pw.TextStyle(
                fontSize: 8,
                fontWeight:
                    isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ),
    );
  }

  /// Generates a Digital PDF for Monthly Reports (V, VI, Preventive) based on actual records.
  /// Form V follows the specific structured format from the reference image.
  static Future<void> generateDigitalMonthlyReportPdf(
    List<ModuleRecord> records,
    String reportTitle,
    String monthYear,
    MonthlyReportKind kind, {
    required List<ModuleRecord> allRecords,
    required int selectedMonth,
    required int selectedYear,
  }) async {
    final theme = await PdfUnicodeFonts.openSansTheme();
    final doc = pw.Document();
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    if (kind == MonthlyReportKind.v) {
      await _generateFormVStructuredPdf(
          doc, theme, allRecords, selectedMonth, selectedYear, monthYear, now);
    } else {
      await _generateDefaultDigitalPdf(
          doc, theme, records, reportTitle, monthYear, kind, now);
    }

    final fileName = '${reportTitle.replaceAll(' ', '_')}_$monthYear.pdf';
    await Printing.layoutPdf(onLayout: (_) async => doc.save(), name: fileName);
  }

  static Future<void> _generateFormVStructuredPdf(
    pw.Document doc,
    pw.ThemeData theme,
    List<ModuleRecord> allRecords,
    int m,
    int y,
    String monthYear,
    String genDate,
  ) async {
    final heads = [
      'Murder',
      'Att to Murder',
      'Dacoity',
      'Pro Of Dacoity',
      'Total Robery',
      'Chain Robery',
      'Other Robery',
      'Total H B Ts',
      'H B Ts (Day)',
      'H B Ts (Night)',
      'Total Theft',
      'Total M VThefts',
      'SAND THEFT',
      'Chain Snaching',
      'Mobile Thefts',
      'Cattel Theft',
      'Other Thefts',
      'Extcrtion',
      'Cheating',
      'Cr Br of Trust',
      'Mischief',
      'Rioting',
      'Unlawful Assembly',
      'Attempt to suicide',
      'Hurt',
      'Kidnapping',
      'Rape',
      'Assault on Govt-',
      'Molestation (354)',
      '304 (A) I P C',
      '498 (A) I P C',
      '509 I P C',
      'Othar I P C'
    ];

    List<ModuleRecord> filter(int mon, int yr,
        {bool isYearCurrent = false, bool isYearPrev = false}) {
      return allRecords.where((r) {
        if (isYearCurrent) {
          return r.incidentDate.year == yr && r.incidentDate.month <= mon;
        }
        if (isYearPrev) {
          return r.incidentDate.year == yr && r.incidentDate.month <= mon;
        }
        return r.incidentDate.month == mon && r.incidentDate.year == yr;
      }).toList();
    }

    final cmRecs = filter(m, y);
    final prevM = m == 1 ? 12 : m - 1;
    final prevMY = m == 1 ? y - 1 : y;
    final pmRecs = filter(prevM, prevMY);
    final smlyRecs = filter(m, y - 1);
    final ycRecs = filter(m, y, isYearCurrent: true);
    final ypRecs = filter(m, y - 1, isYearPrev: true);

    doc.addPage(pw.MultiPage(
        maxPages: 200,
        theme: theme,
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) => [
              pw.Center(
                  child: pw.Text(
                      'Monthly Crime Statement Month  $monthYear  P.S. TUMSAR',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 10),
              pw.Table(border: pw.TableBorder.all(width: 0.5), children: [
                // Header
                pw.TableRow(children: [
                  _tc('अ. क.'),
                  _tc('गुन्हयाचा प्रकार'),
                  _tc('Current Month\n(R|D)'),
                  _tc('Prev. Month\n(R|D)'),
                  _tc('S.M. Last Year\n(R|D)'),
                  _tc('Current Year\n(R|D)'),
                  _tc('Prev Year\n(R|D)'),
                  _tc('Var.'),
                ]),
                // Data Rows
                ...heads.asMap().entries.map((entry) {
                  final i = entry.key + 1;
                  final head = entry.value;

                  int getR(List<ModuleRecord> list, String h) =>
                      list.where((r) => _getHeadLocal(r) == h).length;
                  int getD(List<ModuleRecord> list, String h) => list
                      .where((r) =>
                          _getHeadLocal(r) == h &&
                          r.status.toLowerCase() != 'open')
                      .length;

                  String rd(List<ModuleRecord> list, String h) {
                    final r = getR(list, h);
                    final d = getD(list, h);
                    if (r == 0 && d == 0) return '';
                    return '$r|$d';
                  }

                  final rYp = getR(ypRecs, head);
                  final rYc = getR(ycRecs, head);

                  final varVal = rYc - rYp;
                  final varStr =
                      varVal > 0 ? '+$varVal' : (varVal < 0 ? '$varVal' : '=');

                  return pw.TableRow(children: [
                    _tc('$i'),
                    _tc(head, alignLeft: true),
                    _tc(rd(cmRecs, head)),
                    _tc(rd(pmRecs, head)),
                    _tc(rd(smlyRecs, head)),
                    _tc(rd(ycRecs, head)),
                    _tc(rd(ypRecs, head)),
                    _tc(varStr),
                  ]);
                }),
              ]),
              pw.SizedBox(height: 20),
              pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text('Generated: $genDate',
                      style: const pw.TextStyle(fontSize: 8))),
            ]));
  }

  static pw.Widget _tc(String text, {bool alignLeft = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Center(
          child: pw.Text(text,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center)),
    );
  }

  static String _getHeadLocal(ModuleRecord r) {
    final sub = (r.subCategory ?? '').toLowerCase();
    final key = r.moduleKey.toLowerCase();
    if (key.contains('murder') || sub.contains('murder')) {
      return sub.contains('att') ? 'Att to Murder' : 'Murder';
    }
    if (key.contains('dacoity') || sub.contains('dacoity')) {
      return sub.contains('pro') ? 'Pro Of Dacoity' : 'Dacoity';
    }
    if (key.contains('robbery') || sub.contains('robery')) {
      return sub.contains('chain') ? 'Chain Robery' : 'Total Robery';
    }
    if (key.contains('house') || sub.contains('h b t')) {
      return sub.contains('day')
          ? 'H B Ts (Day)'
          : (sub.contains('night') ? 'H B Ts (Night)' : 'Total H B Ts');
    }
    if (key.contains('theft')) {
      if (sub.contains('sand')) return 'SAND THEFT';
      if (sub.contains('wheeler')) return 'Total M VThefts';
      if (sub.contains('chain')) return 'Chain Snaching';
      if (sub.contains('mobile')) return 'Mobile Thefts';
      if (sub.contains('cattle')) return 'Cattel Theft';
      if (sub.contains('other')) return 'Other Thefts';
      return 'Total Theft';
    }
    if (key.contains('extortion')) return 'Extcrtion';
    if (key.contains('cheating')) return 'Cheating';
    if (sub.contains('trust')) return 'Cr Br of Trust';
    if (key.contains('mischief')) return 'Mischief';
    if (key.contains('rioting')) return 'Rioting';
    if (sub.contains('unlawful')) return 'Unlawful Assembly';
    if (sub.contains('suicide')) return 'Attempt to suicide';
    if (key.contains('hurt')) return 'Hurt';
    if (key.contains('kidnapping')) return 'Kidnapping';
    if (key.contains('rape')) return 'Rape';
    if (sub.contains('assault') && sub.contains('govt')) {
      return 'Assault on Govt-';
    }
    if (sub.contains('354')) return 'Molestation (354)';
    if (sub.contains('304')) return '304 (A) I P C';
    if (sub.contains('498')) return '498 (A) I P C';
    if (sub.contains('509')) return '509 I P C';
    if (sub.contains('ipc') || sub.contains('othar')) return 'Othar I P C';
    return 'Miscellaneous';
  }

  static Future<void> _generateDefaultDigitalPdf(
    pw.Document doc,
    pw.ThemeData theme,
    List<ModuleRecord> records,
    String reportTitle,
    String monthYear,
    MonthlyReportKind kind,
    String genDate,
  ) async {
    doc.addPage(
      pw.MultiPage(
        maxPages: 200,
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context ctx) => pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(15),
          decoration:
              const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1A2A4A)),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('POLICE MANAGEMENT SYSTEM',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('$reportTitle - $monthYear',
                    style: const pw.TextStyle(
                        color: PdfColor.fromInt(0xFFFFC107), fontSize: 11)),
              ]),
        ),
        footer: (pw.Context ctx) => pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Generated: $genDate',
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey600)),
              pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
        ),
        build: (pw.Context ctx) {
          final Map<String, int> headCounts = {};
          for (var r in records) {
            final head = _getHead(r);
            headCounts[head] = (headCounts[head] ?? 0) + 1;
          }
          return [
            pw.SizedBox(height: 20),
            pw.Text(
                'Structured Monthly Statement (Form ${kind == MonthlyReportKind.vi ? 'VI' : 'Preventive'})',
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF1A2A4A))),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _headerCell('N'),
                    _headerCell('Heads'),
                    _headerCell('Count'),
                  ],
                ),
                ...headCounts.entries.toList().asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  return pw.TableRow(
                    children: [
                      _dataCell((i + 1).toString()),
                      _dataCell(e.key, alignLeft: true),
                      _dataCell(e.value.toString(), isBold: true),
                    ],
                  );
                }),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _dataCell(''),
                    _dataCell('TOTAL', alignLeft: true, isBold: true),
                    _dataCell(records.length.toString(), isBold: true),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Text('Detailed Case Breakdown',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            ...records.map((r) => pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(4)),
                  child: pw.Row(children: [
                    pw.Expanded(
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                          pw.Text(r.title,
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                              'Case: ${r.caseNumber} | Date: ${DateFormat('dd MMM yyyy').format(r.incidentDate)}',
                              style: const pw.TextStyle(
                                  fontSize: 8, color: PdfColors.grey700)),
                        ])),
                    pw.Text(r.status,
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: _getPdfStatusColor(r.status))),
                  ]),
                )),
            if (records.isEmpty)
              pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 20),
                  child: pw.Center(
                      child: pw.Text('No records found.',
                          style:
                              const pw.TextStyle(color: PdfColors.grey500)))),
          ];
        },
      ),
    );
  }

  // Helper to get Head (logic mirrored from Dashboard)
  static String _getHead(ModuleRecord r) {
    final sub = (r.subCategory ?? '').toLowerCase();
    final key = r.moduleKey.toLowerCase();
    if (sub.contains('arms act') || key.contains('arms')) return 'Arms Act';
    if (sub.contains('gambling') || key.contains('gambling')) {
      return 'Gambling Act';
    }
    if (sub.contains('prohibition') ||
        sub.contains('alcohol') ||
        key.contains('prohibition')) {
      return 'Prohibition';
    }
    if (key == 'ndps' || sub.contains('ndps')) return 'NDPS Act';
    if (sub.contains('135 b')) return '135 B Act';
    if (sub.contains('142 b')) return '142 B Act';
    if (sub.contains('122 b')) return '122 B Act';
    if (key == 'traffic' ||
        sub.contains('mv act') ||
        sub.contains('motor vehicle')) {
      return 'MV Act';
    }
    return 'Miscellaneous';
  }

  static PdfColor _getPdfStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return PdfColors.green;
      case 'active':
        return PdfColors.blue;
      case 'open':
        return PdfColors.orange;
      default:
        return PdfColors.black;
    }
  }
}
