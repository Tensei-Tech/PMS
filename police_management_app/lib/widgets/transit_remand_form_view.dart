import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import 'form_paper_page.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';

/// Transit Remand — Marathi (2 pp) + English (1 pp) variants.
class TransitRemandFormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const TransitRemandFormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<TransitRemandFormView> createState() => TransitRemandFormViewState();
}

class TransitRemandFormViewState extends State<TransitRemandFormView> {
  bool get _isEnglish {
    final s = widget.formSection?.toLowerCase() ?? '';
    return s.contains('english');
  }

  bool get _showMarathiPage1 {
    if (_isEnglish) return false;
    final s = widget.formSection?.toLowerCase() ?? '';
    if (s.isEmpty || s.contains('marathi')) return true;
    return !s.contains('page 2') && !s.contains('police assist');
  }

  bool get _showMarathiPage2 {
    if (_isEnglish) return false;
    final s = widget.formSection?.toLowerCase() ?? '';
    if (s.isEmpty || s.contains('marathi')) return true;
    return s.contains('page 2') || s.contains('police assist');
  }

  // ── Marathi Page 1: Requisition to transit remand ──
  final _m1DateCtrl = TextEditingController();
  final _m1CourtNameCtrl = TextEditingController();
  final _m1CourtCityCtrl = TextEditingController();
  final _m1CourtStateCtrl = TextEditingController();
  final _m1PsNameCtrl = TextEditingController();
  final _m1PsCityCtrl = TextEditingController();
  final _m1PsStateCtrl = TextEditingController();
  final _m1CrNoCtrl = TextEditingController();
  final _m1CrSectionsCtrl = TextEditingController();
  final _m1CrDateTimeCtrl = TextEditingController();
  final _m1AccusedNameCtrl = TextEditingController();
  final _m1AccusedAgeCtrl = TextEditingController();
  final _m1AccusedAddressCtrl = TextEditingController();
  final _m1ArrestDateTimeCtrl = TextEditingController();
  final _m1ArrestPlaceCtrl = TextEditingController();
  final _m1SeizureCtrl = TextEditingController();
  final _m1RemandFromCtrl = TextEditingController();
  final _m1RemandDaysCtrl = TextEditingController();
  final _m1ProduceCourtCtrl = TextEditingController();
  final _m1OfficerNameCtrl = TextEditingController();
  final _m1OfficerRankCtrl = TextEditingController();
  final _m1OfficerPsCtrl = TextEditingController();
  final _m1OfficerCityCtrl = TextEditingController();
  final _m1CourtRemarkCtrl = TextEditingController();

  // ── Marathi Page 2: Police assistance request ──
  final _m2DateCtrl = TextEditingController();
  final _m2RecipientPsCtrl = TextEditingController();
  final _m2RecipientAddressCtrl = TextEditingController();
  final _m2RefCrNoCtrl = TextEditingController();
  final _m2RefSectionsCtrl = TextEditingController();
  final _m2AccusedNameCtrl = TextEditingController();
  final _m2AccusedAgeCtrl = TextEditingController();
  final _m2AccusedAddressCtrl = TextEditingController();
  final _m2OfficerNameCtrl = TextEditingController();
  final _m2OfficerRankCtrl = TextEditingController();
  final _m2OfficerPsCtrl = TextEditingController();
  final _m2OfficerCityCtrl = TextEditingController();

