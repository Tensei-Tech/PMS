// lib/screens/about_app_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String url, {String? copyText, String? label}) async {
    if (copyText != null) {
      await Clipboard.setData(ClipboardData(text: copyText));
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Opening ${label ?? 'Link'} ($copyText copied to clipboard)',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.navyDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            margin: const EdgeInsets.all(AppSpacing.md),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    try {
      final Uri uri = Uri.parse(url);
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}

      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (_) {}
      }

      if (!launched) {
        try {
          await launchUrl(uri);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[AboutApp] Launch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'About Khakhi Diary',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navyDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Fixed Top Hero Banner ──────────────────────────────────────────
          _buildHeroHeaderBanner(),

          // ── Scrollable Body Content ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xxl),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // [1] APP INFO CARD
                        _buildSectionCard(
                          title: 'App Overview',
                          subtitle: 'Developer, version and contact details',
                          icon: Icons.info_outline_rounded,
                          accentColor: AppColors.navyMid,
                          child: _buildInfoList(context),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // [2] FEATURES HIGHLIGHT SECTION
                        _buildSectionCard(
                          title: "What's Inside",
                          subtitle: 'Core capabilities and officer modules',
                          icon: Icons.auto_awesome_rounded,
                          accentColor: AppColors.goldPrimary,
                          child: _buildFeaturesGrid(),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // [3] SOCIAL & WEB LINKS
                        _buildSectionCard(
                          title: 'Connect With Us',
                          subtitle: 'Visit our official portal and social channels',
                          icon: Icons.share_rounded,
                          accentColor: AppColors.infoBlue,
                          child: Center(child: _buildSocialLinks(context)),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // [4] FOOTER
                        Center(child: _buildFooter()),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeaderBanner() {
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
            color: AppColors.navyDark.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.md,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AppLogo(size: 64),
                const SizedBox(height: 8),
                Text(
                  'Khakhi Diary',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2, bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Version 2.4.0 • Build 2026.08',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.goldLight,
                    ),
                  ),
                ),
                Text(
                  'Built for those who serve.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: AppColors.lightSubText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoList(BuildContext context) {
    return Column(
      children: [
        _buildInteractiveTile(
          icon: Icons.business_rounded,
          title: 'Developer',
          value: 'Tensei Tech Pvt Ltd',
          badgeText: 'Official',
          color: AppColors.navyMid,
          onTap: () => _launchUrl(
            context,
            'https://tenseitech.com/',
            copyText: 'Tensei Tech Pvt Ltd',
            label: 'Developer',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildInteractiveTile(
          icon: Icons.email_rounded,
          title: 'Contact Support',
          value: 'gkutarmare@gmail.com',
          badgeText: 'Email',
          color: AppColors.infoBlue,
          onTap: () => _launchUrl(
            context,
            kIsWeb
                ? 'https://mail.google.com/mail/?view=cm&fs=1&to=gkutarmare@gmail.com&su=PMS%20Inquiry'
                : 'mailto:gkutarmare@gmail.com?subject=PMS%20Inquiry',
            copyText: 'gkutarmare@gmail.com',
            label: 'Email',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildInteractiveTile(
          icon: Icons.language_rounded,
          title: 'Website Portal',
          value: 'https://tenseitech.com/',
          badgeText: 'Visit',
          color: AppColors.goldPrimary,
          onTap: () => _launchUrl(
            context,
            'https://tenseitech.com/',
            copyText: 'https://tenseitech.com/',
            label: 'Website',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildInteractiveTile(
          icon: Icons.phone_android_rounded,
          title: 'Platform & Environment',
          value: 'Flutter • Android, iOS & Web',
          badgeText: 'Universal',
          color: AppColors.successGreen,
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Running on Cross-Platform PMS Engine',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.5),
                ),
                backgroundColor: AppColors.navyMid,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                margin: const EdgeInsets.all(AppSpacing.md),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildInteractiveTile(
          icon: Icons.calendar_today_rounded,
          title: 'Release Version',
          value: 'Version 2.4.0 (Build 2026.08)',
          badgeText: 'Latest',
          color: AppColors.navyDark,
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Your application is up to date (v2.4.0)',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.5),
                ),
                backgroundColor: AppColors.successGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                margin: const EdgeInsets.all(AppSpacing.md),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInteractiveTile({
    required IconData icon,
    required String title,
    required String value,
    required String badgeText,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.navyMid.withValues(alpha: 0.08),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.lightSubText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.poppins(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.navyDark,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 13,
          color: AppColors.lightSubText,
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      (Icons.lock_rounded, 'Secure Login', AppColors.infoBlue),
      (Icons.assignment_rounded, 'Duty Records', AppColors.successGreen),
      (Icons.dashboard_rounded, 'Smart Dashboard', AppColors.goldPrimary),
      (Icons.notifications_active_rounded, 'Live Alerts', AppColors.warningOrange),
      (Icons.translate_rounded, 'Multi-Language', AppColors.navyMid),
      (Icons.groups_rounded, 'Staff Management', AppColors.navyDark),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 480;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 3 : 2,
            mainAxisExtent: 44,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final f = features[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.lightBg.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.navyMid.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: f.$3.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(f.$1, size: 14, color: f.$3),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navyDark,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    final socials = [
      (Icons.link_rounded, 'https://www.linkedin.com/company/tensei-tech-pvt-ltd/', 'LinkedIn', AppColors.infoBlue),
      (Icons.camera_alt_rounded, 'https://www.instagram.com/tenseitechpvtltd', 'Instagram', const Color(0xFFE1306C)),
      (Icons.language_rounded, 'https://tenseitech.com/', 'Website', AppColors.goldPrimary),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: socials.map((s) {
        return InkWell(
          onTap: () => _launchUrl(context, s.$2, copyText: s.$2, label: s.$3),
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: s.$4.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: s.$4.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(s.$1, size: 16, color: s.$4),
                const SizedBox(width: 6),
                Text(
                  s.$3,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: s.$4,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Made with ❤️ by Tensei Tech',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.navyDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '© 2026 Khakhi Diary. All Rights Reserved.',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.lightSubText,
          ),
        ),
      ],
    );
  }
}
