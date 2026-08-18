// lib/screens/module_record_detail_screen.dart
// Detailed view for any ModuleRecord — all saved hub fields + extraFields, rendered dynamically.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../modules/core/models/base_record.dart';
import '../modules/missing/screens/missing_form_screen.dart';
import '../modules/nc/screens/nc_form_screen.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/case_visibility.dart';
import '../utils/police_rbac_helper.dart';
import '../widgets/send_reminder_dialog.dart';
import '../utils/common_form_module.dart';
import '../utils/module_pdf_helper.dart';
import '../utils/pdf_auth_gate.dart';
import '../widgets/access_denied_view.dart';
import '../widgets/module_record_dynamic_document_view.dart';
import 'ad_form_screen.dart';
import 'common_form_screen.dart';
import 'module_form_screen.dart';

class ModuleRecordDetailScreen extends StatefulWidget {
  final ModuleRecord record;

  const ModuleRecordDetailScreen({
    super.key,
    required this.record,
  });

  @override
  State<ModuleRecordDetailScreen> createState() =>
      _ModuleRecordDetailScreenState();
}

class _ModuleRecordDetailScreenState extends State<ModuleRecordDetailScreen> {
  final _firestore = FirestoreService();
  late ModuleRecord _record;
  bool _recordDeleted = false;
  bool _accessDenied = false;
  StreamSubscription<ModuleRecord?>? _subscription;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
    _subscribeToRecord();
  }

  void _subscribeToRecord() {
    final id = _record.id;
    if (id.isEmpty) return;
    _subscription?.cancel();
    _subscription = _firestore.watchCaseById(id).listen(
      (next) {
        if (!mounted) return;
        if (next != null) {
          setState(() {
            _recordDeleted = false;
            _accessDenied = false;
            _record = next;
          });
        }
      },
      onError: (_) {
        // Keep showing local record if stream errors
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
    const bool isDark = false; // light-mode only
    final auth = context.watch<AuthProvider>();
    final canView = CaseVisibility.canViewRecord(record: _record, auth: auth);
    final showContent = !_recordDeleted && !_accessDenied && canView;
    final statusColor = _statusColor(_record.status);
    final moduleLabel = _record.firestoreCategoryDisplayName;

    if (_accessDenied || !canView) {
      return Scaffold(
        backgroundColor: AppColors.lightBg,
        body: CustomScrollView(
          slivers: [
            _buildAppBar(context, isDark, statusColor, moduleLabel),
            SliverFillRemaining(
              hasScrollBody: false,
              child: AccessDeniedView(
                message: CaseVisibility.showAskPiHint(
                  CaseVisibility.resolveFor(auth),
                )
                    ? 'Ask your PI or API for station-wide dashboard access to view this record.'
                    : null,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: _recordDeleted
          ? _buildDeletedBody(context, isDark, statusColor, moduleLabel)
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context, isDark, statusColor, moduleLabel),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusBanner(statusColor),
                        const SizedBox(height: 20),
                        ModuleRecordDynamicDocumentView(
                          record: _record,
                          moduleLabel: moduleLabel,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _recordDeleted || !showContent
          ? null
          : Builder(builder: (ctx) {
              final auth = context.watch<AuthProvider>();
              final canEdit = PoliceRbacHelper.canEditRecord(_record, auth);
              final canSendReminder = PoliceRbacHelper.canSendReminder(auth);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'pdf_module_btn',
                    onPressed: () => runWithPdfAuthGate(
                      context,
                      () => ModulePdfHelper.generatePdf(_record),
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
                      heroTag: 'reminder_module_btn',
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
                      heroTag: 'edit_module_btn',
                      onPressed: () => _openEdit(context, moduleLabel),
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
                    const SizedBox(height: 12),
                    FloatingActionButton.extended(
                      heroTag: 'delete_module_btn',
                      onPressed: () => _confirmDeleteRecord(),
                      backgroundColor: AppColors.dangerRed,
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.white),
                      label: Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              );
            }),
    );
  }

  void _confirmDeleteRecord() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Delete Record',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: AppColors.dangerRed)),
        content: Text('Delete "${_record.title}"? This cannot be undone.',
            style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await _firestore.deleteCase(_record.id, moduleKey: _record.moduleKey);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Record deleted', style: GoogleFonts.poppins()),
                  backgroundColor: AppColors.successGreen,
                ));
                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Failed to delete record: $e',
                      style: GoogleFonts.poppins()),
                  backgroundColor: AppColors.dangerRed,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: Text('Delete',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _openEdit(BuildContext context, String moduleLabel) {
    if (_record.moduleKey == 'ad') {
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(
          page: ADFormScreen(
            existingRecord: _record,
            popCountAfterSubmit: 2,
          ),
        ),
      );
      return;
    }
    if (_record.moduleKey == 'nc') {
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(
          page: NcFormScreen(
            moduleLabel: moduleLabel,
            subCategory: _record.subCategory,
            existingRecord: _record,
          ),
        ),
      );
      return;
    }
    if (_record.moduleKey == 'missing') {
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(
          page: MissingFormScreen(
            moduleLabel: moduleLabel,
            subCategory: _record.subCategory,
            existingRecord: _record,
          ),
        ),
      );
      return;
    }
    if (moduleUsesCommonCrimeForm(_record.moduleKey)) {
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(
          page: CommonFormScreen(
            moduleLabel: moduleLabel,
            moduleKey: _record.moduleKey,
            existingRecord: _record,
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      AppTheme.fadeSlideRoute(
        page: ModuleFormScreen(
          moduleLabel: moduleLabel,
          moduleKey: _record.moduleKey,
          existingRecord: _record,
        ),
      ),
    );
  }

  Widget _buildDeletedBody(
    BuildContext context,
    bool isDark,
    Color statusColor,
    String moduleLabel,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(context, isDark, statusColor, moduleLabel),
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

  Widget _buildAppBar(
      BuildContext context, bool isDark, Color statusColor, String moduleLabel) {
    final titleText = _record.caseNumber.trim().isNotEmpty
        ? _record.caseNumber.trim()
        : (_record.title.trim().isNotEmpty ? _record.title.trim() : moduleLabel);

    final showSubtitle = titleText.toLowerCase() != moduleLabel.trim().toLowerCase();

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
            titleText,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15),
          ),
          if (showSubtitle)
            Text(
              moduleLabel.toUpperCase(),
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldPrimary,
                  fontSize: 10,
                  letterSpacing: 0.5),
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
  }

  Widget _buildStatusBanner(Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
          child: const Icon(Icons.assignment_turned_in_rounded,
              color: Colors.white, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Case Status',
                style: GoogleFonts.poppins(
                    fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
            Text(_record.status.toUpperCase(),
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 1.2)),
          ]),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Priority',
              style: GoogleFonts.poppins(
                  fontSize: 10, color: AppColors.lightSubText)),
          Text(_record.priority,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDark)),
        ]),
      ]),
    );
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
}
