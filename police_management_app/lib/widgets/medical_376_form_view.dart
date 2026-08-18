import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bilingual_field.dart';
import 'form_paper_page.dart';
import 'form_table_helpers.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';

/// Medico-legal examination — Female survivor (13 pp) + Male accused (4 pp).
class Medical376FormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const Medical376FormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<Medical376FormView> createState() => Medical376FormViewState();
}

class Medical376FormViewState extends State<Medical376FormView> {
  bool get _showFemale {
    final s = widget.formSection?.toLowerCase() ?? '';
    if (s.isEmpty) return true;
    return s.contains('female');
  }

  bool get _showMale {
    final s = widget.formSection?.toLowerCase() ?? '';
    if (s.isEmpty) return true;
    return s.contains('male');
  }

  // ── Female (survivor) — key identification fields ──
  final _fHospitalCtrl = TextEditingController();
  final _fOpdCtrl = TextEditingController();
  final _fInpatientCtrl = TextEditingController();
  final _fNameCtrl = TextEditingController();
  final _fParentCtrl = TextEditingController();
  final _fAddressCtrl = TextEditingController();
  final _fAgeCtrl = TextEditingController();
  final _fDobCtrl = TextEditingController();
  final _fSexCtrl = TextEditingController();
  final _fArrivalDtCtrl = TextEditingController();
  final _fExamStartCtrl = TextEditingController();
  final _fBroughtByCtrl = TextEditingController();
  final _fMlcCtrl = TextEditingController();
  final _fPsCtrl = TextEditingController();
  final _fConsciousCtrl = TextEditingController();
  final _fDisabilityCtrl = TextEditingController();
  final _fConsentCtrl = TextEditingController();
  final _fSurvivorSigCtrl = TextEditingController();
  final _fWitnessSigCtrl = TextEditingController();
  final _fIdMark1Ctrl = TextEditingController();
  final _fIdMark2Ctrl = TextEditingController();
  final _fMedHistoryCtrl = TextEditingController();
  final _fViolenceHistoryCtrl = TextEditingController();
  final _fPhysicalViolenceCtrl = TextEditingController();
  final _fEmotionalAbuseCtrl = TextEditingController();
  final _fSexualViolenceDetailCtrl = TextEditingController();
  final _fPostIncidentCtrl = TextEditingController();
  final _fGeneralExamCtrl = TextEditingController();
  final _fBodyFrontNotesCtrl = TextEditingController();
  final _fBodyBackNotesCtrl = TextEditingController();
  final _fGenitalExamCtrl = TextEditingController();
  final _fSystemicExamCtrl = TextEditingController();
  final _fGenitalDiagramNotesCtrl = TextEditingController();
  final _fLabSamplesCtrl = TextEditingController();
  final _fFslSamplesCtrl = TextEditingController();
  final _fGenitalEvidenceCtrl = TextEditingController();
  final _fProvisionalOpinionCtrl = TextEditingController();
  final _fTreatmentCtrl = TextEditingController();
  final _fCompletionCtrl = TextEditingController();
  final _fFinalOpinionCtrl = TextEditingController();

  final List<TextEditingController> _fInjuryRows =
      List.generate(12, (_) => TextEditingController());

