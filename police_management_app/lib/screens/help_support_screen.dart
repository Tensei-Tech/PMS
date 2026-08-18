// lib/screens/help_support_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchUri(BuildContext context, String uriString, String rawValue, String label) async {
    await Clipboard.setData(ClipboardData(text: rawValue));

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
                  'Opening $label ($rawValue copied to clipboard)',
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

    try {
      final uri = Uri.parse(uriString);
      bool ok = false;
      try {
        ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}

      if (!ok) {
        try {
          ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (_) {}
      }

      if (!ok) {
        try {
          await launchUrl(uri);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[HelpSupport] Launch URL exception: $e');
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
          'Help & Support',
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
                        // ── Support Channels Section ─────────────────────────
                        _buildSectionCard(
                          title: 'Contact Support Channels',
                          subtitle: 'Reach out to our technical team through any channel below',
                          icon: Icons.contact_support_rounded,
                          accentColor: AppColors.navyMid,
                          child: Column(
                            children: [
                              _buildSupportTile(
                                icon: Icons.email_rounded,
                                title: 'Email Support',
                                subtitle: 'gkutarmare@gmail.com',
                                badgeText: 'Gmail',
                                color: AppColors.infoBlue,
                                onTap: () => _launchUri(
                                  context,
                                  kIsWeb
                                      ? 'https://mail.google.com/mail/?view=cm&fs=1&to=gkutarmare@gmail.com&su=PMS%20Support%20Request'
                                      : 'mailto:gkutarmare@gmail.com?subject=PMS%20Support%20Request',
                                  'gkutarmare@gmail.com',
                                  'Gmail',
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _buildSupportTile(
                                icon: Icons.phone_rounded,
                                title: 'Helpline Number',
                                subtitle: '+91 72490 39490',
                                badgeText: '24/7 Call',
                                color: AppColors.successGreen,
                                onTap: () => _launchUri(
                                  context,
                                  'tel:+917249039490',
                                  '+91 72490 39490',
                                  'Helpline',
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _buildSupportTile(
                                icon: Icons.chat_rounded,
                                title: 'Chat on WhatsApp',
                                subtitle: 'Instant chat with support team',
                                badgeText: 'WhatsApp',
                                color: const Color(0xFF25D366),
                                onTap: () => _launchUri(
                                  context,
                                  'https://api.whatsapp.com/send?phone=919307583929&text=Hello%20PMS%20Support',
                                  '+91 93075 83929',
                                  'WhatsApp Chat',
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _buildSupportTile(
                                icon: Icons.language_rounded,
                                title: 'Official Website',
                                subtitle: 'tenseitech.com',
                                color: AppColors.goldPrimary,
                                onTap: () => _launchUri(
                                  context,
                                  'https://tenseitech.com/',
                                  'https://tenseitech.com/',
                                  'Official Website',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // ── Footer Info ──────────────────────────────────────
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.navyMid.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                child: Text(
                                  'Version 2.4.0 • Build 2026.08',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.navyMid,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Developed by Tensei Tech Pvt Ltd',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.lightSubText,
                                ),
                              ),
                            ],
                          ),
                        ),
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
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.headset_mic_rounded,
                    color: AppColors.goldPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'How Can We Help You?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Our dedicated technical support team is available 24/7 to assist you',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.8),
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

  Widget _buildSupportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.navyDark,
              ),
            ),
            if (badgeText != null && badgeText.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            color: AppColors.lightSubText,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppColors.lightSubText,
        ),
      ),
    );
  }
}