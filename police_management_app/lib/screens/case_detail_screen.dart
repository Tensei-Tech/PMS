// lib/screens/case_detail_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../modules/core/models/base_record.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/case_visibility.dart';
import '../utils/police_rbac_helper.dart';
import '../widgets/send_reminder_dialog.dart';
import '../utils/pdf_auth_gate.dart';
import '../utils/pdf_helper.dart';
import '../widgets/access_denied_view.dart';
import '../widgets/module_record_dynamic_document_view.dart';
import 'case_form_screen.dart';

class CaseDetailScreen extends StatefulWidget {
  final ModuleRecord caseData;
  /// When false (e.g. opened from Recent Cases), hides FABs on the detail page.
  final bool showFloatingActions;

  const CaseDetailScreen({
    super.key,
    required this.caseData,
    this.showFloatingActions = true,
  });

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  final _firestore = FirestoreService();
  late ModuleRecord _record;
  bool _recordDeleted = false;
  bool _accessDenied = false;
  StreamSubscription<ModuleRecord?>? _subscription;

  @override
  void initState() {
    super.initState();
    _record = widget.caseData;
    _subscribeToRecord();
  }

  void _subscribeToRecord() {
    final id = _record.id;
    if (id.isEmpty) return;
    _subscription?.cancel();
    _subscription = _firestore.watchCaseById(id).listen(
      (next) {
        if (!mounted) return;
        setState(() {
          if (next == null) {
            _recordDeleted = true;
          } else {
            _recordDeleted = false;
            _accessDenied = false;
            _record = next;
          }
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _accessDenied = true);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canView = CaseVisibility.canViewRecord(record: _record, auth: auth);
    final showContent = !_recordDeleted && !_accessDenied && canView;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: _accessDenied || !canView
          ? _buildAccessDeniedBody(context)
          : _recordDeleted
              ? _buildDeletedBody()
              : _buildLiveBody(context),
      floatingActionButton: widget.showFloatingActions && showContent
          ? Builder(builder: (ctx) {
              final canEdit = PoliceRbacHelper.canEditRecord(_record, auth);
              final canSendReminder = PoliceRbacHelper.canSendReminder(auth);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'pdf_btn',
                    onPressed: () => runWithPdfAuthGate(
                      context,
                      () => PdfHelper.generateCasePdf(_record),
                    ),
                    backgroundColor: AppColors.dangerRed,
                    icon: const Icon(Icons.picture_as_pdf_rounded,
                        color: Colors.white),
                    label: Text(
                      'Download PDF',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                  if (canSendReminder) ...[
                    const SizedBox(height: 12),
                    FloatingActionButton.extended(
                      heroTag: 'reminder_btn',
                      onPressed: () => SendReminderDialog.show(context, _record),
                      backgroundColor: AppColors.warningOrange,
                      icon: const Icon(Icons.notifications_active_rounded,
                          color: Colors.white),
                      label: Text(
                        'Send Reminder to IO',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ],
                  if (canEdit) ...[
                    const SizedBox(height: 12),
                    FloatingActionButton.extended(
                      heroTag: 'edit_btn',
                      onPressed: () {
                        Navigator.push(
                          context,
                          AppTheme.fadeSlideRoute(
                            page: CaseFormScreen(
                              categoryName: _record.category,
                              existingCase: _record,
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
            })
          : null,
    );
  }

  Widget _buildAccessDeniedBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverFillRemaining(
          hasScrollBody: false,
          child: AccessDeniedView(
            message: CaseVisibility.showAskPiHint(CaseVisibility.resolveFor(
              context.read<AuthProvider>(),
            ))
                ? 'Ask your PI or API for station-wide dashboard access to view this record.'
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDeletedBody() {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_forever_rounded,
                      size: 64, color: AppColors.lightSubText),
                  const SizedBox(height: 16),
                  Text(
                    'This record no longer exists',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'It may have been deleted by another officer.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.lightSubText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(),
                const SizedBox(height: 24),
                ModuleRecordDynamicDocumentView(
                  record: _record,
                  moduleLabel: _record.firestoreCategoryDisplayName,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 70,
      pinned: true,
      backgroundColor: AppColors.navyDark,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
      ),
      title: Text(
        _record.caseNumber,
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15),
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
  }

  Widget _buildStatusHeader() {
    final statusColor = _record.status == 'Open'
        ? AppColors.warningOrange
        : _record.status == 'Active'
            ? AppColors.infoBlue
            : _record.status == 'Resolved'
                ? AppColors.successGreen
                : AppColors.lightSubText;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration:
                BoxDecoration(color: statusColor, shape: BoxShape.circle),
            child: const Icon(Icons.assignment_turned_in_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Case Status',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600)),
                Text(
                  _record.status.toUpperCase(),
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: 1.1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
