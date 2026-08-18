// lib/screens/pending_io_wise_all_categories_screen.dart
// Pending Cases — IO Wise across all dashboard categories (consolidated providers).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../modules/core/models/base_record.dart';
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
import '../theme/app_theme.dart';
import '../utils/pending_io_wise_logic.dart';
import '../widgets/read_only_module_record_hub_card.dart';

/// Mirrors `pending_io_wise_screens.dart` — same provider merge (see
/// PendingIoWiseByCategoryScreen).
List<ModuleRecord> _watchConsolidatedRecords(BuildContext context) {
  final records = <ModuleRecord>[];
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
  return records.where((r) => r.moduleKey != 'nc').toList();
}

class PendingIoWiseAllCategoriesScreen extends StatelessWidget {
  const PendingIoWiseAllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final consolidated = _watchConsolidatedRecords(context);
    final filtered = consolidated
        .where(pendingIoWiseEligibleAnyDashboardCategory)
        .toList();

    final buckets = <String, List<ModuleRecord>>{};
    for (final r in filtered) {
      final io = pendingIoWiseIoDisplayName(r)!;
      buckets.putIfAbsent(io, () => []).add(r);
    }

    final names = buckets.keys.toList()..sort((a, b) => a.compareTo(b));

    const title = 'IO Wise Pending — All Categories';

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
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: names.isEmpty
                  ? Center(
                      child: Text(
                        'No IO Wise pending cases',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightSubText,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemCount: names.length,
                      itemBuilder: (_, i) {
                        final io = names[i];
                        final count = buckets[io]!.length;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  AppTheme.fadeSlideRoute(
                                    page:
                                        PendingIoWiseAllCategoriesDetailScreen(
                                      ioDisplayName: io,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: AppColors.lightBorder),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'IO Name: $io',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.navyDark,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Cases: $count',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.navyMid,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class PendingIoWiseAllCategoriesDetailScreen extends StatelessWidget {
  const PendingIoWiseAllCategoriesDetailScreen({
    super.key,
    required this.ioDisplayName,
  });

  final String ioDisplayName;

  @override
  Widget build(BuildContext context) {
    final consolidated = _watchConsolidatedRecords(context);
    final mine = consolidated
        .where(
          (r) =>
              pendingIoWiseEligibleAnyDashboardCategory(r) &&
              pendingIoWiseIoDisplayName(r) == ioDisplayName,
        )
        .toList();

    mine.sort((a, b) => b.incidentDate.compareTo(a.incidentDate));

    final title = '$ioDisplayName — All categories';

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
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: mine.isEmpty
                  ? Center(
                      child: Text(
                        'No cases match this officer',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightSubText,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg, 0, AppSpacing.lg, 24),
                      itemCount: mine.length,
                      itemBuilder: (_, i) =>
                          ReadOnlyModuleRecordHubCard(record: mine[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
