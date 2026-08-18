// lib/screens/module_form_screen.dart
// Generic form for ALL modules — creates/edits a ModuleRecord.
// On save, calls the correct isolated module provider.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../modules/core/models/base_record.dart';
import '../modules/core/providers/base_module_provider.dart';
import '../modules/form_iv/providers/form_iv_provider.dart';
import '../modules/form_vi/providers/form_vi_provider.dart';
import '../modules/nc/providers/nc_provider.dart';
import '../modules/preventive/providers/preventive_provider.dart';
import '../modules/ad/providers/ad_provider.dart';
import '../modules/missing/providers/missing_provider.dart';
import '../modules/kidnapping/providers/kidnapping_provider.dart';
import '../modules/theft/providers/theft_provider.dart';
import '../modules/sand_theft/providers/sand_theft_provider.dart';
import '../modules/hurt/providers/hurt_provider.dart';
import '../modules/pocso/providers/pocso_provider.dart';
import '../modules/passport/providers/passport_provider.dart';
import '../modules/monthly/providers/monthly_provider.dart';
import '../modules/pending/providers/pending_provider.dart';
import '../modules/detected/providers/detected_provider.dart';
import '../modules/undetected/providers/undetected_provider.dart';
import '../modules/disposal/providers/disposal_provider.dart';
import '../modules/two_four_wheeler/providers/two_four_wheeler_provider.dart';
import '../modules/arrested/providers/arrested_provider.dart';
import '../modules/absconded/providers/absconded_provider.dart';
import '../modules/crime_women/providers/crime_women_provider.dart';
import '../modules/juvenile/providers/juvenile_provider.dart';
import '../modules/victim/providers/victim_provider.dart';
import '../modules/accident/providers/accident_provider.dart';
import '../modules/traffic/providers/traffic_provider.dart';
import '../modules/application/providers/application_provider.dart';
import '../modules/sam_warrant/providers/sam_warrant_provider.dart';
import '../modules/muddemal/providers/muddemal_provider.dart';
import '../modules/bnss/providers/bnss_provider.dart';
import '../modules/ndps/providers/ndps_provider.dart';
import '../modules/gowans/providers/gowans_provider.dart';
import '../modules/it_act/providers/it_act_provider.dart';
import '../modules/mcoca/providers/mcoca_provider.dart';
import '../modules/uapa/providers/uapa_provider.dart';
import '../modules/mpda/providers/mpda_provider.dart';
import '../modules/coin/providers/coin_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/base_form/base_form.dart';

class ModuleFormScreen extends StatefulWidget {
  final String moduleLabel;
  final String moduleKey;
  final String? subCategory;
  final ModuleRecord? existingRecord;

  const ModuleFormScreen({
    super.key,
    required this.moduleLabel,
    required this.moduleKey,
    this.subCategory,
    this.existingRecord,
  });

  @override
  State<ModuleFormScreen> createState() => _ModuleFormScreenState();
}

