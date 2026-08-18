// lib/screens/login_screen.dart
// Secure login with Government ID email + 6-digit PIN.
// Domain 2: Brute-force lockout UI with live countdown.

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';

import '../services/lockout_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/validators.dart';
import 'dashboard_screen.dart';
import '../widgets/app_logo.dart';
import '../services/biometric_service.dart';

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
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Domain 2: Brute-force lockout state ──────────────────────────────────
  final LockoutService _lockoutService = LockoutService();
  bool _isLockedOut = false;
  String _lockoutCountdown = '';
  final BiometricService _biometricService = BiometricService();
  bool _isBiometricSupported = false;
  bool _biometricAutoTriggered =
      false; // Flag to prevent multiple auto-triggers
  bool _showPinInput = false;

  /// When true, a late [_loadStoredEmail] completion must not restore returning-user UI.
  bool _idSwitchRequested = false;

  // Manual PIN input state
  final List<TextEditingController> _pinFields =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes = List.generate(6, (_) => FocusNode());
  // Stable focus nodes for the per-cell KeyboardListener wrappers — created
  // once instead of on every build (avoids rebuild-time leaks/jank).
  final List<FocusNode> _pinKbListenerNodes =
      List.generate(6, (_) => FocusNode(skipTraversal: true));
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();
    _slideCtrl.forward();
    WidgetsBinding.instance.addObserver(this);

    // Unified initialization to avoid race conditions
    _initAsync();
  }

  Future<void> _initAsync() async {
    // Run independent async checks in parallel for faster first-paint.
    try {
      await Future.wait([
        _checkLockout()
            .catchError((e, s) => debugPrint('Error checking lockout: $e\n$s')),
        _loadStoredEmail().catchError(
            (e, s) => debugPrint('Error loading stored email: $e\n$s')),
        _checkBiometricSupport().catchError(
            (e, s) => debugPrint('Error checking biometric support: $e\n$s')),
      ]);
    } catch (e, s) {
      debugPrint('Error in _initAsync: $e\n$s');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-biometric trigger removed on resume.
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
        const SnackBar(
            content: Text('Biometric login is disabled in settings.')),
      );
      return;
    }

    if (isAuto && _biometricAutoTriggered) return;

    try {
      if (isAuto) {
        _biometricAutoTriggered = true;
      }

      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Please authenticate to login',
      );

      if (!mounted) return;

      if (authenticated) {
        // Biometric success - perform silent login with stored credentials
        final auth = context.read<AuthProvider>();
        setState(() => _isLoading = true);

        final email = _govtEmailCtrl.text.trim();
        final loginError = await auth.loginWithBiometrics(email);

        if (!mounted) return;

        if (loginError == null) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (_) => false,
          );
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loginError)),
          );
        }
      } else {
        // If authentication failed or was cancelled by user
        if (!isAuto && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication failed.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Polls lockout status and starts a 1-second ticker to update countdown.
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

  /// Load stored Government Email and mark as returning user
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

  /// Clears the saved Government ID so a different account can be entered.
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

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _govtEmailCtrl.dispose();
    _pinCtrl.dispose();
    _lockoutTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    for (var ctrl in _pinFields) {
      ctrl.dispose();
    }
    for (var node in _pinFocusNodes) {
      node.dispose();
    }
    for (var node in _pinKbListenerNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Domain 2: Block login attempts during lockout
    if (_isLockedOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account locked. Try again in $_lockoutCountdown.',
              style: GoogleFonts.poppins()),
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
    const isTablet = true;
    const isCompact = false;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Row(
        children: [
          // Sidebar (Tablet/Web only)
          if (isTablet) _buildLoginSidebar(l10n),

          // Main Login Content
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: _buildLoginForm(isCompact, l10n),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginSidebar(AppLocalizations l10n) {
    return Container(
      width: 320,
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
              radius: 100,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_rounded,
                    color: AppColors.goldPrimary, size: 64),
                const SizedBox(height: AppSpacing.xl),
                Text(l10n.khakhiDiary,
                    style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2)),
                const SizedBox(height: 12),
                Text(l10n.safeSwiftSecure,
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 40),
                _sidebarBullet(Icons.lock_rounded, 'End-to-End Encryption'),
                _sidebarBullet(Icons.history_rounded, 'Real-time Sync'),
                _sidebarBullet(Icons.devices_rounded, 'Cross-platform Support'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarBullet(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.goldPrimary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
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
    final bool isSmallScreen = availableHeight < 700;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: isKeyboardOpen ? 20 : 0,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: availableHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isKeyboardOpen) const SizedBox(height: 40),
            if (!isKeyboardOpen)
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppLogo(size: isSmallScreen ? 60 : 90),
                      const SizedBox(height: AppSpacing.md),
                      Text('KHAKHI DIARY',
                          style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 18 : 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navyDark,
                              letterSpacing: 2)),
                      Text('Management System',
                          style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 9 : 11,
                              color: AppColors.navyMid.withValues(alpha: 0.7),
                              letterSpacing: 1.2)),
                    ],
                  ),
                ),
              ),
            SizedBox(
                height: isKeyboardOpen
                    ? 20
                    : isSmallScreen
                        ? 30
                        : 50),
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildFormCard(isSmallScreen || isKeyboardOpen, l10n),
              ),
            ),
            if (!isKeyboardOpen) const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(bool isCompact, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(isCompact ? AppSpacing.md : AppSpacing.lg + 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius:
            BorderRadius.circular(isCompact ? AppRadius.xl : AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: _buildLoginForm(isCompact, l10n),
    );
  }

  Widget _buildLoginForm(bool isCompact, AppLocalizations l10n) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo & Title
            Center(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _isReturningUser ? l10n.welcomeBack : l10n.unlockApp,
                    style: GoogleFonts.poppins(
                      fontSize: isCompact ? 20 : 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isReturningUser
                        ? l10n.enterPinToContinue
                        : l10n.signInWithGovtId,
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

            // ── Domain 2: Lockout Warning Banner ──────────────────────────────
            if (_isLockedOut) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                      color: AppColors.dangerRed.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock_rounded,
                        color: AppColors.dangerRed, size: 20),
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

            // Field 1: Government ID (email) - Read-only for returning users
            if (_isReturningUser) ...[
              // Returning user: show locked email with account indicator
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.badge_rounded,
                      color: AppColors.navyMid,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Government ID',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.lightSubText,
                            ),
                          ),
                          Text(
                            _govtEmailCtrl.text,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        size: 14,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // New user: editable email field
              TextFormField(
                controller: _govtEmailCtrl,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: GoogleFonts.poppins(
                    color: AppColors.lightText, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Government ID',
                  hintText: 'name@department.gov.in',
                  prefixIcon: const Icon(Icons.badge_rounded),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFF),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(color: AppColors.lightBorder)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide:
                          BorderSide(color: AppColors.navyMid, width: 2)),
                ),
                validator: AppValidators.govtEmail,
              ),
            ],
            const SizedBox(height: AppSpacing.md),

            // ── LOGIN OPTIONS (Biometric or PIN) ─────────────────────────────
            if (_isReturningUser) ...[
              if (!_showPinInput && _isBiometricSupported) ...[
                // Option A: Biometric Login Button
                SizedBox(
                  width: double.infinity,
                  height: isCompact ? 48 : 54,
                  child: OutlinedButton.icon(
                    onPressed: (_isLoading || _isLockedOut)
                        ? null
                        : () => _handleBiometricLogin(isAuto: false),
                    icon: const Icon(Icons.fingerprint_rounded, size: 22),
                    label: const Text('Login with Biometrics'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navyMid,
                      side: BorderSide(
                          color: AppColors.navyMid.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                      textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _showPinInput = true),
                    child: Text(
                      'ENTER PIN',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors
                            .navyMid, // Made it more visible as it's clickable
                        letterSpacing: 1.5,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _buildSwitchIdLink(),
              ] else ...[
                TextFormField(
                  controller: _pinCtrl,
                  obscureText: true,
                  style: GoogleFonts.poppins(
                      color: AppColors.navyDark, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Password / PIN',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFF),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: AppColors.lightBorder)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(
                            color: AppColors.navyMid, width: 2)),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Trigger login if length is 6, or just let them type and press Login
                    if (value.length >= 6) {
                      // We can't automatically log in for mixed passwords as easily,
                      // so they will just press the Login button.
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                // Login button
                SizedBox(
                  width: double.infinity,
                  height: isCompact ? 48 : 54,
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
                    child: Text(l10n.login),
                  ),
                ),
                if (_isLoading) ...[
                  const SizedBox(height: AppSpacing.md),
                  const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.navyMid)),
                ],
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _showPinInput = false),
                    child: Text(
                      'Back to Biometrics',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.lightSubText,
                      ),
                    ),
                  ),
                ),
                _buildSwitchIdLink(),
              ],
            ] else ...[
              // New user flow: Standard Govt ID and PIN input
              TextFormField(
                controller: _pinCtrl,
                obscureText: true,
                style: GoogleFonts.poppins(
                    color: AppColors.lightText, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Password / PIN',
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_rounded),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFF),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(color: AppColors.lightBorder)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide:
                          const BorderSide(color: AppColors.navyMid, width: 2)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              // Login button
              SizedBox(
                width: double.infinity,
                height: isCompact ? 48 : 54,
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
                  child: Text(l10n.login),
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(height: AppSpacing.md),
                const Center(
                    child: CircularProgressIndicator(color: AppColors.navyMid)),
              ],
            ],

            const SizedBox(height: AppSpacing.lg),

            // Registration link
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.dontHaveAccount,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.lightSubText,
                    ),
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
      ),
    );
  }
}
