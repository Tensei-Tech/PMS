// lib/utils/app_constants.dart
// Central constants for the entire app — no hardcoded values anywhere else.
import 'package:flutter/material.dart';

/// Route names
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String registerPendingApproval = '/register/pending-approval';
  static const String registerPinSetup = '/register/pin-setup';
  static const String pin = '/pin';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String loginSecurity = '/login-security';
  static const String appSettings = '/app-settings';
  static const String classificationList = '/classification-list';
  static const String transferRequest = '/transfer/request';
  static const String pendingTransfers = '/transfer/pending';
  static const String transferStatus = '/transfer/status';
  static const String stationAccessGrants = '/station/access-grants';

}

/// App-wide timeout and timing constants
class AppTimeouts {
  /// Minutes of inactivity before auto-lock
  static const int autoLockMinutes = 10;
  static const Duration autoLockDuration = Duration(minutes: autoLockMinutes);
  /// Search debounce delay
  static const Duration searchDebounce = Duration(milliseconds: 300);
  /// Carousel auto-scroll interval
  static const Duration carouselInterval = Duration(seconds: 4);
}

/// SharedPreferences / SecureStorage keys
class StorageKeys {
  // ── Secure storage keys (flutter_secure_storage — AES encrypted) ──────────
  /// [DEPRECATED] Legacy plaintext PIN key — kept for migration cleanup only.
  /// DO NOT write new values here; use [pinHash] + [pinSalt] instead.
  static const String pin = 'user_pin';
  static const String password = 'user_password';
  static const String email = 'user_email';
  static const String biometricEnabled = 'biometric_enabled';

  // ── Domain 1: PIN Hashing (PBKDF2-HMAC-SHA256) ───────────────────────────
  /// PBKDF2 hash of the user's PIN (hex-encoded, 64 chars).
  static const String pinHash = 'user_pin_hash';
  /// Per-user cryptographic salt for PBKDF2 (hex-encoded, 64 chars).
  static const String pinSalt = 'user_pin_salt';

  // ── Non-sensitive preferences (SharedPreferences) ────────────────────────
  static const String isRegistered = 'is_registered';
  static const String username = 'username';
  static const String fullName = 'full_name';
  static const String designation = 'designation';
  static const String stationName = 'station_name';
  static const String stationAddress = 'station_address';
  static const String stationLandline = 'station_landline';
  // NOTE: phone and govtId are intentionally NOT stored in SharedPreferences
  // (they are sensitive PII — loaded from Firestore on login instead).
  static const String profilePhoto = 'profile_photo';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String fontSize = 'font_size';
  static const String notificationsEnabled = 'notifications_enabled';
}

/// 34 Classification categories — forms removed, exact order preserved.
class Classification {
  final String name;
  final String iconName;
  final String moduleKey;

  const Classification(this.name, this.iconName, this.moduleKey);

  // ── Part 1: Crime Statistics ──────────────────────────────────────────────
  static const List<Classification> statsGroup = [
    Classification('Monthly',              'calendar_month',   'monthly'),
    Classification('Pending',              'pending_actions',  'pending'),
    Classification('Forms',                'description',      'form_1_5'),
    Classification('Detected',             'search',           'detected'),
    Classification('Undetected',           'visibility_off',   'undetected'),
    Classification('Disposal',             'delete_forever',   'disposal'),
    Classification('I to V',               'description',      'form_1_5'),
    Classification('VI',                   'article',          'form_6'),
  ];

  // ── Part 2: Case Categories ───────────────────────────────────────────────
  static const List<Classification> casesGroup = [
    Classification('A.D',                 'gavel',            'ad'),
    Classification('Hurt',                'local_hospital',   'hurt'),
    Classification('Theft',               'no_encryption',    'theft'),
    Classification('Sand Theft',          'terrain',          'sand_theft'),
    Classification('Two/Four\nWheeler',   'two_wheeler',      'two_four_wheeler'),
    Classification('Kidnapping',          'child_care',       'kidnapping'),
    Classification('Missing',             'person_search',    'missing'),
    Classification('N.C',                 'report',           'nc'),
    Classification('Preventive',          'security',         'preventive'),
    Classification('Arrested',            'handcuffs',        'arrested'),
    Classification('Absconded',           'directions_run',   'absconded'),
    Classification('POCSO',               'shield',           'pocso'),
    Classification('Crime against\nWomen', 'woman',            'crime_women'),
    Classification('Juvenile',            'child_friendly',   'juvenile'),
    Classification('Victim',              'healing',          'victim'),
  ];