  // ── English Page 1: Transit remand application ──
  final _eOutwardNoCtrl = TextEditingController();
  final _eDateCtrl = TextEditingController();
  final _ePsNameCtrl = TextEditingController();
  final _eCourtToLine1Ctrl = TextEditingController();
  final _eCourtToLine2Ctrl = TextEditingController();
  final _eReportByNameCtrl = TextEditingController();
  final _eReportByRankCtrl = TextEditingController();
  final _eSubjectHoursCtrl = TextEditingController();
  final _eFirNoCtrl = TextEditingController();
  final _eIpcSectionsCtrl = TextEditingController();
  final _eComplainantNameCtrl = TextEditingController();
  final _eComplainantAgeCtrl = TextEditingController();
  final _eComplainantProfessionCtrl = TextEditingController();
  final _eComplainantAddressCtrl = TextEditingController();
  final _eAccused1NameCtrl = TextEditingController();
  final _eAccused1AgeCtrl = TextEditingController();
  final _eAccused1DetailsCtrl = TextEditingController();
  final _eAccused2NameCtrl = TextEditingController();
  final _eAccused2AgeCtrl = TextEditingController();
  final _eAccused2DetailsCtrl = TextEditingController();
  final _eIncidentSummaryCtrl = TextEditingController();
  final _eArrestedNameCtrl = TextEditingController();
  final _eArrestPsCtrl = TextEditingController();
  final _eArrestTimeCtrl = TextEditingController();
  final _eArrestDateCtrl = TextEditingController();
  final _eSdNoCtrl = TextEditingController();
  final _eCourtNameCtrl = TextEditingController();
  final _eRemandHoursCtrl = TextEditingController();
  final _eOfficerSigCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _m1DateCtrl,
      _m1CourtNameCtrl,
      _m1CourtCityCtrl,
      _m1CourtStateCtrl,
      _m1PsNameCtrl,
      _m1PsCityCtrl,
      _m1PsStateCtrl,
      _m1CrNoCtrl,
      _m1CrSectionsCtrl,
      _m1CrDateTimeCtrl,
      _m1AccusedNameCtrl,
      _m1AccusedAgeCtrl,
      _m1AccusedAddressCtrl,
      _m1ArrestDateTimeCtrl,
      _m1ArrestPlaceCtrl,
      _m1SeizureCtrl,
      _m1RemandFromCtrl,
      _m1RemandDaysCtrl,
      _m1ProduceCourtCtrl,
      _m1OfficerNameCtrl,
      _m1OfficerRankCtrl,
      _m1OfficerPsCtrl,
      _m1OfficerCityCtrl,
      _m1CourtRemarkCtrl,
      _m2DateCtrl,
      _m2RecipientPsCtrl,
      _m2RecipientAddressCtrl,
      _m2RefCrNoCtrl,
      _m2RefSectionsCtrl,
      _m2AccusedNameCtrl,
      _m2AccusedAgeCtrl,
      _m2AccusedAddressCtrl,
      _m2OfficerNameCtrl,
      _m2OfficerRankCtrl,
      _m2OfficerPsCtrl,
      _m2OfficerCityCtrl,
      _eOutwardNoCtrl,
      _eDateCtrl,
      _ePsNameCtrl,
      _eCourtToLine1Ctrl,
      _eCourtToLine2Ctrl,
      _eReportByNameCtrl,
      _eReportByRankCtrl,
      _eSubjectHoursCtrl,
      _eFirNoCtrl,
      _eIpcSectionsCtrl,
      _eComplainantNameCtrl,
      _eComplainantAgeCtrl,
      _eComplainantProfessionCtrl,
      _eComplainantAddressCtrl,
      _eAccused1NameCtrl,
      _eAccused1AgeCtrl,
      _eAccused1DetailsCtrl,
      _eAccused2NameCtrl,
      _eAccused2AgeCtrl,
      _eAccused2DetailsCtrl,
      _eIncidentSummaryCtrl,
      _eArrestedNameCtrl,
      _eArrestPsCtrl,
      _eArrestTimeCtrl,
      _eArrestDateCtrl,
      _eSdNoCtrl,
      _eCourtNameCtrl,
      _eRemandHoursCtrl,
      _eOfficerSigCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> collectData() {
    return {
      'formSection': widget.formSection ?? '',
      'pageRange': widget.pageRange ?? '',
      'variant': _isEnglish ? 'english' : 'marathi',
      'm1Date': _m1DateCtrl.text.trim(),
      'm1CourtName': _m1CourtNameCtrl.text.trim(),
      'm1CourtCity': _m1CourtCityCtrl.text.trim(),
      'm1CourtState': _m1CourtStateCtrl.text.trim(),
      'm1PsName': _m1PsNameCtrl.text.trim(),
      'm1PsCity': _m1PsCityCtrl.text.trim(),
      'm1PsState': _m1PsStateCtrl.text.trim(),
      'm1CrNo': _m1CrNoCtrl.text.trim(),
      'm1CrSections': _m1CrSectionsCtrl.text.trim(),
      'm1CrDateTime': _m1CrDateTimeCtrl.text.trim(),
      'm1AccusedName': _m1AccusedNameCtrl.text.trim(),
      'm1AccusedAge': _m1AccusedAgeCtrl.text.trim(),
      'm1AccusedAddress': _m1AccusedAddressCtrl.text.trim(),
      'm1ArrestDateTime': _m1ArrestDateTimeCtrl.text.trim(),
      'm1ArrestPlace': _m1ArrestPlaceCtrl.text.trim(),
      'm1Seizure': _m1SeizureCtrl.text.trim(),
      'm1RemandFrom': _m1RemandFromCtrl.text.trim(),
      'm1RemandDays': _m1RemandDaysCtrl.text.trim(),
      'm1ProduceCourt': _m1ProduceCourtCtrl.text.trim(),
      'm1OfficerName': _m1OfficerNameCtrl.text.trim(),
      'm1OfficerRank': _m1OfficerRankCtrl.text.trim(),
      'm1OfficerPs': _m1OfficerPsCtrl.text.trim(),
      'm1OfficerCity': _m1OfficerCityCtrl.text.trim(),
      'm1CourtRemark': _m1CourtRemarkCtrl.text.trim(),
      'm2Date': _m2DateCtrl.text.trim(),
      'm2RecipientPs': _m2RecipientPsCtrl.text.trim(),
      'm2RecipientAddress': _m2RecipientAddressCtrl.text.trim(),
      'm2RefCrNo': _m2RefCrNoCtrl.text.trim(),
      'm2RefSections': _m2RefSectionsCtrl.text.trim(),
      'm2AccusedName': _m2AccusedNameCtrl.text.trim(),
      'm2AccusedAge': _m2AccusedAgeCtrl.text.trim(),
      'm2AccusedAddress': _m2AccusedAddressCtrl.text.trim(),
      'm2OfficerName': _m2OfficerNameCtrl.text.trim(),
      'm2OfficerRank': _m2OfficerRankCtrl.text.trim(),
      'm2OfficerPs': _m2OfficerPsCtrl.text.trim(),
      'm2OfficerCity': _m2OfficerCityCtrl.text.trim(),
      'eOutwardNo': _eOutwardNoCtrl.text.trim(),
      'eDate': _eDateCtrl.text.trim(),
      'ePsName': _ePsNameCtrl.text.trim(),
      'eCourtToLine1': _eCourtToLine1Ctrl.text.trim(),
      'eCourtToLine2': _eCourtToLine2Ctrl.text.trim(),
      'eReportByName': _eReportByNameCtrl.text.trim(),
      'eReportByRank': _eReportByRankCtrl.text.trim(),
      'eSubjectHours': _eSubjectHoursCtrl.text.trim(),
      'eFirNo': _eFirNoCtrl.text.trim(),
      'eIpcSections': _eIpcSectionsCtrl.text.trim(),
      'eComplainantName': _eComplainantNameCtrl.text.trim(),
      'eComplainantAge': _eComplainantAgeCtrl.text.trim(),
      'eComplainantProfession': _eComplainantProfessionCtrl.text.trim(),
      'eComplainantAddress': _eComplainantAddressCtrl.text.trim(),
      'eAccused1Name': _eAccused1NameCtrl.text.trim(),
      'eAccused1Age': _eAccused1AgeCtrl.text.trim(),
      'eAccused1Details': _eAccused1DetailsCtrl.text.trim(),
      'eAccused2Name': _eAccused2NameCtrl.text.trim(),
      'eAccused2Age': _eAccused2AgeCtrl.text.trim(),
      'eAccused2Details': _eAccused2DetailsCtrl.text.trim(),
      'eIncidentSummary': _eIncidentSummaryCtrl.text.trim(),
      'eArrestedName': _eArrestedNameCtrl.text.trim(),
      'eArrestPs': _eArrestPsCtrl.text.trim(),
      'eArrestTime': _eArrestTimeCtrl.text.trim(),
      'eArrestDate': _eArrestDateCtrl.text.trim(),
      'eSdNo': _eSdNoCtrl.text.trim(),
      'eCourtName': _eCourtNameCtrl.text.trim(),
      'eRemandHours': _eRemandHoursCtrl.text.trim(),
      'eOfficerSig': _eOfficerSigCtrl.text.trim(),
    };
  }