  // ── Male (accused) ──
  final _mHospitalCtrl = TextEditingController();
  final _mOpdCtrl = TextEditingController();
  final _mDateCtrl = TextEditingController();
  final _mMlcCtrl = TextEditingController();
  final _mMlcDateCtrl = TextEditingController();
  final _mAccusedNameCtrl = TextEditingController();
  final _mAgeCtrl = TextEditingController();
  final _mDobCtrl = TextEditingController();
  final _mReligionCtrl = TextEditingController();
  final _mMaritalCtrl = TextEditingController();
  final _mAddressCtrl = TextEditingController();
  final _mPoliceNameCtrl = TextEditingController();
  final _mBuckleCtrl = TextEditingController();
  final _mPsCtrl = TextEditingController();
  final _mCrNoCtrl = TextEditingController();
  final _mSectionCtrl = TextEditingController();
  final _mConsentCtrl = TextEditingController();
  final _mIdMark1Ctrl = TextEditingController();
  final _mIdMark2Ctrl = TextEditingController();
  final _mExamDateTimeCtrl = TextEditingController();
  final _mDoctorCtrl = TextEditingController();
  final _mAssaultHistoryCtrl = TextEditingController();
  final _mWitnessSigCtrl = TextEditingController();
  final _mAccusedSigCtrl = TextEditingController();
  final _mMedSurgicalHistoryCtrl = TextEditingController();
  final _mGeneralPhysicalCtrl = TextEditingController();
  final _mLocalExamCtrl = TextEditingController();
  final _mSystemicExamCtrl = TextEditingController();
  final _mAdditionalFindingsCtrl = TextEditingController();
  final _mLabSamplesCtrl = TextEditingController();
  final _mFslNoteCtrl = TextEditingController();
  final _mProvisionalOpinionCtrl = TextEditingController();
  final _mDoctorSigCtrl = TextEditingController();
  final _mReceiptPoliceCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _fHospitalCtrl,
      _fOpdCtrl,
      _fInpatientCtrl,
      _fNameCtrl,
      _fParentCtrl,
      _fAddressCtrl,
      _fAgeCtrl,
      _fDobCtrl,
      _fSexCtrl,
      _fArrivalDtCtrl,
      _fExamStartCtrl,
      _fBroughtByCtrl,
      _fMlcCtrl,
      _fPsCtrl,
      _fConsciousCtrl,
      _fDisabilityCtrl,
      _fConsentCtrl,
      _fSurvivorSigCtrl,
      _fWitnessSigCtrl,
      _fIdMark1Ctrl,
      _fIdMark2Ctrl,
      _fMedHistoryCtrl,
      _fViolenceHistoryCtrl,
      _fPhysicalViolenceCtrl,
      _fEmotionalAbuseCtrl,
      _fSexualViolenceDetailCtrl,
      _fPostIncidentCtrl,
      _fGeneralExamCtrl,
      _fBodyFrontNotesCtrl,
      _fBodyBackNotesCtrl,
      _fGenitalExamCtrl,
      _fSystemicExamCtrl,
      _fGenitalDiagramNotesCtrl,
      _fLabSamplesCtrl,
      _fFslSamplesCtrl,
      _fGenitalEvidenceCtrl,
      _fProvisionalOpinionCtrl,
      _fTreatmentCtrl,
      _fCompletionCtrl,
      _fFinalOpinionCtrl,
      ..._fInjuryRows,
      _mHospitalCtrl,
      _mOpdCtrl,
      _mDateCtrl,
      _mMlcCtrl,
      _mMlcDateCtrl,
      _mAccusedNameCtrl,
      _mAgeCtrl,
      _mDobCtrl,
      _mReligionCtrl,
      _mMaritalCtrl,
      _mAddressCtrl,
      _mPoliceNameCtrl,
      _mBuckleCtrl,
      _mPsCtrl,
      _mCrNoCtrl,
      _mSectionCtrl,
      _mConsentCtrl,
      _mIdMark1Ctrl,
      _mIdMark2Ctrl,
      _mExamDateTimeCtrl,
      _mDoctorCtrl,
      _mAssaultHistoryCtrl,
      _mWitnessSigCtrl,
      _mAccusedSigCtrl,
      _mMedSurgicalHistoryCtrl,
      _mGeneralPhysicalCtrl,
      _mLocalExamCtrl,
      _mSystemicExamCtrl,
      _mAdditionalFindingsCtrl,
      _mLabSamplesCtrl,
      _mFslNoteCtrl,
      _mProvisionalOpinionCtrl,
      _mDoctorSigCtrl,
      _mReceiptPoliceCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> collectData() {
    return {
      'formSection': widget.formSection ?? '',
      'pageRange': widget.pageRange ?? '',
      'variant': _showFemale && _showMale
          ? 'both'
          : _showFemale
              ? 'female'
              : 'male',
      'f_hospital': _fHospitalCtrl.text.trim(),
      'f_opd': _fOpdCtrl.text.trim(),
      'f_inpatient': _fInpatientCtrl.text.trim(),
      'f_name': _fNameCtrl.text.trim(),
      'f_parent': _fParentCtrl.text.trim(),
      'f_address': _fAddressCtrl.text.trim(),
      'f_age': _fAgeCtrl.text.trim(),
      'f_dob': _fDobCtrl.text.trim(),
      'f_sex': _fSexCtrl.text.trim(),
      'f_arrival': _fArrivalDtCtrl.text.trim(),
      'f_examStart': _fExamStartCtrl.text.trim(),
      'f_broughtBy': _fBroughtByCtrl.text.trim(),
      'f_mlc': _fMlcCtrl.text.trim(),
      'f_ps': _fPsCtrl.text.trim(),
      'f_conscious': _fConsciousCtrl.text.trim(),
      'f_disability': _fDisabilityCtrl.text.trim(),
      'f_consent': _fConsentCtrl.text.trim(),
      'f_survivorSig': _fSurvivorSigCtrl.text.trim(),
      'f_witnessSig': _fWitnessSigCtrl.text.trim(),
      'f_idMark1': _fIdMark1Ctrl.text.trim(),
      'f_idMark2': _fIdMark2Ctrl.text.trim(),
      'f_medHistory': _fMedHistoryCtrl.text.trim(),
      'f_violenceHistory': _fViolenceHistoryCtrl.text.trim(),
      'f_physicalViolence': _fPhysicalViolenceCtrl.text.trim(),
      'f_emotionalAbuse': _fEmotionalAbuseCtrl.text.trim(),
      'f_sexualViolenceDetail': _fSexualViolenceDetailCtrl.text.trim(),
      'f_postIncident': _fPostIncidentCtrl.text.trim(),
      'f_generalExam': _fGeneralExamCtrl.text.trim(),
      'f_bodyFrontNotes': _fBodyFrontNotesCtrl.text.trim(),
      'f_bodyBackNotes': _fBodyBackNotesCtrl.text.trim(),
      'f_genitalExam': _fGenitalExamCtrl.text.trim(),
      'f_systemicExam': _fSystemicExamCtrl.text.trim(),
      'f_genitalDiagramNotes': _fGenitalDiagramNotesCtrl.text.trim(),
      'f_labSamples': _fLabSamplesCtrl.text.trim(),
      'f_fslSamples': _fFslSamplesCtrl.text.trim(),
      'f_genitalEvidence': _fGenitalEvidenceCtrl.text.trim(),
      'f_provisionalOpinion': _fProvisionalOpinionCtrl.text.trim(),
      'f_treatment': _fTreatmentCtrl.text.trim(),
      'f_completion': _fCompletionCtrl.text.trim(),
      'f_finalOpinion': _fFinalOpinionCtrl.text.trim(),
      'f_injuryRows': _fInjuryRows.map((c) => c.text.trim()).toList(),
      'm_hospital': _mHospitalCtrl.text.trim(),
      'm_opd': _mOpdCtrl.text.trim(),
      'm_date': _mDateCtrl.text.trim(),
      'm_mlc': _mMlcCtrl.text.trim(),
      'm_mlcDate': _mMlcDateCtrl.text.trim(),
      'm_accusedName': _mAccusedNameCtrl.text.trim(),
      'm_age': _mAgeCtrl.text.trim(),
      'm_dob': _mDobCtrl.text.trim(),
      'm_religion': _mReligionCtrl.text.trim(),
      'm_marital': _mMaritalCtrl.text.trim(),
      'm_address': _mAddressCtrl.text.trim(),
      'm_policeName': _mPoliceNameCtrl.text.trim(),
      'm_buckle': _mBuckleCtrl.text.trim(),
      'm_ps': _mPsCtrl.text.trim(),
      'm_crNo': _mCrNoCtrl.text.trim(),
      'm_section': _mSectionCtrl.text.trim(),
      'm_consent': _mConsentCtrl.text.trim(),
      'm_idMark1': _mIdMark1Ctrl.text.trim(),
      'm_idMark2': _mIdMark2Ctrl.text.trim(),
      'm_examDateTime': _mExamDateTimeCtrl.text.trim(),
      'm_doctor': _mDoctorCtrl.text.trim(),
      'm_assaultHistory': _mAssaultHistoryCtrl.text.trim(),
      'm_witnessSig': _mWitnessSigCtrl.text.trim(),
      'm_accusedSig': _mAccusedSigCtrl.text.trim(),
      'm_medSurgicalHistory': _mMedSurgicalHistoryCtrl.text.trim(),
      'm_generalPhysical': _mGeneralPhysicalCtrl.text.trim(),
      'm_localExam': _mLocalExamCtrl.text.trim(),
      'm_systemicExam': _mSystemicExamCtrl.text.trim(),
      'm_additionalFindings': _mAdditionalFindingsCtrl.text.trim(),
      'm_labSamples': _mLabSamplesCtrl.text.trim(),
      'm_fslNote': _mFslNoteCtrl.text.trim(),
      'm_provisionalOpinion': _mProvisionalOpinionCtrl.text.trim(),
      'm_doctorSig': _mDoctorSigCtrl.text.trim(),
      'm_receiptPolice': _mReceiptPoliceCtrl.text.trim(),
    };
  }

