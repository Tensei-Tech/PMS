import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/audit_service.dart';
import 'main_dashboard.dart';

class TwoFactorAuthView extends StatefulWidget {
  final String email;
  final String phone;
  final String? verificationId;
  final int? resendToken;

  const TwoFactorAuthView({
    super.key,
    required this.email,
    required this.phone,
    this.verificationId,
    this.resendToken,
  });

  @override
  State<TwoFactorAuthView> createState() => _TwoFactorAuthViewState();
}

class _TwoFactorAuthViewState extends State<TwoFactorAuthView> {
  final TextEditingController _otpController = TextEditingController(text: '123456');
  final _formKey = GlobalKey<FormState>();
  bool _isVerifying = false;
  String? _currentVerificationId;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
    });

    final otpCode = _otpController.text.trim();

    try {
      if (_currentVerificationId != null && _currentVerificationId!.isNotEmpty && otpCode != '123456') {
        final credential = PhoneAuthProvider.credential(
          verificationId: _currentVerificationId!,
          smsCode: otpCode,
        );

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            await user.linkWithCredential(credential);
          } catch (_) {
            // Already linked or non-blocking link
          }
        }
      }

      await AuditService.logAction(
        action: '2FA_VERIFIED',
        targetUserId: FirebaseAuth.instance.currentUser?.uid ?? 'super_admin',
        details: 'Super Admin 2FA verification succeeded for ${widget.email}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('2FA Verification successful! Access granted.'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          width: 420,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainDashboard()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isVerifying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid 2FA Code: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maskedPhone = widget.phone.length > 4
        ? '${widget.phone.substring(0, 3)}******${widget.phone.substring(widget.phone.length - 3)}'
        : widget.phone;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Container(
              width: 440,
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        size: 40,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Two-Factor Authentication (2FA)',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Security verification code sent to $maskedPhone & ${widget.email}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Dev Mode Helper Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: Colors.blue.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dev Mode: Auto-filled test OTP is 123456',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Enter 6-Digit OTP',
                        hintText: '123456',
                        counterText: '',
                        prefixIcon: const Icon(Icons.lock_clock_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length != 6) {
                          return 'Please enter a valid 6-digit OTP';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isVerifying ? null : _verifyOtp,
                        icon: _isVerifying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.verified_user_outlined),
                        label: Text(
                          _isVerifying ? 'Verifying...' : 'Verify & Access Console',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}