  // ── Part 3: Special Services ──────────────────────────────────────────────
  static const List<Classification> servicesGroup = [
    Classification('Accident',            'car_crash',        'accident'),
    Classification('Traffic',             'traffic',          'traffic'),
    Classification('Application',         'description',      'application'),
    Classification('Sam/Warrant',         'assignment',       'sam_warrant'),
    Classification('Muddemal',            'inventory',        'muddemal'),
    Classification('Sec 186/175\n(BNSS)', 'balance',          'bnss'),
    Classification('Passport/\nPVR/Lic', 'badge',            'passport'),
    Classification('NDPS',                'medication',       'ndps'),
    Classification('Gowans',              'home_work',        'gowans'),
    Classification('IT Act',              'computer',         'it_act'),
    Classification('MCOCA',               'policy',           'mcoca'),
    Classification('UAPA',                'account_balance',  'uapa'),
    Classification('MPDA',                'admin_panel',      'mpda'),
    Classification('COIN',                'monetization_on',  'coin'),
  ];

  /// Combined flat list for the drawer
  static List<Classification> get all =>
      [...statsGroup, ...casesGroup, ...servicesGroup];

  /// Unified sequence for the "Add" (FAB) menu as requested by user
  static const List<Classification> addMenuAll = [
    Classification('I to V',               'description',      'form_1_5'),
    Classification('VI',                   'article',          'form_6'),
    Classification('A.D',                 'gavel',            'ad'),
    Classification('Hurt',                'local_hospital',   'hurt'),
    Classification('Theft',               'no_encryption',    'theft'),
    Classification('Sand Theft',          'terrain',          'sand_theft'),
    Classification('Two/Four Wheeler Stolen', 'two_wheeler',  'two_four_wheeler'),
    Classification('Kid',                 'child_care',       'kidnapping'),
    Classification('Missing',             'person_search',    'missing'),
    Classification('N.C',                 'report',           'nc'),
    Classification('Preventive',          'security',         'preventive'),
    Classification('Arrested',            'handcuffs',        'arrested'),
    Classification('Absconded',           'directions_run',   'absconded'),
    Classification('POCSO',               'shield',           'pocso'),
    Classification('Crime against Women', 'woman',            'crime_women'),
    Classification('Juvenile',            'child_friendly',   'juvenile'),
    Classification('Victim',              'healing',          'victim'),
    Classification('Accident',            'car_crash',        'accident'),
    Classification('Traffic',             'traffic',          'traffic'),
    Classification('Application',         'description',      'application'),
    Classification('Sam (Summons) / Warrant', 'assignment',   'sam_warrant'),
    Classification('Muddemal',            'inventory',        'muddemal'),
    Classification('Section 186/175/BNSS', 'balance',          'bnss'),
    Classification('Passport /PVR / License', 'badge',         'passport'),
    Classification('NDPS',                'medication',       'ndps'),
    Classification('Gowans',              'home_work',        'gowans'),
    Classification('IT Act',              'computer',         'it_act'),
    Classification('MCOCA',               'policy',           'mcoca'),
    Classification('UAPA',                'account_balance',  'uapa'),
    Classification('MPDA',                'admin_panel',      'mpda'),
    Classification('COIN',                'monetization_on',  'coin'),
  ];
}

// AppSpacing and AppRadius are defined in lib/theme/app_theme.dart
// Import that file to use them — do NOT re-define them here.

/// Senior officer designations that have jurisdiction over multiple stations
/// and are allowed to use the "Switch Policestation" feature.
class SeniorOfficerRoles {
  SeniorOfficerRoles._();

