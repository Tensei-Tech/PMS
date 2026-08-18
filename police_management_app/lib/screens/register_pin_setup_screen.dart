import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import 'pending_approval_screen.dart';

class RegistrationDraft {
  const RegistrationDraft({
    required this.fullName,
    required this.designation,
    required this.mobile,
    required this.email,
    required this.state,
    required this.unitType,
    required this.district,
    required this.stationName,
    required this.stationAddress,
    this.idCardFile,
    this.selfieFile,
  });

  final String fullName;
  final String designation;
  final String mobile;
  final String email;
  final String state;
  final String unitType;
  final String district;
  final String stationName;
  final String stationAddress;
  final XFile? idCardFile;
  final XFile? selfieFile;
}

/// Step 2 of registration: Set the 6-digit Login PIN and submit to Firebase.
class RegisterPinSetupScreen extends StatefulWidget {
  const RegisterPinSetupScreen({super.key, required this.draft});

  final RegistrationDraft draft;

  @override
  State<RegisterPinSetupScreen> createState() => _RegisterPinSetupScreenState();
}

class _RegisterPinSetupScreenState extends State<RegisterPinSetupScreen> {
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

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: color,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final auth = context.read<AuthProvider>();
      final draft = widget.draft;

      final result = await auth.registerWithPin(
        fullName: draft.fullName,
        designation: draft.designation,
        email: draft.email,
        phone: draft.mobile,
        pin: _pinCtrl.text.trim(),
        idCardFile: draft.idCardFile,
        selfieFile: draft.selfieFile,
        stationName: draft.stationName,
        stationAddress: draft.stationAddress,
        stationLandline: '',
        district: draft.district,
        govtId: draft.email,
      );

      if (!mounted) return;

      if (!result.success) {
        final errorMsg =
            result.errorMessage ?? 'Registration failed. Please try again.';
        _showSnack(errorMsg, _getErrorColor(result.errorCode));
        return;
      }

      final userId = result.userId;
      if (userId == null || userId.trim().isEmpty) {
        _showSnack(
          'Registration did not return a user id. Please try again.',
          AppColors.dangerRed,
        );
        return;
      }

      _showSnack(
        'Registration submitted for approval.',
        AppColors.successGreen,
      );

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      await _navigateToPendingApproval();
    } catch (e, st) {
      debugPrint('RegisterPinSetupScreen._register failed: $e\n$st');
      if (!mounted) return;
      _showSnack(
        'Registration failed unexpectedly: $e',
        AppColors.dangerRed,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _navigateToPendingApproval() async {
    try {
      final auth = context.read<AuthProvider>();
      await auth.signOutToLogin();
    } catch (e) {
      debugPrint('signOutToLogin after registration failed: $e');
    }
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      AppTheme.fadeSlideRoute(page: const PendingApprovalScreen()),
      (_) => false,
    );
  }

  Color _getErrorColor(String? errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return AppColors.warningOrange;
      case 'network-request-failed':
      case 'unavailable':
        return AppColors.warningOrange;
      case 'firestore-error':
      case 'permission-denied':
        return AppColors.dangerRed;
      default:
        return AppColors.dangerRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Set Your Login PIN',
              style: GoogleFonts.poppins(
                color: AppColors.navyDark,
                fontWeight: FontWeight.w700,
              )),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navyDark),
            onPressed: _loading ? null : () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFF0F4FF),
              ],
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
                      minHeight: availableHeight - (AppSpacing.lg * 2)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isKeyboardOpen)
                          Text(
                            'This 6-digit PIN will be required every time you log in.',
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
                          enabled: !_loading,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Enter 6-digit PIN',
                            hintText: '●●●●●●',
                            prefixIcon: const Icon(Icons.lock_rounded),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFF),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          validator: AppValidators.pin,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _confirmCtrl,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          enabled: !_loading,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Confirm PIN',
                            hintText: '●●●●●●',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFF),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          validator: (v) {
                            final basic = AppValidators.pin(v);
                            if (basic != null) return basic;
                            if (v != _pinCtrl.text) return 'PINs do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl + 20),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _register,
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
                                : Text('Register',
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
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
    );
  }
}
