// lib/screens/feedback_form_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/feedback_service.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({super.key});

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _feedbackCtrl = TextEditingController();
  
  String _selectedCategory = 'Suggestion';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Suggestion', 'icon': Icons.lightbulb_outline_rounded},
    {'label': 'Bug / Issue', 'icon': Icons.bug_report_outlined},
    {'label': 'Feature Request', 'icon': Icons.extension_outlined},
    {'label': 'General', 'icon': Icons.chat_bubble_outline_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      _nameCtrl.text = auth.fullName;
      _emailCtrl.text = auth.email;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String? val) {
    final v = val?.trim() ?? '';
    if (v.isEmpty) return 'Name is required';
    if (v.length < 2) return 'Enter a valid name';
    return null;
  }

  String? _validateGovtEmail(String? val) {
    final v = val?.trim() ?? '';
    if (v.isEmpty) return 'Government email is required';
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  String? _validateMessage(String? val) {
    final v = val?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your feedback';
    if (v.length < 10) return 'Message must be at least 10 characters';
    return null;
  }

  void _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final success = await FeedbackService().submitFeedback(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        category: _selectedCategory,
        message: _feedbackCtrl.text.trim(),
      );

      if (success) {
        if (mounted) {
          _feedbackCtrl.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Text('Thank you! Your feedback has been submitted.',
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
                ],
              ),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              margin: const EdgeInsets.all(AppSpacing.md),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to submit feedback');
      }
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text('Failed to submit. Please check your connection.',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
              ],
            ),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            margin: const EdgeInsets.all(AppSpacing.md),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          l10n.feedback,
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
          _buildHeroHeaderBanner(),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Officer Info Card (Read-only) ───────────────────
                          _buildSectionCard(
                            title: 'Officer Information',
                            subtitle: 'Verified credentials automatically linked to your submission',
                            icon: Icons.verified_user_rounded,
                            accentColor: AppColors.navyMid,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(l10n.fullName),
                                const SizedBox(height: 6),
                                _buildTextFormField(
                                  controller: _nameCtrl,
                                  hintText: l10n.fullName,
                                  icon: Icons.person_rounded,
                                  keyboardType: TextInputType.name,
                                  validator: _validateName,
                                  readOnly: true,
                                  suffixIcon: Icons.lock_outline_rounded,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _buildLabel(l10n.govGmail),
                                const SizedBox(height: 6),
                                _buildTextFormField(
                                  controller: _emailCtrl,
                                  hintText: 'name@dept.gov.in',
                                  icon: Icons.email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateGovtEmail,
                                  readOnly: true,
                                  suffixIcon: Icons.lock_outline_rounded,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // ── Feedback Submission Card ────────────────────────
                          _buildSectionCard(
                            title: 'Your Feedback',
                            subtitle: 'Select category and describe your thoughts or issues',
                            icon: Icons.rate_review_rounded,
                            accentColor: AppColors.cyanDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Category'),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _categories.map((cat) {
                                    final isSelected = _selectedCategory == cat['label'];
                                    return ChoiceChip(
                                      showCheckmark: false,
                                      avatar: Icon(
                                        cat['icon'] as IconData,
                                        size: 16,
                                        color: isSelected ? Colors.white : AppColors.navyMid,
                                      ),
                                      label: Text(
                                        cat['label'] as String,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                          color: isSelected ? Colors.white : AppColors.navyDark,
                                        ),
                                      ),
                                      selected: isSelected,
                                      selectedColor: AppColors.navyMid,
                                      backgroundColor: AppColors.lightBg,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                        side: BorderSide(
                                          color: isSelected
                                              ? AppColors.navyMid
                                              : AppColors.navyMid.withValues(alpha: 0.15),
                                        ),
                                      ),
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() => _selectedCategory = cat['label'] as String);
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _buildLabel('Message'),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _feedbackCtrl,
                                  maxLines: 5,
                                  validator: _validateMessage,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.lightText,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Describe your suggestion, feature request, or issue details...',
                                    hintStyle: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppColors.lightSubText.withValues(alpha: 0.7),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
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
                                      borderSide: const BorderSide(
                                        color: AppColors.navyMid,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                      borderSide: const BorderSide(color: AppColors.dangerRed, width: 1.5),
                                    ),
                                    contentPadding: const EdgeInsets.all(14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // ── Submit Button ────────────────────────────────────
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.navyDark.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitFeedback,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Submit Feedback',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.3,
                                          ),
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
                    Icons.rate_review_rounded,
                    color: AppColors.goldPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We Value Your Feedback',
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
                  'Help us improve the system by sharing your thoughts or reporting issues',
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.navyDark,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    bool readOnly = false,
    IconData? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.lightText,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: AppColors.lightSubText,
        ),
        prefixIcon: Icon(icon, color: AppColors.navyMid, size: 20),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: AppColors.lightSubText, size: 18)
            : null,
        filled: true,
        fillColor: readOnly ? AppColors.lightBg.withValues(alpha: 0.6) : Colors.white,
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
          borderSide: const BorderSide(
            color: AppColors.navyMid,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.dangerRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}