  /// All designation abbreviations eligible for multi-location switching.
  /// Station-level: PSI, API, PI, Sr. PI
  /// CP Level (Commissionerate): CP, JT. CP, Addl. CP, DCP, ACP
  /// SP Level (District/Rural): SP, Addl. SP, Dy. SP, ASP
  static const List<String> multiLocationDesignations = [
    'PSI',
    'API',
    'PI',
    'Sr. PI',
    'CP',
    'JT. CP',
    'Addl. CP',
    'DCP',
    'ACP',
    'SP',
    'Addl. SP',
    'Dy. SP',
    'ASP',
  ];

  /// CP-level (city-level) officers. Operate over commissionerate cities.
  static const List<String> cpLevelDesignations = [
    'CP',
    'JT. CP',
    'Addl. CP',
    'DCP',
    'ACP',
  ];

  /// SP-level (rural / district-level) officers. Operate over rural
  /// superintendent districts.
  static const List<String> spLevelDesignations = [
    'SP',
    'Addl. SP',
    'Dy. SP',
    'ASP',
  ];

  /// Returns true if [designation] is a senior role that can switch locations.
  /// Comparison is case-insensitive and trimmed.
  static bool canSwitchLocation(String? designation) {
    if (designation == null || designation.trim().isEmpty) return false;
    final d = designation.trim().toLowerCase();
    return multiLocationDesignations.any((r) => r.toLowerCase() == d);
  }

  /// Returns true if [designation] is a CP-level (city-level) role.
  static bool isCpLevel(String? designation) {
    if (designation == null || designation.trim().isEmpty) return false;
    final d = designation.trim().toLowerCase();
    return cpLevelDesignations.any((r) => r.toLowerCase() == d);
  }

  /// Returns true if [designation] is an SP-level (rural / district) role.
  static bool isSpLevel(String? designation) {
    if (designation == null || designation.trim().isEmpty) return false;
    final d = designation.trim().toLowerCase();
    return spLevelDesignations.any((r) => r.toLowerCase() == d);
  }

  /// Police unit type implied by a senior rank, or null for junior/shared ranks.
  ///
  /// Matches [PoliceStationsRepository.commissionerate] /
  /// [PoliceStationsRepository.superintendent].
  static String? impliedUnitType(String? designation) {
    if (isCpLevel(designation)) return 'Commissionerate Police';
    if (isSpLevel(designation)) return 'Superintendent of Police';
    return null;
  }
}

/// Breakpoints for responsive layout
class Breakpoints {
  static const double mobile = 600.0;
  static const double tablet = 900.0;
  static const double desktop = 1280.0;
}

/// Unified data for Case Registration forms
class CaseTypeData {
  final String label;
  final IconData icon;
  final int color;

  const CaseTypeData(this.label, this.icon, this.color);

  static const List<CaseTypeData> all = [
    CaseTypeData('Form I-V', Icons.description_rounded, 0xFF3498DB),
    CaseTypeData('Form VI', Icons.article_rounded, 0xFF9B59B6),
    CaseTypeData('NC', Icons.report_rounded, 0xFF2ECC71),
    CaseTypeData('Preventive', Icons.security_rounded, 0xFFF39C12),
    CaseTypeData('AD', Icons.gavel_rounded, 0xFFE74C3C),
    CaseTypeData('Missing', Icons.person_search_rounded, 0xFF1ABC9C),
    CaseTypeData('Kidnapping', Icons.warning_rounded, 0xFFE74C3C),
    CaseTypeData('Theft', Icons.no_encryption_rounded, 0xFFF39C12),
    CaseTypeData('Sand Theft', Icons.terrain_rounded, 0xFF8D6E63),
    CaseTypeData('Hurt', Icons.local_hospital_rounded, 0xFFE91E63),
    CaseTypeData('POCSO', Icons.shield_rounded, 0xFF673AB7),
  ];
}

/// Unified data for Police Services and Tools
class ServiceData {
  final String label;
  final IconData icon;
  final int color;

  const ServiceData(this.label, this.icon, this.color);

