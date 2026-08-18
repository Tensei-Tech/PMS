// lib/utils/police_rbac_helper.dart
// Centralized Role-Based Access Control (RBAC) engine for Maharashtra Police hierarchy.

import '../modules/core/models/base_record.dart';
import '../providers/auth_provider.dart';
import 'app_constants.dart';

enum PoliceRoleTier {
  /// Tier 1: PC, NPC, HC, ASI, PSI, API, regular PI (Non-incharge)
  regularOfficer,

  /// Tier 2: PI (Incharge) / Senior PI / SHO
  stationIncharge,

  /// Tier 3: ACP (Cities) / Dy. SP, SDPO, ASP (Districts)
  divisionHead,

  /// Tier 4: DCP, SP, Addl. CP, Addl. SP, Jt. CP, CP
  districtLeadership,

  /// Tier 5: IT Administrator / HQ Console
  superAdmin,
}

class PoliceRbacHelper {
  PoliceRbacHelper._();

  /// Returns the matching [PoliceRoleTier] for the logged-in officer.
  static PoliceRoleTier getTier(AuthProvider auth) {
    if (auth.isAdmin) {
      return PoliceRoleTier.superAdmin;
    }

    final designation = auth.designation.trim().toLowerCase();

    // Tier 4: Top leadership (CP, Jt. CP, Addl. CP, DCP, SP, Addl. SP)
    if (SeniorOfficerRoles.isCpLevel(auth.designation) ||
        SeniorOfficerRoles.isSpLevel(auth.designation)) {
      if (designation != 'acp' &&
          designation != 'dy. sp' &&
          designation != 'asp') {
        return PoliceRoleTier.districtLeadership;
      }
    }

    // Tier 3: Division heads (ACP, Dy. SP, SDPO, ASP)
    if (designation == 'acp' ||
        designation.contains('assistant commissioner') ||
        designation == 'dy. sp' ||
        designation == 'sdpo' ||
        designation == 'asp' ||
        designation.contains('deputy superintendent') ||
        designation.contains('assistant superintendent')) {
      return PoliceRoleTier.divisionHead;
    }

    // Tier 2: Station in-charge (Sr. PI / SHO or marked in designation/role)
    if (designation == 'sr. pi' ||
        designation == 'senior police inspector' ||
        designation == 'senior pi' ||
        designation.contains('incharge') ||
        designation.contains('sho') ||
        auth.isSupervisor) {
      return PoliceRoleTier.stationIncharge;
    }

    // Tier 1: Regular field officer / investigating officer
    return PoliceRoleTier.regularOfficer;
  }

  /// 🛡️ CORE RULE: Whether [auth] officer is allowed to EDIT [record].
  ///
  /// Rule 1: SuperAdmin / Admin can edit anything.
  /// Rule 2: Station In-charge (Sr. PI) can edit ANY case in their station.
  /// Rule 3: Regular officers can ONLY edit their own created / assigned cases.
  static bool canEditRecord(ModuleRecord record, AuthProvider auth) {
    if (auth.isAdmin) return true;

    final tier = getTier(auth);

    // Station In-charge has full edit authority in their station
    if (tier == PoliceRoleTier.stationIncharge) {
      return true;
    }

    final userUid = auth.uid.trim();
    final userName = auth.displayName.trim().toLowerCase();

    // Check if current user is the creator (by UID or Name)
    if (userUid.isNotEmpty && record.createdBy.trim() == userUid) {
      return true;
    }
    if (userName.isNotEmpty &&
        record.createdBy.trim().toLowerCase() == userName) {
      return true;
    }

    // Check if current user is the assigned IO (by UID or Name)
    final assignedUid = record.assignedOfficerUid?.trim() ?? '';
    if (userUid.isNotEmpty &&
        assignedUid.isNotEmpty &&
        assignedUid == userUid) {
      return true;
    }
    if (userName.isNotEmpty &&
        record.assignedOfficer.trim().toLowerCase() == userName) {
      return true;
    }

    // Otherwise, read-only
    return false;
  }

  /// 🔔 Whether [auth] officer has authority to send reminders/directives to IOs.
  /// Allowed for: Station In-charge (Sr. PI), Division Heads (ACP / Dy. SP),
  /// District Leadership (DCP / SP / CP), and Admin.
  static bool canSendReminder(AuthProvider auth) {
    if (auth.isAdmin) return true;
    final tier = getTier(auth);
    return tier == PoliceRoleTier.stationIncharge ||
        tier == PoliceRoleTier.divisionHead ||
        tier == PoliceRoleTier.districtLeadership;
  }

  /// 🔄 Whether [auth] officer has authority to switch between police stations.
  /// Allowed for: ACP and above (ACP, Dy. SP, DCP, SP, CP) and Admin.
  static bool canSwitchStation(AuthProvider auth) {
    if (auth.isAdmin) return true;
    final tier = getTier(auth);
    return tier == PoliceRoleTier.divisionHead ||
        tier == PoliceRoleTier.districtLeadership;
  }

  /// User-facing label for the active role tier.
  static String getRoleLabel(PoliceRoleTier tier) {
    switch (tier) {
      case PoliceRoleTier.regularOfficer:
        return 'Investigating Officer';
      case PoliceRoleTier.stationIncharge:
        return 'Station In-charge';
      case PoliceRoleTier.divisionHead:
        return 'Division Head';
      case PoliceRoleTier.districtLeadership:
        return 'Executive Leadership';
      case PoliceRoleTier.superAdmin:
        return 'Super Admin';
    }
  }
}
