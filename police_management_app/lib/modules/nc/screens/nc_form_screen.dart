// lib/modules/nc/screens/nc_form_screen.dart
// NC-specific entry screen — scaffold mirrors CommonFormScreen; body uses NcForm only.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../modules/core/models/base_record.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/module_pdf_helper.dart';
import '../../../utils/pdf_auth_gate.dart';
import '../../../widgets/base_form/base_form.dart';
import '../providers/nc_provider.dart';
import '../widgets/nc_form.dart';

const String kNcFormExtraFieldsKey = 'ncForm';

class NcFormScreen extends StatefulWidget {
  final String moduleLabel;
  final String? subCategory;
  final ModuleRecord? existingRecord;

  const NcFormScreen({
    super.key,
    required this.moduleLabel,
    this.subCategory,
    this.existingRecord,
  });

  @override
  State<NcFormScreen> createState() => _NcFormScreenState();
}

class _NcFormScreenState extends State<NcFormScreen> {
  final GlobalKey<NcFormState> _ncFormKey = GlobalKey<NcFormState>();

  bool get _isEdit => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final provider = context.read<NcProvider>();
      if (auth.stationName.isNotEmpty) {
        provider.setStationId(auth.stationName, createdBy: auth.uid);
      }

      final existing = widget.existingRecord;
      if (existing != null) {
        final nested = existing.extraFields[kNcFormExtraFieldsKey];
        final form = _ncFormKey.currentState;
        if (form != null && nested is Map) {
          form.hydrateFromNcMap(Map<String, dynamic>.from(nested));
        }
      }
    });
  }

  DateTime _parseIncidentDate(String raw) {
    final s = raw.trim();
    final dtMatch =
        RegExp(r'^(\d{2})/(\d{2})/(\d{4})\s+(\d{1,2}):(\d{2})$').firstMatch(s);
    if (dtMatch != null) {
      final dd = int.tryParse(dtMatch.group(1)!);
      final mo = int.tryParse(dtMatch.group(2)!);
      final yy = int.tryParse(dtMatch.group(3)!);
      final hh = int.tryParse(dtMatch.group(4)!);
      final mm = int.tryParse(dtMatch.group(5)!);
      if (dd != null &&
          mo != null &&
          yy != null &&
          hh != null &&
          mm != null &&
          hh <= 23 &&
          mm <= 59) {
        try {
          final dt = DateTime(yy, mo, dd, hh, mm);
          if (dt.year == yy && dt.month == mo && dt.day == dd) return dt;
        } catch (_) {}
      }
    }
    final parts = s.split('/');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0].trim());
      final m = int.tryParse(parts[1].trim());
      final y = int.tryParse(parts[2].trim());
      if (d != null && m != null && y != null) {
        return DateTime(y, m, d);
      }
    }
    try {
      return DateTime.parse(s);
    } catch (_) {
      return DateTime.now();
    }
  }

  String _titleFromDoc(Map<String, dynamic> doc) {
    final nc = doc['ncNumber']?.toString().trim() ?? '';
    if (widget.subCategory != null && widget.subCategory!.trim().isNotEmpty) {
      final sub = widget.subCategory!.trim();
      if (nc.isEmpty) return '$sub — ${widget.moduleLabel}';
      return '$sub — $nc';
    }
    if (nc.isEmpty) return widget.moduleLabel;
    return '${widget.moduleLabel} — $nc';
  }

  String _locationLine(Map<String, dynamic> doc) {
    final spot = doc['crimeSpot'];
    if (spot is! Map) return '';
    final parts = [
      spot['village'],
      spot['area'],
      spot['address'],
    ]
        .map((x) => x?.toString().trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  String _personName(Map<String, dynamic> doc, String key) {
    final m = doc[key];
    if (m is! Map) return '';
    return m['name']?.toString().trim() ?? '';
  }

  Future<void> _exportPdf() async {
    final form = _ncFormKey.currentState;
    if (form == null) return;

    final doc = form.buildDocumentMap();
    final auth = context.read<AuthProvider>();
    final stationName = _isEdit
        ? widget.existingRecord!.stationName
        : auth.stationName.isNotEmpty
            ? auth.stationName
            : context.read<NcProvider>().stationId;

    final stub = ModuleRecord(
      id: _isEdit ? widget.existingRecord!.id : 'preview_nc_pdf',
      moduleKey: 'nc',
      title: _titleFromDoc(doc),
      caseNumber: doc['ncNumber']?.toString().trim() ?? '',
      description: doc['firstInformationContent']?.toString().trim() ?? '',
      complainant: _personName(doc, 'complainant'),
      accused: _personName(doc, 'personComplainedAgainst'),
      location: _locationLine(doc),
      incidentDate: _parseIncidentDate(
          doc['registrationDateTime']?.toString() ?? ''),
      priority: _isEdit ? widget.existingRecord!.priority : 'Medium',
      status: _isEdit ? widget.existingRecord!.status : 'Open',
      assignedOfficer:
          _isEdit ? widget.existingRecord!.assignedOfficer : auth.displayName,
      subCategory:
          _isEdit ? widget.existingRecord!.subCategory : widget.subCategory,
      createdAt: _isEdit ? widget.existingRecord!.createdAt : DateTime.now(),
      extraFields: {
        kNcFormExtraFieldsKey: doc,
        'moduleDisplayName': widget.moduleLabel,
      },
      stationName: stationName,
      createdBy: _isEdit ? widget.existingRecord!.createdBy : auth.uid,
    );

    await runWithPdfAuthGate(
      context,
      () => ModulePdfHelper.generatePdf(stub),
    );
  }

  void _submit() {
    final form = _ncFormKey.currentState;
    if (form == null) return;

    final auth = context.read<AuthProvider>();
    final provider = context.read<NcProvider>();

    final stationName = _isEdit && widget.existingRecord!.stationName.isNotEmpty
        ? widget.existingRecord!.stationName
        : auth.stationName.isNotEmpty
            ? auth.stationName
            : provider.stationId;

    final createdBy = _isEdit && widget.existingRecord!.createdBy.isNotEmpty
        ? widget.existingRecord!.createdBy
        : auth.uid;

    if (!_isEdit && stationName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Station not assigned. Please log out and log in again.',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final doc = form.buildDocumentMap();
    final extra = Map<String, dynamic>.from(
      widget.existingRecord?.extraFields ?? {},
    );
    extra[kNcFormExtraFieldsKey] = doc;
    extra['moduleDisplayName'] = widget.moduleLabel;

    final complainantName = _personName(doc, 'complainant');
    final accusedName = _personName(doc, 'personComplainedAgainst');

    final record = ModuleRecord(
      id: _isEdit
          ? widget.existingRecord!.id
          : '${DateTime.now().millisecondsSinceEpoch}',
      moduleKey: 'nc',
      title: _titleFromDoc(doc),
      caseNumber: doc['ncNumber']?.toString().trim() ?? '',
      description: doc['firstInformationContent']?.toString().trim() ?? '',
      complainant: complainantName,
      accused: accusedName,
      location: _locationLine(doc),
      incidentDate:
          _parseIncidentDate(doc['registrationDateTime']?.toString() ?? ''),
      priority: _isEdit ? widget.existingRecord!.priority : 'Medium',
      status: _isEdit ? widget.existingRecord!.status : 'Open',
      assignedOfficer:
          _isEdit ? widget.existingRecord!.assignedOfficer : auth.displayName,
      subCategory:
          _isEdit ? widget.existingRecord!.subCategory : widget.subCategory,
      createdAt: _isEdit ? widget.existingRecord!.createdAt : DateTime.now(),
      extraFields: extra,
      stationName: stationName,
      createdBy: createdBy,
      assignedOfficerUid: _isEdit
          ? widget.existingRecord!.assignedOfficerUid
          : auth.uid,
    );

    if (_isEdit) {
      provider.updateRecord(record);
    } else {
      provider.addRecord(record);
    }

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
  }

  @override
  Widget build(BuildContext context) {
    return BaseFormLayout(
      title: _isEdit ? 'Edit NC Entry' : 'New NC Entry',
      onSubmit: _submit,
      submitLabel: _isEdit ? 'Update record' : 'Register case',
      backgroundColor: AppColors.lightBg,
      appBarActions: [
        IconButton(
          tooltip: 'Generate PDF',
          onPressed: _exportPdf,
          icon: Icon(Icons.picture_as_pdf_outlined,
              color: AppColors.navyMid, size: 24),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(
            _isEdit ? 'Save' : 'Submit',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: AppColors.navyMid),
          ),
        ),
      ],
      embeddedBody: NcForm(key: _ncFormKey),
    );
  }
}
