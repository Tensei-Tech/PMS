import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'marathi_text_renderer.dart';
import 'form_io_terminology.dart';
import '../widgets/form_section_utils.dart';

Future<void> previewPropertySeizurePdf(
  BuildContext context,
  Map<String, dynamic> doc,
) async {
  final bytes = await generatePropertySeizurePdf(doc);
  if (!context.mounted) return;
  final fileName = 'Property_Seizure_Form_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

Future<Uint8List> generatePropertySeizurePdf(Map<String, dynamic> doc) async {
  final pdf = pw.Document();

  // Load fonts
  final loraRegular = await PdfGoogleFonts.loraRegular();
  final loraBold = await PdfGoogleFonts.loraBold();
  final devanagariRegular = await PdfGoogleFonts.notoSansDevanagariRegular();

  // Pre-render Marathi text blocks to cache as images to resolve Indic shaping issues
  final cache = await _preRenderAllMarathi(doc);

  const knownSectionIds = {'Seizure Memo Body', 'Seizure Memo Signatures'};
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

  final pw.TextStyle valueStyle = pw.TextStyle(
    font: devanagariRegular,
    fontSize: 10,
    color: PdfColors.blue900,
  );

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
          if (showsSection('Seizure Memo Body')) ...[
          // --- HEADER ---
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'PROPERTY SEACH & SEIZURE FORM',
                  style: englishBold.copyWith(fontSize: 15),
                ),
                pw.SizedBox(height: 4),
                if (cache.has('header_title'))
                  cache.img('header_title'),
                pw.SizedBox(height: 4),
                pw.Text(
                  '(Search/ Production/ Recovery u/s. 185 B.N.S.S)',
                  style: englishStyle.copyWith(fontSize: 9),
                ),
                pw.SizedBox(height: 2),
                if (cache.has('header_subtitle'))
                  cache.img('header_subtitle'),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.black, thickness: 0.8),
          pw.SizedBox(height: 12),

          // --- SECTION 1 ---
          pw.Wrap(
            spacing: 4,
            runSpacing: 6,
            crossAxisAlignment: pw.WrapCrossAlignment.end,
            children: [
              _mLbl(cache, 'lbl_s1_district'),
              _buildPdfUnderlineField(
                valKey: 'val_district',
                fallbackValue: doc['district']?.toString() ?? '',
                width: 50,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_ps'),
              _buildPdfUnderlineField(
                valKey: 'val_ps',
                fallbackValue: doc['ps'] ?? '',
                width: 70,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_year'),
              _buildPdfUnderlineField(
                valKey: 'val_year',
                fallbackValue: doc['year'] ?? '',
                width: 35,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_fir'),
              _buildPdfUnderlineField(
                valKey: 'val_firNo',
                fallbackValue: doc['firNo'] ?? '',
                width: 30,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.Text('/', style: englishStyle),
              _buildPdfUnderlineField(
                valKey: 'val_firYearSuffix',
                fallbackValue: doc['firYearSuffix'] ?? '',
                width: 30,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_di'),
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
              _mLbl(cache, 'lbl_slash20'),
              _buildPdfUnderlineField(
                valKey: 'val_dateYear',
                fallbackValue: doc['dateYear'] ?? '',
                width: 18,
                valueStyle: valueStyle,
                cache: cache,
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          // --- SECTION 2 ---
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _mLbl(cache, 'lbl_s2'),
              pw.Expanded(
                child: _buildPdfUnderlineField(
                  valKey: 'val_actSection',
                  fallbackValue: doc['actSection'] ?? '',
                  valueStyle: valueStyle,
                  cache: cache,
                  expanded: true,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          // --- SECTION 3 ---
          if (cache.has('lbl_s3'))
            cache.img('lbl_s3')
          else
            pw.SizedBox(),
          pw.SizedBox(height: 12),

          // --- SECTION 4 ---
          pw.Wrap(
            spacing: 4,
            runSpacing: 6,
            crossAxisAlignment: pw.WrapCrossAlignment.end,
            children: [
              _mLbl(cache, 'lbl_s4_head'),
              _buildPdfUnderlineField(
                valKey: 'val_seizureDateDay',
                fallbackValue: doc['seizureDateDay'] ?? '',
                width: 18,
                valueStyle: valueStyle,
                cache: cache,
              ),
              pw.Text('/', style: englishStyle),
              _buildPdfUnderlineField(
                valKey: 'val_seizureDateMonth',
                fallbackValue: doc['seizureDateMonth'] ?? '',
                width: 18,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_slash20'),
              _buildPdfUnderlineField(
                valKey: 'val_seizureDateYear',
                fallbackValue: doc['seizureDateYear'] ?? '',
                width: 18,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_s4_time'),
              _buildPdfUnderlineField(
                valKey: 'val_seizureTime',
                fallbackValue: doc['seizureTime'] ?? '',
                width: 50,
                valueStyle: valueStyle,
                cache: cache,
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _mLbl(cache, 'lbl_s4_place'),
              pw.Expanded(
                child: _buildPdfUnderlineField(
                  valKey: 'val_seizurePlace',
                  fallbackValue: doc['seizurePlace'] ?? '',
                  valueStyle: valueStyle,
                  cache: cache,
                  expanded: true,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _mLbl(cache, 'lbl_s4_desc'),
              pw.Expanded(
                child: _buildPdfUnderlineField(
                  valKey: 'val_seizurePlaceDesc',
                  fallbackValue: doc['seizurePlaceDesc'] ?? '',
                  valueStyle: valueStyle,
                  cache: cache,
                  expanded: true,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          // --- SECTION 5 ---
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _mLbl(cache, 'lbl_s5'),
              pw.Expanded(
                child: _buildPdfUnderlineField(
                  valKey: 'val_seizedFrom',
                  fallbackValue: doc['seizedFrom'] ?? '',
                  valueStyle: valueStyle,
                  cache: cache,
                  expanded: true,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _mLbl(cache, 'lbl_prof_receiver'),
              _buildPdfUnderlineField(
                valKey: 'val_isProfessionalReceiver',
                fallbackValue: doc['isProfessionalReceiver'] ?? 'नाही',
                width: 40,
                valueStyle: valueStyle,
                cache: cache,
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: pw.WrapCrossAlignment.end,
            children: [
              _mLbl(cache, 'lbl_nav'),
              _buildPdfUnderlineField(
                valKey: 'val_personName',
                fallbackValue: doc['personName'] ?? '',
                width: 80,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_father'),
              _buildPdfUnderlineField(
                valKey: 'val_personFather',
                fallbackValue: doc['personFather'] ?? '',
                width: 80,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_gender'),
              _buildPdfUnderlineField(
                valKey: 'val_personSex',
                fallbackValue: doc['personSex'] ?? '',
                width: 40,
                valueStyle: valueStyle,
                cache: cache,
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: pw.WrapCrossAlignment.end,
            children: [
              _mLbl(cache, 'lbl_age'),
              _buildPdfUnderlineField(
                valKey: 'val_personAge',
                fallbackValue: doc['personAge'] ?? '',
                width: 30,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_occupation'),
              _buildPdfUnderlineField(
                valKey: 'val_personOccupation',
                fallbackValue: doc['personOccupation'] ?? '',
                width: 60,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_address'),
              _buildPdfUnderlineField(
                valKey: 'val_personAddress',
                fallbackValue: doc['personAddress'] ?? '',
                width: 120,
                valueStyle: valueStyle,
                cache: cache,
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          // --- SECTION 6 ---
          _mLbl(cache, 'lbl_s6'),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: pw.WrapCrossAlignment.end,
            children: [
              _mLbl(cache, 'lbl_witness_i'),
              _buildPdfUnderlineField(
                valKey: 'val_w1Name',
                fallbackValue: doc['w1Name'] ?? '',
                width: 80,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_father'),
              _buildPdfUnderlineField(
                valKey: 'val_w1Father',
                fallbackValue: doc['w1Father'] ?? '',
                width: 80,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_gender'),
              _buildPdfUnderlineField(
                valKey: 'val_w1Sex',
                fallbackValue: doc['w1Sex'] ?? '',
                width: 40,
                valueStyle: valueStyle,
                cache: cache,
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: pw.WrapCrossAlignment.end,
            children: [
              _mLbl(cache, 'lbl_age'),
              _buildPdfUnderlineField(
                valKey: 'val_w1Age',
                fallbackValue: doc['w1Age'] ?? '',
                width: 30,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_occupation'),
              _buildPdfUnderlineField(
                valKey: 'val_w1Occupation',
                fallbackValue: doc['w1Occupation'] ?? '',
                width: 60,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_address'),
              _buildPdfUnderlineField(
                valKey: 'val_w1Address',
                fallbackValue: doc['w1Address'] ?? '',
                width: 120,
                valueStyle: valueStyle,
                cache: cache,
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          // --- WITNESS (ii) ---
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: pw.WrapCrossAlignment.end,
            children: [
              _mLbl(cache, 'lbl_witness_ii'),
              _buildPdfUnderlineField(
                valKey: 'val_w2Name',
                fallbackValue: doc['w2Name'] ?? '',
                width: 80,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_father'),
              _buildPdfUnderlineField(
                valKey: 'val_w2Father',
                fallbackValue: doc['w2Father'] ?? '',
                width: 80,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_gender'),
              _buildPdfUnderlineField(
                valKey: 'val_w2Sex',
                fallbackValue: doc['w2Sex'] ?? '',
                width: 40,
                valueStyle: valueStyle,
                cache: cache,
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: pw.WrapCrossAlignment.end,
            children: [
              _mLbl(cache, 'lbl_age'),
              _buildPdfUnderlineField(
                valKey: 'val_w2Age',
                fallbackValue: doc['w2Age'] ?? '',
                width: 30,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_occupation'),
              _buildPdfUnderlineField(
                valKey: 'val_w2Occupation',
                fallbackValue: doc['w2Occupation'] ?? '',
                width: 60,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_address'),
              _buildPdfUnderlineField(
                valKey: 'val_w2Address',
                fallbackValue: doc['w2Address'] ?? '',
                width: 120,
                valueStyle: valueStyle,
                cache: cache,
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          _buildPdfUnderlineField(
            valKey: 'val_w2AddressLine2',
            fallbackValue: doc['w2AddressLine2'] ?? '',
            valueStyle: valueStyle,
            cache: cache,
            expanded: true,
          ),
          pw.SizedBox(height: 12),

          // --- SECTION 7 ---
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _mLbl(cache, 'lbl_s7'),
              pw.Expanded(
                child: _buildPdfUnderlineField(
                  valKey: 'val_perishableDisposal',
                  fallbackValue: doc['perishableDisposal'] ?? '',
                  valueStyle: valueStyle,
                  cache: cache,
                  expanded: true,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),

          // --- SECTION 8 ---
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _mLbl(cache, 'lbl_s8'),
              pw.Expanded(
                child: _buildPdfUnderlineField(
                  valKey: 'val_valuableKeeping',
                  fallbackValue: doc['valuableKeeping'] ?? '',
                  valueStyle: valueStyle,
                  cache: cache,
                  expanded: true,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),

          // --- SECTION 9 ---
          pw.Row(
            children: [
              _mLbl(cache, 'lbl_s9'),
              _buildPdfUnderlineField(
                valKey: 'val_identificationRequired',
                fallbackValue: doc['identificationRequired'] ?? 'नाही',
                width: 40,
                valueStyle: valueStyle,
                cache: cache,
              ),
              _mLbl(cache, 'lbl_s9_hoy'),
            ],
          ),
          pw.SizedBox(height: 10),

          // --- SECTION 10 ---
          if (cache.has('lbl_s10'))
            cache.img('lbl_s10')
          else
            pw.SizedBox(),
          pw.SizedBox(height: 10),

          // --- PROPERTIES TABLE (section 10 attachment) ---

          pw.Table(
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
            columnWidths: const {
              0: pw.FixedColumnWidth(40),  // Sr No
              1: pw.FlexColumnWidth(6.0), // Description
              2: pw.FlexColumnWidth(3.0), // Value
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _buildPdfHeaderCell('th_sr', cache),
                  _buildPdfHeaderCell('th_desc', cache),
                  _buildPdfHeaderCell('th_val', cache),
                ],
              ),
              ...List.generate(
                (doc['properties'] as List? ?? []).length,
                (index) {
                  final row = (doc['properties'] as List)[index];
                  final descKey = 'prop_${index}_desc';
                  final valKey = 'prop_${index}_val';
                  return pw.TableRow(
                    children: [
                      pw.Center(child: pw.Text('${index + 1}', style: englishStyle)),
                      _buildPdfValueCell(
                        row['description']?.toString() ?? '',
                        descKey,
                        cache,
                        valueStyle,
                      ),
                      _buildPdfValueCell(
                        row['value']?.toString() ?? '',
                        valKey,
                        cache,
                        valueStyle,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          // --- SECTION 11 ---
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _mLbl(cache, 'lbl_s11'),
              pw.Expanded(
                child: _buildPdfUnderlineField(
                  valKey: 'val_circumstances',
                  fallbackValue: doc['circumstances'] ?? '',
                  valueStyle: valueStyle,
                  cache: cache,
                  expanded: true,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          _buildPdfUnderlineField(
            valKey: 'val_circumstancesLine2',
            fallbackValue: doc['circumstancesLine2'] ?? '',
            valueStyle: valueStyle,
            cache: cache,
            expanded: true,
          ),
          pw.SizedBox(height: 6),
          _buildPdfUnderlineField(
            valKey: 'val_circumstancesLine3',
            fallbackValue: doc['circumstancesLine3'] ?? '',
            valueStyle: valueStyle,
            cache: cache,
            expanded: true,
          ),
          pw.SizedBox(height: 10),

          ],
          if (showsSection('Seizure Memo Signatures')) ...[
          // --- SECTION 12 ---
          _mLbl(cache, 'lbl_s12'),
          pw.SizedBox(height: 10),

          // --- SECTION 13 ---
          _mLbl(cache, 'lbl_s13'),
          pw.SizedBox(height: 10),

          // --- SEAL PROPERTY TABLE ---
          pw.Table(
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
            columnWidths: const {
              0: pw.FixedColumnWidth(40),
              1: pw.FlexColumnWidth(4.0),
              2: pw.FlexColumnWidth(5.0),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _buildPdfHeaderCell('th_seal_sr', cache),
                  _buildPdfHeaderCell('th_seal_prop', cache),
                  _buildPdfHeaderCell('th_seal_sig', cache),
                ],
              ),
              ...List.generate(
                (doc['sealProperties'] as List? ?? []).isNotEmpty
                    ? (doc['sealProperties'] as List).length
                    : 5,
                (index) {
                  final sealList = doc['sealProperties'] as List?;
                  final Map<String, dynamic> row = (sealList != null && index < sealList.length && sealList[index] is Map)
                      ? Map<String, dynamic>.from(sealList[index] as Map)
                      : {};
                  final propKey = 'seal_${index}_property';
                  final sigKey = 'seal_${index}_signature';
                  return pw.TableRow(
                    children: [
                      pw.Center(child: pw.Text('${index + 1}', style: englishStyle)),
                      _buildPdfValueCell(
                        row['property']?.toString() ?? '',
                        propKey,
                        cache,
                        valueStyle,
                      ),
                      _buildPdfValueCell(
                        row['signature']?.toString() ?? '',
                        sigKey,
                        cache,
                        valueStyle,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: _mLbl(cache, 'lbl_seal_footer'),
          ),
          pw.SizedBox(height: 14),

          // --- PANCHA & IO SIGNATURE BLOCK ---
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (cache.has('lbl_panchas_name'))
                      cache.img('lbl_panchas_name'),
                    pw.SizedBox(height: 4),
                    pw.Text('(1)', style: englishBold.copyWith(fontSize: 9)),
                    pw.SizedBox(height: 2),
                    _buildPdfLinedField(
                      labelKey: '',
                      valKeyPrefix: 'val_pancha1Name',
                      fallbackValue: doc['pancha1Name']?.toString() ?? '',
                      linesCount: 1,
                      style: valueStyle,
                      cache: cache,
                    ),
                    pw.SizedBox(height: 4),
                    _buildPdfLinedField(
                      labelKey: 'lbl_p1_addr',
                      valKeyPrefix: 'val_pancha1Address',
                      fallbackValue: _joinNonEmpty([
                        doc['pancha1Addr1'],
                        doc['pancha1Addr2'],
                        doc['pancha1Addr3'],
                      ]),
                      linesCount: 3,
                      style: valueStyle,
                      cache: cache,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('(2)', style: englishBold.copyWith(fontSize: 9)),
                    pw.SizedBox(height: 2),
                    _buildPdfLinedField(
                      labelKey: '',
                      valKeyPrefix: 'val_pancha2Name',
                      fallbackValue: doc['pancha2Name']?.toString() ?? '',
                      linesCount: 1,
                      style: valueStyle,
                      cache: cache,
                    ),
                    pw.SizedBox(height: 4),
                    _buildPdfLinedField(
                      labelKey: 'lbl_p2_addr',
                      valKeyPrefix: 'val_pancha2Address',
                      fallbackValue: _joinNonEmpty([
                        doc['pancha2Addr1'],
                        doc['pancha2Addr2'],
                        doc['pancha2Addr3'],
                      ]),
                      linesCount: 3,
                      style: valueStyle,
                      cache: cache,
                    ),
                    pw.SizedBox(height: 6),
                    _buildPdfLinedField(
                      labelKey: 'lbl_date_form',
                      valKeyPrefix: 'val_panchaDate',
                      fallbackValue: _formatSlashDate(
                        doc['panchaDateDay'],
                        doc['panchaDateMonth'],
                        doc['panchaDateYear'],
                      ),
                      linesCount: 1,
                      style: valueStyle,
                      cache: cache,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 30),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (cache.has('lbl_panchas_sig'))
                      cache.img('lbl_panchas_sig'),
                    pw.SizedBox(height: 4),
                    pw.Text('1)', style: englishBold.copyWith(fontSize: 9)),
                    pw.SizedBox(height: 2),
                    _buildPdfLinedField(
                      labelKey: '',
                      valKeyPrefix: 'val_pancha1Sig',
                      fallbackValue: doc['pancha1Sig']?.toString() ?? '',
                      linesCount: 1,
                      style: valueStyle,
                      cache: cache,
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('2)', style: englishBold.copyWith(fontSize: 9)),
                    pw.SizedBox(height: 2),
                    _buildPdfLinedField(
                      labelKey: '',
                      valKeyPrefix: 'val_pancha2Sig',
                      fallbackValue: doc['pancha2Sig']?.toString() ?? '',
                      linesCount: 1,
                      style: valueStyle,
                      cache: cache,
                    ),
                    pw.SizedBox(height: 6),
                    if (cache.has('lbl_io_sig'))
                      cache.img('lbl_io_sig'),
                    if (cache.has('lbl_io_sig_mar'))
                      cache.img('lbl_io_sig_mar'),
                    pw.SizedBox(height: 4),
                    _buildPdfLinedField(
                      labelKey: 'lbl_io_name',
                      valKeyPrefix: 'val_ioName',
                      fallbackValue: doc['ioName']?.toString() ?? '',
                      linesCount: 1,
                      style: valueStyle,
                      cache: cache,
                    ),
                    pw.SizedBox(height: 4),
                    _buildPdfLinedField(
                      labelKey: 'lbl_io_rank',
                      valKeyPrefix: 'val_ioRank',
                      fallbackValue: doc['ioRank']?.toString() ?? '',
                      linesCount: 1,
                      style: valueStyle,
                      cache: cache,
                    ),
                    pw.SizedBox(height: 4),
                    _buildPdfLinedField(
                      labelKey: 'lbl_io_buckle',
                      valKeyPrefix: 'val_ioBuckleNo',
                      fallbackValue: doc['ioBuckleNo']?.toString() ?? '',
                      linesCount: 1,
                      style: valueStyle,
                      cache: cache,
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('M.R.W', style: englishBold.copyWith(fontSize: 9)),
          ),
          ],
        ];
      },
    ),
  );

  return pdf.save();
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
    width: expanded ? null : width,
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.8)),
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

pw.Widget _mLbl(MarathiImageCache cache, String key) {
  if (cache.has(key)) return cache.img(key);
  return pw.SizedBox();
}

pw.Widget _buildPdfHeaderCell(String key, MarathiImageCache cache) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(3),
    child: pw.Center(
      child: cache.has(key) ? cache.img(key) : pw.SizedBox(),
    ),
  );
}

pw.Widget _buildPdfValueCell(
  String text,
  String key,
  MarathiImageCache cache,
  pw.TextStyle valueStyle,
) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    child: pw.Center(
      child: (key.isNotEmpty && cache.has(key))
          ? cache.img(key)
          : pw.Text(text, style: valueStyle),
    ),
  );
}

pw.Widget _buildPdfLinedField({
  required String labelKey,
  required String valKeyPrefix,
  required String fallbackValue,
  required int linesCount,
  required pw.TextStyle style,
  required MarathiImageCache cache,
}) {
  final lines = _splitTextIntoLines(fallbackValue, 40);
  final total = lines.length < linesCount ? linesCount : lines.length;

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (labelKey.isNotEmpty && cache.has(labelKey)) cache.img(labelKey),
      if (labelKey.isNotEmpty && cache.has(labelKey)) pw.SizedBox(height: 3),
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
          child: _buildPdfLinedFieldValue(
            valKeyPrefix: valKeyPrefix,
            lineIndex: i,
            fallbackText: i < lines.length ? lines[i] : '',
            style: style,
            cache: cache,
          ),
        ),
      ],
    ],
  );
}

pw.Widget _buildPdfLinedFieldValue({
  required String valKeyPrefix,
  required int lineIndex,
  required String fallbackText,
  required pw.TextStyle style,
  required MarathiImageCache cache,
}) {
  final lineKey = '${valKeyPrefix}_line_$lineIndex';
  if (cache.has(lineKey)) return cache.img(lineKey);
  if (lineIndex == 0 && cache.has(valKeyPrefix)) return cache.img(valKeyPrefix);
  return pw.Text(fallbackText, style: style);
}

String _joinNonEmpty(List<dynamic> parts) {
  return parts
      .map((part) => part?.toString().trim() ?? '')
      .where((part) => part.isNotEmpty)
      .join('\n');
}

String _formatSlashDate(dynamic day, dynamic month, dynamic year) {
  final parts = [day, month, year]
      .map((part) => part?.toString().trim() ?? '')
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  return parts.join(' / ');
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
  final cache = MarathiImageCache();

  final headerStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 11,
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
    fontSize: 8,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // Ensure fonts are ready
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

  Future<void> addLinedBlock(String prefix, String? text, int maxChars) async {
    final lines = _splitTextIntoLines(text?.trim() ?? '', maxChars);
    for (int i = 0; i < lines.length; i++) {
      final lineText = lines[i];
      if (containsDevanagari(lineText)) {
        await cache.add('${prefix}_line_$i', lineText, valueStyle);
      }
    }
  }

  // Pre-render static labels (all Marathi text as images for accurate shaping)
  await addLbl('header_title', 'मालमत्ता शोध व जप्तीचा नमुना', headerStyle);
  await addLbl('header_subtitle', '(कलम १८५ भारतीय नागरीक सुरक्षा संहिता २०२३ अन्वये झडती/हजर करणे/परत मिळविणे)', marathiLabelStyle, maxWidth: 480);

  await addLbl('lbl_s1_district', '१) *जिल्हा:', marathiLabelStyle);
  await addLbl('lbl_ps', '*पोलीस ठाणे:', marathiLabelStyle);
  await addLbl('lbl_year', 'वर्षे:', marathiLabelStyle);
  await addLbl('lbl_fir', '*पहिली खबर क/कार्यवाही', marathiLabelStyle);
  await addLbl('lbl_di', '*दि', marathiLabelStyle);
  await addLbl('lbl_slash20', '/२०', marathiLabelStyle);
  await addLbl('lbl_s2', '२) अधिनियम व कलमे : ', marathiLabelStyle);
  await addLbl('lbl_s3', '३) *जप्त केलेले/मिळालेल्या मालमत्तेचे स्वरूप : चोरीला गेलेली/बेवारशी/बेकायदेशीर ताबा/अंतर्भूत/मृत्यू पत्राशिवाय.', boldLabelStyle, maxWidth: 480);
  await addLbl('lbl_s4_head', '४) जप्त केलेली मालमत्ता : (अ) तारीख :', marathiLabelStyle);
  await addLbl('lbl_s4_time', '(ब) वेळ :', marathiLabelStyle);
  await addLbl('lbl_s4_place', '(क) जेथून जप्त केली/परत मिळवली ती जागा : ', marathiLabelStyle, maxWidth: 300);
  await addLbl('lbl_s4_desc', '(ड) जप्तीच्या/परत मिळवल्याची जागेचे वर्णन: ', marathiLabelStyle, maxWidth: 300);
  await addLbl('lbl_s5', '५) कोणाकडून जप्त केली : ', marathiLabelStyle);
  await addLbl('lbl_prof_receiver', '*चोरीचा माल घेणारा धंदेवाईक : होय/नाही ', marathiLabelStyle, maxWidth: 300);
  await addLbl('lbl_nav', 'नाव :', marathiLabelStyle);
  await addLbl('lbl_father', 'पित्याचे/पतीचे नाव :', marathiLabelStyle);
  await addLbl('lbl_gender', 'लिंग :', marathiLabelStyle);
  await addLbl('lbl_age', 'वय :', marathiLabelStyle);
  await addLbl('lbl_occupation', 'व्यवसाय :', marathiLabelStyle);
  await addLbl('lbl_address', 'पत्ता :', marathiLabelStyle);
  await addLbl('lbl_s6', '६) साक्षीदार', boldLabelStyle);
  await addLbl('lbl_witness_i', '(i) नाव :', marathiLabelStyle);
  await addLbl('lbl_witness_ii', '(ii) नाव :', marathiLabelStyle);
  await addLbl('lbl_s7', '७) नाशवंत मालमत्तेच्या विल्हेवाटीसाठी केलेली शिफारस/केलेली कार्यवाही : ', marathiLabelStyle, maxWidth: 480);
  await addLbl('lbl_s8', '८) मौल्यवान मालमत्ता ठेवण्यासाठी केलेली शिफारस/केलेली कार्यवाही : ', marathiLabelStyle, maxWidth: 480);
  await addLbl('lbl_s9', '९) ओळख पटवावी लागली काय : ', marathiLabelStyle);
  await addLbl('lbl_s9_hoy', ' होय/नाही', marathiLabelStyle);
  await addLbl('lbl_s10', '१०) जप्त केलेल्या/परत मिळालेल्या मालाचे वर्णन (योग्य नमुन्यात माहिती भरा व जोडा )', boldLabelStyle, maxWidth: 480);
  await addLbl('lbl_s11', '११) जप्तीची परिस्थिती/कारणे : ', boldLabelStyle);
  await addLbl('lbl_s12', '१२) वर नमूद करण्यात आलेली मालमत्ता पूर्ववत साक्षीदारांच्या समक्ष कायद्यातील तरतुदी नुसार जप्त करण्यात आली. आणि जप्तीच्या ज्ञापनाची ज्याच्याकडून मालमत्ता जप्त करण्यात आली. त्या इसमास/जागेत राहणाऱ्यास देण्यात आली.', marathiLabelStyle, maxWidth: 480);
  await addLbl('lbl_s13', '१३) खालील मालमत्ता अविष्ठित आणि/किंवा मोहोरबंद करण्यात आली आणि त्यावर किंवा मालमत्तेवर पूर्ववत साक्षीदारांच्या सहया घेण्यात आल्या आहेत.', marathiLabelStyle, maxWidth: 480);
  await addLbl('th_seal_sr', 'अ क्र\n(१)', tableHeaderStyle, maxWidth: 40);
  await addLbl('th_seal_prop', 'मालमत्ता\n(२)', tableHeaderStyle, maxWidth: 120);
  await addLbl('th_seal_sig', 'पुडक्यावर किंवा मालमत्तेवर सही घेण्यात आली.\n(३)', tableHeaderStyle, maxWidth: 200);
  await addLbl('lbl_seal_footer', 'मोहोरेचा नमुना खाली देण्यात आली आहे.', marathiLabelStyle, maxWidth: 300);
  await addLbl('th_sr', "Sr. No.\nअ. क.", tableHeaderStyle, maxWidth: 40);
  await addLbl('th_desc', "Property Description\nमालमत्तेचे वर्णन", tableHeaderStyle, maxWidth: 200);
  await addLbl('th_val', "Estimated Value (Rs)\nअंदाजे किंमत (रु.)", tableHeaderStyle, maxWidth: 100);

  // Pancha & IO signature labels (bilingual images like crime detail form)
  await addLbl('lbl_panchas_name', "Name of panchas:\nपंचाची नांवे :", boldLabelStyle);
  await addLbl('lbl_p1_addr', "Full Address:\nपत्ता", boldLabelStyle);
  await addLbl('lbl_p2_addr', "Full Address:\nपत्ता", boldLabelStyle);
  await addLbl('lbl_date_form', "Date:\nदिनांक", boldLabelStyle);
  await addLbl('lbl_panchas_sig', "Signature of Panchas:\nपंचाच्या सह्या :", boldLabelStyle);
  await addLbl('lbl_io_sig', "Name and Signature of Investigation Officer", boldLabelStyle);
  await addLbl('lbl_io_sig_mar', FormIoTerminology.amaldarSignatureHeader, marathiLabelStyle);
  await addLbl('lbl_io_name', "Name:\n${FormIoTerminology.name} :", boldLabelStyle);
  await addLbl('lbl_io_rank', "Rank:\n${FormIoTerminology.rank} :", boldLabelStyle);
  await addLbl('lbl_io_buckle', "B.No.if any:\nबक्कल नंबर :", boldLabelStyle);

  // Pre-render dynamic values
  await addVal('val_district', doc['district']?.toString() ?? '');
  await addVal('val_ps', doc['ps']);
  await addVal('val_year', doc['year']);
  await addVal('val_firNo', doc['firNo']);
  await addVal('val_firYearSuffix', doc['firYearSuffix']);
  await addVal('val_dateDay', doc['dateDay']);
  await addVal('val_dateMonth', doc['dateMonth']);
  await addVal('val_dateYear', doc['dateYear']);
  await addVal('val_actSection', doc['actSection']);
  await addVal('val_natureOfProperty', doc['natureOfProperty']);
  await addVal('val_seizureDateDay', doc['seizureDateDay']);
  await addVal('val_seizureDateMonth', doc['seizureDateMonth']);
  await addVal('val_seizureDateYear', doc['seizureDateYear']);
  await addVal('val_seizureTime', doc['seizureTime']);
  await addVal('val_seizurePlace', doc['seizurePlace']);
  await addVal('val_seizurePlaceDesc', doc['seizurePlaceDesc']);
  await addVal('val_seizedFrom', doc['seizedFrom']);
  await addVal('val_isProfessionalReceiver', (doc['isProfessionalReceiver'] ?? 'नाही').toString());
  await addVal('val_personName', doc['personName']);
  await addVal('val_personFather', doc['personFather']);
  await addVal('val_personSex', doc['personSex']);
  await addVal('val_personAge', doc['personAge']);
  await addVal('val_personOccupation', doc['personOccupation']);
  await addVal('val_personAddress', doc['personAddress']);
  await addVal('val_w1Name', doc['w1Name']);
  await addVal('val_w1Father', doc['w1Father']);
  await addVal('val_w1Sex', doc['w1Sex']);
  await addVal('val_w1Age', doc['w1Age']);
  await addVal('val_w1Occupation', doc['w1Occupation']);
  await addVal('val_w1Address', doc['w1Address']);
  await addVal('val_w2Name', doc['w2Name']);
  await addVal('val_w2Father', doc['w2Father']);
  await addVal('val_w2Sex', doc['w2Sex']);
  await addVal('val_w2Age', doc['w2Age']);
  await addVal('val_w2Occupation', doc['w2Occupation']);
  await addVal('val_w2Address', doc['w2Address']);
  await addVal('val_w2AddressLine2', doc['w2AddressLine2']);
  await addVal('val_perishableDisposal', doc['perishableDisposal']);
  await addVal('val_valuableKeeping', doc['valuableKeeping']);
  await addVal('val_identificationRequired', (doc['identificationRequired'] ?? 'नाही').toString());
  await addVal('val_circumstances', doc['circumstances']);
  await addVal('val_circumstancesLine2', doc['circumstancesLine2']);
  await addVal('val_circumstancesLine3', doc['circumstancesLine3']);
  await addVal('val_pancha1Name', doc['pancha1Name']?.toString());
  await addLinedBlock(
    'val_pancha1Address',
    _joinNonEmpty([doc['pancha1Addr1'], doc['pancha1Addr2'], doc['pancha1Addr3']]),
    40,
  );
  await addVal('val_pancha2Name', doc['pancha2Name']?.toString());
  await addLinedBlock(
    'val_pancha2Address',
    _joinNonEmpty([doc['pancha2Addr1'], doc['pancha2Addr2'], doc['pancha2Addr3']]),
    40,
  );
  await addVal('val_pancha1Sig', doc['pancha1Sig']?.toString());
  await addVal('val_pancha2Sig', doc['pancha2Sig']?.toString());
  await addVal(
    'val_panchaDate',
    _formatSlashDate(doc['panchaDateDay'], doc['panchaDateMonth'], doc['panchaDateYear']),
  );
  await addVal('val_ioName', doc['ioName']?.toString());
  await addVal('val_ioRank', doc['ioRank']?.toString());
  await addVal('val_ioBuckleNo', doc['ioBuckleNo']?.toString());
  await addVal('val_ioPosting', doc['ioPosting']?.toString());

  // Table rows
  final props = doc['properties'];
  if (props is List) {
    for (int i = 0; i < props.length; i++) {
      final item = props[i];
      final Map<String, dynamic> row = item is Map ? Map<String, dynamic>.from(item) : {};
      final desc = row['description']?.toString() ?? '';
      final val = row['value']?.toString() ?? '';
      if (containsDevanagari(desc)) {
        await cache.add('prop_${i}_desc', desc, valueStyle, maxWidth: 300);
      }
      if (containsDevanagari(val)) {
        await cache.add('prop_${i}_val', val, valueStyle, maxWidth: 100);
      }
    }
  }

  final sealProps = doc['sealProperties'];
  if (sealProps is List) {
    for (int i = 0; i < sealProps.length; i++) {
      final item = sealProps[i];
      final Map<String, dynamic> row = item is Map ? Map<String, dynamic>.from(item) : {};
      final property = row['property']?.toString() ?? '';
      final signature = row['signature']?.toString() ?? '';
      if (containsDevanagari(property)) {
        await cache.add('seal_${i}_property', property, valueStyle, maxWidth: 200);
      }
      if (containsDevanagari(signature)) {
        await cache.add('seal_${i}_signature', signature, valueStyle, maxWidth: 200);
      }
    }
  }

  return cache;
}
