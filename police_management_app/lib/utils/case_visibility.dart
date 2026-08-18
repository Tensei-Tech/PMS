// lib/utils/case_visibility.dart
// Per-designation case visibility resolver + record filtering (Phase 1).

import '../modules/core/models/base_record.dart';
import '../providers/auth_provider.dart';
import 'app_constants.dart';

enum CaseVisibilityMode {
  ownCasesOnly,
  stationWide,
}

class CaseVisibility {
  CaseVisibility._();

  /// Ranks defaulting to own-cases-only (unless granted or senior).
  static const List<String> ownCasesDefaultDesignations = [
    'PC',
    'NPC',
    'HC',
    'PN',
    'ASI',
  ];

  /// Ranks defaulting to station-wide dashboard view.
  static const List<String> stationWideDefaultDesignations = [
    ...SeniorOfficerRoles.multiLocationDesignations,
  ];

  static bool _matches(String? designation, List<String> list) {
    if (designation == null || designation.trim().isEmpty) return false;
    final d = designation.trim().toLowerCase();
    return list.any((r) => r.toLowerCase() == d);
  }

  /// Single source of truth for visibility mode.
  static CaseVisibilityMode resolveMode({
    required String designation,
    required bool stationCaseViewGranted,
    required bool isViewingOtherStation,
  }) {
    if (SeniorOfficerRoles.canSwitchLocation(designation)) {
      return CaseVisibilityMode.stationWide;
    }
    if (isViewingOtherStation) {
      return CaseVisibilityMode.stationWide;
    }
    if (stationCaseViewGranted) {
      return CaseVisibilityMode.stationWide;
    }
    if (_matches(designation, stationWideDefaultDesignations)) {
      return CaseVisibilityMode.stationWide;
    }
    return CaseVisibilityMode.ownCasesOnly;
  }

  static CaseVisibilityMode resolveFor(AuthProvider auth) {
    return resolveMode(
      designation: auth.designation,
      stationCaseViewGranted: auth.stationCaseViewGranted,
      isViewingOtherStation: auth.isViewingOtherStation,
    );
  }

  /// Whether [record] is visible under [mode] for [uid] / [officerName].
  static bool isRecordVisible({
    required ModuleRecord record,
    required String uid,
    String? officerName,
    required CaseVisibilityMode mode,
  }) {
    if (mode == CaseVisibilityMode.stationWide) return true;

    final creator = record.createdBy.trim();
    if (uid.isNotEmpty && creator == uid) return true;

    final assignee = record.assignedOfficerUid?.trim() ?? '';
    if (uid.isNotEmpty && assignee.isNotEmpty && assignee == uid) {
      return true;
    }

    if (officerName != null && officerName.trim().isNotEmpty) {
      final name = officerName.trim().toLowerCase();
      if (record.assignedOfficer.trim().toLowerCase() == name) return true;
      if (creator.toLowerCase() == name) return true;
    }

    return false;
  }

  static List<ModuleRecord> filterRecords(
    List<ModuleRecord> records, {
    required String uid,
    String? officerName,
    required CaseVisibilityMode mode,
  }) {
    if (mode == CaseVisibilityMode.stationWide) return records;
    return records
        .where((r) => isRecordVisible(
              record: r,
              uid: uid,
              officerName: officerName,
              mode: mode,
            ))
        .toList();
  }

  /// Whether the signed-in officer may view [record] (detail screens, deep links).
  static bool canViewRecord({
    required ModuleRecord record,
    required AuthProvider auth,
  }) {
    return isRecordVisible(
      record: record,
      uid: auth.uid,
      officerName: auth.displayName,
      mode: resolveFor(auth),
    );
  }

  /// Filter [records] using the current auth context.
  static List<ModuleRecord> filterForAuth(
    List<ModuleRecord> records,
    AuthProvider auth,
  ) {
    return filterRecords(
      records,
      uid: auth.uid,
      officerName: auth.displayName,
      mode: resolveFor(auth),
    );
  }

  static String modeLabel(CaseVisibilityMode mode) {
    switch (mode) {
      case CaseVisibilityMode.ownCasesOnly:
        return 'My cases';
      case CaseVisibilityMode.stationWide:
        return 'All station cases';
    }
  }

  static String chipPrefix(CaseVisibilityMode mode) =>
      'Showing: ${modeLabel(mode)}';

  static bool showAskPiHint(CaseVisibilityMode mode) =>
      mode == CaseVisibilityMode.ownCasesOnly;

  /// Grant toggles apply only to ranks that default to own-cases-only.
  static bool designationEligibleForGrant(String? designation) {
    return resolveMode(
          designation: designation ?? '',
          stationCaseViewGranted: false,
          isViewingOtherStation: false,
        ) ==
        CaseVisibilityMode.ownCasesOnly;
  }
}
