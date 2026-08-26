// lib/widgets/dashboard_stats_widget.dart
// Client-side dashboard stats — visibility-filtered counts from Firestore streams.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../modules/core/models/base_record.dart';
import '../providers/auth_provider.dart';
import '../screens/my_cases_screen.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/case_visibility.dart';
import '../utils/perf_tracker.dart';
import '../utils/read_counter.dart';

/// Summary cards: total active, pending cases, disposed — filtered by role/visibility.
class DashboardStatsWidget extends StatefulWidget {
  const DashboardStatsWidget({super.key, required this.auth});

  final AuthProvider auth;

  @override
  State<DashboardStatsWidget> createState() => _DashboardStatsWidgetState();
}

class _DashboardStatsWidgetState extends State<DashboardStatsWidget> {
  final FirestoreService _firestore = FirestoreService();

  // Single stream subscription instead of 3 — reduces 5 Firestore listeners to 1.
  StreamSubscription<List<ModuleRecord>>? _statsSub;

  int _totalActive = 0;
  int _pendingAction = 0;
  int _disposed = 0;
  bool _loaded = false;
  String? _subscribedKey;

  @override
  void didUpdateWidget(covariant DashboardStatsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureSubscriptions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureSubscriptions();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureSubscriptions());
  }

  void _ensureSubscriptions() {
    if (!widget.auth.isSessionActive) {
      _statsSub?.cancel();
      _statsSub = null;
      _subscribedKey = null;
      return;
    }

    final station = widget.auth.activeStation.trim();
    final mode = CaseVisibility.resolveFor(widget.auth);
    final key =
        '$station|${mode.name}|${widget.auth.uid}|${widget.auth.designation}|${widget.auth.zone}';
    if (_subscribedKey == key && _statsSub != null) return;
    _subscribedKey = key;
    _subscribeAll(station);
  }

  void _subscribeAll(String station) {
    PerfTracker.startOp('DashboardStats.subscribeAll');
    _statsSub?.cancel();
    _statsSub = null;

    if (station.isEmpty) {
      if (mounted) {
        setState(() {
          _totalActive = 0;
          _pendingAction = 0;
          _disposed = 0;
          _loaded = true;
        });
      }
      return;
    }

    if (mounted) setState(() => _loaded = false);

    // Safety timeout: resolve loading state within 2.5s even if stream hangs.
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && !_loaded) setState(() => _loaded = true);
    });

    final mode = CaseVisibility.resolveFor(widget.auth);
    final uid = widget.auth.uid;

    // Single merged stream — getStationCasesStream already merges cases +
    // pending_cases + disposal_cases internally. Derive all 3 stats from it.
    _statsSub = _firestore.getStationCasesStream(station).listen(
      (records) {
        PerfTracker.stopOp('DashboardStats.subscribeAll');
        PerfTracker.log('9a. getStationCasesStream snapshot received (${records.length} docs)');

        final filtered = CaseVisibility.filterRecords(
          records,
          uid: uid,
          mode: mode,
        );

        // Derive counts by status from the single merged stream.
        int pending = 0;
        int disposed = 0;
        for (final r in filtered) {
          final s = r.status.trim().toLowerCase();
          if (s == 'pending') pending++;
          if (s == 'disposal' || s == 'closed' || s == 'resolved') disposed++;
        }

        if (!mounted) return;
        setState(() {
          _totalActive = filtered.length;
          _pendingAction = pending;
          _disposed = disposed;
          _loaded = true;
        });
        PerfTracker.log('9d. DASHBOARD STATS FULLY LOADED');
        ReadCounter.printSummary('DashboardStats loaded — FULL SESSION SUMMARY');
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _loaded = true);
      },
    );
  }

  @override
  void dispose() {
    _statsSub?.cancel();
    super.dispose();
  }


  void _openActiveCases() {
    Navigator.push(
      context,
      AppTheme.fadeSlideRoute(
        page: const MyCasesScreen(initialTab: MyCasesTab.active),
      ),
    );
  }

  void _openPendingCases() {
    Navigator.push(
      context,
      AppTheme.fadeSlideRoute(
        page: const MyCasesScreen(initialTab: MyCasesTab.pending),
      ),
    );
  }

  void _openDisposedCases() {
    Navigator.push(
      context,
      AppTheme.fadeSlideRoute(
        page: const MyCasesScreen(initialTab: MyCasesTab.disposal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.auth.isSessionActive) {
      return const SizedBox.shrink();
    }

    final cards = [
      _StatCardData(
        label: 'Total Cases',
        value: _totalActive,
        icon: Icons.folder_rounded,
        accent: AppColors.infoBlue,
        loading: !_loaded,
        onTap: _openActiveCases,
      ),
      _StatCardData(
        label: 'Pending Cases',
        value: _pendingAction,
        icon: Icons.schedule_rounded,
        accent: AppColors.warningOrange,
        loading: !_loaded,
        onTap: _openPendingCases,
      ),
      _StatCardData(
        label: 'Disposal Cases',
        value: _disposed,
        icon: Icons.check_circle_rounded,
        accent: AppColors.successGreen,
        loading: !_loaded,
        onTap: _openDisposedCases,
      ),
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _SummaryStatCard(data: cards[i])),
          ],
        ],
      ),
    );
  }
}

class _StatCardData {
  const _StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color accent;
  final bool loading;
  final VoidCallback onTap;
}

class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = !kIsWeb || (screenWidth < 600);
    final isSmallMobile = screenWidth < 400;

    final labelFontSize = isSmallMobile ? 8.5 : (isMobile ? 9.0 : 10.0);
    final valueFontSize = isSmallMobile ? 15.0 : (isMobile ? 16.0 : 20.0);
    final verticalPadding = isMobile ? 6.0 : 12.0;

    return Material(
      elevation: 2,
      shadowColor: data.accent.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: verticalPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: data.accent.withValues(alpha: 0.15)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                data.accent.withValues(alpha: 0.06),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMobile) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: data.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(data.icon, color: data.accent, size: 20),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                data.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightSubText,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isMobile ? 2 : 4),
              data.loading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: valueFontSize,
                        width: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    )
                  : Text(
                      '${data.value}',
                      style: GoogleFonts.poppins(
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyDark,
                        height: 1.1,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
