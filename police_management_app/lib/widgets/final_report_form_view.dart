import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bilingual_field.dart';
import 'form_paper_page.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';
import 'responsive_field_row.dart';
import '../utils/form_io_terminology.dart';
import 'form_section_utils.dart';

class FinalReportFormView extends StatefulWidget {
  final bool readOnly;
  final Map<String, dynamic>? existingRecord;
  final String? formSection;
  final String? pageRange;

  const FinalReportFormView({
    super.key,
    this.readOnly = false,
    this.existingRecord,
    this.formSection,
    this.pageRange,
  });

  @override
  State<FinalReportFormView> createState() => FinalReportFormViewState();
}

class FinalReportFormViewState extends State<FinalReportFormView> {
  static const kPartI = 'Final Report Part I';
  static const kPartII = 'Final Report Part II';
  static const kPartIII = 'Final Report Part III';
  static const _knownSectionIds = {kPartI, kPartII, kPartIII};

  bool _shows(String sectionId) => showsFormSection(
        activeSection: widget.formSection,
        sectionId: sectionId,
        knownSectionIds: _knownSectionIds,
      );

  bool get _showAll => showsAllFormSections(
        activeSection: widget.formSection,
        knownSectionIds: _knownSectionIds,
      );
  // Page 1 — sections 1–10
  final _distCtrl = TextEditingController();
  final _psCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _firNoCtrl = TextEditingController();
  final _firYearSuffixCtrl = TextEditingController(
    text: DateTime.now().year.toString().substring(2),
  );
  final _headerDateCtrl = TextEditingController();
  final _courtCtrl = TextEditingController();
  final _courtDistCtrl = TextEditingController();
  final _reportNoCtrl = TextEditingController();
  final _reportYearSuffixCtrl = TextEditingController(
    text: DateTime.now().year.toString().substring(2),
  );
  final _reportDateCtrl = TextEditingController();
  final _actCtrl = TextEditingController(text: 'Bharatiya Nyaya Sanhita 2023');
  final _sectionCtrl = TextEditingController();
  final _reportTypeCtrl = TextEditingController();
  final _frUnoccurredCtrl = TextEditingController();
  final _chargeSheetedCtrl = TextEditingController();
  final _originalSupplementaryCtrl = TextEditingController();
  final _ioNameCtrl = TextEditingController();
  final _ioRankCtrl = TextEditingController();
  final _ioNoCtrl = TextEditingController();
  final _ioPsCtrl = TextEditingController();
  final _complainantNameCtrl = TextEditingController();
  final _complainantFatherCtrl = TextEditingController();

  static const _propertyRowCount = 2;
  static const _witnessRowCount = 7;

  late final List<TextEditingController> _propDescCtrls;
  late final List<TextEditingController> _propValueCtrls;
  late final List<TextEditingController> _propRegCtrls;
  late final List<TextEditingController> _propFromCtrls;
  late final List<TextEditingController> _propDisposalCtrls;

  late final List<TextEditingController> _witnessNameCtrls;
  late final List<TextEditingController> _witnessAgeCtrls;
  late final List<TextEditingController> _witnessOccupationCtrls;
  late final List<TextEditingController> _witnessAddressCtrls;

  static const _witnessEvidenceLabels = [
    'तक्रारदार / साक्षीदार',
    'पंच क्रमांक १',
    'पंच क्रमांक २',
    'साक्षीदार',
    'साक्षीदार',
    'गुन्हा दाखल करणार अधिकारी',
    'तपासी अधिकारी',
  ];

  // Page 2 — section 11 accused
  final _accNameCtrl = TextEditingController();
  final _accNameVerifiedCtrl = TextEditingController();
  final _accFatherCtrl = TextEditingController();
  final _accDobCtrl = TextEditingController();
  final _accAgeCtrl = TextEditingController();
  final _accSexCtrl = TextEditingController();
  final _accNationalityCtrl = TextEditingController();
  final _accPassportCtrl = TextEditingController();
  final _accPassportDateCtrl = TextEditingController();
  final _accPassportPlaceCtrl = TextEditingController();
  final _accReligionCtrl = TextEditingController();
  final _accScStCtrl = TextEditingController();
  final _accOccupationCtrl = TextEditingController();
  final _accAddressCtrl = TextEditingController();
  final _accAddressVerifiedCtrl = TextEditingController();
  final _accProvCriminalNoCtrl = TextEditingController();
  final _accRegularCriminalNoCtrl = TextEditingController();
  final _accArrestDateCtrl = TextEditingController();
  final _accBailDateCtrl = TextEditingController();
  final _accForwardedCourtCtrl = TextEditingController();
  final _accActsSectionsCtrl = TextEditingController();
  final _accBailersCtrl = TextEditingController();
  final _accPrevConvictionsCtrl = TextEditingController();
  final _accStatusCtrl = TextEditingController();
  final _notChargeSheetedCtrl = TextEditingController();

