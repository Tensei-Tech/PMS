// lib/screens/register_screen.dart
// Self-registration with posting location, identity photos, and PIN setup.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../data/india_states.dart';
import '../data/maharashtra_police_stations_repository.dart';
import '../data/police_stations_repository.dart';
import '../data/india_districts_repository.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/validators.dart';
import '../widgets/mock_otp_verification_section.dart';
import '../widgets/searchable_picker_field.dart';
import 'register_pin_setup_screen.dart';
import '../widgets/app_logo.dart';
import '../l10n/app_localizations.dart';

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
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _mobileVerified = false;
  bool _emailVerified = false;
  bool _isCheckingDuplicate = false;

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
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
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
        (_designation != null && _designation!.trim().isNotEmpty) &&
        _mobileVerified &&
        _emailVerified;
  }

  Future<void> _next() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_canGoNext()) {
      _showSnack(
        'Complete location, profile fields, and verify mobile and email OTP.',
        AppColors.warningOrange,
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
    setState(() => _isCheckingDuplicate = false);

    final draft = RegistrationDraft(
      fullName: _fullNameCtrl.text.trim(),
      designation: _designation!.trim(),
      mobile: _mobileCtrl.text.replaceAll(RegExp(r'\D'), ''),
      email: _emailCtrl.text.trim(),
      state: _selectedState.trim(),
      unitType: _selectedUnitType!.trim(),
      district: _selectedDistrict!.trim(),
      stationName: _selectedStation!.trim(),
      stationAddress: _buildStationAddress(),
      idCardFile: _idCardFile,
      selfieFile: _selfieFile,
    );

    Navigator.push(
      context,
      AppTheme.fadeSlideRoute(page: RegisterPinSetupScreen(draft: draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Theme(
      data: AppTheme.lightTheme(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4FF),
        body: Container(
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
                final bool isKeyboardOpen = constraints.maxHeight < 550;

                return Column(
                  children: [
                    if (!isKeyboardOpen)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Row(
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
                              icon: const Icon(Icons.arrow_back_rounded,
                                  color: AppColors.navyDark),
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
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.registration,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navyDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!isKeyboardOpen) const SizedBox(height: AppSpacing.md),
                    if (isKeyboardOpen) const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.xxl),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            children: [
                              Text(
                                l10n.step1Details,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navyDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Verify your contact details, then complete posting and profile information.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.lightSubText,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'Contact verification',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.navyDark,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _TextField(
                                controller: _mobileCtrl,
                                label: l10n.mobileNumber,
                                hint: l10n.mobileNumber,
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
                                  onVerifiedChanged: (ok) =>
                                      setState(() => _mobileVerified = ok),
                                  enabled: _mobileCtrl.text.length == 10,
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                              _TextField(
                                controller: _emailCtrl,
                                label: 'Email',
                                hint: 'name@gmail.com or name@department.gov.in',
                                icon: Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: AppValidators.govtEmail,
                              ),
                              if (AppValidators.govtEmail(_emailCtrl.text) ==
                                      null &&
                                  _emailCtrl.text.contains('@')) ...[
                                MockOtpVerificationSection(
                                  title: 'Email OTP Verification',
                                  subtitle:
                                      'For dev mode, OTP is auto-filled as 123456.',
                                  onVerifiedChanged: (ok) =>
                                      setState(() => _emailVerified = ok),
                                  enabled: true,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                              ],
                              Text(
                                'Posting & profile',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.navyDark,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              if (!_locationDataReady)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: AppSpacing.md),
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
                                SearchablePickerField(
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
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'State is required'
                                      : null,
                                ),
                                _RegisterUnitTypeSelector(
                                  value: _selectedUnitType,
                                  locked: _unitTypeLockedByDesignation,
                                  onChanged: _onUnitTypeChanged,
                                ),
                                if (_selectedUnitType != null) ...[
                                  SearchablePickerField(
                                    key: ValueKey(
                                        'district-$_selectedState-$_selectedUnitType'),
                                    label: 'District / Commissionerate',
                                    hintText: 'Search district',
                                    leadingIcon: Icons.location_city_rounded,
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
                                    SearchablePickerField(
                                      key: ValueKey(
                                          'station-$_selectedDistrict-$_selectedUnitType'),
                                      label: 'Police Station',
                                      hintText: 'Search police station',
                                      leadingIcon: Icons.local_police_rounded,
                                      items: _stationsForSelection(),
                                      value: _selectedStation,
                                      onChanged: (v) =>
                                          setState(() => _selectedStation = v),
                                      validator: (v) =>
                                          v == null || v.trim().isEmpty
                                              ? 'Police station is required'
                                              : null,
                                    ),
                                ],
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              _TextField(
                                controller: _fullNameCtrl,
                                label: l10n.fullName,
                                hint: l10n.fullName,
                                icon: Icons.person_rounded,
                                validator: AppValidators.fullName,
                              ),
                              _DesignationDropdown(
                                key: ValueKey(
                                    'designation-$_selectedUnitType'),
                                value: _designation,
                                unitType: _selectedUnitType,
                                onChanged: _onDesignationChanged,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Identity photos (optional)',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.navyDark,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _IdentityPhotoPicker(
                                title: 'Upload Police ID Card (optional)',
                                subtitle: 'Clear photo of your official ID',
                                previewBytes: _idCardPreviewBytes,
                                selected: _idCardFile != null,
                                onPick: () => _pickImage(isIdCard: true),
                                onClear: _idCardFile != null
                                    ? () => _clearImage(isIdCard: true)
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _IdentityPhotoPicker(
                                title: 'Upload User Photo / Selfie (optional)',
                                subtitle:
                                    'Recent photo for identity verification',
                                previewBytes: _selfiePreviewBytes,
                                selected: _selfieFile != null,
                                onPick: () => _pickImage(isIdCard: false),
                                onClear: _selfieFile != null
                                    ? () => _clearImage(isIdCard: false)
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              SizedBox(
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: (_mobileVerified && _emailVerified && !_isCheckingDuplicate)
                                      ? _next
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
                                  child: _isCheckingDuplicate
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          l10n.next,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                );
              },
            ),
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
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
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
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFF8FAFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
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
          hintText: l10n.designation,
          prefixIcon: const Icon(Icons.badge_rounded),
          filled: true,
          fillColor: const Color(0xFFF8FAFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
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
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Police Unit',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.navyDark,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  value: PoliceStationsRepository.commissionerate,
                  // ignore: deprecated_member_use
                  groupValue: value,
                  // ignore: deprecated_member_use
                  onChanged: locked
                      ? null
                      : (v) {
                          if (v != null) onChanged(v);
                        },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    'Commissionerate (CP)',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  value: PoliceStationsRepository.superintendent,
                  // ignore: deprecated_member_use
                  groupValue: value,
                  // ignore: deprecated_member_use
                  onChanged: locked
                      ? null
                      : (v) {
                          if (v != null) onChanged(v);
                        },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    'Superintendent (SP)',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          if (value == null)
            Text(
              'Select Commissionerate (CP) or Superintendent (SP)',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.warningOrange,
              ),
            )
          else if (locked)
            Text(
              'Police unit set automatically from your senior designation.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.lightSubText,
              ),
            ),
        ],
      ),
    );
  }
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              child: Container(
                width: double.infinity,
                height: previewBytes == null ? 120 : 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: selected
                        ? AppColors.successGreen.withValues(alpha: 0.45)
                        : AppColors.lightBorder,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: previewBytes == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded,
                              color: AppColors.navyMid.withValues(alpha: 0.7),
                              size: 28),
                          const SizedBox(height: 8),
                          Text(
                            enabled ? 'Tap to upload' : 'Verify mobile first',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.navyMid,
                              fontWeight: FontWeight.w600,
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
      ],
    );
  }
}
