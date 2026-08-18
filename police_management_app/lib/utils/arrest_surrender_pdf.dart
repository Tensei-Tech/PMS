import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'marathi_text_renderer.dart';
import 'form_io_terminology.dart';
import '../widgets/form_section_utils.dart';

Future<void> previewArrestSurrenderPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) async {
  final bytes = await generateArrestSurrenderPdf(doc);
  if (!context.mounted) return;
  final fileName = 'Arrest_Court_Surrender_Form_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

Future<Uint8List> generateArrestSurrenderPdf(Map<String, dynamic> doc) async {
  final pdf = pw.Document();

  // Load fonts
  final loraRegular = await PdfGoogleFonts.loraRegular();
  final loraBold = await PdfGoogleFonts.loraBold();

  // Pre-render Marathi text blocks
  final cache = await _preRenderAllMarathi(doc);

  const knownSectionIds = {'Form 3-A', 'Form 3-B', 'Form 3-C'};
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

  pw.Widget mLbl(String key) {
    if (cache.has(key)) return cache.img(key);
    return pw.SizedBox();
  }
  
  pw.Widget field(String labelText, String valKey, String fallback, {double? width}) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(labelText, style: englishBold),
        pw.Container(
          width: width,
          padding: const pw.EdgeInsets.only(left: 4, right: 4, bottom: 2),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
          ),
          child: renderText(valKey, fallback, englishStyle),
        ),
      ]
    );
  }

  pw.Widget buildInlineFieldWithMLbl(String enLabel, String mKey, String valKey, String fallback, {double? width}) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(enLabel, style: englishBold),
            mLbl(mKey),
          ]
        ),
        pw.Container(
          width: width,
          padding: const pw.EdgeInsets.only(left: 4, right: 4, bottom: 2),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
          ),
          child: renderText(valKey, fallback, englishStyle),
        ),
      ]
    );
  }

  pw.Widget check(String text, bool value, {bool isMarathi = false, String? mKey}) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 10,
          height: 10,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 1),
          ),
          child: value ? pw.Center(child: pw.Text('X', style: englishBold.copyWith(fontSize: 8))) : pw.SizedBox(),
        ),
        pw.SizedBox(width: 4),
        isMarathi && mKey != null ? mLbl(mKey) : pw.Text(text, style: englishStyle),
      ]
    );
  }

  // --- PAGE 1 ---
  if (showsSection('Form 3-A')) {
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Title
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text('ARREST/COURT SURRENDER FORM', style: headerEnglishStyle),
                  pw.SizedBox(height: 4),
                  mLbl('title_m1'),
                  mLbl('title_m2'),
                  pw.SizedBox(height: 8),
                  pw.Text('(Separate Memo for each accused)', style: englishBold),
                  mLbl('title_m3'),
                ]
              )
            ),
            pw.SizedBox(height: 16),
            
            // 1
            pw.Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                buildInlineFieldWithMLbl('1.Dist.', 'lbl_dist', 'val_dist', doc['dist'], width: 60),
                buildInlineFieldWithMLbl('P.S.:', 'lbl_ps', 'val_ps', doc['ps'], width: 60),
                buildInlineFieldWithMLbl('FIR/Proceeding/G.D.No:', 'lbl_fir', 'val_fir', doc['firNo'], width: 60),
                buildInlineFieldWithMLbl('Year:-20', 'lbl_year', 'val_year', doc['year'], width: 30),
                buildInlineFieldWithMLbl('Date', 'lbl_date', 'val_date', doc['date'], width: 60),
              ]
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Alphanumeric Code of the Accused (Write A1 to A9 for the first 9 persons, B1 for 10 th person and so on).', style: englishBold),
                    mLbl('lbl_code'),
                  ]
                ),
                pw.Expanded(
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
                    child: renderText('val_code', doc['accusedCode'], englishStyle),
                  ),
                ),
              ]
            ),
            pw.SizedBox(height: 12),
            
            // 2
            pw.Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                buildInlineFieldWithMLbl('2. Date, Time & place of Arrest/surrender :- Date', 'lbl_arr_date', 'val_arrDate', doc['arrestDate'], width: 60),
                buildInlineFieldWithMLbl('Time', 'lbl_arr_time', 'val_arrTime', doc['arrestTime'], width: 60),
                buildInlineFieldWithMLbl('G.D.No.', 'lbl_arr_gd', 'val_arrGd', doc['arrestGdNo'], width: 60),
              ]
            ),
            pw.SizedBox(height: 4),
            pw.Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                buildInlineFieldWithMLbl('Place of Arrest: - P.S.', 'lbl_arr_ps', 'val_arrPlace', doc['arrestPlace'], width: 100),
                buildInlineFieldWithMLbl('Dist.', 'lbl_arr_dist', 'val_arrDist', doc['arrestDist'], width: 80),
                buildInlineFieldWithMLbl('State.', 'lbl_arr_state', 'val_arrState', doc['arrestState'], width: 80),
              ]
            ),
            pw.SizedBox(height: 12),
            
            // 3
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('3. Name of the Court ( if surrendered) :-', style: englishBold),
                    mLbl('lbl_court'),
                  ]
                ),
                pw.SizedBox(width: 4),
                pw.Expanded(
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
                    child: renderText('val_court', doc['courtName'], englishStyle),
                  ),
                ),
              ]
            ),
            pw.SizedBox(height: 12),
            
            // 4
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('4. Acts and sections:-', style: englishBold),
                    mLbl('lbl_acts'),
                  ]
                ),
                pw.SizedBox(width: 4),
                pw.Expanded(
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
                    child: renderText('val_acts', doc['actsSections'], englishStyle),
                  ),
                ),
              ]
            ),
            pw.SizedBox(height: 12),
            
            // 5
            pw.Text('5. Arrested and forward / Arrested and released on bail or PR bound / Arrested but released on anticipatory bail/ Arrested and remanded to police Custody / Surrender in court and bailed out / Surrender in court and sent to judicial Custody / Surrender in court and remanded to police custody (tie applicable potion).', style: englishBold),
            mLbl('lbl_5_m1'),
            mLbl('lbl_5_m2'),
            pw.SizedBox(height: 4),
            pw.Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                check('Arrested and forward', doc['arrestedAndForwarded'] == true),
                check('Arrested and released on bail', doc['arrestedAndBailed'] == true),
                check('Arrested but released on anticipatory bail', doc['arrestedButAnticipatory'] == true),
                check('Arrested and remanded to police Custody', doc['arrestedAndRemandedPolice'] == true),
                check('Surrender in court and bailed out', doc['surrenderBailed'] == true),
                check('Surrender in court and sent to judicial Custody', doc['surrenderJudicial'] == true),
                check('Surrender in court and remanded to police custody', doc['surrenderPolice'] == true),
              ]
            ),
            pw.SizedBox(height: 12),
            
            // 6
            pw.Text('6. Particulars of the Accused ( आरोपीचा तपशील ) :-', style: englishBold),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  field('(i) Name (नांव) :-', 'val_accName', doc['accusedName'], width: 300),
                  pw.SizedBox(height: 4),
                  field('(ii)Father’s/Husband’s/Guardian\'s Name (पित्याचे/पतीचे/पालकाचे नांव ) :-', 'val_accFather', doc['accusedFather'], width: 200),
                  pw.SizedBox(height: 4),
                  field('(iii)Fist Alias (पहिले टोपण नांव ):-', 'val_accAlias1', doc['accusedAlias1'], width: 250),
                  pw.SizedBox(height: 4),
                  field('(iv)Second Alias (दुसरे टोपण नांव ):-', 'val_accAlias2', doc['accusedAlias2'], width: 250),
                  pw.SizedBox(height: 4),
                  field('(v) Nationality (राष्ट्रीयत्व) :-', 'val_accNat', doc['accusedNationality'], width: 200),
                  pw.SizedBox(height: 4),
                  pw.Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      field('(vi) (a) Voter ID. Card No: -', 'val_accVoter', doc['accusedVoter'], width: 100),
                      field('(b) *Passport No: -', 'val_accPass', doc['accusedPassport'], width: 100),
                    ]
                  ),
                  pw.Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      mLbl('lbl_6vi_m1'),
                      mLbl('lbl_6vi_m2'),
                    ]
                  ),
                  pw.Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      field('(c) Date of iisue :-', 'val_accDateIss', doc['accusedDateIssue'], width: 100),
                      field('(d) *Place or Issue :-', 'val_accPlaceIss', doc['accusedPlaceIssue'], width: 100),
                    ]
                  ),
                  pw.Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      mLbl('lbl_6vi_m3'),
                      mLbl('lbl_6vi_m4'),
                    ]
                  ),
                  pw.Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      buildInlineFieldWithMLbl('(vii) Religion: -', 'lbl_6vii_m1', 'val_accRelig', doc['accusedReligion'], width: 100),
                      buildInlineFieldWithMLbl('(viii) *Cast/Tribe: -', 'lbl_6viii_m1', 'val_accCaste', doc['accusedCaste'], width: 100),
                    ]
                  ),
                  pw.Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      buildInlineFieldWithMLbl('(ix) SC/ST/OBC :-', 'lbl_6ix_m1', 'val_accScSt', doc['accusedScSt'], width: 100),
                      buildInlineFieldWithMLbl('(x)*Occupation :-', 'lbl_6x_m1', 'val_accOcc', doc['accusedOccupation'], width: 100),
                    ]
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('(xi) Permanent Address :-', style: englishBold),
                          mLbl('lbl_6xi_m1'),
                        ]
                      ),
                      pw.SizedBox(width: 4),
                      pw.Expanded(
                        child: pw.Container(
                          decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
                          child: renderText('val_permAddr', doc['permAddress'], englishStyle),
                        ),
                      ),
                    ]
                  ),
                  pw.Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      buildInlineFieldWithMLbl('State :-', 'lbl_state', 'val_permState', doc['permState'], width: 80),
                      buildInlineFieldWithMLbl('Dist.:-', 'lbl_dist2', 'val_permDist', doc['permDist'], width: 80),
                      buildInlineFieldWithMLbl('P.S. :-', 'lbl_ps2', 'val_permPs', doc['permPs'], width: 80),
                    ]
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('(xii) Present Address:-', style: englishBold),
                          mLbl('lbl_6xii_m1'),
                        ]
                      ),
                      pw.SizedBox(width: 4),
                      pw.Expanded(
                        child: pw.Container(
                          decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
                          child: renderText('val_presAddr', doc['presAddress'], englishStyle),
                        ),
                      ),
                    ]
                  ),
                  pw.Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      buildInlineFieldWithMLbl('State: -', 'lbl_state', 'val_presState', doc['presState'], width: 80),
                      buildInlineFieldWithMLbl('Dist.:-', 'lbl_dist2', 'val_presDist', doc['presDist'], width: 80),
                      buildInlineFieldWithMLbl('P.S. :-', 'lbl_ps2', 'val_presPs', doc['presPs'], width: 80),
                    ]
                  ),
                ]
              )
            ),
            pw.SizedBox(height: 12),
            
            // 7
            pw.Text('7. Injuries, cause of injuries and physical condition of the accused person (indicate if medically examined)', style: englishBold),
            mLbl('lbl_7_m1'),
            pw.Container(
              width: double.infinity,
              height: 20,
              decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
              child: renderText('val_injuries', doc['injuries'], englishStyle),
            ),
          ]
        );
      }
    )
  );
  }

  // --- PAGE 2 ---
  if (showsSection('Form 3-B')) {
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('From: 3-B', style: englishBold),
            ),
            pw.SizedBox(height: 8),
            
            // 8
            pw.Text('8. The accused, after vying informed of the grounds of arrest and his leagal rights, was duty taken. Into custody', style: englishBold),
            pw.Wrap(
              crossAxisAlignment: pw.WrapCrossAlignment.end,
              children: [
                pw.Text('on :', style: englishBold),
                pw.Container(
                  width: 80,
                  decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
                  child: renderText('val_cusDate', doc['custodyDate'], englishStyle),
                ),
                pw.Text(' (date) at :', style: englishBold),
                pw.Container(
                  width: 80,
                  decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
                  child: renderText('val_cusHours', doc['custodyHours'], englishStyle),
                ),
                pw.Text(' (hours) at :', style: englishBold),
                pw.Container(
                  width: 120,
                  decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
                  child: renderText('val_cusPlace', doc['custodyPlace'], englishStyle),
                ),
                pw.Text('(place).', style: englishBold),
              ]
            ),
            mLbl('lbl_8_m1'),
            mLbl('lbl_8_m2'),
            pw.SizedBox(height: 8),
            
            pw.Text('The following article(s) was/were found on physical search. Conducted on the person of the accused. And were taken into possession for which a receipt was given to the accused. **', style: englishBold),
            mLbl('lbl_8_m3'),
            pw.SizedBox(height: 8),
            
            pw.Row(
              children: [
                pw.Expanded(child: field('1 ', 'val_art1', doc['article1'], width: 150)),
                pw.Expanded(child: field('2 ', 'val_art2', doc['article2'], width: 150)),
              ]
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                pw.Expanded(child: field('3 ', 'val_art3', doc['article3'], width: 150)),
                pw.Expanded(child: field('4 ', 'val_art4', doc['article4'], width: 150)),
              ]
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                pw.Expanded(child: field('5 ', 'val_art5', doc['article5'], width: 150)),
                pw.Expanded(child: field('6 ', 'val_art6', doc['article6'], width: 150)),
              ]
            ),
            pw.SizedBox(height: 12),
            
            pw.Text('Necessary wearing apparels were left on the accused for the sake of human dignity and body protection', style: englishBold),
            mLbl('lbl_8_m4'),
            pw.SizedBox(height: 8),
            pw.Text('The accused was cautioned to keep him/herself covered for purpose of identification.', style: englishBold),
            mLbl('lbl_8_m5'),
            pw.SizedBox(height: 8),
            
            pw.Row(
              children: [
                field('Intimation given to Name: ', 'val_intName', doc['intimationName'], width: 150),
                pw.SizedBox(width: 16),
                field('(Relationship):', 'val_intRel', doc['intimationRel'], width: 100),
              ]
            ),
            pw.Row(
              children: [
                mLbl('lbl_8_m6'),
                pw.SizedBox(width: 150),
                mLbl('lbl_8_m7'),
              ]
            ),
            pw.SizedBox(height: 8),
            pw.Text('** If no article found, NIL, may be indicated in the bland space provided below:-', style: englishBold),
            mLbl('lbl_8_m8'),
          ]
        );
      }
    )
  );

  // --- PAGE 3: Physical Features (Landscape) ---
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('From: 3-B (cont.)', style: englishBold),
            ),
            pw.SizedBox(height: 8),
            pw.Text('9. Physical features, deformities and other details of the accused:-', style: englishBold),
            mLbl('lbl_9_m1'),
            pw.SizedBox(height: 8),
            _buildPdfTable(
              headers: ['Sr. No.\nअ.क्र.', 'Sex\nलिंग', 'Date/year of\nBirth\nजन्म तारीख/\nवर्ष', 'Build\nबांधा', 'Height in\nCms.\nउंची से.मी.', 'Complexion\nवर्ण', 'identification\n(Mark)\nओळखचिन्ह', 'Deformities\nPeculiarities\nव्यंग व\nवैशिष्टे', 'Teeth\nदात', 'Hair\nकेस'],
              colIndices: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
              doc: doc,
              cache: cache,
              englishStyle: englishStyle,
              englishBold: englishBold,
            ),
            pw.SizedBox(height: 10),
            _buildPdfTable(
              headers: ['Eye\nडोळे', 'Habits\nसवयी', 'Dress\nHabits\nपोषाखाच्या\nसवयी', 'Languages\nबोली/ भाषा', 'Burn Mark\nभाजल्याच्या\nखुणा', 'Leucoderma\nकोळ', 'Mole\nतिळ', 'Scar\nवण', 'Tattoo\nगोंदण', 'Forehead\nकपाळ'],
              colIndices: [11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
              doc: doc,
              cache: cache,
              englishStyle: englishStyle,
              englishBold: englishBold,
            ),
            pw.SizedBox(height: 10),
            _buildPdfTable(
              headers: ['Ear\nकान', 'Noes\nनाक', 'Moustaches\nमिशी', 'Speech/voice\nबोलण्याची पध्दत', 'Face\nचेहरा', 'Lips\nओठ'],
              colIndices: [21, 22, 23, 24, 25, 26],
              doc: doc,
              cache: cache,
              englishStyle: englishStyle,
              englishBold: englishBold,
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Other features if any: ', style: englishBold),
                pw.Expanded(
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                    ),
                    child: renderText('val_otherFeatures', doc['otherFeatures']?.toString(), englishStyle),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
  }

  // --- PAGE 4 ---
  if (showsSection('Form 3-C')) {
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('From: 3-C', style: englishBold),
            ),
            pw.SizedBox(height: 8),
            
            // 10
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('10. Whether finger print taken or not? :', style: englishBold),
                    mLbl('lbl_10_m1'),
                  ]
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
                    child: pw.Text(doc['fingerprintTaken'] == true ? 'Yes' : 'No', style: englishStyle),
                  ),
                ),
              ]
            ),
            pw.SizedBox(height: 12),
            
            // 11
            pw.Text('11. Socio-economic profile of the accused showing.', style: englishBold),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('(a) Living Status: - Living alone/Living with Family/with Associate in Pucca House/Hotel/ Hostel/', style: englishBold),
                  pw.Text('                                 Kacheha House / Thatehed House / Slum/ Homeless/ Harbourer.', style: englishBold),
                  mLbl('lbl_11a_m1'),
                  mLbl('lbl_11a_m2'),
                  pw.Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      check('Living alone', doc['livingAlone'] == true),
                      check('Living with Family', doc['livingWithFamily'] == true),
                      check('with Associate', doc['livingWithAssociate'] == true),
                      check('Pucca House', doc['livingPucca'] == true),
                      check('Hotel', doc['livingHotel'] == true),
                      check('Hostel', doc['livingHostel'] == true),
                      check('Kacheha House', doc['livingKachcha'] == true),
                      check('Thatehed House', doc['livingThatched'] == true),
                      check('Slum', doc['livingSlum'] == true),
                      check('Homeless', doc['livingHomeless'] == true),
                      check('Harbourer', doc['livingHarbourer'] == true),
                    ]
                  ),
                  pw.SizedBox(height: 12),
                  
                  pw.Row(
                    children: [
                      buildInlineFieldWithMLbl('(b)Educational qualifications(s)', 'lbl_11b_m1', 'val_edu', doc['eduQual'], width: 120),
                      pw.SizedBox(width: 16),
                      buildInlineFieldWithMLbl('(c) occupation', 'lbl_11c_m1', 'val_occ2', doc['occupation2'], width: 120),
                    ]
                  ),
                  pw.SizedBox(height: 12),
                  
                  pw.Text('(d) Income Group ( उत्पन्न गट ) :-', style: englishBold),
                  mLbl('lbl_11d_m1'),
                  pw.SizedBox(height: 4),
                  
                  check('(i) Lower Income (Below Rs. 25000 P.Y.) = कमी उत्पन्न ( द.सा.रू २५००० पेक्ष कमी )', doc['incomeLower'] == true),
                  check('(ii) Lower Middle Income (From Rs. 25001 to 50000) = कमी मध्यम उत्पन्न ( २५००१ ते ५००००)', doc['incomeLowerMid'] == true),
                  check('(iii) Middle Income (From 50001 to 100000) = मध्यम उत्पन्न (२५,००१ ते १००,००० )', doc['incomeMiddle'] == true),
                  check('(iv) Upper Middle Income (/From 100000 to 200000)= उच्च मध्यम उत्पन्न ( १००,००१ ते  २००,०००)', doc['incomeUpperMid'] == true),
                  check('(v) Upper Middle Income (Rs. 200000 to 300000) = उच्च मध्यम उत्पन्न ( २००,००१ ते ३००,०००)', doc['incomeUpperMid2'] == true),
                  check('(vi) Upper Income (above 300000) =SSE = उच्च उत्पन्न ( ३००,०००)', doc['incomeUpper'] == true),
                ]
              )
            ),
            pw.SizedBox(height: 16),
            
            // 12
            pw.Text('12. Whether the accused person as per the observations and known police records:', style: englishBold),
            mLbl('lbl_12_m1'),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _yesNoRow('(a) Is dangerous ? (धोकादायक आहे किंवा कसे?)', doc['isDangerous'] == true, englishStyle, englishBold),
                  _yesNoRow('(b) Previously escaped any bail ? ( पुर्वी जामीनावर असतांना पळुन गेला किंवा काय ? )', doc['prevEscaped'] == true, englishStyle, englishBold),
                  _yesNoRow('(c) Is generally armed? ( नेहमी सशस्त्र असतो किंवा नसतो ?)', doc['generallyArmed'] == true, englishStyle, englishBold),
                  _yesNoRow('(d) Operates with accomplices? ( साथीदारासह काम करतो किंवा कसे ? )', doc['operatesWithAccomplices'] == true, englishStyle, englishBold),
                  _yesNoRow('(e) Has past criminal records ? (गुन्हेगारी पार्श्वभुमी आहे किंवा नाही ? )', doc['pastCriminal'] == true, englishStyle, englishBold),
                  _yesNoRow('(f) Is recidivism (वारंवार अपराध करतो किंवा काय ? )', doc['isRecidivism'] == true, englishStyle, englishBold),
                  _yesNoRow('(g) Is likely to escape bail ? (जामीनावर असतांना पळूनजाण्याचा संभव किंवा नाही ? )', doc['likelyToEscape'] == true, englishStyle, englishBold),
                  _yesNoRow('(h) Is released on bail. Likely to commit crime or threaten victims/witnesses.', doc['releasedOnBail'] == true, englishStyle, englishBold),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 16),
                    child: pw.Text('(जामीनावर साडल्यास लगेच दुसरा गुन्हा करण्याचा किंवा बळींना/ साक्षेदारांना धाकदपटशा दाखविण्याचा संभव आहे किंवा नाही?)', style: englishStyle),
                  ),
                  _yesNoRow('(i) Is wanted many other case? (दुसऱ्या कोणत्याही प्रकरणात पाहिजे किंवा काय ?)', doc['wantedMany'] == true, englishStyle, englishBold),
                  pw.Row(
                    children: [
                      pw.Text('(If yes give case ref. Sec.) ( जर होय असेल तर त्या प्रकरणाचा संदर्भ व कलमे दयवीत ?)', style: englishStyle),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Container(
                          decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
                          child: renderText('val_caseRef', doc['caseRefSec'], englishStyle),
                        ),
                      ),
                    ]
                  ),
                ]
              )
            ),
            pw.SizedBox(height: 16),
            
            // 13
            pw.Row(
              children: [
                pw.Expanded(child: buildInlineFieldWithMLbl('13. पंचाची नांवे (1) :', 'lbl_13_m1', 'val_p1Name', doc['panch1Name'])),
                pw.Expanded(child: buildInlineFieldWithMLbl('पंचाच्या सहया (1) :', 'lbl_13_m2', 'val_p1Sig', doc['panch1Sig'])),
              ]
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Name and Address of the witnesses/Panchas\n(At Least one witness necessary)', style: englishBold),
                pw.Text('Signature\n', style: englishBold),
              ]
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                pw.Expanded(child: field('(2):', 'val_p2Name', doc['panch2Name'])),
                pw.Expanded(child: buildInlineFieldWithMLbl('पंचाच्या सहया (2) :', 'lbl_13_m3', 'val_p2Sig', doc['panch2Sig'])),
              ]
            ),
            pw.SizedBox(height: 4),
            pw.Text('(At Least one witness necessary)', style: englishBold),
            pw.SizedBox(height: 16),
            
            // 14 & 15
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('14. Signature and Thumb hapression of Arrested person', style: englishBold),
                      mLbl('lbl_14_m1'),
                      pw.SizedBox(height: 16),
                      field(':', 'val_arrSig', doc['arrestedPersonSig'], width: 150),
                      pw.SizedBox(height: 16),
                      pw.Text('15.', style: englishBold),
                      buildInlineFieldWithMLbl('Place: ', 'lbl_15_m1', 'val_fPlace', doc['finalPlace'], width: 100),
                      pw.SizedBox(height: 8),
                      buildInlineFieldWithMLbl('Date: ', 'lbl_15_m2', 'val_fDate', doc['finalDate'], width: 100),
                    ]
                  )
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Signature of the Investigation Officer with:', style: englishBold),
                      pw.SizedBox(height: 8),
                      field('Signature / सही :-', 'val_ioSig', doc['ioSig'], width: 150),
                      pw.SizedBox(height: 16),
                      buildInlineFieldWithMLbl('Name: ', 'lbl_15_m3', 'val_fName', doc['finalName'], width: 150),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        children: [
                          buildInlineFieldWithMLbl('Rank: ', 'lbl_15_m4', 'val_fRank', doc['finalRank'], width: 80),
                          pw.SizedBox(width: 8),
                          buildInlineFieldWithMLbl('No: ', 'lbl_15_m5', 'val_fNo', doc['finalNo'], width: 60),
                        ]
                      )
                    ]
                  )
                ),
              ]
            ),
          ]
        );
      }
    )
  );
  }

  return pdf.save();
}

