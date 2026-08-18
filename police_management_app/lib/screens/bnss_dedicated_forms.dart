import 'package:flutter/material.dart';

import '../utils/bnss_panch_notice_pdf.dart';
import '../utils/chehare_patti_pdf.dart';
import '../utils/injury_certificate_pdf.dart';
import '../utils/juvenile_social_report_pdf.dart';
import '../utils/medical_exam_s51_pdf.dart';
import '../utils/mobile_seal_label_pdf.dart';
import '../utils/muddemal_pavti_pdf.dart';
import '../utils/nil_house_search_pdf.dart';
import '../utils/notice_section_35_pdf.dart';
import '../utils/notice_to_accused_pdf.dart';
import '../utils/order_section_47_48_pdf.dart';
import '../utils/panchanama_continuation_pdf.dart';
import '../utils/witness_notice_pdf.dart';
import '../widgets/bnss_panch_notice_form_view.dart';
import '../widgets/chehare_patti_form_view.dart';
import '../widgets/injury_certificate_form_view.dart';
import '../widgets/juvenile_social_report_form_view.dart';
import '../widgets/medical_exam_s51_form_view.dart';
import '../widgets/mobile_seal_label_form_view.dart';
import '../widgets/muddemal_pavti_form_view.dart';
import '../widgets/nil_house_search_form_view.dart';
import '../widgets/notice_section_35_form_view.dart';
import '../widgets/notice_to_accused_form_view.dart';
import '../widgets/order_section_47_48_form_view.dart';
import '../widgets/panchanama_continuation_form_view.dart';
import '../widgets/witness_notice_form_view.dart';

/// Central bindings for BNSS compendium dedicated form views.
class BnssDedicatedForms {
  static const orderSection4748 = 'Order Section 47 & 48';
  static const panchanamaContinuation = 'Panchanama Continuation';
  static const injuryCertificate = 'Injury Certificate';
  static const bnssPanchNotice = 'BNSS Panch Notice';
  static const noticeToAccused = 'Notice to Accused';
  static const muddemalPavti = 'Muddemal Pavti';
  static const witnessNotice = 'Witness Notice';
  static const nilHouseSearch = 'Nil House Search Panchanama';
  static const medicalExamS51 = 'Medical Exam Section 51';
  static const cheharePatti = 'Chehare Patti';
  static const noticeSection35 = 'Notice Section 35';
  static const mobileSealLabel = 'Mobile Seal Label';
  static const juvenileSocialReport = 'Juvenile Social Background Report';

  static const allSubCategories = {
    orderSection4748,
    panchanamaContinuation,
    injuryCertificate,
    bnssPanchNotice,
    noticeToAccused,
    muddemalPavti,
    witnessNotice,
    nilHouseSearch,
    medicalExamS51,
    cheharePatti,
    noticeSection35,
    mobileSealLabel,
    juvenileSocialReport,
  };

  static bool isDedicated(String? subCategory) =>
      allSubCategories.contains(subCategory?.trim());

  static final orderSection4748Key = GlobalKey<OrderSection4748FormViewState>();
  static final panchanamaContinuationKey =
      GlobalKey<PanchanamaContinuationFormViewState>();
  static final injuryCertificateKey = GlobalKey<InjuryCertificateFormViewState>();
  static final bnssPanchNoticeKey = GlobalKey<BnssPanchNoticeFormViewState>();
  static final noticeToAccusedKey = GlobalKey<NoticeToAccusedFormViewState>();
  static final muddemalPavtiKey = GlobalKey<MuddemalPavtiFormViewState>();
  static final witnessNoticeKey = GlobalKey<WitnessNoticeFormViewState>();
  static final nilHouseSearchKey = GlobalKey<NilHouseSearchFormViewState>();
  static final medicalExamS51Key = GlobalKey<MedicalExamS51FormViewState>();
  static final cheharePattiKey = GlobalKey<CheharePattiFormViewState>();
  static final noticeSection35Key = GlobalKey<NoticeSection35FormViewState>();
  static final mobileSealLabelKey = GlobalKey<MobileSealLabelFormViewState>();
  static final juvenileSocialReportKey =
      GlobalKey<JuvenileSocialReportFormViewState>();

