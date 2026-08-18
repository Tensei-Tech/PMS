// lib/providers/module_registry.dart

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../providers/auth_provider.dart';
import '../modules/core/providers/base_module_provider.dart';
import '../utils/case_visibility.dart';
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

// ── Helper macro — wires AuthProvider → any BaseModuleProvider subclass ──────
ChangeNotifierProxyProvider<AuthProvider, T> _wired<T extends BaseModuleProvider>(
  T Function() create,
) {
  return ChangeNotifierProxyProvider<AuthProvider, T>(
    create: (_) => create(),
    update: (_, auth, provider) {
      provider!.setStationContext(
        stationId: auth.activeStation,
        uid: auth.uid,
        visibilityMode: CaseVisibility.resolveFor(auth),
      );
      return provider;
    },
  );
}

List<SingleChildWidget> moduleProviders = [
  _wired<FormIVProvider>(() => FormIVProvider()),
  _wired<FormVIProvider>(() => FormVIProvider()),
  _wired<NcProvider>(() => NcProvider()),
  _wired<PreventiveProvider>(() => PreventiveProvider()),
  _wired<AdProvider>(() => AdProvider()),
  _wired<MissingProvider>(() => MissingProvider()),
  _wired<KidnappingProvider>(() => KidnappingProvider()),
  _wired<TheftProvider>(() => TheftProvider()),
  _wired<SandTheftProvider>(() => SandTheftProvider()),
  _wired<HurtProvider>(() => HurtProvider()),
  _wired<PocsoProvider>(() => PocsoProvider()),
  _wired<PassportProvider>(() => PassportProvider()),
  _wired<MonthlyProvider>(() => MonthlyProvider()),
  _wired<PendingProvider>(() => PendingProvider()),
  _wired<DetectedProvider>(() => DetectedProvider()),
  _wired<UndetectedProvider>(() => UndetectedProvider()),
  _wired<DisposalProvider>(() => DisposalProvider()),
  _wired<TwoFourWheelerProvider>(() => TwoFourWheelerProvider()),
  _wired<ArrestedProvider>(() => ArrestedProvider()),
  _wired<AbscondedProvider>(() => AbscondedProvider()),
  _wired<CrimeWomenProvider>(() => CrimeWomenProvider()),
  _wired<JuvenileProvider>(() => JuvenileProvider()),
  _wired<VictimProvider>(() => VictimProvider()),
  _wired<AccidentProvider>(() => AccidentProvider()),
  _wired<TrafficProvider>(() => TrafficProvider()),
  _wired<ApplicationProvider>(() => ApplicationProvider()),
  _wired<SamWarrantProvider>(() => SamWarrantProvider()),
  _wired<MuddemalProvider>(() => MuddemalProvider()),
  _wired<BnssProvider>(() => BnssProvider()),
  _wired<NdpsProvider>(() => NdpsProvider()),
  _wired<GowansProvider>(() => GowansProvider()),
  _wired<ItActProvider>(() => ItActProvider()),
  _wired<McocaProvider>(() => McocaProvider()),
  _wired<UapaProvider>(() => UapaProvider()),
  _wired<MpdaProvider>(() => MpdaProvider()),
  _wired<CoinProvider>(() => CoinProvider()),
];

// ── rest unchanged ─────────────────────────────────────────────────────────

const Map<String, String> labelToModuleKey = {
  'Form I-V'    : 'form_1_5',
  'Form VI'     : 'form_6',
  'NC'          : 'nc',
  'Preventive'  : 'preventive',
  'AD'          : 'ad',
  'Missing'     : 'missing',
  'Kidnapping'  : 'kidnapping',
  'Theft'       : 'theft',
  'Sand Theft'  : 'sand_theft',
  'Hurt'        : 'hurt',
  'POCSO'       : 'pocso',
  'Passport/PVR': 'passport',
  'Monthly'     : 'monthly',
  'Pending'     : 'pending',
  'Detected'    : 'detected',
  'Undetected'  : 'undetected',
  'Disposal'    : 'disposal',
  'I to V'      : 'form_1_5',
  'Forms'       : 'form_1_5',
  'VI'          : 'form_6',
  'A.D'         : 'ad',
  'Two/Four Wheeler Stolen' : 'two_four_wheeler',
  'Kid'         : 'kidnapping',
  'N.C'         : 'nc',
  'Arrested'    : 'arrested',
  'Absconded'   : 'absconded',
  'Crime against Women' : 'crime_women',
  'Juvenile'    : 'juvenile',
  'Victim'      : 'victim',
  'Accident'    : 'accident',
  'Traffic'     : 'traffic',
  'Application' : 'application',
  'Sam (Summons) / Warrant' : 'sam_warrant',
  'Muddemal'    : 'muddemal',
  'Section 186/175/BNSS' : 'bnss',
  'Passport /PVR / License' : 'passport',
  'NDPS'        : 'ndps',
  'Gowans'      : 'gowans',
  'IT Act'      : 'it_act',
  'MCOCA'       : 'mcoca',
  'UAPA'        : 'uapa',
  'MPDA'        : 'mpda',
  'COIN'        : 'coin',
};

