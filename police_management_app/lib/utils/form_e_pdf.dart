import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'marathi_text_renderer.dart';

Future<void> previewFormEPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) async {
  final bytes = await generateFormEPdf(doc);
  if (!context.mounted) return;
  final fileName = 'Form_E_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

Future<Uint8List> generateFormEPdf(Map<String, dynamic> doc) async {
  final pdf = pw.Document();

  final loraRegular = await PdfGoogleFonts.loraRegular();
  final loraBold = await PdfGoogleFonts.loraBold();

  // Pre-render Marathi text blocks
  final cache = await _preRenderAllMarathi(doc);

  final pw.TextStyle englishStyle = pw.TextStyle(
    font: loraRegular,
    fontSize: 10,
    color: PdfColors.black,
  );

  final pw.TextStyle headerEnglishStyle = pw.TextStyle(
    font: loraBold,
    fontSize: 16,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  pw.Widget renderText(String key, String? val, pw.TextStyle engStyle) {
    if (val == null || val.isEmpty) return pw.SizedBox();
    if (containsDevanagari(val)) {
      if (cache.has(key)) {
        return pw.Container(
          alignment: pw.Alignment.topLeft,
          child: cache.img(key),
        );
      }
    }
    return pw.Text(val, style: engStyle);
  }

  pw.TableRow buildPdfRow(String srNo, String labelKey, String fieldKey, String? val) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Center(child: pw.Text(srNo, style: englishStyle)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: cache.has(labelKey) ? cache.img(labelKey) : pw.SizedBox(),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: renderText(fieldKey, val, englishStyle),
        ),
      ],
    );
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return [
          pw.Center(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('FORM "E"', style: headerEnglishStyle),
                pw.SizedBox(height: 4),
                if (cache.has('header_title1')) cache.img('header_title1'),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                  ),
                  child: cache.has('header_title2') ? cache.img('header_title2') : pw.SizedBox(),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1),
            columnWidths: {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FixedColumnWidth(200),
              2: const pw.FlexColumnWidth(),
            },
            children: [
              buildPdfRow('1.', 'lbl_1', 'val_1', doc['field1']),
              buildPdfRow('2.', 'lbl_2', 'val_2', doc['field2']),
              buildPdfRow('3.', 'lbl_3', 'val_3', doc['field3']),
              buildPdfRow('4.', 'lbl_4', 'val_4', doc['field4']),
              buildPdfRow('5.', 'lbl_5', 'val_5', doc['field5']),
              buildPdfRow('6.', 'lbl_6', 'val_6', doc['field6']),
              buildPdfRow('7.', 'lbl_7', 'val_7', doc['field7']),
              buildPdfRow('8.', 'lbl_8', 'val_8', doc['field8']),
              buildPdfRow('9.', 'lbl_9', 'val_9', doc['field9']),
              buildPdfRow('10.', 'lbl_10', 'val_10', doc['field10']),
              buildPdfRow('11.', 'lbl_11', 'val_11', doc['field11']),
              buildPdfRow('12.', 'lbl_12', 'val_12', doc['field12']),
              buildPdfRow('13.', 'lbl_13', 'val_13', doc['field13']),
              buildPdfRow('14.', 'lbl_14', 'val_14', doc['field14']),
              buildPdfRow('15.', 'lbl_15', 'val_15', doc['field15']),
              buildPdfRow('16.', 'lbl_16', 'val_16', doc['field16']),
              buildPdfRow('17.', 'lbl_17', 'val_17', doc['field17']),
              buildPdfRow('18.', 'lbl_18', 'val_18', doc['field18']),
            ],
          ),
        ];
      },
    ),
  );

  return pdf.save();
}

