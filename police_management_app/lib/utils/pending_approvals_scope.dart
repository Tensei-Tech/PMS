// lib/utils/pending_approvals_scope.dart
// Role-based scope for pending officer registration approvals.

import '../providers/auth_provider.dart';
import 'app_constants.dart';

class PendingApprovalsScope {
  PendingApprovalsScope._();

  static bool isSuperAdmin(AuthProvider auth) {
    final role = auth.role.trim().toLowerCase();
    return role == 'admin' ||
        role == 'super_admin' ||
        role == 'super admin';
  }

  /// Officers who may review pending registration requests.
  static bool canReviewRegistrations(AuthProvider auth) {
    if (isSuperAdmin(auth)) return true;
    if (SeniorOfficerRoles.canSwitchLocation(auth.designation)) return true;
    if (TransferRequestRoles.isPiOrApi(auth.designation)) return true;
    return false;
  }

  static bool usesZoneFilter(String? designation) {
    if (designation == null || designation.trim().isEmpty) return false;
    final d = designation.trim().toLowerCase();
    const zoneScoped = ['sp', 'addl. sp', 'dy. sp', 'asp', 'dcp'];
    return zoneScoped.any((r) => r == d) ||
        SeniorOfficerRoles.canSwitchLocation(designation);
  }

  static bool usesStationFilter(String? designation) =>
      TransferRequestRoles.isPiOrApi(designation);

  static String approverZone(AuthProvider auth) => auth.zone.trim();

  static String scopeDescription(AuthProvider auth) {
    if (isSuperAdmin(auth)) return 'All pending registration requests';
    if (usesStationFilter(auth.designation) &&
        !usesZoneFilter(auth.designation)) {
      return 'Pending requests for ${auth.stationName}';
    }
    final zone = approverZone(auth);
    if (zone.isNotEmpty) {
      return 'Pending requests in $zone';
    }
    return 'Pending registration requests in your jurisdiction';
  }
}
