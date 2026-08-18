import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import 'profile_edit_screen.dart';
import 'transfer_request_screen.dart';
import 'pending_transfers_screen.dart';
import 'station_access_grants_screen.dart';
import 'add_members_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navyDark),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.navyMid.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.push(
                context,
                AppTheme.fadeSlideRoute(page: const ProfileEditScreen()),
              ),
              icon: const Icon(Icons.edit_outlined, color: AppColors.navyMid, size: 22),
              tooltip: 'Edit Profile',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeroHeader(context, auth),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xxl),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPersonalInformationSection(auth),
                        const SizedBox(height: AppSpacing.lg),
                        _buildStationInformationSection(auth),
                        if (_hasActions(auth)) ...[
                          const SizedBox(height: AppSpacing.xl),
                          _buildActionsSection(context, auth),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActions(AuthProvider auth) {
    return TransferRequestRoles.canSubmitTransferRequest(auth.designation) ||
        TransferRequestRoles.canApproveTransfers(auth.designation) ||
        TransferRequestRoles.isPiOrApi(auth.designation) ||
        TransferRequestRoles.canAssignOfficers(auth.designation);
  }

  Widget _buildHeroHeader(BuildContext context, AuthProvider auth) {
    final name = auth.displayName;
    final desig = auth.designation.isNotEmpty ? auth.designation : 'Officer';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'O';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circles
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldPrimary.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.md,
            ),
            child: Column(
              children: [
                // Avatar with outer gradient border and shield icon badge
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.goldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldPrimary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: auth.profilePhoto.isNotEmpty
                              ? Image.network(
                                  auth.profilePhoto,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) =>
                                      _buildAvatarInitial(initial),
                                )
                              : _buildAvatarInitial(initial),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.navyDark,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.goldPrimary, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          size: 13,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Officer Name
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Rank / Designation Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.badge_outlined,
                        size: 13,
                        color: AppColors.goldLight,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        desig.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldLight,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
                if (auth.stationName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          auth.stationName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarInitial(String initial) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDark,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInformationSection(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Information', Icons.person_rounded),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: _cardDecoration(),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              _buildTileItem(
                icon: Icons.person_outline_rounded,
                label: 'FULL NAME',
                value: auth.fullName,
              ),
              _buildDivider(),
              _buildTileItem(
                icon: Icons.phone_android_rounded,
                label: 'PHONE NO.',
                value: auth.phone,
              ),
              _buildDivider(),
              _buildTileItem(
                icon: Icons.mail_outline_rounded,
                label: 'GOV GMAIL',
                value: auth.email,
              ),
              _buildDivider(),
              _buildTileItem(
                icon: Icons.account_circle_outlined,
                label: 'USER NAME',
                value: auth.username,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStationInformationSection(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Station Information', Icons.shield_outlined),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: _cardDecoration(),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              _buildTileItem(
                icon: Icons.verified_user_outlined,
                label: 'DESIGNATION',
                value: auth.designation,
              ),
              _buildDivider(),
              _buildTileItem(
                icon: Icons.business_outlined,
                label: 'STATION NAME',
                value: auth.stationName,
              ),
              _buildDivider(),
              _buildTileItem(
                icon: Icons.map_outlined,
                label: 'STATION ADDRESS',
                value: auth.stationAddress,
              ),
              _buildDivider(),
              _buildTileItem(
                icon: Icons.phone_in_talk_outlined,
                label: 'STATION LANDLINE',
                value: auth.stationLandline,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context, AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Officer Actions', Icons.manage_accounts_rounded),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: _cardDecoration(),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            children: [
              if (TransferRequestRoles.canSubmitTransferRequest(auth.designation)) ...[
                _buildActionTile(
                  context,
                  title: 'Request Transfer',
                  subtitle: 'Submit transfer request to senior authority',
                  icon: Icons.swap_horiz_rounded,
                  iconColor: AppColors.cyanDark,
                  iconBg: AppColors.cyanPrimary.withValues(alpha: 0.12),
                  onTap: () => Navigator.push(
                    context,
                    AppTheme.fadeSlideRoute(page: const TransferRequestScreen()),
                  ),
                ),
              ],
              if (TransferRequestRoles.canApproveTransfers(auth.designation)) ...[
                if (TransferRequestRoles.canSubmitTransferRequest(auth.designation))
                  _buildDivider(),
                _buildActionTile(
                  context,
                  title: SeniorOfficerRoles.canSwitchLocation(auth.designation)
                      ? 'Pending PI Transfers'
                      : 'Pending Transfers',
                  subtitle: 'Review and approve subordinate transfers',
                  icon: Icons.pending_actions_rounded,
                  iconColor: AppColors.warningOrange,
                  iconBg: AppColors.warningOrange.withValues(alpha: 0.12),
                  onTap: () => Navigator.push(
                    context,
                    AppTheme.fadeSlideRoute(page: const PendingTransfersScreen()),
                  ),
                ),
              ],
              if (TransferRequestRoles.isPiOrApi(auth.designation)) ...[
                _buildDivider(),
                _buildActionTile(
                  context,
                  title: 'Dashboard Access Grants',
                  subtitle: 'Manage station dashboard permissions',
                  icon: Icons.dashboard_customize_rounded,
                  iconColor: AppColors.navyMid,
                  iconBg: AppColors.navyMid.withValues(alpha: 0.1),
                  onTap: () => Navigator.push(
                    context,
                    AppTheme.fadeSlideRoute(page: const StationAccessGrantsScreen()),
                  ),
                ),
              ],
              if (TransferRequestRoles.canAssignOfficers(auth.designation)) ...[
                _buildDivider(),
                _buildActionTile(
                  context,
                  title: 'Assign Officer',
                  subtitle: 'Assign floating officers to station',
                  icon: Icons.person_add_alt_1_rounded,
                  iconColor: AppColors.successGreen,
                  iconBg: AppColors.successGreen.withValues(alpha: 0.12),
                  onTap: () => Navigator.push(
                    context,
                    AppTheme.fadeSlideRoute(page: const AssignOfficerScreen()),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.navyMid.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 18, color: AppColors.navyMid),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final displayValue = value.isNotEmpty ? value : 'N/A';
    final isNotAvailable = value.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.navyMid.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: AppColors.navyMid,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightSubText,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayValue,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isNotAvailable
                        ? Colors.grey.shade400
                        : AppColors.navyDark,
                    fontStyle: isNotAvailable ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.lightSubText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.lightSubText.withValues(alpha: 0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.withValues(alpha: 0.1),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(
        color: AppColors.navyMid.withValues(alpha: 0.08),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}