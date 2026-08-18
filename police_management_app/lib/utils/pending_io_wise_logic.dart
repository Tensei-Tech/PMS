// lib/utils/pending_io_wise_logic.dart
// Pending Cases → IO Wise: category filter + IO/CC field resolution (Firestore-shaped maps).

import 'package:flutter/foundation.dart';

import '../modules/core/models/base_record.dart';
import 'common_form_module.dart';

bool _trimmedNonEmpty(dynamic v) {
  if (v == null) return false;
  final s = v.toString().trim();
  return s.isNotEmpty;
}

/// True if CC Number–style fields have any meaningful value — case must NOT appear in IO Wise.
bool pendingIoWiseCcIsFilled(ModuleRecord r) {
  bool anyFilled(dynamic x) => _trimmedNonEmpty(x);

  final ef = r.extraFields;
  for (final k in ['ccNumber', 'cc_number', 'ccNo', 'CC No', 'CCNo']) {
    if (anyFilled(ef[k])) return true;
  }

  final cfRaw = ef[kCommonFormExtraFieldsKey];
  if (cfRaw is Map) {
    final m = Map<String, dynamic>.from(cfRaw);
    final court = m['court'];
    if (court is Map) {
      final c = Map<String, dynamic>.from(court);
      for (final k in ['ccStNumber', 'ccNumber', 'cc_number', 'ccNo', 'CC No']) {
        if (anyFilled(c[k])) return true;
      }
    }
  }

  return false;
}

/// Returns displayable IO label if an IO–name field has a value, else null.
String? pendingIoWiseIoDisplayName(ModuleRecord r) {
  String? nz(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  final cfRaw = r.extraFields[kCommonFormExtraFieldsKey];
  if (cfRaw is Map) {
    final m = Map<String, dynamic>.from(cfRaw);
    final cr = m['caseResponsibility'];
    if (cr is Map) {
      final nm = nz(Map<String, dynamic>.from(cr)['ioName']);
      if (nm != null) return nm;
    }
  }

  final ef = r.extraFields;
  for (final k in ['ioName', 'io_name', 'investigatingOfficer']) {
    final nm = nz(ef[k]);
    if (nm != null) return nm;
  }
  final spaced = nz(ef['IO Name']);
  if (spaced != null) return spaced;

  return null;
}

bool _looksLikeRti(ModuleRecord r) {
  bool has(String blob) => blob.contains('rti');

  final sub = (r.subCategory ?? '').toLowerCase();
  if (has(sub)) return true;

  if (has(r.title.toLowerCase())) return true;

  final disp = r.firestoreCategoryDisplayName.toLowerCase();
  if (has(disp)) return true;

  final md = r.extraFields['moduleDisplayName']?.toString().toLowerCase() ?? '';
  return has(md);
}

/// Whether [r] is counted under the Pending dashboard bucket [dashboardCategory].
bool pendingRecordMatchesDashboardCategory({
  required ModuleRecord r,
  required String dashboardCategory,
}) {
  if (r.moduleKey == 'nc') return false;
  switch (dashboardCategory) {
    case 'I to V':
      return r.moduleKey == 'form_1_5';
    case 'Class VI':
      return r.moduleKey == 'form_6';
    case 'Prohibition':
      return r.moduleKey == 'mpda';
    case 'Gambling':
      return r.moduleKey == 'coin';
    case 'AD':
      return r.moduleKey == 'ad';
    case 'Missing':
      return r.moduleKey == 'missing';
    case 'Application':
      return r.moduleKey == 'application' && !_looksLikeRti(r);
    case 'MV Act':
      return r.moduleKey == 'traffic';
    case 'RTI':
      return r.moduleKey == 'application' && _looksLikeRti(r);
    case 'Preventive':
      return r.moduleKey == 'preventive';
    case 'IT Act/Cyber':
      return r.moduleKey == 'it_act';
    default:
      debugPrint('pendingRecordMatchesDashboardCategory: unknown "$dashboardCategory"');
      return false;
  }
}

/// Non-closed, in category, has IO name, CC empty → IO Wise row.
bool pendingIoWiseEligibleInCategory(ModuleRecord r, String dashboardCategory) {
  if (r.moduleKey == 'nc') return false;
  if (r.status == 'Closed') return false;
  if (!pendingRecordMatchesDashboardCategory(
      r: r, dashboardCategory: dashboardCategory)) {
    return false;
  }
  if (pendingIoWiseCcIsFilled(r)) return false;
  return pendingIoWiseIoDisplayName(r) != null;
}

/// Must match dashboard `_PendingSectionInline._categories` (the real category
/// chips only — not the extra "IO Wise" grid action).
const kPendingDashboardCategoriesForIoWise = <String>[
  'I to V',
  'Class VI',
  'Prohibition',
  'Gambling',
  'AD',
  'Missing',
  'Application',
  'MV Act',
  'RTI',
  'Preventive',
  'IT Act/Cyber',
];

/// True if [r] is IO-Wise–eligible for any pending dashboard category chip.
bool pendingIoWiseEligibleAnyDashboardCategory(ModuleRecord r) {
  for (final c in kPendingDashboardCategoriesForIoWise) {
    if (pendingIoWiseEligibleInCategory(r, c)) return true;
  }
  return false;
}
