// lib/screens/forgot_password_screen.dart
// ISSUE 3: Forgot PIN flow (Email OTP verification + Set new PIN).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
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
  String? _emailMismatchError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyRegisteredEmail() async {
    setState(() => _emailMismatchError = null);
    final auth = context.read<AuthProvider>();
    final stored = await auth.getStoredGovtEmail();
    final input = _emailCtrl.text.trim();
    if (stored.isEmpty) {
      setState(() =>
          _emailMismatchError = 'No registered account found on this device.');
      return;
    }
    if (stored.toLowerCase() != input.toLowerCase()) {
      setState(() => _emailMismatchError =
          'Email does not match the registered Government ID.');
    }
  }

  Future<void> _resetPin() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_emailOtpVerified) return;
    setState(() => _loading = true);

    await context.read<AuthProvider>().resetPin(_newPinCtrl.text.trim());

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PIN reset successfully!', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.successGreen,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFF0F4FF),
                Color(0xFFE3E9F9),
              ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
                final bool isSmallScreen = availableHeight < 700;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: AppColors.navyDark),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.navyMid.withValues(alpha: 0.1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: availableHeight - 80),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!isKeyboardOpen)
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: isSmallScreen ? 60 : 80,
                                      height: isSmallScreen ? 60 : 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: AppColors.goldGradient,
                                        boxShadow: [
                                          BoxShadow(
                                              color: AppColors.goldPrimary
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 20,
                                              spreadRadius: 2),
                                        ],
                                      ),
                                      child: Icon(Icons.lock_reset_rounded,
                                          color: AppColors.navyDark,
                                          size: isSmallScreen ? 32 : 40),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text('Forgot PIN?',
                                        style: GoogleFonts.poppins(
                                            fontSize: isSmallScreen ? 20 : 24,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.navyDark)),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Verify your Government Email ID and reset your login PIN.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.lightSubText),
                                    ),
                                    const SizedBox(height: 30),
                                  ],
                                ),

                              // Main card
                              Container(
                                padding: EdgeInsets.all(isSmallScreen
                                    ? AppSpacing.md
                                    : AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppRadius.xl),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Step 1 — Verify Identity',
                                          style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.navyDark)),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: _emailCtrl,
                                        enabled: !_emailOtpVerified,
                                        keyboardType: TextInputType.emailAddress,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        style: GoogleFonts.poppins(
                                            color: AppColors.lightText,
                                            fontSize: 14),
                                        decoration: InputDecoration(
                                          labelText: 'Government Email ID',
                                          hintText: 'name@department.gov.in',
                                          errorText: _emailMismatchError,
                                          prefixIcon:
                                              const Icon(Icons.email_rounded),
                                          filled: true,
                                          fillColor: const Color(0xFFF8FAFF),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.md),
                                          ),
                                        ),
                                        validator: AppValidators.govtEmail,
                                        onChanged: (_) =>
                                            _verifyRegisteredEmail(),
                                      ),
                                      const SizedBox(height: 12),
                                      MockOtpVerificationSection(
                                        title: 'Email OTP',
                                        subtitle:
                                            'For dev mode, OTP is auto-filled as 123456.',
                                        enabled: !_emailOtpVerified &&
                                            AppValidators.govtEmail(
                                                    _emailCtrl.text) ==
                                                null,
                                        onVerifiedChanged: (ok) async {
                                          setState(() => _emailOtpVerified = ok);
                                          if (ok) {
                                            await _verifyRegisteredEmail();
                                            if (_emailMismatchError != null) {
                                              setState(() =>
                                                  _emailOtpVerified = false);
                                            }
                                          }
                                        },
                                      ),
                                      
                                      // Step 2 — Set New PIN
                                      if (_emailOtpVerified) ...[
                                        const SizedBox(height: AppSpacing.lg),
                                        const Divider(),
                                        const SizedBox(height: AppSpacing.md),
                                        Text('Step 2 — Set New PIN',
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.navyDark)),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: _newPinCtrl,
                                          keyboardType: TextInputType.number,
                                          obscureText: true,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(6),
                                          ],
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                            labelText: 'Enter new 6-digit PIN',
                                            filled: true,
                                            fillColor: const Color(0xFFF8FAFF),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(
                                                  AppRadius.md),
                                            ),
                                          ),
                                          validator: AppValidators.pin,
                                        ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: _confirmPinCtrl,
                                          keyboardType: TextInputType.number,
                                          obscureText: true,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(6),
                                          ],
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                            labelText: 'Confirm new PIN',
                                            filled: true,
                                            fillColor: const Color(0xFFF8FAFF),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(
                                                  AppRadius.md),
                                            ),
                                          ),
                                          validator: (v) {
                                            final basic = AppValidators.pin(v);
                                            if (basic != null) return basic;
                                            if (v != _newPinCtrl.text) {
                                              return 'PINs do not match';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: AppSpacing.lg),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 54,
                                          child: ElevatedButton(
                                            onPressed:
                                                _loading ? null : _resetPin,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.navyMid,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppRadius.md),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: _loading
                                                ? const CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.5)
                                                : Text('Reset PIN',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
