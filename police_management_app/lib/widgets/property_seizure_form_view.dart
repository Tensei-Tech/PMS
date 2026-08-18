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

class PropertySeizureFormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const PropertySeizureFormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<PropertySeizureFormView> createState() => PropertySeizureFormViewState();
}

class PropertySeizureFormViewState extends State<PropertySeizureFormView> {
  static const kMemoBody = 'Seizure Memo Body';
  static const kSignatures = 'Seizure Memo Signatures';
  static const _knownSectionIds = {kMemoBody, kSignatures};

  bool _shows(String sectionId) => showsFormSection(
        activeSection: widget.formSection,
        sectionId: sectionId,
        knownSectionIds: _knownSectionIds,
      );

  bool get _showAll => showsAllFormSections(
        activeSection: widget.formSection,
        knownSectionIds: _knownSectionIds,
      );
  // Page 1 Header fields (1)
  final _districtCtrl = TextEditingController();
  final _psCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(text: DateTime.now().year.toString());
  final _firNoCtrl = TextEditingController();
  final _firYearSuffixCtrl = TextEditingController(text: DateTime.now().year.toString().substring(2));
  final _dateDayCtrl = TextEditingController();
  final _dateMonthCtrl = TextEditingController();
  final _dateYearCtrl = TextEditingController(text: DateTime.now().year.toString().substring(2));

  final _actSectionCtrl = TextEditingController();

  // Seizure metadata
  String _natureOfProperty = 'चोरीला गेलेली';
  final _seizureDateDayCtrl = TextEditingController();
  final _seizureDateMonthCtrl = TextEditingController();
  final _seizureDateYearCtrl = TextEditingController(text: DateTime.now().year.toString().substring(2));
  final _seizureTimeCtrl = TextEditingController();
  final _seizurePlaceCtrl = TextEditingController();
  final _seizurePlaceDescCtrl = TextEditingController();

  // Person from whom seized
  final _seizedFromCtrl = TextEditingController();
  String _isProfessionalReceiver = 'नाही';
  final _personNameCtrl = TextEditingController();
  final _personFatherCtrl = TextEditingController();
  final _personSexCtrl = TextEditingController();
  final _personAgeCtrl = TextEditingController();
  final _personOccupationCtrl = TextEditingController();
  final _personAddressCtrl = TextEditingController();

  // Witnesses (x2)
  final _w1NameCtrl = TextEditingController();
  final _w1FatherCtrl = TextEditingController();
  final _w1SexCtrl = TextEditingController();
  final _w1AgeCtrl = TextEditingController();
  final _w1OccupationCtrl = TextEditingController();
  final _w1AddressCtrl = TextEditingController();

  final _w2NameCtrl = TextEditingController();
  final _w2FatherCtrl = TextEditingController();
  final _w2SexCtrl = TextEditingController();
  final _w2AgeCtrl = TextEditingController();
  final _w2OccupationCtrl = TextEditingController();
  final _w2AddressCtrl = TextEditingController();
  final _w2AddressLine2Ctrl = TextEditingController();

  // Actions & Identification
  final _perishableDisposalCtrl = TextEditingController();
  final _valuableKeepingCtrl = TextEditingController();
  String _identificationRequired = 'नाही';
  final _circumstancesCtrl = TextEditingController();
  final _circumstancesLine2Ctrl = TextEditingController();
  final _circumstancesLine3Ctrl = TextEditingController();

  // Pancha & IO Signature
  final _pancha1NameCtrl = TextEditingController();
  final _pancha1Addr1Ctrl = TextEditingController();
  final _pancha1Addr2Ctrl = TextEditingController();
  final _pancha1Addr3Ctrl = TextEditingController();
  final _pancha2NameCtrl = TextEditingController();
  final _pancha2Addr1Ctrl = TextEditingController();
  final _pancha2Addr2Ctrl = TextEditingController();
  final _pancha2Addr3Ctrl = TextEditingController();
  final _pancha1SigCtrl = TextEditingController();
  final _pancha2SigCtrl = TextEditingController();
  final _panchaDateDayCtrl = TextEditingController();
  final _panchaDateMonthCtrl = TextEditingController();
  final _panchaDateYearCtrl = TextEditingController();

  // IO Details
  final _ioNameCtrl = TextEditingController();
  final _ioRankCtrl = TextEditingController();
  final _ioBuckleNoCtrl = TextEditingController();
  final _ioPostingCtrl = TextEditingController();

