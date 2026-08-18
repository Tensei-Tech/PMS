import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared Form I-V IPC case-type labels — single source for bottom sheet
/// and full-screen selection.
const List<String> kFormIVCaseCategories = [
  'Murder',
  'Attempt to Murder',
  'Dacoity',
  'Robbery',
  'HBT',
  'Thefts',
  'Riot',
  'Unlawful Assembly',
  'Kidnapping',
  'CBT',
  'Cheating',
  'Mischief',
  'Hurts',
  'Assault on Public Servant',
  'Rape',
  'Molestation',
  'Suicide',
  'Death Due to Rash Driving',
  'Extortion',
  'IPC (A) 304',
  '498 (A) IPC',
  'Other IPC',
];

/// Teal gradient category button for Form I-V case-type grids.
class FormIVCategoryButton extends StatelessWidget {
  static const double height = 54;

  static const LinearGradient gradient = LinearGradient(
    colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final String label;
  final VoidCallback onTap;

  const FormIVCategoryButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2193B0).withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  label.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Three-column fixed-height grid for [FormIVCategoryButton].
class FormIVCategoryButtonGrid extends StatelessWidget {
  static const int crossAxisCount = 3;
  static const double spacing = 10;

  final List<String> labels;
  final ValueChanged<String> onLabelTap;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  const FormIVCategoryButtonGrid({
    super.key,
    required this.labels,
    required this.onLabelTap,
    this.padding = EdgeInsets.zero,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: !scrollable,
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: labels.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        mainAxisExtent: FormIVCategoryButton.height,
      ),
      itemBuilder: (context, index) {
        final label = labels[index];
        return FormIVCategoryButton(
          label: label,
          onTap: () => onLabelTap(label),
        );
      },
    );
  }
}
