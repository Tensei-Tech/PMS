import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// One indented sub-section under a parent form (page range from reference assets).
class FormsSubSection {
  final String label;
  final String pageRange;
  final String sectionId;

  /// When set, used for [CommonFormScreen.subCategory] instead of the parent entry.
  final String? subCategoryOverride;

  const FormsSubSection({
    required this.label,
    required this.pageRange,
    String? sectionId,
    this.subCategoryOverride,
  }) : sectionId = sectionId ?? label;

  String get displayLabel =>
      pageRange.isEmpty ? label : '$label ($pageRange)';
}

/// One police/medical form — standalone or with nested sub-sections.
class FormsListEntry {
  /// Accordion row title (may include Marathi where helpful).
  final String title;

  /// Canonical [CommonFormScreen.subCategory] for dedicated view routing.
  final String subCategory;

  final List<FormsSubSection> subSections;

  const FormsListEntry({
    required this.title,
    String? subCategory,
    this.subSections = const [],
  }) : subCategory = subCategory ?? title;

  bool get hasSubSections => subSections.isNotEmpty;

  String _effectiveSubCategory(FormsSubSection sub) =>
      sub.subCategoryOverride ?? subCategory;

  /// True when opening the parent without a sub-section is a valid full form.
  bool get allowCompleteForm {
    if (!hasSubSections || subSections.length == 1) return false;
    if (subCategory == 'BNSS Forms Compendium') return false;
    final distinct = subSections.map(_effectiveSubCategory).toSet();
    return distinct.length == 1;
  }

  /// Single-part forms open directly instead of an accordion wrapper.
  bool get opensSingleSubSectionDirectly =>
      hasSubSections && subSections.length == 1;
}

FormsSubSection _sub(
  String label,
  String pageRange, {
  String? sectionId,
  String? subCategoryOverride,
}) =>
    FormsSubSection(
      label: label,
      pageRange: pageRange,
      sectionId: sectionId,
      subCategoryOverride: subCategoryOverride,
    );

