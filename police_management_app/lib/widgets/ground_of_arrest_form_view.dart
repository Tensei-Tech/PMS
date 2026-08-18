import 'package:flutter/material.dart';

import 'bilingual_field.dart';
import 'form_paper_page.dart';
import 'form_typography.dart';
import 'form_view_scaffold.dart';
import '../utils/form_io_terminology.dart';

/// Ground of Arrest notice u/s 47(1)(2) BNSS — 2 pages.
class GroundOfArrestFormView extends StatefulWidget {
  final bool readOnly;
  final String? formSection;
  final String? pageRange;

  const GroundOfArrestFormView({
    super.key,
    this.readOnly = false,
    this.formSection,
    this.pageRange,
  });

  @override
  State<GroundOfArrestFormView> createState() => GroundOfArrestFormViewState();
}

class GroundOfArrestFormViewState extends State<GroundOfArrestFormView> {
  bool get _showMain {
    final s = widget.formSection?.toLowerCase() ?? '';
    if (s.isEmpty) return true;
    return s.contains('main') && !s.contains('continuation');
  }

  bool get _showContinuation {
    final s = widget.formSection?.toLowerCase() ?? '';
    if (s.isEmpty) return true;
    return s.contains('continuation');
  }

  // Page 1
  final _outwardNoCtrl = TextEditingController();
  final _outwardYearCtrl = TextEditingController(text: '2025');
  final _policeStationCtrl = TextEditingController();
  final _talukaCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _noticeDateCtrl = TextEditingController();
  final _accusedNameAddressCtrl = TextEditingController();
  final _subjectPsCtrl = TextEditingController();
  final _subjectCrNoCtrl = TextEditingController();
  final _subjectSectionCtrl = TextEditingController();
  final _subjectBnsCtrl = TextEditingController();
  final _ioNameCtrl = TextEditingController();
  final _briefDescriptionCtrl = TextEditingController();

  // Page 2
  final _ground1Ctrl = TextEditingController();
  final _ground2Ctrl = TextEditingController();
  final _ground3Ctrl = TextEditingController();
  final _ground4Ctrl = TextEditingController();
  final _ground5Ctrl = TextEditingController();
  final _relativeNameCtrl = TextEditingController();
  final _relativeAddressCtrl = TextEditingController();
  final _relativePhoneCtrl = TextEditingController();
  final _accusedSigCtrl = TextEditingController();
  final _accusedNameSigCtrl = TextEditingController();
  final _accusedDateTimeCtrl = TextEditingController();
  final _ioSigCtrl = TextEditingController();
  final _ioNameRankCtrl = TextEditingController();
  final _ioPsCtrl = TextEditingController();
  final _ioTalukaCtrl = TextEditingController();
  final _ioDistrictCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _outwardNoCtrl,
      _outwardYearCtrl,
      _policeStationCtrl,
      _talukaCtrl,
      _districtCtrl,
      _noticeDateCtrl,
      _accusedNameAddressCtrl,
      _subjectPsCtrl,
      _subjectCrNoCtrl,
      _subjectSectionCtrl,
      _subjectBnsCtrl,
      _ioNameCtrl,
      _briefDescriptionCtrl,
      _ground1Ctrl,
      _ground2Ctrl,
      _ground3Ctrl,
      _ground4Ctrl,
      _ground5Ctrl,
      _relativeNameCtrl,
      _relativeAddressCtrl,
      _relativePhoneCtrl,
      _accusedSigCtrl,
      _accusedNameSigCtrl,
      _accusedDateTimeCtrl,
      _ioSigCtrl,
      _ioNameRankCtrl,
      _ioPsCtrl,
      _ioTalukaCtrl,
      _ioDistrictCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> collectData() {
    return {
      'formSection': widget.formSection ?? '',
      'pageRange': widget.pageRange ?? '',
      'outwardNo': _outwardNoCtrl.text.trim(),
      'outwardYear': _outwardYearCtrl.text.trim(),
      'policeStation': _policeStationCtrl.text.trim(),
      'taluka': _talukaCtrl.text.trim(),
      'district': _districtCtrl.text.trim(),
      'noticeDate': _noticeDateCtrl.text.trim(),
      'accusedNameAddress': _accusedNameAddressCtrl.text.trim(),
      'subjectPs': _subjectPsCtrl.text.trim(),
      'subjectCrNo': _subjectCrNoCtrl.text.trim(),
      'subjectSection': _subjectSectionCtrl.text.trim(),
      'subjectBns': _subjectBnsCtrl.text.trim(),
      'ioName': _ioNameCtrl.text.trim(),
      'briefDescription': _briefDescriptionCtrl.text.trim(),
      'ground1': _ground1Ctrl.text.trim(),
      'ground2': _ground2Ctrl.text.trim(),
      'ground3': _ground3Ctrl.text.trim(),
      'ground4': _ground4Ctrl.text.trim(),
      'ground5': _ground5Ctrl.text.trim(),
      'relativeName': _relativeNameCtrl.text.trim(),
      'relativeAddress': _relativeAddressCtrl.text.trim(),
      'relativePhone': _relativePhoneCtrl.text.trim(),
      'accusedSig': _accusedSigCtrl.text.trim(),
      'accusedNameSig': _accusedNameSigCtrl.text.trim(),
      'accusedDateTime': _accusedDateTimeCtrl.text.trim(),
      'ioSig': _ioSigCtrl.text.trim(),
      'ioNameRank': _ioNameRankCtrl.text.trim(),
      'ioPs': _ioPsCtrl.text.trim(),
      'ioTaluka': _ioTalukaCtrl.text.trim(),
      'ioDistrict': _ioDistrictCtrl.text.trim(),
    };
  }

