// lib/screens/login_screen.dart
// Modern, secure login with Government ID email + 6-digit PIN and Biometrics.
// Domain 2: Brute-force lockout UI with live countdown.

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/biometric_service.dart';
import '../services/lockout_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/validators.dart';
import '../widgets/app_logo.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _govtEmailCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isReturningUser = false;
  bool _obscurePin = true;
  bool _showPinInput = false;

  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Domain 2: Brute-force lockout state ──────────────────────────────────
  final LockoutService _lockoutService = LockoutService();
  bool _isLockedOut = false;
  String _lockoutCountdown = '';
  Timer? _lockoutTimer;

  final BiometricService _biometricService = BiometricService();
  bool _isBiometricSupported = false;
  bool _biometricAutoTriggered = false;

  /// When true, a late [_loadStoredEmail] completion must not restore returning-user UI.
  bool _idSwitchRequested = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    _fadeCtrl.forward();
    _slideCtrl.forward();
    WidgetsBinding.instance.addObserver(this);

    _initAsync();
  }

  Future<void> _initAsync() async {
    try {
      await Future.wait([
        _checkLockout().catchError((e, s) => debugPrint('Error checking lockout: $e\n$s')),
        _loadStoredEmail().catchError((e, s) => debugPrint('Error loading stored email: $e\n$s')),
        _checkBiometricSupport().catchError((e, s) => debugPrint('Error checking biometric support: $e\n$s')),
      ]);
    } catch (e, s) {
      debugPrint('Error in _initAsync: $e\n$s');
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _govtEmailCtrl.dispose();
    _pinCtrl.dispose();
    _lockoutTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkBiometricSupport() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (mounted) {
      setState(() {
        _isBiometricSupported = isAvailable;
      });
    }
  }

  Future<void> _handleBiometricLogin({bool isAuto = false}) async {
    final settings = context.read<SettingsProvider>();
    if (!settings.isBiometricEnabled && !isAuto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Biometric login is disabled in settings.', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    if (isAuto && _biometricAutoTriggered) return;

    try {
      if (isAuto) {
        _biometricAutoTriggered = true;
      }

      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Please authenticate to login to Khakhi Diary',
      );

      if (!mounted) return;

      if (authenticated) {
        final auth = context.read<AuthProvider>();
        setState(() => _isLoading = true);

        final email = _govtEmailCtrl.text.trim();
        final loginError = await auth.loginWithBiometrics(email);

        if (!mounted) return;

        if (loginError == null) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.dashboard,
            (_) => false,
          );
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loginError, style: GoogleFonts.poppins()),
              backgroundColor: AppColors.dangerRed,
            ),
          );
        }
      } else {
        if (!isAuto && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication failed. Please use your PIN.', style: GoogleFonts.poppins()),
              backgroundColor: AppColors.warningOrange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkLockout() async {
    final status = await _lockoutService.checkStatus();
    if (!mounted) return;
    if (status.isLocked) {
      setState(() {
        _isLockedOut = true;
        _lockoutCountdown = status.remainingLabel;
      });
      _lockoutTimer?.cancel();
      _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
        final s = await _lockoutService.checkStatus();
        if (!mounted) return;
        if (s.isLocked) {
          setState(() => _lockoutCountdown = s.remainingLabel);
        } else {
          _lockoutTimer?.cancel();
          setState(() {
            _isLockedOut = false;
            _lockoutCountdown = '';
          });
        }
      });
    } else {
      setState(() => _isLockedOut = false);
    }
  }

  Future<void> _loadStoredEmail() async {
    if (_idSwitchRequested) return;
    final auth = context.read<AuthProvider>();
    final storedEmail = await auth.getStoredGovtEmail();
    if (_idSwitchRequested || !mounted) return;
    if (storedEmail.isNotEmpty) {
      setState(() {
        _govtEmailCtrl.text = storedEmail;
        _isReturningUser = true;
      });
    }
  }

  Future<void> _switchGovernmentId() async {
    _idSwitchRequested = true;

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e, s) {
      debugPrint('Switch ID: Firebase signOut failed: $e\n$s');
    }

    try {
      const secure = FlutterSecureStorage();
      await secure.delete(key: StorageKeys.email);
    } catch (e, s) {
      debugPrint('Switch ID: secure storage delete failed: $e\n$s');
    }

    if (!mounted) return;
    setState(() {
      _govtEmailCtrl.clear();
      _pinCtrl.clear();
      _isReturningUser = false;
      _showPinInput = false;
      _biometricAutoTriggered = false;
    });
  }

  Future<void> _handleLogin() async {
    if (_isLockedOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account locked. Try again in $_lockoutCountdown.', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final email = _govtEmailCtrl.text.trim();
    final pin = _pinCtrl.text.trim();

    String? loginError;

    if (_isReturningUser) {
      loginError = await auth.loginWithPin(email: email, pin: pin);
      if (loginError != null) await _checkLockout();
    } else {
      loginError = await auth.loginByEmailAndPin(email: email, pin: pin);
      if (loginError != null) await _checkLockout();
    }

    if (!mounted) return;

    if (loginError == null) {
      setState(() => _isLoading = false);
      Navigator.pushAndRemoveUntil(
        context,
        AppTheme.fadeSlideRoute(page: const DashboardScreen()),
        (_) => false,
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loginError, style: GoogleFonts.poppins()),
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
        resizeToAvoidBottomInset: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
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
                final isWide = constraints.maxWidth >= 768;
                return isWide
                    ? _buildWideLayout()
                    : _buildNarrowLayout(constraints);
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Wide (tablet/desktop) layout ──────────────────────────────────────────
  Widget _buildWideLayout() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _buildLoginSidebar(l10n),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
              child: _buildFormCard(false, l10n),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginSidebar(AppLocalizations l10n) {
    return Container(
      width: 340,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDark, AppColors.navyMid],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_rounded,
                  color: AppColors.goldPrimary,
                  size: 64,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.khakhiDiary,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.safeSwiftSecure,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 36),
                _sidebarBullet(Icons.lock_rounded, 'End-to-End Encryption'),
                _sidebarBullet(Icons.sync_rounded, 'Real-time Case Sync'),
                _sidebarBullet(Icons.verified_user_rounded, 'Authorized Police Access'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarBullet(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: AppColors.goldPrimary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Narrow (mobile) layout ────────────────────────────────────────────────
  Widget _buildNarrowLayout(BoxConstraints constraints) {
    final l10n = AppLocalizations.of(context)!;
    final availableHeight = constraints.maxHeight;
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final bool isSmallScreen = availableHeight < 680;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: isKeyboardOpen ? 16 : 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: availableHeight - (isKeyboardOpen ? 32 : 48)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isKeyboardOpen) ...[
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppLogo(size: isSmallScreen ? 60 : 76),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'KHAKHI DIARY',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 18 : 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyDark,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'Police Management System',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: AppColors.lightSubText,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 20 : 32),
            ],
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildFormCard(isSmallScreen || isKeyboardOpen, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(bool isCompact, AppLocalizations l10n) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: EdgeInsets.all(isCompact ? AppSpacing.lg : AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _buildLoginForm(isCompact, l10n),
    );
  }

  Widget _buildLoginForm(bool isCompact, AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Text(
                  _isReturningUser ? l10n.welcomeBack : l10n.unlockApp,
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 20 : 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navyDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isReturningUser ? l10n.enterPinToContinue : l10n.signInWithGovtId,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.lightSubText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: isCompact ? AppSpacing.md : AppSpacing.lg),

          // Lockout Banner
          if (_isLockedOut) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_clock_rounded, color: AppColors.dangerRed, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Temporarily Locked',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dangerRed,
                          ),
                        ),
                        Text(
                          'Too many failed attempts. Try again in $_lockoutCountdown.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.dangerRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          if (_isReturningUser) ...[
            // ── RETURNING USER VIEW ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.badge_rounded,
                      color: AppColors.navyMid, size: 22),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Government ID',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.lightSubText),
                        ),
                        Text(
                          _govtEmailCtrl.text,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(Icons.verified_user_rounded,
                        size: 14, color: AppColors.successGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (!_showPinInput && _isBiometricSupported) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: (_isLoading || _isLockedOut)
                      ? null
                      : () => _handleBiometricLogin(isAuto: false),
                  icon: const Icon(Icons.fingerprint_rounded, size: 22),
                  label: const Text('Login with Biometrics'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navyMid,
                    side: const BorderSide(color: AppColors.navyMid, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    textStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _showPinInput = true),
                  icon: const Icon(Icons.pin_rounded,
                      size: 16, color: AppColors.navyMid),
                  label: Text(
                    'Use PIN instead',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyMid,
                    ),
                  ),
                ),
              ),
              _buildSwitchIdLink(),
            ] else ...[
              TextFormField(
                controller: _pinCtrl,
                obscureText: _obscurePin,
                style: GoogleFonts.poppins(
                    color: AppColors.navyDark, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Password / PIN',
                  hintText: '••••••••',
                  prefixIcon:
                      const Icon(Icons.lock_rounded, color: AppColors.navyMid),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePin
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.lightSubText,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePin = !_obscurePin),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFF),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide:
                        const BorderSide(color: AppColors.lightBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide:
                        const BorderSide(color: AppColors.navyMid, width: 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password or PIN is required';
                  if (v.length < 6) return 'Must be at least 6 characters';
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.forgotPassword),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navyMid,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      (_isLoading || _isLockedOut) ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyMid,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.navyMid.withValues(alpha: 0.5),
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                    : Text(
                        l10n.login,
                        style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              if (_isBiometricSupported) ...[
                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showPinInput = false),
                    icon: const Icon(Icons.fingerprint_rounded,
                        size: 16, color: AppColors.lightSubText),
                    label: Text(
                      'Back to Biometrics',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.lightSubText),
                    ),
                  ),
                ),
              ],
              _buildSwitchIdLink(),
            ],
          ] else ...[
            // ── NEW USER VIEW ────────────────────────────────────────────────
            TextFormField(
              controller: _govtEmailCtrl,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: GoogleFonts.poppins(
                  color: AppColors.navyDark, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Government ID',
                hintText: 'name@department.gov.in',
                prefixIcon: const Icon(Icons.badge_rounded,
                    color: AppColors.navyMid),
                filled: true,
                fillColor: const Color(0xFFF8FAFF),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide:
                      const BorderSide(color: AppColors.navyMid, width: 2),
                ),
              ),
              validator: AppValidators.govtEmail,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _pinCtrl,
              obscureText: _obscurePin,
              style: GoogleFonts.poppins(
                  color: AppColors.navyDark, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Password / PIN',
                hintText: '••••••••',
                prefixIcon:
                    const Icon(Icons.lock_rounded, color: AppColors.navyMid),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePin
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.lightSubText,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFF),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide:
                      const BorderSide(color: AppColors.navyMid, width: 2),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Must be at least 6 characters';
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(
                      context, AppRoutes.forgotPassword),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyMid,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_isLoading || _isLockedOut) ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyMid,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.navyMid.withValues(alpha: 0.5),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        l10n.login,
                        style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Registration navigation
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.dontHaveAccount,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.lightSubText),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.register,
                    (_) => false,
                  ),
                  child: Text(
                    l10n.register,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.navyMid,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchIdLink() {
    return Center(
      child: TextButton(
        onPressed: _isLoading ? null : _switchGovernmentId,
        child: Text(
          'Switch ID / Use a different account',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.navyMid,
          ),
        ),
      ),
    );
  }
}
