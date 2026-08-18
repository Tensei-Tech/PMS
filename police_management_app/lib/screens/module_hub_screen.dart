// lib/screens/module_hub_screen.dart
// Reusable screen for ALL 12 modules — strictly isolated data per module.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../modules/core/providers/base_module_provider.dart';
import '../modules/core/models/base_record.dart';
import '../modules/form_iv/providers/form_iv_provider.dart';
import '../modules/form_vi/providers/form_vi_provider.dart';
import '../modules/nc/providers/nc_provider.dart';
import '../modules/missing/screens/missing_form_screen.dart';
import '../modules/nc/screens/nc_form_screen.dart';
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
import '../utils/module_pdf_helper.dart';
import '../utils/pdf_auth_gate.dart';
import '../widgets/read_only_module_record_hub_card.dart';
import '../widgets/module_hub_report_card.dart';
import '../widgets/module_hub_screen_app_bar.dart';
import '../widgets/forms_accordion_list.dart';
import '../utils/pending_io_wise_logic.dart';
import 'pending_summary_screen.dart';
import 'pending_io_wise_screens.dart';
import 'pending_io_wise_all_categories_screen.dart';
import 'pending_demo_table_screen.dart';
import 'ad_form_screen.dart';
import 'ad_record_detail_screen.dart';
import 'module_form_screen.dart';
import 'common_form_screen.dart';
import '../utils/common_form_module.dart';
import 'form_i_v_selection_screen.dart';
import 'module_record_detail_screen.dart';
import 'report_case_list_screen.dart';

class _CategoryMeta {
  final String label;
  final String moduleKey;
  final String? subCategory;
  int count;
  int solvedCount = 0;

  _CategoryMeta({
    required this.label,
    required this.moduleKey,
    this.subCategory,
    required this.count,
  });
}

class ModuleHubScreen extends StatefulWidget {
  final String moduleLabel;
  final String moduleKey;
  final String? subCategory;
  final bool readOnly;

  const ModuleHubScreen({
    super.key,
    required this.moduleLabel,
    required this.moduleKey,
    this.subCategory,
    this.readOnly = false,
  });

  @override
  State<ModuleHubScreen> createState() => _ModuleHubScreenState();
}

class _ModuleHubScreenState extends State<ModuleHubScreen> {
  String _filter = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  late int _reportMonth;
  late int _reportYear;
  bool _showMonthlySummaryTable = false;
  bool _showMonthlyClassVTable = false;
  bool _showMonthlyClassVITable = false;
  bool _showMonthlyPreventiveTable = false;

  String? _pendingCategory;
  String? _pendingTimeRange;

  static const List<String> _pendingHubCategories = [
    ...kPendingDashboardCategoriesForIoWise,
    'IO Wise',
  ];

