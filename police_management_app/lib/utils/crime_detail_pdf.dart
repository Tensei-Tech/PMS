import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'marathi_text_renderer.dart';
import 'form_io_terminology.dart';
import '../widgets/form_section_utils.dart';

Future<void> previewCrimeDetailPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) async {
  final bytes = await generateCrimeDetailPdf(doc);
  if (!context.mounted) return;
  final fileName = 'Crime_Detail_Form_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

Future<Uint8List> generateCrimeDetailPdf(Map<String, dynamic> doc) async {
  final pdf = pw.Document();

  // Load fonts dynamically from Google Fonts via Printing package
  final loraRegular = await PdfGoogleFonts.loraRegular();
  final loraBold = await PdfGoogleFonts.loraBold();
  final devanagariRegular = await PdfGoogleFonts.notoSansDevanagariRegular();
  final devanagariBold = await PdfGoogleFonts.notoSansDevanagariBold();

  // Pre-render Marathi text blocks to cache as images to resolve Indic shaping issues
  final cache = await _preRenderAllMarathi(doc);

  const knownSectionIds = {'Form 2-A', 'Form 2-B', 'Form 2-C'};
  final activeSection = doc['formSection']?.toString();

  bool showsSection(String sectionId) => showsFormSection(
        activeSection: activeSection,
        sectionId: sectionId,
        knownSectionIds: knownSectionIds,
      );

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

  final pw.TextStyle marathiStyle = pw.TextStyle(
    font: devanagariBold,
    fontSize: 8.5,
    color: PdfColors.black,
  );

  final pw.TextStyle valueStyle = pw.TextStyle(
    font: devanagariRegular,
    fontSize: 10,
    color: PdfColors.blue900,
  );

  // Load Map Image if available
  pw.MemoryImage? mapImage;
  final mapPath = doc['mapImagePath']?.toString() ?? '';
  if (mapPath.isNotEmpty) {
    try {
      if (kIsWeb) {
        if (mapPath.startsWith('data:image')) {
          final uri = Uri.parse(mapPath);
          mapImage = pw.MemoryImage(uri.data!.contentAsBytes());
        }
      } else {
        final file = File(mapPath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          mapImage = pw.MemoryImage(bytes);
        }
      }
    } catch (e) {
      // Ignore load errors
    }
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      footer: (pw.Context context) {
        return pw.Align(
          alignment: pw.Alignment.bottomRight,
          child: pw.Text(
            'M.R.W',
            style: englishBold.copyWith(fontSize: 9),
          ),
        );
      },
      build: (pw.Context context) {
        return [
            if (showsSection('Form 2-A')) ...[
            // --- HEADER ---
            pw.Align(
              alignment: pw.Alignment.topRight,
              child: pw.Text(
                'Form: 2-A',
                style: englishBold.copyWith(
                  decoration: pw.TextDecoration.underline,
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'CRIME DETAILS FORM',
                    style: englishBold.copyWith(
                      fontSize: 16,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  if (cache.has('header_title'))
                    cache.img('header_title')
                  else
                    pw.Text(
                      'गुन्ह्यांच्या तपशीलाचा नमुना/ घटनास्थल पंचनामा',
                      style: pw.TextStyle(
                        font: devanagariBold,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // --- SECTION 1 (Row 1 - District, P.S., Year, FIR No, Date) ---
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 22,
                  child: _buildPdfInlineField(
                    label: '1) District: ',
                    marathiLabelKey: 'lbl_district',
                    valKey: 'val_district',
                    fallbackValue: doc['district']?.toString() ?? '',
                    englishStyle: englishStyle,
                    marathiStyle: marathiStyle,
                    valueStyle: valueStyle,
                    cache: cache,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  flex: 28,
                  child: _buildPdfInlineField(
                    label: 'P.S.: ',
                    marathiLabelKey: 'lbl_ps',
                    valKey: 'val_ps',
                    fallbackValue: doc['ps'] ?? '',
                    englishStyle: englishStyle,
                    marathiStyle: marathiStyle,
                    valueStyle: valueStyle,
                    cache: cache,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  flex: 15,
                  child: _buildPdfInlineField(
                    label: 'Year: ',
                    marathiLabelKey: 'lbl_year',
                    valKey: 'val_year',
                    fallbackValue: doc['year'] ?? '',
                    englishStyle: englishStyle,
                    marathiStyle: marathiStyle,
                    valueStyle: valueStyle,
                    cache: cache,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  flex: 22,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Text('FIR No: ', style: englishStyle),
                          pw.Expanded(
                            child: pw.Container(
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(color: PdfColors.black, width: 0.8),
                                ),
                              ),
                              alignment: pw.Alignment.bottomCenter,
                              child: cache.has('val_firNo')
                                  ? cache.img('val_firNo')
                                  : pw.Text(doc['firNo'] ?? '', style: valueStyle),
                            ),
                          ),
                          pw.Text('/20', style: englishStyle),
                          pw.Container(
                            width: 15,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom: pw.BorderSide(color: PdfColors.black, width: 0.8),
                                ),
                              ),
                              alignment: pw.Alignment.bottomCenter,
                              child: cache.has('val_firYearSuffix')
                                  ? cache.img('val_firYearSuffix')
                                  : pw.Text(doc['firYearSuffix'] ?? '', style: valueStyle),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 4.0),
                          child: cache.has('lbl_fir_no')
                              ? cache.img('lbl_fir_no')
                              : pw.Text('पहिली खबर क्र.', style: marathiStyle),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    flex: 28,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text('Date : ', style: englishStyle),
                            pw.Container(
                              width: 18,
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(color: PdfColors.black, width: 0.8),
                                ),
                              ),
                              alignment: pw.Alignment.bottomCenter,
                              child: cache.has('val_dateDay')
                                  ? cache.img('val_dateDay')
                                  : pw.Text(doc['dateDay'] ?? '', style: valueStyle),
                            ),
                            pw.Text('/', style: englishStyle),
                            pw.Container(
                              width: 18,
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(color: PdfColors.black, width: 0.8),
                                ),
                              ),
                              alignment: pw.Alignment.bottomCenter,
                              child: cache.has('val_dateMonth')
                                  ? cache.img('val_dateMonth')
                                  : pw.Text(doc['dateMonth'] ?? '', style: valueStyle),
                            ),
                            pw.Text('/20', style: englishStyle),
                            pw.Container(
                              width: 18,
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(color: PdfColors.black, width: 0.8),
                                ),
                              ),
                              alignment: pw.Alignment.bottomCenter,
                              child: cache.has('val_dateYear')
                                  ? cache.img('val_dateYear')
                                  : pw.Text(doc['dateYear'] ?? '', style: valueStyle),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 4.0),
                          child: cache.has('lbl_date')
                              ? cache.img('lbl_date')
                              : pw.Text('तारीख', style: marathiStyle),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),

              // --- SECTION 2 ---
              _buildPdfWideField(
                label: '2) Act and Section:',
                marathiLabelKey: 'lbl_act_sec',
                valKey: 'val_actSection',
                fallbackValue: doc['actSection'] ?? '',
                englishStyle: englishStyle,
                marathiStyle: marathiStyle,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.SizedBox(height: 8),

              // --- SECTION 3 ---
              pw.Text(
                '3) The Place of Occurrence shown by:',
                style: englishStyle,
              ),
              if (cache.has('lbl_shown_by'))
                cache.img('lbl_shown_by')
              else
                pw.Text(
                  'घटनेचे ठिकाण दाखविणाऱ्याचे :',
                  style: pw.TextStyle(font: devanagariBold, fontSize: 10, color: PdfColors.black),
                ),
              pw.SizedBox(height: 4),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _buildPdfInlineField(
                      label: 'Name: ',
                      marathiLabelKey: 'lbl_name',
                      valKey: 'val_shownByName',
                      fallbackValue: doc['shownByName'] ?? '',
                      englishStyle: englishStyle,
                      marathiStyle: marathiStyle,
                      valueStyle: valueStyle,
                      cache: cache,
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: _buildPdfInlineField(
                      label: 'Father\'s/ Husband\'s Name: ',
                      marathiLabelKey: 'lbl_father_husband',
                      valKey: 'val_shownByFatherHusband',
                      fallbackValue: doc['shownByFatherHusband'] ?? '',
                      englishStyle: englishStyle,
                      marathiStyle: marathiStyle,
                      valueStyle: valueStyle,
                      cache: cache,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              _buildPdfWideField(
                label: 'Address:',
                marathiLabelKey: 'lbl_address',
                valKey: 'val_shownByAddress',
                fallbackValue: doc['shownByAddress'] ?? '',
                englishStyle: englishStyle,
                marathiStyle: marathiStyle,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.SizedBox(height: 8),

              // --- SECTION 4 ---
              _buildPdfWideField(
                label: '4) TYPE OF CRIME (All including M.O. Crime) :',
                marathiLabelKey: 'lbl_type_crime',
                valKey: 'val_typeOfCrime',
                fallbackValue: doc['typeOfCrime'] ?? '',
                englishStyle: englishStyle,
                marathiStyle: marathiStyle,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _buildPdfInlineField(
                      label: '(i) *Major Head: : ',
                      marathiLabelKey: 'lbl_major_head',
                      valKey: 'val_majorHead',
                      fallbackValue: doc['majorHead'] ?? '',
                      englishStyle: englishStyle,
                      marathiStyle: marathiStyle,
                      valueStyle: valueStyle,
                      cache: cache,
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: _buildPdfInlineField(
                      label: '(ii): * Minor Head : : ',
                      marathiLabelKey: 'lbl_minor_head',
                      valKey: 'val_minorHead',
                      fallbackValue: doc['minorHead'] ?? '',
                      englishStyle: englishStyle,
                      marathiStyle: marathiStyle,
                      valueStyle: valueStyle,
                      cache: cache,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              _buildPdfWideField(
                label: '(iii) * Method (s):',
                marathiLabelKey: 'lbl_method',
                valKey: 'val_method',
                fallbackValue: doc['method'] ?? '',
                englishStyle: englishStyle,
                marathiStyle: marathiStyle,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.SizedBox(height: 4),
              _buildNumberedMethodPdfField(
                numberKey: 'lbl_m1',
                valKey: 'val_method1',
                fallbackValue: doc['method1'] ?? '',
                devanagariRegular: devanagariBold,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.SizedBox(height: 4),
              _buildNumberedMethodPdfField(
                numberKey: 'lbl_m2',
                valKey: 'val_method2',
                fallbackValue: doc['method2'] ?? '',
                devanagariRegular: devanagariBold,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.SizedBox(height: 4),
              _buildNumberedMethodPdfField(
                numberKey: 'lbl_m3',
                valKey: 'val_method3',
                fallbackValue: doc['method3'] ?? '',
                devanagariRegular: devanagariBold,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.SizedBox(height: 6),
              _buildPdfWideField(
                label: '(iv) Conveyances used:',
                marathiLabelKey: 'lbl_conveyances',
                valKey: 'val_conveyances',
                fallbackValue: doc['conveyances'] ?? '',
                englishStyle: englishStyle,
                marathiStyle: marathiStyle,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.SizedBox(height: 6),
              _buildPdfWideField(
                label: '(V)* Character Assumed:',
                marathiLabelKey: 'lbl_character',
                valKey: 'val_characterAssumed',
                fallbackValue: doc['characterAssumed'] ?? '',
                englishStyle: englishStyle,
                marathiStyle: marathiStyle,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.SizedBox(height: 6),
              _buildPdfWideField(
                label: '(Vi)* Language/ slang used:',
                marathiLabelKey: 'lbl_lang',
                valKey: 'val_languageSlang',
                fallbackValue: doc['languageSlang'] ?? '',
                englishStyle: englishStyle,
                marathiStyle: marathiStyle,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.SizedBox(height: 6),
              _buildPdfWideField(
                label: '(Vii)* Special Feature-1:',
                marathiLabelKey: 'lbl_sf1',
                valKey: 'val_specialFeature1',
                fallbackValue: doc['specialFeature1'] ?? '',
                englishStyle: englishStyle,
                marathiStyle: marathiStyle,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.SizedBox(height: 6),
              _buildPdfWideField(
                label: '*Special Feature-2:',
                marathiLabelKey: 'lbl_sf2',
                valKey: 'val_specialFeature2',
                fallbackValue: doc['specialFeature2'] ?? '',
                englishStyle: englishStyle,
                marathiStyle: marathiStyle,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.SizedBox(height: 6),
              _buildPdfWideField(
                label: '*Special Feature-3:',
                marathiLabelKey: 'lbl_sf3',
                valKey: 'val_specialFeature3',
                fallbackValue: doc['specialFeature3'] ?? '',
                englishStyle: englishStyle,
                marathiStyle: marathiStyle,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.SizedBox(height: 6),
              _buildPdfWideField(
                label: '(Viii) Type of Place of Occurrence:',
                marathiLabelKey: 'lbl_place_type',
                valKey: 'val_placeOfOccurrenceType',
                fallbackValue: doc['placeOfOccurrenceType'] ?? '',
                englishStyle: englishStyle,
                marathiStyle: marathiStyle,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.SizedBox(height: 6),
              _buildPdfWideField(
                label: '(ix) Type of Property Involved ( 4 Types ):',
                marathiLabelKey: 'lbl_prop_inv',
                valKey: 'val_propertyInvolved',
                fallbackValue: doc['propertyInvolved'] ?? '',
                englishStyle: englishStyle,
                marathiStyle: marathiStyle,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildPdfInlineField(
                      label: '(1) ',
                      marathiLabelKey: '',
                      valKey: 'val_propertyType1',
                      fallbackValue: doc['propertyType1'] ?? '',
                      englishStyle: englishStyle,
                      marathiStyle: marathiStyle,
                      valueStyle: valueStyle,
                      cache: cache,
                      showMarathiLabel: false,
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: _buildPdfInlineField(
                      label: '(2) ',
                      marathiLabelKey: '',
                      valKey: 'val_propertyType2',
                      fallbackValue: doc['propertyType2'] ?? '',
                      englishStyle: englishStyle,
                      marathiStyle: marathiStyle,
                      valueStyle: valueStyle,
                      cache: cache,
                      showMarathiLabel: false,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildPdfInlineField(
                      label: '(3) ',
                      marathiLabelKey: '',
                      valKey: 'val_propertyType3',
                      fallbackValue: doc['propertyType3'] ?? '',
                      englishStyle: englishStyle,
                      marathiStyle: marathiStyle,
                      valueStyle: valueStyle,
                      cache: cache,
                      showMarathiLabel: false,
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: _buildPdfInlineField(
                      label: '(4) ',
                      marathiLabelKey: '',
                      valKey: 'val_propertyType4',
                      fallbackValue: doc['propertyType4'] ?? '',
                      englishStyle: englishStyle,
                      marathiStyle: marathiStyle,
                      valueStyle: valueStyle,
                      cache: cache,
                      showMarathiLabel: false,
                    ),
                  ),
                ],
              ),


            // Conditional page break between Page 1 and Page 2
            ],
            if (showsSection('Form 2-B')) ...[
            pw.NewPage(freeSpace: 350),

            // --- PAGE 2: Form 2-B ---
            pw.Align(
              alignment: pw.Alignment.topRight,
              child: pw.Text(
                'Form: 2-B',
                style: englishBold.copyWith(
                  decoration: pw.TextDecoration.underline,
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '5) Particulars of the victims (Attach separate sheet, if required)',
              style: englishBold.copyWith(fontSize: 10),
            ),
            if (cache.has('lbl_victim_title'))
              cache.img('lbl_victim_title')
            else
              pw.Text(
                'बळीचा तपशील ( आवश्यक असल्यास स्वतंत्र कागद जोडावा. )',
                style: pw.TextStyle(
                  font: devanagariBold,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            pw.SizedBox(height: 6),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: pw.FixedColumnWidth(25),  // Sr No
                1: pw.FlexColumnWidth(2.5),  // Full Name
                2: pw.FlexColumnWidth(2.0),  // Date/Year of Birth
                3: pw.FlexColumnWidth(1.2),  // Sex
                4: pw.FlexColumnWidth(1.8),  // Nationality
                5: pw.FlexColumnWidth(1.8),  // Religion
                6: pw.FlexColumnWidth(2.0),  // SC/ST
                7: pw.FlexColumnWidth(2.0),  // Occupation
                8: pw.FlexColumnWidth(2.5),  // Address
                9: pw.FlexColumnWidth(2.0),  // Injury
                10: pw.FlexColumnWidth(2.0), // Means
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _buildPdfHeaderCell("Sr.\nNo\n\nअ.\nक.\n\n(1)", "th_1", devanagariBold, cache),
                    _buildPdfHeaderCell("Full Name\n\nसंपूर्ण नांव\n\n(2)", "th_2", devanagariBold, cache),
                    _buildPdfHeaderCell("Date/Year\nof Birth\n\nजन्म तारीख/\nवर्ष\n\n(3)", "th_3", devanagariBold, cache),
                    _buildPdfHeaderCell("Sex\n\nलिंग\n\n(*4)", "th_4", devanagariBold, cache),
                    _buildPdfHeaderCell("Nationality\n\nराष्ट्रीयत्व\n\n(*5)", "th_5", devanagariBold, cache),
                    _buildPdfHeaderCell("Religion\n\nधर्म\n\n(*6)", "th_6", devanagariBold, cache),
                    _buildPdfHeaderCell("Whether\nSC/ ST\n\nजाती\n/जमाती\n\n(*7)", "th_7", devanagariBold, cache),
                    _buildPdfHeaderCell("Ocupetion\n\nव्यवसाय\n\n(*8)", "th_8", devanagariBold, cache),
                    _buildPdfHeaderCell("Address\n\nपत्ता\n\n(*9)", "th_9", devanagariBold, cache),
                    _buildPdfHeaderCell("Injury:\ngrievous/\nSimple\n\nदुखापत\nगंभीर/साधी\n\n(10)", "th_10", devanagariBold, cache),
                    _buildPdfHeaderCell("Means\n\nसाधने/\nहत्यारे\n\n(11)", "th_11", devanagariBold, cache),
                  ],
                ),
                ..._buildPdfVictimsRows(doc['victims'], devanagariRegular, cache),
              ],
            ),
            pw.SizedBox(height: 8),

            pw.SizedBox(height: 6),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('6) Motive of Crime: ', style: englishBold.copyWith(fontSize: 9)),
                pw.Expanded(
                  child: pw.Stack(
                    alignment: pw.Alignment.bottomLeft,
                    children: [
                      pw.Container(
                        height: 10,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: PdfColors.black,
                              width: 0.8,
                              style: pw.BorderStyle.dashed,
                            ),
                          ),
                        ),
                      ),
                      if ((doc['motiveOfCrime']?.toString() ?? '').trim().isNotEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 1, left: 4),
                          child: cache.has('val_motiveOfCrime')
                              ? cache.img('val_motiveOfCrime')
                              : pw.Text(
                                  doc['motiveOfCrime'].toString(),
                                  style: valueStyle.copyWith(fontSize: 9),
                                ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 3),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (cache.has('lbl_motive'))
                  cache.img('lbl_motive')
                else
                  pw.Text('गुन्ह्याचा हेतू : ', style: pw.TextStyle(font: devanagariBold, fontSize: 9)),
                pw.Expanded(
                  child: pw.Container(
                    height: 10,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.8,
                          style: pw.BorderStyle.dashed,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 3),
            pw.Container(
              height: 10,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: PdfColors.black,
                    width: 0.8,
                    style: pw.BorderStyle.dashed,
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              '7) Details of properties Stolen/Involved: (Use appropriate prescribed forms (s) and attach):',
              style: englishBold.copyWith(fontSize: 9),
            ),
            if (cache.has('lbl_prop_det'))
              cache.img('lbl_prop_det')
            else
              pw.Text(
                'चोरीचा / अंतर्भूत मालमत्तेचा तपशील (योग्य नमुना वापरावा व सोबत जोडावा) :',
                style: pw.TextStyle(font: devanagariBold, fontSize: 8.5, fontWeight: pw.FontWeight.bold),
              ),
            pw.SizedBox(height: 2),
            ..._buildPdfLinedBlock(doc['propertyDetails']?.toString() ?? '', 4, 85, valueStyle, 'val_propertyDetails', cache),
            pw.SizedBox(height: 8),

            pw.Text(
              '8) Description of the place of occurrence:',
              style: englishBold.copyWith(fontSize: 9),
            ),
            if (cache.has('lbl_place_desc'))
              cache.img('lbl_place_desc')
            else
              pw.Text(
                '(घटनेच्या जागेचे वर्णन) :',
                style: pw.TextStyle(font: devanagariBold, fontSize: 8.5, fontWeight: pw.FontWeight.bold),
              ),
            pw.SizedBox(height: 2),
            ..._buildPdfLinedBlock(doc['placeDescription']?.toString() ?? '', 6, 85, valueStyle, 'val_placeDescription', cache),
            pw.SizedBox(height: 6),

            // Conditional page break between Page 2 and Page 3
            ],
            if (showsSection('Form 2-C')) ...[
            pw.NewPage(freeSpace: 350),
            pw.Align(
              alignment: pw.Alignment.topRight,
              child: pw.Text(
                'Form: 2-C',
                style: englishBold.copyWith(
                  decoration: pw.TextDecoration.underline,
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Description of the place of occurrence (Cont.):',
              style: englishBold.copyWith(fontSize: 10),
            ),
            if (cache.has('lbl_place_desc_cont'))
              cache.img('lbl_place_desc_cont')
            else
              pw.Text(
                '(घटनेच्या जागेचे वर्णन) :',
                style: pw.TextStyle(
                  font: devanagariBold,
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            pw.SizedBox(height: 2),
            ..._buildPdfLinedBlock(doc['placeDescriptionCont']?.toString() ?? '', 6, 85, valueStyle, 'val_placeDescriptionCont', cache),
            pw.SizedBox(height: 8),

            // --- SECTION 9: Map ---
            if (cache.has('lbl_map'))
              cache.img('lbl_map')
            else
              pw.Text(
                '(9) Map: नकाशा',
                style: englishBold.copyWith(fontSize: 10),
              ),
            pw.SizedBox(height: 4),
            pw.Container(
              width: double.infinity,
              height: 220,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1.5),
              ),
              child: mapImage != null
                  ? pw.Center(
                      child: pw.Image(mapImage, fit: pw.BoxFit.contain),
                    )
                  : pw.Center(
                      child: cache.has('lbl_no_map')
                          ? cache.img('lbl_no_map')
                          : pw.Text(
                              'No Map Uploaded\n(नकाशा जोडला नाही)',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                font: devanagariRegular,
                                fontSize: 10,
                                color: PdfColors.grey500,
                              ),
                            ),
                    ),
            ),


            // Conditional page break between Page 3 and Page 4
            pw.NewPage(freeSpace: 350),

            // --- PAGE 4: Form 2-D ---
            // --- SECTION 10: Physical Evidence ---
            pw.Text(
              '(10) Description of physical evidence from the science of crime for the property recovered / seized for the purpose of investigation:',
              style: englishBold.copyWith(fontSize: 9),
            ),
            if (cache.has('lbl_phys_ev'))
              cache.img('lbl_phys_ev')
            else
              pw.Text(
                'तпасकामी प्रत्यक्ष पुरावा म्हणून गुन्ह्याच्या जागेवरून मिळविलेल्या / जप्त केलेल्या मालमत्तेचे वर्णन :',
                style: pw.TextStyle(
                  font: devanagariBold,
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            pw.SizedBox(height: 2),
            ..._buildPdfLinedBlock(doc['physicalEvidence']?.toString() ?? '', 6, 85, valueStyle, 'val_physicalEvidence', cache),
            pw.SizedBox(height: 6),
            pw.Divider(color: PdfColors.black, thickness: 0.8),
            pw.SizedBox(height: 4),

            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left Column
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildPdfLinedField(
                        labelKey: 'lbl_dt_panchnama',
                        valKeyPrefix: 'val_panchnamaDate',
                        fallbackValue: doc['panchnamaDate']?.toString() ?? '',
                        linesCount: 1,
                        style: valueStyle,
                        font: devanagariBold,
                        cache: cache,
                      ),
                      pw.SizedBox(height: 6),

                      if (cache.has('lbl_panchas_name'))
                        cache.img('lbl_panchas_name')
                      else
                        pw.Text("Name of panchas: / पंचाची नांवे :", style: englishBold.copyWith(fontSize: 8.5)),
                      pw.SizedBox(height: 4),

                      pw.Text("(1)", style: englishBold.copyWith(fontSize: 9)),
                      pw.SizedBox(height: 2),
                      _buildPdfLinedField(
                        labelKey: '',
                        valKeyPrefix: 'val_pancha1Name',
                        fallbackValue: doc['pancha1Name']?.toString() ?? '',
                        linesCount: 1,
                        style: valueStyle,
                        font: devanagariBold,
                        cache: cache,
                      ),
                      pw.SizedBox(height: 4),
                      _buildPdfLinedField(
                        labelKey: 'lbl_p1_addr',
                        valKeyPrefix: 'val_pancha1Address',
                        fallbackValue: doc['pancha1Address']?.toString() ?? '',
                        linesCount: 3,
                        style: valueStyle,
                        font: devanagariBold,
                        cache: cache,
                      ),
                      pw.SizedBox(height: 4),

                      pw.Text("(2)", style: englishBold.copyWith(fontSize: 9)),
                      pw.SizedBox(height: 2),
                      _buildPdfLinedField(
                        labelKey: '',
                        valKeyPrefix: 'val_pancha2Name',
                        fallbackValue: doc['pancha2Name']?.toString() ?? '',
                        linesCount: 1,
                        style: valueStyle,
                        font: devanagariBold,
                        cache: cache,
                      ),
                      pw.SizedBox(height: 4),
                      _buildPdfLinedField(
                        labelKey: 'lbl_p2_addr',
                        valKeyPrefix: 'val_pancha2Address',
                        fallbackValue: doc['pancha2Address']?.toString() ?? '',
                        linesCount: 3,
                        style: valueStyle,
                        font: devanagariBold,
                        cache: cache,
                      ),
                      pw.SizedBox(height: 6),

                      _buildPdfLinedField(
                        labelKey: 'lbl_date_form',
                        valKeyPrefix: 'val_panchnamaFormDate',
                        fallbackValue: doc['panchnamaFormDate']?.toString() ?? '',
                        linesCount: 1,
                        style: valueStyle,
                        font: devanagariBold,
                        cache: cache,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 30),
                // Right Column
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildPdfLinedField(
                        labelKey: 'lbl_time_form',
                        valKeyPrefix: 'val_panchnamaTime',
                        fallbackValue: doc['panchnamaTime']?.toString() ?? '',
                        linesCount: 1,
                        style: valueStyle,
                        font: devanagariBold,
                        cache: cache,
                      ),
                      pw.SizedBox(height: 6),

                      if (cache.has('lbl_panchas_sig'))
                        cache.img('lbl_panchas_sig')
                      else
                        pw.Text("Signature of Panchas: / पंचाच्या सह्या :", style: englishBold.copyWith(fontSize: 8.5)),
                      pw.SizedBox(height: 4),
                      pw.Text("1)", style: englishBold.copyWith(fontSize: 9)),
                      pw.SizedBox(height: 2),
                      _buildPdfLinedField(
                        labelKey: '',
                        valKeyPrefix: 'val_pancha1Sig',
                        fallbackValue: doc['pancha1Sig']?.toString() ?? '',
                        linesCount: 1,
                        style: valueStyle,
                        font: devanagariBold,
                        cache: cache,
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text("2)", style: englishBold.copyWith(fontSize: 9)),
                      pw.SizedBox(height: 2),
                      _buildPdfLinedField(
                        labelKey: '',
                        valKeyPrefix: 'val_pancha2Sig',
                        fallbackValue: doc['pancha2Sig']?.toString() ?? '',
                        linesCount: 1,
                        style: valueStyle,
                        font: devanagariBold,
                        cache: cache,
                      ),
                      pw.SizedBox(height: 6),

                      if (cache.has('lbl_io_sig'))
                        cache.img('lbl_io_sig')
                      else
                        pw.Text("Name and Signature of Investigation Officer", style: englishBold.copyWith(fontSize: 8.5)),
                      if (cache.has('lbl_io_sig_mar'))
                        cache.img('lbl_io_sig_mar')
                      else
                        pw.Text(FormIoTerminology.amaldarSignatureHeader, style: marathiStyle),
                      pw.SizedBox(height: 4),
                      _buildPdfLinedField(
                        labelKey: 'lbl_io_name',
                        valKeyPrefix: 'val_ioName',
                        fallbackValue: doc['ioName']?.toString() ?? '',
                        linesCount: 1,
                        style: valueStyle,
                        font: devanagariBold,
                        cache: cache,
                      ),
                      pw.SizedBox(height: 4),
                      _buildPdfLinedField(
                        labelKey: 'lbl_io_rank',
                        valKeyPrefix: 'val_ioRank',
                        fallbackValue: doc['ioRank']?.toString() ?? '',
                        linesCount: 1,
                        style: valueStyle,
                        font: devanagariBold,
                        cache: cache,
                      ),
                      pw.SizedBox(height: 4),
                      _buildPdfLinedField(
                        labelKey: 'lbl_io_buckle',
                        valKeyPrefix: 'val_ioBuckleNo',
                        fallbackValue: doc['ioBuckleNo']?.toString() ?? '',
                        linesCount: 1,
                        style: valueStyle,
                        font: devanagariBold,
                        cache: cache,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ],

          ];
        },
      ),
    );

  return pdf.save();
}

pw.Widget _buildPdfHeaderCell(String text, String key, pw.Font font, MarathiImageCache cache) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(3),
    child: cache.has(key)
        ? cache.img(key)
        : pw.Text(
            text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              font: font,
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
  );
}

List<pw.TableRow> _buildPdfVictimsRows(dynamic victimsData, pw.Font font, MarathiImageCache cache) {
  final rows = <pw.TableRow>[];
  if (victimsData is List) {
    for (int i = 0; i < victimsData.length; i++) {
      final item = victimsData[i];
      final Map<String, dynamic> row = item is Map ? Map<String, dynamic>.from(item) : {};
      rows.add(
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(3),
              child: pw.Center(
                child: pw.Text(
                  '${i + 1}',
                  style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.black),
                ),
              ),
            ),
            _buildPdfValueCell(row['fullName']?.toString() ?? '', 'victim_${i}_fullName', font, cache),
            _buildPdfValueCell(row['dob']?.toString() ?? '', 'victim_${i}_dob', font, cache),
            _buildPdfValueCell(row['sex']?.toString() ?? '', 'victim_${i}_sex', font, cache),
            _buildPdfValueCell(row['nationality']?.toString() ?? '', 'victim_${i}_nationality', font, cache),
            _buildPdfValueCell(row['religion']?.toString() ?? '', 'victim_${i}_religion', font, cache),
            _buildPdfValueCell(row['scSt']?.toString() ?? '', 'victim_${i}_scSt', font, cache),
            _buildPdfValueCell(row['occupation']?.toString() ?? '', 'victim_${i}_occupation', font, cache),
            _buildPdfValueCell(row['address']?.toString() ?? '', 'victim_${i}_address', font, cache),
            _buildPdfValueCell(row['injury']?.toString() ?? '', 'victim_${i}_injury', font, cache),
            _buildPdfValueCell(row['means']?.toString() ?? '', 'victim_${i}_means', font, cache),
          ],
        ),
      );
    }
  }
  if (rows.isEmpty) {
    rows.add(
      pw.TableRow(
        children: List.generate(11, (j) => _buildPdfValueCell(j == 0 ? '1' : '', '', font, cache)),
      ),
    );
  }
  return rows;
}

pw.Widget _buildPdfValueCell(String text, String key, pw.Font font, MarathiImageCache cache) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(3),
    child: (key.isNotEmpty && cache.has(key))
        ? cache.img(key)
        : pw.Text(
            text,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
              color: PdfColors.blue900,
            ),
          ),
  );
}

pw.Widget _buildPdfInlineField({
  required String label,
  required String marathiLabelKey,
  required String valKey,
  required String fallbackValue,
  required pw.TextStyle englishStyle,
  required pw.TextStyle marathiStyle,
  required pw.TextStyle valueStyle,
  required MarathiImageCache cache,
  bool showMarathiLabel = true,
}) {
  final hasValImg = cache.has(valKey);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        children: [
          pw.Text(label, style: englishStyle),
          pw.Expanded(
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.8)),
              ),
              alignment: pw.Alignment.bottomLeft,
              padding: const pw.EdgeInsets.only(left: 2),
              child: hasValImg 
                  ? cache.img(valKey)
                  : pw.Text(fallbackValue, style: valueStyle),
            ),
          ),
        ],
      ),
      if (showMarathiLabel && marathiLabelKey.isNotEmpty && cache.has(marathiLabelKey)) ...[
        pw.SizedBox(height: 2),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 4.0),
          child: cache.img(marathiLabelKey),
        ),
      ],
    ],
  );
}

pw.Widget _buildPdfWideField({
  required String label,
  required String marathiLabelKey,
  required String valKey,
  required String fallbackValue,
  required pw.TextStyle englishStyle,
  required pw.TextStyle marathiStyle,
  required pw.TextStyle valueStyle,
  required MarathiImageCache cache,
}) {
  final hasValImg = cache.has(valKey);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        children: [
          pw.Text(label, style: englishStyle),
          pw.Expanded(
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.8)),
              ),
              alignment: pw.Alignment.bottomLeft,
              padding: const pw.EdgeInsets.only(left: 2),
              child: hasValImg
                  ? cache.img(valKey)
                  : pw.Text(fallbackValue, style: valueStyle),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 2),
      if (marathiLabelKey.isNotEmpty && cache.has(marathiLabelKey))
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 4.0),
          child: cache.img(marathiLabelKey),
        ),
    ],
  );
}