  // Seized Properties Table
  final List<PropertyRow> _propertyRows = [PropertyRow()];
  final List<SealPropertyRow> _sealPropertyRows = List.generate(5, (_) => SealPropertyRow());

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
    _seizureDateDayCtrl.dispose();
    _seizureDateMonthCtrl.dispose();
    _seizureDateYearCtrl.dispose();
    _seizureTimeCtrl.dispose();
    _seizurePlaceCtrl.dispose();
    _seizurePlaceDescCtrl.dispose();
    _seizedFromCtrl.dispose();
    _personNameCtrl.dispose();
    _personFatherCtrl.dispose();
    _personSexCtrl.dispose();
    _personAgeCtrl.dispose();
    _personOccupationCtrl.dispose();
    _personAddressCtrl.dispose();
    _w1NameCtrl.dispose();
    _w1FatherCtrl.dispose();
    _w1SexCtrl.dispose();
    _w1AgeCtrl.dispose();
    _w1OccupationCtrl.dispose();
    _w1AddressCtrl.dispose();
    _w2NameCtrl.dispose();
    _w2FatherCtrl.dispose();
    _w2SexCtrl.dispose();
    _w2AgeCtrl.dispose();
    _w2OccupationCtrl.dispose();
    _w2AddressCtrl.dispose();
    _w2AddressLine2Ctrl.dispose();
    _perishableDisposalCtrl.dispose();
    _valuableKeepingCtrl.dispose();
    _circumstancesCtrl.dispose();
    _circumstancesLine2Ctrl.dispose();
    _circumstancesLine3Ctrl.dispose();
    _pancha1NameCtrl.dispose();
    _pancha1Addr1Ctrl.dispose();
    _pancha1Addr2Ctrl.dispose();
    _pancha1Addr3Ctrl.dispose();
    _pancha2NameCtrl.dispose();
    _pancha2Addr1Ctrl.dispose();
    _pancha2Addr2Ctrl.dispose();
    _pancha2Addr3Ctrl.dispose();
    _pancha1SigCtrl.dispose();
    _pancha2SigCtrl.dispose();
    _panchaDateDayCtrl.dispose();
    _panchaDateMonthCtrl.dispose();
    _panchaDateYearCtrl.dispose();
    _ioNameCtrl.dispose();
    _ioRankCtrl.dispose();
    _ioBuckleNoCtrl.dispose();
    _ioPostingCtrl.dispose();
    for (final r in _propertyRows) {
      r.dispose();
    }
    for (final r in _sealPropertyRows) {
      r.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> collectData() {
    final propertiesData = _propertyRows.map((r) => r.toMap()).toList();
    final sealPropertiesData = _sealPropertyRows.map((r) => r.toMap()).toList();
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
      'natureOfProperty': _natureOfProperty,
      'seizureDateDay': _seizureDateDayCtrl.text.trim(),
      'seizureDateMonth': _seizureDateMonthCtrl.text.trim(),
      'seizureDateYear': _seizureDateYearCtrl.text.trim(),
      'seizureTime': _seizureTimeCtrl.text.trim(),
      'seizurePlace': _seizurePlaceCtrl.text.trim(),
      'seizurePlaceDesc': _seizurePlaceDescCtrl.text.trim(),
      'seizedFrom': _seizedFromCtrl.text.trim(),
      'isProfessionalReceiver': _isProfessionalReceiver,
      'personName': _personNameCtrl.text.trim(),
      'personFather': _personFatherCtrl.text.trim(),
      'personSex': _personSexCtrl.text.trim(),
      'personAge': _personAgeCtrl.text.trim(),
      'personOccupation': _personOccupationCtrl.text.trim(),
      'personAddress': _personAddressCtrl.text.trim(),
      'w1Name': _w1NameCtrl.text.trim(),
      'w1Father': _w1FatherCtrl.text.trim(),
      'w1Sex': _w1SexCtrl.text.trim(),
      'w1Age': _w1AgeCtrl.text.trim(),
      'w1Occupation': _w1OccupationCtrl.text.trim(),
      'w1Address': _w1AddressCtrl.text.trim(),
      'w2Name': _w2NameCtrl.text.trim(),
      'w2Father': _w2FatherCtrl.text.trim(),
      'w2Sex': _w2SexCtrl.text.trim(),
      'w2Age': _w2AgeCtrl.text.trim(),
      'w2Occupation': _w2OccupationCtrl.text.trim(),
      'w2Address': _w2AddressCtrl.text.trim(),
      'w2AddressLine2': _w2AddressLine2Ctrl.text.trim(),
      'perishableDisposal': _perishableDisposalCtrl.text.trim(),
      'valuableKeeping': _valuableKeepingCtrl.text.trim(),
      'identificationRequired': _identificationRequired,
      'circumstances': _circumstancesCtrl.text.trim(),
      'circumstancesLine2': _circumstancesLine2Ctrl.text.trim(),
      'circumstancesLine3': _circumstancesLine3Ctrl.text.trim(),
      'pancha1Name': _pancha1NameCtrl.text.trim(),
      'pancha1Addr1': _pancha1Addr1Ctrl.text.trim(),
      'pancha1Addr2': _pancha1Addr2Ctrl.text.trim(),
      'pancha1Addr3': _pancha1Addr3Ctrl.text.trim(),
      'pancha2Name': _pancha2NameCtrl.text.trim(),
      'pancha2Addr1': _pancha2Addr1Ctrl.text.trim(),
      'pancha2Addr2': _pancha2Addr2Ctrl.text.trim(),
      'pancha2Addr3': _pancha2Addr3Ctrl.text.trim(),
      'pancha1Sig': _pancha1SigCtrl.text.trim(),
      'pancha2Sig': _pancha2SigCtrl.text.trim(),
      'panchaDateDay': _panchaDateDayCtrl.text.trim(),
      'panchaDateMonth': _panchaDateMonthCtrl.text.trim(),
      'panchaDateYear': _panchaDateYearCtrl.text.trim(),
      'ioName': _ioNameCtrl.text.trim(),
      'ioRank': _ioRankCtrl.text.trim(),
      'ioBuckleNo': _ioBuckleNoCtrl.text.trim(),
      'ioPosting': _ioPostingCtrl.text.trim(),
      'properties': propertiesData,
      'sealProperties': sealPropertiesData,
      'formSection': widget.formSection ?? '',
      'pageRange': widget.pageRange ?? '',
    };
  }

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
      _natureOfProperty = data['natureOfProperty']?.toString() ?? 'चोरीला गेलेली';
      _seizureDateDayCtrl.text = data['seizureDateDay']?.toString() ?? '';
      _seizureDateMonthCtrl.text = data['seizureDateMonth']?.toString() ?? '';
      _seizureDateYearCtrl.text = data['seizureDateYear']?.toString() ?? '';
      _seizureTimeCtrl.text = data['seizureTime']?.toString() ?? '';
      _seizurePlaceCtrl.text = data['seizurePlace']?.toString() ?? '';
      _seizurePlaceDescCtrl.text = data['seizurePlaceDesc']?.toString() ?? '';
      _seizedFromCtrl.text = data['seizedFrom']?.toString() ?? '';
      _isProfessionalReceiver = data['isProfessionalReceiver']?.toString() ?? 'नाही';
      _personNameCtrl.text = data['personName']?.toString() ?? '';
      _personFatherCtrl.text = data['personFather']?.toString() ?? '';
      _personSexCtrl.text = data['personSex']?.toString() ?? '';
      _personAgeCtrl.text = data['personAge']?.toString() ?? '';
      _personOccupationCtrl.text = data['personOccupation']?.toString() ?? '';
      _personAddressCtrl.text = data['personAddress']?.toString() ?? '';
      _w1NameCtrl.text = data['w1Name']?.toString() ?? '';
      _w1FatherCtrl.text = data['w1Father']?.toString() ?? '';
      _w1SexCtrl.text = data['w1Sex']?.toString() ?? '';
      _w1AgeCtrl.text = data['w1Age']?.toString() ?? '';
      _w1OccupationCtrl.text = data['w1Occupation']?.toString() ?? '';
      _w1AddressCtrl.text = data['w1Address']?.toString() ?? '';
      _w2NameCtrl.text = data['w2Name']?.toString() ?? '';
      _w2FatherCtrl.text = data['w2Father']?.toString() ?? '';
      _w2SexCtrl.text = data['w2Sex']?.toString() ?? '';
      _w2AgeCtrl.text = data['w2Age']?.toString() ?? '';
      _w2OccupationCtrl.text = data['w2Occupation']?.toString() ?? '';
      _w2AddressCtrl.text = data['w2Address']?.toString() ?? '';
      _w2AddressLine2Ctrl.text = data['w2AddressLine2']?.toString() ?? '';
      _perishableDisposalCtrl.text = data['perishableDisposal']?.toString() ?? '';
      _valuableKeepingCtrl.text = data['valuableKeeping']?.toString() ?? '';
      _identificationRequired = data['identificationRequired']?.toString() ?? 'नाही';
      _circumstancesCtrl.text = data['circumstances']?.toString() ?? '';
      _circumstancesLine2Ctrl.text = data['circumstancesLine2']?.toString() ?? '';
      _circumstancesLine3Ctrl.text = data['circumstancesLine3']?.toString() ?? '';
      _pancha1NameCtrl.text = data['pancha1Name']?.toString() ?? '';
      _pancha1Addr1Ctrl.text = data['pancha1Addr1']?.toString() ?? '';
      _pancha1Addr2Ctrl.text = data['pancha1Addr2']?.toString() ?? '';
      _pancha1Addr3Ctrl.text = data['pancha1Addr3']?.toString() ?? '';
      _pancha2NameCtrl.text = data['pancha2Name']?.toString() ?? '';
      _pancha2Addr1Ctrl.text = data['pancha2Addr1']?.toString() ?? '';
      _pancha2Addr2Ctrl.text = data['pancha2Addr2']?.toString() ?? '';
      _pancha2Addr3Ctrl.text = data['pancha2Addr3']?.toString() ?? '';
      _pancha1SigCtrl.text = data['pancha1Sig']?.toString() ?? '';
      _pancha2SigCtrl.text = data['pancha2Sig']?.toString() ?? '';
      _panchaDateDayCtrl.text = data['panchaDateDay']?.toString() ?? '';
      _panchaDateMonthCtrl.text = data['panchaDateMonth']?.toString() ?? '';
      _panchaDateYearCtrl.text = data['panchaDateYear']?.toString() ?? '';
      _ioNameCtrl.text = data['ioName']?.toString() ?? '';
      _ioRankCtrl.text = data['ioRank']?.toString() ?? '';
      _ioBuckleNoCtrl.text = data['ioBuckleNo']?.toString() ?? '';
      _ioPostingCtrl.text = data['ioPosting']?.toString() ?? '';