pw.Widget _yesNoRow(String label, bool value, pw.TextStyle style, pw.TextStyle boldStyle) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(child: pw.Text(label, style: style)),
        pw.Text('Yes/No (होय/नाही) ', style: boldStyle),
        pw.Text(value ? '[Yes]' : '[No]', style: style),
      ]
    ),
  );
}

pw.Widget _buildPdfTable({
  required List<String> headers,
  required List<int> colIndices,
  required Map<String, dynamic> doc,
  required MarathiImageCache cache,
  required pw.TextStyle englishStyle,
  required pw.TextStyle englishBold,
}) {
  final Map<String, dynamic> pt = doc['physTable'] is Map ? doc['physTable'] as Map<String, dynamic> : {};
  
  return pw.Table(
    border: pw.TableBorder.all(width: 1),
    columnWidths: {
      for (int i = 0; i < headers.length; i++)
        i: const pw.FlexColumnWidth(),
    },
    children: [
      pw.TableRow(
        children: List.generate(headers.length, (i) {
          final lines = headers[i].split('\n');
          return pw.Padding(
            padding: const pw.EdgeInsets.all(2),
            child: pw.Column(
              children: [
                pw.Text(lines[0], style: englishBold.copyWith(fontSize: 8), textAlign: pw.TextAlign.center),
                if (lines.length > 1) ...[
                  for (int j = 1; j < lines.length; j++)
                    if (containsDevanagari(lines[j]))
                      cache.has('tbl_h_${colIndices[i]}_$j') ? cache.img('tbl_h_${colIndices[i]}_$j') : pw.SizedBox()
                    else
                      pw.Text(lines[j], style: englishBold.copyWith(fontSize: 8), textAlign: pw.TextAlign.center),
                ],
                pw.Divider(thickness: 0.5),
                pw.Text('${colIndices[i]}', style: englishBold.copyWith(fontSize: 8), textAlign: pw.TextAlign.center),
              ]
            )
          );
        })
      ),
      pw.TableRow(
        children: List.generate(headers.length, (i) {
          final val = pt[colIndices[i].toString()]?.toString() ?? '';
          return pw.Container(
            height: 30, // Fixed height for input area
            padding: const pw.EdgeInsets.all(2),
            child: containsDevanagari(val)
                ? (cache.has('tbl_v_${colIndices[i]}') ? cache.img('tbl_v_${colIndices[i]}') : pw.SizedBox())
                : pw.Text(val, style: englishStyle.copyWith(fontSize: 8)),
          );
        })
      ),
    ]
  );
}