  static void hydrate(String? subCategory, Map<String, dynamic> data) {
    switch (subCategory?.trim()) {
      case orderSection4748:
        orderSection4748Key.currentState?.hydrateFrom(data);
      case panchanamaContinuation:
        panchanamaContinuationKey.currentState?.hydrateFrom(data);
      case injuryCertificate:
        injuryCertificateKey.currentState?.hydrateFrom(data);
      case bnssPanchNotice:
        bnssPanchNoticeKey.currentState?.hydrateFrom(data);
      case noticeToAccused:
        noticeToAccusedKey.currentState?.hydrateFrom(data);
      case muddemalPavti:
        muddemalPavtiKey.currentState?.hydrateFrom(data);
      case witnessNotice:
        witnessNoticeKey.currentState?.hydrateFrom(data);
      case nilHouseSearch:
        nilHouseSearchKey.currentState?.hydrateFrom(data);
      case medicalExamS51:
        medicalExamS51Key.currentState?.hydrateFrom(data);
      case cheharePatti:
        cheharePattiKey.currentState?.hydrateFrom(data);
      case noticeSection35:
        noticeSection35Key.currentState?.hydrateFrom(data);
      case mobileSealLabel:
        mobileSealLabelKey.currentState?.hydrateFrom(data);
      case juvenileSocialReport:
        juvenileSocialReportKey.currentState?.hydrateFrom(data);
    }
  }

  static Map<String, dynamic>? collect(String? subCategory) {
    switch (subCategory?.trim()) {
      case orderSection4748:
        return orderSection4748Key.currentState?.collectData();
      case panchanamaContinuation:
        return panchanamaContinuationKey.currentState?.collectData();
      case injuryCertificate:
        return injuryCertificateKey.currentState?.collectData();
      case bnssPanchNotice:
        return bnssPanchNoticeKey.currentState?.collectData();
      case noticeToAccused:
        return noticeToAccusedKey.currentState?.collectData();
      case muddemalPavti:
        return muddemalPavtiKey.currentState?.collectData();
      case witnessNotice:
        return witnessNoticeKey.currentState?.collectData();
      case nilHouseSearch:
        return nilHouseSearchKey.currentState?.collectData();
      case medicalExamS51:
        return medicalExamS51Key.currentState?.collectData();
      case cheharePatti:
        return cheharePattiKey.currentState?.collectData();
      case noticeSection35:
        return noticeSection35Key.currentState?.collectData();
      case mobileSealLabel:
        return mobileSealLabelKey.currentState?.collectData();
      case juvenileSocialReport:
        return juvenileSocialReportKey.currentState?.collectData();
      default:
        return null;
    }
  }

  static Future<void> previewPdf(
    BuildContext context,
    String? subCategory,
    Map<String, dynamic> doc,
  ) async {
    switch (subCategory?.trim()) {
      case orderSection4748:
        await previewOrderSection4748Pdf(context, doc);
      case panchanamaContinuation:
        await previewPanchanamaContinuationPdf(context, doc);
      case injuryCertificate:
        await previewInjuryCertificatePdf(context, doc);
      case bnssPanchNotice:
        await previewBnssPanchNoticePdf(context, doc);
      case noticeToAccused:
        await previewNoticeToAccusedPdf(context, doc);
      case muddemalPavti:
        await previewMuddemalPavtiPdf(context, doc);
      case witnessNotice:
        await previewWitnessNoticePdf(context, doc);
      case nilHouseSearch:
        await previewNilHouseSearchPdf(context, doc);
      case medicalExamS51:
        await previewMedicalExamS51Pdf(context, doc);
      case cheharePatti:
        await previewCheharePattiPdf(context, doc);
      case noticeSection35:
        await previewNoticeSection35Pdf(context, doc);
      case mobileSealLabel:
        await previewMobileSealLabelPdf(context, doc);
      case juvenileSocialReport:
        await previewJuvenileSocialReportPdf(context, doc);
    }
  }

