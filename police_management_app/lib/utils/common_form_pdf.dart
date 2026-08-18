// lib/utils/common_form_pdf.dart
// Universal PDF for Khakhi Diary: CommonForm 17 sections + arbitrary extraMap.
// No screen imports, no Firebase.

import 'dart:typed_data';

// ignore_for_file: unused_shown_name
// Imports match project spec (`show BuildContext, TimeOfDay`); TimeOfDay is unused in this utility.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show BuildContext, TimeOfDay;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'pdf_unicode_fonts.dart';

// ══════════════════════════════════════════════════════════════════════════════
// COLORS
// ══════════════════════════════════════════════════════════════════════════════

const _dark = PdfColor.fromInt(0xFF0f172a);
const _teal = PdfColor.fromInt(0xFF0ea5e9);
const _green = PdfColor.fromInt(0xFF10b981);
const _red = PdfColor.fromInt(0xFFef4444);
const _amber = PdfColor.fromInt(0xFFf59e0b);
const _sec = PdfColor.fromInt(0xFF64748b);
const _muted = PdfColor.fromInt(0xFF94a3b8);
const _bg = PdfColor.fromInt(0xFFf8fafc);
const _border = PdfColor.fromInt(0xFFe2e8f0);
const _white = PdfColors.white;

// ══════════════════════════════════════════════════════════════════════════════
// MAIN ENTRY POINTS
// ══════════════════════════════════════════════════════════════════════════════

/// Preview + share PDF. Call from any screen.
/// [commonMap] - CommonFormState.buildDocumentMap()
/// [extraMap] - Any extra fields from your form screen (optional, pass {} if none)
/// [formTitle] - e.g. 'CR FORM', 'AD FORM', 'VI FORM', 'DISPOSAL FORM'
/// [formSubtitle] - e.g. 'Crime Registration - Maharashtra Police'
Future<void> previewFormPdf(
  BuildContext context,
  Map<String, dynamic> commonMap, {
  Map<String, dynamic> extraMap = const {},
  String formTitle = 'CASE FORM',
  String formSubtitle = 'Khakhi Diary - Maharashtra Police',
}) async {
  if (!context.mounted) return;
  final bytes = await generateFormPdf(
    commonMap,
    extraMap: extraMap,
    formTitle: formTitle,
    formSubtitle: formSubtitle,
  );
  if (!context.mounted) return;
  final fileName =
      '${formTitle.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
  try {
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } else {
      await Printing.layoutPdf(onLayout: (_) async => bytes, name: fileName);
    }
  } catch (_) {
    // Fallback path if browser print popup is blocked or layoutPdf fails.
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }
}

/// Returns raw PDF bytes. Save to file or share.
Future<Uint8List> generateFormPdf(
  Map<String, dynamic> commonMap, {
  Map<String, dynamic> extraMap = const {},
  String formTitle = 'CASE FORM',
  String formSubtitle = 'Khakhi Diary - Maharashtra Police',
}) async {
  pw.Document pdf;
  try {
    pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: await PdfGoogleFonts.interRegular(),
        bold: await PdfGoogleFonts.interBold(),
        italic: await PdfGoogleFonts.interItalic(),
        boldItalic: await PdfGoogleFonts.interBoldItalic(),
      ),
    );
  } catch (_) {
    // Web can fail fetching remote Google font files (network/CORS/ad-block).
    // Fallback to embedded unicode-capable OpenSans theme.
    final unicodeTheme = await PdfUnicodeFonts.openSansTheme();
    pdf = pw.Document(theme: unicodeTheme);
  }

  pdf.addPage(
    pw.MultiPage(
      maxPages: 1000,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      header: (ctx) => ctx.pageNumber == 1
          ? _header(ctx, formTitle, formSubtitle)
          : pw.SizedBox(),
      footer: (ctx) => _footer(ctx),
      build: (_) => _buildAll(commonMap, extraMap),
    ),
  );

  return pdf.save();
}

// ══════════════════════════════════════════════════════════════════════════════
// HEADER & FOOTER
// ══════════════════════════════════════════════════════════════════════════════

pw.Widget _header(pw.Context ctx, String title, String subtitle) =>
    pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: pw.BoxDecoration(
        color: _dark,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _safeText(title),
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: _white,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                _safeText(subtitle),
                style: pw.TextStyle(
                  fontSize: 8,
                  color: _teal,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Text(
            'Generated: ${_now()}',
            style: pw.TextStyle(fontSize: 8, color: _muted),
          ),
        ],
      ),
    );