  void hydrateFrom(Map<String, dynamic> data) {
    void setCtrl(TextEditingController c, String key) {
      c.text = data[key]?.toString() ?? '';
    }

    for (final e in {
      'outwardNo': _outwardNoCtrl,
      'outwardYear': _outwardYearCtrl,
      'policeStation': _policeStationCtrl,
      'taluka': _talukaCtrl,
      'district': _districtCtrl,
      'noticeDate': _noticeDateCtrl,
      'accusedNameAddress': _accusedNameAddressCtrl,
      'subjectPs': _subjectPsCtrl,
      'subjectCrNo': _subjectCrNoCtrl,
      'subjectSection': _subjectSectionCtrl,
      'subjectBns': _subjectBnsCtrl,
      'ioName': _ioNameCtrl,
      'briefDescription': _briefDescriptionCtrl,
      'ground1': _ground1Ctrl,
      'ground2': _ground2Ctrl,
      'ground3': _ground3Ctrl,
      'ground4': _ground4Ctrl,
      'ground5': _ground5Ctrl,
      'relativeName': _relativeNameCtrl,
      'relativeAddress': _relativeAddressCtrl,
      'relativePhone': _relativePhoneCtrl,
      'accusedSig': _accusedSigCtrl,
      'accusedNameSig': _accusedNameSigCtrl,
      'accusedDateTime': _accusedDateTimeCtrl,
      'ioSig': _ioSigCtrl,
      'ioNameRank': _ioNameRankCtrl,
      'ioPs': _ioPsCtrl,
      'ioTaluka': _ioTalukaCtrl,
      'ioDistrict': _ioDistrictCtrl,
    }.entries) {
      setCtrl(e.value, e.key);
    }
    if (mounted) setState(() {});
  }

