// lib/screens/common_form_screen.dart
// Full-screen wrapper for [CommonForm]: saves a [ModuleRecord] with payload under
// [kCommonFormExtraFieldsKey] plus summary columns for list/search.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../modules/core/models/base_record.dart';
import '../modules/core/providers/base_module_provider.dart';
import '../modules/absconded/providers/absconded_provider.dart';
import '../modules/accident/providers/accident_provider.dart';
import '../modules/application/providers/application_provider.dart';
import '../modules/arrested/providers/arrested_provider.dart';
import '../modules/bnss/providers/bnss_provider.dart';
import '../modules/coin/providers/coin_provider.dart';
import '../modules/crime_women/providers/crime_women_provider.dart';
import '../modules/detected/providers/detected_provider.dart';
import '../modules/disposal/providers/disposal_provider.dart';
import '../modules/form_iv/providers/form_iv_provider.dart';
import '../modules/form_vi/providers/form_vi_provider.dart';
import '../modules/gowans/providers/gowans_provider.dart';
import '../modules/hurt/providers/hurt_provider.dart';
import '../modules/it_act/providers/it_act_provider.dart';
import '../modules/juvenile/providers/juvenile_provider.dart';
import '../modules/kidnapping/providers/kidnapping_provider.dart';
import '../modules/kidnapping/widgets/kidnapping_extra_fields.dart';
import '../modules/mcoca/providers/mcoca_provider.dart';
import '../modules/missing/providers/missing_provider.dart';
import '../modules/monthly/providers/monthly_provider.dart';
import '../modules/mpda/providers/mpda_provider.dart';
import '../modules/muddemal/providers/muddemal_provider.dart';
import '../modules/ndps/providers/ndps_provider.dart';
import '../modules/nc/providers/nc_provider.dart';
import '../modules/passport/providers/passport_provider.dart';
import '../modules/pending/providers/pending_provider.dart';
import '../modules/pocso/providers/pocso_provider.dart';
import '../modules/preventive/providers/preventive_provider.dart';
import '../modules/sam_warrant/providers/sam_warrant_provider.dart';
import '../modules/sand_theft/providers/sand_theft_provider.dart';
import '../modules/theft/providers/theft_provider.dart';
import '../modules/traffic/providers/traffic_provider.dart';
import '../modules/two_four_wheeler/providers/two_four_wheeler_provider.dart';
import '../modules/uapa/providers/uapa_provider.dart';
import '../modules/undetected/providers/undetected_provider.dart';
import '../modules/victim/providers/victim_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/common_form_module.dart';
import '../utils/common_form_pdf.dart';
import '../utils/crime_detail_pdf.dart';
import '../utils/property_seizure_pdf.dart';
import '../utils/crimespot_seizure_pdf.dart';
import '../utils/form_e_pdf.dart';
import '../utils/arrest_surrender_pdf.dart';
import '../utils/inquest_panchanama_pdf.dart';
import '../utils/accused_memorandum_pdf.dart';
import '../utils/final_report_pdf.dart';
import '../utils/house_property_search_seizure_pdf.dart';
import '../utils/ab_form_pdf.dart';
import '../utils/medical_376_form_pdf.dart';
import '../utils/interrogation_form_pdf.dart';
import '../utils/draft_ground_of_arrest_pdf.dart';
import '../utils/ground_of_arrest_pdf.dart';
import '../utils/reason_of_arrest_pdf.dart';
import '../utils/transit_remand_pdf.dart';
import '../utils/pdf_auth_gate.dart';
import '../widgets/common_form/common_form.dart'
    show CommonForm, CommonFormState, commonFormDocumentMapFromState;
import '../widgets/crime_detail_form_view.dart';
import '../widgets/property_seizure_form_view.dart';
import '../widgets/crimespot_seizure_form_view.dart';
import '../widgets/form_e_view.dart';
import '../widgets/arrest_surrender_form_view.dart';
import '../widgets/inquest_panchanama_form_view.dart';
import '../widgets/accused_memorandum_form_view.dart';
import '../widgets/final_report_form_view.dart';
import '../widgets/house_property_search_seizure_form_view.dart';
import '../widgets/ab_form_view.dart';
import '../widgets/medical_376_form_view.dart';
import '../widgets/interrogation_form_view.dart';
import '../widgets/draft_ground_of_arrest_form_view.dart';
import '../widgets/ground_of_arrest_form_view.dart';
import '../widgets/reason_of_arrest_form_view.dart';
import '../widgets/transit_remand_form_view.dart';
import 'bnss_dedicated_forms.dart';
import 'module_hub_screen.dart';

class CommonFormScreen extends StatefulWidget {
  final String moduleLabel;
  final String moduleKey;
  final String? subCategory;
  /// Nested accordion section (e.g. "Form 2-A — Case & Occurrence").
  final String? formSection;
  /// Reference page range from `pending_forms_split` (e.g. "Pages 1–4").
  final String? pageRange;
  final ModuleRecord? existingRecord;
  final bool? readOnly;

  const CommonFormScreen({
    super.key,
    required this.moduleLabel,
    required this.moduleKey,
    this.subCategory,
    this.formSection,
    this.pageRange,
    this.existingRecord,
    this.readOnly = false,
  });

  @override
  State<CommonFormScreen> createState() => _CommonFormScreenState();
}