pw.Widget _footer(pw.Context ctx) => pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: _border, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'KHAKHI DIARY - Maharashtra Police',
            style: pw.TextStyle(fontSize: 7, color: _muted),
          ),
          pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: pw.TextStyle(fontSize: 7, color: _muted),
          ),
        ],
      ),
    );

// ══════════════════════════════════════════════════════════════════════════════
// MASTER CONTENT BUILDER
// ══════════════════════════════════════════════════════════════════════════════

List<pw.Widget> _buildAll(Map<String, dynamic> m, Map<String, dynamic> extra) {
  final sections = <pw.Widget>[];
  final isUnknown = m['isUnknownUntraced'] == true;
  final extraMap = Map<String, dynamic>.from(extra);

  // ── §1 Crime Registration ─────────────────────────────────────────────────
  sections.add(
    _card(
      1,
      'CRIME REGISTRATION INFO',
      _teal,
      _grid2([
        _f('Cr. No.', _v(m['crNo'])),
        _f('Registered Date', _v(m['regDate'])),
        _f('Unknown / Untraced', isUnknown ? 'Yes' : 'No'),
        _f(
          'FIR Copy',
          _v(m['firCopyPath'], or: 'Not uploaded'),
          full: true,
        ),
      ]),
    ),
  );

  // ── §2 Acts & Sections Filed ───────────────────────────────────────────────
  final charges = m['charges'] as Map? ?? {};
  sections.add(
    _card(
      2,
      'ACTS & SECTIONS FILED',
      _teal,
      charges.isEmpty
          ? _empty('No charges added.')
          : pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: charges.entries.toList().asMap().entries.map((e) {
                final chargeNum = e.key + 1;
                final data = e.value.value as Map? ?? {};
                final act = _v(data['act']);
                final secs = (data['sections'] as List?)
                        ?.map((s) => s.toString())
                        .toList() ??
                    [];
                return _chargeBlock(chargeNum, act, secs);
              }).toList(),
            ),
    ),
  );

  // ── §3 Crime Spot ─────────────────────────────────────────────────────────
  sections.add(
    _card(
      3,
      'CRIME SPOT',
      _teal,
      _grid2([
        _f('Village / Town', _v(m['spotVillage'])),
        _f('Area Name', _v(m['spotArea'])),
        _f('Full Address', _v(m['spotAddress']), full: true),
      ]),
    ),
  );

  // ── MODULE EXTRA SECTIONS (auto between Crime Spot and Complainant) ───────
  // Convention: any form-specific payload under keys ending with `_extra`
  // is auto-inserted here for all present/future modules.
  final middleExtras = <String, dynamic>{};
  for (final e in extraMap.entries.toList()) {
    if (e.key.toLowerCase().endsWith('_extra')) {
      middleExtras[e.key] = e.value;
      extraMap.remove(e.key);
    }
  }
  if (middleExtras.isNotEmpty) {
    sections.add(_extraSection(middleExtras));
  }

  // ── §4 Complainant KYC ────────────────────────────────────────────────────
  final comp = m['complainant'] as Map? ?? {};
  sections.add(
    _card(
      4,
      'COMPLAINANT KYC',
      _teal,
      comp.isEmpty
          ? _empty('No complainant data.')
          : _grid2([
              _f('Name', _v(comp['name'])),
              _f('Age', _v(comp['age'])),
              _f('Gender', _v(comp['gender'])),
              _f('Occupation', _v(comp['occ'])),
              _f('Mobile', _v(comp['mobile'])),
              _f('Aadhaar', _v(comp['aadhaar'])),
              _f('Religion', _v(comp['religion'])),
              _f('Caste', _v(comp['caste'])),
              _f('PAN Number', _v(comp['pan'])),
            ]),
    ),
  );

  // ── §5 Accused Details ────────────────────────────────────────────────────
  final accusedList = (m['accused'] as List?) ?? [];
  sections.add(
    _card(
      5,
      'ACCUSED DETAILS',
      _teal,
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (isUnknown) _badge('Unknown / Untraced', _amber),
          if (!isUnknown)
            accusedList.isEmpty
                ? _empty('No accused added.')
                : pw.Column(
                    children: accusedList
                        .asMap()
                        .entries
                        .map(
                          (e) => _personBlock(
                            'Accused #${e.key + 1}',
                            Map<String, dynamic>.from(e.value as Map),
                          ),
                        )
                        .toList(),
                  ),
        ],
      ),
    ),
  );

  // ── §6 Suspected Accused ──────────────────────────────────────────────────
  final suspectedList = (m['suspectedAccused'] as List?) ?? [];
  sections.add(
    _card(
      6,
      'SUSPECTED ACCUSED',
      _teal,
      isUnknown
          ? _badge('Hidden - Unknown/Untraced ON', _muted)
          : suspectedList.isEmpty
              ? _empty('No suspected accused added.')
              : pw.Column(
                  children: suspectedList
                      .asMap()
                      .entries
                      .map(
                        (e) => _personBlock(
                          'Suspected #${e.key + 1}',
                          Map<String, dynamic>.from(e.value as Map),
                        ),
                      )
                      .toList(),
                ),
    ),
  );

  // ── §7 Unidentified (always printed — mirrors buildDocumentMap['unidentified'])
  final u = m['unidentified'] as Map? ?? {};
  sections.add(
    _card(
      7,
      'UNIDENTIFIED CRIMINAL DESCRIPTION',
      _amber,
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (!isUnknown)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                'Known accused mode - unidentified block still reflects stored values if any.',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: _muted,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            )
          else
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: _badge(
                  'Unknown / Untraced - fill all applicable fields', _amber),
            ),
          _grid2([
            _f('Gender', _v(u['gender'])),
            _f('Approx Age', _v(u['approxAge'])),
            _f('Skin Color', _v(u['skinColor'])),
            _f('Approx Height', _v(u['approxHeight'])),
            _f('Mobile (if known)', _v(u['mobile'])),
            _f('Occupation (possible)', _v(u['occupation'])),
            _f('Last Known Address', _v(u['lastKnownAddress']), full: true),
            _f('Other Physical Markers', _v(u['otherPhysicalMarkers']),
                full: true),
          ]),
        ],
      ),
    ),
  );

  // ── §8 Case Responsibility ────────────────────────────────────────────────
  final cr8 = m['caseResponsibility'] as Map? ?? {};
  sections.add(
    _card(
      8,
      'CASE RESPONSIBILITY',
      _teal,
      _grid2([
        _f('IO Designation', _v(cr8['ioDesig'])),
        _f('IO Name', _v(cr8['ioName'])),
        _f('Reg. By Desig.', _v(cr8['regDesig'])),
        _f('Registrar Name', _v(cr8['regName'])),
        _f('CCTV', _v(cr8['cctvValue'], or: 'Not set')),
        _f('CCTV Date & Time', _v(cr8['cctvDateTime'])),
      ]),
    ),
  );

  // ── §9 Arrest & Release ───────────────────────────────────────────────────
  final arrests = (m['arrestRelease'] as List?) ?? [];
  sections.add(
    _card(
      9,
      'ARREST & RELEASE STATUS',
      _teal,
      arrests.isEmpty
          ? _empty('No arrest records. Add accused names first.')
          : pw.Column(
              children: arrests.map((r) {
                final row = r as Map;
                return _subCard(
                  _grid2([
                    _f('Name', _v(row['accusedName'])),
                    _f('Arrest Date/Time', _v(row['arrestDt'])),
                    _f('Release Type', _v(row['releaseType'])),
                    _f('Release Date', _v(row['releaseDt'])),
                  ]),
                );
              }).toList(),
            ),
    ),
  );

  // ── §10 Procedural Details ────────────────────────────────────────────────
  final procChecks = (m['proceduralChecks'] as Map?) ?? {};
  final procDates = (m['proceduralDates'] as Map?) ?? {};
  const procLabels = {
    'chkMemo': 'Memorandum Panchanama',
    'chkPanchSpot': 'Panchanama Spot',
    'chkInquest': 'Inquest',
    'chkIdent': 'Identification',
    'chkSearch': 'Search',
    'chkPersSearch': 'Personal Search',
    'chkIdParade': 'Identification Parade',
    'chkExhumation': 'Exhumation',
  };
  sections.add(
    _card(
      10,
      'PROCEDURAL DETAILS',
      _teal,
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          ...procLabels.entries.map((e) {
            final on = procChecks[e.key] == true;
            final rawDate = procDates[e.key]?.toString().trim() ?? '';
            final dateLine = rawDate.isEmpty ? '-' : rawDate;
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _checkbox(on),
                      pw.SizedBox(width: 6),
                      pw.Expanded(
                        child: pw.Text(
                          '${e.value} (${on ? "checked" : "unchecked"})',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: on ? _dark : _muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 18, top: 2),
                    child: pw.Text(
                      'Date (proceduralDates.${e.key}): $dateLine',
                      style: pw.TextStyle(fontSize: 9, color: _sec),
                    ),
                  ),
                ],
              ),
            );
          }),
          pw.SizedBox(height: 6),
          _grid2([_f('E-shaksh', _v(m['eshakshValue'], or: 'Not set'))]),
        ],
      ),
    ),
  );

  // ── §11 Seizure Records ────────────────────────────────────────────────────
  final seizures = (m['seizures'] as List?) ?? [];
  sections.add(
    _card(
      11,
      'SEIZURE RECORDS',
      _teal,
      seizures.isEmpty
          ? _empty('No seizure records added.')
          : pw.Column(
              children: seizures.asMap().entries.map((e) {
                final s = e.value as Map;
                return _subCard(
                  _grid2([
                    _f('Property Description', _v(s['desc']), full: true),
                    _f('Seized From', _v(s['fromWhom'], or: '-')),
                    _f('Other Name', _v(s['otherName'])),
                  ]),
                );
              }).toList(),
            ),
    ),
  );

  // ── §12 Technical & Custody ────────────────────────────────────────────────
  sections.add(
    _card(
      12,
      'TECHNICAL & CUSTODY',
      _teal,
      _grid2([
        _f('CDR Sent Date', _v(m['cdrSent'])),
        _f('CDR Received Date', _v(m['cdrRecv'])),
        _f('PCR (Days)', _v(m['pcrDays'])),
        _f('MCR (Days)', _v(m['mcrDays'])),
      ]),
    ),
  );

  // ── §13 Preventive & Bonds ─────────────────────────────────────────────────
  final prev = m['preventive'] as Map? ?? {};
  sections.add(
    _card(
      13,
      'PREVENTIVE & BONDS',
      _teal,
      _grid2([
        _f('Preventive Action', _v(prev['action'], or: 'Not set')),
        _f('Outward Number', _v(prev['outwardNumber'])),
        _f('Bond Date', _v(prev['bondDate'])),
        _f('Bond Cancellation Date', _v(prev['bondCancellation'])),
      ]),
    ),
  );

  // ── §14 Discharge Status ───────────────────────────────────────────────────
  final discharge = (m['dischargeByAccused'] as Map?) ?? {};
  sections.add(
    _card(
      14,
      'DISCHARGE STATUS',
      _teal,
      discharge.isEmpty
          ? _empty('No discharge data. Add accused names first.')
          : pw.Column(
              children: discharge.entries.map((e) {
                final discharged = e.value == true;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    children: [
                      _checkbox(discharged, color: _green),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        '${e.key} - ${discharged ? "Discharged" : "Not discharged"}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: discharged ? _dark : _muted,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    ),
  );

  // ── §15 Court Filing ───────────────────────────────────────────────────────
  final court = m['court'] as Map? ?? {};
  sections.add(
    _card(
      15,
      'COURT FILING',
      _teal,
      _grid2([
        _f('Charge Sheet No.', _v(court['chargeSheetNumber'])),
        _f('CC / ST Number', _v(court['ccStNumber'])),
        _f('Final Summary', _v(court['finalSummary'], or: 'Not set')),
        _f('Quashed by High Court', _v(court['quashedHighCourt'])),
      ]),
    ),
  );

  // ── §16 Final Verdict ──────────────────────────────────────────────────────
  final verdict = m['verdict'] as Map? ?? {};
  final acquitted =
      (verdict['acquitted'] as List?)?.map((x) => x.toString()).toList() ?? [];
  final convicted =
      (verdict['convicted'] as List?)?.map((x) => x.toString()).toList() ?? [];
  sections.add(
    _card(
      16,
      'FINAL VERDICT',
      _teal,
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: _verdictCol('✓ ACQUITTED', acquitted, _green),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: _verdictCol('✗ CONVICTED', convicted, _red),
          ),
        ],
      ),
    ),
  );

  // ── §17 Scrutiny Pipeline ─────────────────────────────────────────────────
  final sc = m['scrutiny'] as Map? ?? {};
  sections.add(
    _card(
      17,
      'CASE SCRUTINY PIPELINE',
      _teal,
      pw.Column(
        children: [
          _scrutinyStep(
            1,
            'SDPO / ACP Approval',
            true,
            send: _v(sc['sdpoSend']),
            grant: _v(sc['sdpoGrant']),
          ),
          _scrutinyStep(
            2,
            'APP Scrutiny',
            sc['stepAppActive'] == true,
            send: _v(sc['appSend']),
            grant: _v(sc['appGrant']),
            lockedMsg: 'Unlocks when SDPO Send Date is filled',
          ),
          _scrutinyStep(
            3,
            'Addl SP / DCP / Addl CP',
            sc['stepDcpActive'] == true,
            send: _v(sc['dcpSend']),
            grant: _v(sc['dcpGrant']),
            lockedMsg: 'Unlocks when APP Send Date is filled',
            isLast: true,
          ),
          pw.SizedBox(height: 10),
          _grid2([
            _f(
              'stepAppActive (scrutiny)',
              sc['stepAppActive'] == true ? 'Yes' : 'No',
            ),
            _f(
              'stepDcpActive (scrutiny)',
              sc['stepDcpActive'] == true ? 'Yes' : 'No',
            ),
          ]),
        ],
      ),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // EXTRA FIELDS — 100% DYNAMIC
  // ══════════════════════════════════════════════════════════════════════════
  if (extraMap.isNotEmpty) {
    sections.add(_extraSection(extraMap));
  }

  return sections;
}

// ══════════════════════════════════════════════════════════════════════════════
// EXTRA SECTION BUILDER — reads ANY map structure
// ══════════════════════════════════════════════════════════════════════════════

pw.Widget _extraSection(Map<String, dynamic> extra) {
  final flatFields = <MapEntry<String, dynamic>>[];
  final subSections = <MapEntry<String, dynamic>>[];

  for (final e in extra.entries) {
    if (e.value is Map) {
      subSections.add(e);
    } else {
      flatFields.add(e);
    }
  }

  final widgets = <pw.Widget>[];

  if (flatFields.isNotEmpty) {
    widgets.add(
      _card(
        0,
        'FORM SPECIFIC FIELDS',
        _amber,
        _grid2(
          flatFields
              .map((e) => _f(_labelify(e.key), _anyToString(e.value)))
              .toList(),
        ),
      ),
    );
  }

  for (final e in subSections) {
    if (e.key == 'kidnapping_extra' && e.value is Map) {
      widgets.addAll(
        _kidnappingExtraCards(Map<dynamic, dynamic>.from(e.value as Map)),
      );
      continue;
    }

    final title = _labelify(e.key).toUpperCase();
    final mapValue = Map<dynamic, dynamic>.from(e.value as Map);

    // Prevent TooManyPagesException by splitting large flat maps
    // (e.g. kidnapping_extra) into smaller cards.
    final isFlat = mapValue.values.every((v) => v is! Map && v is! List);
    if (isFlat) {
      final fields = mapValue.entries
          .map((entry) =>
              _f(_labelify(entry.key.toString()), _anyToString(entry.value)))
          .toList();
      const chunkSize = 14;
      for (var i = 0; i < fields.length; i += chunkSize) {
        final chunk = fields.sublist(
          i,
          (i + chunkSize) > fields.length ? fields.length : (i + chunkSize),
        );
        widgets.add(
          _card(
            0,
            i == 0 ? title : '$title (CONT.)',
            _amber,
            _grid2(chunk),
          ),
        );
      }
      continue;
    }

    widgets.add(
      _card(
        0,
        title,
        _amber,
        _buildAnyMap(mapValue),
      ),
    );
  }

  return pw.Column(children: widgets);
}

List<pw.Widget> _kidnappingExtraCards(Map<dynamic, dynamic> data) {
  const ordered = <MapEntry<String, String>>[
    // 1) Kidnapped Person KYC
    MapEntry('kidnappedName', 'Kidnapped Name'),
    MapEntry('kidnappedAge', 'Kidnapped Age'),
    MapEntry('kidnappedGender', 'Kidnapped Gender'),
    MapEntry('kidnappedOccupation', 'Kidnapped Occupation'),
    MapEntry('kidnappedMobile', 'Kidnapped Mobile'),
    MapEntry('kidnappedAadhaar', 'Kidnapped Aadhaar'),
    MapEntry('kidnappedReligion', 'Kidnapped Religion'),
    MapEntry('kidnappedCaste', 'Kidnapped Caste'),
    MapEntry('kidnappedRelation', 'Relation with Complainant'),

    // 2) Found Status
    MapEntry('personFound', 'Person Found'),
    MapEntry('foundDate', 'Found Date'),
    MapEntry('foundTime', 'Found Time'),
    MapEntry('foundSdNo', 'SD No. / Station Diary No.'),
    MapEntry('statementRecorded', 'Statement Recorded'),
    MapEntry('statementDate', 'Statement Date'),
    MapEntry('statementTime', 'Statement Time'),
    MapEntry('custodyTo', 'Custody Given To'),
    MapEntry('custodyOtherText', 'Custody Other (Specify)'),
    MapEntry('custodyName', 'Custody Name'),
    MapEntry('custodyAge', 'Custody Age'),
    MapEntry('custodyGender', 'Custody Gender'),
    MapEntry('custodyMobile', 'Custody Mobile'),
    MapEntry('custodyAadhaar', 'Custody Aadhaar'),
    MapEntry('custodyRelation', 'Custody Relationship'),
    MapEntry('custodyAddress', 'Custody Full Address'),

    // 3) 183 BNSS
    MapEntry('bnss183Recorded', 'Statement Recorded under 183 BNSS'),
    MapEntry('bnssDate', 'BNSS Date'),
    MapEntry('bnssTime', 'BNSS Time'),

    // 4) CWC Statement
    MapEntry('cwcRecorded', 'CWC Statement Recorded'),
    MapEntry('cwcDate', 'CWC Date'),
    MapEntry('cwcTime', 'CWC Time'),

    // 5) Medical Examination
    MapEntry('medicalExamDone', 'Medical Examination Conducted'),
    MapEntry('medicalDate', 'Medical Date'),
    MapEntry('medicalTime', 'Medical Time'),

    // 6) In-Camera Statement
    MapEntry('inCameraRecorded', 'In-Camera Statement Recorded'),
    MapEntry('inCameraDate', 'In-Camera Date'),
    MapEntry('inCameraTime', 'In-Camera Time'),
  ];

  final fields = <_FD>[];
  for (final pair in ordered) {
    fields.add(
      _f(pair.value, _anyToString(data[pair.key])),
    );
  }

  // Keep cards small enough to avoid orphan headers / bad page spacing.
  const chunkSize = 8;
  final cards = <pw.Widget>[];
  for (var i = 0; i < fields.length; i += chunkSize) {
    final chunk = fields.sublist(
      i,
      (i + chunkSize) > fields.length ? fields.length : (i + chunkSize),
    );
    cards.add(
      _card(
        0,
        i == 0 ? 'KIDNAPPING EXTRA FIELDS' : 'KIDNAPPING EXTRA FIELDS (CONT.)',
        _amber,
        _grid2(chunk),
      ),
    );
  }
  return cards;
}

pw.Widget _buildAnyMap(Map<dynamic, dynamic> m) {
  final flatFields = <MapEntry<dynamic, dynamic>>[];
  final listFields = <MapEntry<dynamic, dynamic>>[];
  final subMaps = <MapEntry<dynamic, dynamic>>[];

  for (final e in m.entries) {
    if (e.value is Map) {
      subMaps.add(e);
    } else if (e.value is List) {
      listFields.add(e);
    } else {
      flatFields.add(e);
    }
  }

  final widgets = <pw.Widget>[];

  if (flatFields.isNotEmpty) {
    widgets.add(
      _grid2(
        flatFields
            .map(
              (e) => _f(
                _labelify(e.key.toString()),
                _anyToString(e.value),
              ),
            )
            .toList(),
      ),
    );
  }

  for (final e in listFields) {
    final list = e.value as List;
    widgets.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              _labelify(e.key.toString()).toUpperCase(),
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: _sec,
                letterSpacing: 0.5,
              ),
            ),
            pw.SizedBox(height: 4),
            if (list.isEmpty)
              _empty('No entries.')
            else
              pw.Column(
                children: list.asMap().entries.map((item) {
                  if (item.value is Map) {
                    return _subCard(
                      _buildAnyMap(
                        Map<dynamic, dynamic>.from(item.value as Map),
                      ),
                    );
                  }
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 3),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: 4,
                          height: 4,
                          margin: const pw.EdgeInsets.only(right: 6),
                          decoration: pw.BoxDecoration(
                            color: _amber,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            _anyToString(item.value),
                            style: pw.TextStyle(fontSize: 10, color: _dark),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  for (final e in subMaps) {
    widgets.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              _labelify(e.key.toString()).toUpperCase(),
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: _sec,
                letterSpacing: 0.5,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: _bg,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: _border, width: 0.5),
              ),
              child: _buildAnyMap(
                Map<dynamic, dynamic>.from(e.value as Map),
              ),
            ),
          ],
        ),
      ),
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: widgets,
  );
}

