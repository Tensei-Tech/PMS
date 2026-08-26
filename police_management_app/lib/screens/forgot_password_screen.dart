// lib/screens/forgot_password_screen.dart
// ISSUE 3: Forgot PIN / Password flow (Email OTP verification + Set new PIN).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/validators.dart';
import '../widgets/mock_otp_verification_section.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _newPinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();

  bool _emailOtpVerified = false;
  bool _loading = false;
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPin() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_emailOtpVerified) return;
    setState(() => _loading = true);

    try {
      final email = _emailCtrl.text.trim();
      final newPin = _newPinCtrl.text.trim();
      final auth = context.read<AuthProvider>();

      await auth.resetPinForEmail(email: email, newPin: newPin);

      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Password / PIN reset successfully! Please login with your new credentials.',
              style: GoogleFonts.poppins()),
          backgroundColor: AppColors.successGreen,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not reset password: $e',
              style: GoogleFonts.poppins()),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= 768;
              final double contentMaxWidth = isWide ? 680.0 : double.infinity;
              final bool isSmallScreen = constraints.maxHeight < 700;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 0 : 20,
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_emailOtpVerified) {
                                  setState(() => _emailOtpVerified = false);
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.arrow_back_rounded,
                                  color: AppColors.navyDark),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    AppColors.navyMid.withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: isSmallScreen ? 60 : 72,
                                height: isSmallScreen ? 60 : 72,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.goldGradient,
                                ),
                                child: Icon(Icons.lock_reset_rounded,
                                    color: AppColors.navyDark,
                                    size: isSmallScreen ? 30 : 36),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text('Forgot Password / PIN?',
                                  style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 20 : 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.navyDark)),
                              const SizedBox(height: 6),
                              Text(
                                _emailOtpVerified
                                    ? 'Create and confirm your new secure login credentials.'
                                    : 'Verify your Government Email ID to reset your login password or PIN.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.lightSubText),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),

                        // Main Step Card (Step 1 or Step 2)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: AnimatedCrossFade(
                            duration: const Duration(milliseconds: 140),
                            firstCurve: Curves.easeOutQuad,
                            secondCurve: Curves.easeOutQuad,
                            crossFadeState: _emailOtpVerified
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            // ── STEP 1: VERIFY IDENTITY ───────────────────────
                            firstChild: Form(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.navyMid
                                              .withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.sm),
                                        ),
                                        child: const Icon(Icons.shield_rounded,
                                            color: AppColors.navyMid, size: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Step 1 of 2 — Verify Identity',
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.navyDark,
                                              ),
                                            ),
                                            Text(
                                              'Enter your registered Government Email ID',
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
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    style: GoogleFonts.poppins(
                                        color: AppColors.navyDark,
                                        fontSize: 14),
                                    decoration: InputDecoration(
                                      labelText: 'Government Email ID',
                                      hintText: 'name@department.gov.in',
                                      prefixIcon: const Icon(
                                          Icons.email_rounded,
                                          color: AppColors.navyMid),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFF),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                            color: AppColors.lightBorder),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                            color: AppColors.navyMid, width: 2),
                                      ),
                                    ),
                                    validator: AppValidators.govtEmail,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: 14),
                                  MockOtpVerificationSection(
                                    title: 'Email OTP',
                                    subtitle:
                                        'For dev mode, OTP is auto-filled as 123456.',
                                    enabled:
                                        _emailCtrl.text.trim().isNotEmpty &&
                                            AppValidators.govtEmail(
                                                    _emailCtrl.text) ==
                                                null,
                                    onVerifiedChanged: (ok) {
                                      setState(() => _emailOtpVerified = ok);
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // ── STEP 2: SET NEW PASSWORD / PIN ───────────────
                            secondChild: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.navyMid
                                              .withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.sm),
                                        ),
                                        child: const Icon(
                                            Icons.lock_reset_rounded,
                                            color: AppColors.navyMid,
                                            size: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Step 2 of 2 — Set New Password / PIN',
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.navyDark,
                                              ),
                                            ),
                                            Text(
                                              'Create a new password or 6-digit PIN',
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
                                  const SizedBox(height: 14),

                                  // Verified Account Summary Pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFF),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.md),
                                      border: Border.all(
                                          color: AppColors.lightBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.verified_user_rounded,
                                            color: AppColors.successGreen,
                                            size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _emailCtrl.text.trim(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.navyDark,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => setState(
                                              () => _emailOtpVerified = false),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            'Change',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.navyMid,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  TextFormField(
                                    controller: _newPinCtrl,
                                    obscureText: _obscureNewPass,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    style: GoogleFonts.poppins(
                                        color: AppColors.navyDark,
                                        fontSize: 14),
                                    decoration: InputDecoration(
                                      labelText: 'Enter new Password or PIN',
                                      hintText: '••••••••',
                                      prefixIcon: const Icon(Icons.lock_rounded,
                                          color: AppColors.navyMid),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureNewPass
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color: AppColors.lightSubText,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() =>
                                            _obscureNewPass = !_obscureNewPass),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFF),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                            color: AppColors.lightBorder),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                            color: AppColors.navyMid, width: 2),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Password or PIN is required';
                                      }
                                      if (v.length < 6) {
                                        return 'Must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _confirmPinCtrl,
                                    obscureText: _obscureConfirmPass,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    style: GoogleFonts.poppins(
                                        color: AppColors.navyDark,
                                        fontSize: 14),
                                    decoration: InputDecoration(
                                      labelText: 'Confirm new Password or PIN',
                                      hintText: '••••••••',
                                      prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                          color: AppColors.navyMid),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPass
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color: AppColors.lightSubText,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() =>
                                            _obscureConfirmPass =
                                                !_obscureConfirmPass),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFF),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                            color: AppColors.lightBorder),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                            color: AppColors.navyMid, width: 2),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Please confirm your password or PIN';
                                      }
                                      if (v.length < 6) {
                                        return 'Must be at least 6 characters';
                                      }
                                      if (v != _newPinCtrl.text) {
                                        return 'Passwords / PINs do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _loading ? null : _resetPin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.navyMid,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.md),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _loading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : Text(
                                              'Reset Password / PIN',
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