  /// Tools shown directly on the dashboard grid.
  static const List<ServiceData> dashboardTools = [
    ServiceData('Licence', Icons.assignment_ind_rounded, 0xFF9B59B6),
    ServiceData('CCTNS', Icons.security_rounded, 0xFFF39C12),
    ServiceData('Dial 112', Icons.call_rounded, 0xFFE74C3C),
    ServiceData('Tadipar', Icons.gavel_rounded, 0xFF1ABC9C),
    ServiceData('History Sheet', Icons.assignment_rounded, 0xFFE74C3C),
    ServiceData('Repeat Offender', Icons.warning_rounded, 0xFFF39C12),
    ServiceData('ITSSO', Icons.description_rounded, 0xFFE91E63),
    ServiceData('NAFIS', Icons.fingerprint_rounded, 0xFF673AB7),
    ServiceData('DAR', Icons.folder_rounded, 0xFF607D8B),
    ServiceData('IRDA', Icons.analytics_rounded, 0xFF34495E),
    ServiceData('E-Learning', Icons.school_rounded, 0xFF7F8C8D),
  ];
}

enum MonthlyReportKind { v, vi, preventive }

/// Single police rank entry for registration dropdowns (abbreviation + display label).
class PoliceDesignationEntry {
  const PoliceDesignationEntry({
    required this.abbreviation,
    required this.display,
  });

  final String abbreviation;
  final String display;
}

/// Canonical police designation lists — single source of truth for rank ordering.
class PoliceDesignations {
  PoliceDesignations._();

  /// Form IO / Reg dropdowns (common form, NC, missing).
  static const List<String> formIoAndReg = [
    'HC',
    'PN',
    'PC',
    'NPC',
    'ASI',
    'SI',
    'PSI',
    'API',
    'PI',
    'Sr. PI',
  ];

  /// AD form — IO designation dropdown.
  static const List<String> adIo = [
    'PSI',
    'API',
    'PI',
    'Sr. PI',
  ];

  /// AD form — registered-by designation dropdown.
  static const List<String> adReg = [
    'HC',
    'PN',
    'PC',
    'NPC',
    'ASI',
  ];

  /// Commissionerate Police registration ranks (low → high).
  static const List<PoliceDesignationEntry> commissionerateRegistration = [
    PoliceDesignationEntry(
      abbreviation: 'PC',
      display: 'Police Constable (PC)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'NPC',
      display: 'Naik Police Constable (NPC)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'HC',
      display: 'Head Constable (HC)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'ASI',
      display: 'Assistant Sub Inspector (ASI)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'PSI',
      display: 'Police Sub Inspector (PSI)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'API',
      display: 'Assistant Police Inspector (API)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'PI',
      display: 'Police Inspector (PI)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'ACP',
      display: 'Assistant Commissioner of Police (ACP)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'DCP',
      display: 'Deputy Commissioner of Police (DCP)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'Addl. CP',
      display: 'Additional Commissioner of Police (Addl. CP)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'JT. CP',
      display: 'Joint Commissioner of Police (JT. CP)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'CP',
      display: 'Commissioner of Police (CP)',
    ),
  ];

  /// Superintendent / Rural registration ranks (low → high).
  static const List<PoliceDesignationEntry> ruralRegistration = [
    PoliceDesignationEntry(
      abbreviation: 'PC',
      display: 'Police Constable (PC)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'NPC',
      display: 'Naik Police Constable (NPC)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'HC',
      display: 'Head Constable (HC)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'ASI',
      display: 'Assistant Sub Inspector (ASI)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'PSI',
      display: 'Police Sub Inspector (PSI)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'API',
      display: 'Assistant Police Inspector (API)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'PI',
      display: 'Police Inspector (PI)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'Dy. SP',
      display: 'Deputy Superintendent of Police (Dy. SP)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'ASP',
      display: 'Assistant Superintendent of Police (ASP)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'Addl. SP',
      display: 'Additional Superintendent of Police (Addl. SP)',
    ),
    PoliceDesignationEntry(
      abbreviation: 'SP',
      display: 'Superintendent of Police (SP)',
    ),
  ];