class _CommonFormScreenState extends State<CommonFormScreen> {
  final GlobalKey<CommonFormState> _formKey = GlobalKey<CommonFormState>();
  final GlobalKey<CrimeDetailFormViewState> _crimeDetailKey = GlobalKey<CrimeDetailFormViewState>();
  final GlobalKey<PropertySeizureFormViewState> _propertySeizureKey = GlobalKey<PropertySeizureFormViewState>();
  final GlobalKey<CrimespotSeizureFormViewState> _crimespotSeizureKey = GlobalKey<CrimespotSeizureFormViewState>();
  final GlobalKey<FormEViewState> _formEKey = GlobalKey<FormEViewState>();
  final GlobalKey<ArrestSurrenderFormViewState> _arrestSurrenderKey = GlobalKey<ArrestSurrenderFormViewState>();
  final GlobalKey<InquestPanchanamaFormViewState> _inquestPanchanamaKey = GlobalKey<InquestPanchanamaFormViewState>();
  final GlobalKey<AccusedMemorandumFormViewState> _accusedMemorandumKey = GlobalKey<AccusedMemorandumFormViewState>();
  final GlobalKey<FinalReportFormViewState> _finalReportKey = GlobalKey<FinalReportFormViewState>();
  final GlobalKey<HousePropertySearchSeizureFormViewState> _housePropertySearchSeizureKey =
      GlobalKey<HousePropertySearchSeizureFormViewState>();
  final GlobalKey<AbFormViewState> _abFormKey = GlobalKey<AbFormViewState>();
  final GlobalKey<Medical376FormViewState> _medical376Key =
      GlobalKey<Medical376FormViewState>();
  final GlobalKey<InterrogationFormViewState> _interrogationKey =
      GlobalKey<InterrogationFormViewState>();
  final GlobalKey<DraftGroundOfArrestFormViewState> _draftGroundOfArrestKey =
      GlobalKey<DraftGroundOfArrestFormViewState>();
  final GlobalKey<GroundOfArrestFormViewState> _groundOfArrestKey =
      GlobalKey<GroundOfArrestFormViewState>();
  final GlobalKey<ReasonOfArrestFormViewState> _reasonOfArrestKey =
      GlobalKey<ReasonOfArrestFormViewState>();
  final GlobalKey<TransitRemandFormViewState> _transitRemandKey =
      GlobalKey<TransitRemandFormViewState>();
  final GlobalKey<KidnappingExtraFieldsState> _kidnappingKey =
      GlobalKey<KidnappingExtraFieldsState>();

