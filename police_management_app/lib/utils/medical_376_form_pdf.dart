import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> previewMedical376FormPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) async {
  final bytes = await generateMedical376FormPdf(doc);
  if (!context.mounted) return;
  final fileName = '376_Medical_Form_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

Future<Uint8List> generateMedical376FormPdf(Map<String, dynamic> doc) async {
  final pdf = pw.Document();
  final loraRegular = await PdfGoogleFonts.loraRegular();
  final loraBold = await PdfGoogleFonts.loraBold();
  final devanagari = await PdfGoogleFonts.notoSansDevanagariRegular();
  final devanagariBold = await PdfGoogleFonts.notoSansDevanagariBold();

  final body = pw.TextStyle(font: loraRegular, fontSize: 10);
  final bold = pw.TextStyle(font: loraBold, fontSize: 11, fontWeight: pw.FontWeight.bold);
  final title = pw.TextStyle(font: loraBold, fontSize: 14, fontWeight: pw.FontWeight.bold);
  final marathi = pw.TextStyle(font: devanagari, fontSize: 8.5);
  final marathiBold = pw.TextStyle(font: devanagariBold, fontSize: 9, fontWeight: pw.FontWeight.bold);
  final value = pw.TextStyle(font: devanagari, fontSize: 10, color: PdfColors.blue900);

  String v(String key) => doc[key]?.toString().trim() ?? '';

  pw.Widget row(String labelEn, String labelMr, String val) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 180,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(labelEn, style: bold),
                pw.Text(labelMr, style: marathi),
              ],
            ),
          ),
          pw.Expanded(child: pw.Text(val.isEmpty ? '—' : val, style: value)),
        ],
      ),
    );
  }

  pw.Widget section(String en, String mr) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(en, style: bold),
          pw.Text(mr, style: marathiBold),
        ],
      ),
    );
  }

  pw.Widget textBlock(String en, String mr) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(en.isEmpty ? '—' : en, style: body),
          if (mr.isNotEmpty) pw.Text(mr, style: marathi),
        ],
      ),
    );
  }

  final sectionKey = v('formSection').toLowerCase();
  final showFemale = sectionKey.isEmpty || sectionKey.contains('female');
  final showMale = sectionKey.isEmpty || sectionKey.contains('male');

  if (showFemale) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Text(
            'महाराष्ट्र शासन — सार्वजनिक आरोग्य विभाग. परिपत्रक क्र.: संकीर्ण-२०१४/प्र.क्र.२७०/आरोग्य-३. दिनांक: ०७ ऑगस्ट, २०१५.',
            style: marathiBold,
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('CONFIDENTIAL', style: bold),
                pw.Text('गोपनीय', style: marathiBold),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'Medico-legal Examination Report of Sexual Violence (Female)',
                  style: title,
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  'लैंगिक हिंसाचाराचा वैद्यकीय-कायदेशीर तपासणी अहवाल (स्त्री)',
                  style: marathiBold,
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          row('Hospital', 'रुग्णालय', v('f_hospital')),
          row('Name', 'नाव', v('f_name')),
          row('Age / DOB', 'वय / जन्मतारीख', '${v('f_age')} / ${v('f_dob')}'),
          row('MLC / P.S.', 'एम.एल.सी. / पो.ठ.', '${v('f_mlc')} / ${v('f_ps')}'),
          row('Arrival', 'आगमन', v('f_arrival')),
          section('12. Informed Consent / Refusal', '१२. माहितीपूर्ण संमती / नकार'),
          textBlock(v('f_consent'), 'संमती तपशील'),
          section('History of Sexual Violence', 'लैंगिक हिंसाचाराचा इतिहास'),
          textBlock(v('f_violenceHistory'), ''),
          section('General Physical Examination', 'सामान्य शारीरिक तपासणी'),
          textBlock(v('f_generalExam'), ''),
          section('Injury Examination', 'जखमा तपासणी'),
          ...() {
            final rows = doc['f_injuryRows'];
            if (rows is! List || rows.isEmpty) {
              return [pw.Text('—', style: body)];
            }
            return rows.asMap().entries.map(
              (e) => pw.Text('${e.key + 1}. ${e.value}', style: value),
            );
          }(),
          section('Genital / Local Examination', 'गुप्तांग / स्थानिक तपासणी'),
          textBlock(v('f_genitalExam'), ''),
          section('Provisional Opinion', 'तात्पुरते मत'),
          textBlock(v('f_provisionalOpinion'), ''),
          section('Final Opinion', 'अंतिम मत'),
          textBlock(v('f_finalOpinion'), ''),
          pw.SizedBox(height: 8),
          pw.Text(
            'COPY OF THE ENTIRE MEDICAL REPORT MUST BE GIVEN TO THE SURVIVOR/VICTIM FREE OF COST IMMEDIATELY',
            style: bold.copyWith(fontSize: 9),
          ),
          pw.Text(
            'संपूर्ण वैद्यकीय अहवालाची प्रत पीडित/पीडितेला त्वरित विनामूल्य द्यावी',
            style: marathiBold,
          ),
        ],
      ),
    );
  }

  if (showMale) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'Forensic Medical Examination of Alleged Accused (Male)',
                  style: title,
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  'आरोपीची फॉरेन्सिक वैद्यकीय तपासणी (पुरुष)',
                  style: marathiBold,
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          row('Hospital', 'रुग्णालय', v('m_hospital')),
          row('Accused Name', 'आरोपीचे नाव', v('m_accusedName')),
          row('Age / DOB', 'वय / जन्मतारीख', '${v('m_age')} / ${v('m_dob')}'),
          row('MLC / C.R.No', 'एम.एल.सी. / गु.नो.', '${v('m_mlc')} / ${v('m_crNo')}'),
          row('Police / P.S.', 'पोलीस / ठाणे', '${v('m_policeName')} / ${v('m_ps')}'),
          section('8. CONSENT', '८. संमती'),
          textBlock(v('m_consent'), 'संमती तपशील'),
          section('History (as stated by Accused)', 'आरोपीने सांगितलेला इतिहास'),
          textBlock(v('m_assaultHistory'), ''),
          section('General Physical Examination', 'सामान्य शारीरिक तपासणी'),
          textBlock(v('m_generalPhysical'), ''),
          section('Local Examination', 'स्थानिक तपासणी'),
          textBlock(v('m_localExam'), ''),
          section('Provisional Opinion', 'तात्पुरते मत'),
          textBlock(v('m_provisionalOpinion'), ''),
          row('Doctor Signature', 'डॉ. सही', v('m_doctorSig')),
          section('Police Receipt', 'पोलीस पावती'),
          textBlock(v('m_receiptPolice'), ''),
        ],
      ),
    );
  }

  return pdf.save();
}
