// lib/screens/post_register_pin_setup_screen.dart
// Post-registration PIN setup fallback shown only when device biometrics are
// NOT supported. Hashes the PIN using the existing PBKDF2 utility and stores
// the result in flutter_secure_storage under 'hashed_pin' along with
// 'auth_method' = 'pin'. Then proceeds to home.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../utils/pin_crypto.dart';
import 'dashboard_screen.dart';

class PostRegisterPinSetupScreen extends StatefulWidget {
  const PostRegisterPinSetupScreen({super.key});

  @override
  State<PostRegisterPinSetupScreen> createState() =>
      _PostRegisterPinSetupScreenState();
}

class _PostRegisterPinSetupScreenState
    extends State<PostRegisterPinSetupScreen> {
  static const _secure = FlutterSecureStorage();

  final _formKey = GlobalKey<FormState>();
  final _pinCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _pinCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validatePin(String? v) {
    if (v == null || v.isEmpty) return 'PIN is required';
    if (v.length < 4 || v.length > 6) return 'PIN must be 4-6 digits';
    if (!RegExp(r'^\d{4,6}$').hasMatch(v)) {
      return 'PIN must contain only digits';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final pin = _pinCtrl.text.trim();
      final salt = PinCrypto.generateSalt();
      final pinHash = await PinCrypto.hashPinAsync(pin, salt);

      await _secure.write(key: 'hashed_pin', value: pinHash);
      await _secure.write(key: 'hashed_pin_salt', value: salt);
      await _secure.write(key: 'auth_method', value: 'pin');

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        AppTheme.fadeSlideRoute(page: const DashboardScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save PIN. Please try again.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
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
            title: Text(
              'Set Your Login PIN',
              style: GoogleFonts.poppins(
                color: AppColors.navyDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFF0F4FF)],
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final bool isKeyboardOpen =
                    MediaQuery.of(context).viewInsets.bottom > 0;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: availableHeight - (AppSpacing.lg * 2),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isKeyboardOpen)
                            Text(
                              'Your device does not support biometrics.\nSet a 4-6 digit PIN to secure your account.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.lightSubText,
                              ),
                            ),
                          if (!isKeyboardOpen)
                            const SizedBox(height: AppSpacing.xl),
                          TextFormField(
                            controller: _pinCtrl,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Enter 4-6 digit PIN',
                              hintText: '●●●●',
                              prefixIcon: const Icon(Icons.lock_rounded),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFF),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            validator: _validatePin,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _confirmCtrl,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Confirm PIN',
                              hintText: '●●●●',
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFF),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            validator: (v) {
                              final basic = _validatePin(v);
                              if (basic != null) return basic;
                              if (v != _pinCtrl.text) {
                                return 'PINs do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl + 20),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navyMid,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                                elevation: 0,
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Save PIN',
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