String _labelify(String key) {
  var result = key.replaceAll('_', ' ');
  result = result.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (m) => '${m.group(1)} ${m.group(2)}',
  );
  if (result.isNotEmpty) {
    result = result[0].toUpperCase() + result.substring(1);
  }
  return result;
}

String _anyToString(dynamic v) {
  if (v == null) return '-';
  if (v is bool) return v ? 'Yes' : 'No';
  if (v is List) return v.isEmpty ? '-' : v.map(_anyToString).join(', ');
  if (v is Map) {
    return v.isEmpty
        ? '-'
        : v.entries
            .map(
              (e) => '${_labelify(e.key.toString())}: ${_anyToString(e.value)}',
            )
            .join(' | ');
  }
  final s = v.toString().trim();
  return s.isEmpty ? '-' : s;
}

// ══════════════════════════════════════════════════════════════════════════════
// COMPONENT BUILDERS
// ══════════════════════════════════════════════════════════════════════════════

pw.Widget _card(int num, String title, PdfColor accent, pw.Widget body) =>
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // If remaining space is too small, move this whole section to next page.
        // Prevents orphan headings with empty space below.
        pw.NewPage(freeSpace: 110),
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          decoration: pw.BoxDecoration(
            color: _white,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: _border, width: 0.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: pw.BoxDecoration(
                  color: _dark,
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(7),
                    topRight: pw.Radius.circular(7),
                  ),
                ),
                child: pw.Row(
                  children: [
                    if (num > 0) ...[
                      pw.Container(
                        width: 18,
                        height: 18,
                        decoration: pw.BoxDecoration(
                          color: accent,
                          shape: pw.BoxShape.circle,
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            '$num',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: _white,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                    ],
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: _white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Padding(padding: const pw.EdgeInsets.all(12), child: body),
            ],
          ),
        ),
      ],
    );

