import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/maharashtra_police_stations_repository.dart';
import '../data/police_stations_repository.dart';
import '../models/transfer_request_model.dart';
import '../providers/auth_provider.dart';
import '../services/transfer_request_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/station_address_parser.dart';
import '../widgets/searchable_picker_field.dart';

/// Request Transfer + My Transfer Status for officers below PI/API rank and PI/API/Sr. PI self-transfers.
class TransferRequestScreen extends StatefulWidget {
  const TransferRequestScreen({super.key});

  @override
  State<TransferRequestScreen> createState() => _TransferRequestScreenState();
}

class _TransferRequestScreenState extends State<TransferRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();
  final _transferService = TransferRequestService();

  String? _unitType;
  String? _district;
  String? _station;
  String? _targetDesignation;

  TransferRequest? _activeRequest;
  bool _loading = true;
  bool _submitting = false;
  bool _cancelling = false;

  late String _fromState;
  late String _fromDistrict;
  late String _fromUnitType;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    if (!TransferRequestRoles.canSubmitTransferRequest(auth.designation)) {
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }

    final parsed = StationAddressParser.parse(auth.stationAddress);
    _fromState = parsed.state.isNotEmpty ? parsed.state : 'Maharashtra';
    _fromDistrict = parsed.district;
    _fromUnitType = parsed.unitType;

    try {
      await MaharashtraPoliceStationsRepository.initialize();
    } catch (_) {
      // Offline / CSV missing — form may still render with fallbacks.
    }

    try {
      final active = await _transferService.getLatestStatusRequestForUser(auth.uid);
      if (!mounted) return;
      setState(() {
        _activeRequest = active;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('Could not load transfer status. Please try again.',
          AppColors.dangerRed);
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _refreshProfileAfterApproval() async {
    await context.read<AuthProvider>().refreshProfileFromFirestore();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile refreshed.',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: color,
      ),
    );
  }

  List<String> _districtsForUnitType(String unitType) {
    if (_fromState == 'Maharashtra') {
      final districts = <String>{};
      for (final station in MaharashtraPoliceStationsRepository.getAllStations()) {
        if (station.type == unitType) {
          districts.add(station.districtName);
        }
      }
      return districts.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
    return const [];
  }

  List<String> _stationsForSelection(String district, String unitType) {
    if (_fromState == 'Maharashtra') {
      return MaharashtraPoliceStationsRepository.getStationNamesForSelection(
        district: district,
        unitType: unitType,
      );
    }
    return PoliceStationsRepository.forSelection(
      unitType: unitType,
      state: _fromState,
      district: district,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_unitType == null ||
        _district == null ||
        _station == null ||
        _targetDesignation == null) {
      _showSnack('Please complete all target posting fields.',
          AppColors.warningOrange);
      return;
    }

    final auth = context.read<AuthProvider>();
    if (_activeRequest?.status == TransferRequestStatus.pending) {
      _showSnack('You already have an active transfer request.',
          AppColors.warningOrange);
      return;
    }

    setState(() => _submitting = true);
    try {
      final activeCheck =
          await _transferService.getActiveRequestForUser(auth.uid);
      if (activeCheck != null) {
        if (!mounted) return;
        setState(() {
          _activeRequest = activeCheck;
          _submitting = false;
        });
        _showSnack('You already have an active transfer request.',
            AppColors.warningOrange);
        return;
      }

      final request = TransferRequest(
        id: '',
        requestedByUid: auth.uid,
        requestedByEmail: auth.email,
        requestedByName: auth.fullName,
        fromStationName: auth.homeStationName,
        fromDesignation: auth.designation,
        fromUnitType: _fromUnitType,
        fromState: _fromState,
        fromDistrict: _fromDistrict,
        toStationName: _station!,
        toDesignation: _targetDesignation!,
        toUnitType: _unitType!,
        toState: _fromState,
        toDistrict: _district!,
        status: TransferRequestStatus.pending,
        requesterNote: _noteCtrl.text.trim(),
      );

      await _transferService.createRequest(request);
      final created = await _transferService.getLatestStatusRequestForUser(auth.uid);

      if (!mounted) return;
      setState(() {
        _activeRequest = created;
        _submitting = false;
      });
      final approvalTarget = TransferRequestRoles.requiresSeniorTransferApproval(
              auth.designation)
          ? 'destination SP/CP approval'
          : 'destination PI/API approval';
      _showSnack('Transfer request submitted for $approvalTarget.',
          AppColors.successGreen);
    } catch (e) {
      debugPrint('Transfer submit failed: $e');
      if (!mounted) return;
      setState(() => _submitting = false);
      _showSnack(
        'Failed to submit transfer request. Check your connection and try again.',
        AppColors.dangerRed,
      );
    }
  }

  Future<void> _cancelActiveRequest() async {
    final request = _activeRequest;
    if (request == null || request.status != TransferRequestStatus.pending) {
      return;
    }

    setState(() => _cancelling = true);
    try {
      await _transferService.cancelRequest(request.id);
      if (!mounted) return;
      setState(() {
        _activeRequest = null;
        _cancelling = false;
      });
      _showSnack('Transfer request cancelled.', AppColors.successGreen);
    } catch (e) {
      debugPrint('Transfer cancel failed: $e');
      if (!mounted) return;
      setState(() => _cancelling = false);
      _showSnack('Could not cancel the request.', AppColors.dangerRed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canSubmit =
        TransferRequestRoles.canSubmitTransferRequest(auth.designation);
    final hasBlockingRequest =
        _activeRequest?.status == TransferRequestStatus.pending;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          'Request Transfer',
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
          : !canSubmit
              ? _buildIneligible(auth)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_activeRequest != null) ...[
                        _buildStatusCard(_activeRequest!),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (!hasBlockingRequest) _buildRequestForm(auth),
                    ],
                  ),
                ),
    );
  }

  Widget _buildIneligible(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 48, color: AppColors.lightSubText),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Transfer requests are available to officers below PI/API rank, and to PI/API/Sr. PI for self-transfer.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your designation: ${auth.designation.isNotEmpty ? auth.designation : 'N/A'}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.lightSubText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(TransferRequest request) {
    final awaitingSenior = TransferRequestRoles.requiresSeniorTransferApproval(
      request.fromDesignation,
    );
    final pendingMessage = awaitingSenior
        ? 'Waiting for SP/CP approval at your destination district.'
        : 'Waiting for PI/API approval at your destination station or district.';
    final rejectedMessage = awaitingSenior
        ? 'Your transfer request was rejected by the destination SP/CP.'
        : 'Your transfer request was rejected by the destination PI/API.';

    final statusColor = switch (request.status) {
      TransferRequestStatus.pending => AppColors.warningOrange,
      TransferRequestStatus.approved => AppColors.infoBlue,
      TransferRequestStatus.rejected => AppColors.dangerRed,
      _ => AppColors.lightSubText,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz_rounded, color: statusColor, size: 22),
              const SizedBox(width: 8),
              Text(
                'My Transfer Status',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _statusRow('Status', request.status.toUpperCase()),
          _statusRow('From', request.fromStationName),
          _statusRow('To station', request.toStationName),
          _statusRow('To designation', request.toDesignation),
          _statusRow('Target district', request.toDistrict),
          if (request.requesterNote.isNotEmpty)
            _statusRow('Your note', request.requesterNote),
          if (request.status == TransferRequestStatus.pending) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              pendingMessage,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.lightSubText,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _cancelling ? null : _cancelActiveRequest,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.dangerRed,
                  side: BorderSide(color: AppColors.dangerRed.withValues(alpha: 0.5)),
                ),
                child: _cancelling
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Cancel Request',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ] else if (request.status == TransferRequestStatus.approved) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your transfer has been approved. Your existing account has been updated '
              'to your new posting — no new registration is required. Tap "Refresh profile" '
              'below, or sign out and sign back in, to see your new station dashboard.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.infoBlue,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _refreshProfileAfterApproval,
                child: Text(
                  'Refresh profile',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ] else if (request.status == TransferRequestStatus.rejected) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              request.rejectionReason?.trim().isNotEmpty == true
                  ? 'Rejected: ${request.rejectionReason!.trim()}'
                  : rejectedMessage,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.warningOrange,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.lightSubText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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

  Widget _buildRequestForm(AuthProvider auth) {
    final isSelfTransfer = TransferRequestRoles.isPiApiOrSrPi(auth.designation);
    final designationItems = isSelfTransfer
        ? TransferRequestRoles.targetDesignationsForPiSelfTransfer()
        : TransferRequestRoles.targetDesignationsForUnitType(_unitType);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current posting',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 8),
          _summaryTile(auth.homeStationName, auth.designation, _fromDistrict),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Target posting',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _UnitTypeSelector(
            value: _unitType,
            onChanged: (v) {
              setState(() {
                _unitType = v;
                _district = null;
                _station = null;
                _targetDesignation = null;
              });
            },
          ),
          if (_unitType != null) ...[
            SearchablePickerField(
              label: 'Target District / Commissionerate',
              hintText: 'Select district',
              leadingIcon: Icons.map_rounded,
              value: _district,
              items: _districtsForUnitType(_unitType!),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Target district is required' : null,
              onChanged: (v) {
                setState(() {
                  _district = v;
                  _station = null;
                });
              },
            ),
          ],
          if (_unitType != null && _district != null) ...[
            if (_stationsForSelection(_district!, _unitType!).isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  'No stations found for this district and unit type.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.warningOrange,
                  ),
                ),
              )
            else
              SearchablePickerField(
                label: 'Target Police Station',
                hintText: 'Select station',
                leadingIcon: Icons.local_police_rounded,
                value: _station,
                items: _stationsForSelection(_district!, _unitType!),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Target station is required' : null,
                onChanged: (v) => setState(() => _station = v),
              ),
          ],
          if (_unitType != null && designationItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DropdownButtonFormField<String>(
                key: ValueKey('target-desig-${isSelfTransfer ? 'pi' : _unitType}'),
                initialValue: _targetDesignation,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Target Designation',
                  prefixIcon: const Icon(Icons.badge_rounded),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                items: designationItems
                    .map(
                      (d) => DropdownMenuItem(
                        value: d.abbreviation,
                        child: Text(d.display, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (v) => setState(() => _targetDesignation = v),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Target designation is required' : null,
              ),
            ),
          TextFormField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Note to approver (optional)',
              hintText: 'Reason or additional context',
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navyMid,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Submit Transfer Request',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(String station, String designation, String district) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(station,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: AppColors.navyDark)),
          if (district.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(district,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.lightSubText)),
          ],
          const SizedBox(height: 4),
          Text(designation,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.navyMid)),
        ],
      ),
    );
  }
}

class _UnitTypeSelector extends StatelessWidget {
  const _UnitTypeSelector({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Unit Type',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                value: PoliceStationsRepository.commissionerate,
                // ignore: deprecated_member_use
                groupValue: value,
                // ignore: deprecated_member_use
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
                contentPadding: EdgeInsets.zero,
                title: Text('Commissionerate',
                    style: GoogleFonts.poppins(fontSize: 13)),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                value: PoliceStationsRepository.superintendent,
                // ignore: deprecated_member_use
                groupValue: value,
                // ignore: deprecated_member_use
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
                contentPadding: EdgeInsets.zero,
                title:
                    Text('Rural', style: GoogleFonts.poppins(fontSize: 13)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
