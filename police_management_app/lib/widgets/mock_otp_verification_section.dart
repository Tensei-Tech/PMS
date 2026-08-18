import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Mock OTP verification used across Register and Forgot PIN pages.
///
/// - Does NOT call any paid/third-party OTP provider.
/// - In dev mode it always verifies against `123456`.
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

class _MockOtpVerificationSectionState extends State<MockOtpVerificationSection> {
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

    // For developer convenience: auto-fill mock OTP.
    Future.delayed(const Duration(milliseconds: 250), () {
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
      setState(() => _error = 'Invalid OTP. Please try again.');
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
    final disabled = !widget.enabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Major section header
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(widget.subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            if (_verified)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                      color: AppColors.successGreen.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded,
                        color: AppColors.successGreen, size: 16),
                    const SizedBox(width: 6),
                    Text('Verified',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.successGreen)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Send/Resend OTP button row
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed:
                    disabled ? null : (_secondsLeft > 0 ? null : _sendOtp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyMid,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                  elevation: 0,
                ),
                child: Text(
                  _otpSent ? 'Resend OTP' : 'Send OTP',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (_otpSent)
              Text(
                _secondsLeft > 0 ? 'Resend in $_secondsLeft s' : 'You can resend now',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _secondsLeft > 0 ? Colors.black54 : AppColors.successGreen,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (_otpSent) ...[
          TextField(
            controller: _otpCtrl,
            enabled: !disabled && !_verified,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              labelText: 'Enter OTP',
              hintText: '6-digit OTP',
              errorText: _error,
              filled: true,
              fillColor: disabled ? const Color(0xFFF1F3F7) : const Color(0xFFF8FAFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: (!disabled && !_verified) ? _verifyOtp : null,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                side: const BorderSide(color: AppColors.navyMid),
              ),
              child: Text('Verify OTP',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ],
    );
  }
}