  // Page 3 — sections 14–15
  final _falseFirActionCtrl = TextEditingController();
  final _labAnalysisCtrl = TextEditingController();

  // Page 4 — sections 16–18
  final _briefFactsCtrl = TextEditingController();
  final _referNoticeServedCtrl = TextEditingController();
  final _referNoticeDateCtrl = TextEditingController();
  final _dispatchedOnCtrl = TextEditingController();
  final _shoNameCtrl = TextEditingController();
  final _shoRankCtrl = TextEditingController();
  final _shoNoCtrl = TextEditingController();
  final _shoPsCtrl = TextEditingController();
  final _submitIoNameCtrl = TextEditingController();
  final _submitIoRankCtrl = TextEditingController();
  final _submitIoNoCtrl = TextEditingController();
  final _submitIoPsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _propDescCtrls = List.generate(_propertyRowCount, (_) => TextEditingController());
    _propValueCtrls = List.generate(_propertyRowCount, (_) => TextEditingController());
    _propRegCtrls = List.generate(_propertyRowCount, (_) => TextEditingController());
    _propFromCtrls = List.generate(_propertyRowCount, (_) => TextEditingController());
    _propDisposalCtrls = List.generate(_propertyRowCount, (_) => TextEditingController());
    _witnessNameCtrls = List.generate(_witnessRowCount, (_) => TextEditingController());
    _witnessAgeCtrls = List.generate(_witnessRowCount, (_) => TextEditingController());
    _witnessOccupationCtrls = List.generate(_witnessRowCount, (_) => TextEditingController());
    _witnessAddressCtrls = List.generate(_witnessRowCount, (_) => TextEditingController());
    if (widget.existingRecord != null) {
      hydrateFrom(widget.existingRecord!);
    }
  }

  @override
  void dispose() {
    _distCtrl.dispose();
    _psCtrl.dispose();
    _yearCtrl.dispose();
    _firNoCtrl.dispose();
    _firYearSuffixCtrl.dispose();
    _headerDateCtrl.dispose();
    _courtCtrl.dispose();
    _courtDistCtrl.dispose();
    _reportNoCtrl.dispose();
    _reportYearSuffixCtrl.dispose();
    _reportDateCtrl.dispose();
    _actCtrl.dispose();
    _sectionCtrl.dispose();
    _reportTypeCtrl.dispose();
    _frUnoccurredCtrl.dispose();
    _chargeSheetedCtrl.dispose();
    _originalSupplementaryCtrl.dispose();
    _ioNameCtrl.dispose();
    _ioRankCtrl.dispose();
    _ioNoCtrl.dispose();
    _ioPsCtrl.dispose();
    _complainantNameCtrl.dispose();
    _complainantFatherCtrl.dispose();
    for (final c in [
      ..._propDescCtrls,
      ..._propValueCtrls,
      ..._propRegCtrls,
      ..._propFromCtrls,
      ..._propDisposalCtrls,
      ..._witnessNameCtrls,
      ..._witnessAgeCtrls,
      ..._witnessOccupationCtrls,
      ..._witnessAddressCtrls,
    ]) {
      c.dispose();
    }
    _accNameCtrl.dispose();
    _accNameVerifiedCtrl.dispose();
    _accFatherCtrl.dispose();
    _accDobCtrl.dispose();
    _accAgeCtrl.dispose();
    _accSexCtrl.dispose();
    _accNationalityCtrl.dispose();
    _accPassportCtrl.dispose();
    _accPassportDateCtrl.dispose();
    _accPassportPlaceCtrl.dispose();
    _accReligionCtrl.dispose();
    _accScStCtrl.dispose();
    _accOccupationCtrl.dispose();
    _accAddressCtrl.dispose();
    _accAddressVerifiedCtrl.dispose();
    _accProvCriminalNoCtrl.dispose();
    _accRegularCriminalNoCtrl.dispose();
    _accArrestDateCtrl.dispose();
    _accBailDateCtrl.dispose();
    _accForwardedCourtCtrl.dispose();
    _accActsSectionsCtrl.dispose();
    _accBailersCtrl.dispose();
    _accPrevConvictionsCtrl.dispose();
    _accStatusCtrl.dispose();
    _notChargeSheetedCtrl.dispose();
    _falseFirActionCtrl.dispose();
    _labAnalysisCtrl.dispose();
    _briefFactsCtrl.dispose();
    _referNoticeServedCtrl.dispose();
    _referNoticeDateCtrl.dispose();
    _dispatchedOnCtrl.dispose();
    _shoNameCtrl.dispose();
    _shoRankCtrl.dispose();
    _shoNoCtrl.dispose();
    _shoPsCtrl.dispose();
    _submitIoNameCtrl.dispose();
    _submitIoRankCtrl.dispose();
    _submitIoNoCtrl.dispose();
    _submitIoPsCtrl.dispose();
    super.dispose();
  }

  void hydrateFrom(Map<String, dynamic> data) {
    setState(() {
      _distCtrl.text = data['dist']?.toString() ?? '';
      _psCtrl.text = data['ps']?.toString() ?? '';
      _yearCtrl.text = data['year']?.toString() ?? '';
      _firNoCtrl.text = data['firNo']?.toString() ?? '';
      _firYearSuffixCtrl.text = data['firYearSuffix']?.toString() ?? '';
      _headerDateCtrl.text = data['headerDate']?.toString() ?? '';
      _courtCtrl.text = data['court']?.toString() ?? '';
      _courtDistCtrl.text = data['courtDist']?.toString() ?? '';
      _reportNoCtrl.text = data['reportNo']?.toString() ?? '';
      _reportYearSuffixCtrl.text = data['reportYearSuffix']?.toString() ?? '';
      _reportDateCtrl.text = data['reportDate']?.toString() ?? '';
      _actCtrl.text = data['act']?.toString() ?? '';
      _sectionCtrl.text = data['section']?.toString() ?? '';
      _reportTypeCtrl.text = data['reportType']?.toString() ?? '';
      _frUnoccurredCtrl.text = data['frUnoccurred']?.toString() ?? '';
      _chargeSheetedCtrl.text = data['chargeSheeted']?.toString() ?? '';
      _originalSupplementaryCtrl.text = data['originalSupplementary']?.toString() ?? '';
      _ioNameCtrl.text = data['ioName']?.toString() ?? '';
      _ioRankCtrl.text = data['ioRank']?.toString() ?? '';
      _ioNoCtrl.text = data['ioNo']?.toString() ?? '';
      _ioPsCtrl.text = data['ioPs']?.toString() ?? '';
      _complainantNameCtrl.text = data['complainantName']?.toString() ?? '';
      _complainantFatherCtrl.text = data['complainantFather']?.toString() ?? '';

      for (var i = 0; i < _propertyRowCount; i++) {
        final n = '${i + 1}';
        _propDescCtrls[i].text = data['prop${n}Desc']?.toString() ?? '';
        _propValueCtrls[i].text = data['prop${n}Value']?.toString() ?? '';
        _propRegCtrls[i].text = data['prop${n}Reg']?.toString() ?? '';
        _propFromCtrls[i].text = data['prop${n}From']?.toString() ?? '';
        _propDisposalCtrls[i].text = data['prop${n}Disposal']?.toString() ?? '';
      }
      for (var i = 0; i < _witnessRowCount; i++) {
        final n = '${i + 1}';
        _witnessNameCtrls[i].text = data['witness${n}Name']?.toString() ?? '';
        _witnessAgeCtrls[i].text = data['witness${n}Age']?.toString() ?? '';
        _witnessOccupationCtrls[i].text = data['witness${n}Occupation']?.toString() ?? '';
        _witnessAddressCtrls[i].text = data['witness${n}Address']?.toString() ?? '';
      }

      _accNameCtrl.text = data['accName']?.toString() ?? '';
      _accNameVerifiedCtrl.text = data['accNameVerified']?.toString() ?? '';
      _accFatherCtrl.text = data['accFather']?.toString() ?? '';
      _accDobCtrl.text = data['accDob']?.toString() ?? '';
      _accAgeCtrl.text = data['accAge']?.toString() ?? '';
      _accSexCtrl.text = data['accSex']?.toString() ?? '';
      _accNationalityCtrl.text = data['accNationality']?.toString() ?? '';
      _accPassportCtrl.text = data['accPassport']?.toString() ?? '';
      _accPassportDateCtrl.text = data['accPassportDate']?.toString() ?? '';
      _accPassportPlaceCtrl.text = data['accPassportPlace']?.toString() ?? '';
      _accReligionCtrl.text = data['accReligion']?.toString() ?? '';
      _accScStCtrl.text = data['accScSt']?.toString() ?? '';
      _accOccupationCtrl.text = data['accOccupation']?.toString() ?? '';
      _accAddressCtrl.text = data['accAddress']?.toString() ?? '';
      _accAddressVerifiedCtrl.text = data['accAddressVerified']?.toString() ?? '';
      _accProvCriminalNoCtrl.text = data['accProvCriminalNo']?.toString() ?? '';
      _accRegularCriminalNoCtrl.text = data['accRegularCriminalNo']?.toString() ?? '';
      _accArrestDateCtrl.text = data['accArrestDate']?.toString() ?? '';
      _accBailDateCtrl.text = data['accBailDate']?.toString() ?? '';
      _accForwardedCourtCtrl.text = data['accForwardedCourt']?.toString() ?? '';
      _accActsSectionsCtrl.text = data['accActsSections']?.toString() ?? '';
      _accBailersCtrl.text = data['accBailers']?.toString() ?? '';
      _accPrevConvictionsCtrl.text = data['accPrevConvictions']?.toString() ?? '';
      _accStatusCtrl.text = data['accStatus']?.toString() ?? '';
      _notChargeSheetedCtrl.text = data['notChargeSheeted']?.toString() ?? '';
      _falseFirActionCtrl.text = data['falseFirAction']?.toString() ?? '';
      _labAnalysisCtrl.text = data['labAnalysis']?.toString() ?? '';
      _briefFactsCtrl.text = data['briefFacts']?.toString() ?? '';
      _referNoticeServedCtrl.text = data['referNoticeServed']?.toString() ?? '';
      _referNoticeDateCtrl.text = data['referNoticeDate']?.toString() ?? '';
      _dispatchedOnCtrl.text = data['dispatchedOn']?.toString() ?? '';
      _shoNameCtrl.text = data['shoName']?.toString() ?? '';
      _shoRankCtrl.text = data['shoRank']?.toString() ?? '';
      _shoNoCtrl.text = data['shoNo']?.toString() ?? '';
      _shoPsCtrl.text = data['shoPs']?.toString() ?? '';
      _submitIoNameCtrl.text = data['submitIoName']?.toString() ?? '';
      _submitIoRankCtrl.text = data['submitIoRank']?.toString() ?? '';
      _submitIoNoCtrl.text = data['submitIoNo']?.toString() ?? '';
      _submitIoPsCtrl.text = data['submitIoPs']?.toString() ?? '';
    });
  }

  Map<String, dynamic> collectData() {
    final map = <String, dynamic>{
      'dist': _distCtrl.text.trim(),
      'ps': _psCtrl.text.trim(),
      'year': _yearCtrl.text.trim(),
      'firNo': _firNoCtrl.text.trim(),
      'firYearSuffix': _firYearSuffixCtrl.text.trim(),
      'headerDate': _headerDateCtrl.text.trim(),
      'court': _courtCtrl.text.trim(),
      'courtDist': _courtDistCtrl.text.trim(),
      'reportNo': _reportNoCtrl.text.trim(),
      'reportYearSuffix': _reportYearSuffixCtrl.text.trim(),
      'reportDate': _reportDateCtrl.text.trim(),
      'act': _actCtrl.text.trim(),
      'section': _sectionCtrl.text.trim(),
      'reportType': _reportTypeCtrl.text.trim(),
      'frUnoccurred': _frUnoccurredCtrl.text.trim(),
      'chargeSheeted': _chargeSheetedCtrl.text.trim(),
      'originalSupplementary': _originalSupplementaryCtrl.text.trim(),
      'ioName': _ioNameCtrl.text.trim(),
      'ioRank': _ioRankCtrl.text.trim(),
      'ioNo': _ioNoCtrl.text.trim(),
      'ioPs': _ioPsCtrl.text.trim(),
      'complainantName': _complainantNameCtrl.text.trim(),
      'complainantFather': _complainantFatherCtrl.text.trim(),
      'accName': _accNameCtrl.text.trim(),
      'accNameVerified': _accNameVerifiedCtrl.text.trim(),
      'accFather': _accFatherCtrl.text.trim(),
      'accDob': _accDobCtrl.text.trim(),
      'accAge': _accAgeCtrl.text.trim(),
      'accSex': _accSexCtrl.text.trim(),
      'accNationality': _accNationalityCtrl.text.trim(),
      'accPassport': _accPassportCtrl.text.trim(),
      'accPassportDate': _accPassportDateCtrl.text.trim(),
      'accPassportPlace': _accPassportPlaceCtrl.text.trim(),
      'accReligion': _accReligionCtrl.text.trim(),
      'accScSt': _accScStCtrl.text.trim(),
      'accOccupation': _accOccupationCtrl.text.trim(),
      'accAddress': _accAddressCtrl.text.trim(),
      'accAddressVerified': _accAddressVerifiedCtrl.text.trim(),
      'accProvCriminalNo': _accProvCriminalNoCtrl.text.trim(),
      'accRegularCriminalNo': _accRegularCriminalNoCtrl.text.trim(),
      'accArrestDate': _accArrestDateCtrl.text.trim(),
      'accBailDate': _accBailDateCtrl.text.trim(),
      'accForwardedCourt': _accForwardedCourtCtrl.text.trim(),
      'accActsSections': _accActsSectionsCtrl.text.trim(),
      'accBailers': _accBailersCtrl.text.trim(),
      'accPrevConvictions': _accPrevConvictionsCtrl.text.trim(),
      'accStatus': _accStatusCtrl.text.trim(),
      'notChargeSheeted': _notChargeSheetedCtrl.text.trim(),
      'falseFirAction': _falseFirActionCtrl.text.trim(),
      'labAnalysis': _labAnalysisCtrl.text.trim(),
      'briefFacts': _briefFactsCtrl.text.trim(),
      'referNoticeServed': _referNoticeServedCtrl.text.trim(),
      'referNoticeDate': _referNoticeDateCtrl.text.trim(),
      'dispatchedOn': _dispatchedOnCtrl.text.trim(),
      'shoName': _shoNameCtrl.text.trim(),
      'shoRank': _shoRankCtrl.text.trim(),
      'shoNo': _shoNoCtrl.text.trim(),
      'shoPs': _shoPsCtrl.text.trim(),
      'submitIoName': _submitIoNameCtrl.text.trim(),
      'submitIoRank': _submitIoRankCtrl.text.trim(),
      'submitIoNo': _submitIoNoCtrl.text.trim(),
      'submitIoPs': _submitIoPsCtrl.text.trim(),
      'formSection': widget.formSection ?? '',
      'pageRange': widget.pageRange ?? '',
    };
    for (var i = 0; i < _propertyRowCount; i++) {
      final n = '${i + 1}';
      map['prop${n}Desc'] = _propDescCtrls[i].text.trim();
      map['prop${n}Value'] = _propValueCtrls[i].text.trim();
      map['prop${n}Reg'] = _propRegCtrls[i].text.trim();
      map['prop${n}From'] = _propFromCtrls[i].text.trim();
      map['prop${n}Disposal'] = _propDisposalCtrls[i].text.trim();
    }
    for (var i = 0; i < _witnessRowCount; i++) {
      final n = '${i + 1}';
      map['witness${n}Name'] = _witnessNameCtrls[i].text.trim();
      map['witness${n}Age'] = _witnessAgeCtrls[i].text.trim();
      map['witness${n}Occupation'] = _witnessOccupationCtrls[i].text.trim();
      map['witness${n}Address'] = _witnessAddressCtrls[i].text.trim();
    }
    return map;
  }

  Widget _tableCellInput(TextEditingController ctrl, TextStyle serifStyle) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: BilingualSimpleUnderlineInput(
        controller: ctrl,
        serifStyle: serifStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle serifStyle = FormTypography.serifStyle();
    final TextStyle marathiLabelStyle = FormTypography.marathiLabelStyle();

    return FormViewScaffold(
      readOnly: widget.readOnly,
      children: [
        if (_shows(kPartI))
              FormPaperPage(
                formLabel: widget.pageRange ?? 'Page 70',
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'FINAL REPORT FORM',
                          style: serifStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'अंतिम अहवाल नमुना',
                          style: GoogleFonts.notoSansDevanagari(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '( UNDER SECTION 193 B.N.S.S.2023 )',
                          style: serifStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  BilingualFieldRow(fields: [
                    BilingualWideField(
                      label: 'IN THE COURT OF : ',
                      marathiLabel: 'मा.वि.न्यायदंडाधिकारी प्रथम श्रेणी, न्यायालय',
                      controller: _courtCtrl,
                      serifStyle: serifStyle,
                      marathiLabelStyle: marathiLabelStyle,
                    ),
                    BilingualField(
                      label: 'Dist : ',
                      marathiLabel: 'जिल्हा',
                      controller: _courtDistCtrl,
                      serifStyle: serifStyle,
                      marathiLabelStyle: marathiLabelStyle,
                    ),
                  ]),
                  const SizedBox(height: 16),
                  ResponsiveFieldRow(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: BilingualField(label: '1.Dist : ', marathiLabel: 'जिल्हा', controller: _distCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle)),
                      const SizedBox(width: 8),
                      Expanded(child: BilingualField(label: 'P.S: ', marathiLabel: 'पोलीस ठाणे', controller: _psCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle)),
                      const SizedBox(width: 8),
                      Expanded(child: BilingualField(label: 'Year : ', marathiLabel: 'वर्ष', controller: _yearCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ResponsiveFieldRow(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: BilingualField(label: 'FIR No : ', marathiLabel: 'पहिली खबर क्र.', controller: _firNoCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle)),
                            Padding(padding: const EdgeInsets.only(top: 2), child: Text('/20', style: serifStyle)),
                            SizedBox(width: 35, child: BilingualSimpleUnderlineInput(controller: _firYearSuffixCtrl, serifStyle: serifStyle)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: BilingualField(label: 'Date : ', marathiLabel: 'तारीख', controller: _headerDateCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ResponsiveFieldRow(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 3,
                        child: BilingualField(label: '2. Final Report/Charge Sheet No. ', marathiLabel: 'अंतिम अहवाल / आरोप पत्र क्र.', controller: _reportNoCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                      ),
                      Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('/20', style: serifStyle)),
                      SizedBox(width: 40, child: BilingualSimpleUnderlineInput(controller: _reportYearSuffixCtrl, serifStyle: serifStyle)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BilingualField(label: '3. Date: ', marathiLabel: 'दिनांक', controller: _reportDateCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 12),
                  BilingualFieldRow(fields: [
                    BilingualField(label: '4. Act : ', marathiLabel: 'भारतीय न्याय संहिता २०२३', controller: _actCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: 'Section: ', marathiLabel: 'कलम', controller: _sectionCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  ]),
                  const SizedBox(height: 12),
                  BilingualMultilineField(
                    label: '5. Type of Final Form / Report :',
                    marathiLabel: 'अंतिम अहवालाचा प्रकार',
                    controller: _reportTypeCtrl,
                    minLines: 2,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualMultilineField(
                    label: '6. If F.R. Unoccured :',
                    marathiLabel: 'जर अंतिम अहवालाचा प्रकार घडला नाही',
                    controller: _frUnoccurredCtrl,
                    minLines: 2,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualFieldRow(fields: [
                    BilingualField(label: '7. If Charge Sheeted : ', marathiLabel: 'जर आरोपपत्र ठेवले', controller: _chargeSheetedCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: 'Original / Supplementary : ', marathiLabel: 'मुळ/पुरवणी', controller: _originalSupplementaryCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  ]),
                  const SizedBox(height: 12),
                  BilingualFieldRow(fields: [
                    BilingualField(label: '8. Name of the I.O : ', marathiLabel: '${FormIoTerminology.officer} — ${FormIoTerminology.name}', controller: _ioNameCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: 'Rank : ', marathiLabel: FormIoTerminology.rank, controller: _ioRankCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  ]),
                  BilingualFieldRow(fields: [
                    BilingualField(label: 'No. : ', marathiLabel: 'बक्कल नंबर', controller: _ioNoCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: 'P.S. : ', marathiLabel: 'पोलीस स्टेशन', controller: _ioPsCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  ]),
                  const SizedBox(height: 12),
                  BilingualWideField(label: '9. (a) Name of Complainant/Informant : ', marathiLabel: 'तक्रारदाराचे / खबरिचे नांव', controller: _complainantNameCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  BilingualWideField(label: '(b) Father\'s/Husband\'s Name : ', marathiLabel: 'पित्याचे / पतीचे नांव', controller: _complainantFatherCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 16),
                  BilingualSectionHeader(
                    label: '10. Details of Properties/Articles/Documents recovered/seized during investigation and relied upon :',
                    marathiLabel: 'तपासणीच्या वेळी परत मिळविलेल्या/जप्त केलेल्या आणि अवलंबून राहिलेल्या मालमत्तेचा/वस्तूंचा तपशील',
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: Colors.black87),
                    columnWidths: const {
                      0: FixedColumnWidth(36),
                      1: FlexColumnWidth(3),
                      2: FlexColumnWidth(1.2),
                      3: FlexColumnWidth(1.5),
                      4: FlexColumnWidth(2),
                      5: FlexColumnWidth(1.2),
                    },
                    children: [
                      TableRow(
                        children: [
                          _tableHeader('Sr.No\nअ.क्र', serifStyle),
                          _tableHeader('Property Description\nमालमत्तेचे वर्णन', serifStyle),
                          _tableHeader('Estimated Value\n(Rs.)', serifStyle),
                          _tableHeader('P.S. Property\nRegister No.', serifStyle),
                          _tableHeader('From whom/where\nRecovered or Seized', serifStyle),
                          _tableHeader('Disposal\nविल्हेवाट', serifStyle),
                        ],
                      ),
                      for (var i = 0; i < _propertyRowCount; i++)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('${i + 1}.', style: serifStyle.copyWith(fontWeight: FontWeight.bold)),
                            ),
                            _tableCellInput(_propDescCtrls[i], serifStyle),
                            _tableCellInput(_propValueCtrls[i], serifStyle),
                            _tableCellInput(_propRegCtrls[i], serifStyle),
                            _tableCellInput(_propFromCtrls[i], serifStyle),
                            _tableCellInput(_propDisposalCtrls[i], serifStyle),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FormMrwFooter(serifStyle: serifStyle),
                ],
              ),
        if (_shows(kPartI) && (_shows(kPartII) || _showAll))
              const SizedBox(height: 24),

              // PAGE 2 — section 11–12 (Form : 5-B)
        if (_shows(kPartII))
              FormPaperPage(
                formLabel: widget.pageRange ?? 'Page 71',
                children: [
                  BilingualSectionHeader(
                    label: '11. i) Particulars of accused persons charge-sheeted ( use separate sheet for each accused ) :',
                    marathiLabel: 'आरोपपत्र ठेवलेल्या आरोपीचा तपशिल ( प्रत्येक आरोपीसाठी स्वतंत्र कागद वापरावा )',
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualFieldRow(fields: [
                    BilingualField(label: '(i) Name : ', marathiLabel: 'नाव', controller: _accNameCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: 'Where verified : ', marathiLabel: 'पडताळले किंवा काय', controller: _accNameVerifiedCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  ]),
                  const SizedBox(height: 8),
                  BilingualWideField(label: '(ii) Father\'s/Husband\'s Name : ', marathiLabel: 'पित्याचे/पतीचे नाव', controller: _accFatherCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  BilingualFieldRow(fields: [
                    BilingualField(label: '(iii) Date/Year of Birth : ', marathiLabel: 'जन्मतारीख', controller: _accDobCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: 'Age : ', marathiLabel: 'वय', controller: _accAgeCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  ]),
                  const SizedBox(height: 8),
                  BilingualFieldRow(fields: [
                    BilingualField(label: '(iv) Sex : ', marathiLabel: 'लिंग', controller: _accSexCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: '(v) Nationality : ', marathiLabel: 'राष्ट्रीयत्व', controller: _accNationalityCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  ]),
                  const SizedBox(height: 8),
                  BilingualFieldRow(fields: [
                    BilingualField(label: '(vi) Passport No. : ', marathiLabel: 'पारपत्र क्र.', controller: _accPassportCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: 'Date of issue : ', marathiLabel: 'दिल्याची तारीख', controller: _accPassportDateCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: 'Place of Issue : ', marathiLabel: 'दिल्याचे ठिकाण', controller: _accPassportPlaceCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  ]),
                  const SizedBox(height: 8),
                  BilingualFieldRow(fields: [
                    BilingualField(label: '(vii) Religion : ', marathiLabel: 'धर्म', controller: _accReligionCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: '(viii) Whether SC/ST : ', marathiLabel: 'अनुसूचित जातीचा/जमातीचा आहे का', controller: _accScStCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  ]),
                  const SizedBox(height: 8),
                  BilingualWideField(label: '(ix) Occupation : ', marathiLabel: 'व्यवसाय', controller: _accOccupationCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  BilingualWideField(label: '(x) Address : ', marathiLabel: 'पत्ता', controller: _accAddressCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  BilingualField(label: 'Whether verified : ', marathiLabel: 'पडताळला किंवा काय', controller: _accAddressVerifiedCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  BilingualWideField(label: '(xi) Provisional Criminal No. : ', marathiLabel: 'तात्पुरता गुन्हेगार क्र.', controller: _accProvCriminalNoCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  BilingualWideField(label: '(xii) Regular Criminal No. (if known) : ', marathiLabel: 'नियमित गुन्हेगार क्र. ( माहीत असल्यास )', controller: _accRegularCriminalNoCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  BilingualWideField(label: '(xiii) Date of Arrest : ', marathiLabel: 'अटकेची तारीख', controller: _accArrestDateCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  BilingualWideField(label: '(xiv) Date of release on bail : ', marathiLabel: 'जामीनावर सोडल्याची तारीख', controller: _accBailDateCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  BilingualWideField(label: '(xv) Date on which forwarded to court : ', marathiLabel: 'न्यायालयात पाठविल्याची तारीख', controller: _accForwardedCourtCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  BilingualWideField(label: '(xvi) Under Acts & Section : ', marathiLabel: 'कोणत्या अधिनियमाखाली व कलमाखाली', controller: _accActsSectionsCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  BilingualWideField(label: '(xvii) Name(s) of bailers/sureties and Address : ', marathiLabel: 'जामीनदारांची नावे व पत्ते', controller: _accBailersCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  BilingualWideField(label: '(xviii) Previous convictions with case reference : ', marathiLabel: 'प्रकरणाच्या संदर्भासह पूर्वीची अपराधसिध्दी', controller: _accPrevConvictionsCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  BilingualWideField(label: '(xix) Status of the accused : ', marathiLabel: 'आरोपीची स्थिती', controller: _accStatusCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  Text(
                    'Forwarded / Bailed by Police / In Police Custody / Bailed by Court / In Judicial Custody / Absconding / Proclaimed Offender',
                    style: serifStyle.copyWith(fontSize: 11),
                  ),
                  Text(
                    'पुढे पाठवले / पोलिसांनी जामीनावर सोडले / पोलीस कोठडीत / न्यायालयाने जामीन मंजुर केला / न्यायालयीन कोठडीत / फरारी / उद्घोषित अपराधी',
                    style: marathiLabelStyle.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 16),
                  BilingualMultilineField(
                    label: '12. Particulars of accused persons not charge-sheeted :',
                    marathiLabel: 'आरोप पत्र न ठेवलेल्या आरोपीचा तपशिल',
                    controller: _notChargeSheetedCtrl,
                    minLines: 2,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  FormMrwFooter(serifStyle: serifStyle),
                ],
              ),
        if (_shows(kPartII) && (_shows(kPartIII) || _showAll))
              const SizedBox(height: 24),

        if (_shows(kPartIII)) ...[
              FormPaperPage(
                formLabel: widget.pageRange ?? 'Pages 72–73',
                children: [
                  BilingualSectionHeader(
                    label: '13. Description of the verified witnesses :',
                    marathiLabel: 'पडताळलेल्या साक्षीदारांचे विवरण',
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 4),
                  Center(child: Text('List of Witnesses / साक्षीदारांची यादी', style: serifStyle.copyWith(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: Colors.black87),
                    columnWidths: const {
                      0: FixedColumnWidth(32),
                      1: FlexColumnWidth(2),
                      2: FixedColumnWidth(48),
                      3: FlexColumnWidth(1.2),
                      4: FlexColumnWidth(2),
                      5: FlexColumnWidth(1.8),
                    },
                    children: [
                      TableRow(
                        children: [
                          _tableHeader('Sr.No\nअ.क्र', serifStyle),
                          _tableHeader('Name of Witness\nसाक्षीदारांचे नांव', serifStyle),
                          _tableHeader('Age\nवय', serifStyle),
                          _tableHeader('Occupation\nव्यवसाय', serifStyle),
                          _tableHeader('Address\nराहण्याचा पत्ता', serifStyle),
                          _tableHeader('Type of evidence\nसादर करावयाच्या पुराव्याचा प्रकार', serifStyle),
                        ],
                      ),
                      for (var i = 0; i < _witnessRowCount; i++)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('${i + 1}', style: serifStyle.copyWith(fontWeight: FontWeight.bold)),
                            ),
                            _tableCellInput(_witnessNameCtrls[i], serifStyle),
                            _tableCellInput(_witnessAgeCtrls[i], serifStyle),
                            _tableCellInput(_witnessOccupationCtrls[i], serifStyle),
                            _tableCellInput(_witnessAddressCtrls[i], serifStyle),
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                _witnessEvidenceLabels[i],
                                style: marathiLabelStyle.copyWith(fontSize: 9),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BilingualMultilineField(
                    label: '14. If F. I. R. is False, indicate action taken or proposed to be taken u/s 182/211 I. P. C. :',
                    marathiLabel: 'तक्रार खोटी असेल तर भादंवि १८२/२११ अन्वये केलेली किंवा करावयाची कार्यवाही नमुद करावी',
                    controller: _falseFirActionCtrl,
                    minLines: 3,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualWideField(
                    label: '15. Result of laboratory analysis : ',
                    marathiLabel: 'प्रयोगशाळा विश्लेषकाचा निष्कर्ष',
                    controller: _labAnalysisCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualMultilineField(
                    label: '16. Brief Facts of the Case (Add separate sheet, if necessary.) :',
                    marathiLabel: 'थोडक्यात माहिती ( आवश्यक असल्यास वेगळा कागद जोडावा. )',
                    controller: _briefFactsCtrl,
                    minLines: 14,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 16),
                  BilingualFieldRow(fields: [
                    BilingualField(label: '17. Refer Notice Served : ', marathiLabel: 'Acknowledgement to be placed', controller: _referNoticeServedCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: 'Date : ', marathiLabel: 'तारीख', controller: _referNoticeDateCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  ]),
                  const SizedBox(height: 12),
                  BilingualField(label: '18. Dispatched on : ', marathiLabel: 'पाठविल्याची तारीख', controller: _dispatchedOnCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BilingualSectionHeader(
                              label: 'Forwarded by Station House Officer/officer in-charge',
                              marathiLabel: 'पोलीस ठाणे प्रभारी अधिकारी',
                              serifStyle: serifStyle,
                              marathiLabelStyle: marathiLabelStyle,
                            ),
                            const SizedBox(height: 8),
                            BilingualField(label: 'Name : ', marathiLabel: 'नांव', controller: _shoNameCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualField(label: 'Rank : ', marathiLabel: 'पद', controller: _shoRankCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualField(label: 'No : ', marathiLabel: 'बक्कल नंबर', controller: _shoNoCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualField(label: 'Police Station : ', marathiLabel: 'पोलीस स्टेशन', controller: _shoPsCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BilingualSectionHeader(
                              label: 'Signature of the Investigation Officer submitting the Final Report/Charge Sheet.',
                              marathiLabel: FormIoTerminology.submittingSignatureHeader,
                              serifStyle: serifStyle,
                              marathiLabelStyle: marathiLabelStyle,
                            ),
                            const SizedBox(height: 8),
                            BilingualField(label: 'Name : ', marathiLabel: FormIoTerminology.name, controller: _submitIoNameCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualField(label: 'Rank : ', marathiLabel: FormIoTerminology.rank, controller: _submitIoRankCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualField(label: 'No. : ', marathiLabel: FormIoTerminology.badgeNo, controller: _submitIoNoCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualField(label: 'Police Station : ', marathiLabel: 'पोलीस स्टेशन', controller: _submitIoPsCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FormMrwFooter(serifStyle: serifStyle),
                ],
              ),
        ],
            ],
    );
  }

  Widget _tableHeader(String text, TextStyle serifStyle) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(
        text,
        style: serifStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
