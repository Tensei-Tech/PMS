// lib/widgets/access_denied_view.dart
// Record-level access denial for case/detail screens.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Simple access-denied body for case/detail screens (Phase 4 integration).
class AccessDeniedView extends StatelessWidget {
  const AccessDeniedView({
    super.key,
    this.message,
    this.onBack,
  });

  final String? message;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 56,
              color: AppColors.lightSubText.withValues(alpha: 0.85),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              "You don't have access to this record",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDark,
              ),
            ),
            if (message != null && message!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!.trim(),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.lightText,
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: onBack ?? () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(
                'Go back',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navyMid,
                side: BorderSide(color: AppColors.navyMid.withValues(alpha: 0.35)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
