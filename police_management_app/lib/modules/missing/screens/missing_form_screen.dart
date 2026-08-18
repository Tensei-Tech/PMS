// lib/modules/missing/screens/missing_form_screen.dart
// Missing-specific entry screen — scaffold mirrors NcFormScreen; body uses MissingForm only.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../modules/core/models/base_record.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/module_pdf_helper.dart';
import '../../../utils/pdf_auth_gate.dart';
import '../../../widgets/base_form/base_form.dart';
import '../providers/missing_provider.dart';
import '../widgets/missing_form.dart';

const String kMissingFormExtraFieldsKey = 'missingForm';

class MissingFormScreen extends StatefulWidget {
  final String moduleLabel;
  final String? subCategory;
  final ModuleRecord? existingRecord;

  const MissingFormScreen({
    super.key,
    required this.moduleLabel,
    this.subCategory,
    this.existingRecord,
  });

  @override
  State<MissingFormScreen> createState() => _MissingFormScreenState();
}

class _MissingFormScreenState extends State<MissingFormScreen> {
  final GlobalKey<MissingFormState> _missingFormKey =
      GlobalKey<MissingFormState>();

  bool get _isEdit => widget.existingRecord != null;

  static bool _autoCloseFromDoc(Map<String, dynamic> doc) {
    final found = doc['found'];
    if (found is! Map) return false;
    final reported = found['reported'];
    final yes = reported == true ||
        (reported is String && reported.toLowerCase() == 'true');
    if (!yes) return false;
    final d = found['date']?.toString().trim() ?? '';
    final sd = found['sdNumber']?.toString().trim() ?? '';
    return d.isNotEmpty && sd.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final provider = context.read<MissingProvider>();
      if (auth.stationName.isNotEmpty) {
        provider.setStationId(auth.stationName, createdBy: auth.uid);
      }

      final existing = widget.existingRecord;
      if (existing != null) {
        final nested = existing.extraFields[kMissingFormExtraFieldsKey];
        final form = _missingFormKey.currentState;
        if (form != null && nested is Map) {
          form.hydrateFromMap(Map<String, dynamic>.from(nested));
          form.markLoadedFromRecord();
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
    final mn = doc['missingNumber']?.toString().trim() ?? '';
    if (widget.subCategory != null && widget.subCategory!.trim().isNotEmpty) {
      final sub = widget.subCategory!.trim();
      if (mn.isEmpty) return '$sub — ${widget.moduleLabel}';
      return '$sub — $mn';
    }
    if (mn.isEmpty) return widget.moduleLabel;
    return '${widget.moduleLabel} — $mn';
  }

  String _locationLine(Map<String, dynamic> doc) {
    final mp = doc['missingPerson'];
    if (mp is Map) {
      final addr = mp['address']?.toString().trim() ?? '';
      if (addr.isNotEmpty) return addr;
    }
    final found = doc['found'];
    if (found is Map) {
      final parts = [
        found['village'],
        found['areaName'],
        found['fullAddress'],
      ]
          .map((x) => x?.toString().trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) return parts.join(', ');
    }
    return '';
  }

  String _personName(Map<String, dynamic> doc, String key) {
    final m = doc[key];
    if (m is! Map) return '';
    return m['name']?.toString().trim() ?? '';
  }

  String _suspectedSummary(Map<String, dynamic> doc) {
    final list = doc['suspectedPersons'];
    if (list is! List || list.isEmpty) return '';
    final names = <String>[];
    for (final item in list) {
      if (item is Map && item['name'] != null) {
        final n = item['name'].toString().trim();
        if (n.isNotEmpty) names.add(n);
      }
    }
    return names.join(', ');
  }

  Future<void> _exportPdf() async {
    final form = _missingFormKey.currentState;
    if (form == null) return;

    final doc = form.buildDocumentMap();
    final auth = context.read<AuthProvider>();
    final stationName = _isEdit
        ? widget.existingRecord!.stationName
        : auth.stationName.isNotEmpty
            ? auth.stationName
            : context.read<MissingProvider>().stationId;

    final stub = ModuleRecord(
      id: _isEdit ? widget.existingRecord!.id : 'preview_missing_pdf',
      moduleKey: 'missing',
      title: _titleFromDoc(doc),
      caseNumber: doc['missingNumber']?.toString().trim() ?? '',
      description: doc['reason']?.toString().trim() ?? '',
      complainant: _personName(doc, 'complainant'),
      accused: _suspectedSummary(doc),
      location: _locationLine(doc),
      incidentDate: _isEdit
          ? widget.existingRecord!.incidentDate
          : _parseIncidentDate(doc['cdrSentDate']?.toString() ?? ''),
      priority: _isEdit ? widget.existingRecord!.priority : 'Medium',
      status: _isEdit ? widget.existingRecord!.status : 'Open',
      assignedOfficer:
          _isEdit ? widget.existingRecord!.assignedOfficer : auth.displayName,
      subCategory:
          _isEdit ? widget.existingRecord!.subCategory : widget.subCategory,
      createdAt: _isEdit ? widget.existingRecord!.createdAt : DateTime.now(),
      extraFields: {
        kMissingFormExtraFieldsKey: doc,
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
    final form = _missingFormKey.currentState;
    if (form == null) return;

    final auth = context.read<AuthProvider>();
    final provider = context.read<MissingProvider>();

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

    if (!(form.validate())) return;

    final doc = form.buildDocumentMap();
    final extra = Map<String, dynamic>.from(
      widget.existingRecord?.extraFields ?? {},
    );
    extra[kMissingFormExtraFieldsKey] = doc;
    extra['moduleDisplayName'] = widget.moduleLabel;

    final complainantName = _personName(doc, 'complainant');

    String status;
    if (_autoCloseFromDoc(doc)) {
      status = 'Closed';
    } else if (_isEdit) {
      status = widget.existingRecord!.status;
    } else {
      status = 'Open';
    }

    final record = ModuleRecord(
      id: _isEdit
          ? widget.existingRecord!.id
          : '${DateTime.now().millisecondsSinceEpoch}',
      moduleKey: 'missing',
      title: _titleFromDoc(doc),
      caseNumber: doc['missingNumber']?.toString().trim() ?? '',
      description: doc['reason']?.toString().trim() ?? '',
      complainant: complainantName,
      accused: _suspectedSummary(doc),
      location: _locationLine(doc),
      incidentDate: _isEdit
          ? widget.existingRecord!.incidentDate
          : _parseIncidentDate(doc['cdrSentDate']?.toString() ?? ''),
      priority: _isEdit ? widget.existingRecord!.priority : 'Medium',
      status: status,
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
      title: _isEdit ? 'Edit Missing Entry' : 'New Missing Entry',
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
      embeddedBody: MissingForm(key: _missingFormKey),
    );
  }
}