/// Mock hierarchy — sub-section boundaries align with I.O./official signature endings.
final List<FormsListEntry> kFormsHierarchyMock = [
  FormsListEntry(
    title: 'Crime Detail Form',
    subSections: [
      _sub('Form 2-A — Case & Occurrence', '§§1–4 (no I.O. block)', sectionId: 'Form 2-A'),
      _sub('Form 2-B — Victims & Property', '§§5–8 (no I.O. block)', sectionId: 'Form 2-B'),
      _sub('Form 2-C — Place, Map & Evidence', 'Ends at I.O. signature', sectionId: 'Form 2-C'),
    ],
  ),
  FormsListEntry(
    title: 'Property & Seizure Form',
    subSections: [
      _sub('Seizure Panchanama Memo', '§§1–11 body', sectionId: 'Seizure Memo Body'),
      _sub('Seizure Memo — Signatures', 'Ends at I.O. signature', sectionId: 'Seizure Memo Signatures'),
    ],
  ),
  FormsListEntry(
    title: 'House/Property Search & Seizure',
    subSections: [
      _sub('Search & Seizure Form', '§§1–10', sectionId: 'Search Seizure Form'),
      _sub('Search & Seizure Panchanama', 'Ends at I.O. signature', sectionId: 'Search Seizure Panchanama'),
    ],
  ),
  FormsListEntry(
    title: 'Crimespot Seizure Panchanama',
    subSections: [
      _sub('घटनास्थळ जप्ती पंचनामा', 'Ends at I.O. signature'),
    ],
  ),
  FormsListEntry(
    title: 'Form E',
    subSections: [
      _sub('Modus Operandi Bureau Info', 'Ends at I.O. signature'),
    ],
  ),
  FormsListEntry(
    title: 'Arrest/Court Surrender Form',
    subSections: [
      _sub('Form 3-A — Arrest Particulars', '§§1–7', sectionId: 'Form 3-A'),
      _sub('Form 3-B — Custody & Physical Features', '§§8–9', sectionId: 'Form 3-B'),
      _sub('Form 3-C — Profile & Signatures', 'Ends at I.O. signature', sectionId: 'Form 3-C'),
    ],
  ),
  FormsListEntry(
    title: 'Inquest Panchanama',
    subCategory: 'Inquest Panchanama',
    subSections: [
      _sub(
        'Main Inquest Panchanama (u/s 194 BNSS)',
        'Ends at I.O. signature',
        sectionId: 'Inquest Main',
      ),
      _sub(
        'Police Report to Civil Surgeon for PM',
        'Ends at I.O. signature',
        sectionId: 'Civil Surgeon PM Report',
      ),
      _sub(
        'Vinanti Arj — PM Opinion Request',
        'Ends at I.O. signature',
        sectionId: 'Vinanti Arj',
      ),
      _sub(
        'Summons to Relatives (u/s 179 BNSS)',
        'Ends at I.O. signature',
        sectionId: 'Relative Summons 179',
      ),
      _sub(
        'Summons to Panchas (u/s 195 BNSS)',
        'Ends at I.O. signature',
        sectionId: 'Pancha Summons 195',
      ),
      _sub(
        'Marananveshan Panchanama',
        'Ends at I.O. signature',
        sectionId: 'Marananveshan Panchanama',
      ),
      _sub(
        '14-Kalmi Form with Inquest',
        'Ends at I.O. signature',
        sectionId: '14 Kalmi Form',
      ),
      _sub(
        'Dead Body Handover Receipt',
        'Ends at I.O. & receiver signatures',
        sectionId: 'Dead Body Handover',
      ),
      _sub(
        'Duty Pass',
        'Ends at I.O. signature',
        sectionId: 'Duty Pass',
      ),
    ],
  ),
  FormsListEntry(
    title: 'Accused Memorandum Form',
    subSections: [
      _sub('Part I — Personal Info & Memorandum', 'Ends at I.O. signature', sectionId: 'Accused Part I'),
      _sub('Part II — Further Panchanama', 'Ends at I.O. signature', sectionId: 'Accused Part II'),
    ],
  ),
  FormsListEntry(
    title: 'Final Report Form',
    subSections: [
      _sub('Part I — Header & Classification', '§§1–10', sectionId: 'Final Report Part I'),
      _sub('Part II — Accused Particulars', '§§11–12', sectionId: 'Final Report Part II'),
      _sub('Part III — Witnesses & Dispatch', 'Ends at I.O. submitting signature', sectionId: 'Final Report Part III'),
    ],
  ),

  // ── 376 Medical (reference: 376 Medical forms + 376 Medical Male) ──
  FormsListEntry(
    title: '376 Medical Form',
    subSections: [
      _sub(
        'Female — Medico-legal Exam of Sexual Violence',
        'Pages 1–13',
        sectionId: '376 Medical Female',
      ),
      _sub(
        'Male — Forensic Exam of Alleged Accused',
        'Pages 1–4',
        sectionId: '376 Medical Male',
      ),
    ],
  ),

  // ── Interrogation (reference: Interrogation form — 7 pages) ──
  FormsListEntry(
    title: 'Interrogation Form',
    subCategory: 'Interrogation Form',
    subSections: [
      _sub('Part I — Personal & Physical Details', 'Pages 1–2'),
      _sub('Part II — Family Background', 'Pages 2–3'),
      _sub('Part III — Education, ID & History', 'Page 4'),
      _sub('Part IV — Crime Method & Logistics', 'Pages 5–6'),
      _sub('Part V — Additional Case Details', 'Page 7'),
    ],
  ),

  // ── Arrest grounds cluster ──
  FormsListEntry(
    title: 'Draft Ground of Arrest',
    subSections: [
      _sub('Ground of Arrest', 'Pages 1–4'),
      _sub('Reason of Arrest', 'Pages 5–8'),
      _sub('Reason for PCR', 'Pages 9–12'),
    ],
  ),
  FormsListEntry(
    title: 'Ground of Arrest',
    subSections: [
      _sub('Ground of Arrest — Main', 'Page 1'),
      _sub('Ground of Arrest — Continuation', 'Page 2'),
    ],
  ),
  FormsListEntry(
    title: 'Reason of Arrest Form',
    subSections: [
      _sub('Reason of Arrest — Main', 'Page 1'),
      _sub('Reason of Arrest — Continuation', 'Page 2'),
    ],
  ),

  // ── Transit Remand (Marathi + English variants) ──
  FormsListEntry(
    title: 'Transit Remand',
    subSections: [
      _sub('Marathi — Transit Remand', 'Pages 1–2', sectionId: 'Transit Remand Marathi'),
      _sub('English — Requisition to Transit Remand', 'Page 1', sectionId: 'Transit Remand English'),
    ],
  ),

  // ── Order u/s 47 & 48 (3 pages) ──
  FormsListEntry(
    title: 'Order Section 47 & 48',
    subCategory: 'Order Section 47 & 48',
    subSections: [
      _sub('Administrative Order', 'Ends at SHO signature', sectionId: 'Order Main'),
      _sub('Notice BNSS 47(1)', 'Ends at accused & I.O. signatures', sectionId: 'Notice BNSS 47(1)'),
      _sub('Notice BNSS 48', 'Ends at relative & I.O. signatures', sectionId: 'Notice BNSS 48'),
    ],
  ),

  // ── AB Form for Medical (2 pages) ──
  FormsListEntry(
    title: 'AB Form',
    subCategory: 'AB Form',
    subSections: [
      _sub('AB Form for Medical — Main', 'Page 1'),
      _sub('AB Form for Medical — Continuation', 'Page 2'),
    ],
  ),

  // ── 73-page Marathi compendium ──
  FormsListEntry(
    title: 'Panchanama, Forms & Notices (BNSS)',
    subCategory: 'BNSS Forms Compendium',
    subSections: [
      _sub('Crime Detail Form', 'Pages 1–4', subCategoryOverride: 'Crime Detail Form'),
      _sub('House/Property Search & Seizure', 'Pages 5, 29', subCategoryOverride: 'House/Property Search & Seizure'),
      _sub('Property Seizure Panchanama', 'Pages 6, 30', subCategoryOverride: 'Property & Seizure Form'),
      _sub('Crimespot Seizure Panchanama', 'Page 7', subCategoryOverride: 'Crimespot Seizure Panchanama'),
      _sub('Form E', 'Page 8', subCategoryOverride: 'Form E'),
      _sub('Arrest/Court Surrender Form', 'Pages 9–11', subCategoryOverride: 'Arrest/Court Surrender Form'),
      _sub('Inquest Panchanama — Main (u/s 194)', 'Pages 12–15', sectionId: 'Inquest Main', subCategoryOverride: 'Inquest Panchanama'),
      _sub('Police Report to Civil Surgeon', 'Pages 16–17', sectionId: 'Civil Surgeon PM Report', subCategoryOverride: 'Inquest Panchanama'),
      _sub('PM Request Application (विनंती अर्ज)', 'Page 18', sectionId: 'Vinanti Arj', subCategoryOverride: 'Inquest Panchanama'),
      _sub('Relative Summons — Section 179', 'Page 19', sectionId: 'Relative Summons 179', subCategoryOverride: 'Inquest Panchanama'),
      _sub('Pancha Summons — Section 195', 'Page 20', sectionId: 'Pancha Summons 195', subCategoryOverride: 'Inquest Panchanama'),
      _sub('Marananveshan Panchanama (मरणान्वेषण)', 'Pages 21–22', sectionId: 'Marananveshan Panchanama', subCategoryOverride: 'Inquest Panchanama'),
      _sub('14-Point Medical Officer Form', 'Page 23', sectionId: '14 Kalmi Form', subCategoryOverride: 'Inquest Panchanama'),
      _sub('Pret Taba Pavti (प्रेत ताबा पावती)', 'Page 25', sectionId: 'Dead Body Handover', subCategoryOverride: 'Inquest Panchanama'),
      _sub('Duty Pass (ड्युटी पास)', 'Ends at I.O. signature', sectionId: 'Duty Pass', subCategoryOverride: 'Inquest Panchanama'),
      _sub(
        'Panchanama Continuation',
        'Ends at I.O. signature',
        sectionId: 'Panchanama Continuation',
        subCategoryOverride: 'Panchanama Continuation',
      ),
      _sub(
        'Injury Certificate',
        'Ends at Medical Officer signature',
        sectionId: 'Injury Certificate',
        subCategoryOverride: 'Injury Certificate',
      ),
      _sub(
        'Nil House Search Panchanama',
        'Ends at I.O. signature',
        sectionId: 'Nil House Search',
        subCategoryOverride: 'Nil House Search Panchanama',
      ),
      _sub(
        'Medical Examination Request — Section 51',
        'Ends at I.O. signature',
        sectionId: 'Medical Exam S51',
        subCategoryOverride: 'Medical Exam Section 51',
      ),
      _sub(
        'Chehare Patti (चेहरे पट्टी)',
        'Ends at I.O. signature',
        sectionId: 'Chehare Patti',
        subCategoryOverride: 'Chehare Patti',
      ),
      _sub(
        'Panch Notice — Section 179',
        'Ends at I.O. signature & receipt',
        sectionId: 'Panch Notice 179',
        subCategoryOverride: 'BNSS Panch Notice',
      ),
      _sub(
        'Panch Notice — Section 189',
        'Ends at I.O. signature & receipt',
        sectionId: 'Panch Notice 189',
        subCategoryOverride: 'BNSS Panch Notice',
      ),
      _sub(
        'Notice to Accused (आरोपीस सूचनापत्र)',
        'Ends at I.O. signature',
        sectionId: 'Notice to Accused',
        subCategoryOverride: 'Notice to Accused',
      ),
      _sub(
        'Notice — Section 35(3) — Main',
        'Notice body',
        sectionId: 'Notice Section 35 Main',
        subCategoryOverride: 'Notice Section 35',
      ),
      _sub(
        'Notice — Section 35(3) — Rights & signatures',
        'Ends at I.O. signature',
        sectionId: 'Notice Section 35 Continuation',
        subCategoryOverride: 'Notice Section 35',
      ),
      _sub(
        'Witness Notice (साक्षीदार सूचनापत्र)',
        'Ends at I.O. signature',
        sectionId: 'Witness Notice',
        subCategoryOverride: 'Witness Notice',
      ),
      _sub(
        'Muddemal Pavti (मुद्देमाल पावती)',
        'Ends at I.O. signature',
        sectionId: 'Muddemal Pavti',
        subCategoryOverride: 'Muddemal Pavti',
      ),
      _sub(
        'Mobile Seal Label',
        'Ends at I.O. signature',
        sectionId: 'Mobile Seal Label',
        subCategoryOverride: 'Mobile Seal Label',
      ),
      _sub('Accused Interrogation / Memorandum', 'Pages 47–64', subCategoryOverride: 'Accused Memorandum Form'),
      _sub(
        'Juvenile Social — Part I (Personal)',
        'Personal particulars',
        sectionId: 'Juvenile Social Part I',
        subCategoryOverride: 'Juvenile Social Background Report',
      ),
      _sub(
        'Juvenile Social — Part II (Family)',
        'Family & education',
        sectionId: 'Juvenile Social Part II',
        subCategoryOverride: 'Juvenile Social Background Report',
      ),
      _sub(
        'Juvenile Social — Part III (Social)',
        'Social environment',
        sectionId: 'Juvenile Social Part III',
        subCategoryOverride: 'Juvenile Social Background Report',
      ),
      _sub(
        'Juvenile Social — Part IV (Reports)',
        'Neighbourhood & school',
        sectionId: 'Juvenile Social Part IV',
        subCategoryOverride: 'Juvenile Social Background Report',
      ),
      _sub(
        'Juvenile Social — Part V (Signatures)',
        'Ends at I.O. & SHO signatures',
        sectionId: 'Juvenile Social Part V',
        subCategoryOverride: 'Juvenile Social Background Report',
      ),
      _sub('Final Report Form', 'Pages 70–73', subCategoryOverride: 'Final Report Form'),
    ],
  ),
];

