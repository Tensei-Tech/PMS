// lib/screens/ad_record_detail_screen.dart
// Full read-only view for A.D (Accidental Death) — all fields from ad_form_screen / Firestore.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../modules/core/models/base_record.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/ad_firestore_payload.dart';
import '../utils/case_visibility.dart';
import '../utils/police_rbac_helper.dart';
import '../widgets/send_reminder_dialog.dart';
import '../widgets/access_denied_view.dart';
import '../widgets/ad_form_dynamic_document_view.dart';
import 'ad_form_screen.dart';

class AdRecordDetailScreen extends StatefulWidget {
  final ModuleRecord record;

  const AdRecordDetailScreen({
    super.key,
    required this.record,
  });

  @override
  State<AdRecordDetailScreen> createState() => _AdRecordDetailScreenState();
}

class _AdRecordDetailScreenState extends State<AdRecordDetailScreen> {
  final _firestore = FirestoreService();

  late ModuleRecord _hubRecord;
  Map<String, dynamic>? _submittedData;
  Map<String, dynamic>? _draftData;
  bool _formSnapSeen = false;
  bool _draftSnapSeen = false;
  bool _hubDeleted = false;
  bool _accessDenied = false;
  bool _adDocumentDeleted = false;
  bool _hadAdDocument = false;

  StreamSubscription<ModuleRecord?>? _hubSub;
  StreamSubscription<Map<String, dynamic>?>? _formSub;
  StreamSubscription<Map<String, dynamic>?>? _draftSub;

  @override
  void initState() {
    super.initState();
    _hubRecord = widget.record;
    _subscribe();
  }

  String _adNo() => AdFirestorePayload.adNoFromRecord(_hubRecord);

  void _subscribe() {
    final hubId = _hubRecord.id;
    if (hubId.isNotEmpty) {
      _hubSub?.cancel();
      _hubSub = _firestore.watchCaseById(hubId).listen(
        (next) {
          if (!mounted) return;
          setState(() {
            if (next == null) {
              _hubDeleted = true;
            } else {
              _hubDeleted = false;
              _accessDenied = false;
              _hubRecord = next;
            }
          });
        },
        onError: (_) {
          if (!mounted) return;
          setState(() => _accessDenied = true);
        },
      );
    }

    final adNo = _adNo();
    if (adNo.isEmpty) {
      _formSnapSeen = true;
      _draftSnapSeen = true;
      return;
    }

    _formSub?.cancel();
    _formSub = _firestore.watchDocumentData('ad_forms', adNo).listen((data) {
      _submittedData = data;
      _formSnapSeen = true;
      _onAdStreamsUpdated();
    });

    _draftSub?.cancel();
    _draftSub = _firestore.watchDocumentData('ad_drafts', adNo).listen((data) {
      _draftData = data;
      _draftSnapSeen = true;
      _onAdStreamsUpdated();
    });
  }

  void _onAdStreamsUpdated() {
    if (!mounted) return;

    if (_submittedData != null) {
      _hadAdDocument = true;
      _adDocumentDeleted = false;
      setState(() {});
      return;
    }

    if (!_formSnapSeen) return;

    if (_draftData != null) {
      _hadAdDocument = true;
      _adDocumentDeleted = false;
      setState(() {});
      return;
    }

    if (!_draftSnapSeen) return;

    if (_hadAdDocument) {
      setState(() => _adDocumentDeleted = true);
    } else {
      setState(() {});
    }
  }

  _AdFormSource get _source {
    if (_submittedData != null) return _AdFormSource.submitted;
    if (_draftData != null) return _AdFormSource.draft;
    return _AdFormSource.none;
  }

  Map<String, dynamic> get _formData =>
      _submittedData ?? _draftData ?? <String, dynamic>{};

  bool get _loadingAdDocs =>
      _adNo().isNotEmpty && (!_formSnapSeen || !_draftSnapSeen);