      for (final r in _propertyRows) {
        r.dispose();
      }
      _propertyRows.clear();
      final list = data['properties'];
      if (list is List && list.isNotEmpty) {
        for (final item in list) {
          final row = PropertyRow();
          if (item is Map) {
            row.fromMap(Map<String, dynamic>.from(item));
          }
          _propertyRows.add(row);
        }
      } else {
        _propertyRows.add(PropertyRow());
      }

      for (final r in _sealPropertyRows) {
        r.dispose();
      }
      _sealPropertyRows.clear();
      final sealList = data['sealProperties'];
      if (sealList is List && sealList.isNotEmpty) {
        for (final item in sealList) {
          final row = SealPropertyRow();
          if (item is Map) {
            row.fromMap(Map<String, dynamic>.from(item));
          }
          _sealPropertyRows.add(row);
        }
      } else {
        _sealPropertyRows.addAll(List.generate(5, (_) => SealPropertyRow()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle serifStyle = FormTypography.serifStyle();

    final TextStyle marathiStyle = FormTypography.marathiLabelStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    return FormViewScaffold(
      readOnly: widget.readOnly,
      children: [
        if (_shows(kMemoBody))
        FormPaperPage(
          formLabel: widget.pageRange ?? 'Page 6',
          children: [
                    // --- FORM HEADER ---
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'PROPERTY SEACH & SEIZURE FORM',
                            style: serifStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'मालमत्ता शोध व जप्तीचा नमुना',
                            style: GoogleFonts.notoSansDevanagari(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '(Search/ Production/ Recovery u/s. 185 B.N.S.S)',
                            style: serifStyle.copyWith(fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                              children: [
                                const TextSpan(
                                  text: '(कलम १८५ भारतीय नागरीक सुरक्षा संहिता २०२३ अन्वये झडती/हजर ',
                                ),
                                TextSpan(
                                  text: 'करणे/परत',
                                  style: TextStyle(color: Colors.blue.shade900),
                                ),
                                const TextSpan(text: ' मिळविणे)'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.black54, thickness: 1),
                    const SizedBox(height: 16),

                    // --- SECTION 1 ---
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 4,
                      runSpacing: 8,
                      children: [
                        Text('१) *जिल्हा:', style: marathiStyle),
                        SizedBox(
                          width: 80,
                          child: BilingualSimpleUnderlineInput(
                            controller: _districtCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('*पोलीस ठाणे:', style: marathiStyle),
                        SizedBox(
                          width: 120,
                          child: BilingualSimpleUnderlineInput(
                            controller: _psCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('वर्षे:', style: marathiStyle),
                        SizedBox(
                          width: 60,
                          child: BilingualSimpleUnderlineInput(
                            controller: _yearCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('*पहिली खबर क/कार्यवाही', style: marathiStyle),
                        SizedBox(
                          width: 50,
                          child: BilingualSimpleUnderlineInput(
                            controller: _firNoCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('/', style: marathiStyle),
                        SizedBox(
                          width: 50,
                          child: BilingualSimpleUnderlineInput(
                            controller: _firYearSuffixCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('*दि', style: marathiStyle),
                        SizedBox(
                          width: 35,
                          child: BilingualSimpleUnderlineInput(
                            controller: _dateDayCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('/', style: marathiStyle),
                        SizedBox(
                          width: 35,
                          child: BilingualSimpleUnderlineInput(
                            controller: _dateMonthCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('/२०', style: marathiStyle),
                        SizedBox(
                          width: 35,
                          child: BilingualSimpleUnderlineInput(
                            controller: _dateYearCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- SECTION 2 ---
                    ResponsiveFieldRow(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('२) अधिनियम व कलमे : ', style: marathiStyle),
                        Expanded(
                          child: BilingualSimpleUnderlineInput(
                            controller: _actSectionCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- SECTION 3 ---
                    Text(
                      '३) *जप्त केलेले/मिळालेल्या मालमत्तेचे स्वरूप : चोरीला गेलेली/बेवारशी/बेकायदेशीर ताबा/अंतर्भूत/मृत्यू पत्राशिवाय.',
                      style: marathiStyle,
                    ),
                    const SizedBox(height: 20),

                    // --- SECTION 4 ---
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 4,
                      runSpacing: 8,
                      children: [
                        Text('४) जप्त केलेली मालमत्ता : (अ) तारीख :', style: marathiStyle),
                        SizedBox(
                          width: 35,
                          child: BilingualSimpleUnderlineInput(
                            controller: _seizureDateDayCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('/', style: marathiStyle),
                        SizedBox(
                          width: 35,
                          child: BilingualSimpleUnderlineInput(
                            controller: _seizureDateMonthCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('/२०', style: marathiStyle),
                        SizedBox(
                          width: 35,
                          child: BilingualSimpleUnderlineInput(
                            controller: _seizureDateYearCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('(ब) वेळ :', style: marathiStyle),
                        SizedBox(
                          width: 60,
                          child: BilingualSimpleUnderlineInput(
                            controller: _seizureTimeCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ResponsiveFieldRow(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('(क) जेथून जप्त केली/परत मिळवली ती जागा : ', style: marathiStyle),
                        Expanded(
                          child: BilingualSimpleUnderlineInput(
                            controller: _seizurePlaceCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ResponsiveFieldRow(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('(ड) जप्तीच्या/परत मिळवल्याची जागेचे वर्णन: ', style: marathiStyle),
                        Expanded(
                          child: BilingualSimpleUnderlineInput(
                            controller: _seizurePlaceDescCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- SECTION 5 ---
                    ResponsiveFieldRow(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('५) कोणाकडून जप्त केली : ', style: marathiStyle),
                        Expanded(
                          child: BilingualSimpleUnderlineInput(
                            controller: _seizedFromCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('*चोरीचा माल घेणारा धंदेवाईक : होय/नाही', style: marathiStyle),
                        const SizedBox(width: 8),
                        _chipSelector(
                          items: ['होय', 'नाही'],
                          selected: _isProfessionalReceiver,
                          onSelect: (val) {
                            setState(() {
                              _isProfessionalReceiver = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text('नाव :', style: marathiStyle),
                        SizedBox(
                          width: 140,
                          child: BilingualSimpleUnderlineInput(
                            controller: _personNameCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('पित्याचे/पतीचे नाव :', style: marathiStyle),
                        SizedBox(
                          width: 140,
                          child: BilingualSimpleUnderlineInput(
                            controller: _personFatherCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('लिंग :', style: marathiStyle),
                        SizedBox(
                          width: 80,
                          child: BilingualSimpleUnderlineInput(
                            controller: _personSexCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text('वय :', style: marathiStyle),
                        SizedBox(
                          width: 60,
                          child: BilingualSimpleUnderlineInput(
                            controller: _personAgeCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('व्यवसाय :', style: marathiStyle),
                        SizedBox(
                          width: 120,
                          child: BilingualSimpleUnderlineInput(
                            controller: _personOccupationCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('पत्ता :', style: marathiStyle),
                        SizedBox(
                          width: 200,
                          child: BilingualSimpleUnderlineInput(
                            controller: _personAddressCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- SECTION 6 ---
                    Text('६) साक्षीदार', style: marathiStyle),
                    const SizedBox(height: 12),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text('(i) नाव :', style: marathiStyle),
                        SizedBox(
                          width: 140,
                          child: BilingualSimpleUnderlineInput(
                            controller: _w1NameCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('पित्याचे/पतीचे नाव :', style: marathiStyle),
                        SizedBox(
                          width: 140,
                          child: BilingualSimpleUnderlineInput(
                            controller: _w1FatherCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('लिंग :', style: marathiStyle),
                        SizedBox(
                          width: 80,
                          child: BilingualSimpleUnderlineInput(
                            controller: _w1SexCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text('वय :', style: marathiStyle),
                        SizedBox(
                          width: 60,
                          child: BilingualSimpleUnderlineInput(
                            controller: _w1AgeCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('व्यवसाय :', style: marathiStyle),
                        SizedBox(
                          width: 120,
                          child: BilingualSimpleUnderlineInput(
                            controller: _w1OccupationCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('पत्ता :', style: marathiStyle),
                        SizedBox(
                          width: 200,
                          child: BilingualSimpleUnderlineInput(
                            controller: _w1AddressCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- WITNESS (ii) ---
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text('(ii) नाव :', style: marathiStyle),
                        SizedBox(
                          width: 140,
                          child: BilingualSimpleUnderlineInput(
                            controller: _w2NameCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('पित्याचे/पतीचे नाव :', style: marathiStyle),
                        SizedBox(
                          width: 140,
                          child: BilingualSimpleUnderlineInput(
                            controller: _w2FatherCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('लिंग :', style: marathiStyle),
                        SizedBox(
                          width: 80,
                          child: BilingualSimpleUnderlineInput(
                            controller: _w2SexCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text('वय :', style: marathiStyle),
                        SizedBox(
                          width: 60,
                          child: BilingualSimpleUnderlineInput(
                            controller: _w2AgeCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('व्यवसाय :', style: marathiStyle),
                        SizedBox(
                          width: 120,
                          child: BilingualSimpleUnderlineInput(
                            controller: _w2OccupationCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                        Text('पत्ता :', style: marathiStyle),
                        SizedBox(
                          width: 200,
                          child: BilingualSimpleUnderlineInput(
                            controller: _w2AddressCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    BilingualSimpleUnderlineInput(
                      controller: _w2AddressLine2Ctrl,
                      serifStyle: marathiStyle,
                    ),
                    const SizedBox(height: 20),

                    // --- SECTION 7 ---
                    ResponsiveFieldRow(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '७) नाशवंत मालमत्तेच्या विल्हेवाटीसाठी केलेली शिफारस/केलेली कार्यवाही : ',
                          style: marathiStyle,
                        ),
                        Expanded(
                          child: BilingualSimpleUnderlineInput(
                            controller: _perishableDisposalCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- SECTION 8 ---
                    ResponsiveFieldRow(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '८) मौल्यवान मालमत्ता ठेवण्यासाठी केलेली शिफारस/केलेली कार्यवाही : ',
                          style: marathiStyle,
                        ),
                        Expanded(
                          child: BilingualSimpleUnderlineInput(
                            controller: _valuableKeepingCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- SECTION 9 ---
                    Row(
                      children: [
                        Text('९) ओळख पटवावी लागली काय : ', style: marathiStyle),
                        const SizedBox(width: 8),
                        _chipSelector(
                          items: ['होय', 'नाही'],
                          selected: _identificationRequired,
                          onSelect: (val) {
                            setState(() {
                              _identificationRequired = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- SECTION 10 ---
                    Text(
                      '१०) जप्त केलेल्या/परत मिळालेल्या मालाचे वर्णन (योग्य नमुन्यात माहिती भरा व जोडा )',
                      style: marathiStyle,
                    ),
                    const SizedBox(height: 16),

                    // --- PROPERTY TABLE (section 10 attachment) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!widget.readOnly)
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                            onPressed: () {
                              setState(() {
                                _propertyRows.add(PropertyRow());
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      border: TableBorder.all(color: Colors.black87, width: 1),
                      columnWidths: const {
                        0: FixedColumnWidth(40),
                        1: FlexColumnWidth(6.0),
                        2: FlexColumnWidth(3.0),
                        3: FixedColumnWidth(40),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey.shade100),
                          children: [
                            _buildHeaderCell("Sr. No.\nअ. क."),
                            _buildHeaderCell("Property Description\nमालमत्तेचे वर्णन"),
                            _buildHeaderCell("Estimated Value (Rs)\nअंदाजे किंमत (रु.)"),
                            _buildHeaderCell("Action"),
                          ],
                        ),
                        ...List.generate(_propertyRows.length, (index) {
                          final row = _propertyRows[index];
                          return TableRow(
                            children: [
                              FormTableSrNoCell(index: index, style: serifStyle),
                              _buildTableInputCell(controller: row.descriptionCtrl, style: serifStyle, hintText: 'Description'),
                              _buildTableInputCell(controller: row.estimatedValueCtrl, style: serifStyle, hintText: 'Value in Rs.'),
                              Center(
                                child: widget.readOnly
                                    ? const SizedBox(width: 0, height: 40)
                                    : IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                        onPressed: () {
                                          if (_propertyRows.length > 1) {
                                            setState(() {
                                              _propertyRows.removeAt(index);
                                            });
                                          }
                                        },
                                      ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- SECTION 11 ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: marathiStyle,
                            children: [
                              const TextSpan(text: '११) जप्तीची '),
                              TextSpan(
                                text: 'परिस्थिती/कारणे',
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: ' : '),
                            ],
                          ),
                        ),
                        Expanded(
                          child: BilingualSimpleUnderlineInput(
                            controller: _circumstancesCtrl,
                            serifStyle: marathiStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    BilingualSimpleUnderlineInput(
                      controller: _circumstancesLine2Ctrl,
                      serifStyle: marathiStyle,
                    ),
                    const SizedBox(height: 8),
                    BilingualSimpleUnderlineInput(
                      controller: _circumstancesLine3Ctrl,
                      serifStyle: marathiStyle,
                    ),
                    const SizedBox(height: 16),
                    FormMrwFooter(
                      serifStyle: serifStyle,
                      fontSize: 12,
                      alignment: Alignment.centerRight,
                    ),
          ],
        ),
        if (_shows(kMemoBody) && (_shows(kSignatures) || _showAll))
                    const SizedBox(height: 24),
        if (_shows(kSignatures))
        FormPaperPage(
          formLabel: widget.pageRange ?? 'Page 30',
          children: [
                    const SizedBox(height: 24),

                    // --- SECTION 12 ---
                    Text(
                      '१२) वर नमूद करण्यात आलेली मालमत्ता पूर्ववत साक्षीदारांच्या समक्ष कायद्यातील तरतुदी नुसार जप्त करण्यात आली. आणि जप्तीच्या ज्ञापनाची ज्याच्याकडून मालमत्ता जप्त करण्यात आली. त्या इसमास/जागेत राहणाऱ्यास देण्यात आली.',
                      style: marathiStyle,
                    ),
                    const SizedBox(height: 16),

                    // --- SECTION 13 ---
                    RichText(
                      text: TextSpan(
                        style: marathiStyle,
                        children: [
                          const TextSpan(
                            text: '१३) खालील मालमत्ता अविष्ठित ',
                          ),
                          TextSpan(
                            text: 'आणि/किंवा',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(
                            text: ' मोहोरबंद करण्यात आली आणि त्यावर किंवा मालमत्तेवर पूर्ववत साक्षीदारांच्या सहया घेण्यात आल्या आहेत.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!widget.readOnly)
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                            onPressed: () {
                              setState(() {
                                _sealPropertyRows.add(SealPropertyRow());
                              });
                            },
                          ),
                      ],
                    ),
                    Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      border: TableBorder.all(color: Colors.black87, width: 1),
                      columnWidths: const {
                        0: FixedColumnWidth(50),
                        1: FlexColumnWidth(4.0),
                        2: FlexColumnWidth(5.0),
                        3: FixedColumnWidth(40),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey.shade100),
                          children: [
                            _buildHeaderCell('अ क्र\n(१)'),
                            _buildHeaderCell('मालमत्ता\n(२)'),
                            _buildHeaderCell('पुडक्यावर किंवा मालमत्तेवर सही घेण्यात आली.\n(३)'),
                            _buildHeaderCell('Action'),
                          ],
                        ),
                        ...List.generate(_sealPropertyRows.length, (index) {
                          final row = _sealPropertyRows[index];
                          return TableRow(
                            children: [
                              FormTableSrNoCell(index: index, style: marathiStyle),
                              _buildTableInputCell(
                                controller: row.propertyCtrl,
                                style: marathiStyle,
                              ),
                              _buildTableInputCell(
                                controller: row.signatureCtrl,
                                style: marathiStyle,
                              ),
                              Center(
                                child: widget.readOnly
                                    ? const SizedBox(width: 0, height: 40)
                                    : IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                        onPressed: () {
                                          if (_sealPropertyRows.length > 1) {
                                            setState(() {
                                              _sealPropertyRows.removeAt(index);
                                            });
                                          }
                                        },
                                      ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'मोहोरेचा नमुना खाली देण्यात आली आहे.',
                        style: marathiStyle,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- PANCHA & IO SIGNATURE BLOCK ---
                    ResponsiveFieldRow(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name of panchas:', style: serifStyle),
                              Text('पंचाची नांवे :', style: marathiStyle),
                              const SizedBox(height: 8),
                              ResponsiveFieldRow(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('(1) ', style: serifStyle),
                                  Expanded(
                                    child: BilingualSimpleUnderlineInput(
                                      controller: _pancha1NameCtrl,
                                      serifStyle: serifStyle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ResponsiveFieldRow(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Full Address: ', style: serifStyle),
                                  Expanded(
                                    child: BilingualSimpleUnderlineInput(
                                      controller: _pancha1Addr1Ctrl,
                                      serifStyle: serifStyle,
                                    ),
                                  ),
                                ],
                              ),
                              Text('पत्ता', style: marathiStyle),
                              BilingualSimpleUnderlineInput(
                                controller: _pancha1Addr2Ctrl,
                                serifStyle: serifStyle,
                              ),
                              const SizedBox(height: 4),
                              BilingualSimpleUnderlineInput(
                                controller: _pancha1Addr3Ctrl,
                                serifStyle: serifStyle,
                              ),
                              const SizedBox(height: 16),
                              ResponsiveFieldRow(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('(2) ', style: serifStyle),
                                  Expanded(
                                    child: BilingualSimpleUnderlineInput(
                                      controller: _pancha2NameCtrl,
                                      serifStyle: serifStyle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ResponsiveFieldRow(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Full Address: ', style: serifStyle),
                                  Expanded(
                                    child: BilingualSimpleUnderlineInput(
                                      controller: _pancha2Addr1Ctrl,
                                      serifStyle: serifStyle,
                                    ),
                                  ),
                                ],
                              ),
                              Text('पत्ता', style: marathiStyle),
                              BilingualSimpleUnderlineInput(
                                controller: _pancha2Addr2Ctrl,
                                serifStyle: serifStyle,
                              ),
                              const SizedBox(height: 4),
                              BilingualSimpleUnderlineInput(
                                controller: _pancha2Addr3Ctrl,
                                serifStyle: serifStyle,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Date: ', style: serifStyle),
                                  SizedBox(
                                    width: 50,
                                    child: BilingualSimpleUnderlineInput(
                                      controller: _panchaDateDayCtrl,
                                      serifStyle: serifStyle,
                                    ),
                                  ),
                                  Text(' / ', style: serifStyle),
                                  SizedBox(
                                    width: 50,
                                    child: BilingualSimpleUnderlineInput(
                                      controller: _panchaDateMonthCtrl,
                                      serifStyle: serifStyle,
                                    ),
                                  ),
                                  Text(' / ', style: serifStyle),
                                  SizedBox(
                                    width: 60,
                                    child: BilingualSimpleUnderlineInput(
                                      controller: _panchaDateYearCtrl,
                                      serifStyle: serifStyle,
                                    ),
                                  ),
                                ],
                              ),
                              Text('दिनांक', style: marathiStyle),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Signature of Panchas:', style: serifStyle),
                              Text('पंचाच्या सह्या :', style: marathiStyle),
                              const SizedBox(height: 8),
                              ResponsiveFieldRow(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('1) ', style: serifStyle),
                                  Expanded(
                                    child: BilingualSimpleUnderlineInput(
                                      controller: _pancha1SigCtrl,
                                      serifStyle: serifStyle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              ResponsiveFieldRow(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('2) ', style: serifStyle),
                                  Expanded(
                                    child: BilingualSimpleUnderlineInput(
                                      controller: _pancha2SigCtrl,
                                      serifStyle: serifStyle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 48),
                              Text(
                                'Name and Signature of Investigation Officer',
                                style: serifStyle,
                              ),
                              Text(FormIoTerminology.amaldarSignatureHeader, style: marathiStyle),
                              const SizedBox(height: 8),
                              ResponsiveFieldRow(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Name: ', style: serifStyle),
                                  Expanded(
                                    child: BilingualSimpleUnderlineInput(
                                      controller: _ioNameCtrl,
                                      serifStyle: serifStyle,
                                    ),
                                  ),
                                ],
                              ),
                              Text('${FormIoTerminology.name} :', style: marathiStyle),
                              const SizedBox(height: 8),
                              ResponsiveFieldRow(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Rank: ', style: serifStyle),
                                  SizedBox(
                                    width: 80,
                                    child: BilingualSimpleUnderlineInput(
                                      controller: _ioRankCtrl,
                                      serifStyle: serifStyle,
                                    ),
                                  ),
                                  Text(' B.No.if any: ', style: serifStyle),
                                  Expanded(
                                    child: BilingualSimpleUnderlineInput(
                                      controller: _ioBuckleNoCtrl,
                                      serifStyle: serifStyle,
                                    ),
                                  ),
                                ],
                              ),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Text('${FormIoTerminology.rank} :', style: marathiStyle),
                                  Text('${FormIoTerminology.badgeNo} :', style: marathiStyle),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FormMrwFooter(
                      serifStyle: serifStyle,
                      fontSize: 12,
                      alignment: Alignment.centerRight,
                    ),
                    const SizedBox(height: 24),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.start,
        maxLines: null,
        style: style.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade900,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 6.0),
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

  Widget _chipSelector({
    required List<String> items,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items.map((item) {
        final active = selected == item;
        return GestureDetector(
          onTap: widget.readOnly ? null : () => onSelect(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: active ? Colors.blue.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active ? Colors.blue : Colors.grey.shade300,
                width: active ? 1.5 : 1,
              ),
            ),
            child: Text(
              item,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? Colors.blue.shade900 : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SealPropertyRow {
  final TextEditingController propertyCtrl = TextEditingController();
  final TextEditingController signatureCtrl = TextEditingController();

  void dispose() {
    propertyCtrl.dispose();
    signatureCtrl.dispose();
  }

  Map<String, String> toMap() {
    return {
      'property': propertyCtrl.text.trim(),
      'signature': signatureCtrl.text.trim(),
    };
  }

  void fromMap(Map<String, dynamic> map) {
    propertyCtrl.text = map['property']?.toString() ?? '';
    signatureCtrl.text = map['signature']?.toString() ?? '';
  }
}

class PropertyRow {
  final TextEditingController descriptionCtrl = TextEditingController();
  final TextEditingController estimatedValueCtrl = TextEditingController();

  void dispose() {
    descriptionCtrl.dispose();
    estimatedValueCtrl.dispose();
  }

  Map<String, String> toMap() {
    return {
      'description': descriptionCtrl.text.trim(),
      'value': estimatedValueCtrl.text.trim(),
    };
  }

  void fromMap(Map<String, dynamic> map) {
    descriptionCtrl.text = map['description']?.toString() ?? '';
    estimatedValueCtrl.text = map['value']?.toString() ?? '';
  }
}
