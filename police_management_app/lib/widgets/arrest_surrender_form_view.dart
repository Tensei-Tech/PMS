import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bilingual_field.dart';
import 'form_paper_page.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';
import '../utils/form_io_terminology.dart';
import 'form_section_utils.dart';

class ArrestSurrenderFormView extends StatefulWidget {
  final bool readOnly;
  final Map<String, dynamic>? existingRecord;
  final String? formSection;
  final String? pageRange;

  const ArrestSurrenderFormView({
    super.key,
    this.readOnly = false,
    this.existingRecord,
    this.formSection,
    this.pageRange,
  });

  @override
  State<ArrestSurrenderFormView> createState() => ArrestSurrenderFormViewState();
}

class ArrestSurrenderFormViewState extends State<ArrestSurrenderFormView> {
  static const kForm3A = 'Form 3-A';
  static const kForm3B = 'Form 3-B';
  static const kForm3C = 'Form 3-C';
  static const _knownSectionIds = {kForm3A, kForm3B, kForm3C};

  bool _shows(String sectionId) => showsFormSection(
        activeSection: widget.formSection,
        sectionId: sectionId,
        knownSectionIds: _knownSectionIds,
      );

  bool get _showAll => showsAllFormSections(
        activeSection: widget.formSection,
        knownSectionIds: _knownSectionIds,
      );
  // Page 1
  final _distCtrl = TextEditingController();
  final _psCtrl = TextEditingController();
  final _firNoCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _accusedCodeCtrl = TextEditingController();
  
  final _arrestDateCtrl = TextEditingController();
  final _arrestTimeCtrl = TextEditingController();
  final _arrestGdNoCtrl = TextEditingController();
  final _arrestPlaceCtrl = TextEditingController();
  final _arrestDistCtrl = TextEditingController();
  final _arrestStateCtrl = TextEditingController();
  
  final _courtNameCtrl = TextEditingController();
  final _actsSectionsCtrl = TextEditingController();
  
  // Page 1: 5. checkboxes
  bool _arrestedAndForwarded = false;
  bool _arrestedAndBailed = false;
  bool _arrestedButAnticipatory = false;
  bool _arrestedAndRemandedPolice = false;
  bool _surrenderBailed = false;
  bool _surrenderJudicial = false;
  bool _surrenderPolice = false;

  // Page 1: 6. Particulars
  final _accusedNameCtrl = TextEditingController();
  final _accusedFatherCtrl = TextEditingController();
  final _accusedAlias1Ctrl = TextEditingController();
  final _accusedAlias2Ctrl = TextEditingController();
  final _accusedNationalityCtrl = TextEditingController();
  final _accusedVoterCtrl = TextEditingController();
  final _accusedPassportCtrl = TextEditingController();
  final _accusedDateIssueCtrl = TextEditingController();
  final _accusedPlaceIssueCtrl = TextEditingController();
  final _accusedReligionCtrl = TextEditingController();
  final _accusedCasteCtrl = TextEditingController();
  final _accusedScStCtrl = TextEditingController();
  final _accusedOccupationCtrl = TextEditingController();
  
  final _permAddressCtrl = TextEditingController();
  final _permStateCtrl = TextEditingController();
  final _permDistCtrl = TextEditingController();
  final _permPsCtrl = TextEditingController();
  
  final _presAddressCtrl = TextEditingController();
  final _presStateCtrl = TextEditingController();
  final _presDistCtrl = TextEditingController();
  final _presPsCtrl = TextEditingController();
  
  final _injuriesCtrl = TextEditingController();

  // Page 2: 8. Custody details
  final _custodyDateCtrl = TextEditingController();
  final _custodyHoursCtrl = TextEditingController();
  final _custodyPlaceCtrl = TextEditingController();
  
  final _article1Ctrl = TextEditingController();
  final _article2Ctrl = TextEditingController();
  final _article3Ctrl = TextEditingController();
  final _article4Ctrl = TextEditingController();
  final _article5Ctrl = TextEditingController();
  final _article6Ctrl = TextEditingController();
  
  final _intimationNameCtrl = TextEditingController();
  final _intimationRelCtrl = TextEditingController();
  
  // Page 2: 9. Physical features
  final _physTableCtrl = <String, TextEditingController>{};
  
  // Page 3: 10 & 11. Profile
  bool _fingerprintTaken = false;
  
  // 11(a)
  bool _livingAlone = false;
  bool _livingWithFamily = false;
  bool _livingWithAssociate = false;
  bool _livingPucca = false;
  bool _livingHotel = false;
  bool _livingHostel = false;
  bool _livingKachcha = false;
  bool _livingThatched = false;
  bool _livingSlum = false;
  bool _livingHomeless = false;
  bool _livingHarbourer = false;

  final _eduQualCtrl = TextEditingController();
  final _occupation2Ctrl = TextEditingController();
  
  // 11(d)
  bool _incomeLower = false; // Below 25000
  bool _incomeLowerMid = false; // 25001-50000
  bool _incomeMiddle = false; // 50001-100000
  bool _incomeUpperMid = false; // 100000-200000
  bool _incomeUpperMid2 = false; // 200000-300000
  bool _incomeUpper = false; // >300000
  
  // 12. Records
  bool _isDangerous = false;
  bool _prevEscaped = false;
  bool _generallyArmed = false;
  bool _operatesWithAccomplices = false;
  bool _pastCriminal = false;
  bool _isRecidivism = false;
  bool _likelyToEscape = false;
  bool _releasedOnBail = false;
  bool _wantedMany = false;
  final _caseRefSecCtrl = TextEditingController();
  
  // 13. Panchas
  final _panch1NameCtrl = TextEditingController();
  final _panch2NameCtrl = TextEditingController();
  final _panch1SigCtrl = TextEditingController();
  final _panch2SigCtrl = TextEditingController();
  
  // 14. Signatures
  final _arrestedPersonSigCtrl = TextEditingController();
  final _ioSigCtrl = TextEditingController();
  