class _ModuleFormScreenState extends State<ModuleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caseNoCtrl      = TextEditingController();
  final _titleCtrl       = TextEditingController();
  final _descCtrl        = TextEditingController();
  final _complainantCtrl = TextEditingController();
  final _accusedCtrl     = TextEditingController();
  final _locationCtrl    = TextEditingController();

  DateTime _date     = DateTime.now();
  String _priority   = 'Medium';
  String _status     = 'Open';
  bool get _isEdit   => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final r = widget.existingRecord!;
      _caseNoCtrl.text      = r.caseNumber;
      _titleCtrl.text       = r.title;
      _descCtrl.text        = r.description;
      _complainantCtrl.text = r.complainant;
      _accusedCtrl.text     = r.accused;
      _locationCtrl.text    = r.location;
      _date     = r.incidentDate;
      _priority = r.priority;
      if (widget.moduleKey == 'detected' || widget.moduleKey == 'undetected') {
        _status = (r.status == 'Disposal' || r.status == 'Closed' || r.status == 'Resolved')
            ? 'Disposal'
            : 'Pending';
      } else {
        _status = r.status;
      }
    } else {
      if (widget.moduleKey == 'detected' || widget.moduleKey == 'undetected') {
        _status = 'Pending';
      } else {
        _status = 'Open';
      }
    }

    // ✅ Ensure the provider always has stationId + createdBy injected
    // This runs after the first frame so context.read is safe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final provider = _getProvider(context);

      debugPrint('>>> [ModuleFormScreen] initState stationName="${auth.stationName}" uid="${auth.uid}"');

      // Only inject if stationName is available
      if (auth.stationName.isNotEmpty) {
        provider.setStationId(auth.stationName, createdBy: auth.uid);
      }
    });
  }

  @override
  void dispose() {
    _caseNoCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _complainantCtrl.dispose();
    _accusedCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  BaseModuleProvider _getProvider(BuildContext context) {
    switch (widget.moduleKey) {
      case 'form_1_5':         return context.read<FormIVProvider>();
      case 'form_6':           return context.read<FormVIProvider>();
      case 'nc':               return context.read<NcProvider>();
      case 'preventive':       return context.read<PreventiveProvider>();
      case 'ad':               return context.read<AdProvider>();
      case 'missing':          return context.read<MissingProvider>();
      case 'kidnapping':       return context.read<KidnappingProvider>();
      case 'theft':            return context.read<TheftProvider>();
      case 'sand_theft':       return context.read<SandTheftProvider>();
      case 'hurt':             return context.read<HurtProvider>();
      case 'pocso':            return context.read<PocsoProvider>();
      case 'passport':         return context.read<PassportProvider>();
      case 'monthly':          return context.read<MonthlyProvider>();
      case 'pending':          return context.read<PendingProvider>();
      case 'detected':         return context.read<DetectedProvider>();
      case 'undetected':       return context.read<UndetectedProvider>();
      case 'disposal':         return context.read<DisposalProvider>();
      case 'two_four_wheeler': return context.read<TwoFourWheelerProvider>();
      case 'arrested':         return context.read<ArrestedProvider>();
      case 'absconded':        return context.read<AbscondedProvider>();
      case 'crime_women':      return context.read<CrimeWomenProvider>();
      case 'juvenile':         return context.read<JuvenileProvider>();
      case 'victim':           return context.read<VictimProvider>();
      case 'accident':         return context.read<AccidentProvider>();
      case 'traffic':          return context.read<TrafficProvider>();
      case 'application':      return context.read<ApplicationProvider>();
      case 'sam_warrant':      return context.read<SamWarrantProvider>();
      case 'muddemal':         return context.read<MuddemalProvider>();
      case 'bnss':             return context.read<BnssProvider>();
      case 'ndps':             return context.read<NdpsProvider>();
      case 'gowans':           return context.read<GowansProvider>();
      case 'it_act':           return context.read<ItActProvider>();
      case 'mcoca':            return context.read<McocaProvider>();
      case 'uapa':             return context.read<UapaProvider>();
      case 'mpda':             return context.read<MpdaProvider>();
      case 'coin':             return context.read<CoinProvider>();
      default:                 return context.read<NcProvider>();
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth     = context.read<AuthProvider>();
    final provider = _getProvider(context);

    // ✅ Resolve stationName — prefer auth, never allow empty
    final stationName = _isEdit && widget.existingRecord!.stationName.isNotEmpty
        ? widget.existingRecord!.stationName
        : auth.stationName.isNotEmpty
            ? auth.stationName
            : provider.stationId; // fallback to what provider already knows

    final createdBy = _isEdit && widget.existingRecord!.createdBy.isNotEmpty
        ? widget.existingRecord!.createdBy
        : auth.uid;

    // ✅ Guard: block save if stationName is still empty
    if (!_isEdit && stationName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Station not assigned. Please log out and log in again.',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red,
      ));
      debugPrint('>>> [_onSubmit] BLOCKED — stationName is empty. auth.stationName="${auth.stationName}" provider.stationId="${provider.stationId}"');
      return;
    }

    debugPrint('>>> [_onSubmit] stationName="$stationName" createdBy="$createdBy"');

    final record = ModuleRecord(
      id: _isEdit
          ? widget.existingRecord!.id
          : '${DateTime.now().millisecondsSinceEpoch}',
      moduleKey:       widget.moduleKey,
      title:           _titleCtrl.text.trim(),
      caseNumber:      _caseNoCtrl.text.trim(),
      description:     _descCtrl.text.trim(),
      complainant:     _complainantCtrl.text.trim(),
      accused:         _accusedCtrl.text.trim(),
      location:        _locationCtrl.text.trim(),
      incidentDate:    _date,
      priority:        _priority,
      status:          _status,
      assignedOfficer: _isEdit
          ? widget.existingRecord!.assignedOfficer
          : auth.displayName,
      subCategory:     _isEdit
          ? widget.existingRecord!.subCategory
          : widget.subCategory,
      createdAt:       _isEdit
          ? widget.existingRecord!.createdAt
          : DateTime.now(),
      // ✅ Always populated — never empty
      stationName:     stationName,
      createdBy:       createdBy,
      assignedOfficerUid: _isEdit
          ? widget.existingRecord!.assignedOfficerUid
          : auth.uid,
    );

    try {
      if (_isEdit) {
        await provider.updateRecord(record);
      } else {
        await provider.addRecord(record);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          _isEdit
              ? '${widget.moduleLabel} record updated!'
              : '${widget.moduleLabel} case registered!',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppColors.successGreen,
      ));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Failed to save record: $e',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppColors.dangerRed,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusItems = (widget.moduleKey == 'detected' || widget.moduleKey == 'undetected')
        ? ['Pending', 'Disposal']
        : ['Open', 'Active', 'Resolved', 'Closed'];

    return BaseFormLayout(
      title: _isEdit
          ? 'Edit ${widget.moduleLabel}'
          : 'New ${widget.moduleLabel} Entry',
      onSubmit: _onSubmit,
      submitLabel: _isEdit ? 'Update Record' : 'Register Case',
      backgroundColor: AppColors.lightBg,
      darkAppBar: (widget.moduleKey == 'detected' || widget.moduleKey == 'undetected'),
      appBarActions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.goldPrimary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text('MODULE',
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldPrimary)),
          ),
        ),
      ],
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('General Information', Icons.info_outline_rounded),
              _card([
                StandardFormFieldRow(children: [
                  StandardTextField(
                    label: 'Case / FIR Number',
                    controller: _caseNoCtrl,
                    hint: 'e.g. FIR/2024/0101',
                    prefixIcon: Icons.numbers_rounded,
                  ),
                  StandardTextField(
                    label: 'Subject / Case Title',
                    controller: _titleCtrl,
                    hint: 'Brief case title',
                    prefixIcon: Icons.title_rounded,
                  ),
                ]),
                const SizedBox(height: AppSpacing.md),
                StandardDatePickerValue(
                  label: 'Incident Date',
                  value: _date,
                  onChanged: (d) => setState(() => _date = d),
                  lastDate: DateTime.now(),
                ),
              ]),
              const SizedBox(height: AppSpacing.lg),
              _sectionTitle('Incident Details', Icons.location_on_outlined),
              _card([
                StandardFormFieldRow(children: [
                  StandardTextField(
                    label: 'Location',
                    controller: _locationCtrl,
                    hint: 'Place of occurrence',
                    prefixIcon: Icons.map_rounded,
                  ),
                  StandardTextField(
                    label: 'Complainant Name',
                    controller: _complainantCtrl,
                    prefixIcon: Icons.person_add_alt_rounded,
                  ),
                ]),
                const SizedBox(height: AppSpacing.md),
                StandardTextField(
                  label: 'Description',
                  controller: _descCtrl,
                  hint: 'Detailed explanation...',
                  maxLines: 4,
                  prefixIcon: Icons.description_outlined,
                ),
                const SizedBox(height: AppSpacing.md),
                StandardTextField(
                  label: 'Accused Name / Description',
                  controller: _accusedCtrl,
                  hint: 'Leave empty if unknown',
                  prefixIcon: Icons.person_off_rounded,
                ),
              ]),
              const SizedBox(height: AppSpacing.lg),
              _sectionTitle('Priority & Status', Icons.priority_high_rounded),
              _card([
                _dropdown('Priority', _priority, ['Low', 'Medium', 'High'],
                    (v) => setState(() => _priority = v!)),
                const SizedBox(height: AppSpacing.md),
                _dropdown(
                    'Status',
                    _status,
                    statusItems,
                    (v) => setState(() => _status = v!)),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, IconData icon) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.goldPrimary),
          const SizedBox(width: 8),
          Text(title.toUpperCase(),
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.lightSubText)),
        ]),
      );

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Column(children: children),
      );

  Widget _dropdown(String label, String value, List<String> items,
      void Function(String?) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.navyDark)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: Colors.white,
            items: items
                .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(p,
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: AppColors.lightText)),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ]);
  }
}