pw.Widget _buildPdfLinedField({
  required String labelKey,
  required String valKeyPrefix,
  required String fallbackValue,
  required int linesCount,
  required pw.TextStyle style,
  required pw.Font font,
  required MarathiImageCache cache,
}) {
  final lines = _splitTextIntoLines(fallbackValue, 40);
  final total = lines.length < linesCount ? linesCount : lines.length;

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Render label parts (skip if empty)
      if (labelKey.isNotEmpty && cache.has(labelKey)) ...[
        cache.img(labelKey),
      ],
      pw.SizedBox(height: 3),
      // Render underlined value lines
      for (var i = 0; i < total; i++) ...[
        if (i > 0) pw.SizedBox(height: 4),
        pw.Container(
          width: double.infinity,
          height: 16,
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.8)),
          ),
          alignment: pw.Alignment.bottomLeft,
          padding: const pw.EdgeInsets.only(left: 4, bottom: 2),
          child: cache.has('${valKeyPrefix}_line_$i')
              ? cache.img('${valKeyPrefix}_line_$i')
              : pw.Text(i < lines.length ? lines[i] : '', style: style),
        ),
      ],
    ],
  );
}

pw.Widget _buildNumberedMethodPdfField({
  required String numberKey,
  required String valKey,
  required String fallbackValue,
  required pw.Font devanagariRegular,
  required pw.TextStyle valueStyle,
  required MarathiImageCache cache,
}) {
  return pw.Row(
    children: [
      if (cache.has(numberKey)) cache.img(numberKey),
      pw.SizedBox(width: 4),
      pw.Expanded(
        child: pw.Container(
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.8)),
          ),
          alignment: pw.Alignment.bottomLeft,
          padding: const pw.EdgeInsets.only(left: 2),
          child: cache.has(valKey)
              ? cache.img(valKey)
              : pw.Text(fallbackValue, style: valueStyle),
        ),
      ),
    ],
  );
}