class _FD {
  const _FD(this.label, this.value, {this.full = false});
  final String label;
  final String value;
  final bool full;
}

_FD _f(String label, String value, {bool full = false}) =>
    _FD(label, value, full: full);

pw.Widget _grid2(List<_FD> fields) {
  final rows = <pw.Widget>[];
  final regular = fields.where((f) => !f.full).toList();
  final fullList = fields.where((f) => f.full).toList();

  for (var i = 0; i < regular.length; i += 2) {
    final left = regular[i];
    final right = i + 1 < regular.length ? regular[i + 1] : null;
    rows.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: _fWidget(left.label, left.value)),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: right != null
                  ? _fWidget(right.label, right.value)
                  : pw.SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
  for (final f in fullList) {
    rows.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: _fWidget(f.label, f.value),
      ),
    );
  }
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: rows,
  );
}

pw.Widget _fWidget(String label, String value) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
            color: _sec,
            letterSpacing: 0.5,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: pw.BoxDecoration(
            color: _bg,
            borderRadius: pw.BorderRadius.circular(4),
            border: pw.Border.all(color: _border, width: 0.5),
          ),
          child: pw.Text(
            value.isEmpty ? '-' : value,
            style: pw.TextStyle(
              fontSize: 10,
              color: value.isEmpty ? _muted : _dark,
            ),
          ),
        ),
      ],
    );

