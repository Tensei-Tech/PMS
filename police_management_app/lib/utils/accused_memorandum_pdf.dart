import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'marathi_text_renderer.dart';
import 'form_io_terminology.dart';
import '../widgets/form_section_utils.dart';

Future<void> previewAccusedMemorandumPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) async {
  final bytes = await generateAccusedMemorandumPdf(doc);
  if (!context.mounted) return;
  final fileName =
      'Accused_Memorandum_Form_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

Future<Uint8List> generateAccusedMemorandumPdf(
    Map<String, dynamic> doc) async {
  final pdf = pw.Document();
  final loraRegular = await PdfGoogleFonts.loraRegular();
  final loraBold = await PdfGoogleFonts.loraBold();
  final cache = await _preRenderAllMarathi(doc);

  const knownSectionIds = {'Accused Part I', 'Accused Part II'};
  final activeSection = doc['formSection']?.toString();

  bool showsSection(String sectionId) => showsFormSection(
        activeSection: activeSection,
        sectionId: sectionId,
        knownSectionIds: knownSectionIds,
      );

  final pw.TextStyle englishStyle = pw.TextStyle(
    font: loraRegular,
    fontSize: 9,
    color: PdfColors.black,
  );

  final pw.TextStyle englishBold = pw.TextStyle(
    font: loraBold,
    fontSize: 9,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final pw.TextStyle headerEnglishStyle = pw.TextStyle(
    font: loraBold,
    fontSize: 16,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  final pw.TextStyle valueStyle = pw.TextStyle(
    font: loraRegular,
    fontSize: 9,
    color: PdfColors.blue900,
  );

  pw.Widget renderText(String key, String? val, pw.TextStyle engStyle) {
    final text = val?.trim() ?? '';
    if (text.isEmpty) return pw.SizedBox();
    if (containsDevanagari(text)) {
      if (cache.has(key)) {
        return pw.Container(
          alignment: pw.Alignment.topLeft,
          child: cache.img(key),
        );
      }
    }
    return pw.Text(text, style: engStyle);
  }

  pw.Widget mLbl(String key) {
    if (cache.has(key)) return cache.img(key);
    return pw.SizedBox();
  }

  pw.Widget underlineField(String valKey, String fallback,
      {double? width, bool expanded = false}) {
    final child = pw.Container(
      width: expanded ? null : (width ?? 60),
      padding: const pw.EdgeInsets.only(left: 4, right: 4, bottom: 2),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
      ),
      child: renderText(valKey, fallback, valueStyle),
    );
    return expanded ? pw.Expanded(child: child) : child;
  }

  pw.Widget inlineField(String enLabel, String mKey, String valKey,
      String fallback,
      {double? width}) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(enLabel, style: englishBold),
            mLbl(mKey),
          ],
        ),
        underlineField(valKey, fallback, width: width),
      ],
    );
  }

  pw.Widget linedBlock(String textKey, String text, {int minLines = 18}) {
    final lines = _splitTextIntoLines(text, 85);
    final count = lines.length > minLines ? lines.length : minLines;
    return pw.Column(
      children: List.generate(count, (i) {
        final lineText = i < lines.length ? lines[i] : '';
        return pw.Column(
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.only(left: 4, bottom: 2),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
              ),
              child: lineText.isNotEmpty
                  ? renderText('${textKey}_$i', lineText, valueStyle)
                  : pw.SizedBox(height: 10),
            ),
            pw.SizedBox(height: 2),
          ],
        );
      }),
    );
  }

  pw.Widget panchAddressBlock({
    required String prefix,
    required String l1Key,
    required String l2Key,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('$prefix) ', style: englishBold),
            underlineField(l1Key, doc[l1Key]?.toString() ?? '', expanded: true),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 16),
          child: underlineField(
            l2Key,
            doc[l2Key]?.toString() ?? '',
            expanded: true,
          ),
        ),
      ],
    );
  }

  pw.Widget ioBlock() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Signature of Investigation Officer :-',
            style: englishBold),
        mLbl('lbl_io_header'),
        pw.SizedBox(height: 4),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Name :- ', style: englishBold),
            mLbl('lbl_io_name'),
            underlineField('val_ioName', doc['ioName']?.toString() ?? '',
                expanded: true),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            inlineField('Rank :- ', 'lbl_io_rank', 'val_ioRank',
                doc['ioRank']?.toString() ?? '',
                width: 80),
            pw.SizedBox(width: 12),
            inlineField('Number if any :- ', 'lbl_io_no', 'val_ioNo',
                doc['ioNo']?.toString() ?? '',
                width: 80),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Posting and Address :- ', style: englishBold),
            mLbl('lbl_io_posting'),
            underlineField('val_ioPosting', doc['ioPosting']?.toString() ?? '',
                expanded: true),
          ],
        ),
      ],
    );
  }

  // PAGE 1 — Title
  if (showsSection('Accused Part I')) {
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Spacer(flex: 2),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text('Accused Memorandum Form', style: headerEnglishStyle),
                  pw.SizedBox(height: 8),
                  cache.has('title_marathi')
                      ? cache.img('title_marathi')
                      : pw.Text('(आरोपीचे निवेदन पंचनामा)',
                          style: englishStyle),
                ],
              ),
            ),
            pw.Spacer(flex: 3),
            pw.Align(
              alignment: pw.Alignment.bottomRight,
              child: pw.Text('M.R.W', style: englishBold.copyWith(fontSize: 9)),
            ),
          ],
        );
      },
    ),
  );

  // PAGE 2 — Sections 1–7
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    '( Panchanama u/s 23 (2) Bhartiya Saksh Adhiniyam, 2023',
                    style: englishBold,
                    textAlign: pw.TextAlign.center,
                  ),
                  mLbl('lbl_statute'),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: pw.WrapCrossAlignment.end,
              children: [
                inlineField('1) District: ', 'lbl_dist', 'val_dist',
                    doc['dist']?.toString() ?? '',
                    width: 70),
                inlineField('P.S.: ', 'lbl_ps', 'val_ps',
                    doc['ps']?.toString() ?? '',
                    width: 70),
                inlineField('Year: ', 'lbl_year', 'val_year',
                    doc['year']?.toString() ?? '',
                    width: 40),
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    inlineField('FIR No: ', 'lbl_fir', 'val_firNo',
                        doc['firNo']?.toString() ?? '',
                        width: 50),
                    pw.Text('/20', style: englishBold),
                    underlineField('val_firYearSuffix',
                        doc['firYearSuffix']?.toString() ?? '',
                        width: 25),
                  ],
                ),
                inlineField('Date: ', 'lbl_header_date', 'val_headerDate',
                    doc['headerDate']?.toString() ?? '',
                    width: 70),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('2) Name Of Accused: ', style: englishBold),
                mLbl('lbl_accused_name'),
                underlineField('val_accusedName',
                    doc['accusedName']?.toString() ?? '',
                    expanded: true),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                inlineField('Age: ', 'lbl_age', 'val_accusedAge',
                    doc['accusedAge']?.toString() ?? '',
                    width: 50),
                pw.SizedBox(width: 16),
                inlineField('Sex: ', 'lbl_sex', 'val_accusedSex',
                    doc['accusedSex']?.toString() ?? '',
                    width: 50),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Text('3) Date and Time of Arrest :-', style: englishBold),
            mLbl('lbl_arrest_header'),
            pw.SizedBox(height: 2),
            pw.Row(
              children: [
                inlineField('Date: ', 'lbl_arrest_date', 'val_arrestDate',
                    doc['arrestDate']?.toString() ?? '',
                    width: 70),
                pw.SizedBox(width: 12),
                inlineField('Time: ', 'lbl_arrest_time', 'val_arrestTime',
                    doc['arrestTime']?.toString() ?? '',
                    width: 70),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Text('4) Memorandum made by Accused :-', style: englishBold),
            mLbl('lbl_memorandum_header'),
            pw.SizedBox(height: 4),
            linedBlock('mem', doc['memorandum']?.toString() ?? '', minLines: 14),
            pw.SizedBox(height: 8),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('5) Place of Memorandum: ', style: englishBold),
                mLbl('lbl_mem_place'),
                underlineField('val_memPlace', doc['memPlace']?.toString() ?? '',
                    expanded: true),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                inlineField('Date: ', 'lbl_mem_date', 'val_memDate',
                    doc['memDate']?.toString() ?? '',
                    width: 60),
                pw.SizedBox(width: 8),
                inlineField('Time: ', 'lbl_mem_time_from', 'val_memTimeFrom',
                    doc['memTimeFrom']?.toString() ?? '',
                    width: 50),
                pw.SizedBox(width: 8),
                inlineField('To: ', 'lbl_mem_time_to', 'val_memTimeTo',
                    doc['memTimeTo']?.toString() ?? '',
                    width: 50),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Text('6)', style: englishBold),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Name and Address of Panchas:-',
                          style: englishBold),
                      mLbl('lbl_panch_header'),
                      pw.SizedBox(height: 4),
                      panchAddressBlock(
                        prefix: '1',
                        l1Key: 'panch1Line1',
                        l2Key: 'panch1Line2',
                      ),
                      pw.SizedBox(height: 4),
                      panchAddressBlock(
                        prefix: '2',
                        l1Key: 'panch2Line1',
                        l2Key: 'panch2Line2',
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Signature :-', style: englishBold),
                      mLbl('lbl_sig_header'),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('1) ', style: englishBold),
                          underlineField('val_panch1Sig',
                              doc['panch1Sig']?.toString() ?? '',
                              expanded: true),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('2) ', style: englishBold),
                          underlineField('val_panch2Sig',
                              doc['panch2Sig']?.toString() ?? '',
                              expanded: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Text('7)', style: englishBold),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Accused Signature and Thump',
                          style: englishBold),
                      mLbl('lbl_accused_sig'),
                    ],
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(child: ioBlock()),
              ],
            ),
            pw.Spacer(),
            pw.Align(
              alignment: pw.Alignment.bottomRight,
              child: pw.Text('M.R.W', style: englishBold.copyWith(fontSize: 9)),
            ),
          ],
        );
      },
    ),
  );
  }

  // PAGE 3 — Sections 8–10
  if (showsSection('Accused Part II')) {
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('8) Details of Further Panchanama:-', style: englishBold),
            mLbl('lbl_further_header'),
            pw.SizedBox(height: 4),
            linedBlock('further', doc['furtherPanchanama']?.toString() ?? '',
                minLines: 16),
            pw.SizedBox(height: 6),
            pw.Row(
              children: [
                inlineField('Date: ', 'lbl_further_date', 'val_furtherDate',
                    doc['furtherDate']?.toString() ?? '',
                    width: 60),
                pw.SizedBox(width: 8),
                inlineField('Time: ', 'lbl_further_time_from',
                    'val_furtherTimeFrom',
                    doc['furtherTimeFrom']?.toString() ?? '',
                    width: 50),
                pw.SizedBox(width: 8),
                inlineField('To: ', 'lbl_further_time_to', 'val_furtherTimeTo',
                    doc['furtherTimeTo']?.toString() ?? '',
                    width: 50),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text('9)', style: englishBold),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Name and Address of Panchas:-',
                          style: englishBold),
                      mLbl('lbl_panch_header'),
                      pw.SizedBox(height: 4),
                      panchAddressBlock(
                        prefix: '1',
                        l1Key: 'furtherPanch1Line1',
                        l2Key: 'furtherPanch1Line2',
                      ),
                      pw.SizedBox(height: 4),
                      panchAddressBlock(
                        prefix: '2',
                        l1Key: 'furtherPanch2Line1',
                        l2Key: 'furtherPanch2Line2',
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Signature :-', style: englishBold),
                      mLbl('lbl_sig_header'),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('1) ', style: englishBold),
                          underlineField('val_furtherPanch1Sig',
                              doc['furtherPanch1Sig']?.toString() ?? '',
                              expanded: true),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('2) ', style: englishBold),
                          underlineField('val_furtherPanch2Sig',
                              doc['furtherPanch2Sig']?.toString() ?? '',
                              expanded: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('10) Accused Signature and Thump',
                          style: englishBold),
                      mLbl('lbl_accused_sig'),
                      pw.SizedBox(height: 40),
                    ],
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(child: ioBlock()),
              ],
            ),
            pw.Spacer(),
            pw.Align(
              alignment: pw.Alignment.bottomRight,
              child: pw.Text('M.R.W', style: englishBold.copyWith(fontSize: 9)),
            ),
          ],
        );
      },
    ),
  );
  }

  return pdf.save();
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

  final marathiLabelStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 9,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  final valueStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 9,
    fontWeight: FontWeight.bold,
    color: Colors.blue.shade900,
  );

  await GoogleFonts.pendingFonts();

  Future<void> addLbl(String key, String text,
      {double maxWidth = 500}) async {
    await cache.add(key, text, marathiLabelStyle, maxWidth: maxWidth);
  }

  Future<void> addVal(String key, String? val, {double maxWidth = 500}) async {
    final text = val?.trim() ?? '';
    if (containsDevanagari(text)) {
      await cache.add(key, text, valueStyle, maxWidth: maxWidth);
    }
  }

  await addLbl('title_marathi', '(आरोपीचे निवेदन पंचनामा)');
  await addLbl('lbl_statute', 'कलम २३ (२) भारतीय साक्ष अधिनियम २०२३ )');
  await addLbl('lbl_dist', 'जिल्हा');
  await addLbl('lbl_ps', 'पोलीस स्टेशन');
  await addLbl('lbl_year', 'वर्ष');
  await addLbl('lbl_fir', 'पहिली खबर क्र.');
  await addLbl('lbl_header_date', 'तारीख');
  await addLbl('lbl_accused_name', 'आरोपीचे नांव व पत्ता');
  await addLbl('lbl_age', 'वय');
  await addLbl('lbl_sex', 'लिंग');
  await addLbl('lbl_arrest_header', 'अटकेची तारीख व वेळ');
  await addLbl('lbl_arrest_date', 'तारीख');
  await addLbl('lbl_arrest_time', 'वेळ');
  await addLbl('lbl_memorandum_header', 'आरोपीने केलेले निवेदन');
  await addLbl('lbl_mem_place', 'पंचनाम्याचे ठिकाण');
  await addLbl('lbl_mem_date', 'तारीख');
  await addLbl('lbl_mem_time_from', 'वेळ');
  await addLbl('lbl_mem_time_to', 'ते');
  await addLbl('lbl_panch_header', 'पंचाचे नांव व पत्ता');
  await addLbl('lbl_sig_header', 'सह्या');
  await addLbl('lbl_accused_sig', 'आरोपीची सही व अंगठा');
  await addLbl('lbl_io_header', FormIoTerminology.signatureHeader);
  await addLbl('lbl_io_name', FormIoTerminology.name);
  await addLbl('lbl_io_rank', FormIoTerminology.rank);
  await addLbl('lbl_io_no', FormIoTerminology.badgeNo);
  await addLbl('lbl_io_posting', FormIoTerminology.posting);
  await addLbl('lbl_further_header', 'पंचनाम्याचा पुढील भाग');
  await addLbl('lbl_further_date', 'तारीख');
  await addLbl('lbl_further_time_from', 'वेळ');
  await addLbl('lbl_further_time_to', 'ते');

  final valueKeys = [
    'dist',
    'ps',
    'year',
    'firNo',
    'firYearSuffix',
    'headerDate',
    'accusedName',
    'accusedAge',
    'accusedSex',
    'arrestDate',
    'arrestTime',
    'memPlace',
    'memDate',
    'memTimeFrom',
    'memTimeTo',
    'panch1Line1',
    'panch1Line2',
    'panch2Line1',
    'panch2Line2',
    'panch1Sig',
    'panch2Sig',
    'ioName',
    'ioRank',
    'ioNo',
    'ioPosting',
    'furtherDate',
    'furtherTimeFrom',
    'furtherTimeTo',
    'furtherPanch1Line1',
    'furtherPanch1Line2',
    'furtherPanch2Line1',
    'furtherPanch2Line2',
    'furtherPanch1Sig',
    'furtherPanch2Sig',
  ];

  for (final key in valueKeys) {
    await addVal('val_$key', doc[key]?.toString());
  }

  for (final entry in [
    ('mem', doc['memorandum']?.toString() ?? ''),
    ('further', doc['furtherPanchanama']?.toString() ?? ''),
  ]) {
    final lines = _splitTextIntoLines(entry.$2, 85);
    for (var i = 0; i < lines.length; i++) {
      if (containsDevanagari(lines[i])) {
        await cache.add('${entry.$1}_$i', lines[i], valueStyle, maxWidth: 480);
      }
    }
  }

  return cache;
}
