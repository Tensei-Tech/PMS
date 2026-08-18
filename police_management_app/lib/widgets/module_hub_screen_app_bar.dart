import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Shared AppBar for module hub screens (Pending, Forms, Monthly, Form I-V).
class ModuleHubScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final String badgeLabel;
  final VoidCallback? onAddPressed;
  final Color? backgroundColor;

  const ModuleHubScreenAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    this.onAddPressed,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.white;
    final isDarkHeader = bg != Colors.white;
    final textColor = isDarkHeader ? Colors.white : AppColors.navyDark;
    final subTextColor =
        isDarkHeader ? Colors.white.withValues(alpha: 0.7) : AppColors.lightSubText;
    final iconColor = isDarkHeader ? Colors.white : AppColors.navyDark;
    final btnBg = isDarkHeader ? AppColors.goldPrimary : AppColors.navyDark;
    final btnFg = isDarkHeader ? AppColors.navyDark : Colors.white;

    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: iconColor, size: 20),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: subTextColor,
            ),
          ),
        ],
      ),
      actions: [
        if (onAddPressed != null)
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: Icon(Icons.add_rounded, color: btnFg, size: 16),
              label: Text(
                'Add Case',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: btnFg,
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: btnBg,
                foregroundColor: btnFg,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: const StadiumBorder(),
                elevation: 3,
                shadowColor: btnBg.withValues(alpha: 0.3),
              ),
            ),
          ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border:
                  Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                badgeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