  bool get _isEdit => widget.existingRecord != null;
  bool get _isAbForm => widget.subCategory == 'AB Form';
  bool get _is376MedicalForm => widget.subCategory == '376 Medical Form';
  bool get _isInterrogationForm => widget.subCategory == 'Interrogation Form';
  bool get _isDraftGroundOfArrestForm =>
      widget.subCategory == 'Draft Ground of Arrest';
  bool get _isGroundOfArrestForm => widget.subCategory == 'Ground of Arrest';
  bool get _isReasonOfArrestForm =>
      widget.subCategory == 'Reason of Arrest Form';
  bool get _isTransitRemandForm => widget.subCategory == 'Transit Remand';
  bool get _isBnssDedicatedForm => BnssDedicatedForms.isDedicated(widget.subCategory);
  bool get _isCrimeDetailForm => widget.subCategory == 'Crime Detail Form';
  bool get _isPropertySeizureForm => widget.subCategory == 'Property & Seizure Form';
  bool get _isCrimespotSeizureForm => widget.subCategory == 'Crimespot Seizure Panchanama';
  bool get _isFormE => widget.subCategory == 'Form E';
  bool get _isArrestSurrenderForm => widget.subCategory == 'Arrest/Court Surrender Form';
  bool get _isInquestPanchanamaForm => widget.subCategory == 'Inquest Panchanama';
  bool get _isAccusedMemorandumForm => widget.subCategory == 'Accused Memorandum Form';
  bool get _isFinalReportForm => widget.subCategory == 'Final Report Form';
  bool get _isHousePropertySearchSeizureForm =>
      widget.subCategory == 'House/Property Search & Seizure';
  bool get _hasKidnappingExtras {
    final key = widget.moduleKey.trim().toLowerCase();
    final sub = (widget.subCategory ?? '').trim().toLowerCase();
    final label = widget.moduleLabel.trim().toLowerCase();
    return key == 'kidnapping' ||
        key == 'kid' ||
        key.contains('kidnap') ||
        sub.contains('kidnap') ||
        label.contains('kidnap');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final provider = _getProvider(context);
      if (auth.stationName.isNotEmpty) {
        provider.setStationId(auth.stationName, createdBy: auth.uid);
      }

      final existing = widget.existingRecord;
      if (_isCrimeDetailForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _crimeDetailKey.currentState?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_isPropertySeizureForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _propertySeizureKey.currentState?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_isCrimespotSeizureForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _crimespotSeizureKey.currentState?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_isFormE) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _formEKey.currentState?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_isArrestSurrenderForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _arrestSurrenderKey.currentState?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_isInquestPanchanamaForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _inquestPanchanamaKey.currentState?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_isAccusedMemorandumForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _accusedMemorandumKey.currentState?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_isFinalReportForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _finalReportKey.currentState?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_isHousePropertySearchSeizureForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _housePropertySearchSeizureKey.currentState
                ?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_isAbForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _abFormKey.currentState?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_is376MedicalForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _medical376Key.currentState?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_isInterrogationForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _interrogationKey.currentState?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_isDraftGroundOfArrestForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _draftGroundOfArrestKey.currentState
                ?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_isGroundOfArrestForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _groundOfArrestKey.currentState
                ?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_isReasonOfArrestForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _reasonOfArrestKey.currentState
                ?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_isTransitRemandForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            _transitRemandKey.currentState
                ?.hydrateFrom(Map<String, dynamic>.from(nested));
          }
        }
      } else if (_isBnssDedicatedForm) {
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            BnssDedicatedForms.hydrate(
              widget.subCategory,
              Map<String, dynamic>.from(nested),
            );
          }
        }
      } else {
        final form = _formKey.currentState;
        if (form == null) return;
        if (existing != null) {
          final nested = existing.extraFields[kCommonFormExtraFieldsKey];
          if (nested is Map) {
            form.hydrateFromDocumentMap(Map<String, dynamic>.from(nested));
          } else {
            form.hydrateFromModuleRecordBasics(existing);
          }
        }
        if (_hasKidnappingExtras && existing != null) {
          final kRaw = existing.extraFields['kidnapping_extra'];
          if (kRaw is Map) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _kidnappingKey.currentState?.hydrateFrom(
                Map<String, dynamic>.from(kRaw),
              );
            });
          }
        }
      }
    });
  }

  BaseModuleProvider _getProvider(BuildContext context) {
    switch (widget.moduleKey) {
      case 'form_1_5':
        return context.read<FormIVProvider>();
      case 'form_6':
        return context.read<FormVIProvider>();
      case 'nc':
        return context.read<NcProvider>();
      case 'preventive':
        return context.read<PreventiveProvider>();
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

  DateTime _parseRegDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return DateTime.now();
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

  String _accusedSummary(Map<String, dynamic> doc) {
    if (doc['isUnknownUntraced'] == true) return 'Unknown / Untraced';
    final list = doc['accused'];
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

  String _locationLine(Map<String, dynamic> doc) {
    final parts = [
      doc['spotVillage'],
      doc['spotArea'],
      doc['spotAddress'],
    ]
        .map((x) => x?.toString().trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  Future<void> _exportPdf() async {
    await runWithPdfAuthGate(context, () async {
      try {
        if (!mounted) return;
        if (_isCrimeDetailForm) {
          final detailState = _crimeDetailKey.currentState;
          if (detailState == null) return;
          final commonMap = detailState.collectData();
          await previewCrimeDetailPdf(context, commonMap);
        } else if (_isPropertySeizureForm) {
          final detailState = _propertySeizureKey.currentState;
          if (detailState == null) return;
          final commonMap = detailState.collectData();
          await previewPropertySeizurePdf(context, commonMap);
        } else if (_isCrimespotSeizureForm) {
          final detailState = _crimespotSeizureKey.currentState;
          if (detailState == null) return;
          final commonMap = detailState.collectData();
          await previewCrimespotSeizurePdf(context, commonMap);
        } else if (_isFormE) {
          final detailState = _formEKey.currentState;
          if (detailState == null) return;
          final commonMap = detailState.collectData();
          await previewFormEPdf(context, commonMap);
        } else if (_isArrestSurrenderForm) {
          final detailState = _arrestSurrenderKey.currentState;
          if (detailState == null) return;
          final commonMap = detailState.extractData();
          await previewArrestSurrenderPdf(context, commonMap);
        } else if (_isInquestPanchanamaForm) {
          final detailState = _inquestPanchanamaKey.currentState;
          if (detailState == null) return;
          final commonMap = detailState.extractData();
          await previewInquestPanchanamaPdf(context, commonMap);
        } else if (_isAccusedMemorandumForm) {
          final detailState = _accusedMemorandumKey.currentState;
          if (detailState == null) return;
          final commonMap = detailState.collectData();
          await previewAccusedMemorandumPdf(context, commonMap);
        } else if (_isFinalReportForm) {
          final detailState = _finalReportKey.currentState;
          if (detailState == null) return;
          final commonMap = detailState.collectData();
          await previewFinalReportPdf(context, commonMap);
        } else if (_isHousePropertySearchSeizureForm) {
          final detailState = _housePropertySearchSeizureKey.currentState;
          if (detailState == null) return;
          final commonMap = detailState.collectData();
          await previewHousePropertySearchSeizurePdf(context, commonMap);
        } else if (_isAbForm) {
          final detailState = _abFormKey.currentState;
          if (detailState == null) return;
          final commonMap = detailState.collectData();
          await previewAbFormPdf(context, commonMap);
        } else if (_is376MedicalForm) {
          final detailState = _medical376Key.currentState;
          if (detailState == null) return;
          final commonMap = detailState.collectData();
          await previewMedical376FormPdf(context, commonMap);
        } else if (_isInterrogationForm) {
          final detailState = _interrogationKey.currentState;
          if (detailState == null) return;
          final commonMap = detailState.collectData();
          await previewInterrogationFormPdf(context, commonMap);
        } else if (_isDraftGroundOfArrestForm) {
          final detailState = _draftGroundOfArrestKey.currentState;
          if (detailState == null) return;
          final commonMap = detailState.collectData();
          await previewDraftGroundOfArrestPdf(context, commonMap);
        } else if (_isGroundOfArrestForm) {
          final detailState = _groundOfArrestKey.currentState;
          if (detailState == null) return;
          final commonMap = detailState.collectData();
          await previewGroundOfArrestPdf(context, commonMap);
        } else if (_isReasonOfArrestForm) {
          final detailState = _reasonOfArrestKey.currentState;
          if (detailState == null) return;
          final commonMap = detailState.collectData();
          await previewReasonOfArrestPdf(context, commonMap);
        } else if (_isTransitRemandForm) {
          final detailState = _transitRemandKey.currentState;
          if (detailState == null) return;
          final commonMap = detailState.collectData();
          await previewTransitRemandPdf(context, commonMap);
        } else if (_isBnssDedicatedForm) {
          final commonMap = BnssDedicatedForms.collect(widget.subCategory);
          if (commonMap == null) return;
          await BnssDedicatedForms.previewPdf(context, widget.subCategory, commonMap);
        } else {
          final form = _formKey.currentState;
          if (form == null) return;

          Map<String, dynamic> extraMap = {};
          final rawExtras = widget.existingRecord?.extraFields;
          if (rawExtras != null && rawExtras.isNotEmpty) {
            extraMap = Map<String, dynamic>.from(rawExtras);
            extraMap.remove(kCommonFormExtraFieldsKey);
          }
          if (_hasKidnappingExtras) {
            final kData = _kidnappingKey.currentState?.collectData();
            if (kData != null && kData.isNotEmpty) {
              extraMap['kidnapping_extra'] = kData;
            }
          }

          final commonMap = commonFormDocumentMapFromState(form);

          final sub = widget.subCategory?.trim() ?? '';
          final formSubtitle = sub.isEmpty
              ? '${widget.moduleLabel} — Khakhi Diary · Maharashtra Police'
              : '$sub · ${widget.moduleLabel} — Khakhi Diary · Maharashtra Police';

          await previewFormPdf(
            context,
            commonMap,
            extraMap: extraMap,
            formTitle: '${widget.moduleLabel.toUpperCase()} FORM',
            formSubtitle: formSubtitle,
          );
        }
      } catch (e, st) {
        debugPrint('PDF export failed: $e');
        debugPrint('$st');
        if (!mounted) return;
        final message = 'PDF failed: $e';
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('PDF Download Failed', style: GoogleFonts.poppins()),
            content: SelectableText(
              message,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: message));
                  if (!ctx.mounted) return;
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error copied',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  );
                },
                child: Text('Copy', style: GoogleFonts.poppins()),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Close', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        );
      }
    });
  }

  String _titleFromDoc(Map<String, dynamic> doc) {
    if (_isCrimeDetailForm || _isPropertySeizureForm || _isInquestPanchanamaForm || _isArrestSurrenderForm) {
      final firNo = doc['firNo']?.toString().trim() ?? '';
      final yr = doc['year']?.toString().trim() ?? '';
      final sub = widget.subCategory ?? 'Form';
      if (firNo.isEmpty) return sub;
      return '$sub — $firNo/$yr';
    }
    if (_isAccusedMemorandumForm) {
      final firNo = doc['firNo']?.toString().trim() ?? '';
      final yr = doc['firYearSuffix']?.toString().trim().isNotEmpty == true
          ? doc['firYearSuffix']!.trim()
          : doc['year']?.toString().trim() ?? '';
      final sub = widget.subCategory ?? 'Form';
      if (firNo.isEmpty) return sub;
      return '$sub — $firNo/$yr';
    }
    if (_isFinalReportForm) {
      final reportNo = doc['reportNo']?.toString().trim() ?? '';
      final yr = doc['reportYearSuffix']?.toString().trim().isNotEmpty == true
          ? doc['reportYearSuffix']!.trim()
          : doc['year']?.toString().trim() ?? '';
      final sub = widget.subCategory ?? 'Form';
      if (reportNo.isEmpty) {
        final firNo = doc['firNo']?.toString().trim() ?? '';
        if (firNo.isEmpty) return sub;
        return '$sub — $firNo/$yr';
      }
      return '$sub — $reportNo/$yr';
    }
    if (_isHousePropertySearchSeizureForm) {
      final firNo = doc['firNo']?.toString().trim() ?? '';
      final yr = doc['firYearSuffix']?.toString().trim().isNotEmpty == true
          ? doc['firYearSuffix']!.trim()
          : doc['year']?.toString().trim() ?? '';
      final sub = widget.subCategory ?? 'Form';
      if (firNo.isEmpty) return sub;
      return '$sub — $firNo/$yr';
    }
    if (_isCrimespotSeizureForm) {
      final campNo = doc['campNo']?.toString().trim() ?? '';
      final sub = widget.subCategory ?? 'Form';
      if (campNo.isEmpty) return sub;
      return '$sub — $campNo';
    }
    if (_isFormE) {
      final val5 = doc['field5']?.toString().trim() ?? '';
      final sub = widget.subCategory ?? 'Form';
      if (val5.isEmpty) return sub;
      return '$sub — $val5';
    }
    if (_isAbForm) {
      final serial = doc['serialNo']?.toString().trim() ?? '';
      final name = doc['personName']?.toString().trim() ??
          doc['subjectName']?.toString().trim() ??
          '';
      final sub = widget.subCategory ?? 'AB Form';
      if (serial.isNotEmpty) return '$sub — $serial';
      if (name.isNotEmpty) return '$sub — $name';
      return sub;
    }
    if (_is376MedicalForm) {
      final name = doc['f_name']?.toString().trim().isNotEmpty == true
          ? doc['f_name']!.trim()
          : doc['m_accusedName']?.toString().trim() ?? '';
      final mlc = doc['f_mlc']?.toString().trim().isNotEmpty == true
          ? doc['f_mlc']!.trim()
          : doc['m_mlc']?.toString().trim() ?? '';
      final sub = widget.subCategory ?? '376 Medical Form';
      if (mlc.isNotEmpty) return '$sub — MLC $mlc';
      if (name.isNotEmpty) return '$sub — $name';
      return sub;
    }
    if (_isInterrogationForm) {
      final name = doc['accusedName']?.toString().trim() ?? '';
      final gur = doc['gurNo']?.toString().trim() ?? '';
      final sub = widget.subCategory ?? 'Interrogation Form';
      if (gur.isNotEmpty) return '$sub — GR $gur';
      if (name.isNotEmpty) return '$sub — $name';
      return sub;
    }
    if (_isDraftGroundOfArrestForm) {
      final name = doc['accusedName']?.toString().trim() ?? '';
      final cr = doc['crNo']?.toString().trim() ?? '';
      final sub = widget.subCategory ?? 'Draft Ground of Arrest';
      if (cr.isNotEmpty) return '$sub — CR $cr';
      if (name.isNotEmpty) return '$sub — $name';
      return sub;
    }
    if (_isGroundOfArrestForm) {
      final cr = doc['subjectCrNo']?.toString().trim() ?? '';
      final sub = widget.subCategory ?? 'Ground of Arrest';
      if (cr.isNotEmpty) return '$sub — CR $cr';
      return sub;
    }
    if (_isReasonOfArrestForm) {
      final cr = doc['subjectCrNo']?.toString().trim() ?? '';
      final sub = widget.subCategory ?? 'Reason of Arrest Form';
      if (cr.isNotEmpty) return '$sub — CR $cr';
      return sub;
    }
    if (_isTransitRemandForm) {
      final cr = doc['m1CrNo']?.toString().trim().isNotEmpty == true
          ? doc['m1CrNo']!.trim()
          : doc['eFirNo']?.toString().trim() ?? '';
      final name = doc['m1AccusedName']?.toString().trim().isNotEmpty == true
          ? doc['m1AccusedName']!.trim()
          : doc['eArrestedName']?.toString().trim() ?? '';
      final sub = widget.subCategory ?? 'Transit Remand';
      if (cr.isNotEmpty) return '$sub — CR $cr';
      if (name.isNotEmpty) return '$sub — $name';
      return sub;
    }
    if (_isBnssDedicatedForm) {
      final cr = BnssDedicatedForms.caseNumFromDoc(doc);
      final sub = widget.subCategory ?? 'Form';
      if (cr.isEmpty) return sub;
      return '$sub — $cr';
    }
    final cr = doc['crNo']?.toString().trim() ?? '';
    if (widget.subCategory != null && widget.subCategory!.trim().isNotEmpty) {
      final sub = widget.subCategory!.trim();
      if (cr.isEmpty) return '$sub — ${widget.moduleLabel}';
      return '$sub — $cr';
    }
    if (cr.isEmpty) return widget.moduleLabel;
    return '${widget.moduleLabel} — $cr';
  }

  DateTime _parseCrimeDetailDate(Map<String, dynamic> doc) {
    if (_isFormE) {
      // Try to parse 'field4' which is "गुन्हा घडल्याची तारीख"
      final dateStr = doc['field4']?.toString().trim() ?? '';
      final parts = dateStr.split(RegExp(r'[/.-]'));
      if (parts.length >= 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
      return DateTime.now();
    }
    if (_isArrestSurrenderForm) {
      final dateStr = doc['arrestDate']?.toString().trim().isNotEmpty == true
          ? doc['arrestDate']!.trim()
          : doc['date']?.toString().trim() ?? '';
      final parts = dateStr.split(RegExp(r'[/.-]'));
      if (parts.length >= 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
      return DateTime.now();
    }
    if (_isInquestPanchanamaForm) {
      final dateStr = doc['foundDate']?.toString().trim() ?? '';
      final parts = dateStr.split(RegExp(r'[/.-]'));
      if (parts.length >= 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
      return DateTime.now();
    }
    if (_isAccusedMemorandumForm) {
      final dateStr = doc['headerDate']?.toString().trim() ??
          doc['memDate']?.toString().trim() ??
          '';
      final parts = dateStr.split(RegExp(r'[/.-]'));
      if (parts.length >= 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
      return DateTime.now();
    }
    if (_isFinalReportForm) {
      final dateStr = doc['reportDate']?.toString().trim() ??
          doc['headerDate']?.toString().trim() ??
          '';
      final parts = dateStr.split(RegExp(r'[/.-]'));
      if (parts.length >= 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
      return DateTime.now();
    }
    if (_isHousePropertySearchSeizureForm) {
      final dateStr = doc['seizeDate']?.toString().trim() ??
          doc['headerDate']?.toString().trim() ??
          '';
      final parts = dateStr.split(RegExp(r'[/.-]'));
      if (parts.length >= 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
      return DateTime.now();
    }
    if (_isAbForm) {
      final dateStr = doc['formADated']?.toString().trim().isNotEmpty == true
          ? doc['formADated']!.trim()
          : doc['examinedDate']?.toString().trim().isNotEmpty == true
              ? doc['examinedDate']!.trim()
              : doc['collectionDate']?.toString().trim() ?? '';
      final parts = dateStr.split(RegExp(r'[/.-]'));
      if (parts.length >= 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
      return DateTime.now();
    }
    if (_is376MedicalForm) {
      final dateStr = doc['f_arrival']?.toString().trim().isNotEmpty == true
          ? doc['f_arrival']!.trim()
          : doc['m_examDateTime']?.toString().trim() ?? '';
      final parts = dateStr.split(RegExp(r'[/.-]'));
      if (parts.length >= 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
      return DateTime.now();
    }
    if (_isInterrogationForm) {
      final dateStr = doc['arrestDateTime']?.toString().trim() ?? '';
      final parts = dateStr.split(RegExp(r'[/.-]'));
      if (parts.length >= 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
      return DateTime.now();
    }
    if (_isDraftGroundOfArrestForm) {
      final dateStr = doc['arrestDate']?.toString().trim().isNotEmpty == true
          ? doc['arrestDate']!.trim()
          : doc['goaFooterDate']?.toString().trim() ?? '';
      final parts = dateStr.split(RegExp(r'[/.-]'));
      if (parts.length >= 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
      return DateTime.now();
    }
    if (_isGroundOfArrestForm) {
      final dateStr = doc['noticeDate']?.toString().trim() ?? '';
      final parts = dateStr.split(RegExp(r'[/.-]'));
      if (parts.length >= 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
      return DateTime.now();
    }
    if (_isReasonOfArrestForm) {
      final dateStr = doc['noticeDate']?.toString().trim() ?? '';
      final parts = dateStr.split(RegExp(r'[/.-]'));
      if (parts.length >= 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
      return DateTime.now();
    }
    if (_isTransitRemandForm) {
      final dateStr = doc['m1Date']?.toString().trim().isNotEmpty == true
          ? doc['m1Date']!.trim()
          : doc['eDate']?.toString().trim().isNotEmpty == true
              ? doc['eDate']!.trim()
              : doc['m2Date']?.toString().trim() ?? '';
      final parts = dateStr.split(RegExp(r'[/.-]'));
      if (parts.length >= 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
      return DateTime.now();
    }
    if (_isBnssDedicatedForm) {
      return BnssDedicatedForms.dateFromDoc(doc);
    }
    final d = int.tryParse(doc['dateDay']?.toString() ?? '');
    final m = int.tryParse(doc['dateMonth']?.toString() ?? '');
    final ySuffix = doc['dateYear']?.toString() ?? '';
    final y = int.tryParse('20$ySuffix');
    if (d != null && m != null && y != null) {
      return DateTime(y, m, d);
    }
    return DateTime.now();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final provider = _getProvider(context);

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

    Map<String, dynamic> doc;
    if (_isCrimeDetailForm) {
      final detailState = _crimeDetailKey.currentState;
      if (detailState == null) return;
      doc = detailState.collectData();
    } else if (_isPropertySeizureForm) {
      final detailState = _propertySeizureKey.currentState;
      if (detailState == null) return;
      doc = detailState.collectData();
    } else if (_isCrimespotSeizureForm) {
      final detailState = _crimespotSeizureKey.currentState;
      if (detailState == null) return;
      doc = detailState.collectData();
    } else if (_isFormE) {
      final detailState = _formEKey.currentState;
      if (detailState == null) return;
      doc = detailState.collectData();
    } else if (_isArrestSurrenderForm) {
      final detailState = _arrestSurrenderKey.currentState;
      if (detailState == null) return;
      doc = detailState.extractData();
    } else if (_isInquestPanchanamaForm) {
      final detailState = _inquestPanchanamaKey.currentState;
      if (detailState == null) return;
      doc = detailState.extractData();
    } else if (_isAccusedMemorandumForm) {
      final detailState = _accusedMemorandumKey.currentState;
      if (detailState == null) return;
      doc = detailState.collectData();
    } else if (_isFinalReportForm) {
      final detailState = _finalReportKey.currentState;
      if (detailState == null) return;
      doc = detailState.collectData();
    } else if (_isHousePropertySearchSeizureForm) {
      final detailState = _housePropertySearchSeizureKey.currentState;
      if (detailState == null) return;
      doc = detailState.collectData();
    } else if (_isAbForm) {
      final detailState = _abFormKey.currentState;
      if (detailState == null) return;
      doc = detailState.collectData();
    } else if (_is376MedicalForm) {
      final detailState = _medical376Key.currentState;
      if (detailState == null) return;
      doc = detailState.collectData();
    } else if (_isInterrogationForm) {
      final detailState = _interrogationKey.currentState;
      if (detailState == null) return;
      doc = detailState.collectData();
    } else if (_isDraftGroundOfArrestForm) {
      final detailState = _draftGroundOfArrestKey.currentState;
      if (detailState == null) return;
      doc = detailState.collectData();
    } else if (_isGroundOfArrestForm) {
      final detailState = _groundOfArrestKey.currentState;
      if (detailState == null) return;
      doc = detailState.collectData();
    } else if (_isReasonOfArrestForm) {
      final detailState = _reasonOfArrestKey.currentState;
      if (detailState == null) return;
      doc = detailState.collectData();
    } else if (_isTransitRemandForm) {
      final detailState = _transitRemandKey.currentState;
      if (detailState == null) return;
      doc = detailState.collectData();
    } else if (_isBnssDedicatedForm) {
      final collected = BnssDedicatedForms.collect(widget.subCategory);
      if (collected == null) return;
      doc = collected;
    } else {
      final form = _formKey.currentState;
      if (form == null) return;
      doc = commonFormDocumentMapFromState(form);
    }

    final extra = Map<String, dynamic>.from(
      widget.existingRecord?.extraFields ?? {},
    );
    extra[kCommonFormExtraFieldsKey] = doc;
    extra['lastEditedByUid'] = auth.uid;
    extra['lastEditedByName'] = auth.displayName;
    extra['lastEditedByDesignation'] = auth.designation;
    extra['lastEditedAt'] = DateTime.now().toIso8601String();
    if (!_isCrimeDetailForm && _hasKidnappingExtras) {
      final kData = _kidnappingKey.currentState?.collectData();
      if (kData != null && kData.isNotEmpty) {
        extra['kidnapping_extra'] = kData;
      }
    }

    final String complainantName = _isCrimeDetailForm
        ? (doc['shownByName']?.toString().trim() ?? '')
        : _isPropertySeizureForm
            ? (doc['personName']?.toString().trim() ?? '')
            : _isCrimespotSeizureForm
                ? (doc['panch1Name']?.toString().trim() ?? '')
                : _isFormE
                    ? (doc['field2']?.toString().trim() ?? '')
                    : _isArrestSurrenderForm
                        ? (doc['accusedName']?.toString().trim() ?? '')
                    : _isInquestPanchanamaForm
                        ? (doc['shownBy']?.toString().trim() ?? '')
                        : _isAccusedMemorandumForm
                            ? (doc['accusedName']?.toString().trim() ?? '')
                            : _isFinalReportForm
                                ? (doc['complainantName']?.toString().trim() ?? '')
                                : _isHousePropertySearchSeizureForm
                                    ? (doc['personName']?.toString().trim() ?? '')
                                    : _isAbForm
                                        ? (doc['personName']?.toString().trim().isNotEmpty == true
                                            ? doc['personName']!.trim()
                                            : doc['subjectName']?.toString().trim() ?? '')
                                        : _is376MedicalForm
                                            ? (doc['f_name']?.toString().trim().isNotEmpty == true
                                                ? doc['f_name']!.trim()
                                                : doc['m_accusedName']?.toString().trim() ?? '')
                                            : _isInterrogationForm
                                                ? (doc['accusedName']?.toString().trim() ?? '')
                                            : _isDraftGroundOfArrestForm
                                                ? (doc['accusedName']?.toString().trim() ?? '')
                                            : _isGroundOfArrestForm
                                                ? (doc['accusedNameAddress']?.toString().trim() ?? '')
                                            : _isReasonOfArrestForm
                                                ? (doc['accusedNameAddress']?.toString().trim() ?? '')
                                            : _isTransitRemandForm
                                                ? (doc['eComplainantName']?.toString().trim().isNotEmpty == true
                                                    ? doc['eComplainantName']!.trim()
                                                    : doc['m1AccusedName']?.toString().trim() ?? '')
                                            : _isBnssDedicatedForm
                                                ? BnssDedicatedForms.complainantFromDoc(doc)
                                            : (doc['complainant'] is Map ? doc['complainant']['name']?.toString().trim() ?? '' : '');

    final String caseNum;
    if (_isCrimeDetailForm || _isPropertySeizureForm) {
      caseNum = doc['firNo']?.toString().trim() ?? '';
    } else if (_isCrimespotSeizureForm) {
      caseNum = doc['campNo']?.toString().trim() ?? '';
    } else if (_isFormE) {
      caseNum = doc['field5']?.toString().trim() ?? '';
    } else if (_isArrestSurrenderForm) {
      caseNum = doc['firNo']?.toString().trim() ?? '';
    } else if (_isInquestPanchanamaForm) {
      caseNum = doc['firNo']?.toString().trim() ?? '';
    } else if (_isAccusedMemorandumForm) {
      caseNum = doc['firNo']?.toString().trim() ?? '';
    } else if (_isFinalReportForm) {
      caseNum = doc['reportNo']?.toString().trim().isNotEmpty == true
          ? doc['reportNo']!.trim()
          : doc['firNo']?.toString().trim() ?? '';
    } else if (_isHousePropertySearchSeizureForm) {
      caseNum = doc['firNo']?.toString().trim() ?? '';
    } else if (_isAbForm) {
      caseNum = doc['serialNo']?.toString().trim().isNotEmpty == true
          ? doc['serialNo']!.trim()
          : doc['formBNo']?.toString().trim() ?? '';
    } else if (_is376MedicalForm) {
      caseNum = doc['f_mlc']?.toString().trim().isNotEmpty == true
          ? doc['f_mlc']!.trim()
          : doc['m_mlc']?.toString().trim().isNotEmpty == true
              ? doc['m_mlc']!.trim()
              : doc['m_crNo']?.toString().trim() ?? '';
    } else if (_isInterrogationForm) {
      caseNum = doc['gurNo']?.toString().trim().isNotEmpty == true
          ? doc['gurNo']!.trim()
          : doc['kalam']?.toString().trim() ?? '';
    } else if (_isDraftGroundOfArrestForm) {
      caseNum = doc['crNo']?.toString().trim().isNotEmpty == true
          ? doc['crNo']!.trim()
          : doc['bnsSection']?.toString().trim() ?? '';
    } else if (_isGroundOfArrestForm) {
      caseNum = doc['subjectCrNo']?.toString().trim().isNotEmpty == true
          ? doc['subjectCrNo']!.trim()
          : doc['outwardNo']?.toString().trim() ?? '';
    } else if (_isReasonOfArrestForm) {
      caseNum = doc['subjectCrNo']?.toString().trim().isNotEmpty == true
          ? doc['subjectCrNo']!.trim()
          : doc['outwardNo']?.toString().trim() ?? '';
    } else if (_isTransitRemandForm) {
      caseNum = doc['m1CrNo']?.toString().trim().isNotEmpty == true
          ? doc['m1CrNo']!.trim()
          : doc['eFirNo']?.toString().trim().isNotEmpty == true
              ? doc['eFirNo']!.trim()
              : doc['m2RefCrNo']?.toString().trim() ?? '';
    } else if (_isBnssDedicatedForm) {
      caseNum = BnssDedicatedForms.caseNumFromDoc(doc);
    } else {
      caseNum = doc['crNo']?.toString().trim() ?? '';
    }

    final String loc;
    if (_isCrimeDetailForm) {
      loc = doc['shownByAddress']?.toString().trim() ?? '';
    } else if (_isPropertySeizureForm) {
      loc = doc['seizurePlace']?.toString().trim() ?? '';
    } else if (_isFormE) {
      loc = doc['field3']?.toString().trim() ?? '';
    } else if (_isArrestSurrenderForm) {
      loc = doc['arrestPlace']?.toString().trim().isNotEmpty == true
          ? doc['arrestPlace']!.trim()
          : doc['presAddress']?.toString().trim() ?? '';
    } else if (_isInquestPanchanamaForm) {
      loc = doc['foundPlace']?.toString().trim() ?? '';
    } else if (_isAccusedMemorandumForm) {
      loc = doc['memPlace']?.toString().trim() ?? '';
    } else if (_isFinalReportForm) {
      loc = doc['ps']?.toString().trim().isNotEmpty == true
          ? doc['ps']!.trim()
          : doc['dist']?.toString().trim() ?? '';
    } else if (_isHousePropertySearchSeizureForm) {
      loc = doc['placeSeized']?.toString().trim() ?? '';
    } else if (_isAbForm) {
      loc = doc['dispensary']?.toString().trim().isNotEmpty == true
          ? doc['dispensary']!.trim()
          : doc['subjectAddress']?.toString().trim() ?? '';
    } else if (_is376MedicalForm) {
      loc = doc['f_hospital']?.toString().trim().isNotEmpty == true
          ? doc['f_hospital']!.trim()
          : doc['m_hospital']?.toString().trim() ?? '';
    } else if (_isInterrogationForm) {
      loc = doc['ps']?.toString().trim().isNotEmpty == true
          ? doc['ps']!.trim()
          : doc['address']?.toString().trim() ?? '';
    } else if (_isDraftGroundOfArrestForm) {
      loc = doc['psName']?.toString().trim().isNotEmpty == true
          ? doc['psName']!.trim()
          : doc['accusedAddress']?.toString().trim() ?? '';
    } else if (_isGroundOfArrestForm) {
      loc = doc['policeStation']?.toString().trim().isNotEmpty == true
          ? doc['policeStation']!.trim()
          : doc['subjectPs']?.toString().trim() ?? '';
    } else if (_isReasonOfArrestForm) {
      loc = doc['policeStation']?.toString().trim().isNotEmpty == true
          ? doc['policeStation']!.trim()
          : doc['subjectPs']?.toString().trim() ?? '';
    } else if (_isTransitRemandForm) {
      loc = doc['m1PsName']?.toString().trim().isNotEmpty == true
          ? doc['m1PsName']!.trim()
          : doc['ePsName']?.toString().trim().isNotEmpty == true
              ? doc['ePsName']!.trim()
              : doc['m1PsCity']?.toString().trim() ?? '';
    } else if (_isBnssDedicatedForm) {
      loc = BnssDedicatedForms.locationFromDoc(doc);
    } else {
      loc = _locationLine(doc);
    }

    final DateTime incDate;
    if (_isCrimeDetailForm ||
        _isPropertySeizureForm ||
        _isCrimespotSeizureForm ||
        _isFormE ||
        _isArrestSurrenderForm ||
        _isInquestPanchanamaForm ||
        _isAccusedMemorandumForm ||
        _isFinalReportForm ||
        _isHousePropertySearchSeizureForm ||
        _isAbForm ||
        _is376MedicalForm ||
        _isInterrogationForm ||
        _isDraftGroundOfArrestForm ||
        _isGroundOfArrestForm ||
        _isReasonOfArrestForm ||
        _isTransitRemandForm ||
        _isBnssDedicatedForm) {
      incDate = _parseCrimeDetailDate(doc);
    } else {
      incDate = _parseRegDate(doc['regDate']?.toString() ?? '');
    }

    final record = ModuleRecord(
      id: _isEdit
          ? widget.existingRecord!.id
          : '${DateTime.now().millisecondsSinceEpoch}',
      moduleKey: widget.moduleKey,
      title: _titleFromDoc(doc),
      caseNumber: caseNum,
      description: _isEdit ? widget.existingRecord!.description : '',
      complainant: complainantName,
      accused: (_isCrimeDetailForm ||
              _isPropertySeizureForm ||
              _isCrimespotSeizureForm ||
              _isFormE ||
              _isArrestSurrenderForm ||
              _isInquestPanchanamaForm ||
              _isAccusedMemorandumForm ||
              _isFinalReportForm ||
              _isHousePropertySearchSeizureForm ||
              _isAbForm ||
              _is376MedicalForm ||
              _isInterrogationForm ||
              _isDraftGroundOfArrestForm ||
              _isGroundOfArrestForm ||
              _isReasonOfArrestForm ||
              _isTransitRemandForm ||
              _isBnssDedicatedForm)
          ? ''
          : _accusedSummary(doc),
      location: loc,
      incidentDate: incDate,
      priority: _isEdit ? widget.existingRecord!.priority : 'Medium',
      status: _isEdit ? widget.existingRecord!.status : 'Open',
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

    try {
      if (_isEdit) {
        await provider.updateRecord(record);
      } else {
        await provider.addRecord(record);
      }

      if (!mounted) return;

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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Failed to save record: $e',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppColors.dangerRed,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.navyDark, size: 20),
        ),
        title: Text(
          widget.readOnly == true
              ? 'View ${widget.moduleLabel}'
              : (_isEdit
                  ? 'Edit ${widget.moduleLabel}'
                  : 'New ${widget.moduleLabel} Entry'),
          style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark),
        ),

      ),
      body: _isCrimeDetailForm
          ? CrimeDetailFormView(
              key: _crimeDetailKey,
              readOnly: widget.readOnly == true,
              formSection: widget.formSection,
              pageRange: widget.pageRange,
            )
          : _isPropertySeizureForm
              ? PropertySeizureFormView(
                  key: _propertySeizureKey,
                  readOnly: widget.readOnly == true,
                  formSection: widget.formSection,
                  pageRange: widget.pageRange,
                )
              : _isCrimespotSeizureForm
                    ? CrimespotSeizureFormView(
                        key: _crimespotSeizureKey,
                        readOnly: widget.readOnly == true,
                      )
                    : _isFormE
                        ? FormEView(
                            key: _formEKey,
                            existingRecord: widget.existingRecord?.extraFields[kCommonFormExtraFieldsKey],
                            readOnly: widget.readOnly == true,
                          )
                        : _isArrestSurrenderForm
                            ? ArrestSurrenderFormView(
                                key: _arrestSurrenderKey,
                                existingRecord: widget.existingRecord?.extraFields[kCommonFormExtraFieldsKey],
                                readOnly: widget.readOnly == true,
                                formSection: widget.formSection,
                                pageRange: widget.pageRange,
                              )
                            : _isInquestPanchanamaForm
                                ? InquestPanchanamaFormView(
                                    key: _inquestPanchanamaKey,
                                    existingRecord: widget.existingRecord?.extraFields[kCommonFormExtraFieldsKey],
                                    readOnly: widget.readOnly == true,
                                    formSection: widget.formSection,
                                    pageRange: widget.pageRange,
                                  )
                                : _isAccusedMemorandumForm
                                    ? AccusedMemorandumFormView(
                                        key: _accusedMemorandumKey,
                                        existingRecord: widget.existingRecord?.extraFields[kCommonFormExtraFieldsKey],
                                        readOnly: widget.readOnly == true,
                                        formSection: widget.formSection,
                                        pageRange: widget.pageRange,
                                      )
                                    : _isFinalReportForm
                                        ? FinalReportFormView(
                                            key: _finalReportKey,
                                            existingRecord: widget.existingRecord?.extraFields[kCommonFormExtraFieldsKey],
                                            readOnly: widget.readOnly == true,
                                            formSection: widget.formSection,
                                            pageRange: widget.pageRange,
                                          )
                                        : _isHousePropertySearchSeizureForm
                                            ? HousePropertySearchSeizureFormView(
                                                key: _housePropertySearchSeizureKey,
                                                existingRecord: widget.existingRecord?.extraFields[kCommonFormExtraFieldsKey],
                                                readOnly: widget.readOnly == true,
                                                formSection: widget.formSection,
                                                pageRange: widget.pageRange,
                                              )
                                                : _isAbForm
                                                    ? AbFormView(
                                                        key: _abFormKey,
                                                        readOnly: widget.readOnly == true,
                                                        formSection: widget.formSection,
                                                        pageRange: widget.pageRange,
                                                      )
                                                    : _is376MedicalForm
                                                        ? Medical376FormView(
                                                            key: _medical376Key,
                                                            readOnly: widget.readOnly == true,
                                                            formSection: widget.formSection,
                                                            pageRange: widget.pageRange,
                                                          )
                                                        : _isInterrogationForm
                                                            ? InterrogationFormView(
                                                                key: _interrogationKey,
                                                                readOnly: widget.readOnly == true,
                                                                formSection: widget.formSection,
                                                                pageRange: widget.pageRange,
                                                              )
                                                        : _isDraftGroundOfArrestForm
                                                            ? DraftGroundOfArrestFormView(
                                                                key: _draftGroundOfArrestKey,
                                                                readOnly: widget.readOnly == true,
                                                                formSection: widget.formSection,
                                                                pageRange: widget.pageRange,
                                                              )
                                                        : _isGroundOfArrestForm
                                                            ? GroundOfArrestFormView(
                                                                key: _groundOfArrestKey,
                                                                readOnly: widget.readOnly == true,
                                                                formSection: widget.formSection,
                                                                pageRange: widget.pageRange,
                                                              )
                                                        : _isReasonOfArrestForm
                                                            ? ReasonOfArrestFormView(
                                                                key: _reasonOfArrestKey,
                                                                readOnly: widget.readOnly == true,
                                                                formSection: widget.formSection,
                                                                pageRange: widget.pageRange,
                                                              )
                                                        : _isTransitRemandForm
                                                            ? TransitRemandFormView(
                                                                key: _transitRemandKey,
                                                                readOnly: widget.readOnly == true,
                                                                formSection: widget.formSection,
                                                                pageRange: widget.pageRange,
                                                              )
                                                        : _isBnssDedicatedForm
                                                            ? BnssDedicatedForms.buildBody(
                                                                subCategory: widget.subCategory,
                                                                readOnly: widget.readOnly == true,
                                                                formSection: widget.formSection,
                                                                pageRange: widget.pageRange,
                                                              )
                                                : CommonForm(
                      key: _formKey,
                      middleSlot: _hasKidnappingExtras
                          ? KidnappingExtraFields(key: _kidnappingKey)
                          : null,
                    ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.lg, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.readOnly != true) ...[
                SizedBox(
                  width: 95,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyMid,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              SizedBox(
                width: widget.readOnly == true ? 180 : 110,
                height: 46,
                child: OutlinedButton(
                  onPressed: _exportPdf,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.navyMid, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.picture_as_pdf_outlined,
                          color: AppColors.navyMid, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.readOnly == true ? 'Download PDF' : 'PDF',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navyMid),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.readOnly != true) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 125,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModuleHubScreen(
                            moduleLabel: widget.moduleLabel,
                            moduleKey: widget.moduleKey,
                            subCategory: widget.subCategory,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.navyMid, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded,
                            color: AppColors.navyMid, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'History',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyMid),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
