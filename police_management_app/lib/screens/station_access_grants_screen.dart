import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/case_visibility.dart';

/// PI/API screen to grant station-wide dashboard access to junior officers.
class StationAccessGrantsScreen extends StatefulWidget {
  const StationAccessGrantsScreen({super.key});

  @override
  State<StationAccessGrantsScreen> createState() =>
      _StationAccessGrantsScreenState();
}

class _StationAccessGrantsScreenState extends State<StationAccessGrantsScreen> {
  final _searchCtrl = TextEditingController();
  final _firestore = FirestoreService();
  String _query = '';
  List<UserModel> _officers = [];
  bool _loading = true;
  String? _loadError;
  final Set<String> _savingUids = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOfficers());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOfficers() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final station = auth.homeStationName.trim();
    if (station.isEmpty) {
      setState(() {
        _loading = false;
        _officers = [];
        _loadError = 'Your home station is not set on your profile.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _loadError = null;
    });

    final users = await _firestore.getUsersAtStation(station);
    if (!mounted) return;

    setState(() {
      _officers = users;
      _loading = false;
      if (users.isEmpty) {
        _loadError = null;
      }
    });
  }

  List<UserModel> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _officers;
    return _officers
        .where((o) =>
            o.name.toLowerCase().contains(q) ||
            o.designation.toLowerCase().contains(q))
        .toList();
  }

  bool _isGranted(UserModel user) {
    if (!CaseVisibility.designationEligibleForGrant(user.designation)) {
      return true;
    }
    return user.stationCaseViewGranted;
  }

  int get _grantedCount =>
      _officers.where((o) => _isGranted(o)).length;

  Future<void> _toggleGrant(UserModel user, bool value) async {
    if (!CaseVisibility.designationEligibleForGrant(user.designation)) return;
    if (_savingUids.contains(user.uid)) return;

    setState(() => _savingUids.add(user.uid));

    try {
      await _firestore.updateUserField(
        user.uid,
        'stationCaseViewGranted',
        value,
      );
      if (!mounted) return;
      setState(() {
        _officers = _officers.map((o) {
          if (o.uid != user.uid) return o;
          return UserModel(
            uid: o.uid,
            name: o.name,
            badgeNumber: o.badgeNumber,
            designation: o.designation,
            email: o.email,
            phone: o.phone,
            stationName: o.stationName,
            stationAddress: o.stationAddress,
            stationLandline: o.stationLandline,
            govtId: o.govtId,
            photoUrl: o.photoUrl,
            role: o.role,
            additionalStations: o.additionalStations,
            accountStatus: o.accountStatus,
            district: o.district,
            stationCaseViewGranted: value,
            createdAt: o.createdAt,
          );
        }).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Station-wide access granted to ${user.name}.'
                : 'Station-wide access revoked for ${user.name}.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      final message = e.code == 'permission-denied'
          ? 'Permission denied. Deploy updated Firestore rules (Phase 2) if this persists.'
          : 'Could not save: ${e.message ?? e.code}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save: $e', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _savingUids.remove(user.uid));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isApprover = TransferRequestRoles.isPiOrApi(auth.designation);
    final filtered = _filtered;
    final stationLabel = auth.homeStationName.isNotEmpty
        ? auth.homeStationName
        : 'Your station';

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          'Dashboard access grants',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navyDark),
        actions: [
          if (isApprover && !_loading)
            IconButton(
              tooltip: 'Refresh roster',
              onPressed: _loadOfficers,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: !isApprover
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Only PI or API officers can manage station dashboard access.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: AppColors.lightText),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.infoBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.infoBlue.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stationLabel,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: AppColors.navyDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Grant station-wide access to case lists, pending reports, '
                          'monthly summaries, and IO-wise views for officers at your '
                          'home station.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.lightText,
                            height: 1.4,
                          ),
                        ),
                        if (_officers.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '$_grantedCount of ${_officers.length} officers with station-wide view',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navyMid,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search by name or rank',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.lightBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.lightBorder),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _loadError != null
                          ? _buildMessageState(_loadError!)
                          : filtered.isEmpty
                              ? _buildEmptyState()
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.lg,
                                    0,
                                    AppSpacing.lg,
                                    AppSpacing.lg,
                                  ),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: AppSpacing.sm),
                                  itemBuilder: (context, index) {
                                    final officer = filtered[index];
                                    final eligible =
                                        CaseVisibility.designationEligibleForGrant(
                                      officer.designation,
                                    );
                                    return _OfficerGrantCard(
                                      user: officer,
                                      granted: _isGranted(officer),
                                      eligible: eligible,
                                      saving: _savingUids.contains(officer.uid),
                                      onChanged: eligible
                                          ? (v) => _toggleGrant(officer, v)
                                          : null,
                                    );
                                  },
                                ),
                ),
              ],
            ),
    );
  }

  Widget _buildMessageState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.lightSubText,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded,
                size: 48, color: AppColors.lightSubText),
            const SizedBox(height: AppSpacing.md),
            Text(
              _query.trim().isEmpty
                  ? 'No officers at this station'
                  : 'No officers match "${_query.trim()}"',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.lightSubText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfficerGrantCard extends StatelessWidget {
  const _OfficerGrantCard({
    required this.user,
    required this.granted,
    required this.eligible,
    required this.saving,
    required this.onChanged,
  });

  final UserModel user;
  final bool granted;
  final bool eligible;
  final bool saving;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.navyMid.withValues(alpha: 0.12),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: AppColors.navyMid,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                _DesignationBadge(designation: user.designation),
                if (!eligible) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Station-wide by rank',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.lightSubText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (saving)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Station-wide',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.lightSubText,
                  ),
                ),
                Switch.adaptive(
                  value: granted,
                  activeTrackColor: AppColors.navyMid.withValues(alpha: 0.45),
                  activeThumbColor: AppColors.navyMid,
                  onChanged: onChanged,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DesignationBadge extends StatelessWidget {
  const _DesignationBadge({required this.designation});

  final String designation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.goldPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        designation,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.navyDark,
        ),
      ),
    );
  }
}