typedef FormsAccordionSelectCallback = void Function(
  FormsListEntry entry, {
  FormsSubSection? subSection,
});

/// Accordion-style forms list with dual-action parent rows.
class FormsAccordionList extends StatefulWidget {
  final List<FormsListEntry> entries;
  final FormsAccordionSelectCallback onSelect;

  const FormsAccordionList({
    super.key,
    required this.entries,
    required this.onSelect,
  });

  @override
  State<FormsAccordionList> createState() => _FormsAccordionListState();
}

class _FormsAccordionListState extends State<FormsAccordionList> {
  final Set<int> _expandedIndices = {};

  void _toggleExpanded(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final entry = widget.entries[index];
        if (entry.opensSingleSubSectionDirectly) {
          final sub = entry.subSections.first;
          return _StandaloneFormRow(
            title: entry.title,
            onTap: () => widget.onSelect(entry, subSection: sub),
          );
        }
        if (entry.hasSubSections) {
          return _ParentFormRow(
            entry: entry,
            expanded: _expandedIndices.contains(index),
            onHeaderTap: () => _toggleExpanded(index),
            onOpenFullForm: entry.allowCompleteForm
                ? () => widget.onSelect(entry)
                : null,
            onChildTap: (section) =>
                widget.onSelect(entry, subSection: section),
          );
        }
        return _StandaloneFormRow(
          title: entry.title,
          onTap: () => widget.onSelect(entry),
        );
      },
    );
  }
}

