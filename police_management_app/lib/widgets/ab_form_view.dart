import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bilingual_field.dart';
import 'form_paper_page.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';
import 'responsive_field_row.dart';

class AbFormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const AbFormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<AbFormView> createState() => AbFormViewState();
}

class AbFormViewState extends State<AbFormView> {
  // ── Form A ──
  final _serialNoCtrl = TextEditingController();
  final _dispensaryCtrl = TextEditingController();
  final _personNameCtrl = TextEditingController();
  final _broughtByCtrl = TextEditingController();
  final _broughtDateCtrl = TextEditingController();
  final _broughtTimeCtrl = TextEditingController();
  final _broughtAmPmCtrl = TextEditingController();
  final _examinedDateCtrl = TextEditingController();
  final _examinedTimeCtrl = TextEditingController();
  final _examinedAmPmCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _breathCtrl = TextEditingController();
  final _speechCtrl = TextEditingController();
  final _gaitCtrl = TextEditingController();
  final _pupilsCtrl = TextEditingController();
  final _additionalRemarksCtrl = TextEditingController();
  final _consumedCtrl = TextEditingController();
  final _intoxicantTypeCtrl = TextEditingController();
  final _underInfluenceCtrl = TextEditingController();
  final _bloodCollectedCtrl = TextEditingController();
  final _formADatedCtrl = TextEditingController();
  final _formATimeCtrl = TextEditingController();
  final _moSignatureCtrl = TextEditingController();
  final _moDesignationCtrl = TextEditingController();
  final _examinedSigCtrl = TextEditingController();
  final _idMarksCtrl = TextEditingController();

  // ── Form B ──
  final _formBNoCtrl = TextEditingController();
  final _fromPractitionerCtrl = TextEditingController();
  final _toTestingOfficerCtrl = TextEditingController();
  final _formBDateCtrl = TextEditingController();
  final _messengerNameCtrl = TextEditingController();
  final _phialSerialCtrl = TextEditingController();
  final _bloodAmountCtrl = TextEditingController();
  final _collectionDateCtrl = TextEditingController();
  final _collectionTimeCtrl = TextEditingController();
  final _collectionAmPmCtrl = TextEditingController();
  final _subjectNameCtrl = TextEditingController();
  final _subjectAddressCtrl = TextEditingController();
  final _producedByCtrl = TextEditingController();
  final _formBSignatureCtrl = TextEditingController();
  final _sealFacsimileCtrl = TextEditingController();

  bool get _showFormA {
    final s = widget.formSection?.toLowerCase() ?? '';
    if (s.isEmpty) return true;
    return s.contains('main') || s.contains('form a');
  }

  bool get _showFormB {
    final s = widget.formSection?.toLowerCase() ?? '';
    if (s.isEmpty) return true;
    return s.contains('continuation') || s.contains('form b');
  }