List<pw.Widget> _buildPdfLinedBlock(
  String text,
  int minLines,
  int maxChars,
  pw.TextStyle style,
  String valKeyPrefix,
  MarathiImageCache cache,
) {
  final lines = _splitTextIntoLines(text.trim(), maxChars);
  final totalLines = lines.length < minLines ? minLines : lines.length;

  return List.generate(totalLines, (i) {
    final textLine = i < lines.length ? lines[i] : '';
    final lineKey = '${valKeyPrefix}_line_$i';
    return pw.Container(
      height: 18,
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.black,
            width: 0.8,
            style: pw.BorderStyle.dashed,
          ),
        ),
      ),
      alignment: pw.Alignment.bottomLeft,
      padding: const pw.EdgeInsets.only(left: 4, bottom: 2),
      child: cache.has(lineKey)
          ? cache.img(lineKey)
          : pw.Text(
              textLine,
              style: style,
            ),
    );
  });
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

Future<MarathiImageCache> _preRenderAllMarathi(Map<String, dynamic> doc) async {
  final cache = MarathiImageCache(pixelRatio: 3.0);

  // Setup styles using GoogleFonts for high-quality Devanagari text rendering
  final headerStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  
  final boldLabelStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  
  final marathiLabelStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 8.5,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  final valueStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.blue.shade900,
  );

  final tableHeaderStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 7.5,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  final victimValueStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 8,
    fontWeight: FontWeight.bold,
    color: Colors.blue.shade900,
  );

  // Ensure fonts are ready
  await GoogleFonts.pendingFonts();

  // Helper to add label
  Future<void> addLbl(String key, String text, TextStyle style, {double maxWidth = 500}) async {
    await cache.add(key, text, style, maxWidth: maxWidth);
  }

  // Helper to add value
  Future<void> addVal(String key, String? val, {double maxWidth = 500}) async {
    final text = val?.trim() ?? '';
    if (containsDevanagari(text)) {
      await cache.add(key, text, valueStyle, maxWidth: maxWidth);
    }
  }

  // Helper to add lined block lines
  Future<void> addLinedBlock(String prefix, String? text, int maxChars) async {
    final lines = _splitTextIntoLines(text?.trim() ?? '', maxChars);
    for (int i = 0; i < lines.length; i++) {
      final lineText = lines[i];
      if (containsDevanagari(lineText)) {
        await cache.add('${prefix}_line_$i', lineText, valueStyle);
      }
    }
  }

  // Pre-render static labels
  await addLbl('header_title', 'गुन्ह्यांंच्या तपशीलाचा नमुना/ घटनास्थल पंचनामा', headerStyle);
  
  // Section 1
  await addLbl('lbl_district', 'जिल्हा', marathiLabelStyle);
  await addLbl('lbl_ps', 'पोलीस स्टेशन', marathiLabelStyle);
  await addLbl('lbl_year', 'वर्ष', marathiLabelStyle);
  await addLbl('lbl_fir_no', 'पहिली खबर क्र.', marathiLabelStyle);
  await addLbl('lbl_date', 'तारीख', marathiLabelStyle);
  
  // Section 2
  await addLbl('lbl_act_sec', 'अधिनियम व कलमे', marathiLabelStyle);
  
  // Section 3
  await addLbl('lbl_shown_by', 'घटनेचे ठिकाण दाखविणाऱ्याचे :', boldLabelStyle);
  await addLbl('lbl_name', 'नांव', marathiLabelStyle);
  await addLbl('lbl_father_husband', 'पित्याचे/ पतीचे नांव', marathiLabelStyle);
  await addLbl('lbl_address', 'पत्ता :', marathiLabelStyle);
  
  // Section 4
  await addLbl('lbl_type_crime', 'गुन्ह्याचा प्रकार (गुन्ह्यांच्या सर्व पद्धतीसह)', marathiLabelStyle);
  await addLbl('lbl_major_head', 'प्रधान शीर्ष', marathiLabelStyle);
  await addLbl('lbl_minor_head', 'गौण शीर्ष', marathiLabelStyle);
  await addLbl('lbl_method', 'पद्धती', marathiLabelStyle);
  await addLbl('lbl_m1', '(१)', boldLabelStyle);
  await addLbl('lbl_m2', '(२)', boldLabelStyle);
  await addLbl('lbl_m3', '(३)', boldLabelStyle);
  await addLbl('lbl_conveyances', 'वापरलेली वाहने', marathiLabelStyle);
  await addLbl('lbl_character', 'केलेले वेषांतर/ केलेली बतावणी', marathiLabelStyle);
  await addLbl('lbl_lang', 'वापरलेली भाषा/ बोली भाषा', marathiLabelStyle);
  await addLbl('lbl_sf1', 'विशेष वैशिष्ट्ये - १', marathiLabelStyle);
  await addLbl('lbl_sf2', 'विशेष वैशिष्ट्ये - २', marathiLabelStyle);
  await addLbl('lbl_sf3', 'विशेष वैशिष्ट्ये - ३', marathiLabelStyle);
  await addLbl('lbl_place_type', 'घटनेच्या जागेचा प्रकार', marathiLabelStyle);
  await addLbl('lbl_prop_inv', 'अंतर्भूत मालमत्तेचे प्रकार', marathiLabelStyle);
  
  // Section 5
  await addLbl('lbl_victim_title', 'बळीचा तपशील ( आवश्यक असल्यास स्वतंत्र कागद जोडावा. )', boldLabelStyle);
  
  // Table headers
  await addLbl('th_1', "Sr.\nNo\n\nअ.\nक.\n\n(1)", tableHeaderStyle, maxWidth: 30);
  await addLbl('th_2', "Full Name\n\nसंपूर्ण नांव\n\n(2)", tableHeaderStyle, maxWidth: 100);
  await addLbl('th_3', "Date/Year\nof Birth\n\nजन्म तारीख/\nवर्ष\n\n(3)", tableHeaderStyle, maxWidth: 80);
  await addLbl('th_4', "Sex\n\nलिंग\n\n(*4)", tableHeaderStyle, maxWidth: 50);
  await addLbl('th_5', "Nationality\n\nराष्ट्रीयत्व\n\n(*5)", tableHeaderStyle, maxWidth: 60);
  await addLbl('th_6', "Religion\n\nधर्म\n\n(*6)", tableHeaderStyle, maxWidth: 60);
  await addLbl('th_7', "Whether\nSC/ ST\n\nजाती\n/जमाती\n\n(*7)", tableHeaderStyle, maxWidth: 60);
  await addLbl('th_8', "Ocupetion\n\nव्यवसाय\n\n(*8)", tableHeaderStyle, maxWidth: 60);
  await addLbl('th_9', "Address\n\nपत्ता\n\n(*9)", tableHeaderStyle, maxWidth: 100);
  await addLbl('th_10', "Injury:\ngrievous/\nSimple\n\nदुखापत\nगंभीर/साधी\n\n(10)", tableHeaderStyle, maxWidth: 80);
  await addLbl('th_11', "Means\n\nसाधने/\nहत्यारे\n\n(11)", tableHeaderStyle, maxWidth: 80);
  
  // Section 6
  await addLbl('lbl_motive', 'गुन्ह्याचा हेतू :', boldLabelStyle);
  
  // Section 7
  await addLbl('lbl_prop_det', 'चोरीचा / अंतर्भूत मालमत्तेचा तपशील (योग्य नमुना वापरावा व सोबत जोडावा) :', boldLabelStyle);
  
  // Section 8
  await addLbl('lbl_place_desc', '(घटनेच्या जागेचे वर्णन) :', boldLabelStyle);
  await addLbl('lbl_place_desc_cont', '(घटनेच्या जागेचे वर्णन) :', boldLabelStyle);
  
  // Section 9
  await addLbl('lbl_map', 'Map: नकाशा', boldLabelStyle);
  await addLbl('lbl_no_map', 'No Map Uploaded\n(नकाशा जोडला नाही)', boldLabelStyle);
  
  // Section 10
  await addLbl('lbl_phys_ev', 'तपासकामी प्रत्यक्ष पुरावा म्हणून गुन्ह्यांच्या जागेवरून मिळविलेल्या / जप्त केलेल्या मालमत्तेचे वर्णन :', boldLabelStyle);
  
  // Page 4 Signatures labels
  await addLbl('lbl_dt_panchnama', "Date and Time of panchnama\nघटनास्थळ पंचनाम्याची दिनांक", boldLabelStyle);
  await addLbl('lbl_panchas_name', "Name of panchas: / पंचाची नांवे :", boldLabelStyle);
  await addLbl('lbl_p1_addr', "Full Address\nपत्ता", boldLabelStyle);
  await addLbl('lbl_p2_addr', "Full Address\nपत्ता", boldLabelStyle);
  await addLbl('lbl_date_form', "Date\nदिनांक", boldLabelStyle);
  await addLbl('lbl_time_form', "Time\nवेळ", boldLabelStyle);
  await addLbl('lbl_panchas_sig', "Signature of Panchas: / पंचाच्या सह्या :", boldLabelStyle);
  await addLbl('lbl_io_sig', "Name and Signature of Investigation Officer", boldLabelStyle);
  await addLbl('lbl_io_sig_mar', FormIoTerminology.amaldarSignatureHeader, marathiLabelStyle);
  await addLbl('lbl_io_name', "Name\n${FormIoTerminology.name}", boldLabelStyle);
  await addLbl('lbl_io_rank', "Rank\n${FormIoTerminology.rank}", boldLabelStyle);
  await addLbl('lbl_io_buckle', "B.No. if any\nबक्कल नंबर", boldLabelStyle);

  // Pre-render dynamic user values
  await addVal('val_district', doc['district']?.toString());
  await addVal('val_ps', doc['ps']?.toString());
  await addVal('val_year', doc['year']?.toString());
  await addVal('val_firNo', doc['firNo']?.toString());
  await addVal('val_firYearSuffix', doc['firYearSuffix']?.toString());
  await addVal('val_dateDay', doc['dateDay']?.toString());
  await addVal('val_dateMonth', doc['dateMonth']?.toString());
  await addVal('val_dateYear', doc['dateYear']?.toString());
  await addVal('val_actSection', doc['actSection']?.toString());
  
  await addVal('val_shownByName', doc['shownByName']?.toString());
  await addVal('val_shownByFatherHusband', doc['shownByFatherHusband']?.toString());
  await addVal('val_shownByAddress', doc['shownByAddress']?.toString());
  
  await addVal('val_typeOfCrime', doc['typeOfCrime']?.toString());
  await addVal('val_majorHead', doc['majorHead']?.toString());
  await addVal('val_minorHead', doc['minorHead']?.toString());
  await addVal('val_method', doc['method']?.toString());
  await addVal('val_method1', doc['method1']?.toString());
  await addVal('val_method2', doc['method2']?.toString());
  await addVal('val_method3', doc['method3']?.toString());
  
  await addVal('val_conveyances', doc['conveyances']?.toString());
  await addVal('val_characterAssumed', doc['characterAssumed']?.toString());
  await addVal('val_languageSlang', doc['languageSlang']?.toString());
  await addVal('val_specialFeature1', doc['specialFeature1']?.toString());
  await addVal('val_specialFeature2', doc['specialFeature2']?.toString());
  await addVal('val_specialFeature3', doc['specialFeature3']?.toString());
  await addVal('val_placeOfOccurrenceType', doc['placeOfOccurrenceType']?.toString());
  await addVal('val_propertyInvolved', doc['propertyInvolved']?.toString());
  await addVal('val_propertyType1', doc['propertyType1']?.toString());
  await addVal('val_propertyType2', doc['propertyType2']?.toString());
  await addVal('val_propertyType3', doc['propertyType3']?.toString());
  await addVal('val_propertyType4', doc['propertyType4']?.toString());
  await addVal('val_motiveOfCrime', doc['motiveOfCrime']?.toString());

  // Lined blocks
  await addLinedBlock('val_propertyDetails', doc['propertyDetails']?.toString(), 85);
  await addLinedBlock('val_placeDescription', doc['placeDescription']?.toString(), 85);
  await addLinedBlock('val_placeDescriptionCont', doc['placeDescriptionCont']?.toString(), 85);
  await addLinedBlock('val_physicalEvidence', doc['physicalEvidence']?.toString(), 85);

  // Victims table rows
  final victims = doc['victims'];
  if (victims is List) {
    for (int i = 0; i < victims.length; i++) {
      final item = victims[i];
      final Map<String, dynamic> row = item is Map ? Map<String, dynamic>.from(item) : {};
      final fields = ['fullName', 'dob', 'sex', 'nationality', 'religion', 'scSt', 'occupation', 'address', 'injury', 'means'];
      for (final field in fields) {
        final val = row[field]?.toString() ?? '';
        if (containsDevanagari(val)) {
          await cache.add('victim_${i}_$field', val, victimValueStyle, maxWidth: 100);
        }
      }
    }
  }

  // Signature section values
  await addVal('val_panchnamaDate', doc['panchnamaDate']?.toString());
  await addVal('val_pancha1Name', doc['pancha1Name']?.toString());
  await addVal('val_pancha1Address', doc['pancha1Address']?.toString());
  await addVal('val_pancha2Name', doc['pancha2Name']?.toString());
  await addVal('val_pancha2Address', doc['pancha2Address']?.toString());
  await addVal('val_panchnamaFormDate', doc['panchnamaFormDate']?.toString());
  await addVal('val_panchnamaTime', doc['panchnamaTime']?.toString());
  await addVal('val_pancha1Sig', doc['pancha1Sig']?.toString());
  await addVal('val_pancha2Sig', doc['pancha2Sig']?.toString());
  await addVal('val_ioName', doc['ioName']?.toString());
  await addVal('val_ioRank', doc['ioRank']?.toString());
  await addVal('val_ioBuckleNo', doc['ioBuckleNo']?.toString());

  return cache;
}
