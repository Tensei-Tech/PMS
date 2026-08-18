import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/transfer_request_model.dart';
import '../providers/auth_provider.dart';
import '../services/transfer_request_service.dart';
import '../theme/app_theme.dart';
import 'transfer_request_screen.dart';

/// Transfer outcome guidance — optional route (not a dashboard gate).
class TransferStatusScreen extends StatefulWidget {
  const TransferStatusScreen({super.key});

  @override
  State<TransferStatusScreen> createState() => _TransferStatusScreenState();
}

class _TransferStatusScreenState extends State<TransferStatusScreen> {
  final _service = TransferRequestService();
  TransferRequest? _request;
  bool _loading = true;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = context.read<AuthProvider>().uid;
    try {
      final req = await _service.getLatestStatusRequestForUser(uid);
      if (!mounted) return;
      setState(() {
        _request = req;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshProfile() async {
    setState(() => _refreshing = true);
    try {
      await context.read<AuthProvider>().refreshProfileFromFirestore();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile refreshed. Your dashboard now reflects your current posting.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final request = _request;
    final isApproved =
        request?.status == TransferRequestStatus.approved;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          'Transfer Status',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navyDark),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.navyMid),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.infoBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.infoBlue.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: AppColors.infoBlue),
                            const SizedBox(width: 8),
                            Text(
                              isApproved
                                  ? 'Transfer approved'
                                  : 'Transfer status',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navyDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          isApproved
                              ? 'Your transfer has been approved. Your existing account has '
                                  'been updated to your new posting — no new registration '
                                  'or invite link is required.'
                              : 'View the latest status of your transfer request below.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.lightText,
                            height: 1.45,
                          ),
                        ),
                        if (isApproved) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Tap "Refresh my profile" below, or sign out and sign back in, '
                            'to load your new station dashboard.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.lightText,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (request != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _detailCard(request),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  if (isApproved)
                    ElevatedButton(
                      onPressed: _refreshing ? null : _refreshProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navyMid,
                      ),
                      child: _refreshing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Refresh my profile',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        AppTheme.fadeSlideRoute(
                          page: const TransferRequestScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'View transfer details',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => auth.fullLogout(),
                    child: Text(
                      'Sign out',
                      style: GoogleFonts.poppins(
                        color: AppColors.dangerRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _detailCard(TransferRequest request) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer details',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _line('Status', request.status.toUpperCase()),
          _line('From', request.fromStationName),
          _line('To station', request.toStationName),
          _line('To designation', request.toDesignation),
          _line('Target district', request.toDistrict),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label: ${value.isNotEmpty ? value : '—'}',
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.lightText),
      ),
    );
  }
}