  @override
  void dispose() {
    for (final c in [
      _serialNoCtrl,
      _dispensaryCtrl,
      _personNameCtrl,
      _broughtByCtrl,
      _broughtDateCtrl,
      _broughtTimeCtrl,
      _broughtAmPmCtrl,
      _examinedDateCtrl,
      _examinedTimeCtrl,
      _examinedAmPmCtrl,
      _ageCtrl,
      _weightCtrl,
      _breathCtrl,
      _speechCtrl,
      _gaitCtrl,
      _pupilsCtrl,
      _additionalRemarksCtrl,
      _consumedCtrl,
      _intoxicantTypeCtrl,
      _underInfluenceCtrl,
      _bloodCollectedCtrl,
      _formADatedCtrl,
      _formATimeCtrl,
      _moSignatureCtrl,
      _moDesignationCtrl,
      _examinedSigCtrl,
      _idMarksCtrl,
      _formBNoCtrl,
      _fromPractitionerCtrl,
      _toTestingOfficerCtrl,
      _formBDateCtrl,
      _messengerNameCtrl,
      _phialSerialCtrl,
      _bloodAmountCtrl,
      _collectionDateCtrl,
      _collectionTimeCtrl,
      _collectionAmPmCtrl,
      _subjectNameCtrl,
      _subjectAddressCtrl,
      _producedByCtrl,
      _formBSignatureCtrl,
      _sealFacsimileCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> collectData() {
    return {
      'formSection': widget.formSection ?? '',
      'pageRange': widget.pageRange ?? '',
      'serialNo': _serialNoCtrl.text.trim(),
      'dispensary': _dispensaryCtrl.text.trim(),
      'personName': _personNameCtrl.text.trim(),
      'broughtBy': _broughtByCtrl.text.trim(),
      'broughtDate': _broughtDateCtrl.text.trim(),
      'broughtTime': _broughtTimeCtrl.text.trim(),
      'broughtAmPm': _broughtAmPmCtrl.text.trim(),
      'examinedDate': _examinedDateCtrl.text.trim(),
      'examinedTime': _examinedTimeCtrl.text.trim(),
      'examinedAmPm': _examinedAmPmCtrl.text.trim(),
      'age': _ageCtrl.text.trim(),
      'weight': _weightCtrl.text.trim(),
      'breath': _breathCtrl.text.trim(),
      'speech': _speechCtrl.text.trim(),
      'gait': _gaitCtrl.text.trim(),
      'pupils': _pupilsCtrl.text.trim(),
      'additionalRemarks': _additionalRemarksCtrl.text.trim(),
      'consumed': _consumedCtrl.text.trim(),
      'intoxicantType': _intoxicantTypeCtrl.text.trim(),
      'underInfluence': _underInfluenceCtrl.text.trim(),
      'bloodCollected': _bloodCollectedCtrl.text.trim(),
      'formADated': _formADatedCtrl.text.trim(),
      'formATime': _formATimeCtrl.text.trim(),
      'moSignature': _moSignatureCtrl.text.trim(),
      'moDesignation': _moDesignationCtrl.text.trim(),
      'examinedSignature': _examinedSigCtrl.text.trim(),
      'identificationMarks': _idMarksCtrl.text.trim(),
      'formBNo': _formBNoCtrl.text.trim(),
      'fromPractitioner': _fromPractitionerCtrl.text.trim(),
      'toTestingOfficer': _toTestingOfficerCtrl.text.trim(),
      'formBDate': _formBDateCtrl.text.trim(),
      'messengerName': _messengerNameCtrl.text.trim(),
      'phialSerial': _phialSerialCtrl.text.trim(),
      'bloodAmountCc': _bloodAmountCtrl.text.trim(),
      'collectionDate': _collectionDateCtrl.text.trim(),
      'collectionTime': _collectionTimeCtrl.text.trim(),
      'collectionAmPm': _collectionAmPmCtrl.text.trim(),
      'subjectName': _subjectNameCtrl.text.trim(),
      'subjectAddress': _subjectAddressCtrl.text.trim(),
      'producedBy': _producedByCtrl.text.trim(),
      'formBSignature': _formBSignatureCtrl.text.trim(),
      'sealFacsimile': _sealFacsimileCtrl.text.trim(),
    };
  }

  void hydrateFrom(Map<String, dynamic> data) {
    setState(() {
      _serialNoCtrl.text = data['serialNo']?.toString() ?? '';
      _dispensaryCtrl.text = data['dispensary']?.toString() ?? '';
      _personNameCtrl.text = data['personName']?.toString() ?? '';
      _broughtByCtrl.text = data['broughtBy']?.toString() ?? '';
      _broughtDateCtrl.text = data['broughtDate']?.toString() ?? '';
      _broughtTimeCtrl.text = data['broughtTime']?.toString() ?? '';
      _broughtAmPmCtrl.text = data['broughtAmPm']?.toString() ?? '';
      _examinedDateCtrl.text = data['examinedDate']?.toString() ?? '';
      _examinedTimeCtrl.text = data['examinedTime']?.toString() ?? '';
      _examinedAmPmCtrl.text = data['examinedAmPm']?.toString() ?? '';
      _ageCtrl.text = data['age']?.toString() ?? '';
      _weightCtrl.text = data['weight']?.toString() ?? '';
      _breathCtrl.text = data['breath']?.toString() ?? '';
      _speechCtrl.text = data['speech']?.toString() ?? '';
      _gaitCtrl.text = data['gait']?.toString() ?? '';
      _pupilsCtrl.text = data['pupils']?.toString() ?? '';
      _additionalRemarksCtrl.text = data['additionalRemarks']?.toString() ?? '';
      _consumedCtrl.text = data['consumed']?.toString() ?? '';
      _intoxicantTypeCtrl.text = data['intoxicantType']?.toString() ?? '';
      _underInfluenceCtrl.text = data['underInfluence']?.toString() ?? '';
      _bloodCollectedCtrl.text = data['bloodCollected']?.toString() ?? '';
      _formADatedCtrl.text = data['formADated']?.toString() ?? '';
      _formATimeCtrl.text = data['formATime']?.toString() ?? '';
      _moSignatureCtrl.text = data['moSignature']?.toString() ?? '';
      _moDesignationCtrl.text = data['moDesignation']?.toString() ?? '';
      _examinedSigCtrl.text = data['examinedSignature']?.toString() ?? '';
      _idMarksCtrl.text = data['identificationMarks']?.toString() ?? '';
      _formBNoCtrl.text = data['formBNo']?.toString() ?? '';
      _fromPractitionerCtrl.text = data['fromPractitioner']?.toString() ?? '';
      _toTestingOfficerCtrl.text = data['toTestingOfficer']?.toString() ?? '';
      _formBDateCtrl.text = data['formBDate']?.toString() ?? '';
      _messengerNameCtrl.text = data['messengerName']?.toString() ?? '';
      _phialSerialCtrl.text = data['phialSerial']?.toString() ?? '';
      _bloodAmountCtrl.text = data['bloodAmountCc']?.toString() ?? '';
      _collectionDateCtrl.text = data['collectionDate']?.toString() ?? '';
      _collectionTimeCtrl.text = data['collectionTime']?.toString() ?? '';
      _collectionAmPmCtrl.text = data['collectionAmPm']?.toString() ?? '';
      _subjectNameCtrl.text = data['subjectName']?.toString() ?? '';
      _subjectAddressCtrl.text = data['subjectAddress']?.toString() ?? '';
      _producedByCtrl.text = data['producedBy']?.toString() ?? '';
      _formBSignatureCtrl.text = data['formBSignature']?.toString() ?? '';
      _sealFacsimileCtrl.text = data['sealFacsimile']?.toString() ?? '';
    });
  }

  Widget _marathiCaption(String text, TextStyle marathi) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 6),
      child: SizedBox(
        width: double.infinity,
        child: Text(text, style: marathi.copyWith(fontSize: 10)),
      ),
    );
  }

