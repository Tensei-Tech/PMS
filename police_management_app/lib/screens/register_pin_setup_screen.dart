import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/app_logo.dart';
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
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  @override
  void initState() {
    super.initState();
    _pinCtrl.addListener(() => setState(() {}));
    _confirmCtrl.addListener(() => setState(() {}));
  }

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

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A142F),
            Color(0xFF132247),
            Color(0xFF1A2B5E),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A142F).withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _loading ? null : () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const AppLogo(size: 38),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Officer Setup',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Security Credentials & PIN',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFFB300),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_rounded,
                        size: 13,
                        color: Color(0xFFFFB300),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Step 2/2',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFB300),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficerCredentialCard() {
    final draft = widget.draft;
    final initials = draft.fullName.trim().isNotEmpty
        ? draft.fullName
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'POL';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFB300).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.navyMid,
                  AppColors.navyDark,
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navyMid.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFFB300),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        draft.fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: AppColors.successGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${draft.designation} • ${draft.stationName}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.lightSubText,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  draft.email,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.navyMid,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTactilePinIndicator(String pin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isFilled = index < pin.length;
        final isActive = index == pin.length;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 42,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isFilled
                ? AppColors.navyMid.withValues(alpha: 0.08)
                : const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFFFB300)
                  : isFilled
                      ? AppColors.navyMid
                      : AppColors.lightBorder,
              width: isActive ? 2.2 : (isFilled ? 1.6 : 1),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : (isFilled
                    ? [
                        BoxShadow(
                          color: AppColors.navyMid.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null),
          ),
          child: Center(
            child: isFilled
                ? (_obscurePin
                    ? Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.navyDark,
                          shape: BoxShape.circle,
                        ),
                      )
                    : Text(
                        pin[index],
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyDark,
                        ),
                      ))
                : Text(
                    '●',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.lightBorder,
                    ),
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildChecklistRow({
    required bool condition,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: condition
                  ? AppColors.successGreen
                  : AppColors.lightSubText.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 11,
              color: condition ? Colors.white : AppColors.lightSubText,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: condition ? FontWeight.w600 : FontWeight.w500,
              color: condition ? AppColors.navyDark : AppColors.lightSubText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pin = _pinCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    final bool has6Digits = pin.length == 6;
    final bool hasConfirm6Digits = confirm.length == 6;
    final bool isMatching = has6Digits && hasConfirm6Digits && pin == confirm;

    return Theme(
      data: AppTheme.lightTheme(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        body: Column(
          children: [
            // Top Navigation Banner
            _buildTopHeader(context),

            // Scrollable Content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth >= 768;
                  final double contentMaxWidth =
                      isWide ? 500.0 : double.infinity;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 0 : 20,
                      vertical: 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: Column(
                          children: [
                            // Officer Identity Snapshot
                            _buildOfficerCredentialCard(),
                            const SizedBox(height: 16),

                            // Main PIN Form Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: const Color(0xFFE5ECF6),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Section Header
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.navyMid
                                                .withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.md),
                                          ),
                                          child: const Icon(
                                            Icons.pin_rounded,
                                            size: 20,
                                            color: AppColors.navyMid,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Create 6-Digit PIN',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.navyDark,
                                                ),
                                              ),
                                              Text(
                                                'Used to unlock app and decrypt session',
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
                                    const SizedBox(height: 20),

                                    // Visual Tactile PIN Display
                                    _buildTactilePinIndicator(pin),
                                    const SizedBox(height: 20),

                                    // Create PIN Input
                                    TextFormField(
                                      controller: _pinCtrl,
                                      keyboardType: TextInputType.number,
                                      obscureText: _obscurePin,
                                      enabled: !_loading,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.navyDark,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: _obscurePin ? 4 : 2,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Enter 6-digit PIN',
                                        hintText: '●●●●●●',
                                        hintStyle: GoogleFonts.poppins(
                                          color: AppColors.lightSubText
                                              .withValues(alpha: 0.5),
                                          letterSpacing: 3,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.lock_rounded,
                                          color: AppColors.navyMid,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePin
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            color: AppColors.lightSubText,
                                            size: 20,
                                          ),
                                          onPressed: () => setState(
                                              () => _obscurePin = !_obscurePin),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF8FAFF),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.md),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.md),
                                          borderSide: const BorderSide(
                                              color: AppColors.lightBorder),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.md),
                                          borderSide: const BorderSide(
                                              color: AppColors.navyMid,
                                              width: 2),
                                        ),
                                      ),
                                      validator: AppValidators.pin,
                                    ),
                                    const SizedBox(height: 14),

                                    // Confirm PIN Input
                                    TextFormField(
                                      controller: _confirmCtrl,
                                      keyboardType: TextInputType.number,
                                      obscureText: _obscureConfirmPin,
                                      enabled: !_loading,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.navyDark,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing:
                                            _obscureConfirmPin ? 4 : 2,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Confirm 6-digit PIN',
                                        hintText: '●●●●●●',
                                        hintStyle: GoogleFonts.poppins(
                                          color: AppColors.lightSubText
                                              .withValues(alpha: 0.5),
                                          letterSpacing: 3,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                          color: AppColors.navyMid,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPin
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            color: AppColors.lightSubText,
                                            size: 20,
                                          ),
                                          onPressed: () => setState(() =>
                                              _obscureConfirmPin =
                                                  !_obscureConfirmPin),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF8FAFF),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.md),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.md),
                                          borderSide: const BorderSide(
                                              color: AppColors.lightBorder),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.md),
                                          borderSide: const BorderSide(
                                              color: AppColors.navyMid,
                                              width: 2),
                                        ),
                                      ),
                                      validator: (v) {
                                        final basic = AppValidators.pin(v);
                                        if (basic != null) return basic;
                                        if (v != _pinCtrl.text) {
                                          return 'PINs do not match';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // Dynamic Checklist Box
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFF),
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildChecklistRow(
                                            condition: has6Digits,
                                            text:
                                                'Contains exactly 6 numeric digits',
                                          ),
                                          _buildChecklistRow(
                                            condition: isMatching,
                                            text:
                                                'Confirmation PIN matches exactly',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Hardware Security & Biometric Note
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.navyMid
                                            .withValues(alpha: 0.04),
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        border: Border.all(
                                          color: AppColors.navyMid
                                              .withValues(alpha: 0.1),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.fingerprint_rounded,
                                            size: 22,
                                            color: AppColors.navyMid,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Local secure storage & Biometric Quick-Unlock enabled for this officer profile.',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: AppColors.lightSubText,
                                                height: 1.35,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 22),

                                    // Submit Action Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed: _loading ? null : _register,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.navyDark,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor: AppColors
                                              .navyMid
                                              .withValues(alpha: 0.4),
                                          disabledForegroundColor: Colors.white
                                              .withValues(alpha: 0.85),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.md),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _loading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.verified_user_rounded,
                                                    size: 20,
                                                    color: Color(0xFFFFB300),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'Complete & Submit',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
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
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