  // 9. Physical features — "Other features if any"
  final _otherFeaturesCtrl = TextEditingController();
  
  // 15. Place/Date
  final _finalPlaceCtrl = TextEditingController();
  final _finalDateCtrl = TextEditingController();
  final _finalNameCtrl = TextEditingController();
  final _finalRankCtrl = TextEditingController();
  final _finalNoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize 26 physical columns
    for (int i = 1; i <= 26; i++) {
      _physTableCtrl[i.toString()] = TextEditingController();
    }
    
    if (widget.existingRecord != null) {
      hydrateFrom(widget.existingRecord!);
    }
  }

  @override
  void dispose() {
    _distCtrl.dispose();
    _psCtrl.dispose();
    _firNoCtrl.dispose();
    _yearCtrl.dispose();
    _dateCtrl.dispose();
    _accusedCodeCtrl.dispose();
    _arrestDateCtrl.dispose();
    _arrestTimeCtrl.dispose();
    _arrestGdNoCtrl.dispose();
    _arrestPlaceCtrl.dispose();
    _arrestDistCtrl.dispose();
    _arrestStateCtrl.dispose();
    _courtNameCtrl.dispose();
    _actsSectionsCtrl.dispose();
    _accusedNameCtrl.dispose();
    _accusedFatherCtrl.dispose();
    _accusedAlias1Ctrl.dispose();
    _accusedAlias2Ctrl.dispose();
    _accusedNationalityCtrl.dispose();
    _accusedVoterCtrl.dispose();
    _accusedPassportCtrl.dispose();
    _accusedDateIssueCtrl.dispose();
    _accusedPlaceIssueCtrl.dispose();
    _accusedReligionCtrl.dispose();
    _accusedCasteCtrl.dispose();
    _accusedScStCtrl.dispose();
    _accusedOccupationCtrl.dispose();
    _permAddressCtrl.dispose();
    _permStateCtrl.dispose();
    _permDistCtrl.dispose();
    _permPsCtrl.dispose();
    _presAddressCtrl.dispose();
    _presStateCtrl.dispose();
    _presDistCtrl.dispose();
    _presPsCtrl.dispose();
    _injuriesCtrl.dispose();
    _custodyDateCtrl.dispose();
    _custodyHoursCtrl.dispose();
    _custodyPlaceCtrl.dispose();
    _article1Ctrl.dispose();
    _article2Ctrl.dispose();
    _article3Ctrl.dispose();
    _article4Ctrl.dispose();
    _article5Ctrl.dispose();
    _article6Ctrl.dispose();
    _intimationNameCtrl.dispose();
    _intimationRelCtrl.dispose();
    for (var c in _physTableCtrl.values) {
      c.dispose();
    }
    _eduQualCtrl.dispose();
    _occupation2Ctrl.dispose();
    _caseRefSecCtrl.dispose();
    _panch1NameCtrl.dispose();
    _panch2NameCtrl.dispose();
    _panch1SigCtrl.dispose();
    _panch2SigCtrl.dispose();
    _arrestedPersonSigCtrl.dispose();
    _ioSigCtrl.dispose();
    _otherFeaturesCtrl.dispose();
    _finalPlaceCtrl.dispose();
    _finalDateCtrl.dispose();
    _finalNameCtrl.dispose();
    _finalRankCtrl.dispose();
    _finalNoCtrl.dispose();
    super.dispose();
  }

  void hydrateFrom(Map<String, dynamic> data) {
    setState(() {
      _distCtrl.text = data['dist'] ?? '';
      _psCtrl.text = data['ps'] ?? '';
      _firNoCtrl.text = data['firNo'] ?? '';
      _yearCtrl.text = data['year'] ?? '';
      _dateCtrl.text = data['date'] ?? '';
      _accusedCodeCtrl.text = data['accusedCode'] ?? '';
      _arrestDateCtrl.text = data['arrestDate'] ?? '';
      _arrestTimeCtrl.text = data['arrestTime'] ?? '';
      _arrestGdNoCtrl.text = data['arrestGdNo'] ?? '';
      _arrestPlaceCtrl.text = data['arrestPlace'] ?? '';
      _arrestDistCtrl.text = data['arrestDist'] ?? '';
      _arrestStateCtrl.text = data['arrestState'] ?? '';
      _courtNameCtrl.text = data['courtName'] ?? '';
      _actsSectionsCtrl.text = data['actsSections'] ?? '';
      
      _arrestedAndForwarded = data['arrestedAndForwarded'] == true;
      _arrestedAndBailed = data['arrestedAndBailed'] == true;
      _arrestedButAnticipatory = data['arrestedButAnticipatory'] == true;
      _arrestedAndRemandedPolice = data['arrestedAndRemandedPolice'] == true;
      _surrenderBailed = data['surrenderBailed'] == true;
      _surrenderJudicial = data['surrenderJudicial'] == true;
      _surrenderPolice = data['surrenderPolice'] == true;

      _accusedNameCtrl.text = data['accusedName'] ?? '';
      _accusedFatherCtrl.text = data['accusedFather'] ?? '';
      _accusedAlias1Ctrl.text = data['accusedAlias1'] ?? '';
      _accusedAlias2Ctrl.text = data['accusedAlias2'] ?? '';
      _accusedNationalityCtrl.text = data['accusedNationality'] ?? '';
      _accusedVoterCtrl.text = data['accusedVoter'] ?? '';
      _accusedPassportCtrl.text = data['accusedPassport'] ?? '';
      _accusedDateIssueCtrl.text = data['accusedDateIssue'] ?? '';
      _accusedPlaceIssueCtrl.text = data['accusedPlaceIssue'] ?? '';
      _accusedReligionCtrl.text = data['accusedReligion'] ?? '';
      _accusedCasteCtrl.text = data['accusedCaste'] ?? '';
      _accusedScStCtrl.text = data['accusedScSt'] ?? '';
      _accusedOccupationCtrl.text = data['accusedOccupation'] ?? '';
      _permAddressCtrl.text = data['permAddress'] ?? '';
      _permStateCtrl.text = data['permState'] ?? '';
      _permDistCtrl.text = data['permDist'] ?? '';
      _permPsCtrl.text = data['permPs'] ?? '';
      _presAddressCtrl.text = data['presAddress'] ?? '';
      _presStateCtrl.text = data['presState'] ?? '';
      _presDistCtrl.text = data['presDist'] ?? '';
      _presPsCtrl.text = data['presPs'] ?? '';
      _injuriesCtrl.text = data['injuries'] ?? '';
      
      _custodyDateCtrl.text = data['custodyDate'] ?? '';
      _custodyHoursCtrl.text = data['custodyHours'] ?? '';
      _custodyPlaceCtrl.text = data['custodyPlace'] ?? '';
      
      _article1Ctrl.text = data['article1'] ?? '';
      _article2Ctrl.text = data['article2'] ?? '';
      _article3Ctrl.text = data['article3'] ?? '';
      _article4Ctrl.text = data['article4'] ?? '';
      _article5Ctrl.text = data['article5'] ?? '';
      _article6Ctrl.text = data['article6'] ?? '';
      
      _intimationNameCtrl.text = data['intimationName'] ?? '';
      _intimationRelCtrl.text = data['intimationRel'] ?? '';
      
      if (data['physTable'] is Map) {
        final pt = data['physTable'] as Map;
        for (int i = 1; i <= 26; i++) {
          _physTableCtrl[i.toString()]?.text = pt[i.toString()] ?? '';
        }
      }
      
      _fingerprintTaken = data['fingerprintTaken'] == true;
      _livingAlone = data['livingAlone'] == true;
      _livingWithFamily = data['livingWithFamily'] == true;
      _livingWithAssociate = data['livingWithAssociate'] == true;
      _livingPucca = data['livingPucca'] == true;
      _livingHotel = data['livingHotel'] == true;
      _livingHostel = data['livingHostel'] == true;
      _livingKachcha = data['livingKachcha'] == true;
      _livingThatched = data['livingThatched'] == true;
      _livingSlum = data['livingSlum'] == true;
      _livingHomeless = data['livingHomeless'] == true;
      _livingHarbourer = data['livingHarbourer'] == true;
      
      _eduQualCtrl.text = data['eduQual'] ?? '';
      _occupation2Ctrl.text = data['occupation2'] ?? '';
      
      _incomeLower = data['incomeLower'] == true;
      _incomeLowerMid = data['incomeLowerMid'] == true;
      _incomeMiddle = data['incomeMiddle'] == true;
      _incomeUpperMid = data['incomeUpperMid'] == true;
      _incomeUpperMid2 = data['incomeUpperMid2'] == true;
      _incomeUpper = data['incomeUpper'] == true;
      
      _isDangerous = data['isDangerous'] == true;
      _prevEscaped = data['prevEscaped'] == true;
      _generallyArmed = data['generallyArmed'] == true;
      _operatesWithAccomplices = data['operatesWithAccomplices'] == true;
      _pastCriminal = data['pastCriminal'] == true;
      _isRecidivism = data['isRecidivism'] == true;
      _likelyToEscape = data['likelyToEscape'] == true;
      _releasedOnBail = data['releasedOnBail'] == true;
      _wantedMany = data['wantedMany'] == true;
      _caseRefSecCtrl.text = data['caseRefSec'] ?? '';
      
      _panch1NameCtrl.text = data['panch1Name'] ?? '';
      _panch2NameCtrl.text = data['panch2Name'] ?? '';
      _panch1SigCtrl.text = data['panch1Sig'] ?? '';
      _panch2SigCtrl.text = data['panch2Sig'] ?? '';
      
      _arrestedPersonSigCtrl.text = data['arrestedPersonSig'] ?? '';
      _ioSigCtrl.text = data['ioSig'] ?? '';
      _otherFeaturesCtrl.text = data['otherFeatures'] ?? '';
      
      _finalPlaceCtrl.text = data['finalPlace'] ?? '';
      _finalDateCtrl.text = data['finalDate'] ?? '';
      _finalNameCtrl.text = data['finalName'] ?? '';
      _finalRankCtrl.text = data['finalRank'] ?? '';
      _finalNoCtrl.text = data['finalNo'] ?? '';
    });
  }

  Map<String, dynamic> extractData() {
    final Map<String, dynamic> pt = {};
    for (int i = 1; i <= 26; i++) {
      pt[i.toString()] = _physTableCtrl[i.toString()]?.text ?? '';
    }
    return {
      'dist': _distCtrl.text,
      'ps': _psCtrl.text,
      'firNo': _firNoCtrl.text,
      'year': _yearCtrl.text,
      'date': _dateCtrl.text,
      'accusedCode': _accusedCodeCtrl.text,
      'arrestDate': _arrestDateCtrl.text,
      'arrestTime': _arrestTimeCtrl.text,
      'arrestGdNo': _arrestGdNoCtrl.text,
      'arrestPlace': _arrestPlaceCtrl.text,
      'arrestDist': _arrestDistCtrl.text,
      'arrestState': _arrestStateCtrl.text,
      'courtName': _courtNameCtrl.text,
      'actsSections': _actsSectionsCtrl.text,
      'arrestedAndForwarded': _arrestedAndForwarded,
      'arrestedAndBailed': _arrestedAndBailed,
      'arrestedButAnticipatory': _arrestedButAnticipatory,
      'arrestedAndRemandedPolice': _arrestedAndRemandedPolice,
      'surrenderBailed': _surrenderBailed,
      'surrenderJudicial': _surrenderJudicial,
      'surrenderPolice': _surrenderPolice,
      'accusedName': _accusedNameCtrl.text,
      'accusedFather': _accusedFatherCtrl.text,
      'accusedAlias1': _accusedAlias1Ctrl.text,
      'accusedAlias2': _accusedAlias2Ctrl.text,
      'accusedNationality': _accusedNationalityCtrl.text,
      'accusedVoter': _accusedVoterCtrl.text,
      'accusedPassport': _accusedPassportCtrl.text,
      'accusedDateIssue': _accusedDateIssueCtrl.text,
      'accusedPlaceIssue': _accusedPlaceIssueCtrl.text,
      'accusedReligion': _accusedReligionCtrl.text,
      'accusedCaste': _accusedCasteCtrl.text,
      'accusedScSt': _accusedScStCtrl.text,
      'accusedOccupation': _accusedOccupationCtrl.text,
      'permAddress': _permAddressCtrl.text,
      'permState': _permStateCtrl.text,
      'permDist': _permDistCtrl.text,
      'permPs': _permPsCtrl.text,
      'presAddress': _presAddressCtrl.text,
      'presState': _presStateCtrl.text,
      'presDist': _presDistCtrl.text,
      'presPs': _presPsCtrl.text,
      'injuries': _injuriesCtrl.text,
      'custodyDate': _custodyDateCtrl.text,
      'custodyHours': _custodyHoursCtrl.text,
      'custodyPlace': _custodyPlaceCtrl.text,
      'article1': _article1Ctrl.text,
      'article2': _article2Ctrl.text,
      'article3': _article3Ctrl.text,
      'article4': _article4Ctrl.text,
      'article5': _article5Ctrl.text,
      'article6': _article6Ctrl.text,
      'intimationName': _intimationNameCtrl.text,
      'intimationRel': _intimationRelCtrl.text,
      'physTable': pt,
      'fingerprintTaken': _fingerprintTaken,
      'livingAlone': _livingAlone,
      'livingWithFamily': _livingWithFamily,
      'livingWithAssociate': _livingWithAssociate,
      'livingPucca': _livingPucca,
      'livingHotel': _livingHotel,
      'livingHostel': _livingHostel,
      'livingKachcha': _livingKachcha,
      'livingThatched': _livingThatched,
      'livingSlum': _livingSlum,
      'livingHomeless': _livingHomeless,
      'livingHarbourer': _livingHarbourer,
      'eduQual': _eduQualCtrl.text,
      'occupation2': _occupation2Ctrl.text,
      'incomeLower': _incomeLower,
      'incomeLowerMid': _incomeLowerMid,
      'incomeMiddle': _incomeMiddle,
      'incomeUpperMid': _incomeUpperMid,
      'incomeUpperMid2': _incomeUpperMid2,
      'incomeUpper': _incomeUpper,
      'isDangerous': _isDangerous,
      'prevEscaped': _prevEscaped,
      'generallyArmed': _generallyArmed,
      'operatesWithAccomplices': _operatesWithAccomplices,
      'pastCriminal': _pastCriminal,
      'isRecidivism': _isRecidivism,
      'likelyToEscape': _likelyToEscape,
      'releasedOnBail': _releasedOnBail,
      'wantedMany': _wantedMany,
      'caseRefSec': _caseRefSecCtrl.text,
      'panch1Name': _panch1NameCtrl.text,
      'panch2Name': _panch2NameCtrl.text,
      'panch1Sig': _panch1SigCtrl.text,
      'panch2Sig': _panch2SigCtrl.text,
      'arrestedPersonSig': _arrestedPersonSigCtrl.text,
      'ioSig': _ioSigCtrl.text,
      'otherFeatures': _otherFeaturesCtrl.text,
      'finalPlace': _finalPlaceCtrl.text,
      'finalDate': _finalDateCtrl.text,
      'finalName': _finalNameCtrl.text,
      'finalRank': _finalRankCtrl.text,
      'finalNo': _finalNoCtrl.text,
      'formSection': widget.formSection ?? '',
      'pageRange': widget.pageRange ?? '',
    };
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged, TextStyle serifStyle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: widget.readOnly ? null : onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Flexible(child: Text(label, style: serifStyle.copyWith(fontSize: 12))),
      ],
    );
  }

  Widget _buildYesNo(String label, bool value, ValueChanged<bool?> onChanged, TextStyle serifStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: serifStyle.copyWith(fontWeight: FontWeight.w600))),
          Row(
            children: [
              Text('Yes', style: serifStyle.copyWith(fontSize: 12)),
              Checkbox(value: value, onChanged: widget.readOnly ? null : (v) => onChanged(true)),
              const SizedBox(width: 8),
              Text('No', style: serifStyle.copyWith(fontSize: 12)),
              Checkbox(value: !value, onChanged: widget.readOnly ? null : (v) => onChanged(false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTable1(TextStyle serifStyle) {
    return Table(
      border: TableBorder.all(color: Colors.black87),
      children: [
        TableRow(
          children: [
            _buildTableHeader('Sr. No.\nअ.क्र.', '1.'),
            _buildTableHeader('Sex\nलिंग', '2.'),
            _buildTableHeader('Date/year of Birth\nजन्म तारीख/वर्ष', '3.'),
            _buildTableHeader('Build\nबांधा', '4.'),
            _buildTableHeader('Height in Cms.\nउंची से.मी.', '5.'),
            _buildTableHeader('Complexion\nवर्ण', '6.'),
            _buildTableHeader('identification (Mark)\nओळखचिन्ह', '7.'),
            _buildTableHeader('Deformities Peculiarities\nव्यंग व वैशिष्टे', '8.'),
            _buildTableHeader('Teeth\nदात', '9.'),
            _buildTableHeader('Hair\nकेस', '10.'),
          ]
        ),
        TableRow(
          children: List.generate(10, (i) => _buildTableCell(_physTableCtrl[(i+1).toString()]!, serifStyle))
        ),
      ],
    );
  }

  Widget _buildTable2(TextStyle serifStyle) {
    return Table(
      border: TableBorder.all(color: Colors.black87),
      children: [
        TableRow(
          children: [
            _buildTableHeader('Eye\nडोळे', '11'),
            _buildTableHeader('Habits\nसवयी', '12'),
            _buildTableHeader('Dress Habits\nपोषाखाच्या सवयी', '13'),
            _buildTableHeader('Languages\nबोली/भाषा', '14'),
            _buildTableHeader('Burn Mark\nभाजल्याच्या खुणा', '15'),
            _buildTableHeader('Leucoderma\nकोळ', '16'),
            _buildTableHeader('Mole\nतिळ', '17'),
            _buildTableHeader('Scar\nवण', '18'),
            _buildTableHeader('Tattoo\nगोंदण', '19'),
            _buildTableHeader('Forehead\nकपाळ', '20'),
          ]
        ),
        TableRow(
          children: List.generate(10, (i) => _buildTableCell(_physTableCtrl[(i+11).toString()]!, serifStyle))
        ),
      ],
    );
  }

  Widget _buildTable3(TextStyle serifStyle) {
    return Table(
      border: TableBorder.all(color: Colors.black87),
      children: [
        TableRow(
          children: [
            _buildTableHeader('Ear\nकान', '21'),
            _buildTableHeader('Noes\nनाक', '22'),
            _buildTableHeader('Moustaches\nमिशी', '23'),
            _buildTableHeader('Speech/voice\nबोलण्याची पध्दत', '24'),
            _buildTableHeader('Face\nचेहरा', '25'),
            _buildTableHeader('Lips\nओठ', '26'),
          ]
        ),
        TableRow(
          children: List.generate(6, (i) => _buildTableCell(_physTableCtrl[(i+21).toString()]!, serifStyle))
        ),
      ],
    );
  }

  Widget _buildTableHeader(String label, String number) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.black, height: 8),
          Text(number, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildTableCell(TextEditingController ctrl, TextStyle serifStyle) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextField(
        controller: ctrl,
        minLines: 3,
        maxLines: 5,
        textAlign: TextAlign.start,
        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
        style: serifStyle.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
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
        if (_shows(kForm3A))
        FormPaperPage(
          formLabel: widget.pageRange ?? 'Page 9',
          children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'ARREST/COURT SURRENDER FORM',
                            style: serifStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'अटकेचा पंचनामा/ न्यायालयाच्या स्वाधीन होण्याचा नमुना',
                            style: GoogleFonts.notoSansDevanagari(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '(Separate Memo for each accused)',
                            style: serifStyle.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '(प्रत्येक आरोपीसाठी स्वतंत्र नमुना वापरावा)',
                            style: marathiLabelStyle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.black87, thickness: 2, height: 32),

                    // 1) District / P.S. / FIR / Year / Date
                    BilingualFieldRow(fields: [
                      BilingualField(label: '1) District: ', marathiLabel: 'जिल्हा', controller: _distCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                      BilingualField(label: 'P.S.: ', marathiLabel: 'पो.स्टे.', controller: _psCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    ]),
                    BilingualFieldRow(fields: [
                      BilingualField(label: 'FIR/Proceeding/G.D.No: ', marathiLabel: 'पहिली खबर / दैनंदिनी क्र.', controller: _firNoCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                      BilingualField(label: 'Year:=20', marathiLabel: 'वर्ष', controller: _yearCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    ]),
                    const SizedBox(height: 12),
                    BilingualField(label: 'Date: ', marathiLabel: 'दिनांक', controller: _dateCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    const SizedBox(height: 12),
                    BilingualWideField(label: 'Alphanumeric Code of the Accused: ', marathiLabel: 'आरोपीचा अक्षरांकित कोड', controller: _accusedCodeCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    const SizedBox(height: 24),

                    // 2) Arrest / surrender date, time, place
                    BilingualSectionHeader(
                      label: '2) Date, Time & place of Arrest/surrender :-',
                      marathiLabel: 'अटक / स्वाधीन होण्याची तारीख, वेळ व ठिकाण',
                      serifStyle: serifStyle,
                      marathiLabelStyle: marathiLabelStyle,
                    ),
                    const SizedBox(height: 12),
                    BilingualFieldRow(fields: [
                      BilingualField(label: 'Date: ', marathiLabel: 'दिनांक', controller: _arrestDateCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                      BilingualField(label: 'Time: ', marathiLabel: 'वेळ', controller: _arrestTimeCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                      BilingualField(label: 'G.D.No.: ', marathiLabel: 'दैनंदिनी क्र.', controller: _arrestGdNoCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    ]),
                    const SizedBox(height: 12),
                    BilingualFieldRow(fields: [
                      BilingualField(label: 'Place of Arrest — P.S.: ', marathiLabel: 'अटक ठिकाण — पो.स्टे.', controller: _arrestPlaceCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                      BilingualField(label: 'Dist.: ', marathiLabel: 'जिल्हा', controller: _arrestDistCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                      BilingualField(label: 'State.: ', marathiLabel: 'राज्य', controller: _arrestStateCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    ]),
                    const SizedBox(height: 24),

                    // 3) Court name
                    BilingualWideField(
                      label: '3) Name of the Court (if surrendered) :- ',
                      marathiLabel: 'न्यायालयाचे नाव (स्वाधीन झाल्यास)',
                      controller: _courtNameCtrl,
                      serifStyle: serifStyle,
                      marathiLabelStyle: marathiLabelStyle,
                    ),
                    const SizedBox(height: 24),

                    // 4) Acts and sections
                    BilingualWideField(
                      label: '4) Acts and sections:- ',
                      marathiLabel: 'अधिनियम व कलमे',
                      controller: _actsSectionsCtrl,
                      serifStyle: serifStyle,
                      marathiLabelStyle: marathiLabelStyle,
                    ),
                    const SizedBox(height: 24),

                    // 5) Arrest status checkboxes
                    BilingualSectionHeader(label: '5)', marathiLabel: 'अटक / स्वाधीन स्थिती', serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _buildCheckbox('Arrested and forward', _arrestedAndForwarded, (v) => setState(() => _arrestedAndForwarded = v ?? false), serifStyle),
                        _buildCheckbox('Arrested and released on bail or PR bound', _arrestedAndBailed, (v) => setState(() => _arrestedAndBailed = v ?? false), serifStyle),
                        _buildCheckbox('Arrested but released on anticipatory bail', _arrestedButAnticipatory, (v) => setState(() => _arrestedButAnticipatory = v ?? false), serifStyle),
                        _buildCheckbox('Arrested and remanded to police Custody', _arrestedAndRemandedPolice, (v) => setState(() => _arrestedAndRemandedPolice = v ?? false), serifStyle),
                        _buildCheckbox('Surrender in court and bailed out', _surrenderBailed, (v) => setState(() => _surrenderBailed = v ?? false), serifStyle),
                        _buildCheckbox('Surrender in court and sent to judicial Custody', _surrenderJudicial, (v) => setState(() => _surrenderJudicial = v ?? false), serifStyle),
                        _buildCheckbox('Surrender in court and remanded to police custody', _surrenderPolice, (v) => setState(() => _surrenderPolice = v ?? false), serifStyle),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 6) Particulars of accused
                    BilingualSectionHeader(
                      label: '6) Particulars of the Accused :-',
                      marathiLabel: 'आरोपीचा तपशील',
                      serifStyle: serifStyle,
                      marathiLabelStyle: marathiLabelStyle,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BilingualWideField(label: '(i) Name (नांव) :- ', marathiLabel: 'नांव', controller: _accusedNameCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          const SizedBox(height: 12),
                          BilingualWideField(label: '(ii) Father\'s/Husband\'s/Guardian\'s Name :- ', marathiLabel: 'वडिलांचे/पतीचे/पालकाचे नांव', controller: _accusedFatherCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          const SizedBox(height: 12),
                          BilingualWideField(label: '(iii) First Alias (पहिले टोपण नांव) :- ', marathiLabel: 'पहिले टोपण नांव', controller: _accusedAlias1Ctrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          const SizedBox(height: 12),
                          BilingualWideField(label: '(iv) Second Alias (दुसरे टोपण नांव) :- ', marathiLabel: 'दुसरे टोपण नांव', controller: _accusedAlias2Ctrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          const SizedBox(height: 12),
                          BilingualWideField(label: '(v) Nationality (राष्ट्रीयत्व) :- ', marathiLabel: 'राष्ट्रीयत्व', controller: _accusedNationalityCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          const SizedBox(height: 12),
                          BilingualFieldRow(fields: [
                            BilingualField(label: '(vi) (a) Voter ID Card No: - ', marathiLabel: 'मतदार ओळखपत्र क्र.', controller: _accusedVoterCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualField(label: '(b) *Passport No: - ', marathiLabel: 'पासपोर्ट क्र.', controller: _accusedPassportCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          ]),
                          const SizedBox(height: 12),
                          BilingualFieldRow(fields: [
                            BilingualField(label: '(c) Date of issue :- ', marathiLabel: 'जारी केल्याची तारीख', controller: _accusedDateIssueCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualField(label: '(d) *Place of Issue :- ', marathiLabel: 'जारी केल्याचे ठिकाण', controller: _accusedPlaceIssueCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          ]),
                          const SizedBox(height: 12),
                          BilingualFieldRow(fields: [
                            BilingualField(label: '(vii) Religion: - ', marathiLabel: 'धर्म', controller: _accusedReligionCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualField(label: '(viii) *Cast/Tribe: - ', marathiLabel: 'जात/आदिवासी', controller: _accusedCasteCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          ]),
                          const SizedBox(height: 12),
                          BilingualFieldRow(fields: [
                            BilingualField(label: '(ix) SC/ST/OBC :- ', marathiLabel: 'अ.जा./अ.ज.ज./OBC', controller: _accusedScStCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualField(label: '(x) *Occupation :- ', marathiLabel: 'व्यवसाय', controller: _accusedOccupationCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          ]),
                          const SizedBox(height: 12),
                          BilingualMultilineField(label: '(xi) Permanent Address :-', marathiLabel: 'स्थायी पत्ता', controller: _permAddressCtrl, minLines: 2, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          const SizedBox(height: 12),
                          BilingualFieldRow(fields: [
                            BilingualField(label: 'State :- ', marathiLabel: 'राज्य', controller: _permStateCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualField(label: 'Dist.:- ', marathiLabel: 'जिल्हा', controller: _permDistCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualField(label: 'P.S. :- ', marathiLabel: 'पो.स्टे.', controller: _permPsCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          ]),
                          const SizedBox(height: 12),
                          BilingualMultilineField(label: '(xii) Present Address:-', marathiLabel: 'सध्याचा पत्ता', controller: _presAddressCtrl, minLines: 2, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          const SizedBox(height: 12),
                          BilingualFieldRow(fields: [
                            BilingualField(label: 'State: - ', marathiLabel: 'राज्य', controller: _presStateCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualField(label: 'Dist.:- ', marathiLabel: 'जिल्हा', controller: _presDistCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualField(label: 'P.S. :- ', marathiLabel: 'पो.स्टे.', controller: _presPsCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 7) Injuries
                    BilingualMultilineField(
                      label: '7) Injuries, cause of injuries and physical condition of the accused person (indicate if medically examined)',
                      marathiLabel: 'आरोपीच्या जखमा, जखमांचे कारण व शारीरिक स्थिती (वैद्यकीय तपासणी झाली असल्यास नमूद करावे)',
                      controller: _injuriesCtrl,
                      minLines: 3,
                      serifStyle: serifStyle,
                      marathiLabelStyle: marathiLabelStyle,
                    ),
          ],
        ),
        if (_shows(kForm3A) && (_shows(kForm3B) || _showAll))
                    const SizedBox(height: 24),
        if (_shows(kForm3B))
        FormPaperPage(
          formLabel: widget.pageRange ?? 'Page 10',
          children: [
                    Align(alignment: Alignment.centerRight, child: Text('Form: 3-B', style: serifStyle.copyWith(fontWeight: FontWeight.bold))),
                    const SizedBox(height: 16),

                    // 8) Custody
                    BilingualSectionHeader(
                      label: '8) The accused, after being informed of the grounds of arrest and legal rights, was duly taken into custody on :-',
                      marathiLabel: 'अटकेचे कारण व कायदेशीर हक्क समजावून आरोपी योग्यरित्या ताब्यात घेतला',
                      serifStyle: serifStyle,
                      marathiLabelStyle: marathiLabelStyle,
                    ),
                    const SizedBox(height: 12),
                    BilingualFieldRow(fields: [
                      BilingualField(label: '(date) at :- ', marathiLabel: 'दिनांक', controller: _custodyDateCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                      BilingualField(label: '(hours) at :- ', marathiLabel: 'वेळ', controller: _custodyHoursCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                      BilingualField(label: '(place). ', marathiLabel: 'ठिकाण', controller: _custodyPlaceCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    ]),
                    const SizedBox(height: 16),
                    Text(
                      'The following article(s) was/were found on physical search conducted on the person of the accused and were taken into possession for which a receipt was given to the accused. **',
                      style: serifStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    BilingualFieldRow(fields: [
                      BilingualField(label: '1) ', marathiLabel: '१', controller: _article1Ctrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                      BilingualField(label: '2) ', marathiLabel: '२', controller: _article2Ctrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    ]),
                    const SizedBox(height: 8),
                    BilingualFieldRow(fields: [
                      BilingualField(label: '3) ', marathiLabel: '३', controller: _article3Ctrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                      BilingualField(label: '4) ', marathiLabel: '४', controller: _article4Ctrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    ]),
                    const SizedBox(height: 8),
                    BilingualFieldRow(fields: [
                      BilingualField(label: '5) ', marathiLabel: '५', controller: _article5Ctrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                      BilingualField(label: '6) ', marathiLabel: '६', controller: _article6Ctrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    ]),
                    const SizedBox(height: 16),
                    Text(
                      'Necessary wearing apparels were left on the accused for the sake of human dignity and body protection',
                      style: serifStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'मानवी प्रतिष्ठेसाठी व शरीर झाकण्यासाठी आरोपीच्या अंगावर आवश्यक तेवढे कपडे ठेवण्यात आले होते.',
                      style: marathiLabelStyle.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The accused was cautioned to keep him/herself covered for purpose of identification.',
                      style: serifStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    BilingualFieldRow(fields: [
                      BilingualField(label: 'Intimation given to Name: ', marathiLabel: 'सूचना दिली — नांव', controller: _intimationNameCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                      BilingualField(label: '(Relationship): ', marathiLabel: 'नाते', controller: _intimationRelCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    ]),
                    const SizedBox(height: 24),

                    // 9) Physical features
                    BilingualSectionHeader(
                      label: '9) Physical features, deformities and other details of the accused:-',
                      marathiLabel: 'आरोपीची शारीरिक वैशिष्ट्ये, व्यंग व इतर तपशील',
                      serifStyle: serifStyle,
                      marathiLabelStyle: marathiLabelStyle,
                    ),
                    const SizedBox(height: 12),
                    _buildTable1(serifStyle),
                    const SizedBox(height: 16),
                    _buildTable2(serifStyle),
                    const SizedBox(height: 16),
                    _buildTable3(serifStyle),
                    const SizedBox(height: 16),
                    BilingualMultilineField(
                      label: 'Other features if any:',
                      marathiLabel: 'इतर वैशिष्टे असल्यास',
                      controller: _otherFeaturesCtrl,
                      minLines: 2,
                      serifStyle: serifStyle,
                      marathiLabelStyle: marathiLabelStyle,
                    ),
          ],
        ),
        if (_shows(kForm3B) && (_shows(kForm3C) || _showAll))
                    const SizedBox(height: 24),
        if (_shows(kForm3C))
        FormPaperPage(
          formLabel: widget.pageRange ?? 'Page 11',
          children: [
                    Align(alignment: Alignment.centerRight, child: Text('Form: 3-C', style: serifStyle.copyWith(fontWeight: FontWeight.bold))),
                    const SizedBox(height: 16),

                    // 10) Fingerprint
                    _buildYesNo(
                      '10) Whether finger print taken or not? :-',
                      _fingerprintTaken,
                      (v) => setState(() => _fingerprintTaken = v ?? false),
                      serifStyle,
                    ),
                    const SizedBox(height: 16),

                    // 11) Socio-economic profile
                    BilingualSectionHeader(
                      label: '11) Socio-economic profile of the accused showing.',
                      marathiLabel: 'आरोपीचे सामाजिक-आर्थिक प्रोफाइल',
                      serifStyle: serifStyle,
                      marathiLabelStyle: marathiLabelStyle,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('(a) Living Status: -', style: serifStyle.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildCheckbox('Living alone', _livingAlone, (v) => setState(() => _livingAlone = v ?? false), serifStyle),
                              _buildCheckbox('Living with Family', _livingWithFamily, (v) => setState(() => _livingWithFamily = v ?? false), serifStyle),
                              _buildCheckbox('with Associate', _livingWithAssociate, (v) => setState(() => _livingWithAssociate = v ?? false), serifStyle),
                              _buildCheckbox('in Pucca House', _livingPucca, (v) => setState(() => _livingPucca = v ?? false), serifStyle),
                              _buildCheckbox('Hotel', _livingHotel, (v) => setState(() => _livingHotel = v ?? false), serifStyle),
                              _buildCheckbox('Hostel', _livingHostel, (v) => setState(() => _livingHostel = v ?? false), serifStyle),
                              _buildCheckbox('Kachcha House', _livingKachcha, (v) => setState(() => _livingKachcha = v ?? false), serifStyle),
                              _buildCheckbox('Thatched House', _livingThatched, (v) => setState(() => _livingThatched = v ?? false), serifStyle),
                              _buildCheckbox('Slum', _livingSlum, (v) => setState(() => _livingSlum = v ?? false), serifStyle),
                              _buildCheckbox('Homeless', _livingHomeless, (v) => setState(() => _livingHomeless = v ?? false), serifStyle),
                              _buildCheckbox('Harbourer', _livingHarbourer, (v) => setState(() => _livingHarbourer = v ?? false), serifStyle),
                            ],
                          ),
                          const SizedBox(height: 16),
                          BilingualFieldRow(fields: [
                            BilingualField(label: '(b) Educational qualification(s): ', marathiLabel: 'शैक्षणिक पात्रता', controller: _eduQualCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualField(label: '(c) occupation: ', marathiLabel: 'व्यवसाय', controller: _occupation2Ctrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          ]),
                          const SizedBox(height: 16),
                          Text('(d) Income Group (उत्पन्न गट) :-', style: serifStyle.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildCheckbox('(i) Lower Income (Below Rs. 25000 P.Y.)', _incomeLower, (v) => setState(() => _incomeLower = v ?? false), serifStyle),
                              _buildCheckbox('(ii) Lower Middle Income (From Rs. 25001 to 50000)', _incomeLowerMid, (v) => setState(() => _incomeLowerMid = v ?? false), serifStyle),
                              _buildCheckbox('(iii) Middle Income (From 50001 to 100000)', _incomeMiddle, (v) => setState(() => _incomeMiddle = v ?? false), serifStyle),
                              _buildCheckbox('(iv) Upper Middle Income (From 100000 to 200000)', _incomeUpperMid, (v) => setState(() => _incomeUpperMid = v ?? false), serifStyle),
                              _buildCheckbox('(v) Upper Middle Income (Rs. 200000 to 300000)', _incomeUpperMid2, (v) => setState(() => _incomeUpperMid2 = v ?? false), serifStyle),
                              _buildCheckbox('(vi) Upper Income (above 300000)', _incomeUpper, (v) => setState(() => _incomeUpper = v ?? false), serifStyle),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 12) Police records
                    BilingualSectionHeader(
                      label: '12) Whether the accused person as per the observations and known police records:',
                      marathiLabel: '१२. निरीक्षणावरून व पोलीसां जवळील माहितीनुसार आरोपी',
                      serifStyle: serifStyle,
                      marathiLabelStyle: marathiLabelStyle,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        children: [
                          _buildYesNo('(a) Is dangerous ? (धोकादायक आहे किंवा कसे?)', _isDangerous, (v) => setState(() => _isDangerous = v ?? false), serifStyle),
                          _buildYesNo('(b) Previously escaped any bail ?', _prevEscaped, (v) => setState(() => _prevEscaped = v ?? false), serifStyle),
                          _buildYesNo('(c) Is generally armed?', _generallyArmed, (v) => setState(() => _generallyArmed = v ?? false), serifStyle),
                          _buildYesNo('(d) Operates with accomplices?', _operatesWithAccomplices, (v) => setState(() => _operatesWithAccomplices = v ?? false), serifStyle),
                          _buildYesNo('(e) Has past criminal records ?', _pastCriminal, (v) => setState(() => _pastCriminal = v ?? false), serifStyle),
                          _buildYesNo('(f) Is recidivism?', _isRecidivism, (v) => setState(() => _isRecidivism = v ?? false), serifStyle),
                          _buildYesNo('(g) Is likely to escape bail ?', _likelyToEscape, (v) => setState(() => _likelyToEscape = v ?? false), serifStyle),
                          _buildYesNo('(h) Is released on bail. Likely to commit crime or threaten victims/witnesses.', _releasedOnBail, (v) => setState(() => _releasedOnBail = v ?? false), serifStyle),
                          _buildYesNo('(i) Is wanted in any other case?', _wantedMany, (v) => setState(() => _wantedMany = v ?? false), serifStyle),
                          const SizedBox(height: 8),
                          BilingualWideField(
                            label: '(If yes give case ref. Sec.): ',
                            marathiLabel: 'जर होय असेल तर त्या प्रकरणाचा संदर्भ व कलमे',
                            controller: _caseRefSecCtrl,
                            serifStyle: serifStyle,
                            marathiLabelStyle: marathiLabelStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 13) Panchas
                    BilingualSectionHeader(label: '13) Panch names / signatures', marathiLabel: 'पंचाची नांवे / सह्या', serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BilingualWideField(label: 'Panch (1) :- ', marathiLabel: 'पंच १', controller: _panch1NameCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                              Text('Name and Address of witnesses/Panchas (At least one witness necessary)', style: serifStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BilingualWideField(label: 'Panch Signature (1) :- ', marathiLabel: 'पंचाची सही १', controller: _panch1SigCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                              Text('Signature', style: serifStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: BilingualWideField(label: 'Panch (2) :- ', marathiLabel: 'पंच २', controller: _panch2NameCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle)),
                        const SizedBox(width: 24),
                        Expanded(child: BilingualWideField(label: 'Panch Signature (2) :- ', marathiLabel: 'पंचाची सही २', controller: _panch2SigCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 14) Signatures
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('14) Signature and Thumb impression of Arrested person', style: serifStyle.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              BilingualWideField(label: 'Signature :- ', marathiLabel: 'सही', controller: _arrestedPersonSigCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(FormIoTerminology.englishSignatureHeader, style: serifStyle.copyWith(fontWeight: FontWeight.bold)),
                              Text(FormIoTerminology.signatureHeader, style: marathiLabelStyle),
                              const SizedBox(height: 12),
                              BilingualField(label: 'Signature / सही :- ', marathiLabel: FormIoTerminology.signature, controller: _ioSigCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                              BilingualField(label: 'Name: ', marathiLabel: FormIoTerminology.name, controller: _finalNameCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                              BilingualFieldRow(fields: [
                                BilingualField(label: 'Rank: ', marathiLabel: FormIoTerminology.rank, controller: _finalRankCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                                BilingualField(label: 'No: ', marathiLabel: FormIoTerminology.badgeNo, controller: _finalNoCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 15) Place / Date
                    BilingualFieldRow(fields: [
                      BilingualField(label: '15) Place: ', marathiLabel: 'ठिकाण', controller: _finalPlaceCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                      BilingualField(label: 'Date: ..../..../20.... ', marathiLabel: 'दिनांक', controller: _finalDateCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    ]),
                    const SizedBox(height: 48),
          ],
        ),
      ],
    );
  }
}