  void hydrateFrom(Map<String, dynamic> data) {
    setState(() {
      void set(TextEditingController c, String key) {
        c.text = data[key]?.toString() ?? '';
      }

      set(_fHospitalCtrl, 'f_hospital');
      set(_fOpdCtrl, 'f_opd');
      set(_fInpatientCtrl, 'f_inpatient');
      set(_fNameCtrl, 'f_name');
      set(_fParentCtrl, 'f_parent');
      set(_fAddressCtrl, 'f_address');
      set(_fAgeCtrl, 'f_age');
      set(_fDobCtrl, 'f_dob');
      set(_fSexCtrl, 'f_sex');
      set(_fArrivalDtCtrl, 'f_arrival');
      set(_fExamStartCtrl, 'f_examStart');
      set(_fBroughtByCtrl, 'f_broughtBy');
      set(_fMlcCtrl, 'f_mlc');
      set(_fPsCtrl, 'f_ps');
      set(_fConsciousCtrl, 'f_conscious');
      set(_fDisabilityCtrl, 'f_disability');
      set(_fConsentCtrl, 'f_consent');
      set(_fSurvivorSigCtrl, 'f_survivorSig');
      set(_fWitnessSigCtrl, 'f_witnessSig');
      set(_fIdMark1Ctrl, 'f_idMark1');
      set(_fIdMark2Ctrl, 'f_idMark2');
      set(_fMedHistoryCtrl, 'f_medHistory');
      set(_fViolenceHistoryCtrl, 'f_violenceHistory');
      set(_fPhysicalViolenceCtrl, 'f_physicalViolence');
      set(_fEmotionalAbuseCtrl, 'f_emotionalAbuse');
      set(_fSexualViolenceDetailCtrl, 'f_sexualViolenceDetail');
      set(_fPostIncidentCtrl, 'f_postIncident');
      set(_fGeneralExamCtrl, 'f_generalExam');
      set(_fBodyFrontNotesCtrl, 'f_bodyFrontNotes');
      set(_fBodyBackNotesCtrl, 'f_bodyBackNotes');
      set(_fGenitalExamCtrl, 'f_genitalExam');
      set(_fSystemicExamCtrl, 'f_systemicExam');
      set(_fGenitalDiagramNotesCtrl, 'f_genitalDiagramNotes');
      set(_fLabSamplesCtrl, 'f_labSamples');
      set(_fFslSamplesCtrl, 'f_fslSamples');
      set(_fGenitalEvidenceCtrl, 'f_genitalEvidence');
      set(_fProvisionalOpinionCtrl, 'f_provisionalOpinion');
      set(_fTreatmentCtrl, 'f_treatment');
      set(_fCompletionCtrl, 'f_completion');
      set(_fFinalOpinionCtrl, 'f_finalOpinion');

      final injuries = data['f_injuryRows'];
      if (injuries is List) {
        for (var i = 0; i < _fInjuryRows.length && i < injuries.length; i++) {
          _fInjuryRows[i].text = injuries[i]?.toString() ?? '';
        }
      }

      set(_mHospitalCtrl, 'm_hospital');
      set(_mOpdCtrl, 'm_opd');
      set(_mDateCtrl, 'm_date');
      set(_mMlcCtrl, 'm_mlc');
      set(_mMlcDateCtrl, 'm_mlcDate');
      set(_mAccusedNameCtrl, 'm_accusedName');
      set(_mAgeCtrl, 'm_age');
      set(_mDobCtrl, 'm_dob');
      set(_mReligionCtrl, 'm_religion');
      set(_mMaritalCtrl, 'm_marital');
      set(_mAddressCtrl, 'm_address');
      set(_mPoliceNameCtrl, 'm_policeName');
      set(_mBuckleCtrl, 'm_buckle');
      set(_mPsCtrl, 'm_ps');
      set(_mCrNoCtrl, 'm_crNo');
      set(_mSectionCtrl, 'm_section');
      set(_mConsentCtrl, 'm_consent');
      set(_mIdMark1Ctrl, 'm_idMark1');
      set(_mIdMark2Ctrl, 'm_idMark2');
      set(_mExamDateTimeCtrl, 'm_examDateTime');
      set(_mDoctorCtrl, 'm_doctor');
      set(_mAssaultHistoryCtrl, 'm_assaultHistory');
      set(_mWitnessSigCtrl, 'm_witnessSig');
      set(_mAccusedSigCtrl, 'm_accusedSig');
      set(_mMedSurgicalHistoryCtrl, 'm_medSurgicalHistory');
      set(_mGeneralPhysicalCtrl, 'm_generalPhysical');
      set(_mLocalExamCtrl, 'm_localExam');
      set(_mSystemicExamCtrl, 'm_systemicExam');
      set(_mAdditionalFindingsCtrl, 'm_additionalFindings');
      set(_mLabSamplesCtrl, 'm_labSamples');
      set(_mFslNoteCtrl, 'm_fslNote');
      set(_mProvisionalOpinionCtrl, 'm_provisionalOpinion');
      set(_mDoctorSigCtrl, 'm_doctorSig');
      set(_mReceiptPoliceCtrl, 'm_receiptPolice');
    });
  }