pw.Widget _subCard(pw.Widget child) => pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: _bg,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: _border, width: 0.5),
      ),
      child: child,
    );

pw.Widget _personBlock(String title, Map<String, dynamic> person) =>
    pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: _bg,
        borderRadius: pw.BorderRadius.circular(6),
        border: const pw.Border(left: pw.BorderSide(color: _teal, width: 3)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: _dark,
            ),
          ),
          pw.SizedBox(height: 6),
          _grid2([
            _f('Name', _v(person['name'])),
            _f('Age', _v(person['age'])),
            _f('Gender', _v(person['gender'])),
            _f('Occupation', _v(person['occ'])),
            _f('Mobile', _v(person['mobile'])),
            _f('Aadhaar', _v(person['aadhaar'])),
            _f('Religion', _v(person['religion'])),
            _f('Caste', _v(person['caste'])),
            _f('PAN', _v(person['pan'])),
          ]),
        ],
      ),
    );

pw.Widget _chargeBlock(int num, String act, List<String> secs) => pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: _bg,
        borderRadius: pw.BorderRadius.circular(6),
        border: const pw.Border(left: pw.BorderSide(color: _teal, width: 3)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Charge #$num: ${act.isEmpty ? "No act selected" : act}',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: _dark,
            ),
          ),
          pw.SizedBox(height: 4),
          secs.isEmpty
              ? pw.Text(
                  'No sections selected',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: _muted,
                    fontStyle: pw.FontStyle.italic,
                  ),
                )
              : pw.Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: secs
                      .map(
                        (s) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: pw.BoxDecoration(
                            color: _bg,
                            borderRadius: pw.BorderRadius.circular(4),
                            border: pw.Border.all(color: _teal, width: 0.8),
                          ),
                          child: pw.Text(
                            '§$s',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: _teal,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );

pw.Widget _verdictCol(String title, List<String> names, PdfColor color) =>
    pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: color, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Divider(color: color, thickness: 0.5),
          pw.SizedBox(height: 4),
          names.isEmpty
              ? pw.Text(
                  'None',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: _muted,
                    fontStyle: pw.FontStyle.italic,
                  ),
                )
              : pw.Column(
                  children: names
                      .map(
                        (n) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 3),
                          child: pw.Row(
                            children: [
                              pw.Container(
                                width: 5,
                                height: 5,
                                margin: const pw.EdgeInsets.only(right: 6),
                                decoration: pw.BoxDecoration(
                                  color: color,
                                  shape: pw.BoxShape.circle,
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  n,
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: _dark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );

pw.Widget _scrutinyStep(
  int step,
  String title,
  bool active, {
  required String send,
  required String grant,
  String? lockedMsg,
  bool isLast = false,
}) =>
    pw.Padding(
      padding: pw.EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            children: [
              pw.Container(
                width: 22,
                height: 22,
                decoration: pw.BoxDecoration(
                  color: active ? _teal : _border,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Text(
                    '$step',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: _white,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                pw.Container(
                  width: 2,
                  height: 30,
                  color: active ? _teal : _border,
                ),
            ],
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Padding(
              padding: pw.EdgeInsets.only(bottom: isLast ? 0 : 4),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: active ? _dark : _muted,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  if (!active && lockedMsg != null)
                    pw.Text(
                      lockedMsg,
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: _muted,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    )
                  else
                    _grid2([
                      _f('Send Date', send),
                      _f('Grant Date', grant),
                    ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );

pw.Widget _checkbox(bool checked, {PdfColor color = _teal}) => pw.Container(
      width: 12,
      height: 12,
      decoration: pw.BoxDecoration(
        color: checked ? color : _bg,
        borderRadius: pw.BorderRadius.circular(3),
        border: pw.Border.all(color: checked ? color : _border),
      ),
      child: checked
          ? pw.Center(
              child: pw.Text(
                '✓',
                style: pw.TextStyle(
                  fontSize: 7,
                  color: _white,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            )
          : pw.SizedBox(),
    );

pw.Widget _badge(String label, PdfColor color) => pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(20),
        border: pw.Border.all(color: color, width: 0.8),
      ),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
    );

pw.Widget _empty(String text) => pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _bg,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: _border, width: 0.5),
      ),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 9,
          color: _muted,
          fontStyle: pw.FontStyle.italic,
        ),
      ),
    );

// ══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════════════════

String _v(dynamic v, {String or = ''}) {
  if (v == null) return or;
  final s = v.toString().trim();
  return s.isEmpty ? or : s;
}

String _safeText(String input) => input.replaceAll('—', '-');

String _now() {
  final d = DateTime.now();
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