Future<MarathiImageCache> _preRenderAllMarathi(Map<String, dynamic> doc) async {
  final cache = MarathiImageCache();

  final headerStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  final marathiLabelStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 9,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  final valueStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 9,
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

  // Page 1
  await addLbl('title_m1', 'अटकेचा पंचनामा/ न्यायालयाच्या', headerStyle);
  await addLbl('title_m2', 'स्वाधीन होण्याचा नमुना', headerStyle);
  await addLbl('title_m3', '(प्रत्येक आरोपीसाठी स्वतंत्र नमुना वापरावा)', marathiLabelStyle);
  
  await addLbl('lbl_dist', 'जिल्हा :-', marathiLabelStyle);
  await addLbl('lbl_ps', 'पो.स्टे.', marathiLabelStyle);
  await addLbl('lbl_fir', 'पहिली खबर क्र/ कार्यवाही क्र.', marathiLabelStyle);
  await addLbl('lbl_year', 'वर्ष', marathiLabelStyle);
  await addLbl('lbl_date', 'दिनांक', marathiLabelStyle);
  await addLbl('lbl_code', 'आरोपीचा सांकेतीक क्रमांक ( पहिल्या ९ व्यक्तींसाठी अ १ ते अ ९, दहाव्या व्यक्तीसाठी ब १ या प्रमाणे पुढे असे लिहावे )', marathiLabelStyle);
  
  await addLbl('lbl_arr_date', 'अटकेची / स्वाधीन होण्याची तारीख वेळ', marathiLabelStyle);
  await addLbl('lbl_arr_time', 'दिनांक', marathiLabelStyle);
  await addLbl('lbl_arr_gd', 'वेळ ठाणे दैनंदिन क्रमांक', marathiLabelStyle);
  await addLbl('lbl_arr_ps', 'अटकेची जागा पोलीस ठाणे', marathiLabelStyle);
  await addLbl('lbl_arr_dist', 'जिल्हा', marathiLabelStyle);
  await addLbl('lbl_arr_state', 'राज्य', marathiLabelStyle);
  
  await addLbl('lbl_court', 'न्यायालयाचे नांव ( स्वाधीन झाल्यास ) :-', marathiLabelStyle);
  await addLbl('lbl_acts', 'अधिनियम व कलमे :-', marathiLabelStyle);
  
  await addLbl('lbl_5_m1', 'अटक केली व न्यायालयात पाठविले/ अटक केली व जामीनावर सोडले किंवा वैयक्तीक जात मुचलक्यावर सोडले / अटक केली व अटकपूर्व जामीनावर सोडले/ अटक केले व पोलीस कोठडीत', marathiLabelStyle);
  await addLbl('lbl_5_m2', 'पाठविले/ न्यायालयाचे स्वाधीन व जामीनावर / न्यायालयाचे स्वाधीन व न्यायालयीन कोठडीत पाठविले/ न्यायालयाचे स्वाधीन व पोलीस कोठडीत पाठविले', marathiLabelStyle);
  
  await addLbl('lbl_6vi_m1', 'मतदान ओळखपत्र क्रमांक:-', marathiLabelStyle);
  await addLbl('lbl_6vi_m2', 'पारपत्र क्रमांक :-', marathiLabelStyle);
  await addLbl('lbl_6vi_m3', 'दिल्याची तारीख :-', marathiLabelStyle);
  await addLbl('lbl_6vi_m4', 'दिल्याचो जागा :-', marathiLabelStyle);
  await addLbl('lbl_6vii_m1', '(धर्म) :-', marathiLabelStyle);
  await addLbl('lbl_6viii_m1', '(जात जमात):-', marathiLabelStyle);
  await addLbl('lbl_6ix_m1', '(अनु.जा/ अनु जमात/ इ.मा.व) :-', marathiLabelStyle);
  await addLbl('lbl_6x_m1', '(व्यवसाय) :-', marathiLabelStyle);
  await addLbl('lbl_6xi_m1', '(कायमचा पत्ता) :-', marathiLabelStyle);
  await addLbl('lbl_state', 'राज्य', marathiLabelStyle);
  await addLbl('lbl_dist2', 'जिल्हा', marathiLabelStyle);
  await addLbl('lbl_ps2', 'पोलीस ठाणे', marathiLabelStyle);
  await addLbl('lbl_6xii_m1', '(सध्याचा पत्ता) :-', marathiLabelStyle);
  
  await addLbl('lbl_7_m1', 'जखम, जखमाची कारणे आणि आरोपीची शारीरीक अवस्था / (वैद्यकीय तपासणी केली असल्यास नमुद करणे)', marathiLabelStyle);
  
  // Page 2
  await addLbl('lbl_8_m1', 'कायदेशीर अटकेची कारणे आणि त्याचे कायदेशीर अधिकार सांगीतल्यानंतर दि.:--------/--------/20……… रोजी ………/……….वाजता', marathiLabelStyle);
  await addLbl('lbl_8_m2', '____________________________________________________ (ठिकाण) येथे योग्य रित्या ताब्यात घेण्यात आले.', marathiLabelStyle);
  await addLbl('lbl_8_m3', 'आरोपीच्या अंगझडतीमध्ये खालील वस्तु आढळल्या. त्या ताब्यात घेण्यात आल्या आणि त्या बद्दल त्याची पोच देण्यात आली.', marathiLabelStyle);
  await addLbl('lbl_8_m4', '(मानवी प्रतिष्ठेसाठी व शरीर झाकण्यासाठी आरोपीच्या अंगावर आवश्यक तेवढे कपडे ठेवण्यात आले होते.)', marathiLabelStyle);
  await addLbl('lbl_8_m5', 'ओळख पटण्याच्या प्रयोजनासाठी आरोपीला स्वतःला झाकुन घेण्याची ताकीद देण्यात आली होती.', marathiLabelStyle);
  await addLbl('lbl_8_m6', 'यांना खबरदेण्यात आली नांव', marathiLabelStyle);
  await addLbl('lbl_8_m7', '(नाते)', marathiLabelStyle);
  await addLbl('lbl_8_m8', 'जर कोणतीही वस्तु आढळली नाही तर खालील जागेत नाही असे नमुद करावे.', marathiLabelStyle);
  
  await addLbl('lbl_9_m1', 'शारीरीक वैशिष्टे आणि आरोपीचा इतर तपशील :-', marathiLabelStyle);
  
  // Page 3
  await addLbl('lbl_10_m1', 'बोटाचे ठसे घेतले आहेत किंवा नाही असल्यास त्यांचा नंबर/ ठसे घेतले नसल्यास त्याचे कारण.', marathiLabelStyle);
  await addLbl('lbl_11a_m1', 'राहणीमान :- एकटा कुटूंबीयासोबत/ सहकारी यांच्या बरोबर पक्या घरात/ हॉटेलात/ वसतीगृहात/ कच्च्या घरात/ गव्ती छपराच्या झोपडीत/', marathiLabelStyle);
  await addLbl('lbl_11a_m2', 'गलीच्छ वस्तीत राहतो/ बेघर किंवा आश्रय घेतलेला नाही.', marathiLabelStyle);
  await addLbl('lbl_11b_m1', '(शैक्षणीक अर्हता) :', marathiLabelStyle);
  await addLbl('lbl_11c_m1', '(व्यवसाय) :', marathiLabelStyle);
  await addLbl('lbl_11d_m1', ' उत्पन्न गट ', marathiLabelStyle);
  await addLbl('lbl_12_m1', 'निरीक्षणावरून आणि माहिती असलेल्या पोलीस अभिलेखानुसार आरोपी :-', marathiLabelStyle);
  
  await addLbl('lbl_13_m1', 'पंचाची नांवे (1) :', marathiLabelStyle);
  await addLbl('lbl_13_m2', 'पंचाच्या सहया (1) :', marathiLabelStyle);
  await addLbl('lbl_13_m3', 'पंचाच्या सहया (2) :', marathiLabelStyle);
  
  await addLbl('lbl_14_m1', 'आरोपीची सही व आरोपीचा व अंगठा', marathiLabelStyle);
  
  await addLbl('lbl_15_m1', 'ठिकाण', marathiLabelStyle);
  await addLbl('lbl_15_m2', 'तारीख', marathiLabelStyle);
  await addLbl('lbl_15_m3', FormIoTerminology.signatureHeader, marathiLabelStyle);
  await addLbl('lbl_15_m4', FormIoTerminology.rank, marathiLabelStyle);
  await addLbl('lbl_15_m5', 'क्रमांक', marathiLabelStyle);

  // Table Headers
  final tableHeaders = {
    1: ['अ.क्र.'],
    2: ['लिंग'],
    3: ['जन्म तारीख/', 'वर्ष'],
    4: ['बांधा'],
    5: ['उंची से.मी.'],
    6: ['वर्ण'],
    7: ['ओळखचिन्ह'],
    8: ['व्यंग व', 'वैशिष्टे'],
    9: ['दात'],
    10: ['केस'],
    11: ['डोळे'],
    12: ['सवयी'],
    13: ['पोषाखाच्या', 'सवयी'],
    14: ['बोली/ भाषा'],
    15: ['भाजल्याच्या', 'खुणा'],
    16: ['कोळ'],
    17: ['तिळ'],
    18: ['वण'],
    19: ['गोंदण'],
    20: ['कपाळ'],
    21: ['कान'],
    22: ['नाक'],
    23: ['मिशी'],
    24: ['बोलण्याची पध्दत'],
    25: ['चेहरा'],
    26: ['ओठ'],
  };
  
  final tblHeaderStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 8,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  for (final entry in tableHeaders.entries) {
    for (int j = 0; j < entry.value.length; j++) {
      if (containsDevanagari(entry.value[j])) {
        // use j+1 because header lines loop starts at 1 if lines.length > 1
        await cache.add('tbl_h_${entry.key}_${j+1}', entry.value[j], tblHeaderStyle);
      }
    }
  }

  // Values — cache keys must match renderText valKey arguments in the PDF layout
  const valueKeyMap = <String, String>{
    'val_dist': 'dist',
    'val_ps': 'ps',
    'val_fir': 'firNo',
    'val_year': 'year',
    'val_date': 'date',
    'val_code': 'accusedCode',
    'val_arrDate': 'arrestDate',
    'val_arrTime': 'arrestTime',
    'val_arrGd': 'arrestGdNo',
    'val_arrPlace': 'arrestPlace',
    'val_arrDist': 'arrestDist',
    'val_arrState': 'arrestState',
    'val_court': 'courtName',
    'val_acts': 'actsSections',
    'val_accName': 'accusedName',
    'val_accFather': 'accusedFather',
    'val_accAlias1': 'accusedAlias1',
    'val_accAlias2': 'accusedAlias2',
    'val_accNat': 'accusedNationality',
    'val_accVoter': 'accusedVoter',
    'val_accPass': 'accusedPassport',
    'val_accDateIss': 'accusedDateIssue',
    'val_accPlaceIss': 'accusedPlaceIssue',
    'val_accRelig': 'accusedReligion',
    'val_accCaste': 'accusedCaste',
    'val_accScSt': 'accusedScSt',
    'val_accOcc': 'accusedOccupation',
    'val_permAddr': 'permAddress',
    'val_permState': 'permState',
    'val_permDist': 'permDist',
    'val_permPs': 'permPs',
    'val_presAddr': 'presAddress',
    'val_presState': 'presState',
    'val_presDist': 'presDist',
    'val_presPs': 'presPs',
    'val_injuries': 'injuries',
    'val_cusDate': 'custodyDate',
    'val_cusHours': 'custodyHours',
    'val_cusPlace': 'custodyPlace',
    'val_art1': 'article1',
    'val_art2': 'article2',
    'val_art3': 'article3',
    'val_art4': 'article4',
    'val_art5': 'article5',
    'val_art6': 'article6',
    'val_intName': 'intimationName',
    'val_intRel': 'intimationRel',
    'val_edu': 'eduQual',
    'val_occ2': 'occupation2',
    'val_caseRef': 'caseRefSec',
    'val_p1Name': 'panch1Name',
    'val_p2Name': 'panch2Name',
    'val_p1Sig': 'panch1Sig',
    'val_p2Sig': 'panch2Sig',
    'val_arrSig': 'arrestedPersonSig',
    'val_ioSig': 'ioSig',
    'val_fPlace': 'finalPlace',
    'val_fDate': 'finalDate',
    'val_fName': 'finalName',
    'val_fRank': 'finalRank',
    'val_fNo': 'finalNo',
    'val_otherFeatures': 'otherFeatures',
  };

  for (final entry in valueKeyMap.entries) {
    await addVal(entry.key, doc[entry.value]?.toString());
  }
  
  // Table values
  if (doc['physTable'] is Map) {
    final pt = doc['physTable'] as Map<String, dynamic>;
    for (int i = 1; i <= 26; i++) {
      await addVal('tbl_v_$i', pt[i.toString()]);
    }
  }

  return cache;
}
