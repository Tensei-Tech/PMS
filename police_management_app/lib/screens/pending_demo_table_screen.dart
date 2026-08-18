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

class PendingDemoTableScreen extends StatelessWidget {
  final String stationName;
  final String category;
  final String timeRange;

  /// When non-null, rendered instead of subscribing to pending Firestore stream.
  final List<Map<String, String>>? realDataRows;

  const PendingDemoTableScreen({
    super.key,
    required this.stationName,
    required this.category,
    required this.timeRange,
    this.realDataRows,
  });

  Future<void> _exportPdf(BuildContext context, List<Map<String, String>> rows) async {
    await runWithPdfAuthGate(context, () async {
      final theme = await PdfUnicodeFonts.openSansTheme();
      final doc = DynamicMapPdf.buildLandscapeDataTableDocument(
        theme: theme,
        title: '$category — $timeRange Pending Cases',
        rows: rows.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      await Printing.layoutPdf(
        onLayout: (_) async => doc.save(),
        name: 'Pending_${category}_${timeRange.replaceAll(' ', '_')}.pdf',
      );
    });
  }

  Widget _bodyFromRows({
    required BuildContext context,
    required List<Map<String, String>> filtered,
    required bool liveExclusive,
  }) {
    final isAd = category == 'AD';

    Widget tableOrEmpty() {
      if (filtered.isEmpty) {
        return Center(
          child: Text(
            'No records found for this time period',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.lightSubText,
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: PendingCasesDemoDataTable(
          isAd: isAd,
          realDataRows: liveExclusive ? filtered : null,
          fallbackRows: liveExclusive ? null : filtered,
          exclusiveLiveFirestoreData: liveExclusive,
        ),
      );
    }

    final title = '$category — $timeRange Pending Cases';

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
                    onTap:
                        filtered.isEmpty ? null : () => _exportPdf(context, filtered),
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
            Expanded(child: tableOrEmpty()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final demoFiltered =
        kPendingDemoTableRows.where((r) => r['period'] == timeRange).toList();

    final override = realDataRows;
    if (override != null) {
      return _bodyFromRows(
        context: context,
        filtered: override,
        liveExclusive: true,
      );
    }

    return _LivePendingTableLoader(
      fallbackStation: stationName,
      category: category,
      timeRange: timeRange,
      demoFiltered: demoFiltered,
      bodyFromRows: _bodyFromRows,
    );
  }
}

/// Subscribes to pending Firestore data for [AuthProvider.stationName], re-binding
/// when the active station changes without requiring navigation pop/push.
class _LivePendingTableLoader extends StatefulWidget {
  const _LivePendingTableLoader({
    required this.fallbackStation,
    required this.category,
    required this.timeRange,
    required this.demoFiltered,
    required this.bodyFromRows,
  });

  final String fallbackStation;
  final String category;
  final String timeRange;
  final List<Map<String, String>> demoFiltered;
  final Widget Function({
    required BuildContext context,
    required List<Map<String, String>> filtered,
    required bool liveExclusive,
  }) bodyFromRows;

  @override
  State<_LivePendingTableLoader> createState() =>
      _LivePendingTableLoaderState();
}

class _LivePendingTableLoaderState extends State<_LivePendingTableLoader> {
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

    final now = DateTime.now();
    final liveExclusive = modules.isNotEmpty;
    final List<Map<String, String>> filtered;
    if (liveExclusive) {
      final categoryRows =
          pendingTableRowsForCategory(modules, widget.category, now);
      filtered = categoryRows
          .where((r) => (r['period'] ?? '') == widget.timeRange)
          .toList();
    } else {
      filtered = widget.demoFiltered;
    }

    return widget.bodyFromRows(
      context: context,
      filtered: filtered,
      liveExclusive: liveExclusive,
    );
  }
}