  Widget _bilingualCaption(String en, String mr, TextStyle serif, TextStyle marathi) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(en, style: serif.copyWith(fontSize: 11)),
          _marathiCaption(mr, marathi),
        ],
      ),
    );
  }

  Widget _inlineField({
    required TextStyle style,
    required TextEditingController controller,
    double width = 120,
  }) {
    return SizedBox(
      width: width,
      child: BilingualSimpleUnderlineInput(
        controller: controller,
        serifStyle: style,
      ),
    );
  }

  Widget _examRow(
    String labelEn,
    String labelMr,
    TextEditingController ctrl,
    TextStyle serif,
    TextStyle marathi, {
    String suffixEn = '',
    String suffixMr = '',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(labelEn, style: serif),
                  Text(labelMr, style: marathi.copyWith(fontSize: 9)),
                ],
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 140,
                child: BilingualSimpleUnderlineInput(
                  controller: ctrl,
                  serifStyle: serif,
                ),
              ),
              if (suffixEn.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(suffixEn, style: serif.copyWith(fontSize: 10)),
                ),
              ],
            ],
          ),
          if (suffixMr.isNotEmpty) _marathiCaption(suffixMr, marathi),
        ],
      ),
    );
  }

  Widget _formAPage(TextStyle serifStyle, TextStyle marathiStyle) {
    return FormPaperPage(
      formLabel: 'Form A / नमुना अ',
      children: [
        Center(
          child: Column(
            children: [
              Text(
                'Form A',
                style: serifStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              Text(
                'नमुना "अ"',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 4),
              Text('(See Rule No 3)', style: serifStyle.copyWith(fontSize: 11)),
              Text(
                '(नियम क्र. ३ पहा)',
                style: marathiStyle.copyWith(fontSize: 10),
              ),
              const SizedBox(height: 8),
              Text(
                'Certificate by registered medical practitioner showing where\n'
                'person examined by him has or has not consumed an intoxicant.',
                textAlign: TextAlign.center,
                style: serifStyle.copyWith(fontSize: 11, height: 1.35),
              ),
              Text(
                'नोंदणीकृत वैद्यकीय अधिकारी यांचे प्रमाणपत्र — त्याने तपासलेल्या\n'
                'व्यक्तीने मद्य / नशा सेवन केले आहे की नाही.',
                textAlign: TextAlign.center,
                style: marathiStyle.copyWith(fontSize: 10, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BilingualField(
          label: 'Serial No :',
          marathiLabel: 'अ.क्र.',
          controller: _serialNoCtrl,
          serifStyle: serifStyle,
          marathiLabelStyle: marathiStyle,
        ),
        const SizedBox(height: 12),
        _bilingualCaption(
          '(Name and location of the Dispensary of Hospital)',
          '(दवाखाना / औषधालयाचे नाव व ठिकाण)',
          serifStyle,
          marathiStyle,
        ),
        BilingualSimpleUnderlineInput(
          controller: _dispensaryCtrl,
          serifStyle: serifStyle,
        ),
        const SizedBox(height: 16),
        _bilingualCaption(
          'Certified that Shri/Smt/Kumari',
          'प्रमाणित करतो की श्री / श्रीमती / कुमारी',
          serifStyle,
          marathiStyle,
        ),
        BilingualSimpleUnderlineInput(controller: _personNameCtrl, serifStyle: serifStyle),
        _bilingualCaption(
          'was brought to this hospital / dispensary by',
          'या रुग्णालय / औषधालयात आणण्यात आले',
          serifStyle,
          marathiStyle,
        ),
        BilingualSimpleUnderlineInput(controller: _broughtByCtrl, serifStyle: serifStyle),
        _bilingualCaption(
          '(here state name and designation of the officer)',
          '(अधिकाऱ्याचे नाव व पदनाम)',
          serifStyle,
          marathiStyle,
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 4,
          runSpacing: 8,
          children: [
            Text('on', style: serifStyle),
            Text('दिनांक', style: marathiStyle.copyWith(fontSize: 10)),
            _inlineField(style: serifStyle, controller: _broughtDateCtrl, width: 90),
            Text('at', style: serifStyle),
            Text('वेळ', style: marathiStyle.copyWith(fontSize: 10)),
            _inlineField(style: serifStyle, controller: _broughtTimeCtrl, width: 70),
            _inlineField(style: serifStyle, controller: _broughtAmPmCtrl, width: 50),
            Text('(a.m./p.m.)', style: serifStyle.copyWith(fontSize: 10)),
            Text('and was examined by MO on', style: serifStyle),
            Text('वै.अ. ने तपासणी', style: marathiStyle.copyWith(fontSize: 10)),
            _inlineField(style: serifStyle, controller: _examinedDateCtrl, width: 90),
            Text('at', style: serifStyle),
            _inlineField(style: serifStyle, controller: _examinedTimeCtrl, width: 70),
            _inlineField(style: serifStyle, controller: _examinedAmPmCtrl, width: 50),
            Text('a.m./p.m.', style: serifStyle),
          ],
        ),
        const SizedBox(height: 20),
        BilingualSectionHeader(
          label: 'A clinical examination of the above named person disclosed the following :-',
          marathiLabel: 'वर नमूद व्यक्तीच्या वैद्यकीय तपासणीत खालील गोष्टी आढळल्या :-',
          serifStyle: serifStyle.copyWith(fontWeight: FontWeight.w600),
          marathiLabelStyle: marathiStyle,
        ),
        const SizedBox(height: 12),
        _examRow('Age', 'वय', _ageCtrl, serifStyle, marathiStyle),
        _examRow('Weight', 'वजन', _weightCtrl, serifStyle, marathiStyle),
        _examRow(
          'Breath',
          'श्वास',
          _breathCtrl,
          serifStyle,
          marathiStyle,
          suffixEn: ' smelling / Not smelling of Alcohol / Opium / Charas / Ganja / Bhang',
          suffixMr: ' दुर्गंध / दुर्गंध नाही — मद्य / अफीम / चरस / गांजा / भांग',
        ),
        _examRow(
          'Speech',
          'बोलणे',
          _speechCtrl,
          serifStyle,
          marathiStyle,
          suffixEn: ' Incoherent / Normal',
          suffixMr: ' अस्पष्ट / सामान्य',
        ),
        _examRow(
          'Gait',
          'चाल',
          _gaitCtrl,
          serifStyle,
          marathiStyle,
          suffixEn: ' unsteady / Steady',
          suffixMr: ' अस्थिर / स्थिर',
        ),
        _examRow(
          'Pupils',
          'डोळ्यांची बाभळ',
          _pupilsCtrl,
          serifStyle,
          marathiStyle,
          suffixEn: ' Dilated / Normal',
          suffixMr: ' विस्तार / सामान्य',
        ),
        const SizedBox(height: 8),
        BilingualMultilineField(
          label: 'Additional remarks any',
          marathiLabel: 'अतिरिक्त शेरा (असल्यास)',
          controller: _additionalRemarksCtrl,
          minLines: 2,
          serifStyle: serifStyle,
          marathiLabelStyle: marathiStyle,
        ),
        const SizedBox(height: 12),
        _bilingualCaption(
          'I find that the above named person has consumed / has not consumed',
          'वर नमूद व्यक्तीने सेवन केले / केले नाही',
          serifStyle,
          marathiStyle,
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 4,
          runSpacing: 8,
          children: [
            _inlineField(style: serifStyle, controller: _consumedCtrl, width: 130),
            _inlineField(style: serifStyle, controller: _intoxicantTypeCtrl, width: 160),
            Text('Alcohol / Opium / Charas / Ganja / Bhang / any toxicant.', style: serifStyle),
          ],
        ),
        _marathiCaption('मद्य / अफीम / चरस / गांजा / भांग / इतर विषारी पदार्थ', marathiStyle),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 4,
          children: [
            Text('I also find that he is / is not under the Influence of alcohol.', style: serifStyle),
            _inlineField(style: serifStyle, controller: _underInfluenceCtrl, width: 60),
          ],
        ),
        _marathiCaption('मद्याच्या प्रभावाखाली आहे / नाही', marathiStyle),
        const SizedBox(height: 12),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 4,
          children: [
            Text('(N.B.', style: serifStyle),
            _inlineField(style: serifStyle, controller: _bloodCollectedCtrl, width: 80),
            Text(
              'Blood from the body of the above named was / was not collected by MO for Chemical examination )',
              style: serifStyle,
            ),
          ],
        ),
        _marathiCaption(
          'सूचना — वर नमूद व्यक्तीचे रक्त वै.अ. ने रासायनिक तपासणीसाठी गोळा केले / केले नाही',
          marathiStyle,
        ),
        const SizedBox(height: 24),
        ResponsiveFieldRow(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BilingualField(
                    label: 'Dated',
                    marathiLabel: 'दिनांक',
                    controller: _formADatedCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiStyle,
                  ),
                  BilingualField(
                    label: 'Signature',
                    marathiLabel: 'सही',
                    controller: _moSignatureCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BilingualField(
                    label: 'Time',
                    marathiLabel: 'वेळ',
                    controller: _formATimeCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiStyle,
                  ),
                  BilingualField(
                    label: 'Designation',
                    marathiLabel: 'पदनाम',
                    controller: _moDesignationCtrl,
                    serifStyle: serifStyle,
                    marathiLabelStyle: marathiStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        BilingualMultilineField(
          label: 'Signature / Thumb impression of the person examined',
          marathiLabel: 'तपासण्यात आलेल्या व्यक्तीची सही / अंगठ्याचा ठसा',
          controller: _examinedSigCtrl,
          minLines: 2,
          serifStyle: serifStyle,
          marathiLabelStyle: marathiStyle,
        ),
        BilingualMultilineField(
          label:
              'Marks of Identification of the person examined in case he refuses to give his signature / Thumb impression',
          marathiLabel:
              'सही / अंगठ्याचा ठसा देण्यास नकार दिल्यास ओळखीच्या खुणा',
          controller: _idMarksCtrl,
          minLines: 2,
          serifStyle: serifStyle,
          marathiLabelStyle: marathiStyle,
        ),
      ],
    );
  }

  Widget _formBPage(TextStyle serifStyle, TextStyle marathiStyle) {
    return FormPaperPage(
      formLabel: 'Form B / नमुना ब',
      children: [
        Center(
          child: Column(
            children: [
              Text(
                'FORM "B"',
                style: serifStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              Text(
                'नमुना "ब"',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              Text('(See rule 4 (2))', style: serifStyle.copyWith(fontSize: 11, decoration: TextDecoration.underline)),
              Text(
                '(नियम ४ (२) पहा)',
                style: marathiStyle.copyWith(fontSize: 10, decoration: TextDecoration.underline),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Reference layout: "From," header row with No. top-right; address block full width below.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BilingualSectionHeader(
                label: 'From,',
                marathiLabel: 'पाठवणार,',
                serifStyle: serifStyle.copyWith(fontWeight: FontWeight.w600),
                marathiLabelStyle: marathiStyle,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 150,
              child: BilingualField(
                label: 'No.',
                marathiLabel: 'क्र.',
                controller: _formBNoCtrl,
                serifStyle: serifStyle,
                marathiLabelStyle: marathiStyle,
              ),
            ),
          ],
        ),
        _bilingualCaption(
          '(Name, Designation and address of the registered medical practitioner)',
          '(नोंदणीकृत वैद्यकीय अधिकारी यांचे नाव, पदनाम व पत्ता)',
          serifStyle,
          marathiStyle,
        ),
        BilingualDynamicLinedTextField(
          controller: _fromPractitionerCtrl,
          minLines: 3,
          serifStyle: serifStyle,
        ),
        const SizedBox(height: 16),
        BilingualSectionHeader(
          label: 'To,',
          marathiLabel: 'प्रति,',
          serifStyle: serifStyle.copyWith(fontWeight: FontWeight.w600),
          marathiLabelStyle: marathiStyle,
        ),
        _bilingualCaption(
          '(Name and address of the Testing Officer)',
          '(तपासणी अधिकाऱ्याचे नाव व पत्ता)',
          serifStyle,
          marathiStyle,
        ),
        BilingualDynamicLinedTextField(
          controller: _toTestingOfficerCtrl,
          minLines: 3,
          serifStyle: serifStyle,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 220,
            child: BilingualField(
              label: 'Date :-',
              marathiLabel: 'दिनांक',
              controller: _formBDateCtrl,
              serifStyle: serifStyle,
              marathiLabelStyle: marathiStyle,
            ),
          ),
        ),
        const SizedBox(height: 16),
        BilingualSectionHeader(
          label: 'Sir,',
          marathiLabel: 'महोदय,',
          serifStyle: serifStyle,
          marathiLabelStyle: marathiStyle,
        ),
        const SizedBox(height: 8),
        _bilingualCaption(
          'I forward herewith by post / with Shri.',
          'यासोबत पोस्ट / श्री.',
          serifStyle,
          marathiStyle,
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 4,
          runSpacing: 10,
          children: [
            _inlineField(style: serifStyle, controller: _messengerNameCtrl, width: 140),
            Text('of Police station a phial bearing serial No.', style: serifStyle),
            Text('पोलीस ठाणे — शीशी अ.क्र.', style: marathiStyle.copyWith(fontSize: 10)),
            _inlineField(style: serifStyle, controller: _phialSerialCtrl, width: 90),
            Text('containing', style: serifStyle),
            Text('यात', style: marathiStyle.copyWith(fontSize: 10)),
            _inlineField(style: serifStyle, controller: _bloodAmountCtrl, width: 60),
            Text('c.c. of venous blood collected by me on', style: serifStyle),
            Text('स.स. रक्त गोळा केले', style: marathiStyle.copyWith(fontSize: 10)),
            _inlineField(style: serifStyle, controller: _collectionDateCtrl, width: 90),
            Text('at', style: serifStyle),
            _inlineField(style: serifStyle, controller: _collectionTimeCtrl, width: 70),
            _inlineField(style: serifStyle, controller: _collectionAmPmCtrl, width: 50),
            Text('a.m./p.m. from the body of Shri/Smt/Kumari', style: serifStyle),
            _inlineField(style: serifStyle, controller: _subjectNameCtrl, width: 140),
            Text('of', style: serifStyle),
            Text('यांचे', style: marathiStyle.copyWith(fontSize: 10)),
            _inlineField(style: serifStyle, controller: _subjectAddressCtrl, width: 180),
            Text(
              'who was produced before me for medical examination and / or collection of blood from his / her body by',
              style: serifStyle,
            ),
            _inlineField(style: serifStyle, controller: _producedByCtrl, width: 180),
            Text(
              'and request you to test the blood and issue a certificate ( in duplicates ) regarding the result of the test.',
              style: serifStyle,
            ),
          ],
        ),
        _marathiCaption(
          'वैद्यकीय तपासणी / रक्त गोळा करण्यासाठी सादर — रक्ताची तपासणी करून निकालाचे (दोन प्रती) प्रमाणपत्र द्यावे',
          marathiStyle,
        ),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Yours Faithfully,', style: serifStyle),
              Text('भवदीय', style: marathiStyle.copyWith(fontSize: 10)),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: BilingualSimpleUnderlineInput(
                  controller: _formBSignatureCtrl,
                  serifStyle: serifStyle,
                ),
              ),
              Text(
                'Signature and designation of the registered medical practitioner.',
                style: serifStyle.copyWith(fontSize: 10),
                textAlign: TextAlign.right,
              ),
              Text(
                'नोंदणीकृत वैद्यकीय अधिकारी यांची सही व पदनाम',
                style: marathiStyle.copyWith(fontSize: 9),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        BilingualMultilineField(
          label: 'Facsimile of the seal or Monogram used for sealing the phial containing the blood.',
          marathiLabel: 'रक्ताची शीशी सील करण्यासाठी वापरलेल्या शिक्क्याची / monogram ची प्रतिकृती',
          controller: _sealFacsimileCtrl,
          minLines: 2,
          serifStyle: serifStyle,
          marathiLabelStyle: marathiStyle,
        ),
        const SizedBox(height: 12),
        _bilingualCaption(
          'Here specify the name, designation and address of the messenger with whom the phial containing the blood is forwarded for delivery to the Testing Officer.',
          'शीशी पाठवणाऱ्या दूताचे नाव, पदनाम व पत्ता (तपासणी अधिकाऱ्याकडे पोहोचण्यासाठी).',
          serifStyle.copyWith(fontSize: 10),
          marathiStyle,
        ),
        _bilingualCaption(
          'Here state the name and designation of the officer by whom the said person was produced for collection of blood.',
          'रक्त गोळा करण्यासाठी सादर केलेल्या व्यक्तीला कोणत्या अधिकाऱ्याने सादर केले — नाव व पदनाम.',
          serifStyle.copyWith(fontSize: 10),
          marathiStyle,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final serifStyle = FormTypography.serifStyle();
    final marathiStyle = FormTypography.marathiLabelStyle();

    return FormViewScaffold(
      readOnly: widget.readOnly,
      children: [
        if (_showFormA) _formAPage(serifStyle, marathiStyle),
        if (_showFormA && _showFormB) const SizedBox(height: 24),
        if (_showFormB) _formBPage(serifStyle, marathiStyle),
      ],
    );
  }
}
