import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'responsive_field_row.dart';
import 'bilingual_field.dart';
import 'form_paper_page.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';
import '../utils/form_io_terminology.dart';
import 'form_section_utils.dart';

class CrimeDetailFormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const CrimeDetailFormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<CrimeDetailFormView> createState() => CrimeDetailFormViewState();
}

class CrimeDetailFormViewState extends State<CrimeDetailFormView> {
  static const kForm2A = 'Form 2-A';
  static const kForm2B = 'Form 2-B';
  static const kForm2C = 'Form 2-C';
  static const _knownSectionIds = {kForm2A, kForm2B, kForm2C};

  bool _shows(String sectionId) => showsFormSection(
        activeSection: widget.formSection,
        sectionId: sectionId,
        knownSectionIds: _knownSectionIds,
      );

  bool get _showAll => showsAllFormSections(
        activeSection: widget.formSection,
        knownSectionIds: _knownSectionIds,
      );
  // Text Editing Controllers for all blank fields in Form 2-A
  final _districtCtrl = TextEditingController();
  final _psCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(text: DateTime.now().year.toString());
  final _firNoCtrl = TextEditingController();
  final _firYearSuffixCtrl = TextEditingController(text: DateTime.now().year.toString().substring(2));
  final _dateDayCtrl = TextEditingController();
  final _dateMonthCtrl = TextEditingController();
  final _dateYearCtrl = TextEditingController(text: DateTime.now().year.toString().substring(2));
  
  final _actSectionCtrl = TextEditingController();
  
  final _shownByNameCtrl = TextEditingController();
  final _shownByFatherHusbandCtrl = TextEditingController();
  final _shownByAddressCtrl = TextEditingController();
  
  final _typeOfCrimeCtrl = TextEditingController();
  final _majorHeadCtrl = TextEditingController();
  final _minorHeadCtrl = TextEditingController();
  final _methodCtrl = TextEditingController();
  final _method1Ctrl = TextEditingController();
  final _method2Ctrl = TextEditingController();
  final _method3Ctrl = TextEditingController();

  final _conveyancesCtrl = TextEditingController();
  final _characterAssumedCtrl = TextEditingController();
  final _languageSlangCtrl = TextEditingController();
  final _specialFeature1Ctrl = TextEditingController();
  final _specialFeature2Ctrl = TextEditingController();
  final _specialFeature3Ctrl = TextEditingController();
  final _placeOfOccurrenceTypeCtrl = TextEditingController();
  final _propertyInvolvedCtrl = TextEditingController();
  final _propertyType1Ctrl = TextEditingController();
  final _propertyType2Ctrl = TextEditingController();
  final _propertyType3Ctrl = TextEditingController();
  final _propertyType4Ctrl = TextEditingController();

  // Signature Block Controllers for Card 4 (Form 2-D)
  final _panchnamaDateCtrl = TextEditingController();
  final _panchnamaTimeCtrl = TextEditingController();
  final _pancha1NameCtrl = TextEditingController();
  final _pancha1AddressCtrl = TextEditingController();
  final _pancha2NameCtrl = TextEditingController();
  final _pancha2AddressCtrl = TextEditingController();
  final _pancha1SigCtrl = TextEditingController();
  final _pancha2SigCtrl = TextEditingController();
  final _ioNameCtrl = TextEditingController();
  final _ioRankCtrl = TextEditingController();
  final _ioBuckleNoCtrl = TextEditingController();
  final _panchnamaFormDateCtrl = TextEditingController();

  // Controllers for Form 2-B (Page 2)
  late final List<VictimRow> _victimRows;
  late final TextEditingController _motiveOfCrimeCtrl;
  TextEditingController? __placeDescriptionCtrl;
  TextEditingController get _placeDescriptionCtrl => __placeDescriptionCtrl ??= TextEditingController();
  TextEditingController? __propertyDetailsCtrl;
  TextEditingController get _propertyDetailsCtrl => __propertyDetailsCtrl ??= TextEditingController();
  TextEditingController? __placeDescriptionContCtrl;
  TextEditingController get _placeDescriptionContCtrl => __placeDescriptionContCtrl ??= TextEditingController();
  TextEditingController? __physicalEvidenceCtrl;
  TextEditingController get _physicalEvidenceCtrl => __physicalEvidenceCtrl ??= TextEditingController();
  String? _mapImagePath;

