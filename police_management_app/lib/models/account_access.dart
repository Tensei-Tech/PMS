import 'user_model.dart';

/// Login and session access rules aligned with the admin console.
class AccountAccess {
  const AccountAccess._({required this.allowed, this.blockMessage});

  final bool allowed;
  final String? blockMessage;

  static const archivedMessage =
      'Your account has been archived by the admin. Contact your Master Admin for access.';
  static const pendingApprovalMessage =
      'Your account is still pending admin approval.';
  static const rejectedMessage =
      'Your registration request was rejected by the administration.';
  static const deactivatedMessage =
      'Your account has been deactivated. Contact your administrator.';

  static AccountAccess evaluate(UserModel profile) {
    final accountStatus = profile.accountStatus.trim().toLowerCase();
    final status = profile.status.trim().toLowerCase();

    if (accountStatus == UserAccountStatus.archived || accountStatus == 'archived') {
      return const AccountAccess._(
        allowed: false,
        blockMessage: archivedMessage,
      );
    }
    if (status == 'inactive') {
      return const AccountAccess._(
        allowed: false,
        blockMessage: archivedMessage,
      );
    }
    if (accountStatus == UserAccountStatus.rejected || status == 'rejected') {
      return const AccountAccess._(
        allowed: false,
        blockMessage: rejectedMessage,
      );
    }
    if (accountStatus == UserAccountStatus.pendingApproval ||
        accountStatus == UserAccountStatus.pending) {
      return const AccountAccess._(
        allowed: false,
        blockMessage: pendingApprovalMessage,
      );
    }
    if (accountStatus != UserAccountStatus.active) {
      return const AccountAccess._(
        allowed: false,
        blockMessage: deactivatedMessage,
      );
    }
    return const AccountAccess._(allowed: true);
  }

  /// Real-time stream: sign out when admin archives, rejects, or deactivates.
  static bool shouldForceLogout(UserModel profile) {
    final accountStatus = profile.accountStatus.trim().toLowerCase();
    final status = profile.status.trim().toLowerCase();

    return accountStatus == UserAccountStatus.archived ||
        accountStatus == UserAccountStatus.rejected ||
        status == 'inactive' ||
        status == 'rejected' ||
        accountStatus == UserAccountStatus.pendingApproval ||
        accountStatus == UserAccountStatus.pending ||
        accountStatus != UserAccountStatus.active;
  }
}
