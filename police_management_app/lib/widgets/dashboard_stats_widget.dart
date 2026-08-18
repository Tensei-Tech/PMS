// lib/widgets/dashboard_stats_widget.dart
// Client-side dashboard stats — visibility-filtered counts from Firestore streams.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../modules/core/models/base_record.dart';
import '../providers/auth_provider.dart';
import '../screens/my_cases_screen.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/case_visibility.dart';

/// Summary cards: total active, pending cases, disposed — filtered by role/visibility.
class DashboardStatsWidget extends StatefulWidget {
  const DashboardStatsWidget({super.key, required this.auth});

  final AuthProvider auth;

  @override
  State<DashboardStatsWidget> createState() => _DashboardStatsWidgetState();
}

class _DashboardStatsWidgetState extends State<DashboardStatsWidget> {
  final FirestoreService _firestore = FirestoreService();

  StreamSubscription<List<ModuleRecord>>? _casesSub;
  StreamSubscription<List<ModuleRecord>>? _pendingCasesSub;
  StreamSubscription<List<ModuleRecord>>? _disposalSub;

  int _totalActive = 0;
  int _pendingAction = 0;
  int _disposed = 0;
  bool _casesLoaded = false;
  bool _pendingLoaded = false;
  bool _disposalLoaded = false;
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
      _casesSub?.cancel();
      _pendingCasesSub?.cancel();
      _disposalSub?.cancel();
      _casesSub = null;
      _pendingCasesSub = null;
      _disposalSub = null;
      _subscribedKey = null;
      return;
    }

    final station = widget.auth.activeStation.trim();
    final mode = CaseVisibility.resolveFor(widget.auth);
    final key =
        '$station|${mode.name}|${widget.auth.uid}|${widget.auth.designation}|${widget.auth.zone}';
    if (_subscribedKey == key && _casesSub != null) return;
    _subscribedKey = key;
    _subscribeAll(station);
  }

  void _subscribeAll(String station) {
    _casesSub?.cancel();
    _pendingCasesSub?.cancel();
    _disposalSub?.cancel();

    if (station.isEmpty) {
      if (mounted) {
        setState(() {
          _totalActive = 0;
          _pendingAction = 0;
          _disposed = 0;
          _casesLoaded = true;
          _pendingLoaded = true;
          _disposalLoaded = true;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _casesLoaded = false;
        _pendingLoaded = false;
        _disposalLoaded = false;
      });
    }

    final mode = CaseVisibility.resolveFor(widget.auth);
    final uid = widget.auth.uid;

    final pendingIds = <String>{};
    final disposalIds = <String>{};
    final casesIds = <String>{};

    void recomputeTotal() {
      if (!mounted) return;
      final allIds = <String>{...casesIds, ...pendingIds, ...disposalIds};
      setState(() {
        _totalActive = allIds.length;
      });
    }

    _casesSub = _firestore.getStationCasesStream(station).listen(
      (records) {
        final filtered = CaseVisibility.filterRecords(
          records,
          uid: uid,
          mode: mode,
        );
        casesIds.clear();
        for (final r in filtered) {
          casesIds.add(r.id);
        }
        if (!mounted) return;
        setState(() {
          _casesLoaded = true;
        });
        recomputeTotal();
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _casesLoaded = true);
      },
    );

    _pendingCasesSub = _firestore.getPendingCasesStream(station).listen(
      (records) {
        final filtered = CaseVisibility.filterRecords(
          records,
          uid: uid,
          mode: mode,
        );
        pendingIds.clear();
        for (final r in filtered) {
          pendingIds.add(r.id);
        }
        if (!mounted) return;
        setState(() {
          _pendingAction = filtered.length;
          _pendingLoaded = true;
        });
        recomputeTotal();
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _pendingLoaded = true);
      },
    );

    _disposalSub = _firestore.getDisposalCasesStream(station).listen(
      (records) {
        final filtered = CaseVisibility.filterRecords(
          records,
          uid: uid,
          mode: mode,
        );
        disposalIds.clear();
        for (final r in filtered) {
          disposalIds.add(r.id);
        }
        if (!mounted) return;
        setState(() {
          _disposed = filtered.length;
          _disposalLoaded = true;
        });
        recomputeTotal();
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _disposalLoaded = true);
      },
    );
  }

  @override
  void dispose() {
    _casesSub?.cancel();
    _pendingCasesSub?.cancel();
    _disposalSub?.cancel();
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
        loading: !_casesLoaded,
        onTap: _openActiveCases,
      ),
      _StatCardData(
        label: 'Pending Cases',
        value: _pendingAction,
        icon: Icons.schedule_rounded,
        accent: AppColors.warningOrange,
        loading: !_pendingLoaded,
        onTap: _openPendingCases,
      ),
      _StatCardData(
        label: 'Disposal Cases',
        value: _disposed,
        icon: Icons.check_circle_rounded,
        accent: AppColors.successGreen,
        loading: !_disposalLoaded,
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
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: data.accent,
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
