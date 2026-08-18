import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Shared white-card report hub layout (matches Monthly module hub pattern).
class ModuleHubReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onSummaryTap;
  final bool showSummaryButton;
  final bool showFilterRow;
  final Widget filterRow;
  final Widget categoryButtons;
  final Widget? child;

  const ModuleHubReportCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.filterRow,
    required this.categoryButtons,
    this.onSummaryTap,
    this.showSummaryButton = true,
    this.showFilterRow = true,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (showSummaryButton && onSummaryTap != null)
                  ElevatedButton.icon(
                    onPressed: onSummaryTap,
                    icon: const Icon(Icons.download_rounded,
                        size: 16, color: Colors.white),
                    label: Text(
                      'Summary',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyMid,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
              ],
            ),
            if (showFilterRow) ...[
              const SizedBox(height: 12),
              filterRow,
              const SizedBox(height: 14),
            ] else
              const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.navyMid.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: categoryButtons,
            ),
            if (child != null) ...[
              const SizedBox(height: 14),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Navy pill button matching Monthly Class V / VI / Preventives styling.
/// Fixed height so every grid cell is uniform regardless of label length.
class ModuleHubCategoryButton extends StatelessWidget {
  static const double height = 44;

  final String label;
  final VoidCallback onTap;

  const ModuleHubCategoryButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyMid,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          minimumSize: Size(double.infinity, height),
          maximumSize: Size(double.infinity, height),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.clip,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Fixed-column grid for [ModuleHubCategoryButton] — equal cell width/height,
/// consistent spacing; used by Pending and Forms hub screens.
class ModuleHubCategoryButtonGrid extends StatelessWidget {
  static const int defaultCrossAxisCount = 2;
  static const double spacing = 8;

  final List<String> labels;
  final ValueChanged<String> onLabelTap;
  final int crossAxisCount;

  const ModuleHubCategoryButtonGrid({
    super.key,
    required this.labels,
    required this.onLabelTap,
    this.crossAxisCount = defaultCrossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: labels.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        mainAxisExtent: ModuleHubCategoryButton.height,
      ),
      itemBuilder: (context, index) {
        final label = labels[index];
        return ModuleHubCategoryButton(
          label: label,
          onTap: () => onLabelTap(label),
        );
      },
    );
  }
}

/// Bordered dropdown field matching Monthly month/year selectors.
class ModuleHubFilterDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool expanded;

  const ModuleHubFilterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final dropdown = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: expanded,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.navyMid),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );

    if (expanded) {
      return Expanded(child: dropdown);
    }
    return dropdown;
  }
}
