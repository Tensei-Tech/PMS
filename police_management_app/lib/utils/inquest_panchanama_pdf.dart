import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'marathi_text_renderer.dart';
import '../widgets/form_section_utils.dart';

Future<void> previewInquestPanchanamaPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) async {
  final bytes = await generateInquestPanchanamaPdf(doc);
  if (!context.mounted) return;
  final fileName =
      'Inquest_Panchanama_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

Future<Uint8List> generateInquestPanchanamaPdf(Map<String, dynamic> doc) async {
  final pdf = pw.Document();
  final data = Map<String, dynamic>.from(doc);
  data['kal14Cigarette'] = data['kal14Cigarette'] == true ? 'Yes' : 'No';
  data['kal14Daru'] = data['kal14Daru'] == true ? 'Yes' : 'No';
  data['kal14Tambakhu'] = data['kal14Tambakhu'] == true ? 'Yes' : 'No';
  data['kal14PanMasala'] = data['kal14PanMasala'] == true ? 'Yes' : 'No';

  final loraRegular = await PdfGoogleFonts.loraRegular();
  final loraBold = await PdfGoogleFonts.loraBold();
  final cache = await _preRenderAllMarathi(data);

  final englishStyle = pw.TextStyle(font: loraRegular, fontSize: 9, color: PdfColors.black);
  final englishBold = pw.TextStyle(
    font: loraBold,
    fontSize: 9,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );
  final headerStyle = pw.TextStyle(
    font: loraBold,
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );
  final sectionStyle = pw.TextStyle(
    font: loraBold,
    fontSize: 11,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  String str(dynamic v) => v?.toString().trim() ?? '';

  const knownSectionIds = {
    'Inquest Main',
    'Civil Surgeon PM Report',
    'Vinanti Arj',
    'Relative Summons 179',
    'Pancha Summons 195',
    'Marananveshan Panchanama',
    '14 Kalmi Form',
    'Dead Body Handover',
    'Duty Pass',
  };
  final activeSection = data['formSection']?.toString();

  bool showsSection(String sectionId) => showsFormSection(
        activeSection: activeSection,
        sectionId: sectionId,
        knownSectionIds: knownSectionIds,
      );

  pw.Widget renderText(String key, String? val) {
    final text = val?.trim() ?? '';
    if (text.isEmpty) return pw.SizedBox();
    if (containsDevanagari(text) && cache.has(key)) {
      return pw.Container(alignment: pw.Alignment.topLeft, child: cache.img(key));
    }
    return pw.Text(text, style: englishStyle);
  }

  pw.Widget mImg(String key) => cache.has(key) ? cache.img(key) : pw.SizedBox();

  pw.Widget sectionTitle(String title) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 12, bottom: 6),
        child: pw.Text(title, style: sectionStyle),
      );

  pw.Widget pageBreakLabel(String label) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.NewPage(),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(label, style: englishBold.copyWith(fontSize: 8)),
          ),
          pw.Divider(thickness: 0.5),
          pw.SizedBox(height: 8),
        ],
      );

  pw.Widget field(String label, String key) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(flex: 2, child: pw.Text(label, style: englishBold)),
            pw.SizedBox(width: 4),
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                ),
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: renderText('val_$key', str(data[key])),
              ),
            ),
          ],
        ),
      );

  pw.Widget wideField(String label, String key, {int lines = 1}) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: englishBold),
            pw.Container(
              width: double.infinity,
              constraints: pw.BoxConstraints(minHeight: lines * 12.0),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
              ),
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: renderText('val_$key', str(data[key])),
            ),
          ],
        ),
      );

  pw.TableRow csRow(String question, String key, {int lines = 1}) => pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(question, style: englishBold.copyWith(fontSize: 8)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Container(
              constraints: pw.BoxConstraints(minHeight: lines * 10.0),
              child: renderText('val_$key', str(data[key])),
            ),
          ),
        ],
      );

  pw.Widget csTable(List<pw.TableRow> rows) => pw.Table(
        border: pw.TableBorder.all(width: 0.5),
        columnWidths: {0: const pw.FlexColumnWidth(4), 1: const pw.FlexColumnWidth(6)},
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text('Question (प्रश्न)', style: englishBold, textAlign: pw.TextAlign.center),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text('Answer (उत्तर)', style: englishBold, textAlign: pw.TextAlign.center),
              ),
            ],
          ),
          ...rows,
        ],
      );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 28),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.bottomRight,
        child: pw.Text('M.R.W', style: englishBold.copyWith(fontSize: 8)),
      ),
      build: (ctx) => [
        if (showsSection('Inquest Main')) ...[
        // ── INQUEST PANCHANAMA (u/s 194 BNSS) ──
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text('INQUEST PANCHANAMA', style: headerStyle),
              mImg('hdr_m1'),
              pw.Text('(Under Section - 194 B.N.S.S.)', style: englishBold),
              mImg('hdr_m2'),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            field('1) Dist.:', 'dist'),
            field('P.S.:', 'ps'),
            field('Year:-20', 'year'),
            field('FIR/AD/U.D.No:', 'firNo'),
          ],
        ),
        field('2) Act and Section:', 'actSections'),
        wideField('3) Place From where Dead Body Found/Traced:', 'deadBodyFoundPlace'),
        pw.Wrap(
          spacing: 8,
          children: [
            field('Place:', 'foundPlace'),
            field('Date:', 'foundDate'),
            field('Time:', 'foundTime'),
          ],
        ),
        field('4) By whom Dead Body Shown:', 'shownBy'),
        wideField('5) By whom Dead Body Identified:', 'identifiedBy'),
        field('a) Dead Body Male/Female:', 'gender'),
        field('b) Married/Unmarried:', 'married'),
        field('c) Age of Dead Body:', 'age'),
        pw.Wrap(
          spacing: 8,
          children: [
            field('d) Date of Death:', 'deathDate'),
            field('Time:', 'deathTime'),
          ],
        ),
        wideField('7) Position of Dead Body:', 'positionOfBody', lines: 2),

        pageBreakLabel('Page 2'),
        wideField('8) Name and Address of Dead Body:', 'nameAddressDeceased', lines: 2),
        sectionTitle('9) Description Of injuries Found on Dead Body if any:'),
        ...[
          ('a) Head', 'injHead'),
          ('b) Face', 'injFace'),
          ('c) Neck', 'injNeck'),
          ('d) Chest', 'injChest'),
          ('e) Stomach', 'injStomach'),
          ('f) Right Hand', 'injRightHand'),
          ('g) Left Hand', 'injLeftHand'),
          ('h) Right Leg', 'injRightLeg'),
          ('i) Left Leg', 'injLeftLeg'),
          ('j) Private part', 'injPrivatePart'),
          ('k) Back', 'injBack'),
        ].map((e) => field(e.$1, e.$2)),

        pageBreakLabel('Page 3'),
        wideField('10) Injuries Caused By Accidental/Violence:', 'injAccidentalViolence', lines: 2),
        field('11) Weapon / Means:', 'weaponMeans'),
        field('12) Dead Body Cool / Warm:', 'bodyCoolWarm'),
        field('13) Position Dead Body by Poisoning:', 'poisoningPosition'),
        wideField('14(a) Finger Print taken/not - Reason:', 'fingerprintReason'),
        wideField('14(b) Photo taken/not - Reason:', 'photoReason'),
        wideField('15) Dead Body sent to P.M. / not reason:', 'sentToPMReason'),
        field('(a) Hospital:', 'hospitalName'),
        pw.Wrap(
          spacing: 8,
          children: [
            field('(b) Name:', 'sentOfficerName'),
            field('B/No:', 'sentOfficerBNo'),
            field('P.S.:', 'sentOfficerPs'),
          ],
        ),

        pageBreakLabel('Page 4'),
        wideField('16) Opinion of Panchas and Police about Death:', 'opinionPanchas', lines: 3),
        wideField('17) More information if any:', 'moreInfo', lines: 2),
        pw.Wrap(
          spacing: 8,
          children: [
            field('18) Date:', 'panchanamaDate'),
            field('Time:', 'panchanamaTime'),
            field('To:', 'panchanamaTimeTo'),
          ],
        ),
        sectionTitle('19) Name of Panchas and Signature:'),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                children: [
                  field('1)', 'panch1'),
                  field('2)', 'panch2'),
                  field('3)', 'panch3'),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                children: [
                  field('Sig 1)', 'panch1Sig'),
                  field('Sig 2)', 'panch2Sig'),
                  field('Sig 3)', 'panch3Sig'),
                ],
              ),
            ),
          ],
        ),
        sectionTitle('Signature of Investigation Officer:'),
        pw.Wrap(
          spacing: 8,
          children: [
            field('Name:', 'ioName'),
            field('Rank:', 'ioRank'),
            field('No:', 'ioNo'),
          ],
        ),
        field('Posting and Address:', 'ioPosting'),
        ],

        if (showsSection('Civil Surgeon PM Report')) ...[
        // ── PM REFERRAL / CIVIL SURGEON ──
        pageBreakLabel('Civil Surgeon Report (1)'),
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text('Police Report to the Civil Surgeon', style: sectionStyle),
              mImg('cs_hdr'),
            ],
          ),
        ),
        pw.SizedBox(height: 8),
        csTable([
          csRow('1) Name of Deceased:', 'csNameDeceased'),
          csRow('2) Age:', 'csAge'),
          csRow('3) Married, Single, Widow or Widower:', 'csMaritalStatus'),
          csRow('4) Date and hour of death:', 'csDeathDate'),
          csRow('', 'csDeathTime'),
          csRow('5) Condition of body when found:', 'csBodyCondition', lines: 3),
          csRow('6) Day and hour body seen by officer:', 'csSeenDate'),
          csRow('', 'csSeenTime'),
          csRow('', 'csSeenOfficer'),
          csRow('7) Was body cold or warm?', 'csBodyColdWarm'),
          csRow('8) Recent illness?', 'csRecentIllness', lines: 2),
          csRow('9) Accident injury?', 'csAccidentInjury', lines: 2),
          csRow('10) Articles forwarded?', 'csArticlesForwarded', lines: 3),
          csRow('11) Cause of death / suspicions?', 'csDeathReason', lines: 3),
        ]),

        pageBreakLabel('Civil Surgeon Report (2)'),
        csTable([
          csRow('12) Suspicion of poisoning?', 'csPoisonSuspicion', lines: 3),
          csRow('13) Woman pregnant/recently delivered?', 'csWomanPregnancy', lines: 2),
          csRow('14) Abortion known/suspected?', 'csAbortion', lines: 2),
          csRow('15) Jury findings:', 'csJuryFindings', lines: 2),
          csRow('16) Remarks:', 'csRemarks', lines: 3),
        ]),
        pw.Wrap(
          spacing: 8,
          children: [
            field('IO Name:', 'csIoName'),
            field('Rank:', 'csIoRank'),
            field('No:', 'csIoNo'),
          ],
        ),
        field('Posting:', 'csIoPosting'),
        ],

        if (showsSection('Vinanti Arj')) ...[
        // ── VINANTI ARJ ──
        pageBreakLabel('विनंती अर्ज'),
        pw.Center(child: mImg('vinanti_title')),
        pw.Wrap(
          spacing: 8,
          children: [
            field('Police Station:', 'reqPs'),
            field('Date:', 'reqDate'),
          ],
        ),
        field('To:', 'reqTo'),
        field('From PS:', 'reqFromPs'),
        field('District:', 'reqDist'),
        pw.Wrap(
          spacing: 8,
          children: [
            field('Subject Name:', 'reqSubjectName'),
            field('PS:', 'reqSubjectPs'),
            field('Ta:', 'reqSubjectTa'),
          ],
        ),
        pw.Wrap(
          spacing: 8,
          children: [
            field('Marg Date:', 'reqMargDate'),
            field('Time:', 'reqMargTime'),
            field('PS:', 'reqMargPs'),
            field('Diary No:', 'reqMargDiaryNo'),
            field('Year:', 'reqMargYear'),
          ],
        ),
        field('Deceased Name:', 'reqMargName'),
        field('Ta:', 'reqMargTa'),
        field('He/She:', 'reqDeceasedHeShe'),
        field('Hospital:', 'reqHospitalName'),
        pw.Wrap(
          spacing: 8,
          children: [
            field('Admit Date:', 'reqAdmitDate'),
            field('Time:', 'reqAdmitTime'),
          ],
        ),
        wideField('Reason/Details:', 'reqReasonDetails', lines: 2),
        pw.Wrap(
          spacing: 8,
          children: [
            field('Death Date:', 'reqDeathDate'),
            field('Time:', 'reqDeathTime'),
          ],
        ),
        pw.Wrap(
          spacing: 8,
          children: [
            field('Haste Name:', 'reqHasteName'),
            field('PS:', 'reqHastePs'),
          ],
        ),
        ],

        if (showsSection('Relative Summons 179')) ...[
        // ── SUMMONS TO RELATIVES ──
        pageBreakLabel('नातेवाईकांना समन्स'),
        pw.Center(child: mImg('rel_title')),
        pw.Wrap(
          spacing: 8,
          children: [
            field('PS:', 'relPs'),
            field('Camp:', 'relCamp'),
            field('Date:', 'relDate'),
          ],
        ),
        wideField('Name:', 'relToName', lines: 2),
        pw.Wrap(
          spacing: 8,
          children: [
            field('We:', 'relWeName'),
            field('PS:', 'relPsName'),
            field('Diary:', 'relCrDiaryNo'),
            field('/20', 'relCrYear'),
            field('Section:', 'relActSec'),
          ],
        ),
        field('Deceased:', 'relDeceasedName'),
        pw.Wrap(spacing: 8, children: [field('Ta:', 'relTa'), field('Dist:', 'relDist')]),
        pw.Wrap(
          spacing: 8,
          children: [
            field('Sig 1:', 'relSig1'),
            field('Sig 2:', 'relSig2'),
            field('Sig 3:', 'relSig3'),
            field('Sig 4:', 'relSig4'),
          ],
        ),
        ],

        if (showsSection('Pancha Summons 195')) ...[
        // ── SUMMONS TO PANCHAS ──
        pageBreakLabel('पंचांचा समन्स'),
        pw.Center(child: mImg('pan_title')),
        pw.Wrap(
          spacing: 8,
          children: [
            field('PS:', 'panPs'),
            field('Camp:', 'panCamp'),
            field('Date:', 'panDate'),
          ],
        ),
        wideField('Name:', 'panToName', lines: 2),
        pw.Wrap(
          spacing: 8,
          children: [
            field('We:', 'panWeName'),
            field('PS:', 'panPsName'),
            field('Diary:', 'panCrDiaryNo'),
            field('/20', 'panCrYear'),
            field('Section:', 'panActSec'),
          ],
        ),
        field('Deceased:', 'panDeceasedName'),
        pw.Wrap(spacing: 8, children: [field('Ta:', 'panTa'), field('Dist:', 'panDist')]),
        pw.Wrap(
          spacing: 8,
          children: [
            field('Sig 1:', 'panSig1'),
            field('Sig 2:', 'panSig2'),
            field('Sig 3:', 'panSig3'),
            field('Sig 4:', 'panSig4'),
          ],
        ),
        ],

        if (showsSection('Marananveshan Panchanama')) ...[
        // ── MARAN ANVESHAN ──
        pageBreakLabel('मरणान्वेषण पंचनामा'),
        pw.Center(child: mImg('mar_title')),
        pw.Wrap(
          spacing: 8,
          children: [
            field('Place:', 'marThikan'),
            field('Date:', 'marDate'),
            field('Time:', 'marTime'),
          ],
        ),
        wideField('1) Panch Name & Address:', 'marPanchNameAddress', lines: 2),
        pw.Wrap(spacing: 8, children: [field('2) PS:', 'marPs'), field('Dist:', 'marDist')]),
        field('3) Diary No:', 'marDiaryNo'),
        field('4) Act & Section:', 'marActSec'),
        field('5) IO Name/Rank:', 'marIoDetails'),
        field('6) Complainant:', 'marComplainantName'),
        field('7) Deceased Name & Address:', 'marDeceasedNameAddress'),
        field('8) Shown/Identified by:', 'marShownByName'),
        wideField('9) Place description:', 'marThikanDescription', lines: 2),
        wideField('10) Body condition:', 'marBodyCondition', lines: 2),
        wideField('11) Clothes description:', 'marBodyClothes', lines: 2),
        wideField('12) Ornaments & belongings:', 'marBodyOrnaments', lines: 2),

        // ── MARAN ANVESHAN cont. (Folder 09 p2 / 10 p1) ──
        pageBreakLabel('मरणान्वेषण (cont.)'),
        wideField('13) Injuries on body:', 'mar13Injuries', lines: 3),
        wideField('14) Other marks/samples:', 'mar14OtherMarks', lines: 3),
        wideField('15) Ornaments disposal:', 'mar15OrnamentsDisposal', lines: 2),
        wideField('16) Opinion of Panch & IO:', 'mar16Opinion', lines: 2),
        wideField('17) Body disposal:', 'mar17BodyDisposal', lines: 2),
        field('18) Date & time completed:', 'mar18DateTime'),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                children: [
                  field('Panch Sig 1:', 'mar11Panch1'),
                  field('Panch Sig 2:', 'mar11Panch2'),
                  field('Panch Sig 3:', 'mar11Panch3'),
                  field('Panch Sig 4:', 'mar11Panch4'),
                  field('Copy to MO:', 'mar11CopyTo'),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                children: [
                  field('IO Name:', 'mar11IoName'),
                  field('Rank:', 'mar11IoRank'),
                  field('PS:', 'mar11IoPs'),
                ],
              ),
            ),
          ],
        ),
        ],

        if (showsSection('14 Kalmi Form')) ...[
        // ── 14-KALAMI FORM ──
        pageBreakLabel('१४ कलमी फॉर्म (1)'),
        pw.Center(child: mImg('kal14_title')),
        wideField('1) Name & Age:', 'kal14NameAge'),
        wideField('2) Address:', 'kal14Address', lines: 2),
        pw.Wrap(spacing: 8, children: [field('3) From:', 'kal14ShavFrom'), field('To:', 'kal14ShavTo')]),
        wideField('4) Mother name:', 'kal14AaiName', lines: 2),
        wideField('5) Father name:', 'kal14BaapName', lines: 2),
        field('6) Religion:', 'kal14Dharm'),
        field('7) Occupation:', 'kal14Vyavsay'),
        field('Cigarette:', 'kal14Cigarette'),
        field('Days:', 'kal14CigaretteDays'),
        field('Alcohol:', 'kal14Daru'),
        field('Days:', 'kal14DaruDays'),
        field('Tobacco:', 'kal14Tambakhu'),
        field('Days:', 'kal14TambakhuDays'),
        field('Pan Masala:', 'kal14PanMasala'),
        field('Days:', 'kal14PanMasalaDays'),

        pageBreakLabel('१४ कलमी फॉर्म (2)'),
        field('11(a) Vehicle:', 'kal14VehicleName'),
        field('11(b) Driver/Passenger:', 'kal14DriverPass'),
        field('11(c) Pedestrian:', 'kal14Pedestrian'),
        field('11(d) How accident:', 'kal14AccidentHow'),
        field('11(e) Date/Time:', 'kal14AccidentDateTime'),
        wideField('12) Fall info:', 'kal14FallInfo', lines: 2),
        field('13(a) Pregnant months:', 'kal14PregnantMonths'),
        field('13(b) Delivered/abortion:', 'kal14DeliveredAbortion'),
        field('13(c) Days:', 'kal14PregnantDays'),
        wideField('14) Identifier name & address:', 'kal14IdentifierName', lines: 2),
        pw.Wrap(
          spacing: 8,
          children: [
            field('IO Name:', 'kal14IoName'),
            field('Rank:', 'kal14IoRank'),
            field('PS:', 'kal14IoPs'),
          ],
        ),
        ],

        if (showsSection('Dead Body Handover')) ...[
        // ── BODY CUSTODY RECEIPT ──
        pageBreakLabel('प्रेत ताबा पावती'),
        pw.Center(child: mImg('ptp_title')),
        pw.Wrap(
          spacing: 8,
          children: [
            field('PS:', 'ptpPs'),
            field('Camp:', 'ptpCamp'),
            field('Date:', 'ptpDate'),
          ],
        ),
        pw.Wrap(
          spacing: 8,
          children: [
            field('Receiver:', 'ptpReceiverName'),
            field('R/O:', 'ptpReceiverRa'),
            field('Ta:', 'ptpReceiverTa'),
            field('Dist:', 'ptpReceiverDist'),
            field('Mo:', 'ptpMoNo'),
          ],
        ),
        field('Receipt Date:', 'ptpReceiptDate'),
        pw.Wrap(
          spacing: 8,
          children: [
            field('Deceased:', 'ptpDeceasedName'),
            field('R/O:', 'ptpDeceasedRa'),
            field('Dist:', 'ptpDeceasedDist'),
          ],
        ),
        field('Receiver Signature:', 'ptpReceiverSig'),
        pw.Wrap(
          spacing: 8,
          children: [
            field('IO Name:', 'ptpIoName'),
            field('Rank:', 'ptpIoRank'),
            field('PS:', 'ptpIoPs'),
          ],
        ),
        ],

        if (showsSection('Duty Pass')) ...[
        // ── DUTY PASS ──
        pageBreakLabel('ड्युटी पास'),
        pw.Center(child: mImg('dp_title')),
        pw.Wrap(
          spacing: 8,
          children: [
            field('PS:', 'dpPs'),
            field('Camp:', 'dpCamp'),
            field('Date:', 'dpDate'),
          ],
        ),
        field('Officer Name:', 'dpAmaldaarName'),
        field('Duty PS:', 'dpDutyPs'),
        field('Duty District:', 'dpDutyDist'),
        field('Duty Date/Time:', 'dpDutyDateTime'),
        pw.Wrap(
          spacing: 8,
          children: [
            field('Marg/Diary No:', 'dpMargNo'),
            field('/20', 'dpMargYear'),
            field('Section:', 'dpKalam'),
          ],
        ),
        field('Deceased:', 'dpDeceasedName'),
        pw.Wrap(
          spacing: 8,
          children: [
            field('R/O:', 'dpDeceasedRa'),
            field('Ta:', 'dpDeceasedTa'),
            field('Dist:', 'dpDeceasedDist'),
          ],
        ),
        field('Medical Officer:', 'dpMedOfficerName'),
        field('Officer Signature:', 'dpAmaldaarSig'),
        pw.Wrap(
          spacing: 8,
          children: [
            field('IO Name:', 'dpIoName'),
            field('Rank:', 'dpIoRank'),
            field('PS:', 'dpIoPs'),
          ],
        ),
        ],
      ],
    ),
  );

  return pdf.save();
}

