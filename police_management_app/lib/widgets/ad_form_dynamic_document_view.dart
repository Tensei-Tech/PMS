// lib/widgets/ad_form_dynamic_document_view.dart
// A.D read-only view: recursively renders every key/value in [formData] (maps/lists/scalars)
// so the screen stays in sync with Firestore + the form without hardcoded sections.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../modules/core/models/base_record.dart';
import '../theme/app_theme.dart';
import '../utils/ad_form_display_order.dart';
import 'module_record_dynamic_document_view.dart'
    show kModuleHubFieldLabels, orderedModuleHubScalarKeys;

/// Preferred labels for known `buildAdDocumentMap` keys (new keys fall back to [humanizeFieldKey]).
const Map<String, String> kAdFormFieldLabels = {
  'adNo': 'AD No.',
  'crNo': 'Cr. No. (If applicable)',
  'regDate': 'Registered Date',
  'status': 'Form status (Firestore)',
  'caseListDocId': 'Linked case document id',
  'submittedAt': 'Submitted at',
  'updatedAt': 'Last updated',
  'savedAt': 'Draft saved at',
  'spotVillage': 'Village / Town',
  'spotArea': 'Area Name',
  'spotAddress': 'Full Address',
  'compName': 'Name',
  'compAge': 'Age',
  'compGender': 'Gender',
  'compOcc': 'Occupation',
  'compMobile': 'Mobile Number',
  'compAadhaar': 'Aadhaar Number',
  'compReligion': 'Religion',
  'compCaste': 'Caste',
  'compPan': 'PAN Number',
  'isUnknownDeath': 'Unknown death',
  'causeOfDeath': 'Cause of death',
  'otherCause': 'Other cause (specify)',
  'relName': 'Relative Name',
  'relRelation': 'Relation',
  'relAge': 'Age',
  'relGender': 'Gender',
  'relOcc': 'Occupation',
  'relMobile': 'Mobile Number',
  'relAadhaar': 'Aadhaar Number',
  'relReligion': 'Religion',
  'relCaste': 'Caste',
  'relPan': 'PAN Number',
  'ioDesig': 'IO Designation',
  'ioName': 'IO Name',
  'regDesig': 'Reg. By Designation',
  'regName': 'Registrar Name',
  'cctvValue': 'CCTV Available',
  'cctvDateTime': 'CCTV Date & Time',
  'eshakshValue': 'E-shaksh',
  'cdrSent': 'CDR Sent Date',
  'cdrRecv': 'CDR Received Date',
  'sdpoSend': 'SDPO / ACP — Sent',
  'sdpoGrant': 'SDPO / ACP — Granted',
  'appSend': 'APP — Sent',
  'appGrant': 'APP — Granted',
  'dcpSend': 'Addl SP / DCP / Addl CP — Sent',
  'dcpGrant': 'Addl SP / DCP / Addl CP — Granted',
  'stepAppActive': 'APP scrutiny step active',
  'stepDcpActive': 'DCP scrutiny step active',
  'peopleNames': 'People names (deceased list for seizures)',
  'act': 'Act',
  'sections': 'Sections',
  'roman': 'Roman',
  'value': 'Value',
  'date': 'Date',
  'desc': 'Property Description',
  'fromWhom': 'From Whom (Deceased)',
  'otherName': 'Other Name (if not in list)',
  'name': 'Name',
  'age': 'Age',
  'gender': 'Gender',
  'occ': 'Occupation',
  'mobile': 'Mobile Number',
  'aadhaar': 'Aadhaar Number',
  'religion': 'Religion',
  'caste': 'Caste',
  'pan': 'PAN Number',
};

const Map<String, String> kAdUnknownSubLabels = {
  'shodhPatrika': 'Shodh Patrika',
  'gazette': 'Gazette',
  'mediaPub': 'Media Publication',
  'dnaSent': 'DNA sent to CA',
  'dnaReport': 'DNA report received',
  'funeralPolice': 'Body funeral by police',
  'funeralRelative': 'Body funeral by relative',
};

const Map<String, String> kAdProceduralSubLabels = {
  'chkMemo': 'Memorandum Panchanama',
  'chkPanchSpot': 'Panchanama Spot',
  'chkInquest': 'Inquest',
  'chkIdent': 'Identification',
  'chkSearch': 'Search',
  'chkPersSearch': 'Personal Search',
  'chkExhumation': 'Exhumation',
};

/// Keys written by `buildAdDocumentMap` (exported for callers that need the set).
const Set<String> kAdFormDocumentKeys = {
  'adNo',
  'crNo',
  'regDate',
  'spotVillage',
  'spotArea',
  'spotAddress',
  'compName',
  'compAge',
  'compGender',
  'compOcc',
  'compMobile',
  'compAadhaar',
  'compReligion',
  'compCaste',
  'compPan',
  'deceased',
  'chargeData',
  'charges',
  'isUnknownDeath',
  'causeOfDeath',
  'otherCause',
  'unknownFields',
  'relName',
  'relRelation',
  'relAge',
  'relGender',
  'relOcc',
  'relMobile',
  'relAadhaar',
  'relReligion',
  'relCaste',
  'relPan',
  'ioDesig',
  'ioName',
  'regDesig',
  'regName',
  'cctvValue',
  'cctvDateTime',
  'proceduralChecks',
  'proceduralDates',
  'eshakshValue',
  'seizures',
  'cdrSent',
  'cdrRecv',
  'sdpoSend',
  'sdpoGrant',
  'appSend',
  'appGrant',
  'dcpSend',
  'dcpGrant',
  'stepAppActive',
  'stepDcpActive',
  'peopleNames',
  'caseListDocId',
  'status',
  'submittedAt',
  'savedAt',
  'updatedAt',
};

