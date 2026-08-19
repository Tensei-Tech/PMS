import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardAnalyticsSection extends StatefulWidget {
  final bool isDesktop;
  final ValueChanged<int>? onNavigate;

  const DashboardAnalyticsSection({
    super.key,
    required this.isDesktop,
    this.onNavigate,
  });

  @override
  State<DashboardAnalyticsSection> createState() => _DashboardAnalyticsSectionState();
}

class _DashboardAnalyticsSectionState extends State<DashboardAnalyticsSection> {
  int _selectedTrendDays = 365; // Default 1 Year (7, 30, 180, 365)

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics & Trends',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Case filing patterns, yearly trends and crime type breakdown',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.insights_rounded, size: 15, color: Color(0xFF2563EB)),
                  SizedBox(width: 5),
                  Text(
                    'Real-time Intelligence',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Stream of Cases from Firestore for live analytics
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('cases').snapshots(),
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;
            final docs = snapshot.data?.docs ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Full-Width Cases Trend Graph (100% width with 1-Year & Crime-Type Analysis)
                _CasesTrendGraphCard(
                  docs: docs,
                  isLoading: isLoading,
                  days: _selectedTrendDays,
                  isDesktop: widget.isDesktop,
                  onDaysChanged: (days) => setState(() => _selectedTrendDays = days),
                  onNavigateToCases: () => widget.onNavigate?.call(4),
                ),

                const SizedBox(height: 24),

                // 2. Crime Circle Section (Dedicated row below trend chart)
                _CrimeTypeDonutCard(
                  docs: docs,
                  isLoading: isLoading,
                  isDesktop: widget.isDesktop,
                  onNavigateToCases: () => widget.onNavigate?.call(4),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// Fixed, consistent color palette per crime category
const Map<String, Color> kCrimeCategoryColors = {
  'Homicide / Violent': Color(0xFFEF4444),
  'Theft & Robbery': Color(0xFFF59E0B),
  'Cyber & Financial': Color(0xFF3B82F6),
  'Women & Child Safety': Color(0xFFEC4899),
  'Narcotics (NDPS)': Color(0xFF8B5CF6),
  'Traffic & Accidents': Color(0xFF10B981),
  'Other Cognizable': Color(0xFF64748B),
};

String resolveCaseType(Map<String, dynamic> data) {
  final val = (data['caseType'] ??
          data['classificationType'] ??
          data['category'] ??
          data['crimeType'] ??
          data['type'] ??
          data['classification'] ??
          data['formType'])
      ?.toString()
      .trim();

  if (val != null && val.isNotEmpty && val.toLowerCase() != 'null') {
    final l = val.toLowerCase();
    if (l.contains('murder') || l.contains('assault') || l.contains('homicide') || l.contains('302')) return 'Homicide / Violent';
    if (l.contains('theft') || l.contains('robbery') || l.contains('burglary') || l.contains('379')) return 'Theft & Robbery';
    if (l.contains('cyber') || l.contains('fraud') || l.contains('financial') || l.contains('420')) return 'Cyber & Financial';
    if (l.contains('women') || l.contains('rape') || l.contains('pocso') || l.contains('376')) return 'Women & Child Safety';
    if (l.contains('drug') || l.contains('narcotics') || l.contains('ndps')) return 'Narcotics (NDPS)';
    if (l.contains('traffic') || l.contains('accident') || l.contains('mva')) return 'Traffic & Accidents';
    return val;
  }

  final sections = (data['sections'] ?? data['title'] ?? '').toString().toLowerCase();
  if (sections.contains('302') || sections.contains('murder')) return 'Homicide / Violent';
  if (sections.contains('376') || sections.contains('pocso')) return 'Women & Child Safety';
  if (sections.contains('379') || sections.contains('theft') || sections.contains('392')) return 'Theft & Robbery';
  if (sections.contains('cyber') || sections.contains('fraud') || sections.contains('420')) return 'Cyber & Financial';
  if (sections.contains('ndps') || sections.contains('drug')) return 'Narcotics (NDPS)';
  return 'Other Cognizable';
}

// =============================================================================
// 📈 1. CASES TREND GRAPH CARD (Line / Area Chart + By Crime Type Breakdown)
// =============================================================================
class _CasesTrendGraphCard extends StatefulWidget {
  final List<QueryDocumentSnapshot> docs;
  final bool isLoading;
  final int days;
  final bool isDesktop;
  final ValueChanged<int> onDaysChanged;
  final VoidCallback? onNavigateToCases;

  const _CasesTrendGraphCard({
    required this.docs,
    required this.isLoading,
    required this.days,
    required this.isDesktop,
    required this.onDaysChanged,
    this.onNavigateToCases,
  });

  @override
  State<_CasesTrendGraphCard> createState() => _CasesTrendGraphCardState();
}

class _CasesTrendGraphCardState extends State<_CasesTrendGraphCard> {
  bool _showByCrimeType = false; // Toggle: Overall vs By Crime Type
  final Set<String> _hiddenCrimeTypes = {}; // Interactive hide/show toggles
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isYearlyOrMultiMonth = widget.days >= 180;

    // Time buckets
    final List<DateTime> timeBuckets = [];
    final List<String> bucketLabels = [];

    if (isYearlyOrMultiMonth) {
      final monthsCount = widget.days == 365 ? 12 : 6;
      for (int i = monthsCount - 1; i >= 0; i--) {
        final dt = DateTime(now.year, now.month - i, 1);
        timeBuckets.add(dt);
        const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        bucketLabels.add(monthNames[dt.month - 1]);
      }
    } else {
      final today = DateTime(now.year, now.month, now.day);
      for (int i = widget.days - 1; i >= 0; i--) {
        final dt = today.subtract(Duration(days: i));
        timeBuckets.add(dt);
        bucketLabels.add('${dt.day}/${dt.month}');
      }
    }

    final bucketCount = timeBuckets.length;
    final filedCounts = List<int>.filled(bucketCount, 0);
    final disposedCounts = List<int>.filled(bucketCount, 0);

    // Per crime type series
    final Map<String, List<int>> crimeTypeSeries = {};
    for (final cat in kCrimeCategoryColors.keys) {
      crimeTypeSeries[cat] = List<int>.filled(bucketCount, 0);
    }

    // Comparison buckets for Increase / Decrease Summary
    final currentWindowStart = now.subtract(Duration(days: widget.days));
    final previousWindowStart = now.subtract(Duration(days: widget.days * 2));

    final Map<String, int> currentPeriodCounts = {};
    final Map<String, int> previousPeriodCounts = {};

    for (final cat in kCrimeCategoryColors.keys) {
      currentPeriodCounts[cat] = 0;
      previousPeriodCounts[cat] = 0;
    }

    for (final doc in widget.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final dynamic createdRaw = data['createdAt'] ?? data['date'] ?? data['incidentDate'];
      final status = (data['status'] ?? '').toString().toLowerCase();
      final isDisposed = status == 'disposed' ||
          status == 'completed' ||
          status == 'chargesheet filed' ||
          status == 'closed' ||
          data['chargesheetNumber'] != null;
      final crimeType = resolveCaseType(data);

      DateTime? createdDt;
      if (createdRaw is Timestamp) {
        createdDt = createdRaw.toDate();
      } else if (createdRaw is String) {
        createdDt = DateTime.tryParse(createdRaw);
      }

      if (createdDt != null) {
        // Increase / Decrease window comparison
        if (createdDt.isAfter(currentWindowStart)) {
          currentPeriodCounts[crimeType] = (currentPeriodCounts[crimeType] ?? 0) + 1;
        } else if (createdDt.isAfter(previousWindowStart) && createdDt.isBefore(currentWindowStart)) {
          previousPeriodCounts[crimeType] = (previousPeriodCounts[crimeType] ?? 0) + 1;
        }

        // Plot bucket matching
        if (isYearlyOrMultiMonth) {
          for (int b = 0; b < bucketCount; b++) {
            final bDt = timeBuckets[b];
            if (createdDt.year == bDt.year && createdDt.month == bDt.month) {
              filedCounts[b]++;
              if (isDisposed) disposedCounts[b]++;
              if (!crimeTypeSeries.containsKey(crimeType)) {
                crimeTypeSeries[crimeType] = List<int>.filled(bucketCount, 0);
              }
              crimeTypeSeries[crimeType]![b]++;
              break;
            }
          }
        } else {
          final today = DateTime(now.year, now.month, now.day);
          final cDate = DateTime(createdDt.year, createdDt.month, createdDt.day);
          final diffDays = today.difference(cDate).inDays;
          if (diffDays >= 0 && diffDays < widget.days) {
            final idx = widget.days - 1 - diffDays;
            if (idx >= 0 && idx < bucketCount) {
              filedCounts[idx]++;
              if (isDisposed) disposedCounts[idx]++;
              if (!crimeTypeSeries.containsKey(crimeType)) {
                crimeTypeSeries[crimeType] = List<int>.filled(bucketCount, 0);
              }
              crimeTypeSeries[crimeType]![idx]++;
            }
          }
        }
      }
    }

    final totalFiled = filedCounts.fold<int>(0, (a, b) => a + b);
    final totalDisposed = disposedCounts.fold<int>(0, (a, b) => a + b);

    // Calculate max value for Y-axis scale
    int maxVal = 1;
    if (_showByCrimeType) {
      for (final entry in crimeTypeSeries.entries) {
        if (!_hiddenCrimeTypes.contains(entry.key)) {
          for (final val in entry.value) {
            if (val > maxVal) maxVal = val;
          }
        }
      }
    } else {
      maxVal = math.max(1, [
        ...filedCounts,
        ...disposedCounts,
      ].fold<int>(0, (prev, e) => math.max(prev, e)));
    }

    // Build comparison items (Sorted: Highest Increases at top, Decreases below)
    final comparisonItems = _buildComparisonStats(currentPeriodCounts, previousPeriodCounts);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Controls Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.show_chart_rounded, color: Color(0xFF2563EB), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _showByCrimeType ? 'Crime-Type Dynamics & Trends' : 'Cases Trend Analysis',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          _showByCrimeType
                              ? 'Month-over-month trajectory by crime classification'
                              : 'Filed vs. Disposed registration volume over time',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                // View Mode & Range Switchers
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Mode Switcher: Overall vs By Crime Type
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildModeBtn('Overall', false),
                          _buildModeBtn('By Crime Type', true),
                        ],
                      ),
                    ),

                    // Range Switcher: 7D / 30D / 6M / 1Y
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRangeBtn('7 Days', 7),
                          _buildRangeBtn('30 Days', 30),
                          _buildRangeBtn('6 Months', 180),
                          _buildRangeBtn('1 Year', 365),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Legend & Interactive Filter Bar
            if (!_showByCrimeType)
              Row(
                children: [
                  _buildLegendPill('Filed Cases', const Color(0xFF2563EB), totalFiled, null),
                  const SizedBox(width: 16),
                  _buildLegendPill('Disposed Cases', const Color(0xFF10B981), totalDisposed, null),
                  const Spacer(),
                  if (_hoveredIndex != null && _hoveredIndex! < bucketCount)
                    _buildHoverBadge('${bucketLabels[_hoveredIndex!]}: ${filedCounts[_hoveredIndex!]} Filed, ${disposedCounts[_hoveredIndex!]} Disposed'),
                ],
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...kCrimeCategoryColors.keys.map((cat) {
                    final color = kCrimeCategoryColors[cat]!;
                    final count = currentPeriodCounts[cat] ?? 0;
                    final isHidden = _hiddenCrimeTypes.contains(cat);
                    return _buildLegendPill(
                      cat,
                      color,
                      count,
                      () {
                        setState(() {
                          if (isHidden) {
                            _hiddenCrimeTypes.remove(cat);
                          } else {
                            _hiddenCrimeTypes.add(cat);
                          }
                        });
                      },
                      isHidden: isHidden,
                    );
                  }),
                  if (_hoveredIndex != null && _hoveredIndex! < bucketCount)
                    _buildHoverBadge('${bucketLabels[_hoveredIndex!]} Point Inspected'),
                ],
              ),

            const SizedBox(height: 18),

            // Line Chart Canvas Area
            SizedBox(
              height: 240,
              child: widget.isLoading
                  ? const Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    )
                  : (totalFiled == 0 && totalDisposed == 0)
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics_outlined, size: 36, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              const Text(
                                'No case records registered in this time period',
                                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        )
                      : MouseRegion(
                          onHover: (event) {
                            final box = context.findRenderObject() as RenderBox?;
                            if (box != null) {
                              final localX = event.localPosition.dx - 30; // padding offset
                              final chartW = box.size.width - 60;
                              if (chartW > 0) {
                                final idx = ((localX / chartW) * (bucketCount - 1)).round().clamp(0, bucketCount - 1);
                                if (_hoveredIndex != idx) {
                                  setState(() => _hoveredIndex = idx);
                                }
                              }
                            }
                          },
                          onExit: (_) => setState(() => _hoveredIndex = null),
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _MultiSeriesTrendPainter(
                              labels: bucketLabels,
                              showByCrimeType: _showByCrimeType,
                              filed: filedCounts,
                              disposed: disposedCounts,
                              crimeTypeSeries: crimeTypeSeries,
                              hiddenCrimeTypes: _hiddenCrimeTypes,
                              maxVal: maxVal,
                              hoveredIndex: _hoveredIndex,
                            ),
                          ),
                        ),
            ),

            const SizedBox(height: 22),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 18),

            // 🎯 2. INCREASE / DECREASE SUMMARY LIST
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.compare_arrows_rounded, size: 16, color: Color(0xFF475569)),
                        SizedBox(width: 6),
                        Text(
                          'Period-over-Period Crime Trend Summary',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Comparing last ${widget.days == 365 ? "1 Year" : widget.days == 180 ? "6 Months" : "${widget.days} Days"} vs Prior Period',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Responsive summary cards
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: comparisonItems.map((item) {
                    return _buildComparisonChip(item);
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<_CrimeComparisonItem> _buildComparisonStats(
    Map<String, int> currentMap,
    Map<String, int> previousMap,
  ) {
    final List<_CrimeComparisonItem> list = [];

    for (final cat in kCrimeCategoryColors.keys) {
      final current = currentMap[cat] ?? 0;
      final prev = previousMap[cat] ?? 0;

      double pctChange = 0.0;
      if (prev > 0) {
        pctChange = ((current - prev) / prev) * 100;
      } else if (current > 0) {
        pctChange = 100.0; // New entries
      }

      list.add(_CrimeComparisonItem(
        category: cat,
        currentCount: current,
        previousCount: prev,
        percentageChange: pctChange,
        color: kCrimeCategoryColors[cat]!,
      ));
    }

    // Sort: Largest positive increase (more crime = highest priority) down to decreases
    list.sort((a, b) => b.percentageChange.compareTo(a.percentageChange));
    return list;
  }

  Widget _buildComparisonChip(_CrimeComparisonItem item) {
    final isIncrease = item.percentageChange > 0;
    final isDecrease = item.percentageChange < 0;
    final isZero = item.percentageChange == 0;

    // 🚨 Police Rule: Crime Increase = Red/Orange (Warning), Crime Decrease = Green (Safe), Zero = Slate
    final trendColor = isIncrease
        ? const Color(0xFFEF4444)
        : isDecrease
            ? const Color(0xFF10B981)
            : const Color(0xFF64748B);

    final trendBg = trendColor.withValues(alpha: 0.1);
    final icon = isIncrease
        ? Icons.trending_up_rounded
        : isDecrease
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;

    final pctStr = isZero
        ? '0%'
        : isIncrease
            ? '+${item.percentageChange.toStringAsFixed(0)}%'
            : '${item.percentageChange.toStringAsFixed(0)}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.category,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.currentCount} cases',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: trendBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: trendColor),
                const SizedBox(width: 3),
                Text(
                  pctStr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: trendColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBtn(String label, bool isCrimeTypeMode) {
    final isSelected = _showByCrimeType == isCrimeTypeMode;
    return GestureDetector(
      onTap: () => setState(() => _showByCrimeType = isCrimeTypeMode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildRangeBtn(String label, int val) {
    final isSelected = widget.days == val;
    return GestureDetector(
      onTap: () => widget.onDaysChanged(val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendPill(
    String label,
    Color color,
    int count,
    VoidCallback? onTap, {
    bool isHidden = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isHidden ? 0.35 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isHidden ? const Color(0xFFF1F5F9) : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isHidden ? const Color(0xFFCBD5E1) : color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isHidden ? Colors.grey : color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isHidden ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                  decoration: isHidden ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isHidden ? const Color(0xFF94A3B8) : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoverBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CrimeComparisonItem {
  final String category;
  final int currentCount;
  final int previousCount;
  final double percentageChange;
  final Color color;

  _CrimeComparisonItem({
    required this.category,
    required this.currentCount,
    required this.previousCount,
    required this.percentageChange,
    required this.color,
  });
}

// 🎨 Custom Painter for Multi-Series Trend Curves
class _MultiSeriesTrendPainter extends CustomPainter {
  final List<String> labels;
  final bool showByCrimeType;
  final List<int> filed;
  final List<int> disposed;
  final Map<String, List<int>> crimeTypeSeries;
  final Set<String> hiddenCrimeTypes;
  final int maxVal;
  final int? hoveredIndex;

  _MultiSeriesTrendPainter({
    required this.labels,
    required this.showByCrimeType,
    required this.filed,
    required this.disposed,
    required this.crimeTypeSeries,
    required this.hiddenCrimeTypes,
    required this.maxVal,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padL = 35.0;
    const padB = 25.0;
    final w = size.width - padL - 10;
    final h = size.height - padB - 10;

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1;

    const textStyle = TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w500);

    // Draw horizontal grid lines & Y-axis labels
    const gridSteps = 4;
    for (int i = 0; i <= gridSteps; i++) {
      final y = 10 + (h / gridSteps) * i;
      final val = (maxVal * (gridSteps - i) / gridSteps).round();
      canvas.drawLine(Offset(padL, y), Offset(size.width - 10, y), gridPaint);

      final tp = TextPainter(
        text: TextSpan(text: '$val', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(padL - tp.width - 6, y - tp.height / 2));
    }

    final n = labels.length;
    if (n < 2) return;

    if (!showByCrimeType) {
      // 1. Overall: Filed vs Disposed
      final filedPoints = <Offset>[];
      final disposedPoints = <Offset>[];

      for (int i = 0; i < n; i++) {
        final x = padL + (w / (n - 1)) * i;
        final yF = 10 + h - (filed[i] / maxVal) * h;
        final yD = 10 + h - (disposed[i] / maxVal) * h;
        filedPoints.add(Offset(x, yF));
        disposedPoints.add(Offset(x, yD));
      }

      _drawCurvedArea(canvas, filedPoints, h + 10, const Color(0xFF2563EB));
      _drawCurvedArea(canvas, disposedPoints, h + 10, const Color(0xFF10B981));
      _drawCurvedLine(canvas, filedPoints, const Color(0xFF2563EB), 2.5);
      _drawCurvedLine(canvas, disposedPoints, const Color(0xFF10B981), 2.5);

      for (int i = 0; i < n; i++) {
        final isHovered = hoveredIndex == i;
        _drawDot(canvas, filedPoints[i], const Color(0xFF2563EB), isHovered);
        _drawDot(canvas, disposedPoints[i], const Color(0xFF10B981), isHovered);
      }
    } else {
      // 2. By Crime Type Series
      for (final entry in crimeTypeSeries.entries) {
        if (hiddenCrimeTypes.contains(entry.key)) continue;
        final color = kCrimeCategoryColors[entry.key] ?? Colors.blue;
        final points = <Offset>[];

        for (int i = 0; i < n; i++) {
          final x = padL + (w / (n - 1)) * i;
          final y = 10 + h - (entry.value[i] / maxVal) * h;
          points.add(Offset(x, y));
        }

        _drawCurvedArea(canvas, points, h + 10, color.withValues(alpha: 0.15));
        _drawCurvedLine(canvas, points, color, 2.2);

        for (int i = 0; i < n; i++) {
          final isHovered = hoveredIndex == i;
          _drawDot(canvas, points[i], color, isHovered);
        }
      }
    }

    // Hover vertical indicator line
    if (hoveredIndex != null && hoveredIndex! < n) {
      final x = padL + (w / (n - 1)) * hoveredIndex!;
      canvas.drawLine(
        Offset(x, 10),
        Offset(x, h + 10),
        Paint()
          ..color = const Color(0xFF64748B).withValues(alpha: 0.3)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke,
      );
    }

    // Draw X-Axis Date/Month Labels
    final step = (n / 12).ceil().clamp(1, n);
    for (int i = 0; i < n; i += step) {
      final x = padL + (w / (n - 1)) * i;
      final lbl = labels[i];
      final tp = TextPainter(
        text: TextSpan(text: lbl, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - padB + 6));
    }
  }

  void _drawDot(Canvas canvas, Offset pt, Color color, bool isHovered) {
    canvas.drawCircle(pt, isHovered ? 5.5 : 3.5, Paint()..color = Colors.white);
    canvas.drawCircle(pt, isHovered ? 4.2 : 2.5, Paint()..color = color);
  }

  void _drawCurvedArea(Canvas canvas, List<Offset> points, double bottomY, Color color) {
    if (points.isEmpty) return;
    final path = Path()..moveTo(points.first.dx, bottomY);
    path.lineTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }
    path.lineTo(points.last.dx, bottomY);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(points.first.dx, 0, points.last.dx, bottomY));

    canvas.drawPath(path, paint);
  }

  void _drawCurvedLine(Canvas canvas, List<Offset> points, Color color, double strokeWidth) {
    if (points.isEmpty) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MultiSeriesTrendPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.showByCrimeType != showByCrimeType ||
        oldDelegate.hiddenCrimeTypes != hiddenCrimeTypes ||
        oldDelegate.labels != labels ||
        oldDelegate.filed != filed ||
        oldDelegate.disposed != disposed;
  }
}

// =============================================================================
// 🍩 2. CRIME TYPE DISTRIBUTION — "Crime Circle" (Donut Chart)
// =============================================================================
class _CrimeTypeDonutCard extends StatefulWidget {
  final List<QueryDocumentSnapshot> docs;
  final bool isLoading;
  final bool isDesktop;
  final VoidCallback? onNavigateToCases;

  const _CrimeTypeDonutCard({
    required this.docs,
    required this.isLoading,
    this.isDesktop = true,
    this.onNavigateToCases,
  });

  @override
  State<_CrimeTypeDonutCard> createState() => _CrimeTypeDonutCardState();
}

class _CrimeTypeDonutCardState extends State<_CrimeTypeDonutCard> {
  int? _hoveredSliceIndex;

  Color _getColorForCategory(String category, int index) {
    if (kCrimeCategoryColors.containsKey(category)) {
      return kCrimeCategoryColors[category]!;
    }
    const fallbackPalette = [
      Color(0xFF06B6D4),
      Color(0xFF6366F1),
      Color(0xFFEAB308),
      Color(0xFF14B8A6),
      Color(0xFFF97316),
      Color(0xFF84CC16),
    ];
    return fallbackPalette[index % fallbackPalette.length];
  }

  int? _detectSliceAtOffset(Offset localPos, Size chartSize, List<MapEntry<String, int>> sortedEntries, int totalCases) {
    if (totalCases <= 0) return null;
    final center = Offset(chartSize.width / 2, chartSize.height / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    final outerR = (chartSize.width / 2) + 6;
    final innerR = (chartSize.width / 2) - 30;

    if (distance < innerR || distance > outerR) return null;

    // Angle from -pi to +pi (0 is at 3 o'clock)
    double angle = math.atan2(dy, dx);
    // Adjust for start angle at 12 o'clock (-pi/2)
    angle = (angle + (math.pi / 2));
    if (angle < 0) angle += 2 * math.pi;

    double cumulativeAngle = 0;
    for (int i = 0; i < sortedEntries.length; i++) {
      final sweep = (sortedEntries[i].value / totalCases) * 2 * math.pi;
      if (angle >= cumulativeAngle && angle < cumulativeAngle + sweep) {
        return i;
      }
      cumulativeAngle += sweep;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Group and calculate purely from live Firestore docs
    final Map<String, int> counts = {};
    for (final doc in widget.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final type = resolveCaseType(data);
      counts[type] = (counts[type] ?? 0) + 1;
    }

    final totalCases = counts.values.fold<int>(0, (a, b) => a + b);
    final sortedEntries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF2F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.pie_chart_outline_rounded, color: Color(0xFFDB2777), size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Crime Circle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Live proportion & volume by crime classification',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: widget.onNavigateToCases,
                  icon: const Icon(Icons.open_in_new_rounded, size: 13, color: Color(0xFF2563EB)),
                  label: const Text(
                    'View All Cases',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (widget.isLoading)
              const SizedBox(
                height: 200,
                child: Center(
                  child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
                ),
              )
            else if (totalCases == 0)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
                        ],
                      ),
                      child: const Icon(Icons.pie_chart_outline_rounded, size: 32, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No cases recorded yet',
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Real-time crime breakdown will populate automatically once cases are registered.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 760;
                  final isMedium = constraints.maxWidth >= 500 && constraints.maxWidth < 760;

                  return _buildResponsiveBody(
                    sortedEntries: sortedEntries,
                    totalCases: totalCases,
                    isWide: isWide,
                    isMedium: isMedium,
                    containerWidth: constraints.maxWidth,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveBody({
    required List<MapEntry<String, int>> sortedEntries,
    required int totalCases,
    required bool isWide,
    required bool isMedium,
    required double containerWidth,
  }) {
    const chartSize = Size(180, 180);

    final donutWidget = SizedBox(
      height: chartSize.height,
      width: chartSize.width,
      child: MouseRegion(
        onHover: (event) {
          final idx = _detectSliceAtOffset(event.localPosition, chartSize, sortedEntries, totalCases);
          if (_hoveredSliceIndex != idx) {
            setState(() => _hoveredSliceIndex = idx);
          }
        },
        onExit: (_) => setState(() => _hoveredSliceIndex = null),
        child: GestureDetector(
          onTap: widget.onNavigateToCases,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: chartSize,
                painter: _DonutChartPainter(
                  entries: sortedEntries,
                  total: totalCases,
                  hoveredIndex: _hoveredSliceIndex,
                  getColor: _getColorForCategory,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _hoveredSliceIndex != null && _hoveredSliceIndex! < sortedEntries.length
                        ? '${sortedEntries[_hoveredSliceIndex!].value}'
                        : '$totalCases',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: _hoveredSliceIndex != null && _hoveredSliceIndex! < sortedEntries.length
                          ? _getColorForCategory(sortedEntries[_hoveredSliceIndex!].key, _hoveredSliceIndex!)
                          : const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    _hoveredSliceIndex != null && _hoveredSliceIndex! < sortedEntries.length
                        ? sortedEntries[_hoveredSliceIndex!].key
                        : 'Total Cases',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Multi-column cards grid for desktop and tablet
    final cardsGrid = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? (containerWidth > 1000 ? 3 : 2) : (isMedium ? 2 : 1),
        mainAxisSpacing: 10,
        crossAxisSpacing: 12,
        mainAxisExtent: 72,
      ),
      itemCount: sortedEntries.length,
      itemBuilder: (context, i) {
        final item = sortedEntries[i];
        final catColor = _getColorForCategory(item.key, i);
        final pct = (item.value / totalCases) * 100;
        final isHovered = _hoveredSliceIndex == i;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredSliceIndex = i),
          onExit: (_) => setState(() => _hoveredSliceIndex = null),
          child: InkWell(
            onTap: widget.onNavigateToCases,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isHovered ? catColor.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isHovered ? catColor : const Color(0xFFE2E8F0),
                  width: isHovered ? 1.5 : 1,
                ),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color: catColor.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: catColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isWide ? 140 : 180,
                            ),
                            child: Text(
                              item.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isHovered ? FontWeight.w800 : FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${item.value} (${pct.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: catColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Visual Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(catColor),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          donutWidget,
          const SizedBox(width: 32),
          Expanded(child: cardsGrid),
          const SizedBox(width: 8),
        ],
      );
    } else {
      return Column(
        children: [
          Center(child: donutWidget),
          const SizedBox(height: 24),
          cardsGrid,
        ],
      );
    }
  }
}

// 🎨 Custom Painter for Interactive Donut Arcs
class _DonutChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> entries;
  final int total;
  final int? hoveredIndex;
  final Color Function(String, int) getColor;

  _DonutChartPainter({
    required this.entries,
    required this.total,
    required this.hoveredIndex,
    required this.getColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = (size.width / 2) - 14;
    double startAngle = -math.pi / 2;

    for (int i = 0; i < entries.length; i++) {
      final sweepAngle = (entries[i].value / total) * 2 * math.pi;
      final isHovered = hoveredIndex == i;
      final color = getColor(entries[i].key, i);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHovered ? 24 : 18
        ..strokeCap = StrokeCap.butt;

      // Draw active arc with slight separation gap
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: isHovered ? baseRadius + 1.5 : baseRadius),
        startAngle,
        sweepAngle - (entries.length > 1 ? 0.04 : 0.0),
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.entries != entries ||
        oldDelegate.total != total;
  }
}

