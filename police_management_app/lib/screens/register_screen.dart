// lib/screens/register_screen.dart
// Self-registration with posting location, identity photos, and PIN setup.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/india_districts_repository.dart';
import '../data/india_states.dart';
import '../data/maharashtra_police_stations_repository.dart';
import '../data/police_stations_repository.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/validators.dart';
import '../widgets/app_logo.dart';
import '../widgets/mock_otp_verification_section.dart';
import '../widgets/searchable_picker_field.dart';
import 'register_pin_setup_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  String? _designation;
  String _selectedState = 'Maharashtra';
  String? _selectedUnitType;
  String? _selectedDistrict;
  String? _selectedStation;
  bool _locationDataReady = false;
  Map<String, List<String>> _districtsByState = {};

  XFile? _idCardFile;
  XFile? _selfieFile;
  Uint8List? _idCardPreviewBytes;
  Uint8List? _selfiePreviewBytes;

  final _fullNameCtrl = TextEditingController();
  final _govtIdCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();

  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  bool _mobileVerified = false;
  bool _emailVerified = false;
  bool _isCheckingDuplicate = false;
  bool _isRegistering = false;
  bool _submitted = false;

  final _mobileKey = GlobalKey();
  final _emailKey = GlobalKey();
  final _fullNameKey = GlobalKey();
  final _designationKey = GlobalKey();
  final _govtIdKey = GlobalKey();
  final _stateKey = GlobalKey();
  final _unitTypeKey = GlobalKey();
  final _districtKey = GlobalKey();
  final _stationKey = GlobalKey();
  final _pinKey = GlobalKey();
  final _confirmPinKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _bootstrapLocationData();
    _mobileCtrl.addListener(() {
      if (mounted) {
        setState(() {
          if (_mobileVerified && _mobileCtrl.text.length != 10) {
            _mobileVerified = false;
          }
        });
      }
    });
    _emailCtrl.addListener(() {
      if (mounted) {
        setState(() {
          if (_emailVerified) _emailVerified = false;
        });
      }
    });
  }

  Future<void> _bootstrapLocationData() async {
    try {
      final map = await IndiaDistrictsRepository.load();
      await MaharashtraPoliceStationsRepository.initialize();
      if (!mounted) return;
      setState(() {
        _districtsByState = map;
        _locationDataReady = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _locationDataReady = true);
    }
  }

  List<String> _districtsForSelection() {
    if (_selectedUnitType == null || _selectedState.trim().isEmpty) {
      return const [];
    }
    if (_selectedState == 'Maharashtra') {
      final districts = <String>{};
      for (final station
          in MaharashtraPoliceStationsRepository.getAllStations()) {
        if (station.type == _selectedUnitType) {
          districts.add(station.districtName);
        }
      }
      return districts.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
    return List<String>.from(_districtsByState[_selectedState] ?? const []);
  }

  List<String> _stationsForSelection() {
    if (_selectedDistrict == null ||
        _selectedUnitType == null ||
        _selectedState.trim().isEmpty) {
      return const [];
    }
    if (_selectedState == 'Maharashtra') {
      return MaharashtraPoliceStationsRepository.getStationNamesForSelection(
        district: _selectedDistrict!,
        unitType: _selectedUnitType!,
      );
    }
    return PoliceStationsRepository.forSelection(
      unitType: _selectedUnitType!,
      state: _selectedState,
      district: _selectedDistrict!,
    );
  }

  String _buildStationAddress() {
    return '${_selectedDistrict!.trim()}, ${_selectedState.trim()} • ${_selectedUnitType!.trim()}';
  }

  bool get _unitTypeLockedByDesignation =>
      SeniorOfficerRoles.impliedUnitType(_designation) != null;

  void _clearLocationSelection() {
    _selectedDistrict = null;
    _selectedStation = null;
  }

  void _onUnitTypeChanged(String unitType) {
    setState(() {
      if (_unitTypeLockedByDesignation) return;
      if (_selectedUnitType != unitType) {
        _selectedUnitType = unitType;
        _clearLocationSelection();
      }
      if (_designation != null) {
        final allowed = PoliceDesignations.forRegistration(unitType)
            .map((e) => e.abbreviation)
            .toSet();
        if (!allowed.contains(_designation)) {
          _designation = null;
        }
      }
    });
  }

  void _onDesignationChanged(String? designation) {
    setState(() {
      _designation = designation;
      final implied = SeniorOfficerRoles.impliedUnitType(designation);
      if (implied != null && implied != _selectedUnitType) {
        _selectedUnitType = implied;
        _clearLocationSelection();
      }
    });
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _govtIdCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _pinCtrl.dispose();
    _confirmPinCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _pickImage({required bool isIdCard}) async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        if (isIdCard) {
          _idCardFile = file;
          _idCardPreviewBytes = bytes;
        } else {
          _selfieFile = file;
          _selfiePreviewBytes = bytes;
        }
      });
    } catch (e) {
      _showSnack('Could not pick image: $e', AppColors.dangerRed);
    }
  }

  void _clearImage({required bool isIdCard}) {
    setState(() {
      if (isIdCard) {
        _idCardFile = null;
        _idCardPreviewBytes = null;
      } else {
        _selfieFile = null;
        _selfiePreviewBytes = null;
      }
    });
  }

  bool _canGoNext() {
    return _selectedState.trim().isNotEmpty &&
        (_selectedUnitType != null && _selectedUnitType!.trim().isNotEmpty) &&
        (_selectedDistrict != null && _selectedDistrict!.trim().isNotEmpty) &&
        (_selectedStation != null && _selectedStation!.trim().isNotEmpty) &&
        _fullNameCtrl.text.trim().isNotEmpty &&
        _govtIdCtrl.text.trim().isNotEmpty &&
        (_designation != null && _designation!.trim().isNotEmpty) &&
        _mobileVerified &&
        _emailVerified &&
        _pinCtrl.text.trim().length >= 6 &&
        _confirmPinCtrl.text.trim() == _pinCtrl.text.trim();
  }

  Future<void> _submitRegistration() async {
    setState(() => _submitted = true);

    final formValid = _formKey.currentState?.validate() ?? false;
    final canProceed = _canGoNext();

    if (!formValid || !canProceed) {
      GlobalKey? targetKey;
      final mobileClean = _mobileCtrl.text.replaceAll(RegExp(r'\D'), '');

      if (mobileClean.length != 10 || !_mobileVerified) {
        targetKey = _mobileKey;
      } else if (AppValidators.govtEmail(_emailCtrl.text.trim()) != null || !_emailVerified) {
        targetKey = _emailKey;
      } else if (_fullNameCtrl.text.trim().isEmpty) {
        targetKey = _fullNameKey;
      } else if (_designation == null || _designation!.trim().isEmpty) {
        targetKey = _designationKey;
      } else if (_govtIdCtrl.text.trim().isEmpty) {
        targetKey = _govtIdKey;
      } else if (_selectedState.trim().isEmpty) {
        targetKey = _stateKey;
      } else if (_selectedUnitType == null || _selectedUnitType!.trim().isEmpty) {
        targetKey = _unitTypeKey;
      } else if (_selectedDistrict == null || _selectedDistrict!.trim().isEmpty) {
        targetKey = _districtKey;
      } else if (_selectedStation == null || _selectedStation!.trim().isEmpty) {
        targetKey = _stationKey;
      } else if (_pinCtrl.text.trim().length < 6) {
        targetKey = _pinKey;
      } else if (_confirmPinCtrl.text.trim() != _pinCtrl.text.trim() || _confirmPinCtrl.text.trim().isEmpty) {
        targetKey = _confirmPinKey;
      }

      if (targetKey != null && targetKey.currentContext != null) {
        Scrollable.ensureVisible(
          targetKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
          alignment: 0.15,
        );
      }

      _showSnack(
        'Please complete all required fields marked in red.',
        AppColors.dangerRed,
      );
      return;
    }

    setState(() => _isCheckingDuplicate = true);

    try {
      final auth = context.read<AuthProvider>();
      final email = _emailCtrl.text.trim();
      final mobile = _mobileCtrl.text.replaceAll(RegExp(r'\D'), '');

      final exists = await auth.checkContactExists(email: email, phone: mobile);

      if (!mounted) return;

      if (exists) {
        setState(() => _isCheckingDuplicate = false);
        _showSnack(
          'An account with this Email or Phone Number already exists.',
          AppColors.dangerRed,
        );
        return;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCheckingDuplicate = false);
      _showSnack(
        'Could not verify account details: $e',
        AppColors.dangerRed,
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isCheckingDuplicate = false;
      _isRegistering = true;
    });

    try {
      final auth = context.read<AuthProvider>();
      final result = await auth.registerWithPin(
        fullName: _fullNameCtrl.text.trim(),
        designation: _designation!.trim(),
        email: _emailCtrl.text.trim(),
        phone: _mobileCtrl.text.replaceAll(RegExp(r'\D'), ''),
        pin: _pinCtrl.text.trim(),
        govtId: _govtIdCtrl.text.trim(),
        idCardFile: _idCardFile,
        selfieFile: _selfieFile,
        stationName: _selectedStation!.trim(),
        stationAddress: _buildStationAddress(),
        stationLandline: '',
        district: _selectedDistrict!.trim(),
      );

      if (!mounted) return;

      if (!result.success) {
        setState(() => _isRegistering = false);
        _showSnack(
          result.errorMessage ?? 'Registration failed. Please try again.',
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

      try {
        await auth.signOutToLogin();
      } catch (_) {}

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.registerPendingApproval,
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRegistering = false);
      _showSnack(
        'Registration failed unexpectedly: $e',
        AppColors.dangerRed,
      );
    }
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.navyMid.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: AppColors.navyMid, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDark,
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.lightSubText,
              height: 1.3,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Theme(
      data: AppTheme.lightTheme(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= 768;
              final double contentMaxWidth = isWide ? 680.0 : double.infinity;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 0 : 20,
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _submitted
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Bar
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.login,
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: AppColors.navyDark,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      AppColors.navyMid.withValues(alpha: 0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              const AppLogo(size: 40),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.registration,
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.navyDark,
                                      ),
                                    ),
                                    Text(
                                      'Officer account registration portal',
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
                          const SizedBox(height: AppSpacing.lg),

                          // ── CARD 1: CONTACT VERIFICATION ─────────────────
                          _buildSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                  icon: Icons.verified_user_rounded,
                                  title: 'Contact verification',
                                  subtitle:
                                      'Verify your mobile number and government email.',
                                ),
                                KeyedSubtree(
                                  key: _mobileKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _TextField(
                                        controller: _mobileCtrl,
                                        label: l10n.mobileNumber,
                                        hint: '10-digit mobile number',
                                        icon: Icons.phone_android_rounded,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                        validator: AppValidators.phone,
                                      ),
                                      if (_mobileCtrl.text.length == 10) ...[
                                        MockOtpVerificationSection(
                                          title: 'Mobile OTP Verification',
                                          subtitle:
                                              'For dev mode, OTP is auto-filled as 123456.',
                                          onVerifiedChanged: (ok) => setState(
                                              () => _mobileVerified = ok),
                                          enabled:
                                              _mobileCtrl.text.length == 10,
                                        ),
                                        const SizedBox(height: AppSpacing.md),
                                      ],
                                      if (_submitted && !_mobileVerified)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                  Icons.error_outline_rounded,
                                                  size: 14,
                                                  color: AppColors.dangerRed),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Mobile OTP verification required',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.dangerRed,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                KeyedSubtree(
                                  key: _emailKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _TextField(
                                        controller: _emailCtrl,
                                        label: 'Email',
                                        hint: 'officer@police.gov.in',
                                        icon: Icons.email_rounded,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: AppValidators.govtEmail,
                                      ),
                                      if (AppValidators.govtEmail(
                                                  _emailCtrl.text) ==
                                              null &&
                                          _emailCtrl.text.contains('@')) ...[
                                        MockOtpVerificationSection(
                                          title: 'Email OTP Verification',
                                          subtitle:
                                              'For dev mode, OTP is auto-filled as 123456.',
                                          onVerifiedChanged: (ok) => setState(
                                              () => _emailVerified = ok),
                                          enabled: true,
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                      ],
                                      if (_submitted && !_emailVerified)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                  Icons.error_outline_rounded,
                                                  size: 14,
                                                  color: AppColors.dangerRed),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Email OTP verification required',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.dangerRed,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // ── CARD 2: POSTING & PROFILE ────────────────────
                          _buildSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                  icon: Icons.badge_rounded,
                                  title: 'Posting & profile',
                                  subtitle:
                                      'Enter full name, designation, and official posting details.',
                                ),
                                // 1. Officer Identity & Rank
                                KeyedSubtree(
                                  key: _fullNameKey,
                                  child: _TextField(
                                    controller: _fullNameCtrl,
                                    label: l10n.fullName,
                                    hint: 'Officer full name',
                                    icon: Icons.person_rounded,
                                    validator: AppValidators.fullName,
                                  ),
                                ),
                                KeyedSubtree(
                                  key: _designationKey,
                                  child: _DesignationDropdown(
                                    key: ValueKey(
                                        'designation-$_selectedUnitType'),
                                    value: _designation,
                                    unitType: _selectedUnitType,
                                    onChanged: _onDesignationChanged,
                                  ),
                                ),
                                KeyedSubtree(
                                  key: _govtIdKey,
                                  child: _TextField(
                                    controller: _govtIdCtrl,
                                    label: 'Government ID',
                                    hint: 'MH-POL-10482',
                                    icon: Icons.badge_rounded,
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                            ? 'Government ID is required'
                                            : null,
                                  ),
                                ),

                                // 2. Official Jurisdiction & Posting
                                if (!_locationDataReady)
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(bottom: AppSpacing.md),
                                    child: Center(
                                      child: SizedBox(
                                        height: 28,
                                        width: 28,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.navyMid,
                                        ),
                                      ),
                                    ),
                                  )
                                else ...[
                                  KeyedSubtree(
                                    key: _stateKey,
                                    child: SearchablePickerField(
                                      label: 'State',
                                      hintText: 'Select state',
                                      leadingIcon: Icons.map_rounded,
                                      items: IndiaStates.all,
                                      value: _selectedState,
                                      onChanged: (v) => setState(() {
                                        _selectedState = v;
                                        _selectedDistrict = null;
                                        _selectedStation = null;
                                      }),
                                      validator: (v) =>
                                          v == null || v.trim().isEmpty
                                              ? 'State is required'
                                              : null,
                                    ),
                                  ),
                                  KeyedSubtree(
                                    key: _unitTypeKey,
                                    child: _RegisterUnitTypeSelector(
                                      value: _selectedUnitType,
                                      locked: _unitTypeLockedByDesignation,
                                      hasError: _submitted &&
                                          (_selectedUnitType == null ||
                                              _selectedUnitType!.isEmpty),
                                      onChanged: _onUnitTypeChanged,
                                    ),
                                  ),
                                  if (_selectedUnitType != null) ...[
                                    KeyedSubtree(
                                      key: _districtKey,
                                      child: SearchablePickerField(
                                        key: ValueKey(
                                            'district-$_selectedState-$_selectedUnitType'),
                                        label: 'District / Commissionerate',
                                        hintText: 'Search district',
                                        leadingIcon:
                                            Icons.location_city_rounded,
                                        items: _districtsForSelection(),
                                        value: _selectedDistrict,
                                        onChanged: (v) => setState(() {
                                          _selectedDistrict = v;
                                          _selectedStation = null;
                                        }),
                                        validator: (v) =>
                                            v == null || v.trim().isEmpty
                                                ? 'District is required'
                                                : null,
                                      ),
                                    ),
                                  ],
                                  if (_selectedUnitType != null &&
                                      _selectedDistrict != null) ...[
                                    if (_stationsForSelection().isEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 14),
                                        child: Text(
                                          'No stations found for this district and unit type.',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.warningOrange,
                                          ),
                                        ),
                                      )
                                    else
                                      KeyedSubtree(
                                        key: _stationKey,
                                        child: SearchablePickerField(
                                          key: ValueKey(
                                              'station-$_selectedDistrict-$_selectedUnitType'),
                                          label: 'Police Station',
                                          hintText: 'Search police station',
                                          leadingIcon:
                                              Icons.local_police_rounded,
                                          items: _stationsForSelection(),
                                          value: _selectedStation,
                                          onChanged: (v) => setState(
                                              () => _selectedStation = v),
                                          validator: (v) =>
                                              v == null || v.trim().isEmpty
                                                  ? 'Police station is required'
                                                  : null,
                                        ),
                                      ),
                                  ],
                                  const SizedBox(height: AppSpacing.xs),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // ── CARD 3: ACCOUNT SECURITY ─────────────────────
                          _buildSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                  icon: Icons.security_rounded,
                                  title: 'Account Security',
                                  subtitle:
                                      'Create a password or PIN (minimum 6 characters) to secure your login.',
                                ),
                                KeyedSubtree(
                                  key: _pinKey,
                                  child: _PasswordField(
                                    controller: _pinCtrl,
                                    label: 'Create Password / PIN',
                                    hint: 'Minimum 6 characters',
                                    icon: Icons.lock_rounded,
                                    obscureText: _obscurePin,
                                    onToggleObscure: () => setState(
                                        () => _obscurePin = !_obscurePin),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Password / PIN is required';
                                      }
                                      if (v.trim().length < 6) {
                                        return 'Must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                KeyedSubtree(
                                  key: _confirmPinKey,
                                  child: _PasswordField(
                                    controller: _confirmPinCtrl,
                                    label: 'Confirm Password / PIN',
                                    hint: 'Re-enter password / PIN',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscureConfirmPin,
                                    onToggleObscure: () => setState(() =>
                                        _obscureConfirmPin =
                                            !_obscureConfirmPin),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Please confirm Password / PIN';
                                      }
                                      if (v.trim() != _pinCtrl.text.trim()) {
                                        return 'Passwords / PINs do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // ── CARD 4: IDENTITY PHOTOS ──────────────────────
                          _buildSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                  icon: Icons.photo_camera_rounded,
                                  title: 'Identity photos (optional)',
                                  subtitle:
                                      'Attach official ID and verification photos for faster supervisor approval.',
                                ),
                                _IdentityPhotoPicker(
                                  title: 'Police ID Card',
                                  subtitle:
                                      'Clear photo or scan of your official department ID card',
                                  previewBytes: _idCardPreviewBytes,
                                  selected: _idCardFile != null,
                                  onPick: () => _pickImage(isIdCard: true),
                                  onClear: _idCardFile != null
                                      ? () => _clearImage(isIdCard: true)
                                      : null,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _IdentityPhotoPicker(
                                  title: 'User Photo / Selfie',
                                  subtitle:
                                      'Recent portrait photo for profile verification',
                                  previewBytes: _selfiePreviewBytes,
                                  selected: _selfieFile != null,
                                  onPick: () => _pickImage(isIdCard: false),
                                  onClear: _selfieFile != null
                                      ? () => _clearImage(isIdCard: false)
                                      : null,
                                ),
                              ],
                            ),
                          ),

                          // Extra spacing above button
                          const SizedBox(height: AppSpacing.xl),

                          // Primary Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: (!_isCheckingDuplicate &&
                                      !_isRegistering)
                                  ? _submitRegistration
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navyMid,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    AppColors.navyMid.withValues(alpha: 0.4),
                                disabledForegroundColor:
                                    Colors.white.withValues(alpha: 0.85),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                                elevation: 0,
                              ),
                              child: (_isCheckingDuplicate || _isRegistering)
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Register',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Login Link
                          Center(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  l10n.alreadyHaveAccount,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.lightSubText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    } else {
                                      Navigator.of(context)
                                          .pushReplacementNamed(
                                        AppRoutes.login,
                                      );
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 36),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    l10n.login,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.navyMid,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
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

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    required this.obscureText,
    required this.onToggleObscure,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool obscureText;
  final VoidCallback onToggleObscure;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: GoogleFonts.poppins(
          color: AppColors.navyDark,
          fontSize: 14,
        ),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: AppColors.lightSubText.withValues(alpha: 0.55),
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, color: AppColors.navyMid),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.lightSubText,
              size: 20,
            ),
            onPressed: onToggleObscure,
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.navyMid, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.dangerRed, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.dangerRed, width: 2),
          ),
          errorStyle: GoogleFonts.poppins(
            color: AppColors.dangerRed,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: GoogleFonts.poppins(
          color: AppColors.navyDark,
          fontSize: 14,
        ),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: AppColors.lightSubText.withValues(alpha: 0.55),
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, color: AppColors.navyMid),
          filled: true,
          fillColor: const Color(0xFFF8FAFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.navyMid, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.dangerRed, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.dangerRed, width: 2),
          ),
          errorStyle: GoogleFonts.poppins(
            color: AppColors.dangerRed,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DesignationDropdown extends StatelessWidget {
  const _DesignationDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.unitType,
  });

  final String? value;
  final String? unitType;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = unitType != null && unitType!.trim().isNotEmpty
        ? PoliceDesignations.forRegistration(unitType)
        : PoliceDesignations.simplifiedRegistration();
    final safeValue =
        (value != null && items.any((d) => d.abbreviation == value))
            ? value
            : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: safeValue,
        isExpanded: true,
        menuMaxHeight: 360,
        items: items
            .map(
              (d) => DropdownMenuItem<String>(
                value: d.abbreviation,
                child: Text(
                  d.display,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            )
            .toList(growable: false),
        onChanged: onChanged,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Designation is required' : null,
        decoration: InputDecoration(
          labelText: l10n.designation,
          prefixIcon: const Icon(Icons.badge_rounded, color: AppColors.navyMid),
          filled: true,
          fillColor: const Color(0xFFF8FAFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.navyMid, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.dangerRed, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.dangerRed, width: 2),
          ),
          errorStyle: GoogleFonts.poppins(
            color: AppColors.dangerRed,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _RegisterUnitTypeSelector extends StatelessWidget {
  const _RegisterUnitTypeSelector({
    required this.value,
    required this.onChanged,
    this.locked = false,
    this.hasError = false,
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final bool locked;
  final bool hasError;

  Widget _buildUnitCard({
    required BuildContext context,
    required String unitValue,
    required String title,
    required IconData icon,
  }) {
    final bool isSelected = value == unitValue;
    final bool showError = hasError && value == null;

    return Expanded(
      child: InkWell(
        onTap: locked ? null : () => onChanged(unitValue),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.navyMid.withValues(alpha: 0.06)
                : showError
                    ? AppColors.dangerRed.withValues(alpha: 0.03)
                    : const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected
                  ? AppColors.navyMid
                  : showError
                      ? AppColors.dangerRed
                      : AppColors.lightBorder,
              width: isSelected ? 1.8 : (showError ? 1.5 : 1.0),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.navyMid.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.navyMid
                          : showError
                              ? AppColors.dangerRed.withValues(alpha: 0.1)
                              : AppColors.navyMid.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : showError
                              ? AppColors.dangerRed
                              : AppColors.navyMid,
                    ),
                  ),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.navyMid
                            : showError
                                ? AppColors.dangerRed
                                : AppColors.lightBorder,
                        width: isSelected ? 4.5 : 1.5,
                      ),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? AppColors.navyDark
                        : showError
                            ? AppColors.dangerRed
                            : AppColors.navyDark.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showError = hasError && value == null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Police Unit',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: showError ? AppColors.dangerRed : AppColors.navyDark,
                ),
              ),
              if (locked) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.navyMid.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_rounded,
                          size: 11, color: AppColors.navyMid),
                      const SizedBox(width: 3),
                      Text(
                        'Auto-set',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navyMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildUnitCard(
                context: context,
                unitValue: PoliceStationsRepository.commissionerate,
                title: 'Commissionerate (CP)',
                icon: Icons.location_city_rounded,
              ),
              const SizedBox(width: 12),
              _buildUnitCard(
                context: context,
                unitValue: PoliceStationsRepository.superintendent,
                title: 'Superintendent (SP)',
                icon: Icons.account_balance_rounded,
              ),
            ],
          ),
          if (showError) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 14, color: AppColors.dangerRed),
                const SizedBox(width: 4),
                Text(
                  'Police unit is required',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.dangerRed,
                  ),
                ),
              ],
            ),
          ] else if (value == null) ...[
            const SizedBox(height: 6),
            Text(
              'Select Commissionerate (CP) or Superintendent (SP)',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.warningOrange,
              ),
            ),
          ] else if (locked) ...[
            const SizedBox(height: 6),
            Text(
              'Police unit set automatically from your senior designation.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.lightSubText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 4.0,
    this.dash = 6.0,
    this.radius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = math.min(dash, metric.length - distance);
        final Path extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _IdentityPhotoPicker extends StatelessWidget {
  const _IdentityPhotoPicker({
    required this.title,
    required this.subtitle,
    required this.previewBytes,
    required this.selected,
    required this.onPick,
    this.onClear,
  });

  final String title;
  final String subtitle;
  final Uint8List? previewBytes;
  final bool selected;
  final VoidCallback? onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final enabled = onPick != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyDark,
                ),
              ),
            ),
            if (selected && onClear != null)
              IconButton(
                onPressed: onClear,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Remove photo',
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.dangerRed.withValues(alpha: 0.85),
                ),
              )
            else if (selected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: AppColors.successGreen.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 14, color: AppColors.successGreen),
                    const SizedBox(width: 4),
                    Text(
                      'Selected',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.lightSubText,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPick : null,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Opacity(
              opacity: enabled ? 1 : 0.55,
              child: CustomPaint(
                painter: previewBytes == null
                    ? _DashedBorderPainter(
                        color: selected
                            ? AppColors.successGreen
                            : AppColors.navyMid.withValues(alpha: 0.35),
                        strokeWidth: 1.5,
                        dash: 6,
                        gap: 4,
                        radius: AppRadius.md,
                      )
                    : null,
                child: Container(
                  width: double.infinity,
                  height: previewBytes == null ? 108 : 180,
                  decoration: BoxDecoration(
                    color: AppColors.navyMid.withValues(alpha: 0.035),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: previewBytes != null
                        ? Border.all(
                            color: selected
                                ? AppColors.successGreen.withValues(alpha: 0.45)
                                : AppColors.lightBorder,
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: previewBytes == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.navyMid.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_upload_rounded,
                                color: AppColors.navyMid,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              enabled
                                  ? 'Tap to upload image'
                                  : 'Verify mobile first',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.navyMid,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Supports JPG, PNG (Clear photo/scan)',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.lightSubText,
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: Image.memory(
                                previewBytes!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            if (onClear != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: onClear,
                                    customBorder: const CircleBorder(),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade800
                                            .withValues(alpha: 0.88),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
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
      ],
    );
  }
}