final List<Type> allDataProviders = [
  FormIVProvider, FormVIProvider, NcProvider, PreventiveProvider,
  AdProvider, MissingProvider, KidnappingProvider, TheftProvider,
  SandTheftProvider, HurtProvider, PocsoProvider, PassportProvider,
  TwoFourWheelerProvider, ArrestedProvider, AbscondedProvider,
  CrimeWomenProvider, JuvenileProvider, VictimProvider, AccidentProvider,
  TrafficProvider, ApplicationProvider, SamWarrantProvider, MuddemalProvider,
  BnssProvider, NdpsProvider, GowansProvider, ItActProvider, McocaProvider,
  UapaProvider, MpdaProvider, CoinProvider,
];

BaseModuleProvider getProvider(BuildContext context, String label) {
  final key = labelToModuleKey[label];
  if (key == null) return context.read<NcProvider>();
  switch (key) {
    case 'form_1_5':     return context.read<FormIVProvider>();
    case 'form_6':       return context.read<FormVIProvider>();
    case 'nc':           return context.read<NcProvider>();
    case 'preventive':   return context.read<PreventiveProvider>();
    case 'ad':           return context.read<AdProvider>();
    case 'missing':      return context.read<MissingProvider>();
    case 'kidnapping':   return context.read<KidnappingProvider>();
    case 'theft':        return context.read<TheftProvider>();
    case 'sand_theft':   return context.read<SandTheftProvider>();
    case 'hurt':         return context.read<HurtProvider>();
    case 'pocso':        return context.read<PocsoProvider>();
    case 'passport':     return context.read<PassportProvider>();
    case 'monthly':      return context.read<MonthlyProvider>();
    case 'pending':      return context.read<PendingProvider>();
    case 'detected':     return context.read<DetectedProvider>();
    case 'undetected':   return context.read<UndetectedProvider>();
    case 'disposal':     return context.read<DisposalProvider>();
    case 'two_four_wheeler': return context.read<TwoFourWheelerProvider>();
    case 'arrested':     return context.read<ArrestedProvider>();
    case 'absconded':    return context.read<AbscondedProvider>();
    case 'crime_women':  return context.read<CrimeWomenProvider>();
    case 'juvenile':     return context.read<JuvenileProvider>();
    case 'victim':       return context.read<VictimProvider>();
    case 'accident':     return context.read<AccidentProvider>();
    case 'traffic':      return context.read<TrafficProvider>();
    case 'application':  return context.read<ApplicationProvider>();
    case 'sam_warrant':  return context.read<SamWarrantProvider>();
    case 'muddemal':     return context.read<MuddemalProvider>();
    case 'bnss':         return context.read<BnssProvider>();
    case 'ndps':         return context.read<NdpsProvider>();
    case 'gowans':       return context.read<GowansProvider>();
    case 'it_act':       return context.read<ItActProvider>();
    case 'mcoca':        return context.read<McocaProvider>();
    case 'uapa':         return context.read<UapaProvider>();
    case 'mpda':         return context.read<MpdaProvider>();
    case 'coin':         return context.read<CoinProvider>();
    default:             return context.read<NcProvider>();
  }
}

List<BaseModuleProvider> getModuleProviders(BuildContext context) {
  return [
    context.read<FormIVProvider>(),
    context.read<FormVIProvider>(),
    context.read<NcProvider>(),
    context.read<PreventiveProvider>(),
    context.read<AdProvider>(),
    context.read<MissingProvider>(),
    context.read<KidnappingProvider>(),
    context.read<TheftProvider>(),
    context.read<SandTheftProvider>(),
    context.read<HurtProvider>(),
    context.read<PocsoProvider>(),
    context.read<PassportProvider>(),
    context.read<MonthlyProvider>(),
    context.read<PendingProvider>(),
    context.read<DetectedProvider>(),
    context.read<UndetectedProvider>(),
    context.read<DisposalProvider>(),
    context.read<TwoFourWheelerProvider>(),
    context.read<ArrestedProvider>(),
    context.read<AbscondedProvider>(),
    context.read<CrimeWomenProvider>(),
    context.read<JuvenileProvider>(),
    context.read<VictimProvider>(),
    context.read<AccidentProvider>(),
    context.read<TrafficProvider>(),
    context.read<ApplicationProvider>(),
    context.read<SamWarrantProvider>(),
    context.read<MuddemalProvider>(),
    context.read<BnssProvider>(),
    context.read<NdpsProvider>(),
    context.read<GowansProvider>(),
    context.read<ItActProvider>(),
    context.read<McocaProvider>(),
    context.read<UapaProvider>(),
    context.read<MpdaProvider>(),
    context.read<CoinProvider>(),
  ];
}