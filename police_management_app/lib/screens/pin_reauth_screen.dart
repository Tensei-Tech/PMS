// lib/screens/pin_reauth_screen.dart
// Compulsory PIN re-authentication shown only when device biometrics are
// not available. Verifies against the existing stored PIN hash via
// AuthProvider.verifyPin. There is intentionally NO skip / not-now / back
// option — the user must enter their PIN to continue.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class PinReauthScreen extends StatefulWidget {
  /// When provided, called on successful PIN verification instead of popping
  /// the Navigator. Used by overlay-based hosts (e.g. resume lock) that must
  /// preserve the underlying screen state and remove the overlay only.
  final VoidCallback? onAuthSuccess;

  const PinReauthScreen({super.key, this.onAuthSuccess});

  @override
  State<PinReauthScreen> createState() => _PinReauthScreenState();
}

class _PinReauthScreenState extends State<PinReauthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinCtrl = TextEditingController();
  bool _verifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    if (v == null || v.isEmpty) return 'PIN is required';
    if (v.length < 4 || v.length > 6) return 'PIN must be 4-6 digits';
    if (!RegExp(r'^\d{4,6}$').hasMatch(v)) return 'PIN must contain only digits';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _verifying = true;
      _errorMessage = null;
    });

    final auth = context.read<AuthProvider>();
    final pin = _pinCtrl.text.trim();
    final ok = await auth.verifyPin(pin);

    if (!mounted) return;
    if (ok) {
      final cb = widget.onAuthSuccess;
      if (cb != null) {
        cb();
      } else {
        Navigator.of(context).pop(true);
      }
      return;
    }

    setState(() {
      _verifying = false;
      _errorMessage = 'Incorrect PIN. Please try again.';
      _pinCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Theme(
        data: AppTheme.lightTheme(),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Verify Your PIN',
              style: GoogleFonts.poppins(
                color: AppColors.navyDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFF0F4FF)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_rounded,
                        color: AppColors.navyMid,
                        size: 56,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Enter your PIN to continue',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.lightSubText,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextFormField(
                        controller: _pinCtrl,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        autofocus: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Enter PIN',
                          hintText: '●●●●',
                          prefixIcon: const Icon(Icons.lock_rounded),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          errorText: _errorMessage,
                        ),
                        validator: _validate,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _verifying ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navyMid,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                            elevation: 0,
                          ),
                          child: _verifying
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Verify',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
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
      ),
    );
  }
}
