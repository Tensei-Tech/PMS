import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/pending_approvals_scope.dart';

/// Pending officer registration / access requests for superiors in hierarchy.
class PendingApprovalsScreen extends StatefulWidget {
  const PendingApprovalsScreen({super.key});

  @override
  State<PendingApprovalsScreen> createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends State<PendingApprovalsScreen> {
  final _firestore = FirestoreService();
  final Set<String> _processingUids = {};

  Stream<List<UserModel>> _requestsStream(AuthProvider auth) {
    return _firestore.watchPendingRegistrationRequests(
      isSuperAdmin: PendingApprovalsScope.isSuperAdmin(auth),
      canReview: PendingApprovalsScope.canReviewRegistrations(auth),
      approverDesignation: auth.designation,
      approverZone: PendingApprovalsScope.approverZone(auth),
      approverStation: auth.stationName,
    );
  }

  Future<void> _approve(UserModel user) async {
    if (_processingUids.contains(user.uid)) return;
    setState(() => _processingUids.add(user.uid));
    try {
      await _firestore.approveUserRegistration(user.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${user.name} approved.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'permission-denied'
                ? 'Permission denied. You may not approve this request.'
                : 'Approval failed: ${e.message ?? e.code}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _processingUids.remove(user.uid));
    }
  }

  Future<void> _reject(UserModel user) async {
    if (_processingUids.contains(user.uid)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Reject registration?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Reject ${user.name}\'s access request?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _processingUids.add(user.uid));
    try {
      await _firestore.rejectUserRegistration(user.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${user.name} rejected.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.warningOrange,
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'permission-denied'
                ? 'Permission denied. You may not reject this request.'
                : 'Rejection failed: ${e.message ?? e.code}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _processingUids.remove(user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canReview = PendingApprovalsScope.canReviewRegistrations(auth);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.navyDark, size: 20),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pending Approvals',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDark,
              ),
            ),
            Text(
              PendingApprovalsScope.scopeDescription(auth),
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.lightSubText,
              ),
            ),
          ],
        ),
      ),
      body: !canReview
          ? _AccessDeniedState(designation: auth.designation)
          : StreamBuilder<List<UserModel>>(
              stream: _requestsStream(auth),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Could not load requests',
                    subtitle: 'Please try again.',
                  );
                }

                final requests = snapshot.data ?? const [];
                if (requests.isEmpty) {
                  return _EmptyState(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'No pending approvals',
                    subtitle: 'Registration requests in your jurisdiction will appear here.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final user = requests[index];
                    final busy = _processingUids.contains(user.uid);
                    return _PendingApprovalCard(
                      user: user,
                      busy: busy,
                      onApprove: () => _approve(user),
                      onReject: () => _reject(user),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _PendingApprovalCard extends StatelessWidget {
  const _PendingApprovalCard({
    required this.user,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  final UserModel user;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final zoneLabel = user.effectiveZone.isNotEmpty
        ? user.effectiveZone
        : 'Zone not specified';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.warningOrange.withValues(alpha: 0.15),
                  child: Icon(Icons.person_rounded,
                      color: AppColors.warningOrange, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.trim().isNotEmpty ? user.name : 'Unnamed applicant',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDark,
                        ),
                      ),
                      Text(
                        user.designation.trim().isNotEmpty
                            ? user.designation
                            : 'Designation pending',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.infoBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warningOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pending',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warningOrange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.location_city_rounded,
              label: 'Station',
              value: user.stationName.trim().isNotEmpty
                  ? user.stationName
                  : 'Not assigned',
            ),
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.map_rounded,
              label: 'Zone',
              value: zoneLabel,
            ),
            if (user.email.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : onReject,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: Text(
                      'Reject',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.dangerRed,
                      side: BorderSide(
                        color: AppColors.dangerRed.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: busy ? null : onApprove,
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      'Approve',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.lightSubText),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.lightSubText,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: AppColors.navyDark.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.lightSubText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessDeniedState extends StatelessWidget {
  const _AccessDeniedState({required this.designation});

  final String designation;

  @override
  Widget build(BuildContext context) {
    return _EmptyState(
      icon: Icons.lock_outline_rounded,
      title: 'Approvals not available',
      subtitle: designation.trim().isEmpty
          ? 'Your role cannot review registration requests.'
          : '$designation officers cannot review registration requests.',
    );
  }
}
