import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../modules/core/models/base_record.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../widgets/send_reminder_dialog.dart';
import 'module_record_detail_screen.dart';

class AnalyticsPerformanceScreen extends StatefulWidget {
  const AnalyticsPerformanceScreen({super.key});

  @override
  State<AnalyticsPerformanceScreen> createState() =>
      _AnalyticsPerformanceScreenState();
}

class _AnalyticsPerformanceScreenState
    extends State<AnalyticsPerformanceScreen> {
  final FirestoreService _firestore = FirestoreService();
  String _selectedTimeFilter = 'All Time';

  static const List<String> _timeFilters = [
    'All Time',
    'This Month',
    'Last 30 Days',
    'This Year',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isSenior = SeniorOfficerRoles.canSwitchLocation(auth.designation) ||
        auth.isSupervisor ||
        auth.isAdmin;

    final activeStation = auth.activeStation;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon:
              const Icon(Icons.arrow_back_rounded, color: AppColors.navyDark),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crime Analytics & Performance',
              style: GoogleFonts.poppins(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDark,
              ),
            ),
            Text(
              '${auth.designation.toUpperCase()} Executive Monitoring · ${activeStation.isNotEmpty ? activeStation : "City-wide"}',
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: AppColors.lightSubText,
              ),
            ),
          ],
        ),
        actions: [
          // Time filter dropdown
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DropdownButtonHideUnderline(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.navyMid.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: DropdownButton<String>(
                  value: _selectedTimeFilter,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: AppColors.navyDark),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyDark,
                  ),
                  dropdownColor: Colors.white,
                  items: _timeFilters
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedTimeFilter = v);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<ModuleRecord>>(
        stream: _firestore.getStationCasesStream(activeStation),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allRecords = snapshot.data ?? [];
          final filteredRecords = _filterByTime(allRecords);

          final totalCases = filteredRecords.length;
          final pendingCases = filteredRecords
              .where((r) =>
                  r.status != 'Disposal' &&
                  r.status != 'Closed' &&
                  r.status != 'Resolved')
              .toList();
          final disposedCases = filteredRecords
              .where((r) =>
                  r.status == 'Disposal' ||
                  r.status == 'Closed' ||
                  r.status == 'Resolved')
              .toList();

          final disposalRate = totalCases > 0
              ? ((disposedCases.length / totalCases) * 100).toStringAsFixed(1)
              : '0.0';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── KPI Summary Cards ──────────────────────────────────────
                _buildKpiRow(
                  total: totalCases,
                  pending: pendingCases.length,
                  disposed: disposedCases.length,
                  rate: disposalRate,
                ),
                const SizedBox(height: 20),

                // ── Disposal Efficiency Rate Gauge ─────────────────────────
                _buildEfficiencyCard(
                  total: totalCases,
                  disposed: disposedCases.length,
                  rateStr: disposalRate,
                ),
                const SizedBox(height: 20),

                // ── Crime Breakdown by Category ────────────────────────────
                _buildCategoryBreakdown(filteredRecords),
                const SizedBox(height: 20),

                // ── Investigating Officer (IO) Workload & Pending Cases ────
                _buildIoPerformanceSection(
                  context,
                  pendingCases: pendingCases,
                  isSenior: isSenior,
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  List<ModuleRecord> _filterByTime(List<ModuleRecord> records) {
    if (_selectedTimeFilter == 'All Time') return records;

    final now = DateTime.now();
    return records.where((r) {
      final date = r.createdAt;
      if (_selectedTimeFilter == 'This Month') {
        return date.year == now.year && date.month == now.month;
      }
      if (_selectedTimeFilter == 'Last 30 Days') {
        return now.difference(date).inDays <= 30;
      }
      if (_selectedTimeFilter == 'This Year') {
        return date.year == now.year;
      }
      return true;
    }).toList();
  }

  Widget _buildKpiRow({
    required int total,
    required int pending,
    required int disposed,
    required String rate,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            label: 'Total Crime',
            value: '$total',
            icon: Icons.folder_special_rounded,
            color: AppColors.navyDark,
            subtitle: 'Registered',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            label: 'Pending',
            value: '$pending',
            icon: Icons.pending_actions_rounded,
            color: AppColors.warningOrange,
            subtitle: 'Under Investigation',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            label: 'Disposed',
            value: '$disposed',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.successGreen,
            subtitle: 'Chargesheet/Court',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.lightSubText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyCard({
    required int total,
    required int disposed,
    required String rateStr,
  }) {
    final rate = double.tryParse(rateStr) ?? 0.0;
    final color = rate >= 70
        ? AppColors.successGreen
        : rate >= 40
            ? AppColors.warningOrange
            : AppColors.dangerRed;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disposal & Clearance Rate',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyDark,
                    ),
                  ),
                  Text(
                    '$disposed of $total cases resolved',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.lightSubText,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$rateStr%',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total > 0 ? disposed / total : 0.0,
              minHeight: 10,
              backgroundColor: AppColors.lightBg,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<ModuleRecord> records) {
    final Map<String, int> counts = {};
    for (final r in records) {
      final cat = r.firestoreCategoryDisplayName;
      counts[cat] = (counts[cat] ?? 0) + 1;
    }

    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_rounded,
                  size: 18, color: AppColors.navyDark),
              const SizedBox(width: 8),
              Text(
                'Crime Category Distribution',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (sortedEntries.isEmpty)
            Text(
              'No records found for the selected filter.',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.lightSubText),
            )
          else
            ...sortedEntries.map((e) {
              final pct = records.isNotEmpty
                  ? (e.value / records.length * 100).toStringAsFixed(1)
                  : '0';
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.key,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyDark,
                          ),
                        ),
                        Text(
                          '${e.value} cases ($pct%)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyMid,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: records.isNotEmpty
                            ? e.value / records.length
                            : 0.0,
                        minHeight: 6,
                        backgroundColor: AppColors.lightBg,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.goldPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildIoPerformanceSection(
    BuildContext context, {
    required List<ModuleRecord> pendingCases,
    required bool isSenior,
  }) {
    final Map<String, List<ModuleRecord>> ioCases = {};
    for (final r in pendingCases) {
      final io = r.assignedOfficer.trim().isNotEmpty
          ? r.assignedOfficer.trim()
          : 'Unassigned IO';
      ioCases.putIfAbsent(io, () => []).add(r);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_rounded,
                  size: 18, color: AppColors.navyDark),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Investigating Officer (IO) Pendency',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                      ),
                    ),
                    Text(
                      'Track workload and issue direct supervision reminders',
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
          const SizedBox(height: 14),
          if (ioCases.isEmpty)
            Text(
              'No active pending cases.',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.lightSubText),
            )
          else
            ...ioCases.entries.map((entry) {
              final ioName = entry.key;
              final cases = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              AppColors.navyMid.withValues(alpha: 0.1),
                          child: const Icon(Icons.person_rounded,
                              size: 16, color: AppColors.navyDark),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ioName,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warningOrange
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${cases.length} Pending',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warningOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...cases.take(3).map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    AppTheme.fadeSlideRoute(
                                      page: ModuleRecordDetailScreen(record: c),
                                    ),
                                  );
                                },
                                child: Text(
                                  '• ${c.caseNumber.isNotEmpty ? c.caseNumber : c.title}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    color: AppColors.navyMid,
                                    decoration: TextDecoration.underline,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (isSenior)
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_active_outlined,
                                  size: 18,
                                  color: AppColors.warningOrange,
                                ),
                                tooltip: 'Send Reminder to IO',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  SendReminderDialog.show(context, c);
                                },
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