  /// Registration dropdown list for [unitType] (Commissionerate vs Rural).
  static List<PoliceDesignationEntry> forRegistration(String? unitType) {
    if (unitType == null || unitType.isEmpty) return const [];
    if (unitType == 'Commissionerate Police') {
      return commissionerateRegistration;
    }
    return ruralRegistration;
  }

  /// Admin-assigned registration — all ranks (deduped by abbreviation).
  static List<PoliceDesignationEntry> simplifiedRegistration() {
    final seen = <String>{};
    final out = <PoliceDesignationEntry>[];
    for (final e in [...commissionerateRegistration, ...ruralRegistration]) {
      if (seen.add(e.abbreviation)) out.add(e);
    }
    return out;
  }
}

/// Transfer request eligibility — PI/API approve; ranks below PI/API may submit.
class TransferRequestRoles {
  TransferRequestRoles._();

  /// Designations that may approve subordinate transfer requests (Phase 3 UI).
  static const List<String> piApiDesignations = ['PI', 'API'];

  static const List<String> piSelfTransferDesignations = ['PI', 'API', 'Sr. PI'];

  /// Ranks strictly below PI/API that may submit transfer requests.
  /// Keep in sync with `belowPiApiDesignations` in firestore.rules.
  static const List<String> belowPiApiDesignations = [
    'PC',
    'NPC',
    'HC',
    'PN',
    'ASI',
    'SI',
    'PSI',
  ];

  static bool _matchesAbbreviation(String? designation, List<String> list) {
    if (designation == null || designation.trim().isEmpty) return false;
    final d = designation.trim().toLowerCase();
    return list.any((r) => r.toLowerCase() == d);
  }

  static bool isPiOrApi(String? designation) =>
      _matchesAbbreviation(designation, piApiDesignations);

  static bool isPiApiOrSrPi(String? designation) =>
      _matchesAbbreviation(designation, piSelfTransferDesignations);

  static bool isBelowPiApi(String? designation) =>
      _matchesAbbreviation(designation, belowPiApiDesignations);

  /// True when the officer may open the Request Transfer flow.
  static bool canSubmitTransferRequest(String? designation) =>
      isBelowPiApi(designation) || isPiApiOrSrPi(designation);

  /// PI/API/Sr. PI self-transfers require senior (SP/CP) approval at destination.
  static bool requiresSeniorTransferApproval(String? fromDesignation) =>
      isPiApiOrSrPi(fromDesignation);

  /// True when this user can approve/reject incoming transfer requests.
  static bool canApproveTransfers(String? designation) =>
      isPiOrApi(designation) ||
      SeniorOfficerRoles.canSwitchLocation(designation);

  /// Target designations for junior (below PI) transfers.
  static List<PoliceDesignationEntry> targetDesignationsForUnitType(
    String? unitType,
  ) {
    return PoliceDesignations.forRegistration(unitType)
        .where((entry) => isBelowPiApi(entry.abbreviation))
        .toList(growable: false);
  }

  /// Target designations for PI/API/Sr. PI self-transfer.
  static List<PoliceDesignationEntry> targetDesignationsForPiSelfTransfer() {
    return piSelfTransferDesignations
        .map(
          (abbr) => PoliceDesignationEntry(
            abbreviation: abbr,
            display: abbr == 'Sr. PI'
                ? 'Senior Police Inspector (Sr. PI)'
                : abbr == 'PI'
                    ? 'Police Inspector (PI)'
                    : 'Assistant Police Inspector (API)',
          ),
        )
        .toList(growable: false);
  }

  /// PI/API approves junior transfers; SP/CP approves PI/API/Sr. PI transfers.
  static bool isApproverForTransfer({
    required String? approverDesignation,
    required String fromDesignation,
  }) {
    if (isPiOrApi(approverDesignation)) {
      return isBelowPiApi(fromDesignation);
    }
    if (SeniorOfficerRoles.canSwitchLocation(approverDesignation)) {
      return requiresSeniorTransferApproval(fromDesignation);
    }
    return false;
  }

  /// PI/API or senior officer can assign floating users to a station.
  static bool canAssignOfficers(String? designation) =>
      isPiOrApi(designation) ||
      SeniorOfficerRoles.canSwitchLocation(designation);
}
