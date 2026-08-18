import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../modules/core/models/base_record.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/case_visibility.dart';
import 'ad_record_detail_screen.dart';
import 'module_record_detail_screen.dart';

/// Tab indices for [MyCasesScreen].
abstract final class MyCasesTab {
  static const int total = 0;
  static const int active = 0;
  static const int pending = 1;
  static const int disposal = 2;
  static const int closed = 2;
}

/// Case list opened from dashboard summary cards or the drawer.
///
/// [initialTab]: `0` Active, `1` Pending, `2` Closed/Disposed.
/// Lists honor [CaseVisibility] the same way dashboard card counts do.
class MyCasesScreen extends StatefulWidget {
  const MyCasesScreen({
    super.key,
    this.initialTab = MyCasesTab.active,
  });

  final int initialTab;

  @override
  State<MyCasesScreen> createState() => _MyCasesScreenState();
}

class _MyCasesScreenState extends State<MyCasesScreen> {
  final _firestore = FirestoreService();
  late int _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTab.clamp(MyCasesTab.active, MyCasesTab.disposal);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final mode = CaseVisibility.resolveFor(auth);
    final stationWide = mode == CaseVisibilityMode.stationWide;
    final title = stationWide ? 'Station Cases' : 'My Assigned Cases';

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navyDark),
        ),
      ),
      body: Column(
        children: [
          // ── Fixed Top Hero Banner ──────────────────────────────────────────
          _buildHeroHeaderBanner(auth, mode, stationWide, title),

          // ── Segmented Tab Selector (Click-Only with Hover) ──────────────────
          _buildSegmentedTabBar(),

          // ── Instant Tab Content (Zero Sliding Animation) ───────────────────
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _VisibilityCasesTab(
                  stream: _activeStream(auth, mode),
                  emptyMessage: stationWide
                      ? 'No active cases for this station.'
                      : 'No active cases assigned to you.',
                  emptyHint: stationWide
                      ? 'Active station cases will appear here automatically.'
                      : 'Cases assigned to you by a senior officer will show up here.',
                  listKind: _CaseListKind.active,
                ),
                _VisibilityCasesTab(
                  stream: _pendingStream(auth, mode),
                  emptyMessage: stationWide
                      ? 'No pending cases for this station.'
                      : 'No pending cases assigned to you.',
                  emptyHint: 'Pending investigations and follow-ups appear in this tab.',
                  listKind: _CaseListKind.pending,
                ),
                _VisibilityCasesTab(
                  stream: _closedStream(auth, mode),
                  emptyMessage: stationWide
                      ? 'No disposal cases for this station.'
                      : 'No disposal cases assigned to you.',
                  emptyHint: 'Disposed cases are archived here for reference.',
                  listKind: _CaseListKind.closed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeaderBanner(
    AuthProvider auth,
    CaseVisibilityMode mode,
    bool stationWide,
    String title,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.lg),
          bottomRight: Radius.circular(AppRadius.lg),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.assignment_rounded,
                    color: AppColors.goldPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.displayName.isNotEmpty ? auth.displayName : 'Officer',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (auth.designation.isNotEmpty)
                            _HeaderChip(
                              icon: Icons.badge_outlined,
                              label: auth.designation,
                            ),
                          if (auth.stationName.isNotEmpty)
                            _HeaderChip(
                              icon: Icons.location_on_outlined,
                              label: auth.stationName,
                            ),
                          _HeaderChip(
                            icon: stationWide
                                ? Icons.groups_outlined
                                : Icons.person_outline_rounded,
                            label: CaseVisibility.chipPrefix(mode),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabBar() {
    final tabs = [
      (0, Icons.folder_open_rounded, 'Total Cases'),
      (1, Icons.pending_actions_outlined, 'Pending Cases'),
      (2, Icons.check_circle_outline_rounded, 'Disposal Cases'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: AppSpacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.lightBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Row(
              children: tabs.map((t) {
                final isSelected = _selectedTabIndex == t.$1;
                return Expanded(
                  child: _HoverTabItem(
                    icon: t.$2,
                    label: t.$3,
                    isSelected: isSelected,
                    onTap: () {
                      if (_selectedTabIndex != t.$1) {
                        setState(() => _selectedTabIndex = t.$1);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Stream<List<ModuleRecord>> _activeStream(
    AuthProvider auth,
    CaseVisibilityMode mode,
  ) {
    return _firestore.getStationCasesStream(auth.activeStation).map(
          (records) => CaseVisibility.filterRecords(
            records,
            uid: auth.uid,
            officerName: auth.displayName,
            mode: mode,
          ),
        );
  }

  Stream<List<ModuleRecord>> _pendingStream(
    AuthProvider auth,
    CaseVisibilityMode mode,
  ) {
    return _firestore.getPendingCasesStream(auth.activeStation).map(
          (records) => CaseVisibility.filterRecords(
            records,
            uid: auth.uid,
            officerName: auth.displayName,
            mode: mode,
          ),
        );
  }

  Stream<List<ModuleRecord>> _closedStream(
    AuthProvider auth,
    CaseVisibilityMode mode,
  ) {
    return _firestore.getDisposalCasesStream(auth.activeStation).map(
          (records) => CaseVisibility.filterRecords(
            records,
            uid: auth.uid,
            officerName: auth.displayName,
            mode: mode,
          ),
        );
  }
}

class _HoverTabItem extends StatefulWidget {
  const _HoverTabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_HoverTabItem> createState() => _HoverTabItemState();
}

class _HoverTabItemState extends State<_HoverTabItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    if (widget.isSelected) {
      bg = AppColors.navyDark;
      fg = Colors.white;
    } else if (_isHovered) {
      bg = AppColors.navyMid.withValues(alpha: 0.08);
      fg = AppColors.navyDark;
    } else {
      bg = Colors.transparent;
      fg = AppColors.lightSubText;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _CaseListKind { active, pending, closed }

class _VisibilityCasesTab extends StatefulWidget {
  const _VisibilityCasesTab({
    required this.stream,
    required this.emptyMessage,
    required this.emptyHint,
    required this.listKind,
  });

  final Stream<List<ModuleRecord>> stream;
  final String emptyMessage;
  final String emptyHint;
  final _CaseListKind listKind;

  @override
  State<_VisibilityCasesTab> createState() => _VisibilityCasesTabState();
}

class _VisibilityCasesTabState extends State<_VisibilityCasesTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ModuleRecord> _filter(List<ModuleRecord> cases) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return cases;
    return cases.where((r) {
      return r.title.toLowerCase().contains(q) ||
          r.caseNumber.toLowerCase().contains(q) ||
          r.complainant.toLowerCase().contains(q) ||
          r.location.toLowerCase().contains(q) ||
          r.assignedOfficer.toLowerCase().contains(q) ||
          r.firestoreCategoryDisplayName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ModuleRecord>>(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: 4,
                itemBuilder: (_, __) => const _CaseCardSkeleton(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _EmptyState(
            icon: Icons.cloud_off_rounded,
            iconColor: AppColors.dangerRed,
            title: 'Unable to load cases',
            message: 'Check your connection and pull down to try again.',
          );
        }

        final allCases = snapshot.data ?? const [];
        final cases = _filter(allCases);

        return RefreshIndicator(
          color: AppColors.navyMid,
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 600));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SearchField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _query = v),
                            onClear: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                _query.isNotEmpty
                                    ? 'Found ${cases.length} of ${allCases.length} records'
                                    : 'Total: ${allCases.length} records',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.lightSubText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (cases.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: _EmptyState(
                        icon: _query.isNotEmpty
                            ? Icons.search_off_rounded
                            : Icons.folder_open_rounded,
                        iconColor: AppColors.navyMid,
                        title: _query.isNotEmpty
                            ? 'No matching cases'
                            : widget.emptyMessage,
                        message: _query.isNotEmpty
                            ? 'Try a different FIR number, title, or location.'
                            : widget.emptyHint,
                      ),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.xl,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cases.length,
                          itemBuilder: (context, index) => _CaseCard(
                            record: cases[index],
                            listKind: widget.listKind,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.navyDark),
      decoration: InputDecoration(
        hintText: 'Search by FIR, title, location…',
        hintStyle: GoogleFonts.poppins(
          fontSize: 12.5,
          color: AppColors.lightSubText,
        ),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.navyMid, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, color: AppColors.lightSubText, size: 18),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.navyMid, width: 1.5),
        ),
      ),
    );
  }
}

class _CaseCard extends StatefulWidget {
  const _CaseCard({
    required this.record,
    required this.listKind,
  });

  final ModuleRecord record;
  final _CaseListKind listKind;

  @override
  State<_CaseCard> createState() => _CaseCardState();
}

class _CaseCardState extends State<_CaseCard> {
  bool _isHovered = false;

  String get _displayStatus {
    final s = widget.record.status.trim().toLowerCase();
    if (s == 'closed' || s == 'resolved' || s == 'disposed' || s == 'disposal' || widget.listKind == _CaseListKind.closed) {
      return 'Disposal';
    }
    return 'Pending';
  }

  Color get _accentColor {
    switch (widget.listKind) {
      case _CaseListKind.active:
        return AppColors.infoBlue;
      case _CaseListKind.pending:
        return AppColors.warningOrange;
      case _CaseListKind.closed:
        return AppColors.successGreen;
    }
  }

  Color _recordStatusColor(String status) {
    switch (status) {
      case 'Disposal':
        return AppColors.successGreen;
      case 'Pending':
      default:
        return AppColors.warningOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    final displayStatus = _displayStatus;
    final statusColor = _recordStatusColor(displayStatus);
    final displayTitle =
        widget.record.title.trim().isNotEmpty ? widget.record.title.trim() : 'Untitled Case';
    final firLabel = widget.record.caseNumber.trim().isNotEmpty
        ? widget.record.caseNumber.trim()
        : 'No FIR / case number';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: _isHovered
                ? AppColors.navyMid.withValues(alpha: 0.3)
                : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.03),
              blurRadius: _isHovered ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: () => _openCaseDetail(context),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.navyMid.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  firLabel,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.navyMid,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      displayStatus,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            displayTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyDark,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.record.firestoreCategoryDisplayName.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.goldPrimary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.record.firestoreCategoryDisplayName,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.goldDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              _MetaChip(
                                icon: Icons.calendar_today_rounded,
                                label: DateFormat('dd MMM yyyy')
                                    .format(widget.record.createdAt),
                              ),
                              if (widget.record.location.trim().isNotEmpty)
                                _MetaChip(
                                  icon: Icons.location_on_outlined,
                                  label: widget.record.location.trim(),
                                ),
                              if (widget.record.assignedOfficer.trim().isNotEmpty)
                                _MetaChip(
                                  icon: Icons.person_outline_rounded,
                                  label: widget.record.assignedOfficer.trim(),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Tap to view details',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.navyMid,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: AppColors.navyMid,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openCaseDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget.record.moduleKey == 'ad'
            ? AdRecordDetailScreen(record: widget.record)
            : ModuleRecordDetailScreen(record: widget.record),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.lightSubText),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.lightSubText,
            ),
          ),
        ),
      ],
    );
  }
}

class _CaseCardSkeleton extends StatelessWidget {
  const _CaseCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            decoration: const BoxDecoration(
              color: AppColors.lightBorder,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(AppRadius.md),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 160,
                    decoration: BoxDecoration(
                      color: AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 10,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: iconColor.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.lightSubText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