  void hydrateFrom(Map<String, dynamic> data) {
    final map = {
      'm1Date': _m1DateCtrl,
      'm1CourtName': _m1CourtNameCtrl,
      'm1CourtCity': _m1CourtCityCtrl,
      'm1CourtState': _m1CourtStateCtrl,
      'm1PsName': _m1PsNameCtrl,
      'm1PsCity': _m1PsCityCtrl,
      'm1PsState': _m1PsStateCtrl,
      'm1CrNo': _m1CrNoCtrl,
      'm1CrSections': _m1CrSectionsCtrl,
      'm1CrDateTime': _m1CrDateTimeCtrl,
      'm1AccusedName': _m1AccusedNameCtrl,
      'm1AccusedAge': _m1AccusedAgeCtrl,
      'm1AccusedAddress': _m1AccusedAddressCtrl,
      'm1ArrestDateTime': _m1ArrestDateTimeCtrl,
      'm1ArrestPlace': _m1ArrestPlaceCtrl,
      'm1Seizure': _m1SeizureCtrl,
      'm1RemandFrom': _m1RemandFromCtrl,
      'm1RemandDays': _m1RemandDaysCtrl,
      'm1ProduceCourt': _m1ProduceCourtCtrl,
      'm1OfficerName': _m1OfficerNameCtrl,
      'm1OfficerRank': _m1OfficerRankCtrl,
      'm1OfficerPs': _m1OfficerPsCtrl,
      'm1OfficerCity': _m1OfficerCityCtrl,
      'm1CourtRemark': _m1CourtRemarkCtrl,
      'm2Date': _m2DateCtrl,
      'm2RecipientPs': _m2RecipientPsCtrl,
      'm2RecipientAddress': _m2RecipientAddressCtrl,
      'm2RefCrNo': _m2RefCrNoCtrl,
      'm2RefSections': _m2RefSectionsCtrl,
      'm2AccusedName': _m2AccusedNameCtrl,
      'm2AccusedAge': _m2AccusedAgeCtrl,
      'm2AccusedAddress': _m2AccusedAddressCtrl,
      'm2OfficerName': _m2OfficerNameCtrl,
      'm2OfficerRank': _m2OfficerRankCtrl,
      'm2OfficerPs': _m2OfficerPsCtrl,
      'm2OfficerCity': _m2OfficerCityCtrl,
      'eOutwardNo': _eOutwardNoCtrl,
      'eDate': _eDateCtrl,
      'ePsName': _ePsNameCtrl,
      'eCourtToLine1': _eCourtToLine1Ctrl,
      'eCourtToLine2': _eCourtToLine2Ctrl,
      'eReportByName': _eReportByNameCtrl,
      'eReportByRank': _eReportByRankCtrl,
      'eSubjectHours': _eSubjectHoursCtrl,
      'eFirNo': _eFirNoCtrl,
      'eIpcSections': _eIpcSectionsCtrl,
      'eComplainantName': _eComplainantNameCtrl,
      'eComplainantAge': _eComplainantAgeCtrl,
      'eComplainantProfession': _eComplainantProfessionCtrl,
      'eComplainantAddress': _eComplainantAddressCtrl,
      'eAccused1Name': _eAccused1NameCtrl,
      'eAccused1Age': _eAccused1AgeCtrl,
      'eAccused1Details': _eAccused1DetailsCtrl,
      'eAccused2Name': _eAccused2NameCtrl,
      'eAccused2Age': _eAccused2AgeCtrl,
      'eAccused2Details': _eAccused2DetailsCtrl,
      'eIncidentSummary': _eIncidentSummaryCtrl,
      'eArrestedName': _eArrestedNameCtrl,
      'eArrestPs': _eArrestPsCtrl,
      'eArrestTime': _eArrestTimeCtrl,
      'eArrestDate': _eArrestDateCtrl,
      'eSdNo': _eSdNoCtrl,
      'eCourtName': _eCourtNameCtrl,
      'eRemandHours': _eRemandHoursCtrl,
      'eOfficerSig': _eOfficerSigCtrl,
    };
    for (final e in map.entries) {
      e.value.text = data[e.key]?.toString() ?? '';
    }
    if (mounted) setState(() {});
  }