class _StandaloneFormRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _StandaloneFormRow({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.description_outlined,
                  size: 20, color: AppColors.navyMid),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyDark,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.navyMid.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParentFormRow extends StatelessWidget {
  final FormsListEntry entry;
  final bool expanded;
  final VoidCallback onHeaderTap;
  final VoidCallback? onOpenFullForm;
  final ValueChanged<FormsSubSection> onChildTap;

  const _ParentFormRow({
    required this.entry,
    required this.expanded,
    required this.onHeaderTap,
    required this.onOpenFullForm,
    required this.onChildTap,
  });

  @override
  Widget build(BuildContext context) {
    final sectionCount = entry.subSections.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(AppRadius.md),
            bottom: expanded
                ? Radius.zero
                : const Radius.circular(AppRadius.md),
          ),
          child: InkWell(
            onTap: onHeaderTap,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(AppRadius.md),
              bottom: expanded
                  ? Radius.zero
                  : const Radius.circular(AppRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
              child: Row(
                children: [
                  Icon(Icons.folder_outlined,
                      size: 20, color: AppColors.navyMid),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyDark,
                          ),
                        ),
                        if (!expanded && sectionCount > 0)
                          Text(
                            '$sectionCount sub-sections — tap to expand',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.navyMid.withValues(alpha: 0.75),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.navyMid.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$sectionCount',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyMid,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.navyMid,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: expanded
              ? Container(
            decoration: BoxDecoration(
              color: AppColors.navyMid.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.md),
              ),
              border: Border(
                top: BorderSide(color: AppColors.lightBorder),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (onOpenFullForm != null) ...[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onOpenFullForm,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(44, 12, 14, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Icon(
                                Icons.layers_outlined,
                                size: 18,
                                color: AppColors.goldPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Complete form (all sections)',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.navyDark,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                size: 18,
                                color:
                                    AppColors.navyMid.withValues(alpha: 0.4)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 44,
                    color: AppColors.lightBorder,
                  ),
                ],
                for (var i = 0; i < entry.subSections.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 44,
                      color: AppColors.lightBorder,
                    ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onChildTap(entry.subSections[i]),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(44, 12, 14, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Icon(
                                Icons.subdirectory_arrow_right_rounded,
                                size: 18,
                                color:
                                    AppColors.navyMid.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.subSections[i].displayLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.navyDark,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                size: 18,
                                color:
                                    AppColors.navyMid.withValues(alpha: 0.4)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