  static Widget buildBody({
    required String? subCategory,
    required bool readOnly,
    String? formSection,
    String? pageRange,
  }) {
    switch (subCategory?.trim()) {
      case orderSection4748:
        return OrderSection4748FormView(
          key: orderSection4748Key,
          readOnly: readOnly,
          formSection: formSection,
          pageRange: pageRange,
        );
      case panchanamaContinuation:
        return PanchanamaContinuationFormView(
          key: panchanamaContinuationKey,
          readOnly: readOnly,
          formSection: formSection,
          pageRange: pageRange,
        );
      case injuryCertificate:
        return InjuryCertificateFormView(
          key: injuryCertificateKey,
          readOnly: readOnly,
          formSection: formSection,
          pageRange: pageRange,
        );
      case bnssPanchNotice:
        return BnssPanchNoticeFormView(
          key: bnssPanchNoticeKey,
          readOnly: readOnly,
          formSection: formSection,
          pageRange: pageRange,
        );
      case noticeToAccused:
        return NoticeToAccusedFormView(
          key: noticeToAccusedKey,
          readOnly: readOnly,
          formSection: formSection,
          pageRange: pageRange,
        );
      case muddemalPavti:
        return MuddemalPavtiFormView(
          key: muddemalPavtiKey,
          readOnly: readOnly,
          formSection: formSection,
          pageRange: pageRange,
        );
      case witnessNotice:
        return WitnessNoticeFormView(
          key: witnessNoticeKey,
          readOnly: readOnly,
          formSection: formSection,
          pageRange: pageRange,
        );
      case nilHouseSearch:
        return NilHouseSearchFormView(
          key: nilHouseSearchKey,
          readOnly: readOnly,
          formSection: formSection,
          pageRange: pageRange,
        );
      case medicalExamS51:
        return MedicalExamS51FormView(
          key: medicalExamS51Key,
          readOnly: readOnly,
          formSection: formSection,
          pageRange: pageRange,
        );
      case cheharePatti:
        return CheharePattiFormView(
          key: cheharePattiKey,
          readOnly: readOnly,
          formSection: formSection,
          pageRange: pageRange,
        );
      case noticeSection35:
        return NoticeSection35FormView(
          key: noticeSection35Key,
          readOnly: readOnly,
          formSection: formSection,
          pageRange: pageRange,
        );
      case mobileSealLabel:
        return MobileSealLabelFormView(
          key: mobileSealLabelKey,
          readOnly: readOnly,
          formSection: formSection,
          pageRange: pageRange,
        );
      case juvenileSocialReport:
        return JuvenileSocialReportFormView(
          key: juvenileSocialReportKey,
          readOnly: readOnly,
          formSection: formSection,
          pageRange: pageRange,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  static String complainantFromDoc(Map<String, dynamic> doc) {
    return doc['accusedName']?.toString().trim().isNotEmpty == true
        ? doc['accusedName']!.trim()
        : doc['juvenileName']?.toString().trim().isNotEmpty == true
            ? doc['juvenileName']!.trim()
            : doc['patientName']?.toString().trim().isNotEmpty == true
                ? doc['patientName']!.trim()
                : doc['witnessNameAddress']?.toString().trim().isNotEmpty == true
                    ? doc['witnessNameAddress']!.trim()
                    : doc['toNameAddress']?.toString().trim().isNotEmpty == true
                        ? doc['toNameAddress']!.trim()
                        : doc['accusedNameAddress']?.toString().trim() ?? '';
  }

  static String caseNumFromDoc(Map<String, dynamic> doc) {
    return doc['crNo']?.toString().trim().isNotEmpty == true
        ? doc['crNo']!.trim()
        : doc['firNo']?.toString().trim().isNotEmpty == true
            ? doc['firNo']!.trim()
            : doc['outwardNo']?.toString().trim().isNotEmpty == true
                ? doc['outwardNo']!.trim()
                : doc['campNo']?.toString().trim().isNotEmpty == true
                    ? doc['campNo']!.trim()
                    : doc['receiptNo']?.toString().trim() ?? '';
  }

  static String locationFromDoc(Map<String, dynamic> doc) {
    return doc['policeStation']?.toString().trim().isNotEmpty == true
        ? doc['policeStation']!.trim()
        : doc['ps']?.toString().trim().isNotEmpty == true
            ? doc['ps']!.trim()
            : doc['searchAddress']?.toString().trim() ?? '';
  }

  static DateTime dateFromDoc(Map<String, dynamic> doc) {
    final dateStr = doc['noticeDate']?.toString().trim().isNotEmpty == true
        ? doc['noticeDate']!.trim()
        : doc['date']?.toString().trim().isNotEmpty == true
            ? doc['date']!.trim()
            : doc['headerDate']?.toString().trim().isNotEmpty == true
                ? doc['headerDate']!.trim()
                : doc['reportDate']?.toString().trim() ?? '';
    final parts = dateStr.split(RegExp(r'[/.-]'));
    if (parts.length >= 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);
      if (d != null && m != null && y != null) return DateTime(y, m, d);
    }
    return DateTime.now();
  }
}