  @override
  void initState() {
    super.initState();
    _victimRows = [VictimRow()];
    _motiveOfCrimeCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _districtCtrl.dispose();
    _psCtrl.dispose();
    _yearCtrl.dispose();
    _firNoCtrl.dispose();
    _firYearSuffixCtrl.dispose();
    _dateDayCtrl.dispose();
    _dateMonthCtrl.dispose();
    _dateYearCtrl.dispose();
    _actSectionCtrl.dispose();
    _shownByNameCtrl.dispose();
    _shownByFatherHusbandCtrl.dispose();
    _shownByAddressCtrl.dispose();
    _typeOfCrimeCtrl.dispose();
    _majorHeadCtrl.dispose();
    _minorHeadCtrl.dispose();
    _methodCtrl.dispose();
    _method1Ctrl.dispose();
    _method2Ctrl.dispose();
    _method3Ctrl.dispose();
    _conveyancesCtrl.dispose();
    _characterAssumedCtrl.dispose();
    _languageSlangCtrl.dispose();
    _specialFeature1Ctrl.dispose();
    _specialFeature2Ctrl.dispose();
    _specialFeature3Ctrl.dispose();
    _placeOfOccurrenceTypeCtrl.dispose();
    _propertyInvolvedCtrl.dispose();
    _propertyType1Ctrl.dispose();
    _propertyType2Ctrl.dispose();
    _propertyType3Ctrl.dispose();
    _propertyType4Ctrl.dispose();
    _motiveOfCrimeCtrl.dispose();
    __placeDescriptionCtrl?.dispose();
    __propertyDetailsCtrl?.dispose();
    __placeDescriptionContCtrl?.dispose();
    __physicalEvidenceCtrl?.dispose();
    _panchnamaDateCtrl.dispose();
    _panchnamaTimeCtrl.dispose();
    _pancha1NameCtrl.dispose();
    _pancha1AddressCtrl.dispose();
    _pancha2NameCtrl.dispose();
    _pancha2AddressCtrl.dispose();
    _pancha1SigCtrl.dispose();
    _pancha2SigCtrl.dispose();
    _ioNameCtrl.dispose();
    _ioRankCtrl.dispose();
    _ioBuckleNoCtrl.dispose();
    _panchnamaFormDateCtrl.dispose();
    for (final r in _victimRows) {
      r.dispose();
    }
    super.dispose();
  }

  /// Collects the current state of all form inputs into a Map.
  Map<String, dynamic> collectData() {
    final victimsData = _victimRows.map((r) => r.toMap()).toList();
    return {
      'district': _districtCtrl.text.trim(),
      'ps': _psCtrl.text.trim(),
      'year': _yearCtrl.text.trim(),
      'firNo': _firNoCtrl.text.trim(),
      'firYearSuffix': _firYearSuffixCtrl.text.trim(),
      'dateDay': _dateDayCtrl.text.trim(),
      'dateMonth': _dateMonthCtrl.text.trim(),
      'dateYear': _dateYearCtrl.text.trim(),
      'actSection': _actSectionCtrl.text.trim(),
      'shownByName': _shownByNameCtrl.text.trim(),
      'shownByFatherHusband': _shownByFatherHusbandCtrl.text.trim(),
      'shownByAddress': _shownByAddressCtrl.text.trim(),
      'typeOfCrime': _typeOfCrimeCtrl.text.trim(),
      'majorHead': _majorHeadCtrl.text.trim(),
      'minorHead': _minorHeadCtrl.text.trim(),
      'method': _methodCtrl.text.trim(),
      'method1': _method1Ctrl.text.trim(),
      'method2': _method2Ctrl.text.trim(),
      'method3': _method3Ctrl.text.trim(),
      'conveyances': _conveyancesCtrl.text.trim(),
      'characterAssumed': _characterAssumedCtrl.text.trim(),
      'languageSlang': _languageSlangCtrl.text.trim(),
      'specialFeature1': _specialFeature1Ctrl.text.trim(),
      'specialFeature2': _specialFeature2Ctrl.text.trim(),
      'specialFeature3': _specialFeature3Ctrl.text.trim(),
      'placeOfOccurrenceType': _placeOfOccurrenceTypeCtrl.text.trim(),
      'propertyInvolved': _propertyInvolvedCtrl.text.trim(),
      'propertyType1': _propertyType1Ctrl.text.trim(),
      'propertyType2': _propertyType2Ctrl.text.trim(),
      'propertyType3': _propertyType3Ctrl.text.trim(),
      'propertyType4': _propertyType4Ctrl.text.trim(),
      'victims': victimsData,
      'motiveOfCrime': _motiveOfCrimeCtrl.text.trim(),
      'placeDescription': _placeDescriptionCtrl.text.trim(),
      'propertyDetails': _propertyDetailsCtrl.text.trim(),
      'placeDescriptionCont': _placeDescriptionContCtrl.text.trim(),
      'mapImagePath': _mapImagePath,
      'physicalEvidence': _physicalEvidenceCtrl.text.trim(),
      'panchnamaDate': _panchnamaDateCtrl.text.trim(),
      'panchnamaTime': _panchnamaTimeCtrl.text.trim(),
      'pancha1Name': _pancha1NameCtrl.text.trim(),
      'pancha1Address': _pancha1AddressCtrl.text.trim(),
      'pancha2Name': _pancha2NameCtrl.text.trim(),
      'pancha2Address': _pancha2AddressCtrl.text.trim(),
      'pancha1Sig': _pancha1SigCtrl.text.trim(),
      'pancha2Sig': _pancha2SigCtrl.text.trim(),
      'ioName': _ioNameCtrl.text.trim(),
      'ioRank': _ioRankCtrl.text.trim(),
      'ioBuckleNo': _ioBuckleNoCtrl.text.trim(),
      'panchnamaFormDate': _panchnamaFormDateCtrl.text.trim(),
      'formSection': widget.formSection ?? '',
      'pageRange': widget.pageRange ?? '',
    };
  }