  Widget _buildMarathiPage1(TextStyle serif, TextStyle marathiLabel) {
    return FormPaperPage(
      formLabel: widget.pageRange ?? 'Page 1',
      children: [
        BilingualSectionHeader(
          label: 'Requisition to Transit Remand',
          marathiLabel: 'ट्रान्झिट रिमांडची मागणी',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Date',
              marathiLabel: 'दिनांक',
              controller: _m1DateCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Court name',
              marathiLabel: 'न्यायालय',
              controller: _m1CourtNameCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Court city',
              marathiLabel: 'शहर',
              controller: _m1CourtCityCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Court state',
              marathiLabel: 'राज्य',
              controller: _m1CourtStateCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualField(
          label: 'Police station (originating)',
          marathiLabel: 'पोलीस ठाणे',
          controller: _m1PsNameCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'PS city',
              marathiLabel: 'शहर',
              controller: _m1PsCityCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'PS state',
              marathiLabel: 'राज्य',
              controller: _m1PsStateCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'C.R. No.',
              marathiLabel: 'ग.र.क्र.',
              controller: _m1CrNoCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Sections',
              marathiLabel: 'कलम',
              controller: _m1CrSectionsCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualField(
          label: 'CR registered date & time',
          marathiLabel: 'ग.र. नोंद दिनांक/वेळ',
          controller: _m1CrDateTimeCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualField(
          label: 'Accused name',
          marathiLabel: 'आरोपीचे नाव',
          controller: _m1AccusedNameCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Age',
              marathiLabel: 'वय',
              controller: _m1AccusedAgeCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Address',
              marathiLabel: 'पत्ता',
              controller: _m1AccusedAddressCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Arrest date & time',
              marathiLabel: 'अटक दिनांक/वेळ',
              controller: _m1ArrestDateTimeCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Arrest place',
              marathiLabel: 'अटक ठिकाण',
              controller: _m1ArrestPlaceCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualMultilineField(
          label: 'Seized property',
          marathiLabel: 'जप्त माल',
          controller: _m1SeizureCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
          minLines: 2,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Remand from date',
              marathiLabel: 'रिमांड दिनांकापासून',
              controller: _m1RemandFromCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Remand days',
              marathiLabel: 'दिवस',
              controller: _m1RemandDaysCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualField(
          label: 'Court to produce accused',
          marathiLabel: 'आरोपी सादर करण्याचे न्यायालय',
          controller: _m1ProduceCourtCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Officer name',
              marathiLabel: 'अधिकारी नाव',
              controller: _m1OfficerNameCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Rank',
              marathiLabel: 'हुद्दा',
              controller: _m1OfficerRankCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Police station',
              marathiLabel: 'पोलीस ठाणे',
              controller: _m1OfficerPsCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'City',
              marathiLabel: 'शहर',
              controller: _m1OfficerCityCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualMultilineField(
          label: 'Hon. Court remark',
          marathiLabel: 'मा. न्यायालयाची टिप्पणी',
          controller: _m1CourtRemarkCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
          minLines: 2,
        ),
      ],
    );
  }

  Widget _buildMarathiPage2(TextStyle serif, TextStyle marathiLabel) {
    return FormPaperPage(
      formLabel: widget.pageRange ?? 'Page 2',
      children: [
        BilingualSectionHeader(
          label: 'Police Assistance Request',
          marathiLabel: 'पोलीस सहाय्याची विनंती',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        BilingualField(
          label: 'Date',
          marathiLabel: 'दिनांक',
          controller: _m2DateCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualField(
          label: 'To — Sr. Police Inspector (recipient PS)',
          marathiLabel: 'प्रति — वरिष्ठ पोलीस निरीक्षक',
          controller: _m2RecipientPsCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualField(
          label: 'Recipient address',
          marathiLabel: 'पत्ता',
          controller: _m2RecipientAddressCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Ref. CR No.',
              marathiLabel: 'संदर्भ ग.र.क्र.',
              controller: _m2RefCrNoCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Sections',
              marathiLabel: 'कलम',
              controller: _m2RefSectionsCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualField(
          label: 'Wanted accused name',
          marathiLabel: 'फरार आरोपीचे नाव',
          controller: _m2AccusedNameCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Age',
              marathiLabel: 'वय',
              controller: _m2AccusedAgeCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Address',
              marathiLabel: 'पत्ता',
              controller: _m2AccusedAddressCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Officer name',
              marathiLabel: 'अधिकारी नाव',
              controller: _m2OfficerNameCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Rank',
              marathiLabel: 'हुद्दा',
              controller: _m2OfficerRankCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Police station',
              marathiLabel: 'पोलीस ठाणे',
              controller: _m2OfficerPsCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'City',
              marathiLabel: 'शहर',
              controller: _m2OfficerCityCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnglishPage(TextStyle serif, TextStyle marathiLabel) {
    return FormPaperPage(
      formLabel: widget.pageRange ?? 'Page 1',
      children: [
        BilingualSectionHeader(
          label: 'Requisition to Transit Remand',
          marathiLabel: 'ट्रान्झिट रिमांड अर्ज',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Outward No.',
              marathiLabel: 'जावक क्र.',
              controller: _eOutwardNoCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Date',
              marathiLabel: 'दिनांक',
              controller: _eDateCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualField(
          label: 'Police Station',
          marathiLabel: 'पोलीस ठाणे',
          controller: _ePsNameCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualField(
          label: 'To — Hon. Court (line 1)',
          marathiLabel: 'प्रति — मा. न्यायालय',
          controller: _eCourtToLine1Ctrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualField(
          label: 'To — Hon. Court (line 2)',
          marathiLabel: 'प्रति — (पुढील ओळ)',
          controller: _eCourtToLine2Ctrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Report by (name)',
              marathiLabel: 'अहवाल सादर',
              controller: _eReportByNameCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Rank',
              marathiLabel: 'हुद्दा',
              controller: _eReportByRankCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualField(
          label: 'Subject — transit remand (hours)',
          marathiLabel: 'विषय — ट्रान्झिट रिमांड (तास)',
          controller: _eSubjectHoursCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'FIR No.',
              marathiLabel: 'FIR क्र.',
              controller: _eFirNoCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'IPC / BNS sections',
              marathiLabel: 'कलम',
              controller: _eIpcSectionsCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualSectionHeader(
          label: 'Complainant',
          marathiLabel: 'फिर्यादी',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualField(
          label: 'Name',
          marathiLabel: 'नाव',
          controller: _eComplainantNameCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Age',
              marathiLabel: 'वय',
              controller: _eComplainantAgeCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Profession',
              marathiLabel: 'व्यवसाय',
              controller: _eComplainantProfessionCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualField(
          label: 'Address',
          marathiLabel: 'पत्ता',
          controller: _eComplainantAddressCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualSectionHeader(
          label: 'Accused persons',
          marathiLabel: 'आरोपी',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Accused 1 name',
              marathiLabel: 'आरोपी १ नाव',
              controller: _eAccused1NameCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Age',
              marathiLabel: 'वय',
              controller: _eAccused1AgeCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualField(
          label: 'Accused 1 details',
          marathiLabel: 'आरोपी १ तपशील',
          controller: _eAccused1DetailsCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Accused 2 name',
              marathiLabel: 'आरोपी २ नाव',
              controller: _eAccused2NameCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Age',
              marathiLabel: 'वय',
              controller: _eAccused2AgeCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualField(
          label: 'Accused 2 details',
          marathiLabel: 'आरोपी २ तपशील',
          controller: _eAccused2DetailsCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualMultilineField(
          label: 'Incident summary',
          marathiLabel: 'गुन्ह्याचा सारांश',
          controller: _eIncidentSummaryCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
          minLines: 4,
        ),
        BilingualSectionHeader(
          label: 'Arrest & remand request',
          marathiLabel: 'अटक व रिमांड विनंती',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualField(
          label: 'Arrested accused name',
          marathiLabel: 'अटक केलेल्या आरोपीचे नाव',
          controller: _eArrestedNameCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Arrest PS',
              marathiLabel: 'अटक ठाणे',
              controller: _eArrestPsCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'SD No.',
              marathiLabel: 'SD क्र.',
              controller: _eSdNoCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Arrest date',
              marathiLabel: 'अटक दिनांक',
              controller: _eArrestDateCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Arrest time',
              marathiLabel: 'अटक वेळ',
              controller: _eArrestTimeCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualField(
          label: 'Court name',
          marathiLabel: 'न्यायालय',
          controller: _eCourtNameCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualField(
          label: 'Transit remand (hours)',
          marathiLabel: 'ट्रान्झिट रिमांड (तास)',
          controller: _eRemandHoursCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualField(
          label: 'Officer signature',
          marathiLabel: 'अधिकारी सही',
          controller: _eOfficerSigCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final serif = FormTypography.serifStyle();
    final marathiLabel = FormTypography.marathiLabelStyle();

    final pages = <Widget>[];
    if (_isEnglish) {
      pages.add(_buildEnglishPage(serif, marathiLabel));
    } else {
      if (_showMarathiPage1) {
        pages.add(_buildMarathiPage1(serif, marathiLabel));
        if (_showMarathiPage2) pages.add(const SizedBox(height: 24));
      }
      if (_showMarathiPage2) {
        pages.add(_buildMarathiPage2(serif, marathiLabel));
      }
    }

    return FormViewScaffold(readOnly: widget.readOnly, children: pages);
  }
}