Future<MarathiImageCache> _preRenderAllMarathi(Map<String, dynamic> doc) async {
  final cache = MarathiImageCache();

  final headerStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  final marathiLabelStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 10,
    color: Colors.black,
  );

  final valueStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 10,
    color: Colors.blue.shade900,
  );

  await GoogleFonts.pendingFonts();

  Future<void> addLbl(String key, String text, TextStyle style, {double maxWidth = 500}) async {
    await cache.add(key, text, style, maxWidth: maxWidth);
  }

  Future<void> addVal(String key, String? val, {double maxWidth = 500}) async {
    final text = val?.trim() ?? '';
    if (containsDevanagari(text)) {
      await cache.add(key, text, valueStyle, maxWidth: maxWidth);
    }
  }

  await addLbl('header_title1', 'मोडस ऑपरेंडी ब्युरोला पुरविण्यात', headerStyle);
  await addLbl('header_title2', 'यावयाची माहिती', headerStyle);

  await addLbl('lbl_1', 'पोलीस स्टेशन', marathiLabelStyle);
  await addLbl('lbl_2', 'तक्रार दाखल करणाऱ्याचे नांव\nव पत्ता', marathiLabelStyle, maxWidth: 180);
  await addLbl('lbl_3', 'गुन्हा घडला ते शहर अथवा गांव\nई.', marathiLabelStyle, maxWidth: 180);
  await addLbl('lbl_4', 'गुन्हा घडल्याची तारीख', marathiLabelStyle);
  await addLbl('lbl_5', 'अप क्रमांक व कलम', marathiLabelStyle);
  await addLbl('lbl_6', 'चोरीस गेलेल्या मालमत्तेची\nकिंमत', marathiLabelStyle, maxWidth: 180);
  await addLbl('lbl_7', 'परत मिळालेल्या मालमत्तेची\nकिंमत (मालमत्ता कोणाकडून व\nकोणत्या ठिकाणी परत मिळाली)', marathiLabelStyle, maxWidth: 180);
  await addLbl('lbl_8', 'ज्याच्यावर हल्ला करण्यात\nआला त्या ईसमाचा अथवा\nमिळकतीचा वर्ग', marathiLabelStyle, maxWidth: 180);
  await addLbl('lbl_9', 'गुन्ह्याच्या जागी पोहचण्याकरीता\nउपयोगात आणलेले साधन', marathiLabelStyle, maxWidth: 180);
  await addLbl('lbl_10', 'गुन्हा करण्यासाठी वापरलेली रीत', marathiLabelStyle, maxWidth: 180);
  await addLbl('lbl_11', 'गुन्हा करण्यासाठी वापरलेले\nसाधन', marathiLabelStyle, maxWidth: 180);
  await addLbl('lbl_12', 'दिवसाचा वेळ', marathiLabelStyle);
  await addLbl('lbl_13', 'साथीदार', marathiLabelStyle);
  await addLbl('lbl_14', 'वाहन', marathiLabelStyle);
  await addLbl('lbl_15', 'विशीष्ट निदर्शक खुण', marathiLabelStyle);
  await addLbl('lbl_16', 'शैली', marathiLabelStyle);
  await addLbl('lbl_17', 'रचुन सांगीतलेली हकीकत,\nगुन्ह्याकरण्याबाबत केलेले\nहेतुनिवेदन', marathiLabelStyle, maxWidth: 180);
  await addLbl('lbl_18', 'गुन्ह्यासंबंधीत थोडक्यात\nहकीकत', marathiLabelStyle, maxWidth: 180);

  await addVal('val_1', doc['field1'], maxWidth: 280);
  await addVal('val_2', doc['field2'], maxWidth: 280);
  await addVal('val_3', doc['field3'], maxWidth: 280);
  await addVal('val_4', doc['field4'], maxWidth: 280);
  await addVal('val_5', doc['field5'], maxWidth: 280);
  await addVal('val_6', doc['field6'], maxWidth: 280);
  await addVal('val_7', doc['field7'], maxWidth: 280);
  await addVal('val_8', doc['field8'], maxWidth: 280);
  await addVal('val_9', doc['field9'], maxWidth: 280);
  await addVal('val_10', doc['field10'], maxWidth: 280);
  await addVal('val_11', doc['field11'], maxWidth: 280);
  await addVal('val_12', doc['field12'], maxWidth: 280);
  await addVal('val_13', doc['field13'], maxWidth: 280);
  await addVal('val_14', doc['field14'], maxWidth: 280);
  await addVal('val_15', doc['field15'], maxWidth: 280);
  await addVal('val_16', doc['field16'], maxWidth: 280);
  await addVal('val_17', doc['field17'], maxWidth: 280);
  await addVal('val_18', doc['field18'], maxWidth: 280);

  return cache;
}