  /// Hydrates the form controllers from an existing database map.
  void hydrateFrom(Map<String, dynamic> data) {
    setState(() {
      _districtCtrl.text = data['district']?.toString() ?? '';
      _psCtrl.text = data['ps']?.toString() ?? '';
      _yearCtrl.text = data['year']?.toString() ?? '';
      _firNoCtrl.text = data['firNo']?.toString() ?? '';
      _firYearSuffixCtrl.text = data['firYearSuffix']?.toString() ?? '';
      _dateDayCtrl.text = data['dateDay']?.toString() ?? '';
      _dateMonthCtrl.text = data['dateMonth']?.toString() ?? '';
      _dateYearCtrl.text = data['dateYear']?.toString() ?? '';
      _actSectionCtrl.text = data['actSection']?.toString() ?? '';
      _shownByNameCtrl.text = data['shownByName']?.toString() ?? '';
      _shownByFatherHusbandCtrl.text = data['shownByFatherHusband']?.toString() ?? '';
      _shownByAddressCtrl.text = data['shownByAddress']?.toString() ?? '';
      _typeOfCrimeCtrl.text = data['typeOfCrime']?.toString() ?? '';
      _majorHeadCtrl.text = data['majorHead']?.toString() ?? '';
      _minorHeadCtrl.text = data['minorHead']?.toString() ?? '';
      _methodCtrl.text = data['method']?.toString() ?? '';
      _method1Ctrl.text = data['method1']?.toString() ?? '';
      _method2Ctrl.text = data['method2']?.toString() ?? '';
      _method3Ctrl.text = data['method3']?.toString() ?? '';
      _conveyancesCtrl.text = data['conveyances']?.toString() ?? '';
      _characterAssumedCtrl.text = data['characterAssumed']?.toString() ?? '';
      _languageSlangCtrl.text = data['languageSlang']?.toString() ?? '';
      _specialFeature1Ctrl.text = data['specialFeature1']?.toString() ?? '';
      _specialFeature2Ctrl.text = data['specialFeature2']?.toString() ?? '';
      _specialFeature3Ctrl.text = data['specialFeature3']?.toString() ?? '';
      _placeOfOccurrenceTypeCtrl.text =
          data['placeOfOccurrenceType']?.toString() ?? '';
      _propertyInvolvedCtrl.text = data['propertyInvolved']?.toString() ?? '';
      _propertyType1Ctrl.text = data['propertyType1']?.toString() ?? '';
      _propertyType2Ctrl.text = data['propertyType2']?.toString() ?? '';
      _propertyType3Ctrl.text = data['propertyType3']?.toString() ?? '';
      _propertyType4Ctrl.text = data['propertyType4']?.toString() ?? '';
      _motiveOfCrimeCtrl.text = data['motiveOfCrime']?.toString() ?? '';
      _placeDescriptionCtrl.text = data['placeDescription']?.toString() ?? '';
      _propertyDetailsCtrl.text = data['propertyDetails']?.toString() ?? '';
      _placeDescriptionContCtrl.text = data['placeDescriptionCont']?.toString() ?? '';
      _mapImagePath = data['mapImagePath'] as String?;
      _physicalEvidenceCtrl.text = data['physicalEvidence']?.toString() ?? '';
      _panchnamaDateCtrl.text = data['panchnamaDate']?.toString() ?? '';
      _panchnamaTimeCtrl.text = data['panchnamaTime']?.toString() ?? '';
      _pancha1NameCtrl.text = data['pancha1Name']?.toString() ?? '';
      _pancha1AddressCtrl.text = data['pancha1Address']?.toString() ?? '';
      _pancha2NameCtrl.text = data['pancha2Name']?.toString() ?? '';
      _pancha2AddressCtrl.text = data['pancha2Address']?.toString() ?? '';
      _pancha1SigCtrl.text = data['pancha1Sig']?.toString() ?? '';
      _pancha2SigCtrl.text = data['pancha2Sig']?.toString() ?? '';
      _ioNameCtrl.text = data['ioName']?.toString() ?? '';
      _ioRankCtrl.text = data['ioRank']?.toString() ?? '';
      _ioBuckleNoCtrl.text = data['ioBuckleNo']?.toString() ?? '';
      _panchnamaFormDateCtrl.text = data['panchnamaFormDate']?.toString() ?? '';

      // Clear existing rows and dispose them
      for (final r in _victimRows) {
        r.dispose();
      }
      _victimRows.clear();

      final list = data['victims'];
      if (list is List && list.isNotEmpty) {
        for (final item in list) {
          final row = VictimRow();
          if (item is Map) {
            row.fromMap(Map<String, dynamic>.from(item));
          }
          _victimRows.add(row);
        }
      } else {
        _victimRows.add(VictimRow());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle serifStyle = FormTypography.serifStyle();
    final TextStyle marathiLabelStyle = FormTypography.marathiLabelStyle();

    return FormViewScaffold(
      readOnly: widget.readOnly,
      children: [
        if (_shows(kForm2A))
            FormPaperPage(
              formLabel: widget.pageRange ?? 'Page 1',
              children: [
                  // --- FORM HEADER ---
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      'Form: 2-A',
                      style: serifStyle.copyWith(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'CRIME DETAILS FORM',
                          style: serifStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'गुन्ह्यांच्या तपशीलाचा नमुना/ घटनास्थल पंचनामा',
                          style: GoogleFonts.notoSansDevanagari(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- SECTION 1 ---
                  ResponsiveFieldRow(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 22,
                        child: BilingualField(
                          label: '1) District: ',
                          marathiLabel: 'जिल्हा',
                          controller: _districtCtrl,
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 28,
                        child: BilingualField(
                          label: 'P.S.: ',
                          marathiLabel: 'पोलीस स्टेशन',
                          controller: _psCtrl,
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 15,
                        child: BilingualField(
                          label: 'Year: ',
                          marathiLabel: 'वर्ष',
                          controller: _yearCtrl,
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 22,
                        child: ResponsiveFieldRow(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: BilingualField(
                                label: 'FIR No: ',
                                marathiLabel: 'पहिली खबर क्र.',
                                controller: _firNoCtrl,
                                serifStyle: serifStyle,
                                marathiLabelStyle: marathiLabelStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0, left: 2, right: 2),
                              child: Text('/20', style: serifStyle),
                            ),
                            SizedBox(
                              width: 35,
                              child: BilingualSimpleUnderlineInput(
                                controller: _firYearSuffixCtrl,
                                serifStyle: serifStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 28,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date : ', style: serifStyle),
                            const SizedBox(width: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 35,
                                      child: BilingualSimpleUnderlineInput(
                                        controller: _dateDayCtrl,
                                        serifStyle: serifStyle,
                                        hintText: 'DD',
                                      ),
                                    ),
                                    Text('/', style: serifStyle),
                                    SizedBox(
                                      width: 35,
                                      child: BilingualSimpleUnderlineInput(
                                        controller: _dateMonthCtrl,
                                        serifStyle: serifStyle,
                                        hintText: 'MM',
                                      ),
                                    ),
                                    Text('/20', style: serifStyle),
                                    SizedBox(
                                      width: 35,
                                      child: BilingualSimpleUnderlineInput(
                                        controller: _dateYearCtrl,
                                        serifStyle: serifStyle,
                                        hintText: 'YY',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text('तारीख', style: marathiLabelStyle),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- SECTION 2 ---
                  BilingualWideField(
                    label: '2) Act and Section:',
                    marathiLabel: 'अधिनियम व कलमे',
                    controller: _actSectionCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 24),

                  // --- SECTION 3 ---
                  Text(
                    '3) The Place of Occurrence shown by:',
                    style: serifStyle,
                  ),
                  Text(
                    'घटनेचे ठिकाण दाखविणाऱ्याचे :',
                    style: marathiLabelStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ResponsiveFieldRow(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: BilingualField(
                          label: 'Name: ',
                          marathiLabel: 'नांव',
                          controller: _shownByNameCtrl,
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 5,
                        child: BilingualField(
                          label: 'Father\'s/ Husband\'s Name: ',
                          marathiLabel: 'पित्याचे/ पतीचे नांव',
                          controller: _shownByFatherHusbandCtrl,
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BilingualWideField(
                    label: 'Address:',
                    marathiLabel: 'पत्ता :',
                    controller: _shownByAddressCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 24),

                  // --- SECTION 4 ---
                  BilingualWideField(
                    label: '4) TYPE OF CRIME (All including M.O. Crime) :',
                    marathiLabel: 'गुन्ह्याचा प्रकार (गुन्ह्याच्या सर्व पद्धतीसह)',
                    controller: _typeOfCrimeCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 16),
                  ResponsiveFieldRow(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: BilingualField(
                          label: '(i) *Major Head: : ',
                          marathiLabel: 'प्रधान शीर्ष',
                          controller: _majorHeadCtrl,
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: BilingualField(
                          label: '(ii): * Minor Head : : ',
                          marathiLabel: 'गौण शीर्ष',
                          controller: _minorHeadCtrl,
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BilingualWideField(
                    label: '(iii) * Method (s):',
                    marathiLabel: 'पद्धती',
                    controller: _methodCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualNumberedMethodField(
                    number: '(१)',
                    controller: _method1Ctrl,
                    serifStyle: serifStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualNumberedMethodField(
                    number: '(२)',
                    controller: _method2Ctrl,
                    serifStyle: serifStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualNumberedMethodField(
                    number: '(३)',
                    controller: _method3Ctrl,
                    serifStyle: serifStyle,
                  ),
                  const SizedBox(height: 16),
                  BilingualWideField(
                    label: '(iv) Conveyances used:',
                    marathiLabel: 'वापरलेली वाहने',
                    controller: _conveyancesCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 16),
                  BilingualWideField(
                    label: '(V)* Character Assumed:',
                    marathiLabel: 'केलेले वेषांतर/ केलेली बतावणी',
                    controller: _characterAssumedCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 16),
                  BilingualWideField(
                    label: '(Vi)* Language/ slang used:',
                    marathiLabel: 'वापरलेली भाषा/ बोली भाषा',
                    controller: _languageSlangCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 16),
                  BilingualWideField(
                    label: '(Vii)* Special Feature-1:',
                    marathiLabel: 'विशेष वैशिष्ट्ये - १',
                    controller: _specialFeature1Ctrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 16),
                  BilingualWideField(
                    label: '*Special Feature-2:',
                    marathiLabel: 'विशेष वैशिष्ट्ये - २',
                    controller: _specialFeature2Ctrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 16),
                  BilingualWideField(
                    label: '*Special Feature-3:',
                    marathiLabel: 'विशेष वैशिष्ट्ये - ३',
                    controller: _specialFeature3Ctrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 16),
                  BilingualWideField(
                    label: '(Viii) Type of Place of Occurrence:',
                    marathiLabel: 'घटनेच्या ठिकाणाचा प्रकार',
                    controller: _placeOfOccurrenceTypeCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 16),
                  BilingualWideField(
                    label: '(ix) Type of Property Involved ( 4 Types ):',
                    marathiLabel: 'अंतर्भूत मालमत्तेचे प्रकार',
                    controller: _propertyInvolvedCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  ResponsiveFieldRow(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: BilingualField(
                          label: '(1) ',
                          marathiLabel: '',
                          controller: _propertyType1Ctrl,
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                          showMarathiLabel: false,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: BilingualField(
                          label: '(2) ',
                          marathiLabel: '',
                          controller: _propertyType2Ctrl,
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                          showMarathiLabel: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ResponsiveFieldRow(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: BilingualField(
                          label: '(3) ',
                          marathiLabel: '',
                          controller: _propertyType3Ctrl,
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                          showMarathiLabel: false,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: BilingualField(
                          label: '(4) ',
                          marathiLabel: '',
                          controller: _propertyType4Ctrl,
                          serifStyle: serifStyle,
                          marathiLabelStyle: marathiLabelStyle,
                          showMarathiLabel: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FormMrwFooter(serifStyle: serifStyle, fontSize: 11),
                ],
              ),
        if (_shows(kForm2A) && (_shows(kForm2B) || _showAll))
            const SizedBox(height: 24),

        if (_shows(kForm2B))
            FormPaperPage(
              formLabel: widget.pageRange ?? 'Page 2',
              children: [
                  // --- FORM HEADER ---
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      'Form: 2-B',
                      style: serifStyle.copyWith(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    '5) Particulars of the victims (Attach separate sheet, if required)',
                    style: serifStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'बळीचा तपशील ( आवश्यक असल्यास स्वतंत्र कागद जोडावा. )',
                    style: marathiLabelStyle.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.all(color: Colors.black87, width: 1),
                    columnWidths: const {
                      0: FixedColumnWidth(30),  // Sr No
                      1: FlexColumnWidth(2.5),  // Full Name
                      2: FlexColumnWidth(1.8),  // Date/Year of Birth
                      3: FlexColumnWidth(1.0),  // Sex
                      4: FlexColumnWidth(1.8),  // Nationality
                      5: FlexColumnWidth(1.5),  // Religion
                      6: FlexColumnWidth(1.8),  // SC/ST
                      7: FlexColumnWidth(1.8),  // Occupation
                      8: FlexColumnWidth(2.2),  // Address
                      9: FlexColumnWidth(2.0),  // Injury
                      10: FlexColumnWidth(1.5), // Means
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey.shade100),
                        children: [
                          _buildHeaderCell("Sr.\nNo\n\nअ.\nक.\n\n(1)"),
                          _buildHeaderCell("Full Name\n\nसंपूर्ण नांव\n\n(2)"),
                          _buildHeaderCell("Date/Year\nof Birth\n\nजन्म तारीख/\nवर्ष\n\n(3)"),
                          _buildHeaderCell("Sex\n\nलिंग\n\n(*4)"),
                          _buildHeaderCell("Nationality\n\nराष्ट्रीयत्व\n\n(*5)"),
                          _buildHeaderCell("Religion\n\nधर्म\n\n(*6)"),
                          _buildHeaderCell("Whether\nSC/ ST\n\nजाती\n/जमाती\n\n(*7)"),
                          _buildHeaderCell("Ocupetion\n\nव्यवसाय\n\n(*8)"),
                          _buildHeaderCell("Address\n\nपत्ता\n\n(*9)"),
                          _buildHeaderCell("Injury:\ngrievous/\nSimple\n\nदुखापत\nगंभीर/साधी\n\n(10)"),
                          _buildHeaderCell("Means\n\nसाधने/\nहत्यारे\n\n(11)"),
                        ],
                      ),
                      ...List.generate(_victimRows.length, (index) {
                        final row = _victimRows[index];
                        return TableRow(
                          children: [
                            FormTableSrNoCell(index: index, style: serifStyle),
                            _buildTableInputCell(controller: row.fullNameCtrl, style: serifStyle, hintText: 'Name'),
                            _buildTableInputCell(controller: row.dobCtrl, style: serifStyle, hintText: 'DOB/Year'),
                            _buildTableInputCell(controller: row.sexCtrl, style: serifStyle, hintText: 'Sex'),
                            _buildTableInputCell(controller: row.nationalityCtrl, style: serifStyle, hintText: 'Nationality'),
                            _buildTableInputCell(controller: row.religionCtrl, style: serifStyle, hintText: 'Religion'),
                            _buildTableInputCell(controller: row.scStCtrl, style: serifStyle, hintText: 'SC/ST'),
                            _buildTableInputCell(controller: row.occupationCtrl, style: serifStyle, hintText: 'Occupation'),
                            _buildTableInputCell(controller: row.addressCtrl, style: serifStyle, hintText: 'Address'),
                            _buildTableInputCell(controller: row.injuryCtrl, style: serifStyle, hintText: 'Injury'),
                            _buildTableInputCell(controller: row.meansCtrl, style: serifStyle, hintText: 'Means'),
                          ],
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _victimRows.add(VictimRow());
                          });
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(
                          'Add Row (ओळ जोडा)',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (_victimRows.length > 1) ...[
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              final last = _victimRows.removeLast();
                              last.dispose();
                            });
                          },
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          icon: const Icon(Icons.remove, size: 18),
                          label: Text(
                            'Remove Row (ओळ काढा)',
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  BilingualWideField(
                    label: '6) Motive of Crime:',
                    marathiLabel: 'गुन्ह्याचा हेतू :',
                    controller: _motiveOfCrimeCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 24),

                  // --- SECTION 7 ---
                  Text(
                    '7) Details of properties Stolen/Involved: (Use appropriate prescribed forms (s) and attach):',
                    style: serifStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'चोरीचा / अंतर्भूत मालमत्तेचा तपशील (योग्य नमुना वापरावा व सोबत जोडावा) :',
                    style: marathiLabelStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  BilingualDynamicLinedTextField(
                    controller: _propertyDetailsCtrl,
                    minLines: 4,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 24),

                  // --- SECTION 8 ---
                  Text(
                    '8) Description of the place of occurrence:',
                    style: serifStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '(घटनेच्या जागेचे वर्णन) :',
                    style: marathiLabelStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  BilingualDynamicLinedTextField(
                    controller: _placeDescriptionCtrl,
                    minLines: 6,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                ],
              ),
        if (_shows(kForm2B) && (_shows(kForm2C) || _showAll))
            const SizedBox(height: 32),

        if (_shows(kForm2C)) ...[
            FormPaperPage(
              formLabel: widget.pageRange ?? 'Pages 3–4',
              children: [
            Align(
              alignment: Alignment.topRight,
              child: Text(
                'Form: 2-C',
                style: serifStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Description of the place of occurrence (Cont.):',
              style: serifStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              '(घटनेच्या जागेचे वर्णन) :',
              style: marathiLabelStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            BilingualDynamicLinedTextField(
              controller: _placeDescriptionContCtrl,
              minLines: 6,
              serifStyle: serifStyle,
              marathiLabelStyle: marathiLabelStyle,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),

            // --- SECTION 9: Map ---
            Text(
              '(9) Map: नकाशा',
              style: serifStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final x = await picker.pickImage(source: ImageSource.gallery);
                if (x != null) {
                  setState(() {
                    _mapImagePath = x.path;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                height: 350,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  color: Colors.white,
                ),
                child: _mapImagePath == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text(
                              'Click to upload Map Image',
                              style: serifStyle.copyWith(color: Colors.grey.shade600, fontSize: 13),
                            ),
                            Text(
                              '(नकाशा चित्र अपलोड करण्यासाठी येथे क्लिक करा)',
                              style: marathiLabelStyle.copyWith(color: Colors.grey.shade500, fontSize: 11),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: kIsWeb
                                ? Image.network(_mapImagePath!, fit: BoxFit.contain)
                                : Image.file(File(_mapImagePath!), fit: BoxFit.contain),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _mapImagePath = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              ),
            const SizedBox(height: 16),
            // --- SECTION 10: Physical Evidence ---
            Text(
              '(10) Description of physical evidence from the science of crime for the property recovered / seized for the purpose of investigation:',
              style: serifStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'तपासकामी प्रत्यक्ष पुरावा म्हणून गुन्ह्याच्या जागेवरून मिळविलेल्या / जप्त केलेल्या मालमत्तेचे वर्णन :',
              style: marathiLabelStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            BilingualDynamicLinedTextField(
              controller: _physicalEvidenceCtrl,
              minLines: 6,
              serifStyle: serifStyle,
              marathiLabelStyle: marathiLabelStyle,
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.black26),
            const SizedBox(height: 16),
            ResponsiveFieldRow(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date and Time of panchnama:', style: serifStyle.copyWith(fontWeight: FontWeight.w600)),
                      Text('घटनास्थळ पंचनाम्याची दिनांक :', style: marathiLabelStyle),
                      const SizedBox(height: 6),
                      BilingualDynamicLinedTextField(
                        controller: _panchnamaDateCtrl,
                        minLines: 1,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Name of panchas: / पंचाची नांवे :',
                        style: serifStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text('(1)', style: serifStyle.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      BilingualDynamicLinedTextField(
                        controller: _pancha1NameCtrl,
                        minLines: 1,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      const SizedBox(height: 12),
                      Text('Full Address: / पत्ता', style: serifStyle.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      BilingualDynamicLinedTextField(
                        controller: _pancha1AddressCtrl,
                        minLines: 3,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      const SizedBox(height: 20),
                      Text('(2)', style: serifStyle.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      BilingualDynamicLinedTextField(
                        controller: _pancha2NameCtrl,
                        minLines: 1,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      const SizedBox(height: 12),
                      Text('Full Address: / पत्ता', style: serifStyle.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      BilingualDynamicLinedTextField(
                        controller: _pancha2AddressCtrl,
                        minLines: 3,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      const SizedBox(height: 20),
                      Text('Date: / दिनांक', style: serifStyle.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      BilingualDynamicLinedTextField(
                        controller: _panchnamaFormDateCtrl,
                        minLines: 1,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                // Right Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time:', style: serifStyle.copyWith(fontWeight: FontWeight.w600)),
                      Text('वेळ :', style: marathiLabelStyle),
                      const SizedBox(height: 6),
                      BilingualDynamicLinedTextField(
                        controller: _panchnamaTimeCtrl,
                        minLines: 1,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Signature of Panchas: / पंचाच्या सह्या :',
                        style: serifStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text('1)', style: serifStyle.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      BilingualDynamicLinedTextField(
                        controller: _pancha1SigCtrl,
                        minLines: 1,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      const SizedBox(height: 20),
                      Text('2)', style: serifStyle.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      BilingualDynamicLinedTextField(
                        controller: _pancha2SigCtrl,
                        minLines: 1,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Name and Signature of Investigation Officer: / ${FormIoTerminology.amaldarSignatureHeader} :',
                        style: serifStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text('Name: / ${FormIoTerminology.name} :', style: serifStyle.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      BilingualDynamicLinedTextField(
                        controller: _ioNameCtrl,
                        minLines: 1,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      const SizedBox(height: 12),
                      Text('Rank: / ${FormIoTerminology.rank} :', style: serifStyle.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      BilingualDynamicLinedTextField(
                        controller: _ioRankCtrl,
                        minLines: 1,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                      const SizedBox(height: 12),
                      Text('B.No. if any: / बक्कल नंबर :', style: serifStyle.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      BilingualDynamicLinedTextField(
                        controller: _ioBuckleNoCtrl,
                        minLines: 1,
                        serifStyle: serifStyle,
                        marathiLabelStyle: marathiLabelStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FormMrwFooter(serifStyle: serifStyle, fontSize: 11),
          ],
        ),
        ],
      ],
    );
  }
  // Helper methods for Form 2-B Table
  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.notoSansDevanagari(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTableInputCell({
    required TextEditingController controller,
    required TextStyle style,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.start,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        style: style.copyWith(
          fontSize: 11,
          color: Colors.blue.shade900,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: style.copyWith(
            color: Colors.grey.shade400,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

// VictimRow model for table input tracking
class VictimRow {
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController dobCtrl = TextEditingController();
  final TextEditingController sexCtrl = TextEditingController();
  final TextEditingController nationalityCtrl = TextEditingController();
  final TextEditingController religionCtrl = TextEditingController();
  final TextEditingController scStCtrl = TextEditingController();
  final TextEditingController occupationCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController injuryCtrl = TextEditingController();
  final TextEditingController meansCtrl = TextEditingController();

  void dispose() {
    fullNameCtrl.dispose();
    dobCtrl.dispose();
    sexCtrl.dispose();
    nationalityCtrl.dispose();
    religionCtrl.dispose();
    scStCtrl.dispose();
    occupationCtrl.dispose();
    addressCtrl.dispose();
    injuryCtrl.dispose();
    meansCtrl.dispose();
  }

  Map<String, String> toMap() {
    return {
      'fullName': fullNameCtrl.text.trim(),
      'dob': dobCtrl.text.trim(),
      'sex': sexCtrl.text.trim(),
      'nationality': nationalityCtrl.text.trim(),
      'religion': religionCtrl.text.trim(),
      'scSt': scStCtrl.text.trim(),
      'occupation': occupationCtrl.text.trim(),
      'address': addressCtrl.text.trim(),
      'injury': injuryCtrl.text.trim(),
      'means': meansCtrl.text.trim(),
    };
  }

  void fromMap(Map<String, dynamic> map) {
    fullNameCtrl.text = map['fullName']?.toString() ?? '';
    dobCtrl.text = map['dob']?.toString() ?? '';
    sexCtrl.text = map['sex']?.toString() ?? '';
    nationalityCtrl.text = map['nationality']?.toString() ?? '';
    religionCtrl.text = map['religion']?.toString() ?? '';
    scStCtrl.text = map['scSt']?.toString() ?? '';
    occupationCtrl.text = map['occupation']?.toString() ?? '';
    addressCtrl.text = map['address']?.toString() ?? '';
    injuryCtrl.text = map['injury']?.toString() ?? '';
    meansCtrl.text = map['means']?.toString() ?? '';
  }
}