  static const List<String> _pendingHubTimeRanges = [
    'More than 1 year',
    '6 to 12 months',
    '3 to 6 months',
    'More than 3 months',
    'Within 3 months',
    '1 month',
    'IO Wise',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _reportMonth = now.month;
    _reportYear = now.year;
    if (widget.moduleKey == 'detected' || widget.moduleKey == 'undetected') {
      _filter = 'All';
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Watch the correct typed provider so UI rebuilds on data changes.
  BaseModuleProvider _watchProvider(BuildContext context) {
    switch (widget.moduleKey) {
      case 'form_1_5':
        return context.watch<FormIVProvider>();
      case 'form_6':
        return context.watch<FormVIProvider>();
      case 'nc':
        return context.watch<NcProvider>();
      case 'preventive':
        return context.watch<PreventiveProvider>();
      case 'ad':
        return context.watch<AdProvider>();
      case 'missing':
        return context.watch<MissingProvider>();
      case 'kidnapping':
        return context.watch<KidnappingProvider>();
      case 'theft':
        return context.watch<TheftProvider>();
      case 'sand_theft':
        return context.watch<SandTheftProvider>();
      case 'hurt':
        return context.watch<HurtProvider>();
      case 'pocso':
        return context.watch<PocsoProvider>();
      case 'passport':
        return context.watch<PassportProvider>();
      case 'monthly':
        return context.watch<MonthlyProvider>();
      case 'pending':
        return context.watch<PendingProvider>();
      case 'detected':
        return context.watch<DetectedProvider>();
      case 'undetected':
        return context.watch<UndetectedProvider>();
      case 'disposal':
        return context.watch<DisposalProvider>();
      case 'two_four_wheeler':
        return context.watch<TwoFourWheelerProvider>();
      case 'arrested':
        return context.watch<ArrestedProvider>();
      case 'absconded':
        return context.watch<AbscondedProvider>();
      case 'crime_women':
        return context.watch<CrimeWomenProvider>();
      case 'juvenile':
        return context.watch<JuvenileProvider>();
      case 'victim':
        return context.watch<VictimProvider>();
      case 'accident':
        return context.watch<AccidentProvider>();
      case 'traffic':
        return context.watch<TrafficProvider>();
      case 'application':
        return context.watch<ApplicationProvider>();
      case 'sam_warrant':
        return context.watch<SamWarrantProvider>();
      case 'muddemal':
        return context.watch<MuddemalProvider>();
      case 'bnss':
        return context.watch<BnssProvider>();
      case 'ndps':
        return context.watch<NdpsProvider>();
      case 'gowans':
        return context.watch<GowansProvider>();
      case 'it_act':
        return context.watch<ItActProvider>();
      case 'mcoca':
        return context.watch<McocaProvider>();
      case 'uapa':
        return context.watch<UapaProvider>();
      case 'mpda':
        return context.watch<MpdaProvider>();
      case 'coin':
        return context.watch<CoinProvider>();
      default:
        return context.watch<NcProvider>();
    }
  }

  /// Read (no listen) version for delete/update calls inside callbacks.
  BaseModuleProvider _readProvider(BuildContext context) {
    switch (widget.moduleKey) {
      case 'form_1_5':
        return context.read<FormIVProvider>();
      case 'form_6':
        return context.read<FormVIProvider>();
      case 'nc':
        return context.read<NcProvider>();
      case 'preventive':
        return context.read<PreventiveProvider>();
      case 'ad':
        return context.read<AdProvider>();
      case 'missing':
        return context.read<MissingProvider>();
      case 'kidnapping':
        return context.read<KidnappingProvider>();
      case 'theft':
        return context.read<TheftProvider>();
      case 'sand_theft':
        return context.read<SandTheftProvider>();
      case 'hurt':
        return context.read<HurtProvider>();
      case 'pocso':
        return context.read<PocsoProvider>();
      case 'passport':
        return context.read<PassportProvider>();
      case 'monthly':
        return context.read<MonthlyProvider>();
      case 'pending':
        return context.read<PendingProvider>();
      case 'detected':
        return context.read<DetectedProvider>();
      case 'undetected':
        return context.read<UndetectedProvider>();
      case 'disposal':
        return context.read<DisposalProvider>();
      case 'two_four_wheeler':
        return context.read<TwoFourWheelerProvider>();
      case 'arrested':
        return context.read<ArrestedProvider>();
      case 'absconded':
        return context.read<AbscondedProvider>();
      case 'crime_women':
        return context.read<CrimeWomenProvider>();
      case 'juvenile':
        return context.read<JuvenileProvider>();
      case 'victim':
        return context.read<VictimProvider>();
      case 'accident':
        return context.read<AccidentProvider>();
      case 'traffic':
        return context.read<TrafficProvider>();
      case 'application':
        return context.read<ApplicationProvider>();
      case 'sam_warrant':
        return context.read<SamWarrantProvider>();
      case 'muddemal':
        return context.read<MuddemalProvider>();
      case 'bnss':
        return context.read<BnssProvider>();
      case 'ndps':
        return context.read<NdpsProvider>();
      case 'gowans':
        return context.read<GowansProvider>();
      case 'it_act':
        return context.read<ItActProvider>();
      case 'mcoca':
        return context.read<McocaProvider>();
      case 'uapa':
        return context.read<UapaProvider>();
      case 'mpda':
        return context.read<MpdaProvider>();
      case 'coin':
        return context.read<CoinProvider>();
      default:
        return context.read<NcProvider>();
    }
  }

  bool _isReportMode = false;

  List<ModuleRecord> _getConsolidatedRecords(BuildContext context) {
    final records = <ModuleRecord>[];
    // We only include crime/service modules, excluding stats modules to avoid recursion
    records.addAll(context.watch<FormIVProvider>().records);
    records.addAll(context.watch<FormVIProvider>().records);
    records.addAll(context.watch<NcProvider>().records);
    records.addAll(context.watch<PreventiveProvider>().records);
    records.addAll(context.watch<AdProvider>().records);
    records.addAll(context.watch<MissingProvider>().records);
    records.addAll(context.watch<KidnappingProvider>().records);
    records.addAll(context.watch<TheftProvider>().records);
    records.addAll(context.watch<SandTheftProvider>().records);
    records.addAll(context.watch<HurtProvider>().records);
    records.addAll(context.watch<PocsoProvider>().records);
    records.addAll(context.watch<PassportProvider>().records);
    records.addAll(context.watch<TwoFourWheelerProvider>().records);
    records.addAll(context.watch<ArrestedProvider>().records);
    records.addAll(context.watch<AbscondedProvider>().records);
    records.addAll(context.watch<CrimeWomenProvider>().records);
    records.addAll(context.watch<JuvenileProvider>().records);
    records.addAll(context.watch<VictimProvider>().records);
    records.addAll(context.watch<AccidentProvider>().records);
    records.addAll(context.watch<TrafficProvider>().records);
    records.addAll(context.watch<ApplicationProvider>().records);
    records.addAll(context.watch<SamWarrantProvider>().records);
    records.addAll(context.watch<MuddemalProvider>().records);
    records.addAll(context.watch<BnssProvider>().records);
    records.addAll(context.watch<NdpsProvider>().records);
    records.addAll(context.watch<GowansProvider>().records);
    records.addAll(context.watch<ItActProvider>().records);
    records.addAll(context.watch<McocaProvider>().records);
    records.addAll(context.watch<UapaProvider>().records);
    records.addAll(context.watch<MpdaProvider>().records);
    records.addAll(context.watch<CoinProvider>().records);
    return records;
  }

  void _openNewEntryForm(BuildContext context) {
    if (widget.moduleKey == 'ad') {
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(page: const ADFormScreen()),
      );
      return;
    }
    if (widget.moduleKey == 'nc') {
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(
          page: NcFormScreen(
            moduleLabel: widget.moduleLabel,
            subCategory: widget.subCategory,
          ),
        ),
      );
      return;
    }
    if (widget.moduleKey == 'missing') {
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(
          page: MissingFormScreen(
            moduleLabel: widget.moduleLabel,
            subCategory: widget.subCategory,
          ),
        ),
      );
      return;
    }
    if (widget.moduleKey == 'form_1_5' && widget.subCategory == null) {
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(
          page: const FormIVSelectionScreen(
            mode: FormIVSelectionMode.add,
          ),
        ),
      );
    } else {
      final page = moduleUsesCommonCrimeForm(widget.moduleKey)
          ? CommonFormScreen(
              moduleLabel: widget.moduleLabel,
              moduleKey: widget.moduleKey,
              subCategory: widget.subCategory,
            )
          : ModuleFormScreen(
              moduleLabel: widget.moduleLabel,
              moduleKey: widget.moduleKey,
              subCategory: widget.subCategory,
            );
      Navigator.push(context, AppTheme.fadeSlideRoute(page: page));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ModuleRecord> allRecords;
    int totalCount;
    int openCount = 0;
    int activeCount = 0;
    int resolvedCount = 0;
    int closedCount = 0;

    if (widget.moduleKey == 'pending') {
      // Aggregate across ALL categories and show only active (non-closed) cases
      final consolidated = _getConsolidatedRecords(context);
      allRecords = consolidated
          .where((r) =>
              r.status != 'Closed' && r.moduleKey != 'nc')
          .toList();
      totalCount = allRecords.length;
      openCount = allRecords.where((r) => r.status == 'Open').length;
      activeCount = allRecords.where((r) => r.status == 'Active').length;
      resolvedCount = allRecords.where((r) => r.status == 'Resolved').length;
      closedCount = 0; // Closed cases are excluded from pending
    } else if (widget.moduleKey == 'disposal') {
      // Aggregate across ALL categories and show only closed cases
      final consolidated = _getConsolidatedRecords(context);
      allRecords = consolidated.where((r) => r.status == 'Closed').toList();
      totalCount = allRecords.length;
      openCount = 0; // Only closed cases in disposal
      activeCount = 0;
      resolvedCount = 0;
      closedCount = allRecords.length;
    } else if (widget.moduleKey == 'monthly') {
      allRecords = _getConsolidatedRecords(context);
      totalCount = allRecords.length;
      openCount = allRecords.where((r) => r.status == 'Open').length;
      activeCount = allRecords.where((r) => r.status == 'Active').length;
      resolvedCount = allRecords.where((r) => r.status == 'Resolved').length;
      closedCount = allRecords.where((r) => r.status == 'Closed').length;
    } else {
      final provider = _watchProvider(context);
      allRecords = provider.getFilteredRecords(widget.subCategory);
      totalCount = provider.getFilteredTotalCount(widget.subCategory);
      openCount = provider.getFilteredOpenCount(widget.subCategory);
      activeCount = provider.getFilteredActiveCount(widget.subCategory);
      resolvedCount = provider.getFilteredResolvedCount(widget.subCategory);
      closedCount = provider.getFilteredClosedCount(widget.subCategory);
    }

    final List<ModuleRecord> filtered;
    if (widget.moduleKey == 'detected' || widget.moduleKey == 'undetected') {
      if (_filter == 'Disposal' || _filter == 'Closed' || _filter == 'Resolved') {
        filtered = allRecords
            .where((r) =>
                r.status == 'Disposal' ||
                r.status == 'Closed' ||
                r.status == 'Resolved')
            .toList();
      } else if (_filter == 'Pending' ||
          _filter == 'Open' ||
          _filter == 'Active') {
        filtered = allRecords
            .where((r) =>
                r.status != 'Disposal' &&
                r.status != 'Closed' &&
                r.status != 'Resolved')
            .toList();
      } else {
        filtered = allRecords;
      }
    } else {
      filtered = _filter == 'All'
          ? allRecords
          : allRecords.where((r) => r.status == _filter).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: _buildAppBar(context, totalCount),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (widget.moduleKey == 'monthly') ...[
            // Monthly module is report-only (no records section).
            SliverToBoxAdapter(child: _buildMonthlyReport(context, allRecords)),
          ] else if (widget.moduleKey == 'pending') ...[
            SliverToBoxAdapter(child: _buildPendingModuleReportOnly(context)),
          ] else if (widget.moduleLabel == 'Forms' &&
              widget.moduleKey == 'form_1_5') ...[
            SliverToBoxAdapter(child: _buildFormsModuleReportOnly(context)),
          ] else ...[
            if (widget.moduleKey == 'disposal')
              SliverToBoxAdapter(child: _buildModuleTabs()),
            if (_isReportMode && widget.moduleKey == 'disposal')
              SliverToBoxAdapter(
                  child: _buildMonthlyReport(context, allRecords))
            else ...[
              if (widget.moduleKey != 'form_1_5' && widget.moduleKey != 'disposal') ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
                    child: _buildStatsRow(openCount, activeCount, resolvedCount,
                        closedCount, totalCount),
                  ),
                ),
              ],
              if (filtered.isEmpty)
                SliverToBoxAdapter(child: _buildEmpty())
              else
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildCard(ctx, filtered[i]),
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: (widget.readOnly || widget.moduleKey == 'detected' || widget.moduleKey == 'undetected' || widget.moduleKey == 'disposal')
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openNewEntryForm(context),
              backgroundColor: AppColors.navyDark,
              elevation: 4,
              shape: const StadiumBorder(),
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              label: Text(
                'Add Case',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, int total) {
    return ModuleHubScreenAppBar(
      title: widget.moduleLabel,
      subtitle: '$total record${total == 1 ? '' : 's'} registered',
      badgeLabel: widget.moduleLabel.toUpperCase(),
      onAddPressed: widget.readOnly ? null : () => _openNewEntryForm(context),
      backgroundColor: (widget.moduleKey == 'detected' || widget.moduleKey == 'undetected' || widget.moduleKey == 'disposal') ? AppColors.navyDark : null,
    );
  }

  Widget _buildModuleTabs() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
      child: Row(
        children: [
          _tabControl('Records', !_isReportMode,
              () => setState(() => _isReportMode = false)),
          const SizedBox(width: 12),
          _tabControl('Report', _isReportMode,
              () => setState(() => _isReportMode = true)),
        ],
      ),
    );
  }

  Widget _tabControl(String label, bool active, VoidCallback onTap) {
    final color = AppColors.navyMid;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? color : (Colors.white),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: active ? color : (AppColors.lightBorder)),
          ),
          child: Center(
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? Colors.white : (AppColors.lightSubText))),
          ),
        ),
      ),
    );
  }



  Widget _buildMonthlyReport(BuildContext context, List<ModuleRecord> records) {
    // For the "Monthly" module, show report-only (no category record tiles),
    // matching the clean Monthly layout used in the Calendar screen.
    if (widget.moduleKey == 'monthly') {
      return _buildMonthlyModuleReportOnly(context, records);
    }

    // Show ALL cases regardless of status (open, pending, closed) or incident date
    final now = DateTime.now();
    final monthRecords = records;

    // Grouping by category with meta-info for navigation
    final Map<String, _CategoryMeta> catMeta = {};
    for (var r in monthRecords) {
      final label = r.firestoreCategoryDisplayName;
      final sub = r.subCategory;

      final key = '${r.moduleKey}_${sub ?? ""}';
      if (!catMeta.containsKey(key)) {
        catMeta[key] = _CategoryMeta(
            label: label, moduleKey: r.moduleKey, subCategory: sub, count: 0);
      }
      catMeta[key]!.count++;
      // Count solved: Resolved or Closed
      if (r.status == 'Resolved' || r.status == 'Closed') {
        catMeta[key]!.solvedCount++;
      }
    }

    // Sort alphabetically by label
    final sortedMetas = catMeta.values.toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    // For the PDF helper, we still need Map<String, int>
    final Map<String, int> countsForPdf = {
      for (var m in sortedMetas) m.label: m.count
    };

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Registration Summary',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDark)),
                  Text(DateFormat('MMMM yyyy').format(now),
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.goldPrimary)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => runWithPdfAuthGate(
                  context,
                  () => ModulePdfHelper.generateSummaryReportPdf(
                    countsForPdf,
                    widget.moduleKey == 'disposal'
                        ? 'Monthly Disposal Report'
                        : widget.moduleKey == 'pending'
                            ? 'Pending Cases Report'
                            : 'Monthly Registration Report',
                    DateFormat('MMMM yyyy').format(now),
                  ),
                ),
                icon: const Icon(Icons.download_rounded,
                    size: 18, color: Colors.white),
                label: Text('Summary',
                    style:
                        GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyMid,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (sortedMetas.isEmpty)
            _buildEmptyReport()
          else
            ...sortedMetas.map((meta) => _buildReportTile(
                    meta.label, meta.count, solvedCount: meta.solvedCount,
                    onTap: () {
                  Navigator.push(
                      context,
                      AppTheme.fadeSlideRoute(
                          page: ModuleHubScreen(
                        moduleLabel: meta.label,
                        moduleKey: meta.moduleKey,
                        subCategory: meta.subCategory,
                        readOnly: true,
                      )));
                })),
          const SizedBox(height: 24),
          _buildDemoReportSection(),
        ],
      ),
    );
  }

  String _pendingHubSubtitle() {
    if (_pendingCategory == null) return 'Select a category';
    if (_pendingTimeRange == null) {
      return '$_pendingCategory — Select time range';
    }
    return '$_pendingCategory — $_pendingTimeRange';
  }

  void _onPendingCategorySelected(String label) {
    if (label == 'IO Wise') {
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(
          page: const PendingIoWiseAllCategoriesScreen(),
        ),
      );
      return;
    }
    setState(() {
      _pendingCategory = label;
      _pendingTimeRange = null;
    });
  }

  void _onPendingTimeRangeSelected(String label) {
    final category = _pendingCategory;
    if (category == null) return;
    if (label == 'IO Wise') {
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(
          page: PendingIoWiseByCategoryScreen(category: category),
        ),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    Navigator.push(
      context,
      AppTheme.fadeSlideRoute(
        page: PendingDemoTableScreen(
          stationName: auth.stationName,
          category: category,
          timeRange: label,
        ),
      ),
    );
  }

  Widget _buildPendingModuleReportOnly(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final categoryValue = _pendingCategory ?? '';
    final timeRangeValue = _pendingTimeRange ?? '';

    return ModuleHubReportCard(
      title: 'Pending Reports',
      subtitle: _pendingHubSubtitle(),
      onSummaryTap: () {
        Navigator.push(
          context,
          AppTheme.fadeSlideRoute(
            page: PendingSummaryScreen(stationName: auth.stationName),
          ),
        );
      },
      filterRow: Row(
        children: [
          ModuleHubFilterDropdown<String>(
            expanded: true,
            value: categoryValue.isEmpty ? _pendingHubCategories.first : categoryValue,
            items: _pendingHubCategories
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(
                      c,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val == null) return;
              if (val == categoryValue) return;
              _onPendingCategorySelected(val);
            },
          ),
          const SizedBox(width: 10),
          ModuleHubFilterDropdown<String>(
            value: timeRangeValue.isEmpty
                ? _pendingHubTimeRanges.first
                : timeRangeValue,
            items: _pendingHubTimeRanges
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(
                      t,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: _pendingCategory == null || _pendingCategory == 'IO Wise'
                ? null
                : (val) {
                    if (val == null) return;
                    setState(() => _pendingTimeRange = val);
                    _onPendingTimeRangeSelected(val);
                  },
          ),
        ],
      ),
      categoryButtons: ModuleHubCategoryButtonGrid(
        labels: _pendingHubCategories,
        onLabelTap: _onPendingCategorySelected,
      ),
      child: _pendingCategory != null && _pendingCategory != 'IO Wise'
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Select time range',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDark,
                  ),
                ),
                const SizedBox(height: 8),
                ModuleHubCategoryButtonGrid(
                  labels: _pendingHubTimeRanges,
                  onLabelTap: _onPendingTimeRangeSelected,
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildFormsModuleReportOnly(BuildContext context) {
    void onFormSelect(FormsListEntry entry, {FormsSubSection? subSection}) {
      final subCategory =
          subSection?.subCategoryOverride ?? entry.subCategory;
      final moduleLabel = subSection != null
          ? '${entry.title} — ${subSection.label}'
          : entry.title;
      if (subSection == null) {
        debugPrint('Opened ${entry.title} (subCategory: $subCategory)');
      } else {
        debugPrint(
          'Opened ${entry.title} — ${subSection.label} '
          '(${subSection.pageRange}, subCategory: $subCategory)',
        );
      }
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(
          page: CommonFormScreen(
            moduleLabel: moduleLabel,
            moduleKey: 'form_1_5',
            subCategory: subCategory,
            formSection: subSection?.sectionId,
            pageRange: subSection?.pageRange,
          ),
        ),
      );
    }

    return ModuleHubReportCard(
      title: 'Forms Categories',
      subtitle: '${kFormsHierarchyMock.length} form types',
      showSummaryButton: false,
      showFilterRow: false,
      filterRow: const SizedBox.shrink(),
      categoryButtons: FormsAccordionList(
        entries: kFormsHierarchyMock,
        onSelect: onFormSelect,
      ),
    );
  }

  Widget _buildMonthlyModuleReportOnly(
      BuildContext context, List<ModuleRecord> allRecords) {
    final months = const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final monthYearLabel = '${months[_reportMonth - 1]} $_reportYear';

    // Reuse the Calendar monthly table builder from dashboard (static helper).
    // We call into the same logic by generating a table locally and using the same PDF helper.
    // (intentionally unused) monthRecords was previously used for PDF export here.

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Reports',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                      ),
                    ),
                    Text(
                      monthYearLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => setState(() {
                    _showMonthlySummaryTable = !_showMonthlySummaryTable;
                    if (_showMonthlySummaryTable) {
                      _showMonthlyClassVTable = false;
                      _showMonthlyClassVITable = false;
                      _showMonthlyPreventiveTable = false;
                    }
                  }),
                  icon: const Icon(Icons.download_rounded,
                      size: 16, color: Colors.white),
                  label: Text(
                    'Summary',
                    style:
                        GoogleFonts.poppins(fontSize: 11, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyMid,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Month/Year selector (compact)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _reportMonth,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.navyMid),
                        items: List.generate(
                          12,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(
                              months[i],
                              style: GoogleFonts.poppins(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        onChanged: (val) =>
                            setState(() => _reportMonth = val ?? _reportMonth),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _reportYear,
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.navyMid),
                      items: List.generate(
                        5,
                        (i) => DropdownMenuItem(
                          value: DateTime.now().year - i,
                          child: Text(
                            '${DateTime.now().year - i}',
                            style: GoogleFonts.poppins(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      onChanged: (val) =>
                          setState(() => _reportYear = val ?? _reportYear),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Report buttons (report-only; no records list)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.navyMid.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _reportDownloadBtn(
                      'Class V',
                      () => setState(() {
                        _showMonthlySummaryTable = false;
                        _showMonthlyClassVTable = !_showMonthlyClassVTable;
                        if (_showMonthlyClassVTable) {
                          _showMonthlyClassVITable = false;
                          _showMonthlyPreventiveTable = false;
                        }
                      }),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _reportDownloadBtn(
                      'Class VI',
                      () => setState(() {
                        _showMonthlySummaryTable = false;
                        _showMonthlyClassVITable = !_showMonthlyClassVITable;
                        if (_showMonthlyClassVITable) {
                          _showMonthlyClassVTable = false;
                          _showMonthlyPreventiveTable = false;
                        }
                      }),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _reportDownloadBtn(
                      'Preventives',
                      () => setState(() {
                        _showMonthlySummaryTable = false;
                        _showMonthlyPreventiveTable =
                            !_showMonthlyPreventiveTable;
                        if (_showMonthlyPreventiveTable) {
                          _showMonthlyClassVTable = false;
                          _showMonthlyClassVITable = false;
                        }
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            if (_showMonthlySummaryTable)
              _buildMonthlySummaryPhotoTable(
                  context, allRecords, _reportMonth, _reportYear),
            if (_showMonthlyClassVTable)
              _buildMonthlyRegistrationTable(
                  context, allRecords, _reportMonth, _reportYear),
            if (_showMonthlyClassVITable)
              _buildMonthlyRegistrationTableVI(
                  context, allRecords, _reportMonth, _reportYear),
            if (_showMonthlyPreventiveTable)
              _buildMonthlyRegistrationTablePreventive(
                  context, allRecords, _reportMonth, _reportYear),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyRegistrationTablePreventive(
    BuildContext context,
    List<ModuleRecord> allRecords,
    int selectedMonth,
    int selectedYear,
  ) {
    const heads = [
      '107 Crpc/126 BNSS',
      '109 Crpc/128 BNSS',
      '110 Crpc/129 BNSS',
      '151 (3) Crpc/170(3) BNSS',
      '55 to 57 B P Act',
      'U/s 122  B P Act',
      'U/s 124  B P Act',
      '142 B P Act',
      'M H O R',
      '93 Pro Act',
      'N S A',
      'M P D A',
      'M.C.O.C.A.',
    ];

    String getHead(ModuleRecord r) {
      final key = r.moduleKey.toLowerCase();
      final sub = (r.subCategory ?? '').toLowerCase();
      if (key != 'preventive') return 'M H O R';

      if (sub.contains('107') || sub.contains('126')) {
        return '107 Crpc/126 BNSS';
      }
      if (sub.contains('109') || sub.contains('128')) {
        return '109 Crpc/128 BNSS';
      }
      if (sub.contains('110') || sub.contains('129')) {
        return '110 Crpc/129 BNSS';
      }
      if (sub.contains('151') || sub.contains('170')) {
        return '151 (3) Crpc/170(3) BNSS';
      }
      if (sub.contains('55') || sub.contains('56') || sub.contains('57')) {
        return '55 to 57 B P Act';
      }
      if (sub.contains('122')) return 'U/s 122  B P Act';
      if (sub.contains('124')) return 'U/s 124  B P Act';
      if (sub.contains('142')) return '142 B P Act';
      if (sub.contains('mhor') || sub.contains('m h o r')) return 'M H O R';
      if (sub.contains('93') || sub.contains('pro act')) return '93 Pro Act';
      if (sub.contains('nsa') || sub.contains('n s a')) return 'N S A';
      if (sub.contains('mpda') || sub.contains('m p d a')) return 'M P D A';
      if (sub.contains('mcoca') || sub.contains('m.c.o.c.a')) {
        return 'M.C.O.C.A.';
      }

      return 'M H O R';
    }

    List<ModuleRecord> filterMonth(int m, int y) => allRecords
        .where((r) =>
            r.moduleKey == 'preventive' &&
            r.incidentDate.year == y &&
            r.incidentDate.month == m)
        .toList();

    List<ModuleRecord> filterYearToMonth(int m, int y) => allRecords
        .where((r) =>
            r.moduleKey == 'preventive' &&
            r.incidentDate.year == y &&
            r.incidentDate.month <= m)
        .toList();

    final currentMonthRecords = filterMonth(selectedMonth, selectedYear);
    final prevMonth = selectedMonth == 1 ? 12 : selectedMonth - 1;
    final prevYear = selectedMonth == 1 ? selectedYear - 1 : selectedYear;
    final previousMonthRecords = filterMonth(prevMonth, prevYear);
    final sameMonthLastYearRecords =
        filterMonth(selectedMonth, selectedYear - 1);
    final yearCurrentRecords = filterYearToMonth(selectedMonth, selectedYear);
    final yearPreviousRecords =
        filterYearToMonth(selectedMonth, selectedYear - 1);

    final tableRows = <Map<String, dynamic>>[];
    int totalcm = 0, totalpm = 0, totalsmly = 0, totalyc = 0, totalyp = 0;

    for (int i = 0; i < heads.length; i++) {
      final head = heads[i];
      List<ModuleRecord> byHead(List<ModuleRecord> list) =>
          list.where((r) => getHead(r) == head).toList();

      final cmRecs = byHead(currentMonthRecords);
      final pmRecs = byHead(previousMonthRecords);
      final smlyRecs = byHead(sameMonthLastYearRecords);
      final ycRecs = byHead(yearCurrentRecords);
      final ypRecs = byHead(yearPreviousRecords);

      final cm = cmRecs.length;
      final pm = pmRecs.length;
      final smly = smlyRecs.length;
      final yc = ycRecs.length;
      final yp = ypRecs.length;
      final variation = yc - yp;

      tableRows.add({
        'N': i + 1,
        'Heads': head,
        'cm_R': cm,
        'pm_R': pm,
        'smly_R': smly,
        'yc_R': yc,
        'yp_R': yp,
        'variation': variation,
        'cmRecords': cmRecs,
        'pmRecords': pmRecs,
        'smlyRecords': smlyRecs,
        'ycRecords': ycRecs,
        'ypRecords': ypRecs,
      });

      totalcm += cm;
      totalpm += pm;
      totalsmly += smly;
      totalyc += yc;
      totalyp += yp;
    }

    tableRows.add({
      'N': '',
      'Heads': 'TOTAL',
      'cm_R': totalcm,
      'pm_R': totalpm,
      'smly_R': totalsmly,
      'yc_R': totalyc,
      'yp_R': totalyp,
      'variation': totalyc - totalyp,
      'cmRecords': currentMonthRecords,
      'pmRecords': previousMonthRecords,
      'smlyRecords': sameMonthLastYearRecords,
      'ycRecords': yearCurrentRecords,
      'ypRecords': yearPreviousRecords,
    });

    String mLabel(DateTime d) {
      final m = DateFormat('MMM').format(d).toUpperCase();
      return '$m\n${d.year}';
    }

    final cmLabel = mLabel(DateTime(selectedYear, selectedMonth));
    final pmLabel = mLabel(DateTime(prevYear, prevMonth));
    final smlyLabel = mLabel(DateTime(selectedYear - 1, selectedMonth));
    final ycLabel = 'Year\n$selectedYear';
    final ypLabel = 'Year\n${selectedYear - 1}';

    DataColumn col(String label, {bool alignLeft = false}) => DataColumn(
          label: Text(
            label,
            textAlign: alignLeft ? TextAlign.left : TextAlign.center,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.navyDark,
            ),
          ),
        );

    DataCell cell(String text, {bool alignLeft = false, bool isBold = false}) =>
        DataCell(
          Align(
            alignment: alignLeft ? Alignment.centerLeft : Alignment.center,
            child: Text(
              text,
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: isBold ? AppColors.navyDark : AppColors.lightText,
              ),
            ),
          ),
        );

    DataCell navCell(String text, List<ModuleRecord> recs, String title,
        {bool isBold = false}) {
      return DataCell(
        InkWell(
          onTap: recs.isEmpty
              ? null
              : () {
                  Navigator.push(
                    context,
                    AppTheme.fadeSlideRoute(
                      page: ReportCaseListScreen(title: title, records: recs),
                    ),
                  );
                },
          child: Align(
            alignment: Alignment.center,
            child: Text(
              text,
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color:
                    recs.isEmpty ? AppColors.lightSubText : AppColors.infoBlue,
                decoration: recs.isEmpty ? null : TextDecoration.underline,
              ),
            ),
          ),
        ),
      );
    }

    String varText(dynamic v) {
      final n = (v as int?) ?? 0;
      if (n == 0) return '=';
      return n > 0 ? '+$n' : '$n';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final colSpace =
                w < 360 ? 10.0 : (w < 600 ? 15.0 : (w < 1000 ? 20.0 : 36.0));
            final margin = w < 360 ? 8.0 : (w < 1000 ? 12.0 : 20.0);
            final headingH = w < 360 ? 52.0 : (w < 1000 ? 56.0 : 60.0);
            final rowH = w < 360 ? 44.0 : (w < 1000 ? 48.0 : 52.0);
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: w, // fill available width on PC
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: SizedBox(
                    width: w,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.navyMid.withValues(alpha: 0.05),
                      ),
                      dataRowMinHeight: rowH,
                      dataRowMaxHeight: rowH,
                      headingRowHeight: headingH,
                      horizontalMargin: margin,
                      columnSpacing: colSpace,
                      border: TableBorder.all(
                          color: AppColors.lightBorder, width: 0.5),
                      columns: [
                        col('SR'),
                        col('Heads', alignLeft: true),
                        col(cmLabel),
                        col(pmLabel),
                        col(smlyLabel),
                        col(ycLabel),
                        col(ypLabel),
                        col('var.'),
                      ],
                      rows: tableRows.map((row) {
                        final isTotal = row['Heads'] == 'TOTAL';
                        return DataRow(
                          color: isTotal
                              ? WidgetStateProperty.all(
                                  AppColors.goldPrimary.withValues(alpha: 0.1),
                                )
                              : null,
                          cells: [
                            cell(row['N'].toString(), isBold: isTotal),
                            cell(row['Heads'].toString(),
                                alignLeft: true, isBold: true),
                            navCell(
                              '${row['cm_R']}',
                              (row['cmRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $cmLabel',
                              isBold: isTotal,
                            ),
                            navCell(
                              '${row['pm_R']}',
                              (row['pmRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $pmLabel',
                              isBold: isTotal,
                            ),
                            navCell(
                              '${row['smly_R']}',
                              (row['smlyRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $smlyLabel',
                              isBold: isTotal,
                            ),
                            navCell(
                              '${row['yc_R']}',
                              (row['ycRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $ycLabel',
                              isBold: isTotal,
                            ),
                            navCell(
                              '${row['yp_R']}',
                              (row['ypRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $ypLabel',
                              isBold: isTotal,
                            ),
                            cell(varText(row['variation']), isBold: isTotal),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final label = DateFormat('MMMM yyyy')
                  .format(DateTime(selectedYear, selectedMonth));
              runWithPdfAuthGate(
                context,
                () => ModulePdfHelper.generateMonthlyTablePdf(
                    label, tableRows),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_rounded,
                color: Colors.white, size: 18),
            label: Text(
              'Export Table PDF',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyRegistrationTableVI(
    BuildContext context,
    List<ModuleRecord> allRecords,
    int selectedMonth,
    int selectedYear,
  ) {
    const heads = [
      'Arms Act',
      'Gambling Act',
      'Prohibition',
      'NDPS Act',
      '135 B Pact',
      '142 B Pact',
      '122 B Pact',
      'M V Act',
      'Miscellaneous',
    ];

    String getHead(ModuleRecord r) {
      final sub = (r.subCategory ?? '').toLowerCase();
      final key = r.moduleKey.toLowerCase();

      if (key != 'form_6') return 'Miscellaneous';

      if (sub.contains('arms')) return 'Arms Act';
      if (sub.contains('gambl')) return 'Gambling Act';
      if (sub.contains('prohib')) return 'Prohibition';
      if (sub.contains('ndps')) return 'NDPS Act';
      if (sub.contains('135')) return '135 B Pact';
      if (sub.contains('142')) return '142 B Pact';
      if (sub.contains('122')) return '122 B Pact';
      if (sub.contains('m v') || sub.contains('mv') || sub.contains('motor')) {
        return 'M V Act';
      }

      return 'Miscellaneous';
    }

    List<ModuleRecord> filterMonth(int m, int y) => allRecords
        .where((r) =>
            r.moduleKey == 'form_6' &&
            r.incidentDate.year == y &&
            r.incidentDate.month == m)
        .toList();

    List<ModuleRecord> filterYearToMonth(int m, int y) => allRecords
        .where((r) =>
            r.moduleKey == 'form_6' &&
            r.incidentDate.year == y &&
            r.incidentDate.month <= m)
        .toList();

    final currentMonthRecords = filterMonth(selectedMonth, selectedYear);
    final prevMonth = selectedMonth == 1 ? 12 : selectedMonth - 1;
    final prevYear = selectedMonth == 1 ? selectedYear - 1 : selectedYear;
    final previousMonthRecords = filterMonth(prevMonth, prevYear);
    final sameMonthLastYearRecords =
        filterMonth(selectedMonth, selectedYear - 1);
    final yearCurrentRecords = filterYearToMonth(selectedMonth, selectedYear);
    final yearPreviousRecords =
        filterYearToMonth(selectedMonth, selectedYear - 1);

    final tableRows = <Map<String, dynamic>>[];
    int totalcmR = 0;
    int totalpmR = 0;
    int totalsmlyR = 0;
    int totalycR = 0;
    int totalypR = 0;

    for (int i = 0; i < heads.length; i++) {
      final head = heads[i];
      List<ModuleRecord> byHead(List<ModuleRecord> list) =>
          list.where((r) => getHead(r) == head).toList();

      final cm = byHead(currentMonthRecords);
      final pm = byHead(previousMonthRecords);
      final smly = byHead(sameMonthLastYearRecords);
      final yc = byHead(yearCurrentRecords);
      final yp = byHead(yearPreviousRecords);

      final cmR = cm.length;
      final pmR = pm.length;
      final smlyR = smly.length;
      final ycR = yc.length;
      final ypR = yp.length;
      final variation = ycR - ypR;

      tableRows.add({
        'N': i + 1,
        'Heads': head,
        'cm_R': cmR,
        'pm_R': pmR,
        'smly_R': smlyR,
        'yc_R': ycR,
        'yp_R': ypR,
        'variation': variation,
        'cmRecords': cm,
        'pmRecords': pm,
        'smlyRecords': smly,
        'ycRecords': yc,
        'ypRecords': yp,
      });

      totalcmR += cmR;
      totalpmR += pmR;
      totalsmlyR += smlyR;
      totalycR += ycR;
      totalypR += ypR;
    }

    tableRows.add({
      'N': '',
      'Heads': 'TOTAL',
      'cm_R': totalcmR,
      'pm_R': totalpmR,
      'smly_R': totalsmlyR,
      'yc_R': totalycR,
      'yp_R': totalypR,
      'variation': totalycR - totalypR,
      'cmRecords': currentMonthRecords,
      'pmRecords': previousMonthRecords,
      'smlyRecords': sameMonthLastYearRecords,
      'ycRecords': yearCurrentRecords,
      'ypRecords': yearPreviousRecords,
    });

    DataColumn col(String label, {bool alignLeft = false}) => DataColumn(
          label: Text(
            label,
            textAlign: alignLeft ? TextAlign.left : TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.navyDark,
            ),
          ),
        );

    DataCell cell(String text,
            {bool alignLeft = false, bool isBold = false, Color? color}) =>
        DataCell(
          Align(
            alignment: alignLeft ? Alignment.centerLeft : Alignment.center,
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: color ??
                    (isBold ? AppColors.navyDark : AppColors.lightText),
              ),
            ),
          ),
        );

    DataCell navCell(String text, List<ModuleRecord> recs, String title,
        {bool isBold = false}) {
      return DataCell(
        InkWell(
          onTap: recs.isEmpty
              ? null
              : () {
                  Navigator.push(
                    context,
                    AppTheme.fadeSlideRoute(
                      page: ReportCaseListScreen(title: title, records: recs),
                    ),
                  );
                },
          child: Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color:
                    recs.isEmpty ? AppColors.lightSubText : AppColors.infoBlue,
                decoration: recs.isEmpty ? null : TextDecoration.underline,
              ),
            ),
          ),
        ),
      );
    }

    String mLabel(DateTime d) {
      final m = DateFormat('MMM').format(d).toUpperCase();
      return '$m\n${d.year}';
    }

    final cmLabel = mLabel(DateTime(selectedYear, selectedMonth));
    final pmLabel = mLabel(DateTime(prevYear, prevMonth));
    final smlyLabel = mLabel(DateTime(selectedYear - 1, selectedMonth));
    final ycLabel = 'Year\n$selectedYear';
    final ypLabel = 'Year\n${selectedYear - 1}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minWidth: w), // fill available width on PC
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: SizedBox(
                    width: w,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.navyMid.withValues(alpha: 0.05),
                      ),
                      dataRowMinHeight: 48,
                      dataRowMaxHeight: 48,
                      headingRowHeight: 56,
                      horizontalMargin: 12,
                      columnSpacing: 15,
                      border: TableBorder.all(
                          color: AppColors.lightBorder, width: 0.5),
                      columns: [
                        col('N'),
                        col('Heads', alignLeft: true),
                        col(cmLabel),
                        col(pmLabel),
                        col(smlyLabel),
                        col(ycLabel),
                        col(ypLabel),
                        col('var.'),
                      ],
                      rows: tableRows.map((row) {
                        final isTotal = row['Heads'] == 'TOTAL';
                        return DataRow(
                          color: isTotal
                              ? WidgetStateProperty.all(
                                  AppColors.goldPrimary.withValues(alpha: 0.1),
                                )
                              : null,
                          cells: [
                            cell(row['N'].toString(), isBold: isTotal),
                            cell(row['Heads'].toString(),
                                alignLeft: true, isBold: true),
                            navCell(
                              '${row['cm_R']}',
                              (row['cmRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $cmLabel',
                              isBold: isTotal,
                            ),
                            navCell(
                              '${row['pm_R']}',
                              (row['pmRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $pmLabel',
                              isBold: isTotal,
                            ),
                            navCell(
                              '${row['smly_R']}',
                              (row['smlyRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $smlyLabel',
                              isBold: isTotal,
                            ),
                            navCell(
                              '${row['yc_R']}',
                              (row['ycRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $ycLabel',
                              isBold: isTotal,
                            ),
                            navCell(
                              '${row['yp_R']}',
                              (row['ypRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $ypLabel',
                              isBold: isTotal,
                            ),
                            cell(
                              row['variation'].toString(),
                              isBold: isTotal,
                              color: (row['variation'] as int) > 0
                                  ? AppColors.dangerRed
                                  : ((row['variation'] as int) < 0
                                      ? AppColors.successGreen
                                      : null),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final label = DateFormat('MMMM yyyy')
                  .format(DateTime(selectedYear, selectedMonth));
              runWithPdfAuthGate(
                context,
                () => ModulePdfHelper.generateMonthlyTablePdf(
                    label, tableRows),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_rounded,
                color: Colors.white, size: 18),
            label: Text(
              'Export Table PDF',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlySummaryPhotoTable(
    BuildContext context,
    List<ModuleRecord> allRecords,
    int selectedMonth,
    int selectedYear,
  ) {
    bool isInMonth(ModuleRecord r) =>
        r.incidentDate.year == selectedYear &&
        r.incidentDate.month == selectedMonth;
    bool isInYear(ModuleRecord r) => r.incidentDate.year == selectedYear;

    bool isDetected(ModuleRecord r) =>
        r.status == 'Resolved' ||
        r.status == 'Closed' ||
        r.moduleKey == 'detected';

    List<ModuleRecord> monthRecsWhere(bool Function(ModuleRecord) test) =>
        allRecords.where((r) => isInMonth(r) && test(r)).toList();
    List<ModuleRecord> yearRecsWhere(bool Function(ModuleRecord) test) =>
        allRecords.where((r) => isInYear(r) && test(r)).toList();
    List<ModuleRecord> monthDetRecsWhere(bool Function(ModuleRecord) test) =>
        allRecords
            .where((r) => isInMonth(r) && test(r) && isDetected(r))
            .toList();
    List<ModuleRecord> yearDetRecsWhere(bool Function(ModuleRecord) test) =>
        allRecords
            .where((r) => isInYear(r) && test(r) && isDetected(r))
            .toList();

    Widget cellBox(Widget child, {int flex = 1, bool alignLeft = false}) {
      return Expanded(
        flex: flex,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightBorder, width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          alignment: alignLeft ? Alignment.centerLeft : Alignment.center,
          constraints: const BoxConstraints(minHeight: 26),
          child: child,
        ),
      );
    }

    Widget headText(String s) => Text(
          s,
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDark,
          ),
        );

    Widget labelText(String s, {bool bold = false}) => Text(
          s,
          textAlign: TextAlign.left,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 9.5,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: bold ? AppColors.navyDark : AppColors.lightText,
          ),
        );

    Widget linkText(int n, List<ModuleRecord> recs, String title,
        {bool bold = false}) {
      return InkWell(
        onTap: recs.isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  AppTheme.fadeSlideRoute(
                    page: ReportCaseListScreen(title: title, records: recs),
                  ),
                );
              },
        child: Text(
          '$n',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 9.5,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color:
                recs.isEmpty ? AppColors.lightSubText : AppColors.infoBlue,
            decoration: recs.isEmpty ? null : TextDecoration.underline,
          ),
        ),
      );
    }

    Widget rowOf(List<Widget> cells) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cells,
          ),
        );

    Widget dataRow5(String label, bool Function(ModuleRecord) test,
        {bool bold = false, String detLabel = 'Detected'}) {
      final cmReg = monthRecsWhere(test);
      final cmDet = monthDetRecsWhere(test);
      final cyReg = yearRecsWhere(test);
      final cyDet = yearDetRecsWhere(test);
      return rowOf([
        cellBox(labelText(label, bold: bold), flex: 5, alignLeft: true),
        cellBox(linkText(cmReg.length, cmReg,
            '$label • Current Month • Registered',
            bold: bold)),
        cellBox(linkText(cmDet.length, cmDet,
            '$label • Current Month • $detLabel',
            bold: bold)),
        cellBox(linkText(cyReg.length, cyReg,
            '$label • Current Year • Registered',
            bold: bold)),
        cellBox(linkText(cyDet.length, cyDet,
            '$label • Current Year • $detLabel',
            bold: bold)),
      ]);
    }

    Widget dataRow3(String label, bool Function(ModuleRecord) test,
        {bool bold = false}) {
      final cmReg = monthRecsWhere(test);
      final cyReg = yearRecsWhere(test);
      return rowOf([
        cellBox(labelText(label, bold: bold), flex: 5, alignLeft: true),
        cellBox(
            linkText(cmReg.length, cmReg,
                '$label • Current Month • Registered',
                bold: bold),
            flex: 2),
        cellBox(
            linkText(cyReg.length, cyReg,
                '$label • Current Year • Registered',
                bold: bold),
            flex: 2),
      ]);
    }

    Widget groupHeader(String label) => rowOf([
          cellBox(headText(label), flex: 5),
          cellBox(headText('Current Month'), flex: 2),
          cellBox(headText('Current Year'), flex: 2),
        ]);

    Widget groupSubHeader(String regLabel, String detLabel) => rowOf([
          cellBox(headText(''), flex: 5),
          cellBox(headText(regLabel)),
          cellBox(headText(detLabel)),
          cellBox(headText(regLabel)),
          cellBox(headText(detLabel)),
        ]);

    // Heuristic mapping (same as dashboard summary).
    bool isBnss(ModuleRecord r) =>
        r.moduleKey == 'bnss' || r.title.toLowerCase().contains('bnss');
    bool isOtherSection(ModuleRecord r) => r.moduleKey == 'it_act';
    bool isGambling(ModuleRecord r) =>
        r.moduleKey == 'coin' || r.title.toLowerCase().contains('gambl');
    bool isProhibition(ModuleRecord r) =>
        r.moduleKey == 'mpda' || r.title.toLowerCase().contains('prohibit');

    bool isAd(ModuleRecord r) => r.moduleKey == 'ad';
    bool isAccident(ModuleRecord r) => r.moduleKey == 'accident';
    bool isNc(ModuleRecord r) => r.moduleKey == 'nc';

    bool isSec186175Bnss(ModuleRecord r) => r.moduleKey == 'bnss';
    bool isSec128Bnss(ModuleRecord r) => r.moduleKey == 'bnss';
    bool isSec129Bnss(ModuleRecord r) => r.moduleKey == 'bnss';
    bool isSec93Ndps(ModuleRecord r) => r.moduleKey == 'ndps';
    bool isSec144Crpc(ModuleRecord r) =>
        r.moduleKey == 'gowans' || r.moduleKey == 'it_act';
    bool isSec55_57Police(ModuleRecord r) =>
        r.moduleKey == 'mpda' || r.moduleKey == 'coin';
    bool isCotpa(ModuleRecord r) => r.moduleKey == 'it_act';
    bool isSec122Police(ModuleRecord r) => r.moduleKey == 'mpda';
    bool isMpda(ModuleRecord r) => r.moduleKey == 'mpda';

    bool isMotorVehicleAct(ModuleRecord r) => r.moduleKey == 'traffic';
    bool isOtherMvAct(ModuleRecord r) => false;

    bool isMissingMale(ModuleRecord r) =>
        r.moduleKey == 'missing' &&
        (r.subCategory?.toLowerCase() == 'male' ||
            r.title.toLowerCase().contains('male'));
    bool isMissingFemale(ModuleRecord r) =>
        r.moduleKey == 'missing' &&
        (r.subCategory?.toLowerCase() == 'female' ||
            r.title.toLowerCase().contains('female'));
    bool isMissingTotal(ModuleRecord r) => r.moduleKey == 'missing';

    bool g1Total(ModuleRecord r) =>
        isBnss(r) || isOtherSection(r) || isGambling(r) || isProhibition(r);
    bool g1NcTotal(ModuleRecord r) =>
        isAd(r) || isAccident(r) || isNc(r);
    bool g2Total(ModuleRecord r) =>
        isSec186175Bnss(r) ||
        isSec128Bnss(r) ||
        isSec129Bnss(r) ||
        isSec93Ndps(r) ||
        isSec144Crpc(r) ||
        isSec55_57Police(r) ||
        isCotpa(r) ||
        isSec122Police(r) ||
        isMpda(r);
    bool g3Total(ModuleRecord r) => isMotorVehicleAct(r) || isOtherMvAct(r);

    final monthYearLabel =
        DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth));

    // SINGLE SOURCE OF TRUTH for the Monthly Summary table.
    // Both the on-screen table and the PDF export iterate this exact list,
    // so they cannot drift apart. Each entry kind:
    //   'h'  : group header   (label spans col 1; "Current Month" / "Current Year" span 2/2)
    //   's'  : group sub-head (empty col 1; reg/det reg/det)
    //   'd5' : 5-column data row (label + cmReg + cmDet + cyReg + cyDet)
    //   'd3' : 3-column data row (label + cmReg(span2) + cyReg(span2)) — col 3 & 5 merged
    //   'b'  : blank row separator
    final rowDefs = <Map<String, dynamic>>[
      {'k': 'h', 'l': 'Category'},
      {'k': 's', 'r': 'Registered', 'd': 'Detected'},
      {'k': 'd5', 'l': 'IPC/BNS', 't': isBnss, 'bold': true, 'dl': 'Detected'},
      {'k': 'd5', 'l': 'Section 6', 't': isOtherSection, 'dl': 'Detected'},
      {'k': 'd5', 'l': 'Gambling', 't': isGambling, 'dl': 'Detected'},
      {'k': 'd5', 'l': 'Prohibition', 't': isProhibition, 'dl': 'Detected'},
      {'k': 'd5', 'l': 'Total', 't': g1Total, 'bold': true, 'dl': 'Detected'},
      {'k': 'd5', 'l': 'AD', 't': isAd, 'dl': 'Detected'},
      {'k': 'd5', 'l': 'N.C Injury', 't': isAccident, 'dl': 'Detected'},
      {'k': 'd5', 'l': 'N.C others', 't': isNc, 'dl': 'Detected'},
      {'k': 'd5', 'l': 'N.C Total', 't': g1NcTotal, 'bold': true, 'dl': 'Detected'},
      {'k': 'b'},
      {'k': 'h', 'l': 'Preventive'},
      {'k': 'd3', 'l': 'Sec. 126, 135(2) BNSS', 't': isSec186175Bnss},
      {'k': 'd3', 'l': 'Sec. 128 BNSS', 't': isSec128Bnss},
      {'k': 'd3', 'l': 'Sec. 129 BNSS', 't': isSec129Bnss},
      {'k': 'd3', 'l': 'Sec. 93 Prohibition Act', 't': isSec93Ndps},
      {'k': 'd3', 'l': 'Sec 144(1) BNSS act', 't': isSec144Crpc},
      {'k': 'd3', 'l': 'Sec. 55-57 MAH Police act', 't': isSec55_57Police},
      {'k': 'd3', 'l': 'COTPA', 't': isCotpa},
      {'k': 'd3', 'l': 'Sec 122 MAH Police act', 't': isSec122Police},
      {'k': 'd3', 'l': 'MPDA', 't': isMpda},
      {'k': 'd3', 'l': 'Total', 't': g2Total, 'bold': true},
      {'k': 'b'},
      {'k': 'h', 'l': 'MV Act'},
      {'k': 's', 'r': 'Registered', 'd': 'Fine'},
      {'k': 'd5', 'l': 'Sec. 66/192 MV Act', 't': isMotorVehicleAct, 'dl': 'Fine'},
      {'k': 'd5', 'l': 'Other MV Act', 't': isOtherMvAct, 'dl': 'Fine'},
      {'k': 'd5', 'l': 'Total MV Act', 't': g3Total, 'bold': true, 'dl': 'Fine'},
      {'k': 'b'},
      {'k': 'h', 'l': 'Missing'},
      {'k': 's', 'r': 'Registered', 'd': 'Found'},
      {'k': 'd5', 'l': 'Male', 't': isMissingMale, 'dl': 'Found'},
      {'k': 'd5', 'l': 'Female', 't': isMissingFemale, 'dl': 'Found'},
      {'k': 'd5', 'l': 'Total missing', 't': isMissingTotal, 'bold': true, 'dl': 'Found'},
    ];

    // Renders one rowDef as a Flutter widget (on-screen).
    Widget buildScreenRow(Map<String, dynamic> r) {
      switch (r['k'] as String) {
        case 'b':
          return const SizedBox(height: 8);
        case 'h':
          return groupHeader(r['l'] as String);
        case 's':
          return groupSubHeader(r['r'] as String, r['d'] as String);
        case 'd5':
          return dataRow5(
            r['l'] as String,
            r['t'] as bool Function(ModuleRecord),
            bold: (r['bold'] as bool?) ?? false,
            detLabel: (r['dl'] as String?) ?? 'Detected',
          );
        case 'd3':
          return dataRow3(
            r['l'] as String,
            r['t'] as bool Function(ModuleRecord),
            bold: (r['bold'] as bool?) ?? false,
          );
      }
      return const SizedBox.shrink();
    }

    final tableWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rowDefs.map(buildScreenRow).toList(),
    );

    Future<void> exportPdf() async {
      final doc = pw.Document();

      pw.Widget pCellBox(String text,
          {bool bold = false, bool alignLeft = false}) {
        return pw.Container(
          padding:
              const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          alignment:
              alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
          constraints: const pw.BoxConstraints(minHeight: 11),
          child: pw.Text(
            text,
            textAlign:
                alignLeft ? pw.TextAlign.left : pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight:
                  bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        );
      }

      // A single-row pw.Table whose columnWidths sum to the same total flex
      // (9 units) for every row kind — this guarantees column boundaries
      // line up vertically across the whole table even though some rows
      // use merged (colspan) cells.
      //   d5/s : widths 5, 1, 1, 1, 1   (5-col rows: label + 4 numbers)
      //   d3/h : widths 5, 2, 2         (3-col rows: label + 2 spans)
      pw.Widget pTableRow(List<int> flexes, List<pw.Widget> cells) {
        return pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.4),
          columnWidths: {
            for (var i = 0; i < flexes.length; i++)
              i: pw.FlexColumnWidth(flexes[i].toDouble()),
          },
          children: [pw.TableRow(children: cells)],
        );
      }

      // Renders one rowDef as a pw widget (PDF). Mirrors buildScreenRow.
      pw.Widget buildPdfRow(Map<String, dynamic> r) {
        switch (r['k'] as String) {
          case 'b':
            return pw.SizedBox(height: 4);
          case 'h':
            return pTableRow([5, 2, 2], [
              pCellBox(r['l'] as String, bold: true),
              pCellBox('Current Month', bold: true),
              pCellBox('Current Year', bold: true),
            ]);
          case 's':
            return pTableRow([5, 1, 1, 1, 1], [
              pCellBox(''),
              pCellBox(r['r'] as String, bold: true),
              pCellBox(r['d'] as String, bold: true),
              pCellBox(r['r'] as String, bold: true),
              pCellBox(r['d'] as String, bold: true),
            ]);
          case 'd5':
            final test = r['t'] as bool Function(ModuleRecord);
            final bold = (r['bold'] as bool?) ?? false;
            return pTableRow([5, 1, 1, 1, 1], [
              pCellBox(r['l'] as String, bold: bold, alignLeft: true),
              pCellBox('${monthRecsWhere(test).length}', bold: bold),
              pCellBox('${monthDetRecsWhere(test).length}', bold: bold),
              pCellBox('${yearRecsWhere(test).length}', bold: bold),
              pCellBox('${yearDetRecsWhere(test).length}', bold: bold),
            ]);
          case 'd3':
            final test = r['t'] as bool Function(ModuleRecord);
            final bold = (r['bold'] as bool?) ?? false;
            return pTableRow([5, 2, 2], [
              pCellBox(r['l'] as String, bold: bold, alignLeft: true),
              pCellBox('${monthRecsWhere(test).length}', bold: bold),
              pCellBox('${yearRecsWhere(test).length}', bold: bold),
            ]);
        }
        return pw.SizedBox.shrink();
      }

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(16),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF1A2A4A),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MONTHLY SUMMARY REPORT',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      monthYearLabel,
                      style: const pw.TextStyle(
                        color: PdfColor.fromInt(0xFFFFC107),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 6),
              ...rowDefs.map(buildPdfRow),
            ],
          ),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (_) async => doc.save(),
        name: 'Monthly_Summary_${monthYearLabel.replaceAll(' ', '_')}.pdf',
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              const minW = 560.0;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: w < minW ? minW : w,
                  child: tableWidget,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => runWithPdfAuthGate(context, exportPdf),
              icon: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                'Export PDF',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dangerRed,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Local copy of the Calendar "Monthly" table builder (keeps monthly module report UI consistent
  // without depending on a private class from dashboard_screen.dart).
  Widget _buildMonthlyRegistrationTable(
    BuildContext context,
    List<ModuleRecord> allRecords,
    int selectedMonth,
    int selectedYear,
  ) {
    const heads = [
      'Murder',
      'Att to Murder',
      'Dacoity',
      'Pro Of Dacoity',
      'Total Robery',
      'Chain Robery',
      'Other Robery',
      'Total H B Ts',
      'H B Ts (Day)',
      'H B Ts (Night)',
      'Total Theft',
      'Total M VThefts',
      'SAND THEFT',
      'Chain Snaching',
      'Mobile Thefts',
      'Cattel Theft',
      'Other Thefts',
      'Extcrtion',
      'Cheating',
      'Cr Br of Trust',
      'Mischief',
      'Rioting',
      'Unlawful Assembly',
      'Attempt to suicide',
      'Hurt',
      'Kidnapping',
      'Rape',
      'Assault on Govt-',
      'Molestation (354)',
      '304 (A) I P C',
      '498 (A) I P C',
      '509 I P C',
      'Othar I P C',
      'Miscellaneous',
    ];

    String getHead(ModuleRecord r) {
      final sub = (r.subCategory ?? '').toLowerCase();
      final key = r.moduleKey.toLowerCase();

      if (key.contains('murder') || sub.contains('murder')) {
        return sub.contains('attempt') || sub.contains('att')
            ? 'Att to Murder'
            : 'Murder';
      }
      if (key.contains('dacoity') || sub.contains('dacoity')) {
        return sub.contains('preparation') || sub.contains('pro')
            ? 'Pro Of Dacoity'
            : 'Dacoity';
      }
      if (key.contains('robbery') || sub.contains('robery')) {
        if (sub.contains('chain')) return 'Chain Robery';
        return 'Total Robery';
      }
      if (key.contains('house') ||
          sub.contains('h b t') ||
          sub.contains('hbt')) {
        if (sub.contains('day')) return 'H B Ts (Day)';
        if (sub.contains('night')) return 'H B Ts (Night)';
        return 'Total H B Ts';
      }
      if (key.contains('theft') || sub.contains('theft')) {
        if (key.contains('sand') || sub.contains('sand')) return 'SAND THEFT';
        if (key.contains('two_four') ||
            sub.contains('wheeler') ||
            sub.contains('vehicle')) {
          return 'Total M VThefts';
        }
        if (sub.contains('chain')) return 'Chain Snaching';
        if (sub.contains('mobile')) return 'Mobile Thefts';
        if (sub.contains('cattle') || sub.contains('cattel')) {
          return 'Cattel Theft';
        }
        if (sub.contains('other')) return 'Other Thefts';
        return 'Total Theft';
      }
      if (key.contains('extortion') || sub.contains('extcrtion')) {
        return 'Extcrtion';
      }
      if (key.contains('cheating') || sub.contains('cheating')) {
        return 'Cheating';
      }
      if (key.contains('trust') || sub.contains('trust')) {
        return 'Cr Br of Trust';
      }
      if (key.contains('mischief') || sub.contains('mischief')) {
        return 'Mischief';
      }
      if (key.contains('rioting') || sub.contains('rioting')) return 'Rioting';
      if (key.contains('unlawful') || sub.contains('unlawful')) {
        return 'Unlawful Assembly';
      }
      if (key.contains('suicide') || sub.contains('suicide')) {
        return 'Attempt to suicide';
      }
      if (key.contains('hurt') || sub.contains('hurt')) return 'Hurt';
      if (key.contains('kidnap') || sub.contains('kidnap')) return 'Kidnapping';
      if (key.contains('rape') || sub.contains('rape')) return 'Rape';
      if (key.contains('assault') || sub.contains('assault')) {
        return 'Assault on Govt-';
      }
      if (key.contains('molest') || sub.contains('354')) {
        return 'Molestation (354)';
      }
      if (sub.contains('304') || key.contains('304')) return '304 (A) I P C';
      if (sub.contains('498') || key.contains('498')) return '498 (A) I P C';
      if (sub.contains('509') || key.contains('509')) return '509 I P C';
      if (key.contains('ipc') || sub.contains('ipc')) return 'Othar I P C';

      return 'Miscellaneous';
    }

    List<ModuleRecord> filterMonth(int m, int y) => allRecords
        .where((r) => r.incidentDate.year == y && r.incidentDate.month == m)
        .toList();

    List<ModuleRecord> filterYearToMonth(int m, int y) => allRecords
        .where((r) => r.incidentDate.year == y && r.incidentDate.month <= m)
        .toList();

    final currentMonthRecords = filterMonth(selectedMonth, selectedYear);
    final prevMonth = selectedMonth == 1 ? 12 : selectedMonth - 1;
    final prevYear = selectedMonth == 1 ? selectedYear - 1 : selectedYear;
    final previousMonthRecords = filterMonth(prevMonth, prevYear);
    final sameMonthLastYearRecords =
        filterMonth(selectedMonth, selectedYear - 1);
    final yearCurrentRecords = filterYearToMonth(selectedMonth, selectedYear);
    final yearPreviousRecords =
        filterYearToMonth(selectedMonth, selectedYear - 1);

    int detected(List<ModuleRecord> recs) =>
        recs.where((r) => r.status.toLowerCase() != 'open').length;

    final tableRows = <Map<String, dynamic>>[];
    int totalcmR = 0, totalcmD = 0;
    int totalpmR = 0, totalpmD = 0;
    int totalsmlyR = 0, totalsmlyD = 0;
    int totalycR = 0, totalycD = 0;
    int totalypR = 0, totalypD = 0;

    for (int i = 0; i < heads.length; i++) {
      final head = heads[i];
      List<ModuleRecord> byHead(List<ModuleRecord> list) =>
          list.where((r) => getHead(r) == head).toList();

      final cm = byHead(currentMonthRecords);
      final pm = byHead(previousMonthRecords);
      final smly = byHead(sameMonthLastYearRecords);
      final yc = byHead(yearCurrentRecords);
      final yp = byHead(yearPreviousRecords);

      final cmR = cm.length, cmD = detected(cm);
      final pmR = pm.length, pmD = detected(pm);
      final smlyR = smly.length, smlyD = detected(smly);
      final ycR = yc.length, ycD = detected(yc);
      final ypR = yp.length, ypD = detected(yp);
      final variation = ycR - ypR;

      tableRows.add({
        'N': i + 1,
        'Heads': head,
        'cm_R': cmR,
        'cm_D': cmD,
        'pm_R': pmR,
        'pm_D': pmD,
        'smly_R': smlyR,
        'smly_D': smlyD,
        'yc_R': ycR,
        'yc_D': ycD,
        'yp_R': ypR,
        'yp_D': ypD,
        'variation': variation,
        'cmRecords': cm,
        'pmRecords': pm,
        'smlyRecords': smly,
        'ycRecords': yc,
        'ypRecords': yp,
      });

      totalcmR += cmR;
      totalcmD += cmD;
      totalpmR += pmR;
      totalpmD += pmD;
      totalsmlyR += smlyR;
      totalsmlyD += smlyD;
      totalycR += ycR;
      totalycD += ycD;
      totalypR += ypR;
      totalypD += ypD;
    }

    tableRows.add({
      'N': '',
      'Heads': 'TOTAL',
      'cm_R': totalcmR,
      'cm_D': totalcmD,
      'pm_R': totalpmR,
      'pm_D': totalpmD,
      'smly_R': totalsmlyR,
      'smly_D': totalsmlyD,
      'yc_R': totalycR,
      'yc_D': totalycD,
      'yp_R': totalypR,
      'yp_D': totalypD,
      'variation': totalycR - totalypR,
      'cmRecords': currentMonthRecords,
      'pmRecords': previousMonthRecords,
      'smlyRecords': sameMonthLastYearRecords,
      'ycRecords': yearCurrentRecords,
      'ypRecords': yearPreviousRecords,
    });

    final cmDateLabel = DateFormat('MMMM,yyyy')
        .format(DateTime(selectedYear, selectedMonth));
    final pmDateLabel =
        DateFormat('MMMM,yyyy').format(DateTime(prevYear, prevMonth));
    final smlyDateLabel = DateFormat('MMMM,yyyy')
        .format(DateTime(selectedYear - 1, selectedMonth));
    final ycDateLabel = 'Year,$selectedYear';
    final ypDateLabel = 'Year,${selectedYear - 1}';

    final classVRowDefs = <Map<String, dynamic>>[
      {'sr': '1', 'label': 'Murder', 'head': 'Murder'},
      {'sr': '2', 'label': 'Attempt to murder', 'head': 'Att to Murder'},
      {'sr': '3', 'label': 'Dacoity', 'head': 'Dacoity'},
      {'sr': '4', 'label': 'Pro of Decoity', 'head': 'Pro Of Dacoity'},
      {'sr': '5', 'label': 'Total Robery', 'head': 'Total Robery', 'bold': true},
      {'sr': 'a', 'label': 'Chain Robery', 'head': 'Chain Robery', 'indent': 1},
      {'sr': 'b', 'label': 'Other Robery', 'head': 'Other Robery', 'indent': 1},
      {'sr': '6', 'label': 'Total H.B.Ts', 'head': 'Total H B Ts', 'bold': true},
      {'sr': 'a', 'label': 'H.B.Ts (Day)', 'head': 'H B Ts (Day)', 'indent': 1},
      {
        'sr': 'b',
        'label': 'H.B.Ts (Night)',
        'head': 'H B Ts (Night)',
        'indent': 1,
      },
      {'sr': '7', 'label': 'Total thefts', 'head': 'Total Theft', 'bold': true},
      {
        'sr': 'a',
        'label': 'Total MV Thefts',
        'head': 'Total M VThefts',
        'indent': 1,
      },
      {'sr': 'b', 'label': 'Sand Theft', 'head': 'SAND THEFT', 'indent': 1},
      {
        'sr': 'c',
        'label': 'Chain Snaching',
        'head': 'Chain Snaching',
        'indent': 1,
      },
      {'sr': 'd', 'label': 'Mobile Thefts', 'head': 'Mobile Thefts', 'indent': 1},
      {'sr': 'e', 'label': 'Cattle Thefts', 'head': 'Cattel Theft', 'indent': 1},
      {'sr': 'f', 'label': 'Other Thefts', 'head': 'Other Thefts', 'indent': 1},
      {'sr': '8', 'label': 'Extortion', 'head': 'Extcrtion'},
      {'sr': '9', 'label': 'Cheating', 'head': 'Cheating', 'bold': true},
      {'sr': '10', 'label': 'Cr Br of Trust', 'head': 'Cr Br of Trust'},
      {'sr': '11', 'label': 'Mischief', 'head': 'Mischief'},
      {'sr': '12', 'label': 'Rioting', 'head': 'Rioting'},
      {'sr': '13', 'label': 'Unlawful assembly', 'head': 'Unlawful Assembly'},
      {'sr': '14', 'label': 'Attempt to Suicide', 'head': 'Attempt to suicide'},
      {'sr': '15', 'label': 'Hurt', 'head': 'Hurt', 'bold': true},
      {'sr': '16', 'label': 'Kidnapping', 'head': 'Kidnapping', 'bold': true},
      {'sr': '17', 'label': 'Rape', 'head': 'Rape', 'bold': true},
      {
        'sr': '18',
        'label': 'Assault on Govt.',
        'head': 'Assault on Govt-',
        'bold': true,
      },
      {'sr': '19', 'label': 'Molestation (354)', 'head': 'Molestation (354)'},
      {'sr': '20', 'label': '304 (A) IPC', 'head': '304 (A) I P C'},
      {'sr': '21', 'label': '498 (A) IPC', 'head': '498 (A) I P C'},
      {'sr': '22', 'label': '509 IPC', 'head': '509 I P C'},
      {'sr': '23', 'label': 'Other IPC', 'head': 'Othar I P C'},
      {'sr': '', 'label': 'Total', 'head': 'TOTAL', 'bold': true},
    ];

    const classVBodyFontSize = 11.0;
    const classVTitleFontSize = 12.0;
    const classVTightRowHeads = <String>{
      'Murder',
      'Att to Murder',
      'Dacoity',
      'Pro Of Dacoity',
      'Total Robery',
      'Chain Robery',
      'Other Robery',
      'Total H B Ts',
      'H B Ts (Day)',
      'H B Ts (Night)',
      'Total Theft',
      'Total M VThefts',
      'SAND THEFT',
      'Chain Snaching',
      'Mobile Thefts',
      'Cattel Theft',
      'Other Thefts',
      'Extcrtion',
      'Cheating',
      'Cr Br of Trust',
      'Mischief',
      'Rioting',
      'Unlawful Assembly',
      'Attempt to suicide',
      'Hurt',
      'Kidnapping',
      'Rape',
      'Assault on Govt-',
      'Molestation (354)',
      '304 (A) I P C',
      '498 (A) I P C',
      '509 I P C',
      'Othar I P C',
    };

    EdgeInsets classVCellPad({
      required bool denseTop,
      required bool denseBottom,
      double horizontal = 3,
    }) {
      const v = 3.0; // minimal vertical padding (was 4)
      return EdgeInsets.fromLTRB(
        horizontal,
        denseTop ? 0 : v,
        horizontal,
        denseBottom ? 0 : v,
      );
    }

    Map<String, dynamic> rowFor(String head) {
      for (final r in tableRows) {
        if (r['Heads'] == head) return r;
      }
      return <String, dynamic>{};
    }

    int vInt(Map<String, dynamic> r, String k) => (r[k] as int?) ?? 0;

    // Flex layout (totals to 20 across all rows so columns align):
    // SrNo:2 | Crime:7 | Apr,2026:R(1) D(1) | Mar,2025:R(1) D(1) |
    // Apr,2025:R(1) D(1) | Year,2026:R(1) D(1) | Year,2025:R(1) D(1) | Var:1
    const flexAll = 20;
    const dataFlexes = <int>[2, 7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
    const headerGroupFlexes = <int>[2, 7, 2, 2, 2, 2, 2, 1];

    Widget rowOfFlex(List<int> flexes, List<Widget> children) {
      assert(flexes.length == children.length);
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < flexes.length; i++)
              Expanded(
                flex: flexes[i],
                child: children[i],
              ),
          ],
        ),
      );
    }

    Widget cBox({
      required Widget child,
      EdgeInsets? padding,
      AlignmentGeometry alignment = Alignment.center,
    }) {
      return Container(
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightBorder, width: 0.5),
        ),
        alignment: alignment,
        child: child,
      );
    }

    Widget cText(
      String s, {
      bool bold = false,
      bool alignLeft = false,
      double indent = 0,
      double fontSize = classVBodyFontSize,
    }) {
      return Padding(
        padding: EdgeInsets.only(left: indent),
        child: Text(
          s,
          textAlign: alignLeft ? TextAlign.left : TextAlign.center,
          softWrap: true,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.lightText,
            height: 1.15,
          ),
        ),
      );
    }

    Widget cLink(
      int n,
      List<ModuleRecord> recs,
      String title, {
      bool bold = false,
      double fontSize = classVBodyFontSize,
    }) {
      final empty = recs.isEmpty;
      return InkWell(
        onTap: empty
            ? null
            : () {
                Navigator.push(
                  context,
                  AppTheme.fadeSlideRoute(
                    page: ReportCaseListScreen(title: title, records: recs),
                  ),
                );
              },
        child: Text(
          '$n',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: empty ? AppColors.lightSubText : AppColors.infoBlue,
            decoration: empty ? null : TextDecoration.underline,
            height: 1.15,
          ),
        ),
      );
    }

    List<ModuleRecord> detRecs(List<ModuleRecord> r) =>
        r.where((x) => x.status.toLowerCase() != 'open').toList();

    Widget buildScreenDataRow(Map<String, dynamic> def) {
      final headKey = def['head'] as String;
      final inTightBlock = classVTightRowHeads.contains(headKey);
      final denseTop = inTightBlock && headKey != 'Murder';
      final denseBottom = inTightBlock && headKey != 'Othar I P C';
      final src = rowFor(headKey);
      final bold = (def['bold'] as bool?) ?? false;
      final indent = ((def['indent'] as int?) ?? 0) * 12.0;
      final cmR = vInt(src, 'cm_R');
      final cmD = vInt(src, 'cm_D');
      final pmR = vInt(src, 'pm_R');
      final pmD = vInt(src, 'pm_D');
      final smlyR = vInt(src, 'smly_R');
      final smlyD = vInt(src, 'smly_D');
      final ycR = vInt(src, 'yc_R');
      final ycD = vInt(src, 'yc_D');
      final ypR = vInt(src, 'yp_R');
      final ypD = vInt(src, 'yp_D');
      final varVal = vInt(src, 'variation');
      final cmRecs = (src['cmRecords'] as List<ModuleRecord>?) ??
          const <ModuleRecord>[];
      final pmRecs = (src['pmRecords'] as List<ModuleRecord>?) ??
          const <ModuleRecord>[];
      final smlyRecs = (src['smlyRecords'] as List<ModuleRecord>?) ??
          const <ModuleRecord>[];
      final ycRecs = (src['ycRecords'] as List<ModuleRecord>?) ??
          const <ModuleRecord>[];
      final ypRecs = (src['ypRecords'] as List<ModuleRecord>?) ??
          const <ModuleRecord>[];
      final label = def['label'] as String;
      final labelPad = classVCellPad(
        denseTop: denseTop,
        denseBottom: denseBottom,
        horizontal: 4,
      );

      return rowOfFlex(dataFlexes, [
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cText(def['sr'] as String, bold: bold),
        ),
        cBox(
          alignment: Alignment.centerLeft,
          padding: labelPad,
          child: cText(
            label,
            bold: bold,
            alignLeft: true,
            indent: indent,
          ),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(cmR, cmRecs, '$label • $cmDateLabel • R', bold: bold),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(cmD, detRecs(cmRecs),
              '$label • $cmDateLabel • D', bold: bold),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(pmR, pmRecs, '$label • $pmDateLabel • R', bold: bold),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(pmD, detRecs(pmRecs),
              '$label • $pmDateLabel • D', bold: bold),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(smlyR, smlyRecs,
              '$label • $smlyDateLabel • R', bold: bold),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(smlyD, detRecs(smlyRecs),
              '$label • $smlyDateLabel • D', bold: bold),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(ycR, ycRecs, '$label • $ycDateLabel • R', bold: bold),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(ycD, detRecs(ycRecs),
              '$label • $ycDateLabel • D', bold: bold),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(ypR, ypRecs, '$label • $ypDateLabel • R', bold: bold),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(ypD, detRecs(ypRecs),
              '$label • $ypDateLabel • D', bold: bold),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cText('$varVal', bold: bold),
        ),
      ]);
    }

    Widget buildScreenTable() {
      return LayoutBuilder(
        builder: (context, constraints) {
          final barW = constraints.hasBoundedWidth &&
                  constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: barW,
                  child: Row(
                    children: [
                      Expanded(
                        child: cBox(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          child: cText(
                            'Name of the Police Station',
                            bold: true,
                            fontSize: classVTitleFontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                rowOfFlex(headerGroupFlexes, [
                  cBox(
                      child: cText('Sr.No',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: cText('Types of Crime',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: Center(
                          child: cText(cmDateLabel,
                              bold: true, fontSize: classVBodyFontSize))),
                  cBox(
                      child: Center(
                          child: cText(pmDateLabel,
                              bold: true, fontSize: classVBodyFontSize))),
                  cBox(
                      child: Center(
                          child: cText(smlyDateLabel,
                              bold: true, fontSize: classVBodyFontSize))),
                  cBox(
                      child: Center(
                          child: cText(ycDateLabel,
                              bold: true, fontSize: classVBodyFontSize))),
                  cBox(
                      child: Center(
                          child: cText(ypDateLabel,
                              bold: true, fontSize: classVBodyFontSize))),
                  cBox(
                      child: cText('Var.',
                          bold: true, fontSize: classVBodyFontSize)),
                ]),
                rowOfFlex(dataFlexes, [
                  cBox(
                      child: cText('',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: cText('',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: cText('R',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: cText('D',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: cText('R',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: cText('D',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: cText('R',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: cText('D',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: cText('R',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: cText('D',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: cText('R',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: cText('D',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: cText('',
                          bold: true, fontSize: classVBodyFontSize)),
                ]),
                for (final def in classVRowDefs) buildScreenDataRow(def),
              ],
            ),
          );
        },
      );
    }

    // ---------- PDF builders (mirror screen exactly) ----------

    pw.Widget pCellBox(
      String text, {
      bool bold = false,
      bool alignLeft = false,
      int indentLevel = 0,
      double fontSize = 7,
    }) {
      return pw.Container(
        padding: pw.EdgeInsets.fromLTRB(
          2.0 + indentLevel * 6.0,
          2,
          2,
          2,
        ),
        alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
        child: pw.Text(
          text,
          textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );
    }

    pw.Widget pTableRow(List<int> flexes, List<pw.Widget> cells) {
      return pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.4),
        columnWidths: {
          for (var i = 0; i < flexes.length; i++)
            i: pw.FlexColumnWidth(flexes[i].toDouble()),
        },
        children: [pw.TableRow(children: cells)],
      );
    }

    pw.Widget buildPdfDataRow(Map<String, dynamic> def) {
      final src = rowFor(def['head'] as String);
      final bold = (def['bold'] as bool?) ?? false;
      final indent = (def['indent'] as int?) ?? 0;
      final cmR = vInt(src, 'cm_R');
      final cmD = vInt(src, 'cm_D');
      final pmR = vInt(src, 'pm_R');
      final pmD = vInt(src, 'pm_D');
      final smlyR = vInt(src, 'smly_R');
      final smlyD = vInt(src, 'smly_D');
      final ycR = vInt(src, 'yc_R');
      final ycD = vInt(src, 'yc_D');
      final ypR = vInt(src, 'yp_R');
      final ypD = vInt(src, 'yp_D');
      final varVal = vInt(src, 'variation');
      String s(int n) => '$n';
      return pTableRow(dataFlexes, [
        pCellBox(def['sr'] as String, bold: bold),
        pCellBox(
          def['label'] as String,
          bold: bold,
          alignLeft: true,
          indentLevel: indent,
        ),
        pCellBox(s(cmR), bold: bold),
        pCellBox(s(cmD), bold: bold),
        pCellBox(s(pmR), bold: bold),
        pCellBox(s(pmD), bold: bold),
        pCellBox(s(smlyR), bold: bold),
        pCellBox(s(smlyD), bold: bold),
        pCellBox(s(ycR), bold: bold),
        pCellBox(s(ycD), bold: bold),
        pCellBox(s(ypR), bold: bold),
        pCellBox(s(ypD), bold: bold),
        pCellBox(s(varVal), bold: bold),
      ]);
    }

    Future<void> exportPdf() async {
      final doc = pw.Document();
      final body = <pw.Widget>[
        pTableRow([flexAll], [
          pCellBox('Name of the Police Station',
              bold: true, fontSize: 9),
        ]),
        pTableRow(headerGroupFlexes, [
          pCellBox('Sr.No', bold: true),
          pCellBox('Types of Crime', bold: true),
          pCellBox(cmDateLabel, bold: true),
          pCellBox(pmDateLabel, bold: true),
          pCellBox(smlyDateLabel, bold: true),
          pCellBox(ycDateLabel, bold: true),
          pCellBox(ypDateLabel, bold: true),
          pCellBox('Var.', bold: true),
        ]),
        pTableRow(dataFlexes, [
          pCellBox('', bold: true),
          pCellBox('', bold: true),
          pCellBox('R', bold: true),
          pCellBox('D', bold: true),
          pCellBox('R', bold: true),
          pCellBox('D', bold: true),
          pCellBox('R', bold: true),
          pCellBox('D', bold: true),
          pCellBox('R', bold: true),
          pCellBox('D', bold: true),
          pCellBox('R', bold: true),
          pCellBox('D', bold: true),
          pCellBox('', bold: true),
        ]),
        for (final def in classVRowDefs) buildPdfDataRow(def),
      ];
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape.copyWith(
            marginTop: 12,
            marginBottom: 12,
            marginLeft: 14,
            marginRight: 14,
          ),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: body,
          ),
        ),
      );
      await Printing.layoutPdf(onLayout: (format) async => doc.save());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            const minW = 560.0;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: w < minW ? minW : w,
                child: buildScreenTable(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => runWithPdfAuthGate(context, exportPdf),
            icon: const Icon(Icons.picture_as_pdf_rounded,
                color: Colors.white, size: 18),
            label: Text(
              'Export Table PDF',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _reportDownloadBtn(String label, VoidCallback onTap) {
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyMid,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildReportTile(String category, int count,
      {int solvedCount = 0, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            if (onTap != null)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(category,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightText)),
                  const SizedBox(width: 6),
                  if (onTap != null)
                    Icon(Icons.open_in_new_rounded,
                        size: 13,
                        color: (AppColors.navyMid).withValues(alpha: 0.5)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Total cases badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$count Case${count == 1 ? '' : 's'}',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.goldPrimary)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text('|',
                  style: TextStyle(
                      color: Color(0xFFCCD0D5), fontWeight: FontWeight.w300)),
            ),
            // Solved badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$solvedCount Solved',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.successGreen)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyReport() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.analytics_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No cases registered this month',
                style: GoogleFonts.poppins(color: AppColors.lightSubText)),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoReportSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.infoBlue.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: AppColors.infoBlue),
          const SizedBox(width: 8),
          Text('Demo Statistics',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.infoBlue)),
        ]),
        const SizedBox(height: 8),
        Text(
            'The counts above reflect all cases registered across all modules for the current month. You can add new cases from the dashboard to see them reflected here instantly.',
            style: GoogleFonts.poppins(
                fontSize: 11, color: AppColors.lightSubText)),
      ]),
    );
  }

  Widget _buildStatsRow(
      int open, int active, int resolved, int closed, int total) {
    if (widget.moduleKey == 'detected' || widget.moduleKey == 'undetected') {
      final provider = _watchProvider(context);
      final allRecs = provider.getFilteredRecords(widget.subCategory);
      final disposalCount = allRecs
          .where((r) =>
              r.status == 'Disposal' ||
              r.status == 'Closed' ||
              r.status == 'Resolved')
          .length;
      final pendingCount = allRecs.length - disposalCount;
      final totalCaseCount = allRecs.length;

      return Row(
        children: [
          _statCard('Total Case', totalCaseCount, AppColors.infoBlue, 'All'),
          const SizedBox(width: 8),
          _statCard('Pending', pendingCount, AppColors.warningOrange, 'Pending'),
          const SizedBox(width: 8),
          _statCard('Disposal', disposalCount, AppColors.successGreen, 'Disposal'),
        ],
      );
    }

    return Column(
      children: [
        if (!widget.readOnly) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openNewEntryForm(context),
                    icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    label: Text(
                      '+ Add New ${widget.moduleLabel} Case',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyDark,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const StadiumBorder(),
                      elevation: 3,
                      shadowColor: AppColors.navyDark.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        Row(children: [
          _statCard('Total', total, AppColors.infoBlue, 'All'),
          const SizedBox(width: 8),
          _statCard('Open', open, AppColors.warningOrange, 'Open'),
          const SizedBox(width: 8),
          _statCard('Active', active, AppColors.goldPrimary, 'Active'),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _statCard('Resolved', resolved, AppColors.successGreen, 'Resolved'),
          const SizedBox(width: 8),
          _statCard('Closed', closed, const Color(0xFF607D8B), 'Closed'),
          const SizedBox(width: 8),
          Expanded(child: const SizedBox()),
        ]),
      ],
    );
  }

  Widget _statCard(String label, int value, Color color, String filterKey) {
    final isSelected = _filter == filterKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = filterKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.22)
                : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected ? color : color.withValues(alpha: 0.3),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$value',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected) ...[
                    Icon(Icons.check_circle_rounded, size: 10, color: color),
                    const SizedBox(width: 3),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? AppColors.navyDark : AppColors.lightSubText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.navyMid.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_special_rounded,
                size: 40,
                color: AppColors.navyMid,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No ${widget.moduleLabel} records yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No registered entries found in this category.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.lightSubText,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext ctx, ModuleRecord record) {
    if (widget.readOnly) {
      return ReadOnlyModuleRecordHubCard(record: record);
    }
    final isDetailFormHistory =
        record.subCategory == 'Crime Detail Form' ||
        record.subCategory == 'Property & Seizure Form';
    if (isDetailFormHistory) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.lightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      record.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 13, color: AppColors.lightSubText),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(record.incidentDate),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.lightSubText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time_rounded,
                            size: 13, color: AppColors.lightSubText),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('hh:mm a').format(record.createdAt),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.lightSubText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: AppColors.lightBorder),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _actionBtn(
                      Icons.visibility_rounded,
                      'View',
                      AppColors.goldPrimary,
                      () {
                        Navigator.push(
                          ctx,
                          AppTheme.fadeSlideRoute(
                            page: CommonFormScreen(
                              moduleLabel: record.firestoreCategoryDisplayName,
                              moduleKey: widget.moduleKey,
                              subCategory: record.subCategory,
                              existingRecord: record,
                              readOnly: true,
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppColors.lightBorder,
                    ),
                    _actionBtn(
                      Icons.picture_as_pdf_rounded,
                      'PDF',
                      AppColors.dangerRed,
                      () {
                        runWithPdfAuthGate(
                          ctx,
                          () => ModulePdfHelper.generatePdf(record),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    final isDetectedCard =
        widget.moduleKey == 'detected' || record.moduleKey == 'detected' ||
        widget.moduleKey == 'undetected' || record.moduleKey == 'undetected';
    final String displayStatus;
    final Color sc;
    if (isDetectedCard) {
      final isDisposal = record.status == 'Disposal' ||
          record.status == 'Closed' ||
          record.status == 'Resolved';
      displayStatus = isDisposal ? 'Disposal' : 'Pending';
      sc = isDisposal ? AppColors.successGreen : AppColors.warningOrange;
    } else {
      displayStatus = record.status;
      sc = _statusColor(record.status);
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: isDetectedCard
              ? BoxDecoration(
                  color: AppColors.navyDark.withValues(alpha: 0.06),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.lg)),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.infoBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(record.caseNumber,
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.infoBlue)),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sc.withValues(alpha: 0.3)),
                  ),
                  child: Text(displayStatus,
                      style: GoogleFonts.poppins(
                          fontSize: 9, fontWeight: FontWeight.w700, color: sc)),
                ),
              ]),
              const SizedBox(height: 10),
              Text(record.title,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyDark)),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  record.firestoreCategoryDisplayName,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (record.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(record.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.lightSubText)),
              ],
              const SizedBox(height: 10),
              Row(children: [
                Icon(Icons.person_rounded,
                    size: 13, color: AppColors.lightSubText),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(record.assignedOfficer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.lightSubText)),
                ),
                Icon(Icons.calendar_today_rounded,
                    size: 13, color: AppColors.lightSubText),
                const SizedBox(width: 4),
                Text(DateFormat('dd MMM yyyy').format(record.incidentDate),
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.lightSubText)),
              ]),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.lightBorder),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                      _actionBtn(
                          Icons.edit_note_rounded, 'Edit', AppColors.infoBlue,
                          () {
                        if (widget.moduleKey == 'ad') {
                          Navigator.push(
                            ctx,
                            AppTheme.fadeSlideRoute(
                              page: ADFormScreen(existingRecord: record),
                            ),
                          );
                          return;
                        }
                        if (widget.moduleKey == 'nc') {
                          Navigator.push(
                            ctx,
                            AppTheme.fadeSlideRoute(
                              page: NcFormScreen(
                                moduleLabel:
                                    record.firestoreCategoryDisplayName,
                                subCategory: widget.subCategory,
                                existingRecord: record,
                              ),
                            ),
                          );
                          return;
                        }
                        if (widget.moduleKey == 'missing') {
                          Navigator.push(
                            ctx,
                            AppTheme.fadeSlideRoute(
                              page: MissingFormScreen(
                                moduleLabel:
                                    record.firestoreCategoryDisplayName,
                                subCategory: widget.subCategory,
                                existingRecord: record,
                              ),
                            ),
                          );
                          return;
                        }
                        final page = moduleUsesCommonCrimeForm(widget.moduleKey)
                            ? CommonFormScreen(
                                moduleLabel: record.firestoreCategoryDisplayName,
                                moduleKey: widget.moduleKey,
                                subCategory: record.subCategory,
                                existingRecord: record,
                              )
                            : ModuleFormScreen(
                                moduleLabel: record.firestoreCategoryDisplayName,
                                moduleKey: widget.moduleKey,
                                subCategory: record.subCategory,
                                existingRecord: record,
                              );
                        Navigator.push(
                            ctx,
                            AppTheme.fadeSlideRoute(page: page));
                      }),
                      Container(
                          width: 1, height: 24, color: AppColors.lightBorder),
                      _actionBtn(Icons.picture_as_pdf_rounded, 'PDF',
                          AppColors.dangerRed, () {
                        ModulePdfHelper.generatePdf(record);
                      }),
                      Container(
                          width: 1, height: 24, color: AppColors.lightBorder),
                      _actionBtn(Icons.visibility_rounded, 'View',
                          AppColors.goldPrimary, () {
                        Navigator.push(
                            ctx,
                            AppTheme.fadeSlideRoute(
                              page: widget.moduleKey == 'ad'
                                  ? AdRecordDetailScreen(
                                      record: record,
                                    )
                                  : ModuleRecordDetailScreen(
                                      record: record,
                                    ),
                            ));
                      }),
                      Container(
                          width: 1, height: 24, color: AppColors.lightBorder),
                      _actionBtn(Icons.delete_outline_rounded, 'Delete',
                          AppColors.warningOrange, () {
                        _confirmDelete(ctx, record);
                      }),
                    ]),
        ),
      ]),
    );
  }

  Widget _actionBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 10, fontWeight: FontWeight.w600, color: color)),
            ),
          ]),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, ModuleRecord record) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Delete Record',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: AppColors.dangerRed)),
        content: Text('Delete "${record.title}"? This cannot be undone.',
            style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _readProvider(ctx).deleteRecord(record.id);
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text('Record deleted', style: GoogleFonts.poppins()),
                  backgroundColor: AppColors.successGreen,
                ));
              } catch (e) {
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text('Failed to delete record: $e',
                      style: GoogleFonts.poppins()),
                  backgroundColor: AppColors.dangerRed,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: Text('Delete',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return AppColors.warningOrange;
      case 'Active':
        return AppColors.infoBlue;
      case 'Resolved':
        return AppColors.successGreen;
      case 'Closed':
        return const Color(0xFF607D8B);
      default:
        return AppColors.lightSubText;
    }
  }
}
