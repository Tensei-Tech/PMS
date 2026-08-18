import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> previewAbFormPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) async {
  final bytes = await generateAbFormPdf(doc);
  if (!context.mounted) return;
  final fileName = 'AB_Form_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

Future<Uint8List> generateAbFormPdf(Map<String, dynamic> doc) async {
  final pdf = pw.Document();
  final loraRegular = await PdfGoogleFonts.loraRegular();
  final loraBold = await PdfGoogleFonts.loraBold();
  final devanagari = await PdfGoogleFonts.notoSansDevanagariRegular();
  final devanagariBold = await PdfGoogleFonts.notoSansDevanagariBold();

  final bodyStyle = pw.TextStyle(font: loraRegular, fontSize: 10);
  final boldStyle = pw.TextStyle(font: loraBold, fontSize: 11, fontWeight: pw.FontWeight.bold);
  final titleStyle = pw.TextStyle(font: loraBold, fontSize: 16, fontWeight: pw.FontWeight.bold);
  final marathiStyle = pw.TextStyle(font: devanagari, fontSize: 8.5);
  final marathiBold = pw.TextStyle(font: devanagariBold, fontSize: 9, fontWeight: pw.FontWeight.bold);
  final valueStyle = pw.TextStyle(font: devanagari, fontSize: 10, color: PdfColors.blue900);

  String v(String key) => doc[key]?.toString().trim() ?? '';

  pw.Widget bilingualFieldRow(String labelEn, String labelMr, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
          pw.SizedBox(
            width: 180,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(labelEn, style: boldStyle),
                pw.Text(labelMr, style: marathiStyle),
              ],
            ),
          ),
              pw.Expanded(
                child: pw.Text(value.isEmpty ? '—' : value, style: valueStyle),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final section = v('formSection').toLowerCase();
  final showA = section.isEmpty || section.contains('main') || section.contains('form a');
  final showB =
      section.isEmpty || section.contains('continuation') || section.contains('form b');

  if (showA) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text('Form A / नमुना "अ"', style: titleStyle),
                  pw.SizedBox(height: 4),
                  pw.Text('(See Rule No 3) / (नियम क्र. ३ पहा)', style: bodyStyle),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Certificate by registered medical practitioner regarding consumption of an intoxicant.',
                    textAlign: pw.TextAlign.center,
                    style: bodyStyle,
                  ),
                  pw.Text(
                    'नोंदणीकृत वैद्यकीय अधिकारी — मद्य/नशा सेवन प्रमाणपत्र',
                    textAlign: pw.TextAlign.center,
                    style: marathiBold,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            bilingualFieldRow('Serial No', 'अ.क्र.', v('serialNo')),
            bilingualFieldRow('Dispensary / Hospital', 'दवाखाना / औषधालय', v('dispensary')),
            bilingualFieldRow('Person examined', 'तपासण्यात आलेली व्यक्ती', v('personName')),
            bilingualFieldRow('Brought by', 'कोणी आणले', v('broughtBy')),
            bilingualFieldRow(
              'Brought on',
              'आणण्याची तारीख/वेळ',
              '${v('broughtDate')} ${v('broughtTime')} ${v('broughtAmPm')}',
            ),
            bilingualFieldRow(
              'Examined on',
              'तपासणी दिनांक/वेळ',
              '${v('examinedDate')} ${v('examinedTime')} ${v('examinedAmPm')}',
            ),
            pw.SizedBox(height: 8),
            pw.Text('Clinical examination / वैद्यकीय तपासणी', style: boldStyle),
            pw.Text('वैद्यकीय तपासणी', style: marathiStyle),
            bilingualFieldRow('Age', 'वय', v('age')),
            bilingualFieldRow('Weight', 'वजन', v('weight')),
            bilingualFieldRow('Breath', 'श्वास', v('breath')),
            bilingualFieldRow('Speech', 'बोलणे', v('speech')),
            bilingualFieldRow('Gait', 'चाल', v('gait')),
            bilingualFieldRow('Pupils', 'डोळ्यांची बाभळ', v('pupils')),
            bilingualFieldRow('Additional remarks', 'अतिरिक्त शेरा', v('additionalRemarks')),
            bilingualFieldRow('Consumed', 'सेवन', '${v('consumed')} ${v('intoxicantType')}'),
            bilingualFieldRow('Under influence', 'मद्याच्या प्रभावाखाली', v('underInfluence')),
            bilingualFieldRow('Blood collected', 'रक्त गोळा', v('bloodCollected')),
            pw.SizedBox(height: 8),
            bilingualFieldRow('Dated', 'दिनांक', v('formADated')),
            bilingualFieldRow('Time', 'वेळ', v('formATime')),
            bilingualFieldRow('MO Signature', 'वै.अ. सही', v('moSignature')),
            bilingualFieldRow('Designation', 'पदनाम', v('moDesignation')),
            bilingualFieldRow('Examined person signature', 'तपासलेल्याची सही', v('examinedSignature')),
            bilingualFieldRow('Identification marks', 'ओळखीच्या खुणा', v('identificationMarks')),
          ],
        ),
      ),
    );
  }

  if (showB) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text('FORM "B" / नमुना "ब"', style: titleStyle),
                  pw.Text('(See rule 4 (2)) / (नियम ४ (२) पहा)', style: bodyStyle),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            bilingualFieldRow('No.', 'क्र.', v('formBNo')),
            bilingualFieldRow('From', 'पाठवणार', v('fromPractitioner')),
            bilingualFieldRow('To', 'प्रति', v('toTestingOfficer')),
            bilingualFieldRow('Date', 'दिनांक', v('formBDate')),
            bilingualFieldRow('Messenger', 'दूत', v('messengerName')),
            bilingualFieldRow('Phial serial No.', 'शीशी अ.क्र.', v('phialSerial')),
            bilingualFieldRow('Blood amount (c.c.)', 'रक्त (स.स.)', v('bloodAmountCc')),
            bilingualFieldRow(
              'Collected on',
              'गोळा दिनांक/वेळ',
              '${v('collectionDate')} ${v('collectionTime')} ${v('collectionAmPm')}',
            ),
            bilingualFieldRow('Subject', 'व्यक्ती', v('subjectName')),
            bilingualFieldRow('Subject address', 'पत्ता', v('subjectAddress')),
            bilingualFieldRow('Produced by', 'सादर केले', v('producedBy')),
            bilingualFieldRow('Signature / designation', 'सही / पदनाम', v('formBSignature')),
            bilingualFieldRow('Seal facsimile', 'शिक्का प्रतिकृती', v('sealFacsimile')),
          ],
        ),
      ),
    );
  }

  return pdf.save();
}
