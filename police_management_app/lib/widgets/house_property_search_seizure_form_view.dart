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

class HousePropertySearchSeizureFormView extends StatefulWidget {
  final bool readOnly;
  final Map<String, dynamic>? existingRecord;
  final String? formSection;
  final String? pageRange;

  const HousePropertySearchSeizureFormView({
    super.key,
    this.readOnly = false,
    this.existingRecord,
    this.formSection,
    this.pageRange,
  });

  @override
  State<HousePropertySearchSeizureFormView> createState() =>
      HousePropertySearchSeizureFormViewState();
}

class HousePropertySearchSeizureFormViewState
    extends State<HousePropertySearchSeizureFormView> {
  static const kSearchForm = 'Search Seizure Form';
  static const kPanchanama = 'Search Seizure Panchanama';
  static const _knownSectionIds = {kSearchForm, kPanchanama};

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
  final _yearCtrl = TextEditingController();
  final _firNoCtrl = TextEditingController();
  final _firYearSuffixCtrl = TextEditingController(
    text: DateTime.now().year.toString().substring(2),
  );
  final _headerDateCtrl = TextEditingController();
  final _actSectionsCtrl = TextEditingController();
  final _naturePropertyCtrl = TextEditingController();
  final _accusedNameAddressCtrl = TextEditingController();
  final _placeSeizedCtrl = TextEditingController();
  final _placeDescriptionCtrl = TextEditingController();
  final _profReceiverCtrl = TextEditingController();
  final _personNameCtrl = TextEditingController();
  final _personFatherCtrl = TextEditingController();
  final _personSexCtrl = TextEditingController();
  final _personAgeCtrl = TextEditingController();
  final _personOccupationCtrl = TextEditingController();
  final _personAddressCtrl = TextEditingController();
  final _personAddressLine2Ctrl = TextEditingController();
  final _perishableDisposalCtrl = TextEditingController();
  final _valuableKeepingCtrl = TextEditingController();
  final _identificationRequiredCtrl = TextEditingController();
  final _propertyDetailsCtrl = TextEditingController();
  final _propertyDetailsAttachCtrl = TextEditingController();
  final _circumstancesCtrl = TextEditingController();

  // Page 3
  final _propertyPackedCtrl = TextEditingController();
  final _seizeDateCtrl = TextEditingController();
  final _seizeTimeFromCtrl = TextEditingController();
  final _seizeTimeToCtrl = TextEditingController();
  final _witness1Line1Ctrl = TextEditingController();
  final _witness1Line2Ctrl = TextEditingController();
  final _witness1Line3Ctrl = TextEditingController();
  final _witness1SigCtrl = TextEditingController();
  final _witness2Line1Ctrl = TextEditingController();
  final _witness2Line2Ctrl = TextEditingController();
  final _witness2Line3Ctrl = TextEditingController();
  final _witness2SigCtrl = TextEditingController();
  final _sealSampleDateCtrl = TextEditingController();
  final _seizedPersonSigCtrl = TextEditingController();
  final _ioNameCtrl = TextEditingController();
  final _ioRankCtrl = TextEditingController();
  final _ioNoCtrl = TextEditingController();
  final _ioPostingCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    _actSectionsCtrl.dispose();
    _naturePropertyCtrl.dispose();
    _accusedNameAddressCtrl.dispose();
    _placeSeizedCtrl.dispose();
    _placeDescriptionCtrl.dispose();
    _profReceiverCtrl.dispose();
    _personNameCtrl.dispose();
    _personFatherCtrl.dispose();
    _personSexCtrl.dispose();
    _personAgeCtrl.dispose();
    _personOccupationCtrl.dispose();
    _personAddressCtrl.dispose();
    _personAddressLine2Ctrl.dispose();
    _perishableDisposalCtrl.dispose();
    _valuableKeepingCtrl.dispose();
    _identificationRequiredCtrl.dispose();
    _propertyDetailsCtrl.dispose();
    _propertyDetailsAttachCtrl.dispose();
    _circumstancesCtrl.dispose();
    _propertyPackedCtrl.dispose();
    _seizeDateCtrl.dispose();
    _seizeTimeFromCtrl.dispose();
    _seizeTimeToCtrl.dispose();
    _witness1Line1Ctrl.dispose();
    _witness1Line2Ctrl.dispose();
    _witness1Line3Ctrl.dispose();
    _witness1SigCtrl.dispose();
    _witness2Line1Ctrl.dispose();
    _witness2Line2Ctrl.dispose();
    _witness2Line3Ctrl.dispose();
    _witness2SigCtrl.dispose();
    _sealSampleDateCtrl.dispose();
    _seizedPersonSigCtrl.dispose();
    _ioNameCtrl.dispose();
    _ioRankCtrl.dispose();
    _ioNoCtrl.dispose();
    _ioPostingCtrl.dispose();
    super.dispose();
  }

  void hydrateFrom(Map<String, dynamic> data) {
    setState(() {
      void set(TextEditingController c, String key) {
        c.text = data[key]?.toString() ?? '';
      }
      set(_distCtrl, 'dist');
      set(_psCtrl, 'ps');
      set(_yearCtrl, 'year');
      set(_firNoCtrl, 'firNo');
      set(_firYearSuffixCtrl, 'firYearSuffix');
      set(_headerDateCtrl, 'headerDate');
      set(_actSectionsCtrl, 'actSections');
      set(_naturePropertyCtrl, 'natureProperty');
      set(_accusedNameAddressCtrl, 'accusedNameAddress');
      set(_placeSeizedCtrl, 'placeSeized');
      set(_placeDescriptionCtrl, 'placeDescription');
      set(_profReceiverCtrl, 'profReceiver');
      set(_personNameCtrl, 'personName');
      set(_personFatherCtrl, 'personFather');
      set(_personSexCtrl, 'personSex');
      set(_personAgeCtrl, 'personAge');
      set(_personOccupationCtrl, 'personOccupation');
      set(_personAddressCtrl, 'personAddress');
      set(_personAddressLine2Ctrl, 'personAddressLine2');
      set(_perishableDisposalCtrl, 'perishableDisposal');
      set(_valuableKeepingCtrl, 'valuableKeeping');
      set(_identificationRequiredCtrl, 'identificationRequired');
      set(_propertyDetailsCtrl, 'propertyDetails');
      set(_propertyDetailsAttachCtrl, 'propertyDetailsAttach');
      set(_circumstancesCtrl, 'circumstances');
      set(_propertyPackedCtrl, 'propertyPacked');
      set(_seizeDateCtrl, 'seizeDate');
      set(_seizeTimeFromCtrl, 'seizeTimeFrom');
      set(_seizeTimeToCtrl, 'seizeTimeTo');
      set(_witness1Line1Ctrl, 'witness1Line1');
      set(_witness1Line2Ctrl, 'witness1Line2');
      set(_witness1Line3Ctrl, 'witness1Line3');
      set(_witness1SigCtrl, 'witness1Sig');
      set(_witness2Line1Ctrl, 'witness2Line1');
      set(_witness2Line2Ctrl, 'witness2Line2');
      set(_witness2Line3Ctrl, 'witness2Line3');
      set(_witness2SigCtrl, 'witness2Sig');
      set(_sealSampleDateCtrl, 'sealSampleDate');
      set(_seizedPersonSigCtrl, 'seizedPersonSig');
      set(_ioNameCtrl, 'ioName');
      set(_ioRankCtrl, 'ioRank');
      set(_ioNoCtrl, 'ioNo');
      set(_ioPostingCtrl, 'ioPosting');
    });
  }

  Map<String, dynamic> collectData() {
    return {
      'dist': _distCtrl.text.trim(),
      'ps': _psCtrl.text.trim(),
      'year': _yearCtrl.text.trim(),
      'firNo': _firNoCtrl.text.trim(),
      'firYearSuffix': _firYearSuffixCtrl.text.trim(),
      'headerDate': _headerDateCtrl.text.trim(),
      'actSections': _actSectionsCtrl.text.trim(),
      'natureProperty': _naturePropertyCtrl.text.trim(),
      'accusedNameAddress': _accusedNameAddressCtrl.text.trim(),
      'placeSeized': _placeSeizedCtrl.text.trim(),
      'placeDescription': _placeDescriptionCtrl.text.trim(),
      'profReceiver': _profReceiverCtrl.text.trim(),
      'personName': _personNameCtrl.text.trim(),
      'personFather': _personFatherCtrl.text.trim(),
      'personSex': _personSexCtrl.text.trim(),
      'personAge': _personAgeCtrl.text.trim(),
      'personOccupation': _personOccupationCtrl.text.trim(),
      'personAddress': _personAddressCtrl.text.trim(),
      'personAddressLine2': _personAddressLine2Ctrl.text.trim(),
      'perishableDisposal': _perishableDisposalCtrl.text.trim(),
      'valuableKeeping': _valuableKeepingCtrl.text.trim(),
      'identificationRequired': _identificationRequiredCtrl.text.trim(),
      'propertyDetails': _propertyDetailsCtrl.text.trim(),
      'propertyDetailsAttach': _propertyDetailsAttachCtrl.text.trim(),
      'circumstances': _circumstancesCtrl.text.trim(),
      'propertyPacked': _propertyPackedCtrl.text.trim(),
      'seizeDate': _seizeDateCtrl.text.trim(),
      'seizeTimeFrom': _seizeTimeFromCtrl.text.trim(),
      'seizeTimeTo': _seizeTimeToCtrl.text.trim(),
      'witness1Line1': _witness1Line1Ctrl.text.trim(),
      'witness1Line2': _witness1Line2Ctrl.text.trim(),
      'witness1Line3': _witness1Line3Ctrl.text.trim(),
      'witness1Sig': _witness1SigCtrl.text.trim(),
      'witness2Line1': _witness2Line1Ctrl.text.trim(),
      'witness2Line2': _witness2Line2Ctrl.text.trim(),
      'witness2Line3': _witness2Line3Ctrl.text.trim(),
      'witness2Sig': _witness2SigCtrl.text.trim(),
      'sealSampleDate': _sealSampleDateCtrl.text.trim(),
      'seizedPersonSig': _seizedPersonSigCtrl.text.trim(),
      'ioName': _ioNameCtrl.text.trim(),
      'ioRank': _ioRankCtrl.text.trim(),
      'ioNo': _ioNoCtrl.text.trim(),
      'ioPosting': _ioPostingCtrl.text.trim(),
      'formSection': widget.formSection ?? '',
      'pageRange': widget.pageRange ?? '',
    };
  }

  Widget _witnessBlock({
    required String number,
    required TextEditingController l1,
    required TextEditingController l2,
    required TextEditingController l3,
    required TextEditingController sig,
    required TextStyle serifStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              BilingualNumberedMethodField(number: number, controller: l1, serifStyle: serifStyle),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: BilingualSimpleUnderlineInput(controller: l2, serifStyle: serifStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: BilingualSimpleUnderlineInput(controller: l3, serifStyle: serifStyle),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BilingualNumberedMethodField(number: number, controller: sig, serifStyle: serifStyle),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle serifStyle = FormTypography.serifStyle();
    final TextStyle marathiLabelStyle = FormTypography.marathiLabelStyle();

    return FormViewScaffold(
      readOnly: widget.readOnly,
      children: [
        if (_shows(kSearchForm)) ...[
              FormPaperPage(
                formLabel: widget.pageRange ?? 'Page 5',
                children: [
                  SizedBox(
                    height: 280,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'HOUSE/PROPERTY SEARCH',
                            style: serifStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '& SEIZURI FORM',
                            style: serifStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'घरझडती पंचनामा/ मालमत्ता शोध व जप्तीचा पंचनामा',
                            style: GoogleFonts.notoSansDevanagari(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  FormMrwFooter(serifStyle: serifStyle),
                ],
              ),
              const SizedBox(height: 24),

              // PAGE 2 — sections 1–10
              FormPaperPage(
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'HOUSE/PROPERTY SEARCH & SEIZURI FORM',
                          style: serifStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'घरझडती पंचनामा/ मालमत्ता शोध व जप्तीचा पंचनामा',
                          style: marathiLabelStyle.copyWith(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '(Search/Production/Recovery U/s 185 B.N.S.S. 2023)',
                          style: serifStyle.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '(कलम १८५ भारतीय नागरी संरक्षण अधिनियम २०२३ अन्वये झडती/हजर करणे/परत मिळविणे)',
                          style: marathiLabelStyle.copyWith(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ResponsiveFieldRow(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: BilingualField(label: '1.Dist : ', marathiLabel: 'जिल्हा', controller: _distCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle)),
                      const SizedBox(width: 8),
                      Expanded(child: BilingualField(label: 'P.S: ', marathiLabel: 'पोलीस स्टेशन', controller: _psCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle)),
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
                  BilingualWideField(label: '2. Act and Section : ', marathiLabel: 'अधिनियम व कलमे', controller: _actSectionsCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 12),
                  BilingualMultilineField(
                    label: '3. Nature of property seized/Recover: Stolen/Unclaimed/Unlawful procession/Involved/Intestate.',
                    marathiLabel: 'जप्त केलेल्या / मिळालेल्या मालमत्तेचे स्वरूप',
                    controller: _naturePropertyCtrl,
                    minLines: 2,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualWideField(label: '4. Name And Address of accused : ', marathiLabel: 'आरोपीचे नांव व पत्ता', controller: _accusedNameAddressCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  BilingualWideField(label: '(a) Place from where seized/recovered :- ', marathiLabel: 'जेथुन जप्त केली / परत मिळवली ती जागा', controller: _placeSeizedCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  const SizedBox(height: 8),
                  BilingualMultilineField(
                    label: '(b) Description of the place of seizure/recovery : ',
                    marathiLabel: 'जप्तीच्या परत मिळवल्याच्या जागेचे वर्णन /चतु सिमा',
                    controller: _placeDescriptionCtrl,
                    minLines: 2,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualSectionHeader(
                    label: '5. Person form whom seized :-',
                    marathiLabel: 'कोणाकडून जप्त केली',
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 8),
                  BilingualField(
                    label: 'Professional Receiver of Stolen Property: - Yes/No.',
                    marathiLabel: 'चोरीचा माल घेणारा धंदेवाईक :- होय/ नाही',
                    controller: _profReceiverCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 8),
                  BilingualFieldRow(fields: [
                    BilingualField(label: 'Name : - ', marathiLabel: 'नांव', controller: _personNameCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: 'Father\'s/Husband\'s Name : ', marathiLabel: 'वडील/ पतीचे नांव', controller: _personFatherCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: 'Sex- ', marathiLabel: 'लिंग', controller: _personSexCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  ]),
                  const SizedBox(height: 8),
                  BilingualFieldRow(fields: [
                    BilingualField(label: 'Age : ', marathiLabel: 'वय', controller: _personAgeCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: 'Occupation : ', marathiLabel: 'व्यवसाय', controller: _personOccupationCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: 'Address : ', marathiLabel: 'पत्ता', controller: _personAddressCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  ]),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: BilingualSimpleUnderlineInput(controller: _personAddressLine2Ctrl, serifStyle: serifStyle),
                  ),
                  const SizedBox(height: 12),
                  BilingualMultilineField(
                    label: '6. Action taken/recommended for disposal of perishable property: -',
                    marathiLabel: 'नाशवंत मालमत्तेच्या विल्हेवाटीसाठी केलेली शिफारस / केलेली कार्यवाही',
                    controller: _perishableDisposalCtrl,
                    minLines: 2,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualMultilineField(
                    label: '7. Action taken/recommended for keeping of valuable property :-',
                    marathiLabel: 'मौल्यवान मालमत्ता ठेवण्यासाठी केलेली शिफारस / केलेली कार्यवाही',
                    controller: _valuableKeepingCtrl,
                    minLines: 2,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualField(
                    label: '8. Identification repuired :- Yes / No.',
                    marathiLabel: 'ओळख पटवावी लागली काय :- होय/ नाही',
                    controller: _identificationRequiredCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualWideField(
                    label: '9. Details of property seized/recovered (Use prescribed form (8) and attach): ',
                    marathiLabel: 'जप्त केलेल्या / परत मिळालेल्या मालाचे वर्णन',
                    controller: _propertyDetailsCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 8),
                  BilingualWideField(
                    label: '(1) (Attach separate sheet, if required) :- ',
                    marathiLabel: 'आवश्यक असल्यास स्वतंत्र कागद जोडा',
                    controller: _propertyDetailsAttachCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  BilingualMultilineField(
                    label: '10. Circumstances/Grounds for seizures :-',
                    marathiLabel: 'जप्तीची परिस्थिती/ कारणे',
                    controller: _circumstancesCtrl,
                    minLines: 3,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 12),
                  FormMrwFooter(serifStyle: serifStyle),
                ],
              ),
        ],
        if (_shows(kSearchForm) && (_shows(kPanchanama) || _showAll))
              const SizedBox(height: 24),
        if (_shows(kPanchanama))
              FormPaperPage(
                formLabel: widget.pageRange ?? 'Page 29',
                children: [
                  Text(
                    '11) The above mentioned properties were seized in accordance with the provisions of law in the presence of the below said witnesses** and a copy of the seizure memo was given to the person/occupant of the place from whom seized.',
                    style: serifStyle.copyWith(fontSize: 12),
                  ),
                  Text(
                    'वरील मालमत्ता खालील साक्षीदारांच्या समक्ष कायद्याच्या तरतुदीनुसार जप्त केली व ज्यांच्याकडून जप्त केली त्यांना/ त्या ठिकाणी राहणाऱ्यास जप्तीच्या पंचनाम्याची प्रत देण्यात आली.',
                    style: marathiLabelStyle.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '12) The following properties were packed and/of sealed and the signature of the below said witnesses obtained thereon or on the body of the property.',
                    style: serifStyle.copyWith(fontSize: 12),
                  ),
                  Text(
                    'खालील मालमत्ता पोत्यात बंद/शिक्का मारून खालील साक्षीदारांची सही घेण्यात आली.',
                    style: marathiLabelStyle.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: Colors.black87),
                    columnWidths: const {
                      0: FixedColumnWidth(60),
                      1: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text('Sr.No.\nअनु.क्र', style: serifStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text('Property/ मालमत्ता', style: serifStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text('1', style: serifStyle.copyWith(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: BilingualDynamicLinedTextField(
                              controller: _propertyPackedCtrl,
                              minLines: 8,
                              serifStyle: serifStyle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BilingualFieldRow(fields: [
                    BilingualField(label: '13) Property seized : (a) Date : ', marathiLabel: 'जप्त केलेली मालमत्ता दिनांक', controller: _seizeDateCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: '(b) Time : ', marathiLabel: 'वेळ', controller: _seizeTimeFromCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                    BilingualField(label: 'To : ', marathiLabel: 'ते', controller: _seizeTimeToCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                  ]),
                  const SizedBox(height: 12),
                  BilingualSectionHeader(
                    label: '14) witness — / Signature:',
                    marathiLabel: 'साक्षीदारांचे नांव व पत्ता / सह्या',
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiLabelStyle,
                  ),
                  const SizedBox(height: 8),
                  _witnessBlock(number: '1', l1: _witness1Line1Ctrl, l2: _witness1Line2Ctrl, l3: _witness1Line3Ctrl, sig: _witness1SigCtrl, serifStyle: serifStyle),
                  const SizedBox(height: 12),
                  _witnessBlock(number: '2', l1: _witness2Line1Ctrl, l2: _witness2Line2Ctrl, l3: _witness2Line3Ctrl, sig: _witness2SigCtrl, serifStyle: serifStyle),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BilingualField(label: '15) शिक्याचा नमुना :- Date : ', marathiLabel: 'दिनांक', controller: _sealSampleDateCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            const SizedBox(height: 12),
                            BilingualField(
                              label: '16) Signature of person from whom seized : ',
                              marathiLabel: 'ज्यांच्याकडून माल जप्त केला त्याची सही',
                              controller: _seizedPersonSigCtrl,
                              serifStyle: serifStyle,
                              marathiLabelStyle: marathiLabelStyle,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BilingualSectionHeader(
                              label: FormIoTerminology.englishSignatureHeader,
                              marathiLabel: FormIoTerminology.signatureHeader,
                              serifStyle: serifStyle,
                              marathiLabelStyle: marathiLabelStyle,
                            ),
                            const SizedBox(height: 8),
                            BilingualField(label: 'Name: ', marathiLabel: FormIoTerminology.name, controller: _ioNameCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            BilingualFieldRow(fields: [
                              BilingualField(label: 'Rank: ', marathiLabel: FormIoTerminology.rank, controller: _ioRankCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                              BilingualField(label: 'Number if any: ', marathiLabel: 'बक्कल नंबर', controller: _ioNoCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                            ]),
                            BilingualWideField(label: 'Posting and Address: ', marathiLabel: 'नेमणूक व पत्ता', controller: _ioPostingCtrl, serifStyle: serifStyle, marathiLabelStyle: marathiLabelStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '** In case the property is seized from such a place that no receipt is required to be given to anybody this portion of the sentence should be struck off.',
                    style: serifStyle.copyWith(fontSize: 9, fontStyle: FontStyle.italic),
                  ),
                  Text(
                    'जर मालमत्ता अशा ठिकाणीून जप्त केली की कोणालाही पावती देण्याची आवश्यकता नसेल तर वाक्याचा हा भाग काढून टाकावा.',
                    style: marathiLabelStyle.copyWith(fontSize: 9),
                  ),
                  const SizedBox(height: 8),
                  FormMrwFooter(serifStyle: serifStyle),
                ],
              ),
            ],
    );
  }
}
