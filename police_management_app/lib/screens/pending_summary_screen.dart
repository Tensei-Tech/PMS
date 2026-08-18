// lib/screens/pending_summary_screen.dart
// Pending cases summary — time-period groups match 1-to-5 pending PDF layout.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../modules/core/models/base_record.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/dynamic_map_pdf.dart';
import '../utils/pdf_auth_gate.dart';
import '../utils/pdf_unicode_fonts.dart';
import '../utils/pending_table_firestore_mapper.dart';
import '../utils/case_visibility.dart';
import '../widgets/pending_cases_demo_data_table.dart';

class PendingSummaryScreen extends StatelessWidget {
  const PendingSummaryScreen({
    super.key,
    this.liveRows,
    this.stationName = '',
  });

  /// When non-null and non-empty, summary uses only this data (skips Firestore stream).
  final List<Map<String, String>>? liveRows;

  /// Station scope for pending Firestore read (ignored when [liveRows] is used).
  final String stationName;

  /// PDF / UI section order and footer labels (exact casing).
  static const List<String> _sectionOrder = [
    'More than a Year',
    'More than 6 months',
    'More than 3 months',
    'Under 3 months',
  ];

  static bool _usingExplicitLive(List<Map<String, String>>? live) =>
      live != null && live.isNotEmpty;

  static String _bucketForRow(Map<String, String> row) {
    final p = row['period'] ?? '';
    switch (p) {
      case 'More than 1 year':
        return 'More than a Year';
      case '6 to 12 months':
        return 'More than 6 months';
      case '3 to 6 months':
      case 'More than 3 months':
        return 'More than 3 months';
      case 'Within 3 months':
      case '1 month':
        return 'Under 3 months';
      default:
        return 'Under 3 months';
    }
  }

  List<Map<String, String>> _rowsForBucket(
    List<Map<String, String>> data,
    String bucketLabel,
  ) {
    return data.where((r) => _bucketForRow(r) == bucketLabel).toList();
  }

  Future<void> _exportPdf(
    BuildContext context,
    List<Map<String, String>> dataset,
  ) async {
    final flat = <Map<String, String>>[];
    for (final section in _sectionOrder) {
      flat.addAll(_rowsForBucket(dataset, section));
    }
    if (flat.isEmpty) return;
    await runWithPdfAuthGate(context, () async {
      final theme = await PdfUnicodeFonts.openSansTheme();
      final doc = DynamicMapPdf.buildLandscapeDataTableDocument(
        theme: theme,
        title: 'Pending Cases — Summary (all periods)',
        rows: flat.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      await Printing.layoutPdf(
        onLayout: (_) async => doc.save(),
        name: 'Pending_Summary_All_Periods.pdf',
      );
    });
  }

  Widget _builtContent(
    BuildContext context, {
    required List<Map<String, String>> dataset,
    required bool firedFromFirestoreExclusive,
    required bool showDemoNote,
  }) {
    const title = 'Pending Cases — Summary';
    final anyRows = dataset.isNotEmpty;

    Widget sectionBlock(String bucketLabel) {
      final rows = _rowsForBucket(dataset, bucketLabel);
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                bucketLabel,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDark,
                ),
              ),
            ),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'No cases',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightSubText,
                  ),
                ),
              )
            else
              PendingCasesDemoDataTable(
                isAd: false,
                realDataRows: firedFromFirestoreExclusive ? rows : null,
                fallbackRows: firedFromFirestoreExclusive ? null : rows,
                includeDemoDisclaimerBelowTable: false,
                exclusiveLiveFirestoreData: firedFromFirestoreExclusive,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          color: AppColors.navyMid, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: !anyRows
                        ? null
                        : () => _exportPdf(context, dataset),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.navyMid,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.download_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Export',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                children: [
                  for (final label in _sectionOrder) sectionBlock(label),
                  if (showDemoNote)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        '* Demo Data — Will be replaced with live data',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.lightSubText,
                          height: 1.15,
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

  @override
  Widget build(BuildContext context) {
    if (_usingExplicitLive(liveRows)) {
      return _builtContent(
        context,
        dataset: liveRows!,
        firedFromFirestoreExclusive: true,
        showDemoNote: false,
      );
    }

    return _LivePendingSummaryLoader(
      fallbackStation: stationName,
      buildContent: _builtContent,
    );
  }
}

/// Subscribes to pending Firestore data for [AuthProvider.stationName], re-binding
/// when the active station changes without requiring navigation pop/push.
class _LivePendingSummaryLoader extends StatefulWidget {
  const _LivePendingSummaryLoader({
    required this.fallbackStation,
    required this.buildContent,
  });

  final String fallbackStation;
  final Widget Function(
    BuildContext context, {
    required List<Map<String, String>> dataset,
    required bool firedFromFirestoreExclusive,
    required bool showDemoNote,
  }) buildContent;

  @override
  State<_LivePendingSummaryLoader> createState() =>
      _LivePendingSummaryLoaderState();
}

class _LivePendingSummaryLoaderState extends State<_LivePendingSummaryLoader> {
  final _firestore = FirestoreService();
  StreamSubscription<List<ModuleRecord>>? _sub;
  String _boundStation = '';
  List<ModuleRecord> _modules = const [];
  bool _initialLoad = true;
  Object? _error;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _effectiveStation() {
    final active = Provider.of<AuthProvider>(context).stationName;
    return active.isNotEmpty ? active : widget.fallbackStation;
  }

  void _bindStation(String station) {
    if (station == _boundStation && _sub != null) return;
    _boundStation = station;
    _sub?.cancel();
    _error = null;

    if (station.isEmpty) {
      setState(() {
        _modules = const [];
        _initialLoad = false;
      });
      return;
    }

    // Keep showing prior rows while the new station stream connects.
    if (_modules.isEmpty) {
      setState(() => _initialLoad = true);
    }

    _sub = _firestore.getPendingCasesStream(station).listen(
      (data) {
        if (!mounted) return;
        final auth = Provider.of<AuthProvider>(context, listen: false);
        setState(() {
          _modules = CaseVisibility.filterForAuth(data, auth);
          _initialLoad = false;
          _error = null;
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _error = e;
          _initialLoad = false;
        });
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bindStation(_effectiveStation());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final modules = CaseVisibility.filterForAuth(_modules, auth);

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.lightBg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load pending cases',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightSubText,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_initialLoad && modules.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.lightBg,
        body: const SafeArea(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.navyMid),
          ),
        ),
      );
    }

    final exclusive = modules.isNotEmpty;
    final now = DateTime.now();
    final dataset =
        exclusive ? pendingTableRowsAll(modules, now) : kPendingDemoTableRows;
    final showDemoNote = !exclusive && dataset.isNotEmpty;

    return widget.buildContent(
      context,
      dataset: dataset,
      firedFromFirestoreExclusive: exclusive,
      showDemoNote: showDemoNote,
    );
  }
}