  Widget _buildPage1(TextStyle serif, TextStyle marathiLabel) {
    return FormPaperPage(
      formLabel: widget.pageRange ?? 'Page 1',
      children: [
        Center(
          child: Column(
            children: [
              Text(
                'Under Section 47(1)(2) BNSS, 2023',
                style: serif.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              Text(
                'भारतीय नागरिक सुरक्षा संहिता, २०२३ चे कलम ४७ (१)(२) अन्वये',
                style: marathiLabel.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('NOTICE / सूचनापत्र',
                  style: serif.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Outward No.',
              marathiLabel: 'जावक क्रमांक',
              controller: _outwardNoCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Year',
              marathiLabel: 'वर्ष',
              controller: _outwardYearCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        const SizedBox(height: 12),
        BilingualField(
          label: 'Police Station',
          marathiLabel: 'पोलीस स्टेशन',
          controller: _policeStationCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Taluka',
              marathiLabel: 'ता.',
              controller: _talukaCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'District',
              marathiLabel: 'जिल्हा',
              controller: _districtCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualField(
          label: 'Date',
          marathiLabel: 'दिनांक',
          controller: _noticeDateCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        BilingualMultilineField(
          label: 'To — Name & Address',
          marathiLabel: 'प्रति, नाव व पत्ता',
          controller: _accusedNameAddressCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
          minLines: 2,
        ),
        const SizedBox(height: 12),
        Text(
          'Subject: Grounds and reasons for arrest in CR No. (BNS)',
          style: serif.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Police Station',
              marathiLabel: 'पोलीस स्टेशन',
              controller: _subjectPsCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'CR No.',
              marathiLabel: 'गुन्हा रजि.क्र.',
              controller: _subjectCrNoCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Section',
              marathiLabel: 'कलम',
              controller: _subjectSectionCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'BNS',
              marathiLabel: 'भा.न्या.स.',
              controller: _subjectBnsCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualField(
          label: 'Investigating Officer',
          marathiLabel: 'तपासी अधिकारी',
          controller: _ioNameCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        BilingualMultilineField(
          label: 'Brief description of offences',
          marathiLabel: 'गुन्ह्यांचे संक्षिप्त विवरण',
          controller: _briefDescriptionCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
          minLines: 4,
        ),
      ],
    );
  }

  Widget _buildPage2(TextStyle serif, TextStyle marathiLabel) {
    return FormPaperPage(
      formLabel: widget.pageRange ?? 'Page 2',
      children: [
        BilingualSectionHeader(
          label: 'Grounds of Arrest',
          marathiLabel: 'अटक करण्यासाठी आधारभूत मुद्दे',
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 12),
        for (final e in [
          ('Ground 1', '१.', _ground1Ctrl),
          ('Ground 2', '२.', _ground2Ctrl),
          ('Ground 3', '३.', _ground3Ctrl),
          ('Ground 4', '४.', _ground4Ctrl),
          ('Ground 5', '५.', _ground5Ctrl),
        ]) ...[
          BilingualMultilineField(
            label: e.$1,
            marathiLabel: e.$2,
            controller: e.$3,
            serifStyle: serif,
            marathiLabelStyle: marathiLabel,
            minLines: 2,
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        Text(
          'Relative/friend informed of arrest (written notice / phone)',
          style: serif.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 8),
        BilingualFieldRow(
          fields: [
            BilingualField(
              label: 'Relative / friend name',
              marathiLabel: 'नातेवाईक/मित्र',
              controller: _relativeNameCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
            BilingualField(
              label: 'Address',
              marathiLabel: 'रा.',
              controller: _relativeAddressCtrl,
              serifStyle: serif,
              marathiLabelStyle: marathiLabel,
            ),
          ],
        ),
        BilingualField(
          label: 'Phone number',
          marathiLabel: 'फोन क्रमांक',
          controller: _relativePhoneCtrl,
          serifStyle: serif,
          marathiLabelStyle: marathiLabel,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('I have received the notice',
                      style: marathiLabel.copyWith(fontSize: 11)),
                  BilingualField(
                    label: 'Accused signature',
                    marathiLabel: 'आरोपीची सही',
                    controller: _accusedSigCtrl,
                    serifStyle: serif,
                    marathiLabelStyle: marathiLabel,
                  ),
                  BilingualField(
                    label: 'Accused name',
                    marathiLabel: 'आरोपीचे नाव',
                    controller: _accusedNameSigCtrl,
                    serifStyle: serif,
                    marathiLabelStyle: marathiLabel,
                  ),
                  BilingualField(
                    label: 'Date & time',
                    marathiLabel: 'दिनांक व वेळ',
                    controller: _accusedDateTimeCtrl,
                    serifStyle: serif,
                    marathiLabelStyle: marathiLabel,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BilingualField(
                    label: 'IO signature',
                    marathiLabel: '${FormIoTerminology.officer} — ${FormIoTerminology.signature}',
                    controller: _ioSigCtrl,
                    serifStyle: serif,
                    marathiLabelStyle: marathiLabel,
                  ),
                  BilingualField(
                    label: 'Name / rank',
                    marathiLabel: 'नाव/हुद्दा',
                    controller: _ioNameRankCtrl,
                    serifStyle: serif,
                    marathiLabelStyle: marathiLabel,
                  ),
                  BilingualField(
                    label: 'Police station',
                    marathiLabel: 'पोलीस स्टेशन',
                    controller: _ioPsCtrl,
                    serifStyle: serif,
                    marathiLabelStyle: marathiLabel,
                  ),
                  BilingualFieldRow(
                    fields: [
                      BilingualField(
                        label: 'Taluka',
                        marathiLabel: 'ता.',
                        controller: _ioTalukaCtrl,
                        serifStyle: serif,
                        marathiLabelStyle: marathiLabel,
                      ),
                      BilingualField(
                        label: 'District',
                        marathiLabel: 'जिल्हा',
                        controller: _ioDistrictCtrl,
                        serifStyle: serif,
                        marathiLabelStyle: marathiLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final serif = FormTypography.serifStyle();
    final marathiLabel = FormTypography.marathiLabelStyle();

    final pages = <Widget>[];
    if (_showMain) {
      pages.add(_buildPage1(serif, marathiLabel));
      if (_showContinuation) pages.add(const SizedBox(height: 24));
    }
    if (_showContinuation) {
      pages.add(_buildPage2(serif, marathiLabel));
    }

    return FormViewScaffold(readOnly: widget.readOnly, children: pages);
  }
}
