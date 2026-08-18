import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/transfer_request_model.dart';
import '../providers/auth_provider.dart';
import '../services/transfer_request_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';

/// Approver queue: PI/API for junior transfers; SP/CP for PI/API/Sr. PI transfers.
class PendingTransfersScreen extends StatefulWidget {
  const PendingTransfersScreen({super.key});

  @override
  State<PendingTransfersScreen> createState() => _PendingTransfersScreenState();
}

class _PendingTransfersScreenState extends State<PendingTransfersScreen> {
  final _service = TransferRequestService();
  List<TransferRequest> _pending = [];
  bool _loading = true;
  String? _processingId;
  String _action = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    try {
      final list = await _service.getPendingForApprover(
        homeStationName: auth.homeStationName,
        district: auth.district,
        approverDesignation: auth.designation,
      );
      if (!mounted) return;
      setState(() {
        _pending = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('Failed to load pending transfers.', AppColors.dangerRed);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _approve(TransferRequest request) async {
    if (request.toStationName.trim().isEmpty &&
        request.toDistrict.trim().isEmpty) {
      _snack(
        'This request is missing destination details and cannot be approved.',
        AppColors.warningOrange,
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    setState(() {
      _processingId = request.id;
      _action = 'approve';
    });
    try {
      await _service.approveTransfer(
        request: request,
        approverUid: auth.uid,
      );
      if (!mounted) return;
      _snack('Transfer approved. Officer posting updated in place.',
          AppColors.successGreen);
      await _load();
    } catch (e) {
      debugPrint('approve failed: $e');
      if (!mounted) return;
      _snack('Approval failed. Check your connection or permissions.',
          AppColors.dangerRed);
    } finally {
      if (mounted) {
        setState(() {
          _processingId = null;
          _action = '';
        });
      }
    }
  }

  Future<void> _reject(TransferRequest request) async {
    final auth = context.read<AuthProvider>();
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reject transfer?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
            hintText: 'Brief reason for rejection',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    final reason = reasonCtrl.text.trim();
    reasonCtrl.dispose();
    if (confirmed != true || !mounted) return;

    setState(() {
      _processingId = request.id;
      _action = 'reject';
    });
    try {
      await _service.rejectTransfer(
        requestId: request.id,
        approverUid: auth.uid,
        rejectionReason: reason,
      );
      if (!mounted) return;
      _snack('Transfer request rejected.', AppColors.warningOrange);
      await _load();
    } catch (e) {
      debugPrint('reject failed: $e');
      if (!mounted) return;
      _snack('Rejection failed.', AppColors.dangerRed);
    } finally {
      if (mounted) {
        setState(() {
          _processingId = null;
          _action = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isApprover = TransferRequestRoles.canApproveTransfers(auth.designation);
    final isSenior = SeniorOfficerRoles.canSwitchLocation(auth.designation);
    final title = isSenior ? 'Pending PI Transfers' : 'Pending Transfers';
    final emptyMessage = isSenior
        ? 'No pending PI/API/Sr. PI transfer requests for your jurisdiction.'
        : 'No pending junior transfer requests for incoming transfers to your station or district.';
    final deniedMessage = isSenior
        ? 'Only SP/CP or other senior officers with multi-location access can review PI transfer requests.'
        : 'Only PI or API officers can review junior transfer requests.';

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navyDark),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: !isApprover
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  deniedMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: AppColors.lightText),
                ),
              ),
            )
          : _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.navyMid),
                )
              : _pending.isEmpty
                  ? Center(
                      child: Text(
                        emptyMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: AppColors.lightSubText,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: _pending.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final req = _pending[index];
                        final busy = _processingId == req.id;
                        return _RequestCard(
                          request: req,
                          busy: busy,
                          action: _action,
                          onApprove: () => _approve(req),
                          onReject: () => _reject(req),
                        );
                      },
                    ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.busy,
    required this.action,
    required this.onApprove,
    required this.onReject,
  });

  final TransferRequest request;
  final bool busy;
  final String action;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
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
            request.requestedByName,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark,
            ),
          ),
          Text(
            request.requestedByEmail,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.lightSubText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _row('Current station', request.fromStationName),
          _row('Current rank', request.fromDesignation),
          _row('From district', request.fromDistrict),
          const Divider(height: 24),
          _row('Target station', request.toStationName),
          _row('Target rank', request.toDesignation),
          _row('Target district', request.toDistrict),
          _row('Unit type', request.toUnitType),
          if (request.requesterNote.isNotEmpty)
            _row('Note', request.requesterNote),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dangerRed,
                  ),
                  child: busy && action == 'reject'
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Reject',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: busy ? null : onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyMid,
                  ),
                  child: busy && action == 'approve'
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Approve',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.lightSubText)),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.navyDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