  @override
  void dispose() {
    _hubSub?.cancel();
    _formSub?.cancel();
    _draftSub?.cancel();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return AppColors.warningOrange;
      case 'Active':
        return AppColors.infoBlue;
      case 'Resolved':
        return AppColors.successGreen;
      case 'Closed':
        return const Color(0xFF607D8B);
      default:
        return AppColors.lightSubText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canView =
        CaseVisibility.canViewRecord(record: _hubRecord, auth: auth);
    final showContent = !_hubDeleted && !_accessDenied && canView;
    final statusColor = _statusColor(_hubRecord.status);
    final merged = AdFirestorePayload.mergeHubIntoForm(
      Map<String, dynamic>.from(_formData),
      _hubRecord,
    );

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          () {
            final mainTitle = _adNo().trim().isNotEmpty
                ? _adNo().trim()
                : (_hubRecord.caseNumber.trim().isNotEmpty
                    ? _hubRecord.caseNumber.trim()
                    : _hubRecord.firestoreCategoryDisplayName.trim());
            final showSubtitle = mainTitle.toLowerCase() !=
                _hubRecord.firestoreCategoryDisplayName.trim().toLowerCase();

            return SliverAppBar(
              expandedHeight: showSubtitle ? 70 : 60,
              pinned: true,
              backgroundColor: AppColors.navyDark,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainTitle,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  if (showSubtitle)
                    Text(
                      _hubRecord.firestoreCategoryDisplayName.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.goldPrimary,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [AppColors.navyDark, AppColors.navyMid],
                    ),
                  ),
                ),
              ),
            );
          }(),
          if (_accessDenied || !canView)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AccessDeniedView(
                message: CaseVisibility.showAskPiHint(
                  CaseVisibility.resolveFor(auth),
                )
                    ? 'Ask your PI or API for station-wide dashboard access to view this record.'
                    : null,
              ),
            )
          else if (_hubDeleted)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildDeletedMessage(
                'This record no longer exists',
                'The case may have been deleted by another officer.',
              ),
            )
          else if (_loadingAdDocs)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.35)),
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: statusColor, shape: BoxShape.circle),
                          child: const Icon(Icons.assignment_turned_in_rounded,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Case Status',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                              Text(
                                _hubRecord.status.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: statusColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Priority',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.lightSubText,
                              ),
                            ),
                            Text(
                              _hubRecord.priority,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navyDark,
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    if (_adDocumentDeleted)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Material(
                          color: AppColors.dangerRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Text(
                              'The A.D form document was removed remotely. Values below use the case list only where applicable.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.navyDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_source == _AdFormSource.draft)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Material(
                          color:
                              AppColors.warningOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Text(
                              'This is a saved draft. Latest submitted record may differ.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.navyDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_source == _AdFormSource.none && !_adDocumentDeleted)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Material(
                          color: AppColors.infoBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Text(
                              'No A.D form document found in Firestore for this AD No. Values below use the case list only where applicable.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.navyDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    AdFormDynamicDocumentView(
                      formData: merged,
                      hubRecord: _hubRecord,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: !showContent
          ? null
          : Builder(builder: (ctx) {
              final canEdit =
                  PoliceRbacHelper.canEditRecord(_hubRecord, auth);
              final canSendReminder = PoliceRbacHelper.canSendReminder(auth);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canSendReminder) ...[
                    FloatingActionButton.extended(
                      heroTag: 'ad_reminder_btn',
                      onPressed: () =>
                          SendReminderDialog.show(context, _hubRecord),
                      backgroundColor: AppColors.warningOrange,
                      icon: const Icon(Icons.notifications_active_rounded,
                          color: Colors.white),
                      label: Text(
                        'Send Reminder to IO',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (canEdit) ...[
                    FloatingActionButton.extended(
                      heroTag: 'ad_edit_btn',
                      onPressed: () {
                        Navigator.push(
                          context,
                          AppTheme.fadeSlideRoute(
                            page: ADFormScreen(
                              existingRecord: _hubRecord,
                              popCountAfterSubmit: 2,
                            ),
                          ),
                        );
                      },
                      backgroundColor: AppColors.goldPrimary,
                      icon: const Icon(Icons.edit_note_rounded,
                          color: AppColors.navyDark),
                      label: Text(
                        'Edit Record',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyDark),
                      ),
                    ),
                  ],
                ],
              );
            }),
    );
  }

  Widget _buildDeletedMessage(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_forever_rounded,
                size: 64, color: AppColors.lightSubText),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
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

enum _AdFormSource { submitted, draft, none }