String humanizeFieldKey(String key) {
  if (key.isEmpty) return key;
  final withSpaces = key
      .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')
      .replaceAll('_', ' ')
      .trim();
  return withSpaces
      .split(RegExp(r'\s+'))
      .map((w) => w.isEmpty
          ? ''
          : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');
}

String labelForKey(String key) =>
    kAdFormFieldLabels[key] ??
    kAdUnknownSubLabels[key] ??
    kAdProceduralSubLabels[key] ??
    humanizeFieldKey(key);

class AdFormDynamicDocumentView extends StatelessWidget {
  final Map<String, dynamic> formData;
  final ModuleRecord hubRecord;

  const AdFormDynamicDocumentView({
    super.key,
    required this.formData,
    required this.hubRecord,
  });

  static String disp(dynamic v) {
    if (v == null) return '—';
    if (v is bool) return v ? 'Yes' : 'No';
    if (v is Timestamp) {
      final d = v.toDate().toLocal();
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    if (v is DateTime) {
      return DateFormat('dd MMMM yyyy, hh:mm a').format(v.toLocal());
    }
    if (v is String) {
      final t = v.trim();
      if (t.isEmpty) return '—';
      try {
        if (t.length >= 10 &&
            (t.contains('T') || RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(t))) {
          final d = DateTime.parse(t).toLocal();
          final datePart = DateFormat('dd MMMM yyyy').format(d);
          final hasTime = t.contains('T') &&
              (d.hour != 0 || d.minute != 0 || d.second != 0);
          if (hasTime) {
            return '$datePart, ${DateFormat('hh:mm a').format(d)}';
          }
          return datePart;
        }
      } catch (_) {}
      return t;
    }
    if (v is List) {
      if (v.isEmpty) return '—';
      return v.map((e) => disp(e)).join(', ');
    }
    final s = v.toString().trim();
    return s.isEmpty ? '—' : s;
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.goldPrimary),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
      ),
    ]);
  }

  Widget _row(String label, String value, {bool boldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.lightSubText,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: boldValue ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.lightText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: AppColors.lightBorder);

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(children: children),
    );
  }

  List<Widget> _expandField(String label, dynamic v,
      {String? fieldKey, String? mapParentKey}) {
    if (v == null) return [_row(label, '—')];
    if (v is List) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDark,
              ),
            ),
          ),
        ),
        ..._expandList(v, listFieldKey: fieldKey),
      ];
    }
    if (v is Map) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDark,
              ),
            ),
          ),
        ),
        ..._expandMap(
          v,
          parentFieldKey: mapParentKey ?? fieldKey,
        ),
      ];
    }
    return [_row(label, disp(v))];
  }

  List<Widget> _expandMap(Map raw, {String? parentFieldKey}) {
    final m = Map<String, dynamic>.from(raw);
    if (m.isEmpty) return [_row('(empty)', '—')];
    final kind =
        adNestedMapKindFor(parentFieldKey: parentFieldKey, m: m);
    final keys = orderedKeysForAdNestedMap(kind: kind, m: m);
    final parentForNestedValues =
        kind == AdNestedMapKind.chargeDataSlots ? 'chargeData' : parentFieldKey;
    final out = <Widget>[];
    for (final k in keys) {
      if (out.isNotEmpty) out.add(_divider());
      out.addAll(_expandField(
        labelForKey(k),
        m[k],
        fieldKey: k,
        mapParentKey: parentForNestedValues,
      ));
    }
    return out;
  }

  List<Widget> _expandList(List list, {String? listFieldKey}) {
    if (list.isEmpty) return [_row('(empty)', '—')];
    final out = <Widget>[];
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      if (out.isNotEmpty) out.add(_divider());
      if (item is Map) {
        final im = Map<String, dynamic>.from(item);
        out.add(_row('Item #${i + 1}', '', boldValue: true));
        final keys = orderedKeysForAdListItemMap(
          listFieldKey: listFieldKey ?? '',
          m: im,
        );
        for (final k in keys) {
          if (out.isNotEmpty) out.add(_divider());
          out.addAll(_expandField(labelForKey(k), im[k],
              fieldKey: k, mapParentKey: listFieldKey));
        }
      } else {
        out.add(_row('#${i + 1}', disp(item)));
      }
    }
    return out;
  }

  List<Widget> _allFieldRows(Map<String, dynamic> data) {
    final keys = orderedAdFormRootKeys(data);
    final rows = <Widget>[];
    for (final k in keys) {
      if (rows.isNotEmpty) rows.add(_divider());
      rows.addAll(_expandField(labelForKey(k), data[k], fieldKey: k));
    }
    return rows;
  }

  String _hubLabel(String key) =>
      kModuleHubFieldLabels[key] ?? humanizeFieldKey(key);

  Widget _hubCard() {
    final raw = Map<String, dynamic>.from(hubRecord.toMap());
    raw.remove('extraFields');
    final keys = orderedModuleHubScalarKeys(raw);
    final children = <Widget>[];
    for (final k in keys) {
      if (children.isNotEmpty) children.add(_divider());
      children.add(_row(_hubLabel(k), disp(raw[k])));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Case hub summary', Icons.dashboard_outlined),
        const SizedBox(height: 10),
        _card(children: children),
        const SizedBox(height: 100),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
            'A.D — complete form record (all saved fields)',
            Icons.fact_check_outlined),
        const SizedBox(height: 10),
        _card(children: _allFieldRows(formData)),
        const SizedBox(height: AppSpacing.lg),
        _hubCard(),
      ],
    );
  }
}