Future<MarathiImageCache> _preRenderAllMarathi(Map<String, dynamic> doc) async {
  final cache = MarathiImageCache();
  final labelStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 9,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  final valueStyle = GoogleFonts.notoSansDevanagari(
    fontSize: 9,
    color: Colors.blue.shade900,
  );

  await GoogleFonts.pendingFonts();

  Future<void> lbl(String key, String text) async {
    if (containsDevanagari(text)) {
      await cache.add(key, text, labelStyle, maxWidth: 500);
    }
  }

  Future<void> val(String key, dynamic v) async {
    final text = v?.toString().trim() ?? '';
    if (containsDevanagari(text)) {
      await cache.add(key, text, valueStyle, maxWidth: 480);
    }
  }

  await lbl('hdr_m1', 'मरणोत्तर पंचनामा');
  await lbl('hdr_m2', '( भारतीय नागरीक सुरक्षा संहिता २०२३ कलम १९४ अन्वये. )');
  await lbl('cs_hdr', 'शवविच्छेदन परिक्षेसाठी पाठविलेल्या प्रेताबरोबर जिल्हा शल्यचिकीत्सकाकडे पाठवायाचा पोलीस अहवाल');
  await lbl('vinanti_title', 'विनंती अर्ज');
  await lbl('rel_title', 'नातेवाईकांना समन्स');
  await lbl('pan_title', 'पंचांचा समन्स');
  await lbl('mar_title', 'मरणान्वेषण पंचनामा');
  await lbl('kal14_title', '१४ कलमी फॉर्म');
  await lbl('ptp_title', 'प्रेत ताबा पावती');
  await lbl('dp_title', 'ड्युटी पास');

  const keys = [
    'dist', 'ps', 'year', 'firNo', 'actSections', 'deadBodyFoundPlace', 'foundPlace',
    'foundDate', 'foundTime', 'shownBy', 'identifiedBy', 'gender', 'married', 'age',
    'deathDate', 'deathTime', 'positionOfBody', 'nameAddressDeceased',
    'injHead', 'injFace', 'injNeck', 'injChest', 'injStomach', 'injRightHand', 'injLeftHand',
    'injRightLeg', 'injLeftLeg', 'injPrivatePart', 'injBack', 'injAccidentalViolence',
    'weaponMeans', 'bodyCoolWarm', 'poisoningPosition', 'fingerprintReason', 'photoReason',
    'sentToPMReason', 'hospitalName', 'sentOfficerName', 'sentOfficerBNo', 'sentOfficerPs',
    'opinionPanchas', 'moreInfo', 'panchanamaDate', 'panchanamaTime', 'panchanamaTimeTo',
    'panch1', 'panch1Sig', 'panch2', 'panch2Sig', 'panch3', 'panch3Sig',
    'ioName', 'ioRank', 'ioNo', 'ioPosting',
    'csNameDeceased', 'csAge', 'csMaritalStatus', 'csDeathDate', 'csDeathTime',
    'csBodyCondition', 'csSeenDate', 'csSeenTime', 'csSeenOfficer', 'csBodyColdWarm',
    'csRecentIllness', 'csAccidentInjury', 'csArticlesForwarded', 'csDeathReason',
    'csPoisonSuspicion', 'csWomanPregnancy', 'csAbortion', 'csJuryFindings', 'csRemarks',
    'csIoName', 'csIoRank', 'csIoNo', 'csIoPosting',
    'reqPs', 'reqDate', 'reqTo', 'reqFromPs', 'reqDist', 'reqSubjectName', 'reqSubjectPs', 'reqSubjectTa',
    'reqMargDate', 'reqMargTime', 'reqMargPs', 'reqMargDiaryNo', 'reqMargYear', 'reqMargName',
    'reqMargTa', 'reqDeceasedHeShe', 'reqHospitalName', 'reqAdmitDate', 'reqAdmitTime',
    'reqReasonDetails', 'reqDeathDate', 'reqDeathTime', 'reqHasteName', 'reqHastePs',
    'relPs', 'relCamp', 'relDate', 'relToName', 'relWeName', 'relPsName', 'relCrDiaryNo',
    'relCrYear', 'relActSec', 'relDeceasedName', 'relTa', 'relDist',
    'relSig1', 'relSig2', 'relSig3', 'relSig4',
    'panPs', 'panCamp', 'panDate', 'panToName', 'panWeName', 'panPsName', 'panCrDiaryNo',
    'panCrYear', 'panActSec', 'panDeceasedName', 'panTa', 'panDist',
    'panSig1', 'panSig2', 'panSig3', 'panSig4',
    'marThikan', 'marDate', 'marTime', 'marPanchNameAddress', 'marPs', 'marDist',
    'marDiaryNo', 'marActSec', 'marIoDetails', 'marComplainantName', 'marDeceasedNameAddress',
    'marShownByName', 'marThikanDescription', 'marBodyCondition', 'marBodyClothes',
    'marBodyOrnaments', 'mar13Injuries', 'mar14OtherMarks', 'mar15OrnamentsDisposal',
    'mar16Opinion', 'mar17BodyDisposal', 'mar18DateTime', 'mar11Panch1', 'mar11Panch2',
    'mar11Panch3', 'mar11Panch4', 'mar11IoName', 'mar11IoRank', 'mar11IoPs', 'mar11CopyTo',
    'kal14NameAge', 'kal14Address', 'kal14ShavFrom', 'kal14ShavTo', 'kal14AaiName',
    'kal14BaapName', 'kal14Dharm', 'kal14Vyavsay', 'kal14CigaretteDays', 'kal14DaruDays',
    'kal14TambakhuDays', 'kal14PanMasalaDays', 'kal14VehicleName', 'kal14DriverPass',
    'kal14Pedestrian', 'kal14AccidentHow', 'kal14AccidentDateTime', 'kal14FallInfo',
    'kal14PregnantMonths', 'kal14DeliveredAbortion', 'kal14PregnantDays', 'kal14IdentifierName',
    'kal14IoName', 'kal14IoRank', 'kal14IoPs',
    'ptpPs', 'ptpCamp', 'ptpDate', 'ptpReceiverName', 'ptpReceiverRa', 'ptpReceiverTa',
    'ptpReceiverDist', 'ptpMoNo', 'ptpReceiptDate', 'ptpDeceasedName', 'ptpDeceasedRa',
    'ptpDeceasedDist', 'ptpReceiverSig', 'ptpIoName', 'ptpIoRank', 'ptpIoPs',
    'dpPs', 'dpCamp', 'dpDate', 'dpAmaldaarName', 'dpDutyPs', 'dpDutyDist', 'dpDutyDateTime',
    'dpMargNo', 'dpMargYear', 'dpKalam', 'dpDeceasedName', 'dpDeceasedRa', 'dpDeceasedTa',
    'dpDeceasedDist', 'dpMedOfficerName', 'dpAmaldaarSig', 'dpIoName', 'dpIoRank', 'dpIoPs',
  ];

  for (final k in keys) {
    await val('val_$k', doc[k]);
  }

  return cache;
}
