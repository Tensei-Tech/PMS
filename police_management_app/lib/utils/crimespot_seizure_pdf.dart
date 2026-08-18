import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'marathi_text_renderer.dart';
import 'form_io_terminology.dart';

Future<void> previewCrimespotSeizurePdf(
  BuildContext context,
  Map<String, dynamic> doc,
) async {
  final bytes = await generateCrimespotSeizurePdf(doc);
  if (!context.mounted) return;
  final fileName =
      'Crimespot_Seizure_Panchanama_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

Future<Uint8List> generateCrimespotSeizurePdf(
    Map<String, dynamic> doc) async {
  final pdf = pw.Document();

  // Load fonts
  final loraRegular = await PdfGoogleFonts.loraRegular();
  final loraBold = await PdfGoogleFonts.loraBold();
  final devanagariRegular =
      await PdfGoogleFonts.notoSansDevanagariRegular();

  // Pre-render Marathi text blocks
  final cache = await _preRenderAllMarathi(doc);

  final pw.TextStyle englishStyle = pw.TextStyle(
    font: loraRegular,
    fontSize: 10,
    color: PdfColors.black,
  );

  final pw.TextStyle englishBold = pw.TextStyle(
    font: loraBold,
    fontSize: 10,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final pw.TextStyle valueStyle = pw.TextStyle(
    font: devanagariRegular,
    fontSize: 10,
    color: PdfColors.blue900,
  );

  // --- PAGE 1: Title Page ---
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      build: (pw.Context context) {
        return pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Center(
              child: cache.has('title_main')
                  ? cache.img('title_main')
                  : pw.Text('घटनास्थळ जप्ती पंचनामा',
                      style: englishBold.copyWith(fontSize: 22)),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'CRIME SPOT SEIZURE PANCHANAMA',
                style: englishBold.copyWith(fontSize: 14),
              ),
            ),
            pw.Spacer(),
            pw.Align(
              alignment: pw.Alignment.bottomRight,
              child: pw.Text('M.R.W',
                  style: englishBold.copyWith(fontSize: 9)),
            ),
          ],
        );
      },
    ),
  );

  // --- PAGE 2+: Form Content ---
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      footer: (pw.Context context) {
        return pw.Align(
          alignment: pw.Alignment.bottomRight,
          child: pw.Text('M.R.W',
              style: englishBold.copyWith(fontSize: 9)),
        );
      },
      build: (pw.Context context) {
        // Split body text into lines for rendering
        final bodyText = doc['body']?.toString().trim() ?? '';
        final bodyLines = _splitTextIntoLines(bodyText, 80);

        return [
          // --- HEADER ---
          pw.Center(
            child: pw.Column(
              children: [
                if (cache.has('header_title'))
                  cache.img('header_title')
                else
                  pw.Text('घटनास्थळ जप्ती पंचनामा',
                      style: englishBold.copyWith(fontSize: 15)),
                pw.SizedBox(height: 4),
                pw.Text(
                  'CRIME SPOT SEIZURE PANCHANAMA',
                  style: englishBold.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 4),

          // --- Camp No. + Date ---
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.SizedBox(width: 10),
              pw.Spacer(),
              // Camp No.
              pw.Row(
                children: [
                  _mLbl(cache, 'lbl_camp'),
                  _buildPdfUnderlineField(
                    valKey: 'val_campNo',
                    fallbackValue: doc['campNo'] ?? '',
                    width: 80,
                    valueStyle: valueStyle,
                    cache: cache,
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                _mLbl(cache, 'lbl_date'),
                _buildPdfUnderlineField(
                  valKey: 'val_dateDay',
                  fallbackValue: doc['dateDay'] ?? '',
                  width: 18,
                  valueStyle: valueStyle,
                  cache: cache,
                ),
                pw.Text('/', style: englishStyle),
                _buildPdfUnderlineField(
                  valKey: 'val_dateMonth',
                  fallbackValue: doc['dateMonth'] ?? '',
                  width: 18,
                  valueStyle: valueStyle,
                  cache: cache,
                ),
                pw.Text('/20', style: englishStyle),
                _buildPdfUnderlineField(
                  valKey: 'val_dateYear',
                  fallbackValue: doc['dateYear'] ?? '',
                  width: 18,
                  valueStyle: valueStyle,
                  cache: cache,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // --- Panch Names ---
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _mLbl(cache, 'lbl_panch_name'),
              pw.Text(' : 1) ', style: englishBold),
              pw.Expanded(
                child: _buildPdfUnderlineField(
                  valKey: 'val_panch1Name',
                  fallbackValue: doc['panch1Name'] ?? '',
                  valueStyle: valueStyle,
                  cache: cache,
                  expanded: true,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 80),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('2) ', style: englishBold),
                pw.Expanded(
                  child: _buildPdfUnderlineField(
                    valKey: 'val_panch2Name',
                    fallbackValue: doc['panch2Name'] ?? '',
                    valueStyle: valueStyle,
                    cache: cache,
                    expanded: true,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // --- Body Text (lined area) ---
          for (var i = 0; i < bodyLines.length; i++) ...[
            pw.Container(
              width: double.infinity,
              constraints: const pw.BoxConstraints(minHeight: 16),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(
                        color: PdfColors.black, width: 0.5)),
              ),
              alignment: pw.Alignment.bottomLeft,
              padding:
                  const pw.EdgeInsets.only(left: 4, bottom: 2),
              child: cache.has('body_line_$i')
                  ? cache.img('body_line_$i')
                  : pw.Text(bodyLines[i], style: valueStyle),
            ),
            pw.SizedBox(height: 3),
          ],

          // Add empty lines if body is short (minimum 15 lines)
          for (var i = bodyLines.length; i < 15; i++) ...[
            pw.Container(
              width: double.infinity,
              height: 16,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(
                        color: PdfColors.black, width: 0.5)),
              ),
            ),
            pw.SizedBox(height: 3),
          ],
          pw.SizedBox(height: 24),

          // --- Signature Block ---
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Left: IO
              pw.Expanded(
                flex: 4,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (cache.has('lbl_io'))
                      cache.img('lbl_io')
                    else
                      pw.Text('तपासी अंमलदार',
                          style: englishBold),
                    pw.SizedBox(height: 4),
                    pw.Text('Investigating Officer',
                        style: englishStyle.copyWith(fontSize: 8)),
                    pw.SizedBox(height: 8),
                    _buildPdfUnderlineField(
                      valKey: 'val_ioName',
                      fallbackValue: doc['ioName'] ?? '',
                      width: 140,
                      valueStyle: valueStyle,
                      cache: cache,
                    ),
                  ],
                ),
              ),
              // Right: Panch signatures
              pw.Expanded(
                flex: 5,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        _mLbl(cache, 'lbl_panch_sig'),
                        pw.Text(' 1) ', style: englishBold),
                        pw.Expanded(
                          child: _buildPdfUnderlineField(
                            valKey: 'val_panchSig1',
                            fallbackValue: doc['panchSig1'] ?? '',
                            valueStyle: valueStyle,
                            cache: cache,
                            expanded: true,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 60),
                      child: pw.Row(
                        children: [
                          pw.Text('2) ', style: englishBold),
                          pw.Expanded(
                            child: _buildPdfUnderlineField(
                              valKey: 'val_panchSig2',
                              fallbackValue:
                                  doc['panchSig2'] ?? '',
                              valueStyle: valueStyle,
                              cache: cache,
                              expanded: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ];
      },
    ),
  );

  return pdf.save();
}

// --- Helper Functions ---

pw.Widget _mLbl(MarathiImageCache cache, String key) {
  if (cache.has(key)) return cache.img(key);
  return pw.SizedBox();
}

pw.Widget _buildPdfUnderlineField({
  required String valKey,
  required String fallbackValue,
  required pw.TextStyle valueStyle,
  required MarathiImageCache cache,
  double? width,
  bool expanded = false,
}) {
  final hasValImg = cache.has(valKey);
  final child = pw.Container(
    width: expanded ? null : (width ?? 60),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
          bottom:
              pw.BorderSide(color: PdfColors.black, width: 0.8)),
    ),
    alignment: pw.Alignment.bottomCenter,
    padding: const pw.EdgeInsets.only(left: 2, bottom: 1),
    child: hasValImg
        ? cache.img(valKey)
        : pw.Text(fallbackValue, style: valueStyle),
  );
  return expanded
      ? pw.SizedBox(width: double.infinity, child: child)
      : child;
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
    if (currentLine.isNotEmpty) {
      result.add(currentLine);
    }
  }
  return result;
}

Future<MarathiImageCache> _preRenderAllMarathi(
    Map<String, dynamic> doc) async {
  final cache = MarathiImageCache();

  final headerStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  final marathiLabelStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  final valueStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.blue.shade900,
  );

  // Ensure fonts are ready
  await GoogleFonts.pendingFonts();

  Future<void> addLbl(String key, String text, TextStyle style,
      {double maxWidth = 500}) async {
    await cache.add(key, text, style, maxWidth: maxWidth);
  }

  Future<void> addVal(String key, String? val,
      {double maxWidth = 500}) async {
    final text = val?.trim() ?? '';
    if (containsDevanagari(text)) {
      await cache.add(key, text, valueStyle, maxWidth: maxWidth);
    }
  }

  // Title page
  await addLbl(
      'title_main', 'घटनास्थळ जप्ती पंचनामा', headerStyle);

  // Form header
  await addLbl('header_title', 'घटनास्थळ जप्ती पंचनामा',
      marathiLabelStyle.copyWith(fontSize: 13, fontWeight: FontWeight.bold));

  // Static labels
  await addLbl('lbl_camp', 'कंप :- ', marathiLabelStyle);
  await addLbl('lbl_date', 'दिनांक :- ', marathiLabelStyle);
  await addLbl('lbl_panch_name', 'पंच नांव', marathiLabelStyle);
  await addLbl('lbl_io', FormIoTerminology.officerAmaldar, marathiLabelStyle);
  await addLbl(
      'lbl_panch_sig', 'पंच साही :- ', marathiLabelStyle);

  // Dynamic values
  await addVal('val_campNo', doc['campNo']);
  await addVal('val_dateDay', doc['dateDay']);
  await addVal('val_dateMonth', doc['dateMonth']);
  await addVal('val_dateYear', doc['dateYear']);
  await addVal('val_panch1Name', doc['panch1Name']);
  await addVal('val_panch2Name', doc['panch2Name']);
  await addVal('val_ioName', doc['ioName']);
  await addVal('val_panchSig1', doc['panchSig1']);
  await addVal('val_panchSig2', doc['panchSig2']);

  // Body text — render line by line
  final bodyText = doc['body']?.toString().trim() ?? '';
  final bodyLines = _splitTextIntoLines(bodyText, 80);
  for (int i = 0; i < bodyLines.length; i++) {
    final lineText = bodyLines[i];
    if (containsDevanagari(lineText)) {
      await cache.add(
          'body_line_$i', lineText, valueStyle, maxWidth: 480);
    }
  }

  return cache;
}
