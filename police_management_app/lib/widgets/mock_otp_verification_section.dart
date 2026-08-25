import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Modern, compact OTP verification component used across Register and Forgot PIN pages.
///
/// - High-density single-row layout to prevent UI stretching.
/// - In dev mode, automatically fills the test OTP `123456`.
class MockOtpVerificationSection extends StatefulWidget {
  const MockOtpVerificationSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onVerifiedChanged,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final ValueChanged<bool> onVerifiedChanged;
  final bool enabled;

  @override
  State<MockOtpVerificationSection> createState() =>
      _MockOtpVerificationSectionState();
}

class _MockOtpVerificationSectionState
    extends State<MockOtpVerificationSection> {
  static const _mockOtp = '123456';
  static const _resendSeconds = 60;

  final _otpCtrl = TextEditingController();
  Timer? _timer;

  bool _otpSent = false;
  bool _verified = false;
  int _secondsLeft = 0;
  String? _error;

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _sendOtp() {
    if (!widget.enabled) return;
    setState(() {
      _otpSent = true;
      _verified = false;
      _error = null;
      _otpCtrl.text = '';
    });
    widget.onVerifiedChanged(false);
    _startTimer();

    // Auto-fill mock OTP for smooth developer testing.
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() => _otpCtrl.text = _mockOtp);
    });
  }

  void _verifyOtp() {
    if (!widget.enabled) return;
    final value = _otpCtrl.text.trim();
    if (value.length != 6) {
      setState(() => _error = 'Enter the 6-digit OTP');
      return;
    }
    if (value != _mockOtp) {
      setState(() => _error = 'Invalid OTP. Please enter 123456.');
      widget.onVerifiedChanged(false);
      return;
    }
    setState(() {
      _verified = true;
      _error = null;
    });
    widget.onVerifiedChanged(true);
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = !widget.enabled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _verified
            ? AppColors.successGreen.withValues(alpha: 0.05)
            : const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _verified
              ? AppColors.successGreen.withValues(alpha: 0.3)
              : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Section Label + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                      ),
                    ),
                    Text(
                      _verified ? 'OTP verified successfully' : widget.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _verified
                            ? AppColors.successGreen
                            : AppColors.lightSubText,
                      ),
                    ),
                  ],
                ),
              ),
              if (_verified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.successGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.successGreen, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // ── STATE 1: NOT VERIFIED YET ──────────────────────────────────────
          if (!_verified) ...[
            const SizedBox(height: 10),
            if (!_otpSent) ...[
              // Send OTP Compact Action
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: disabled ? null : _sendOtp,
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: Text(
                    'Send OTP',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyMid,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.navyMid.withValues(alpha: 0.2),
                    disabledForegroundColor: AppColors.lightSubText,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Integrated OTP Input + Verify Button (Single Row)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _otpCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                          color: AppColors.navyDark,
                        ),
                        decoration: InputDecoration(
                          hintText: '••••••',
                          hintStyle: GoogleFonts.poppins(
                            letterSpacing: 3,
                            color:
                                AppColors.lightSubText.withValues(alpha: 0.5),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_clock_rounded,
                            color: AppColors.navyMid,
                            size: 18,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm + 2),
                            borderSide:
                                const BorderSide(color: AppColors.lightBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm + 2),
                            borderSide:
                                const BorderSide(color: AppColors.lightBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm + 2),
                            borderSide: const BorderSide(
                                color: AppColors.navyMid, width: 2),
                          ),
                        ),
                        onSubmitted: (_) => _verifyOtp(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navyMid,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                        ),
                      ),
                      child: Text(
                        'Verify',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (_error != null) ...[
                const SizedBox(height: 6),
                Text(
                  _error!,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.dangerRed,
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // Subtle Resend Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _secondsLeft > 0
                        ? 'Resend available in ${_secondsLeft}s'
                        : 'Did not receive code?',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.lightSubText,
                    ),
                  ),
                  TextButton(
                    onPressed: _secondsLeft > 0 ? null : _sendOtp,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Resend OTP',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _secondsLeft > 0
                            ? AppColors.lightSubText
                            : AppColors.navyMid,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