  Widget _bilingualSection(String en, String mr, TextStyle serif, TextStyle marathi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: BilingualSectionHeader(
        label: en,
        marathiLabel: mr,
        serifStyle: serif.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
        marathiLabelStyle: marathi,
      ),
    );
  }

  Widget _bilingualField(
    String labelEn,
    String labelMr,
    TextEditingController controller,
    TextStyle serif,
    TextStyle marathi, {
    int minLines = 1,
  }) {
    if (minLines > 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: BilingualMultilineField(
          label: labelEn,
          marathiLabel: labelMr,
          controller: controller,
          minLines: minLines,
          serifStyle: serif,
          marathiLabelStyle: marathi,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: BilingualField(
        label: labelEn,
        marathiLabel: labelMr,
        controller: controller,
        serifStyle: serif,
        marathiLabelStyle: marathi,
      ),
    );
  }

  static const _femaleInjuryLabels = [
    ('Scalp examination for tenderness', 'टाळू — संवेदनशीलता तपासणी'),
    ('Facial bone injury / orbital blackening', 'चेहऱ्याच्या हाडांवर जखम / डोळ्याभोवती काळे पडणे'),
    ('Petechial haemorrhage in eyes', 'डोळ्यांमध्ये पेटेकियल रक्तस्त्राव'),
    ('Lips and Buccal Mucosa / Gums', 'ओठ / गालाची आतली बाजू / दात'),
    ('Behind the ears', 'कानामागे'),
    ('Ear drum', 'कानाचे पडदे'),
    ('Neck, Shoulders and Breast', 'मान, खांदे व स्तन'),
    ('Upper limb', 'वरचा हात / पाय'),
    ('Inner aspect of upper arms', 'वरच्या हाताच्या आतील बाजू'),
    ('Inner aspect of thighs', 'मांड्यांच्या आतील बाजू'),
    ('Lower limb / Buttocks', 'खालचा हात-पाय / नितंब'),
    ('Other, please specify', 'इतर (नमूद करा)'),
  ];

  Widget _buildFemalePages(TextStyle style, TextStyle marathi) {
    return Column(
      children: [
        FormPaperPage(
          formLabel: 'Pages 1–2 / पृ. १–२',
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
              ),
              child: Text(
                'महाराष्ट्र शासन — सार्वजनिक आरोग्य विभाग. परिपत्रक क्रमांक: संकीर्ण-२०१४/प्र.क्र.२७०/आरोग्य-३. '
                'दिनांक: ०७ ऑगस्ट, २०१५.',
                style: GoogleFonts.notoSansDevanagari(fontSize: 9, height: 1.35),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('CONFIDENTIAL', style: style.copyWith(fontWeight: FontWeight.bold)),
                  Text('गोपनीय', style: marathi.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  Text(
                    'Medico-legal Examination Report of Sexual Violence',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Text(
                    'लैंगिक हिंसाचाराचा वैद्यकीय-कायदेशीर तपासणी अहवाल',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _bilingualSection('1–11. Basic Information', '१–११. मूलभूत माहिती', style, marathi),
            BilingualFieldRow(fields: [
              _bilingualField('1. Hospital', '१. रुग्णालयाचे नाव', _fHospitalCtrl, style, marathi),
              _bilingualField('OPD No.', 'बाह्य रुग्ण क्र.', _fOpdCtrl, style, marathi),
            ]),
            _bilingualField('Inpatient No.', 'अंतर्गत रुग्ण क्र.', _fInpatientCtrl, style, marathi),
            _bilingualField('2. Name', '२. नाव', _fNameCtrl, style, marathi),
            _bilingualField('D/o or S/o (where known)', 'मुलगी / मुलगा (माहित असल्यास)', _fParentCtrl, style, marathi),
            _bilingualField('3. Address', '३. पत्ता', _fAddressCtrl, style, marathi, minLines: 2),
            BilingualFieldRow(fields: [
              _bilingualField('4. Age (as reported)', '४. वय (सांगितले)', _fAgeCtrl, style, marathi),
              _bilingualField('Date of Birth', 'जन्मतारीख', _fDobCtrl, style, marathi),
            ]),
            _bilingualField('5. Sex (M/F/Others)', '५. लिंग (पु/स्त्री/इ.)', _fSexCtrl, style, marathi),
            _bilingualField('6. Date and Time of arrival', '६. रुग्णालयात आगमन दिनांक व वेळ', _fArrivalDtCtrl, style, marathi),
            _bilingualField('7. Date and Time of commencement of examination', '७. तपासणी सुरू दिनांक व वेळ', _fExamStartCtrl, style, marathi),
            _bilingualField('8. Brought by (Name & signatures)', '८. कोणी आणले (नाव व सही)', _fBroughtByCtrl, style, marathi),
            BilingualFieldRow(fields: [
              _bilingualField('9. MLC No.', '९. एम.एल.सी. क्र.', _fMlcCtrl, style, marathi),
              _bilingualField('Police Station', 'पोलीस ठाणे', _fPsCtrl, style, marathi),
            ]),
            _bilingualField(
              '10. Whether conscious, oriented in time and place and person',
              '१०. जागरूक, वेळ/ठिकाण/व्यक्ती ओळखणारी आहे का',
              _fConsciousCtrl,
              style,
              marathi,
            ),
            _bilingualField(
              '11. Any physical/intellectual/psychosocial disability',
              '११. शारीरिक / बौद्धिक / मानसिक अपंगत्व',
              _fDisabilityCtrl,
              style,
              marathi,
              minLines: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '(Interpreters or special educators will be needed where the survivor has special needs such as hearing/speech disability, language barriers, intellectual or psychosocial disability.)',
                style: style.copyWith(fontSize: 9, fontStyle: FontStyle.italic),
              ),
            ),
            Text(
              '(श्रवण/वाक् अपंगत्व, भाषा अडथळा, बौद्धिक/मानसिक अपंगत्व असल्यास दुभाषी / विशेष शिक्षक आवश्यक.)',
              style: marathi.copyWith(fontSize: 9),
            ),
            _bilingualSection('12. Informed Consent / Refusal', '१२. माहितीपूर्ण संमती / नकार', style, marathi),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'I … D/o or S/o … hereby give my consent for: (a) medical examination for treatment (b) this medico legal examination (c) sample collection for clinical & forensic examination. I also understand that as per law the hospital is required to inform police.',
                    style: style.copyWith(fontSize: 10, height: 1.35),
                  ),
                  Text(
                    'मी … मुलगी/मुलगा … यांची … येथे संमती देतो/देते: (अ) उपचारासाठी वैद्यकीय तपासणी (ब) वैद्यकीय-कायदेशीर तपासणी (क) नैदानिक व फॉरेन्सिक नमुने. कायद्यानुसार रुग्णालयाने पोलीसांना कळवणे आवश्यक — हे मला समजावले.',
                    style: marathi.copyWith(fontSize: 9, height: 1.35),
                  ),
                ],
              ),
            ),
            _bilingualField('Consent / refusal details (record Yes/No choices)', 'संमती / नकार तपशील (होय/नाही)', _fConsentCtrl, style, marathi, minLines: 8),
            _bilingualSection('Signatures (Page 2)', 'सही (पृष्ठ २)', style, marathi),
            _bilingualField(
              'Survivor / Guardian signature (with date, time & place)',
              'पीडित / पालक सही (दिनांक, वेळ, ठिकाण)',
              _fSurvivorSigCtrl,
              style,
              marathi,
              minLines: 2,
            ),
            _bilingualField(
              'Witness signature / thumb impression',
              'साक्षीदार सही / अंगठ्याचा ठसा',
              _fWitnessSigCtrl,
              style,
              marathi,
              minLines: 2,
            ),
            _bilingualSection('13. Marks of identification', '१३. ओळखीच्या खुणा', style, marathi),
            BilingualFieldRow(fields: [
              _bilingualField('(1)', '(१)', _fIdMark1Ctrl, style, marathi),
              _bilingualField('(2)', '(२)', _fIdMark2Ctrl, style, marathi),
            ]),
            Center(
              child: Column(
                children: [
                  Text('Left Thumb impression', style: style.copyWith(fontSize: 10)),
                  Text('डाव्या हाताचा अंगठ्याचा ठसा', style: marathi.copyWith(fontSize: 9)),
                ],
              ),
            ),
            _bilingualSection('14. Relevant Medical/Surgical history', '१४. संबंधित वैद्यकीय / शस्त्रक्रिया इतिहास', style, marathi),
            _bilingualField('', 'मासिक पाळी, गर्भधारणा, लस, इ. तपशील', _fMedHistoryCtrl, style, marathi, minLines: 8),
          ],
        ),
        const SizedBox(height: 24),
        FormPaperPage(
          formLabel: 'Pages 3–5 / पृ. ३–५',
          children: [
            _bilingualSection('15 A. History of Sexual Violence', '१५ अ. लैंगिक हिंसाचाराचा इतिहास', style, marathi),
            _bilingualField('', 'घटना दिनांक, वेळ, ठिकाण, आरोपी, वर्णन', _fViolenceHistoryCtrl, style, marathi, minLines: 10),
            _bilingualSection('15 B. Type of physical violence used', '१५ ब. शारीरिक हिंसाचाराचा प्रकार', style, marathi),
            _bilingualField('', 'मारहाण, चाव, लाथ, डोके, इ.', _fPhysicalViolenceCtrl, style, marathi, minLines: 6),
            _bilingualSection('15 C–F. Emotional abuse, intoxication, sexual violence details', '१५ क–फ. भावनिक, नशा, लैंगिक हिंसा तपशील', style, marathi),
            _bilingualField('', 'भावनिक/मानसिक छळ, नशा, इ.', _fEmotionalAbuseCtrl, style, marathi, minLines: 6),
            _bilingualField('15 F. Penetration / emission details (Y/N/DNK)', '१५ फ. प्रवेश / उत्सर्ग (होय/नाही/माहित नाही)', _fSexualViolenceDetailCtrl, style, marathi, minLines: 8),
            _bilingualSection('Post-incident actions & general examination (Page 5)', 'घटनोत्तर कृती व सामान्य तपासणी (पृ. ५)', style, marathi),
            _bilingualField('', 'घटनोत्तर केलेली कृती', _fPostIncidentCtrl, style, marathi, minLines: 8),
            _bilingualField('16. General Physical Examination', '१६. सामान्य शारीरिक तपासणी', _fGeneralExamCtrl, style, marathi, minLines: 6),
          ],
        ),
        const SizedBox(height: 24),
        FormPaperPage(
          formLabel: 'Pages 6–8 / पृ. ६–८',
          children: [
            _bilingualSection('17. Examination for injuries on the body', '१७. शरीरावरील जखमा तपासणी', style, marathi),
            for (var i = 0; i < _femaleInjuryLabels.length; i++)
              _bilingualField(_femaleInjuryLabels[i].$1, _femaleInjuryLabels[i].$2, _fInjuryRows[i], style, marathi, minLines: 2),
            _bilingualSection('Page 7 — Body diagram (anterior) — markings/notes', 'पृ. ७ — समोरील आकृती — खुणा/टिपणी', style, marathi),
            _bilingualField('', 'समोरील आकृतीवरील खुणा', _fBodyFrontNotesCtrl, style, marathi, minLines: 6),
            _bilingualSection('Page 8 — Body diagram (posterior) — markings/notes', 'पृ. ८ — मागील आकृती — खुणा/टिपणी', style, marathi),
            _bilingualField('', 'मागील आकृतीवरील खुणा', _fBodyBackNotesCtrl, style, marathi, minLines: 6),
          ],
        ),
        const SizedBox(height: 24),
        FormPaperPage(
          formLabel: 'Pages 9–10 / पृ. ९–१०',
          children: [
            _bilingualSection('18. Local examination of genital parts / other orifices', '१८. गुप्तांग / इतर छिद्रांची स्थानिक तपासणी', style, marathi),
            _bilingualField('', 'स्थानिक तपासणी तपशील', _fGenitalExamCtrl, style, marathi, minLines: 12),
            _bilingualSection('19. Systemic examination', '१९. प्रणालीगत तपासणी', style, marathi),
            _bilingualField('', 'प्रणालीगत तपासणी', _fSystemicExamCtrl, style, marathi, minLines: 6),
            _bilingualSection('Page 10 — Anatomical diagram notes', 'पृ. १० — शारीरिक आकृती टिपणी', style, marathi),
            _bilingualField('', 'आकृती टिपणी', _fGenitalDiagramNotesCtrl, style, marathi, minLines: 8),
          ],
        ),
        const SizedBox(height: 24),
        FormPaperPage(
          formLabel: 'Pages 11–13 / पृ. ११–१३',
          children: [
            _bilingualSection('20. Sample collection — hospital laboratory', '२०. नमुने — रुग्णालय प्रयोगशाळा', style, marathi),
            _bilingualField('', 'प्रयोगशाळा नमुने', _fLabSamplesCtrl, style, marathi, minLines: 4),
            _bilingualSection('21. Samples for Forensic Science Laboratory', '२१. फॉरेन्सिक विज्ञान प्रयोगशाळेसाठी नमुने', style, marathi),
            _bilingualField('', 'एफ.एस.एल. नमुने', _fFslSamplesCtrl, style, marathi, minLines: 8),
            _bilingualSection('Genital and Anal evidence (Page 12)', 'गुप्तांग व गुदद्वार पुरावा (पृ. १२)', style, marathi),
            _bilingualField('', 'पुरावा तपशील', _fGenitalEvidenceCtrl, style, marathi, minLines: 8),
            _bilingualSection('22. Provisional medical opinion', '२२. तात्पुरती वैद्यकीय मते', style, marathi),
            _bilingualField('', 'तात्पुरते मत', _fProvisionalOpinionCtrl, style, marathi, minLines: 8),
            _bilingualSection('23. Treatment prescribed', '२३. दिलेला उपचार', style, marathi),
            _bilingualField('', 'उपचार', _fTreatmentCtrl, style, marathi, minLines: 6),
            _bilingualSection('24–25. Completion & Final Opinion', '२४–२५. पूर्णता व अंतिम मत', style, marathi),
            _bilingualField('Date/time of completion, doctor signature, place', 'पूर्णता दिनांक/वेळ, डॉ. सही, ठिकाण', _fCompletionCtrl, style, marathi, minLines: 4),
            _bilingualField('25. Final Opinion (after Lab reports)', '२५. अंतिम मत (अहवालानंतर)', _fFinalOpinionCtrl, style, marathi, minLines: 8),
            const SizedBox(height: 8),
            Text(
              'COPY OF THE ENTIRE MEDICAL REPORT MUST BE GIVEN TO THE SURVIVOR/VICTIM FREE OF COST IMMEDIATELY',
              style: style.copyWith(fontWeight: FontWeight.bold, fontSize: 10),
            ),
            Text(
              'संपूर्ण वैद्यकीय अहवालाची प्रत पीडित/पीडितेला त्वरित विनामूल्य द्यावी',
              style: marathi.copyWith(fontWeight: FontWeight.bold, fontSize: 9),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMalePages(TextStyle style, TextStyle marathi) {
    return Column(
      children: [
        FormPaperPage(
          formLabel: 'Page 1 / पृ. १',
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'FORENSIC MEDICAL EXAMINATION OF ALLEGED ACCUSED\nFOR EVIDENCE OF SEXUAL ASSAULT',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Text(
                    'लैंगिक अत्याचाराच्या पुराव्यासाठी\nआरोपीची फॉरेन्सिक वैद्यकीय तपासणी',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _bilingualSection('(I) Preliminary information and consent', '(१) प्राथमिक माहिती व संमती', style, marathi),
            _bilingualField('1. Name of the hospital', '१. रुग्णालयाचे नाव', _mHospitalCtrl, style, marathi),
            BilingualFieldRow(fields: [
              _bilingualField('2. OPD/IPD No.', '२. बाह्य/अंतर्गत क्र.', _mOpdCtrl, style, marathi),
              _bilingualField('Date', 'दिनांक', _mDateCtrl, style, marathi),
            ]),
            BilingualFieldRow(fields: [
              _bilingualField('MLC No.', 'एम.एल.सी. क्र.', _mMlcCtrl, style, marathi),
              _bilingualField('MLC Date', 'एम.एल.सी. दिनांक', _mMlcDateCtrl, style, marathi),
            ]),
            _bilingualField('3. Name of the alleged Accused', '३. आरोपीचे नाव', _mAccusedNameCtrl, style, marathi),
            BilingualFieldRow(fields: [
              _bilingualField('4. Age', '४. वय', _mAgeCtrl, style, marathi),
              _bilingualField('Date of Birth', 'जन्मतारीख', _mDobCtrl, style, marathi),
              _bilingualField('Religion', 'धर्म', _mReligionCtrl, style, marathi),
            ]),
            _bilingualField('5. Married/Single/Divorced', '५. विवाहित/अविवाहित/घटस्फोट', _mMaritalCtrl, style, marathi),
            _bilingualField('6. Address', '६. पत्ता', _mAddressCtrl, style, marathi, minLines: 3),
            _bilingualField(
              '7. Brought by — Name of police / B No. / Police Station / C.R.No / U/s',
              '७. कोणी आणले — पोलीस नाव / बक्कल / ठाणे / गु.नो. / कलम',
              _mPoliceNameCtrl,
              style,
              marathi,
              minLines: 2,
            ),
            BilingualFieldRow(fields: [
              _bilingualField('Buckle No.', 'बक्कल क्र.', _mBuckleCtrl, style, marathi),
              _bilingualField('P.S.', 'पो.ठ.', _mPsCtrl, style, marathi),
            ]),
            BilingualFieldRow(fields: [
              _bilingualField('C.R.No', 'गु.नो.', _mCrNoCtrl, style, marathi),
              _bilingualField('U/s', 'कलम', _mSectionCtrl, style, marathi),
            ]),
            _bilingualSection('8. CONSENT', '८. संमती', style, marathi),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'I … hereby voluntarily consent to: (a) medical examination and examination of genitals and other body parts (b) collection of samples for medical and forensic examination and treatment. All this has been explained to me in the manner and language which I can understand.',
                    style: style.copyWith(fontSize: 10, height: 1.35),
                  ),
                  Text(
                    'मी … येथे स्वेच्छेने संमती देतो: (अ) वैद्यकीय व गुप्तांग/शरीर तपासणी (ब) वैद्यकीय व फॉरेन्सिक नमुने व उपचार. हे मला समजेल अशा भाषेत समजावले.',
                    style: marathi.copyWith(fontSize: 9, height: 1.35),
                  ),
                ],
              ),
            ),
            _bilingualField('Consent details / signature block', 'संमती तपशील / सही', _mConsentCtrl, style, marathi, minLines: 6),
            _bilingualSection('9. Identification Marks', '९. ओळखीच्या खुणा', style, marathi),
            BilingualFieldRow(fields: [
              _bilingualField('(1)', '(१)', _mIdMark1Ctrl, style, marathi),
              _bilingualField('(2) Left thumb impression', '(२) डाव्या हाताचा अंगठा', _mIdMark2Ctrl, style, marathi),
            ]),
            _bilingualField('10. Date & time of examination', '१०. तपासणी दिनांक व वेळ', _mExamDateTimeCtrl, style, marathi),
            _bilingualField('11. Name/s of doctor who conducted examination', '११. तपासणी केलेल्या डॉक्टराचे नाव', _mDoctorCtrl, style, marathi),
            _bilingualSection('(II) History of alleged sexual assault as stated by Accused', '(२) आरोपीने सांगितलेला अत्याचाराचा इतिहास', style, marathi),
            _bilingualField('', 'आरोपीचे वर्णन', _mAssaultHistoryCtrl, style, marathi, minLines: 10),
            BilingualFieldRow(fields: [
              _bilingualField('Signature & name of witness', 'साक्षीदार सही व नाव', _mWitnessSigCtrl, style, marathi),
              _bilingualField('Signature & name of accused/guardian', 'आरोपी/पालक सही व नाव', _mAccusedSigCtrl, style, marathi),
            ]),
          ],
        ),
        const SizedBox(height: 24),
        FormPaperPage(
          formLabel: 'Page 2 / पृ. २',
          children: [
            _bilingualSection('(III) Medical and Surgical History', '(३) वैद्यकीय व शस्त्रक्रिया इतिहास', style, marathi),
            _bilingualField('', 'वैद्यकीय इतिहास', _mMedSurgicalHistoryCtrl, style, marathi, minLines: 12),
            _bilingualSection('(IV) General physical examination', '(४) सामान्य शारीरिक तपासणी', style, marathi),
            _bilingualField('', 'सामान्य तपासणी', _mGeneralPhysicalCtrl, style, marathi, minLines: 12),
            _bilingualSection('(V) Local Examination: Perineum and Genitals', '(५) स्थानिक तपासणी: गुदद्वार व गुप्तांग', style, marathi),
            _bilingualField('', 'स्थानिक तपासणी', _mLocalExamCtrl, style, marathi, minLines: 10),
          ],
        ),
        const SizedBox(height: 24),
        FormPaperPage(
          formLabel: 'Page 3 / पृ. ३',
          children: [
            _bilingualSection('(VI) Systemic Examination', '(६) प्रणालीगत तपासणी', style, marathi),
            _bilingualField('', 'प्रणालीगत तपासणी', _mSystemicExamCtrl, style, marathi, minLines: 4),
            _bilingualSection('(VII) Additional findings / referral', '(७) अतिरिक्त निष्कर्ष / संदर्भ', style, marathi),
            _bilingualField('', 'अतिरिक्त निष्कर्ष', _mAdditionalFindingsCtrl, style, marathi, minLines: 4),
            _bilingualSection('VIII) Hospital/Clinical Laboratory samples (Rows 7–11)', '(८) रुग्णालय प्रयोगशाळा नमुने', style, marathi),
            _bilingualField('', 'नमुने', _mLabSamplesCtrl, style, marathi, minLines: 8),
            _bilingualSection('(IX) Samples / Forensic Evidence for FSL', '(९) एफ.एस.एल.साठी फॉरेन्सिक पुरावा', style, marathi),
            _bilingualField('Note (If any)', 'टिपणी (असल्यास)', _mFslNoteCtrl, style, marathi, minLines: 6),
          ],
        ),
        const SizedBox(height: 24),
        FormPaperPage(
          formLabel: 'Page 4 / पृ. ४',
          children: [
            _bilingualSection('PROVISIONAL OPINION', 'तात्पुरते वैद्यकीय मत', style, marathi),
            _bilingualField('', 'तात्पुरते मत', _mProvisionalOpinionCtrl, style, marathi, minLines: 10),
            _bilingualField('Signature / Name of Dr. / Designation', 'डॉ. सही / नाव / पदनाम', _mDoctorSigCtrl, style, marathi, minLines: 3),
            _bilingualSection('RECEIPT (by police official)', 'पोलीस अधिकाऱ्याची पावती', style, marathi),
            _bilingualField('', 'पावती तपशील', _mReceiptPoliceCtrl, style, marathi, minLines: 4),
            FormMrwFooter(serifStyle: style, fontSize: 10),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = FormTypography.serifStyle();
    final marathi = FormTypography.marathiLabelStyle();

    return FormViewScaffold(
      readOnly: widget.readOnly,
      children: [
        if (_showFemale) _buildFemalePages(style, marathi),
        if (_showFemale && _showMale) const SizedBox(height: 24),
        if (_showMale) _buildMalePages(style, marathi),
      ],
    );
  }
}
