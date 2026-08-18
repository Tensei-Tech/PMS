// lib/screens/form_i_v_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../modules/core/models/base_record.dart';
import '../modules/form_iv/providers/form_iv_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/form_iv_category_button.dart';
import '../widgets/module_hub_screen_app_bar.dart';
import '../widgets/read_only_module_record_hub_card.dart';
import 'common_form_screen.dart';
import 'module_record_detail_screen.dart';

/// Controls where a Form I-V category tap navigates.
enum FormIVSelectionMode {
  /// Home grid browse — filter bar + cases list on this screen.
  browse,

  /// Drawer / FAB add-entry — same layout; New Case opens Form I-V entry.
  add,

  /// Read-only hub browse.
  readOnly,
}

class FormIVSelectionScreen extends StatefulWidget {
  static const allFilterLabel = 'All';

  final FormIVSelectionMode mode;

  const FormIVSelectionScreen({
    super.key,
    this.mode = FormIVSelectionMode.add,
  });

  @override
  State<FormIVSelectionScreen> createState() => _FormIVSelectionScreenState();
}

class _FormIVSelectionScreenState extends State<FormIVSelectionScreen> {
  String _selectedCategory = FormIVSelectionScreen.allFilterLabel;

  bool get _readOnly => widget.mode == FormIVSelectionMode.readOnly;
  bool get _showNewCaseFab => !_readOnly;

  List<String> get _filterOptions =>
      [FormIVSelectionScreen.allFilterLabel, ...kFormIVCaseCategories];

  List<ModuleRecord> _filteredRecords(List<ModuleRecord> records) {
    final filtered = _selectedCategory == FormIVSelectionScreen.allFilterLabel
        ? records
        : records.where((r) => r.subCategory == _selectedCategory).toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  void _openForm(String category, {ModuleRecord? existingRecord}) {
    Navigator.push(
      context,
      AppTheme.fadeSlideRoute(
        page: CommonFormScreen(
          moduleLabel: category,
          moduleKey: 'form_1_5',
          subCategory: category,
          existingRecord: existingRecord,
          readOnly: _readOnly && existingRecord != null,
        ),
      ),
    );
  }

  void _onNewCase() {
    final category = _selectedCategory != FormIVSelectionScreen.allFilterLabel
        ? _selectedCategory
        : kFormIVCaseCategories.first;
    _openForm(category);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FormIVProvider>();
    final allRecords = provider.records;
    final visibleRecords = _filteredRecords(allRecords);
    final subtitle = _selectedCategory == FormIVSelectionScreen.allFilterLabel
        ? '${visibleRecords.length} cases · ${kFormIVCaseCategories.length} types'
        : '$_selectedCategory · ${visibleRecords.length} cases';

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: ModuleHubScreenAppBar(
        title: 'Form I-V Cases',
        subtitle: subtitle,
        badgeLabel: 'I TO V',
      ),
      floatingActionButton: _showNewCaseFab
          ? FloatingActionButton.extended(
              onPressed: _onNewCase,
              backgroundColor: AppColors.navyMid,
              foregroundColor: Colors.white,
              elevation: 6,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'New Case',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CategoryFilterBar(
            options: _filterOptions,
            selected: _selectedCategory,
            onSelected: (value) => setState(() => _selectedCategory = value),
          ),
          Expanded(
            child: visibleRecords.isEmpty
                ? _EmptyCasesState(
                    category: _selectedCategory,
                    readOnly: _readOnly,
                    onNewCase: _showNewCaseFab ? _onNewCase : null,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      88,
                    ),
                    itemCount: visibleRecords.length,
                    itemBuilder: (context, index) {
                      final record = visibleRecords[index];
                      if (_readOnly) {
                        return ReadOnlyModuleRecordHubCard(record: record);
                      }
                      return _FormIVCaseCard(
                        record: record,
                        onEdit: () => _openForm(
                          record.subCategory ?? record.title,
                          existingRecord: record,
                        ),
                        onView: () {
                          Navigator.push(
                            context,
                            AppTheme.fadeSlideRoute(
                              page: ModuleRecordDetailScreen(record: record),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_list_rounded,
                      size: 18, color: AppColors.navyMid),
                  const SizedBox(width: 8),
                  Text(
                    'Filter by case type',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightSubText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selected,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.navyMid),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyDark,
                  ),
                  dropdownColor: Colors.white,
                  menuMaxHeight: 360,
                  items: options
                      .map(
                        (label) => DropdownMenuItem<String>(
                          value: label,
                          child: Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.navyDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) onSelected(value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormIVCaseCard extends StatelessWidget {
  const _FormIVCaseCard({
    required this.record,
    required this.onEdit,
    required this.onView,
  });

  final ModuleRecord record;
  final VoidCallback onEdit;
  final VoidCallback onView;

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
    final statusColor = _statusColor(record.status);
    final categoryLabel =
        record.subCategory?.trim().isNotEmpty == true
            ? record.subCategory!.trim()
            : record.firestoreCategoryDisplayName;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (record.caseNumber.trim().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.infoBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          record.caseNumber,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.infoBlue,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        record.status,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  record.title.trim().isNotEmpty
                      ? record.title.trim()
                      : 'Untitled Case',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDark,
                  ),
                ),
                if (categoryLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    categoryLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.goldPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.person_rounded,
                        size: 13, color: AppColors.lightSubText),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        record.assignedOfficer.trim().isNotEmpty
                            ? record.assignedOfficer
                            : 'Unassigned',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.lightSubText,
                        ),
                      ),
                    ),
                    Icon(Icons.calendar_today_rounded,
                        size: 13, color: AppColors.lightSubText),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(record.incidentDate),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.lightSubText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.lightBorder),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppRadius.lg),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_note_rounded,
                            size: 16, color: AppColors.infoBlue),
                        const SizedBox(width: 6),
                        Text(
                          'Edit',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.infoBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 28, color: AppColors.lightBorder),
              Expanded(
                child: InkWell(
                  onTap: onView,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(AppRadius.lg),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility_rounded,
                            size: 16, color: AppColors.goldPrimary),
                        const SizedBox(width: 6),
                        Text(
                          'View',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.goldPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCasesState extends StatelessWidget {
  const _EmptyCasesState({
    required this.category,
    required this.readOnly,
    this.onNewCase,
  });

  final String category;
  final bool readOnly;
  final VoidCallback? onNewCase;

  @override
  Widget build(BuildContext context) {
    final isAll = category == FormIVSelectionScreen.allFilterLabel;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              isAll
                  ? 'No Form I-V cases yet'
                  : 'No $category cases yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.lightSubText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              readOnly
                  ? 'Cases will appear here once registered.'
                  : 'Tap New Case to register the first case.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.lightSubText,
              ),
            ),
            if (onNewCase != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onNewCase,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navyMid,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  'New Case',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
