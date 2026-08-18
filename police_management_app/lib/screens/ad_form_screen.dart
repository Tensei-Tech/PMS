import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../modules/core/models/base_record.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../utils/app_constants.dart';
import '../widgets/base_form/base_form.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Theme colors
// ─────────────────────────────────────────────────────────────────────────────
const Color primaryDark = Color(0xFF0f172a);
const Color primaryMid = Color(0xFF1e293b);
const Color accentTeal = Color(0xFF0ea5e9);
const Color accentBlue = Color(0xFF3b82f6);
const Color accentGreen = Color(0xFF10b981);
const Color accentRed = Color(0xFFef4444);
const Color textPrimary = Color(0xFF1e293b);
const Color textSecondary = Color(0xFF64748b);
const Color textMuted = Color(0xFF94a3b8);
const Color inputBg = Color(0xFFf8fafc);
const Color inputBorder = Color(0xFFe2e8f0);
const Color cardBg = Color(0xFFffffff);
const Color pageBg = Color(0xFFf4f7f9);

// ─────────────────────────────────────────────────────────────────────────────
// ACT data
// ─────────────────────────────────────────────────────────────────────────────
// ignore: constant_identifier_names — public map symbol shared with downstream / Firestore payloads
const Map<String, Map<String, dynamic>> ACT_DATA = {
  'BNS': {
    'label': 'BNS, 2023',
    'hint': 'Applies to offences on or after 1 July 2024.',
    'sections': [
      {'val': '100', 'label': '100 - Culpable homicide', 'cat': 'BNS_C6'},
      {'val': '101', 'label': '101 - Murder', 'cat': 'BNS_C6'},
      {'val': '103', 'label': '103 - Punishment for murder', 'cat': 'BNS_C6'},
      {'val': '104', 'label': '104 - Murder by life convict', 'cat': 'BNS_C6'},
      {
        'val': '105',
        'label': '105 - Culpable homicide not amounting to murder',
        'cat': 'BNS_C6'
      },
      {
        'val': '106',
        'label': '106 - Causing death by negligence',
        'cat': 'BNS_C6'
      },
      {
        'val': '107',
        'label': '107 - Abetment of suicide of child',
        'cat': 'BNS_C6'
      },
      {'val': '108', 'label': '108 - Abetment of suicide', 'cat': 'BNS_C6'},
      {'val': '109', 'label': '109 - Attempt to murder', 'cat': 'BNS_C6'},
      {
        'val': '110',
        'label': '110 - Attempt to commit culpable homicide',
        'cat': 'BNS_C6'
      },
      {'val': '111', 'label': '111 - Organised crime', 'cat': 'BNS_C6'},
      {'val': '113', 'label': '113 - Terrorist act', 'cat': 'BNS_C6'},
      {'val': '114', 'label': '114 - Hurt', 'cat': 'BNS_C6'},
      {
        'val': '115',
        'label': '115 - Voluntarily causing hurt',
        'cat': 'BNS_C6'
      },
      {'val': '116', 'label': '116 - Grievous hurt', 'cat': 'BNS_C6'},
      {
        'val': '117',
        'label': '117 - Voluntarily causing grievous hurt',
        'cat': 'BNS_C6'
      },
      {
        'val': '118',
        'label': '118 - Hurt by dangerous weapons',
        'cat': 'BNS_C6'
      },
      {'val': '124', 'label': '124 - Grievous hurt by acid', 'cat': 'BNS_C6'},
      {'val': '125', 'label': '125 - Act endangering life', 'cat': 'BNS_C6'},
      {'val': '140', 'label': '140 - Kidnapping to murder', 'cat': 'BNS_C6'},
      {'val': '143', 'label': '143 - Trafficking of person', 'cat': 'BNS_C6'},
      {'val': '63', 'label': '63 - Rape', 'cat': 'BNS_C5'},
      {'val': '70', 'label': '70 - Gang rape', 'cat': 'BNS_C5'},
      {'val': '80', 'label': '80 - Dowry death', 'cat': 'BNS_C5'},
      {
        'val': '85',
        'label': '85 - Cruelty by husband or relatives',
        'cat': 'BNS_C5'
      },
      {'val': '303', 'label': '303 - Theft', 'cat': 'BNS_C17'},
      {'val': '309', 'label': '309 - Robbery', 'cat': 'BNS_C17'},
      {'val': '310', 'label': '310 - Dacoity', 'cat': 'BNS_C17'},
      {
        'val': '316',
        'label': '316 - Criminal breach of trust',
        'cat': 'BNS_C17'
      },
      {'val': '318', 'label': '318 - Cheating', 'cat': 'BNS_C17'},
      {'val': '336', 'label': '336 - Forgery', 'cat': 'BNS_C18'},
      {'val': '351', 'label': '351 - Criminal intimidation', 'cat': 'BNS_C19'},
    ],
  },
  'IPC': {
    'label': 'IPC, 1860',
    'hint': 'Applies to offences BEFORE 1 July 2024.',
    'sections': [
      {'val': '302', 'label': '302 - Murder', 'cat': '1'},
      {
        'val': '304',
        'label': '304 - Culpable homicide not amounting to murder',
        'cat': '1'
      },
      {
        'val': '304A',
        'label': '304A - Causing death by negligence',
        'cat': '1'
      },
      {'val': '307', 'label': '307 - Attempt to murder', 'cat': '1'},
      {'val': '376', 'label': '376 - Rape', 'cat': '3'},
      {'val': '379', 'label': '379 - Theft', 'cat': '2'},
      {'val': '392', 'label': '392 - Robbery', 'cat': '2'},
      {'val': '395', 'label': '395 - Dacoity', 'cat': '2'},
      {'val': '406', 'label': '406 - Criminal breach of trust', 'cat': '2'},
      {'val': '420', 'label': '420 - Cheating', 'cat': '2'},
    ],
  },
  'ARMS': {
    'label': 'Arms Act, 1959',
    'hint': 'Apply when illegal weapons or ammunition are seized.',
    'sections': [
      {
        'val': '3',
        'label': '3 - Licence required for Arms/Ammunition',
        'cat': '5'
      },
      {'val': '25', 'label': '25 - Unlawful Possession of Arms', 'cat': '5'},
      {'val': '27', 'label': '27 - Punishment for using arms', 'cat': '5'},
    ],
  },
  'NDPS': {
    'label': 'NDPS Act, 1985',
    'hint': 'Narcotics/drugs/psychotropic substances.',
    'sections': [
      {
        'val': '8',
        'label': '8 - Prohibition on production/sale/possession',
        'cat': '5'
      },
      {'val': '20', 'label': '20 - Offences relating to Cannabis', 'cat': '5'},
      {
        'val': '21',
        'label': '21 - Offences relating to manufactured drugs',
        'cat': '5'
      },
      {
        'val': '22',
        'label': '22 - Offences relating to psychotropic substances',
        'cat': '5'
      },
    ],
  },
  'POCSO': {
    'label': 'POCSO Act, 2012',
    'hint': 'Victim must be under 18 years.',
    'sections': [
      {'val': '3', 'label': '3 - Penetrative Sexual Assault', 'cat': '3'},
      {
        'val': '4',
        'label': '4 - Punishment for Penetrative Sexual Assault',
        'cat': '3'
      },
      {'val': '7', 'label': '7 - Sexual Assault', 'cat': '3'},
      {'val': '8', 'label': '8 - Punishment for Sexual Assault', 'cat': '3'},
    ],
  },
  'MCOCA': {
    'label': 'MCOCA, 1999',
    'hint': 'Requires SP-level sanction to invoke.',
    'sections': [
      {
        'val': '3(1)(i)',
        'label': '3(1)(i) - Organised Crime causing death',
        'cat': '5'
      },
      {'val': '3(2)', 'label': '3(2) - Abetment/Conspiracy', 'cat': '5'},
    ],
  },
  'MPDA': {
    'label': 'MPDA, 1981',
    'hint': 'Preventive Detention order.',
    'sections': [
      {
        'val': '3(1)',
        'label': '3(1) - Detention of dangerous person',
        'cat': '5'
      },
    ],
  },
  'IT': {
    'label': 'IT Act, 2000',
    'hint': 'Apply for cyber crimes and electronic fraud.',
    'sections': [
      {'val': '66', 'label': '66 - Computer Related Offences', 'cat': '5'},
      {'val': '66C', 'label': '66C - Identity Theft', 'cat': '5'},
      {
        'val': '66D',
        'label': '66D - Cheating by personation using computer',
        'cat': '5'
      },
      {
        'val': '67',
        'label': '67 - Publishing obscene material electronically',
        'cat': '5'
      },
    ],
  },
  'SC_ST': {
    'label': 'SC/ST (PoA) Act, 1989',
    'hint': 'Atrocity cases involving SC/ST victims.',
    'sections': [
      {
        'val': '3(1)(r)',
        'label': '3(1)(r) - Intentional insult/intimidation',
        'cat': '5'
      },
      {
        'val': '3(2)(v)',
        'label': '3(2)(v) - Murder/attempt on SC/ST member',
        'cat': '5'
      },
    ],
  },
};

class ADFormScreen extends StatefulWidget {
  /// When set (e.g. user tapped Edit on the A.D hub), form loads `ad_forms` / draft by AD No.
  final ModuleRecord? existingRecord;

  /// Routes to pop after successful submit (hub→form = 1; hub→detail→form = 2).
  final int popCountAfterSubmit;

  const ADFormScreen({
    super.key,
    this.existingRecord,
    this.popCountAfterSubmit = 1,
  });

  @override
  State<ADFormScreen> createState() => _ADFormScreenState();
}

class _ADFormScreenState extends State<ADFormScreen> {
  // Section 1
  final adNoController = TextEditingController();
  final crNoController = TextEditingController();
  final regDateController = TextEditingController();

  // Section 3 Crime Spot
  final spotVillageController = TextEditingController();
  final spotAreaController = TextEditingController();
  final spotAddressController = TextEditingController();

  // Section 4 Complainant KYC
  final compNameController = TextEditingController();
  final compAgeController = TextEditingController();
  String compGender = 'Male';
  final compOccController = TextEditingController();
  final compMobileController = TextEditingController();
  final compAadhaarController = TextEditingController();
  final compReligionController = TextEditingController();
  final compCasteController = TextEditingController();
  final compPanController = TextEditingController();

  // Section 5 Deceased
  List<Map<String, dynamic>> deceasedList = [];

  // Section 2 Charges
  int chargeCount = 0;
  Map<String, Map<String, dynamic>> chargeData = {};

  // Section 6 Cause of Death
  bool isUnknownDeath = false;
  String? causeOfDeath;
  final otherCauseController = TextEditingController();

  Map<String, Map<String, dynamic>> unknownFields = {
    'shodhPatrika': {'value': null, 'date': TextEditingController()},
    'gazette': {'value': null, 'date': TextEditingController()},
    'mediaPub': {'value': null, 'date': TextEditingController()},
    'dnaSent': {'value': null, 'date': TextEditingController()},
    'dnaReport': {'value': null, 'date': TextEditingController()},
    'funeralPolice': {'value': null, 'date': TextEditingController()},
    'funeralRelative': {'value': null, 'date': TextEditingController()},
  };

  final relNameController = TextEditingController();
  final relRelationController = TextEditingController();
  final relAgeController = TextEditingController();
  String relGender = 'Male';
  final relOccController = TextEditingController();
  final relMobileController = TextEditingController();
  final relAadhaarController = TextEditingController();
  final relReligionController = TextEditingController();
  final relCasteController = TextEditingController();
  final relPanController = TextEditingController();

  // Section 8 Case Responsibility
  String ioDesig = 'PSI';
  String regDesig = 'HC';
  final ioNameController = TextEditingController();
  final regNameController = TextEditingController();
  String? cctvValue;
  final cctvDateTimeController = TextEditingController();

  // Section 10 Procedural
  Map<String, bool> proceduralChecks = {
    'chkMemo': false,
    'chkPanchSpot': false,
    'chkInquest': false,
    'chkIdent': false,
    'chkSearch': false,
    'chkPersSearch': false,
    'chkExhumation': false,
  };
  Map<String, TextEditingController> proceduralDates = {
    'chkMemo': TextEditingController(),
    'chkPanchSpot': TextEditingController(),
    'chkInquest': TextEditingController(),
    'chkIdent': TextEditingController(),
    'chkSearch': TextEditingController(),
    'chkPersSearch': TextEditingController(),
    'chkExhumation': TextEditingController(),
  };
  String? eshakshValue;

  // Section 11 Seizures
  List<Map<String, dynamic>> seizureList = [];

  // Section 12 Technical
  final cdrSentController = TextEditingController();
  final cdrRecvController = TextEditingController();

  // Section 13 Scrutiny Pipeline
  final sdpoSendController = TextEditingController();
  final sdpoGrantController = TextEditingController();
  final appSendController = TextEditingController();
  final appGrantController = TextEditingController();
  final dcpSendController = TextEditingController();
  final dcpGrantController = TextEditingController();
  bool stepAppActive = false;
  bool stepDcpActive = false;

  // Shared
  List<String> peopleNames = [];
  String saveBarText = 'All changes unsaved';
  Timer? _syncDebounce;
  final _scrollController = ScrollController();
  final ValueNotifier<double> _scrollProgressNotifier = ValueNotifier<double>(0);

  final FirestoreService _caseFirestore = FirestoreService();
  /// Document id in `cases` collection (keeps hub list in sync with this form).
  String? _caseListDocId;
  bool _hydrating = false;

  StreamSubscription<Map<String, dynamic>?>? _adFormSub;
  StreamSubscription<Map<String, dynamic>?>? _adDraftSub;
  Map<String, dynamic>? _liveFormData;
  Map<String, dynamic>? _liveDraftData;
  bool _formSnapSeen = false;
  bool _draftSnapSeen = false;
  bool _initialHydrateDone = false;
  bool _hadAdDocument = false;
  bool _adDocumentDeleted = false;
  bool _remoteUpdateAvailable = false;
  Map<String, dynamic>? _pendingRemoteData;

  bool _onScrollNotification(ScrollNotification n) {
    final metrics = n.metrics;
    final maxExtent = metrics.maxScrollExtent;
    if (maxExtent <= 0) {
      if (_scrollProgressNotifier.value != 0) {
        _scrollProgressNotifier.value = 0;
      }
      return false;
    }
    final p = (metrics.pixels / maxExtent).clamp(0.0, 1.0);
    if ((p - _scrollProgressNotifier.value).abs() > 0.005) {
      _scrollProgressNotifier.value = p;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _caseListDocId = widget.existingRecord?.id;
    if (widget.existingRecord == null) {
      addDeceased();
    }
    if (widget.existingRecord != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startAdDocumentWatch();
      });
    }
  }

  DateTime _parseRegDate(String s) {
    final p = s.trim().split('/');
    if (p.length == 3) {
      final d = int.tryParse(p[0]);
      final m = int.tryParse(p[1]);
      final y = int.tryParse(p[2]);
      if (d != null && m != null && y != null) return DateTime(y, m, d);
    }
    return DateTime.now();
  }

  List<Map<String, dynamic>> _chargesListForPayload() {
    const romanNumerals = [
      'I',
      'II',
      'III',
      'IV',
      'V',
      'VI',
      'VII',
      'VIII',
      'IX',
      'X'
    ];
    return chargeData.entries.toList().asMap().entries.map((e) {
      final roman = e.key < romanNumerals.length
          ? romanNumerals[e.key]
          : '${e.key + 1}';
      final rawAct = e.value.value['act'] as dynamic;
      return {
        'roman': roman,
        'act': ACT_DATA['$rawAct']?['label'] ?? '$rawAct',
        'sections': (e.value.value['sections'] as Set<String>).toList(),
      };
    }).toList();
  }

  Map<String, dynamic> _chargeDataFirestoreMap() {
    return chargeData.map(
      (k, v) => MapEntry(
        k,
        {
          'act': v['act'],
          'sections': (v['sections'] as Set<String>).toList(),
        },
      ),
    );
  }

  List<Map<String, dynamic>> _deceasedPayloadList() {
    return deceasedList
        .map(
          (p) => {
            'name': (p['name'] as TextEditingController).text,
            'age': (p['age'] as TextEditingController).text,
            'gender': p['gender'],
            'occ': (p['occ'] as TextEditingController).text,
            'mobile': (p['mobile'] as TextEditingController).text,
            'aadhaar': (p['aadhaar'] as TextEditingController).text,
            'religion': (p['religion'] as TextEditingController).text,
            'caste': (p['caste'] as TextEditingController).text,
            'pan': (p['pan'] as TextEditingController).text,
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> _seizuresPayloadList() {
    return seizureList
        .map(
          (s) => {
            'desc': (s['desc'] as TextEditingController).text,
            'fromWhom': s['fromWhom'],
            'otherName': (s['otherName'] as TextEditingController).text,
          },
        )
        .toList();
  }

  /// Plain map suitable for Firestore + PDF (no FieldValue).
  Map<String, dynamic> buildAdDocumentMap({
    required String status,
    String? caseListDocId,
  }) {
    final auth = context.read<AuthProvider>();
    final prev = widget.existingRecord;
    final adNo = adNoController.text.trim();
    return {
      'adNo': adNo,
      'crNo': crNoController.text,
      'regDate': regDateController.text,
      'spotVillage': spotVillageController.text,
      'spotArea': spotAreaController.text,
      'spotAddress': spotAddressController.text,
      'compName': compNameController.text,
      'compAge': compAgeController.text,
      'compGender': compGender,
      'compOcc': compOccController.text,
      'compMobile': compMobileController.text,
      'compAadhaar': compAadhaarController.text,
      'compReligion': compReligionController.text,
      'compCaste': compCasteController.text,
      'compPan': compPanController.text,
      'deceased': _deceasedPayloadList(),
      'chargeData': _chargeDataFirestoreMap(),
      'charges': _chargesListForPayload(),
      'isUnknownDeath': isUnknownDeath,
      'causeOfDeath': causeOfDeath,
      'otherCause': otherCauseController.text,
      'unknownFields': unknownFields.map(
        (k, v) => MapEntry(k, {
          'value': v['value'],
          'date': (v['date'] as TextEditingController).text,
        }),
      ),
      'relName': relNameController.text,
      'relRelation': relRelationController.text,
      'relAge': relAgeController.text,
      'relGender': relGender,
      'relOcc': relOccController.text,
      'relMobile': relMobileController.text,
      'relAadhaar': relAadhaarController.text,
      'relReligion': relReligionController.text,
      'relCaste': relCasteController.text,
      'relPan': relPanController.text,
      'ioDesig': ioDesig,
      'ioName': ioNameController.text,
      'regDesig': regDesig,
      'regName': regNameController.text,
      'cctvValue': cctvValue,
      'cctvDateTime': cctvDateTimeController.text,
      'proceduralChecks': Map<String, bool>.from(proceduralChecks),
      'proceduralDates': proceduralDates.map(
        (k, v) => MapEntry(k, v.text),
      ),
      'eshakshValue': eshakshValue,
      'seizures': _seizuresPayloadList(),
      'cdrSent': cdrSentController.text,
      'cdrRecv': cdrRecvController.text,
      'sdpoSend': sdpoSendController.text,
      'sdpoGrant': sdpoGrantController.text,
      'appSend': appSendController.text,
      'appGrant': appGrantController.text,
      'dcpSend': dcpSendController.text,
      'dcpGrant': dcpGrantController.text,
      'stepAppActive': stepAppActive,
      'stepDcpActive': stepDcpActive,
      'peopleNames': List<String>.from(peopleNames),
      'caseListDocId': caseListDocId ?? _caseListDocId,
      'status': status,
      'stationName': prev?.stationName ?? auth.stationName,
      'createdBy': prev != null ? prev.createdBy : auth.uid,
      if (prev?.assignedOfficerUid != null)
        'assignedOfficerUid': prev!.assignedOfficerUid
      else if (auth.uid.isNotEmpty)
        'assignedOfficerUid': auth.uid,
    };
  }

  ModuleRecord _moduleRecordForCaseList() {
    final auth = context.read<AuthProvider>();
    final adNo = adNoController.text.trim();
    final id = _caseListDocId ??
        widget.existingRecord?.id ??
        const Uuid().v4();
    _caseListDocId = id;
    final village = spotVillageController.text.trim();
    final area = spotAreaController.text.trim();
    final addr = spotAddressController.text.trim();
    final location = addr.isNotEmpty
        ? addr
        : [village, area].where((s) => s.isNotEmpty).join(', ');
    final prev = widget.existingRecord;
    final regStr = regDateController.text.trim();
    final incident =
        regStr.isNotEmpty ? _parseRegDate(regStr) : prev?.incidentDate ?? DateTime.now();
    final title = 'AD — $adNo';
    final comp = compNameController.text.trim();
    final desc = [
      'Accidental Death case $adNo.',
      if (comp.isNotEmpty) 'Complainant: $comp',
    ].join(' ');
    return ModuleRecord(
      id: id,
      moduleKey: 'ad',
      title: title,
      caseNumber: adNo,
      description: desc,
      complainant: compNameController.text,
      accused: 'N/A',
      location: location,
      incidentDate: incident,
      priority: prev?.priority ?? 'Medium',
      status: prev?.status ?? 'Open',
      assignedOfficer: '$ioDesig ${ioNameController.text}'.trim(),
      createdAt: prev?.createdAt,
      extraFields: const {},
      stationName: auth.stationName,
      createdBy: prev != null ? prev.createdBy : auth.uid,
      assignedOfficerUid: prev?.assignedOfficerUid ??
          (auth.uid.isNotEmpty ? auth.uid : null),
    );
  }

  void _startAdDocumentWatch() {
    final rec = widget.existingRecord;
    if (rec == null) return;

    var adNo = rec.caseNumber.trim();
    if (adNo.isEmpty) {
      adNo = (rec.extraFields['adNo']?.toString() ?? '').trim();
    }
    if (adNo.isNotEmpty) {
      adNoController.text = adNo;
    }

    if (adNo.isEmpty) {
      _applyMinimalFromModuleRecord(rec);
      if (deceasedList.isEmpty) addDeceased();
      _initialHydrateDone = true;
      if (mounted) setState(() {});
      syncAllNames();
      return;
    }

    _adFormSub?.cancel();
    _adFormSub =
        _caseFirestore.watchDocumentData('ad_forms', adNo).listen((data) {
      _liveFormData = data;
      _formSnapSeen = true;
      _onAdStreamUpdate();
    });

    _adDraftSub?.cancel();
    _adDraftSub =
        _caseFirestore.watchDocumentData('ad_drafts', adNo).listen((data) {
      _liveDraftData = data;
      _draftSnapSeen = true;
      _onAdStreamUpdate();
    });
  }

  void _onAdStreamUpdate() {
    if (!mounted) return;

    if (_liveFormData != null) {
      _handleAdDocumentData(_liveFormData!);
      return;
    }
    if (!_formSnapSeen) return;

    if (_liveDraftData != null) {
      _handleAdDocumentData(_liveDraftData!);
      return;
    }
    if (!_draftSnapSeen) return;

    _handleNoAdDocument();
  }

  void _handleAdDocumentData(Map<String, dynamic> data) {
    _hadAdDocument = true;
    _adDocumentDeleted = false;

    if (!_initialHydrateDone) {
      _applyLoadedDocument(data);
      _initialHydrateDone = true;
      if (mounted) setState(() {});
      syncAllNames();
      return;
    }

    if (mounted) {
      setState(() {
        _remoteUpdateAvailable = true;
        _pendingRemoteData = Map<String, dynamic>.from(data);
      });
    }
  }

  void _handleNoAdDocument() {
    if (_initialHydrateDone && _hadAdDocument) {
      if (mounted) setState(() => _adDocumentDeleted = true);
      return;
    }
    if (_initialHydrateDone) return;

    final rec = widget.existingRecord;
    if (rec != null) {
      _applyMinimalFromModuleRecord(rec);
    }
    if (deceasedList.isEmpty) addDeceased();
    _initialHydrateDone = true;
    if (mounted) setState(() {});
    syncAllNames();
  }

  void _applyRemoteUpdate() {
    final data = _pendingRemoteData;
    if (data == null) return;
    _applyLoadedDocument(data);
    _remoteUpdateAvailable = false;
    _pendingRemoteData = null;
    if (mounted) setState(() {});
    syncAllNames();
  }

  void _dismissRemoteUpdate() {
    _remoteUpdateAvailable = false;
    _pendingRemoteData = null;
    if (mounted) setState(() {});
  }

  Widget _buildRemoteUpdateBanner() {
    if (!_remoteUpdateAvailable) return const SizedBox.shrink();
    return Material(
      color: accentBlue.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.sync_rounded, color: accentBlue, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'This record was updated by another officer.',
                style: TextStyle(fontSize: 12, color: textPrimary),
              ),
            ),
            TextButton(
              onPressed: _dismissRemoteUpdate,
              child: const Text('Dismiss', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: _applyRemoteUpdate,
              child: const Text(
                'Reload',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdDocumentDeletedBanner() {
    if (!_adDocumentDeleted) return const SizedBox.shrink();
    return Material(
      color: accentRed.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: accentRed, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'The A.D form document was removed remotely.',
                style: TextStyle(fontSize: 12, color: textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyMinimalFromModuleRecord(ModuleRecord rec) {
    if (rec.caseNumber.trim().isNotEmpty) {
      adNoController.text = rec.caseNumber.trim();
    }
    regDateController.text = _formatDateDdMmYyyy(rec.incidentDate);
    compNameController.text = rec.complainant;
    spotAddressController.text = rec.location;
    ioNameController.text = rec.assignedOfficer;
  }

  void _applyLoadedDocument(Map<String, dynamic> d) {
    _hydrating = true;
    _syncDebounce?.cancel();

    String? actKeyFromStoredLabel(String label) {
      for (final e in ACT_DATA.entries) {
        if (e.value['label'] == label) return e.key;
      }
      return null;
    }

    final cid = d['caseListDocId']?.toString();
    if (cid != null && cid.isNotEmpty) _caseListDocId = cid;

    adNoController.text = d['adNo']?.toString() ?? adNoController.text;
    crNoController.text = d['crNo']?.toString() ?? '';
    regDateController.text = d['regDate']?.toString() ?? '';
    spotVillageController.text = d['spotVillage']?.toString() ?? '';
    spotAreaController.text = d['spotArea']?.toString() ?? '';
    spotAddressController.text = d['spotAddress']?.toString() ?? '';

    compNameController.text = d['compName']?.toString() ?? '';
    compAgeController.text = d['compAge']?.toString() ?? '';
    compGender = d['compGender']?.toString() ?? compGender;
    compOccController.text = d['compOcc']?.toString() ?? '';
    compMobileController.text = d['compMobile']?.toString() ?? '';
    compAadhaarController.text = d['compAadhaar']?.toString() ?? '';
    compReligionController.text = d['compReligion']?.toString() ?? '';
    compCasteController.text = d['compCaste']?.toString() ?? '';
    compPanController.text = d['compPan']?.toString() ?? '';

    _disposeDeceasedList();
    deceasedList = [];
    final decRaw = d['deceased'];
    if (decRaw is List && decRaw.isNotEmpty) {
      for (final item in decRaw) {
        if (item is! Map) continue;
        final m = Map<String, dynamic>.from(item);
        deceasedList.add({
          'name': TextEditingController(text: m['name']?.toString() ?? ''),
          'age': TextEditingController(text: m['age']?.toString() ?? ''),
          'gender': m['gender']?.toString() ?? 'Male',
          'occ': TextEditingController(text: m['occ']?.toString() ?? ''),
          'mobile': TextEditingController(text: m['mobile']?.toString() ?? ''),
          'aadhaar':
              TextEditingController(text: m['aadhaar']?.toString() ?? ''),
          'religion':
              TextEditingController(text: m['religion']?.toString() ?? ''),
          'caste': TextEditingController(text: m['caste']?.toString() ?? ''),
          'pan': TextEditingController(text: m['pan']?.toString() ?? ''),
        });
      }
    }
    if (deceasedList.isEmpty) {
      deceasedList.add({
        'name': TextEditingController(),
        'age': TextEditingController(),
        'gender': 'Male',
        'occ': TextEditingController(),
        'mobile': TextEditingController(),
        'aadhaar': TextEditingController(),
        'religion': TextEditingController(),
        'caste': TextEditingController(),
        'pan': TextEditingController(),
      });
    }

    chargeData.clear();
    final cdRaw = d['chargeData'];
    if (cdRaw is Map) {
      int maxN = 0;
      for (final e in cdRaw.entries) {
        final key = e.key.toString();
        final v = e.value;
        if (v is! Map) continue;
        final vm = Map<String, dynamic>.from(v);
        final secsRaw = vm['sections'];
        final set = secsRaw is List
            ? Set<String>.from(secsRaw.map((x) => x.toString()))
            : <String>{};
        chargeData[key] = {
          'act': vm['act'] ?? '',
          'sections': set,
        };
        final n = int.tryParse(key.replaceFirst(RegExp(r'^charge-'), ''));
        if (n != null && n > maxN) maxN = n;
      }
      chargeCount = maxN;
    }
    if (chargeData.isEmpty && d['charges'] is List) {
      var i = 0;
      for (final c in d['charges'] as List) {
        if (c is! Map) continue;
        i++;
        final m = Map<String, dynamic>.from(c);
        final label = m['act']?.toString() ?? '';
        final actKey = actKeyFromStoredLabel(label) ?? '';
        final secsRaw = m['sections'];
        final set = secsRaw is List
            ? Set<String>.from(secsRaw.map((x) => x.toString()))
            : <String>{};
        chargeData['charge-$i'] = {
          'act': actKey,
          'sections': set,
        };
      }
      if (i > chargeCount) chargeCount = i;
    }

    isUnknownDeath = d['isUnknownDeath'] == true;
    if (d['isUnknownDeath'] == null &&
        d['causeOfDeath']?.toString().toLowerCase() == 'unknown') {
      isUnknownDeath = true;
    }
    causeOfDeath = d['causeOfDeath']?.toString();
    otherCauseController.text = d['otherCause']?.toString() ?? '';

    final uRaw = d['unknownFields'];
    if (uRaw is Map) {
      for (final key in unknownFields.keys) {
        final entry = uRaw[key];
        if (entry is Map) {
          unknownFields[key]!['value'] = entry['value'];
          (unknownFields[key]!['date'] as TextEditingController).text =
              entry['date']?.toString() ?? '';
        }
      }
    }

    relNameController.text = d['relName']?.toString() ?? '';
    relRelationController.text = d['relRelation']?.toString() ?? '';
    relAgeController.text = d['relAge']?.toString() ?? '';
    relGender = d['relGender']?.toString() ?? relGender;
    relOccController.text = d['relOcc']?.toString() ?? '';
    relMobileController.text = d['relMobile']?.toString() ?? '';
    relAadhaarController.text = d['relAadhaar']?.toString() ?? '';
    relReligionController.text = d['relReligion']?.toString() ?? '';
    relCasteController.text = d['relCaste']?.toString() ?? '';
    relPanController.text = d['relPan']?.toString() ?? '';

    ioDesig = d['ioDesig']?.toString() ?? ioDesig;
    ioNameController.text = d['ioName']?.toString() ?? '';
    regDesig = d['regDesig']?.toString() ?? regDesig;
    regNameController.text = d['regName']?.toString() ?? '';
    cctvValue = d['cctvValue']?.toString();
    cctvDateTimeController.text = d['cctvDateTime']?.toString() ?? '';

    final pc = d['proceduralChecks'];
    if (pc is Map) {
      for (final e in proceduralChecks.keys.toList()) {
        final v = pc[e];
        if (v is bool) proceduralChecks[e] = v;
      }
    }
    final pd = d['proceduralDates'];
    if (pd is Map) {
      for (final e in proceduralDates.keys) {
        final t = pd[e]?.toString();
        if (t != null) proceduralDates[e]!.text = t;
      }
    }
    eshakshValue = d['eshakshValue']?.toString();

    _disposeSeizureList();
    seizureList = [];
    final szRaw = d['seizures'];
    if (szRaw is List) {
      for (final item in szRaw) {
        if (item is! Map) continue;
        final m = Map<String, dynamic>.from(item);
        seizureList.add({
          'desc': TextEditingController(text: m['desc']?.toString() ?? ''),
          'fromWhom': m['fromWhom']?.toString(),
          'otherName':
              TextEditingController(text: m['otherName']?.toString() ?? ''),
        });
      }
    }

    cdrSentController.text = d['cdrSent']?.toString() ?? '';
    cdrRecvController.text = d['cdrRecv']?.toString() ?? '';
    sdpoSendController.text = d['sdpoSend']?.toString() ?? '';
    sdpoGrantController.text = d['sdpoGrant']?.toString() ?? '';
    appSendController.text = d['appSend']?.toString() ?? '';
    appGrantController.text = d['appGrant']?.toString() ?? '';
    dcpSendController.text = d['dcpSend']?.toString() ?? '';
    dcpGrantController.text = d['dcpGrant']?.toString() ?? '';
    if (d['stepAppActive'] is bool) stepAppActive = d['stepAppActive'] as bool;
    if (d['stepDcpActive'] is bool) stepDcpActive = d['stepDcpActive'] as bool;

    final pn = d['peopleNames'];
    if (pn is List) {
      peopleNames = pn.map((e) => e.toString()).toList();
    }

    _hydrating = false;
  }

  void _disposeDeceasedList() {
    for (final p in deceasedList) {
      for (final e in [
        'name',
        'age',
        'occ',
        'mobile',
        'aadhaar',
        'religion',
        'caste',
        'pan'
      ]) {
        (p[e] as TextEditingController).dispose();
      }
    }
  }

  void _disposeSeizureList() {
    for (final s in seizureList) {
      (s['desc'] as TextEditingController).dispose();
      (s['otherName'] as TextEditingController).dispose();
    }
  }

  void _disposeUnknownFieldsDates() {
    for (final m in unknownFields.values) {
      (m['date'] as TextEditingController).dispose();
    }
  }

  void _disposeProceduralDates() {
    for (final c in proceduralDates.values) {
      c.dispose();
    }
  }

  void _disposeAllSectionControllersBeforeClear() {
    _disposeDeceasedList();
    _disposeSeizureList();
    _disposeUnknownFieldsDates();
    _disposeProceduralDates();
    unknownFields = {};
    proceduralDates = {};
    deceasedList = [];
    seizureList = [];
  }

  @override
  void dispose() {
    _adFormSub?.cancel();
    _adDraftSub?.cancel();
    _syncDebounce?.cancel();
    _scrollProgressNotifier.dispose();
    _scrollController.dispose();
    adNoController.dispose();
    crNoController.dispose();
    regDateController.dispose();
    spotVillageController.dispose();
    spotAreaController.dispose();
    spotAddressController.dispose();
    compNameController.dispose();
    compAgeController.dispose();
    compOccController.dispose();
    compMobileController.dispose();
    compAadhaarController.dispose();
    compReligionController.dispose();
    compCasteController.dispose();
    compPanController.dispose();
    otherCauseController.dispose();
    relNameController.dispose();
    relRelationController.dispose();
    relAgeController.dispose();
    relOccController.dispose();
    relMobileController.dispose();
    relAadhaarController.dispose();
    relReligionController.dispose();
    relCasteController.dispose();
    relPanController.dispose();
    ioNameController.dispose();
    regNameController.dispose();
    cctvDateTimeController.dispose();
    cdrSentController.dispose();
    cdrRecvController.dispose();
    sdpoSendController.dispose();
    sdpoGrantController.dispose();
    appSendController.dispose();
    appGrantController.dispose();
    dcpSendController.dispose();
    dcpGrantController.dispose();
    _disposeDeceasedList();
    _disposeSeizureList();
    _disposeUnknownFieldsDates();
    _disposeProceduralDates();
    super.dispose();
  }

  String _formatDateDdMmYyyy(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatDateTimeDdMmYyyyHhMm(DateTime d) =>
      '${_formatDateDdMmYyyy(d)} ${TimeOfDay(hour: d.hour, minute: d.minute).format(context)}';

  Future<DateTime?> _pickDate() async => showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

  Future<DateTime?> _pickDateThenTime(TextEditingController target,
      {VoidCallback? onComplete}) async {
    final pickedDate = await _pickDate();
    if (!mounted || pickedDate == null) return null;
    final tod = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (!mounted || tod == null) return null;
    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      tod.hour,
      tod.minute,
    );
    target.text = _formatDateTimeDdMmYyyyHhMm(combined);
    onComplete?.call();
    setState(() {});
    return combined;
  }

  InputDecoration _fieldDecor(String label) => BaseFormStyles.inputDecoration(label);

  Widget _responsiveGrid(BuildContext context, List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w > 700
            ? 3
            : w > 450
                ? 2
                : 1;
        const spacing = 16.0;
        const runSpacing = 14.0;
        final safeCols = cols < 1 ? 1 : cols;

        final rows = <Widget>[];
        for (var i = 0; i < fields.length; i += safeCols) {
          final end = i + safeCols > fields.length ? fields.length : i + safeCols;
          final chunk = fields.sublist(i, end);
          final rowChildren = <Widget>[];
          for (var j = 0; j < chunk.length; j++) {
            if (j > 0) rowChildren.add(const SizedBox(width: spacing));
            rowChildren.add(
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: chunk[j],
                ),
              ),
            );
          }
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowChildren,
            ),
          );
          if (end < fields.length) {
            rows.add(const SizedBox(height: runSpacing));
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: rows,
        );
      },
    );
  }

  Widget _fullWidth(Widget child) =>
      SizedBox(width: double.infinity, child: child);

  Widget _sectionCard(
      {required String title, Widget? action, required Widget content}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      color: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: accentTeal,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: primaryDark,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    fit: FlexFit.loose,
                    child: action,
                  ),
                ],
              ],
            ),
            const Divider(height: 24, color: Color(0xFFf1f5f9)),
            content,
          ],
        ),
      ),
    );
  }

  Widget _dynamicRowCard({
    Key? key,
    required String title,
    Color borderColor = accentTeal,
    required VoidCallback onRemove,
    required Widget content,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: inputBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            constraints: const BoxConstraints(minHeight: 80),
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: primaryDark,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onRemove,
                        icon:
                            const Icon(Icons.close, size: 14, color: accentRed),
                        label: const Text('Remove',
                            style: TextStyle(fontSize: 12, color: accentRed)),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  content,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _yesNoChip(
      String label, bool selected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : inputBg,
          border: Border.all(
            color: selected ? color : inputBorder,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? color : textSecondary,
          ),
        ),
      ),
    );
  }

  void addChargeRow() {
    chargeCount++;
    chargeData['charge-$chargeCount'] = {
      'act': '',
      'sections': <String>{},
    };
    setState(() {});
    debouncedSync();
  }

  void removeChargeRow(String id) {
    chargeData.remove(id);
    setState(() {});
    debouncedSync();
  }

  void onActChange(String id, String? act) {
    if (act == null) return;
    chargeData[id]!['act'] = act;
    chargeData[id]!['sections'] = <String>{};
    setState(() {});
    debouncedSync();
  }

  void onSectionAdd(String id, String val) {
    (chargeData[id]!['sections'] as Set<String>).add(val);
    setState(() {});
    debouncedSync();
  }

  void removeSection(String id, String val) {
    (chargeData[id]!['sections'] as Set<String>).remove(val);
    setState(() {});
    debouncedSync();
  }

  String _sectionDisplayLabel(String actKey, String val) {
    final sections =
        ACT_DATA[actKey]?['sections'] as List<dynamic>? ?? const [];
    for (final raw in sections) {
      final m = raw as Map<String, dynamic>;
      if ((m['val'] as String) == val) return m['label'] as String? ?? val;
    }
    return val;
  }

  Widget _buildChargeRow(String id, int num, Map<String, dynamic> data) {
    final actRaw = data['act']?.toString() ?? '';
    final actKey = actRaw.isEmpty ? null : actRaw;
    final selSections = (data['sections'] as Set<String>?) ?? {};
    final actLawItems = ACT_DATA.entries
        .map(
          (e) => DropdownMenuItem<String>(
            value: e.key,
            child: Text(e.value['label'] as String,
                overflow: TextOverflow.ellipsis),
          ),
        )
        .toList();
    final sectionItems = actKey == null
        ? const <DropdownMenuItem<String>>[]
        : (ACT_DATA[actKey]!['sections'] as List<dynamic>).map(
            (raw) {
              final m = raw as Map<String, dynamic>;
              final v = m['val'] as String;
              return DropdownMenuItem<String>(
                value: v,
                child: Text(m['label'] as String? ?? v,
                    overflow: TextOverflow.ellipsis),
              );
            },
          ).toList();

    return _dynamicRowCard(
      key: ValueKey('charge_$id'),
      title: 'Charge #$num',
      borderColor: accentBlue,
      onRemove: () => removeChargeRow(id),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _responsiveGrid(context, [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey('charge_act_${id}_$actRaw'),
                  isExpanded: true,
                  decoration: _fieldDecor('Act / Law'),
                  initialValue: actKey?.isEmpty ?? true ? null : actKey,
                  items: actLawItems,
                  onChanged: (v) => onActChange(id, v),
                ),
                if (actKey != null &&
                    ACT_DATA[actKey] != null &&
                    (ACT_DATA[actKey]!['hint'] as String?) != null &&
                    ACT_DATA[actKey]!['hint'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      ACT_DATA[actKey]!['hint'] as String,
                      style: const TextStyle(fontSize: 11, color: textMuted),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey(
                      'section_dd_${id}_${actKey ?? 'none'}_${selSections.length}'),
                  isExpanded: true,
                  decoration: _fieldDecor('Section(s) — tap to add'),
                  initialValue: null,
                  hint: const Text('Tap to add',
                      style: TextStyle(color: textMuted, fontSize: 12)),
                  items: sectionItems,
                  onChanged: actKey == null
                      ? null
                      : (v) {
                          if (v != null) onSectionAdd(id, v);
                        },
                ),
                if (selSections.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selSections
                          .map(
                            (v) => Chip(
                              backgroundColor:
                                  accentBlue.withValues(alpha: 0.12),
                              side: const BorderSide(color: accentBlue),
                              label: Text(
                                actKey != null
                                    ? _sectionDisplayLabel(actKey, v)
                                    : v,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: accentBlue,
                                    fontWeight: FontWeight.w600),
                              ),
                              deleteIcon: const Icon(Icons.close,
                                  size: 16, color: accentBlue),
                              onDeleted: () => removeSection(id, v),
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  Widget _chargeSummaryPanel() {
    final entries = chargeData.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'CHARGE SUMMARY',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textSecondary,
              letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        ...entries.map((e) {
          final actKey = e.value['act']?.toString() ?? '';
          final label =
              actKey.isNotEmpty ? (ACT_DATA[actKey]?['label'] ?? actKey) : '—';
          final secs = (e.value['sections'] as Set<String>?) ?? {};
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: cardBg,
                  border: Border.all(color: inputBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      constraints: const BoxConstraints(minHeight: 48),
                      decoration: const BoxDecoration(color: accentTeal),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: primaryDark)),
                            const SizedBox(height: 8),
                            ...secs.map(
                              (v) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ',
                                        style: TextStyle(
                                            color: accentTeal,
                                            fontWeight: FontWeight.w800)),
                                    Expanded(
                                      child: Text(
                                        actKey.isNotEmpty
                                            ? _sectionDisplayLabel(actKey, v)
                                            : v,
                                        style: const TextStyle(
                                            fontSize: 12, color: textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _section2Charges() {
    return _sectionCard(
      title: '2. ACTS & SECTIONS FILED',
      action: ElevatedButton.icon(
        onPressed: addChargeRow,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Charge',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (chargeData.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: textMuted.withValues(alpha: 0.45)),
              ),
              child: Column(
                children: [
                  Icon(Icons.gavel_outlined,
                      size: 40, color: textMuted.withValues(alpha: 0.6)),
                  const SizedBox(height: 12),
                  Text(
                    'No charges added. Tap Add Charge to begin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        color: textSecondary.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            )
          else
            ...chargeData.entries.toList().asMap().entries.map(
                  (indexed) => _buildChargeRow(
                      indexed.value.key, indexed.key + 1, indexed.value.value),
                ),
          if (chargeData.isNotEmpty) _chargeSummaryPanel(),
        ],
      ),
    );
  }

  void addDeceased() {
    deceasedList.add({
      'name': TextEditingController(),
      'age': TextEditingController(),
      'gender': 'Male',
      'occ': TextEditingController(),
      'mobile': TextEditingController(),
      'aadhaar': TextEditingController(),
      'religion': TextEditingController(),
      'caste': TextEditingController(),
      'pan': TextEditingController(),
    });
    setState(() {});
  }

  void syncAllNames() {
    final newNames = deceasedList
        .map((p) => (p['name'] as TextEditingController).text.trim())
        .where((n) => n.isNotEmpty)
        .toList();
    if (!listEquals(newNames, peopleNames)) {
      setState(() => peopleNames = newNames);
    }
  }

  Widget _buildUnknownCause() {
    final relGenderItems = const ['Male', 'Female', 'Other']
        .map((g) => DropdownMenuItem<String>(value: g, child: Text(g)))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildYesNoRow('shodhPatrika', 'Shodh Patrika'),
        _buildYesNoRow('gazette', 'Gazette'),
        _buildYesNoRow('mediaPub', 'Media Publication'),
        _buildYesNoRow('dnaSent', 'DNA sent to CA'),
        _buildYesNoRow('dnaReport', 'DNA report received'),
        _buildYesNoRow('funeralPolice', 'Body funeral by police'),
        _buildYesNoRow('funeralRelative', 'Body funeral by relative'),
        const Divider(height: 32, color: inputBorder),
        const Text(
          'RELATIVE DETAILS',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: primaryDark,
              letterSpacing: 1),
        ),
        const SizedBox(height: 14),
        _responsiveGrid(context, [
          TextFormField(
              controller: relNameController,
              decoration: _fieldDecor('Relative Name')),
          TextFormField(
              controller: relRelationController,
              decoration: _fieldDecor('Relation')),
          TextFormField(
            controller: relAgeController,
            keyboardType: TextInputType.number,
            decoration: _fieldDecor('Age'),
          ),
          DropdownButtonFormField<String>(
            key: ValueKey('relGender_$relGender'),
            isExpanded: true,
            decoration: _fieldDecor('Gender'),
            initialValue: relGender,
            items: relGenderItems,
            onChanged: (v) {
              if (v != null) setState(() => relGender = v);
            },
          ),
          TextFormField(
              controller: relOccController,
              decoration: _fieldDecor('Occupation')),
          TextFormField(
            controller: relMobileController,
            keyboardType: TextInputType.phone,
            decoration: _fieldDecor('Mobile Number'),
          ),
          TextFormField(
              controller: relAadhaarController,
              decoration: _fieldDecor('Aadhaar Number')),
          TextFormField(
              controller: relReligionController,
              decoration: _fieldDecor('Religion')),
          TextFormField(
              controller: relCasteController, decoration: _fieldDecor('Caste')),
          TextFormField(
              controller: relPanController,
              decoration: _fieldDecor('PAN Number')),
        ]),
      ],
    );
  }

  Widget _buildYesNoRow(String key, String label) {
    final m = unknownFields[key]!;
    final val = m['value'] as String?;

    Future<void> pickUnknownDate() async {
      final d = await _pickDate();
      if (!mounted || d == null) return;
      (m['date'] as TextEditingController).text = _formatDateDdMmYyyy(d);
      setState(() {});
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textPrimary),
                ),
              ),
              _yesNoChip(
                'Yes',
                val == 'yes',
                accentGreen,
                () {
                  unknownFields[key]!['value'] = 'yes';
                  setState(() {});
                },
              ),
              const SizedBox(width: 8),
              _yesNoChip(
                'No',
                val == 'no',
                accentRed,
                () {
                  unknownFields[key]!['value'] = 'no';
                  (unknownFields[key]!['date'] as TextEditingController)
                      .clear();
                  setState(() {});
                },
              ),
            ],
          ),
          if (val == 'yes') ...[
            const SizedBox(height: 10),
            TextFormField(
              readOnly: true,
              controller: m['date'] as TextEditingController,
              decoration: _fieldDecor('Date').copyWith(
                  suffixIcon: const Icon(Icons.calendar_today,
                      size: 18, color: textMuted)),
              onTap: pickUnknownDate,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStandardCause() {
    final causeItems = [
      'Hanging',
      'Drowning',
      'Burning',
      'Poisoning',
      'Electrocution',
      'Drug overdose',
      'Fall',
      'Snake bite',
      'Other causes',
    ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fullWidth(
          DropdownButtonFormField<String>(
            key: ValueKey('causeOfDeath_${causeOfDeath ?? 'nil'}'),
            isExpanded: true,
            decoration: _fieldDecor('Select Cause of Death'),
            initialValue: causeOfDeath,
            hint: const Text('Select Cause of Death',
                style: TextStyle(color: textMuted)),
            items: causeItems,
            onChanged: (v) => setState(() => causeOfDeath = v),
          ),
        ),
        if (causeOfDeath == 'Other causes') ...[
          const SizedBox(height: 14),
          _fullWidth(TextFormField(
              controller: otherCauseController,
              decoration: _fieldDecor('Specify Other Cause'))),
        ],
      ],
    );
  }

  Widget _scrutinyStep({
    required String title,
    required bool active,
    required TextEditingController sendCtrl,
    required TextEditingController grantCtrl,
    String? nextStep,
  }) {
    Future<void> onSendTap() async {
      if (!active) return;
      final d = await _pickDate();
      if (!mounted || d == null) return;
      sendCtrl.text = _formatDateDdMmYyyy(d);
      setState(() {});
    }

    Future<void> onGrantTap() async {
      if (!active) return;
      final d = await _pickDate();
      if (!mounted || d == null) return;
      grantCtrl.text = _formatDateDdMmYyyy(d);
      if (nextStep == 'APP') {
        stepAppActive = true;
      } else if (nextStep == 'DCP') {
        stepDcpActive = true;
      }
      setState(() {});
    }

    final dotGlow = BoxDecoration(
      shape: BoxShape.circle,
      color: active ? accentTeal.withValues(alpha: 0.2) : Colors.transparent,
      boxShadow: active
          ? [
              BoxShadow(
                  color: accentTeal.withValues(alpha: 0.55),
                  blurRadius: 12,
                  spreadRadius: 1),
            ]
          : null,
      border: Border.all(
          color: active ? accentTeal : inputBorder, width: active ? 2 : 1),
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: active ? 1.0 : 0.4,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: dotGlow.copyWith(shape: BoxShape.circle),
                    child: Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: active ? accentTeal : Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Container(width: 2, height: 64, color: inputBorder),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: primaryDark)),
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: 260,
                        child: TextFormField(
                          readOnly: true,
                          controller: sendCtrl,
                          enabled: active,
                          decoration: _fieldDecor('Send Date').copyWith(
                              suffixIcon: const Icon(Icons.calendar_today,
                                  size: 16, color: textMuted)),
                          onTap: onSendTap,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: TextFormField(
                          readOnly: true,
                          controller: grantCtrl,
                          enabled: active,
                          decoration: _fieldDecor('Grant Date').copyWith(
                              suffixIcon: const Icon(Icons.calendar_today,
                                  size: 16, color: textMuted)),
                          onTap: onGrantTap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProceduralLine(String key, String caption) {
    final dateCtrl = proceduralDates[key]!;
    return StatefulBuilder(
      builder: (context, localSet) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              value: proceduralChecks[key] ?? false,
              onChanged: (v) {
                final nv = v ?? false;
                localSet(() {
                  proceduralChecks[key] = nv;
                  if (!nv) dateCtrl.clear();
                });
                setState(() {});
              },
              title: Text(caption,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary)),
              activeColor: accentTeal,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            if (proceduralChecks[key] == true)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
                child: TextFormField(
                  controller: dateCtrl,
                  decoration: _fieldDecor('Date & Time').copyWith(
                    suffixIcon: const Icon(Icons.access_time,
                        size: 14, color: textMuted),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (!context.mounted || d == null) return;
                    final t = await showTimePicker(
                        context: context, initialTime: TimeOfDay.now());
                    if (!context.mounted || t == null) return;
                    final dateStr =
                        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${t.format(context)}';
                    localSet(() => dateCtrl.text = dateStr);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  void addSeizure() {
    seizureList.add({
      'desc': TextEditingController(),
      'fromWhom': null,
      'otherName': TextEditingController(),
    });
    setState(() {});
  }

  Widget _buildSection11() {
    return RepaintBoundary(
      child: _sectionCard(
        title: '11. SEIZURE RECORDS',
        action: ElevatedButton.icon(
          onPressed: addSeizure,
          style: ElevatedButton.styleFrom(backgroundColor: primaryDark),
          icon: const Icon(Icons.add),
          label: const Text('Add Property'),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (seizureList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: inputBorder),
                ),
                child: const Text('No seized property added',
                    style: TextStyle(fontSize: 13, color: textSecondary)),
              )
            else
              ...seizureList.asMap().entries.map((indexed) {
                final i = indexed.key;
                final s = indexed.value;
                final fromWhomItems = <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Select Deceased',
                        style: TextStyle(fontSize: 12, color: textMuted)),
                  ),
                  ...peopleNames.map((n) =>
                      DropdownMenuItem<String?>(value: n, child: Text(n))),
                ];
                return _dynamicRowCard(
                  key: ValueKey('seizure_$i'),
                  title: 'Seized Property #${i + 1}',
                  borderColor: accentTeal,
                  onRemove: () {
                    (s['desc'] as TextEditingController).dispose();
                    (s['otherName'] as TextEditingController).dispose();
                    seizureList.removeAt(i);
                    setState(() {});
                  },
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fullWidth(
                        TextFormField(
                            controller: s['desc'] as TextEditingController,
                            decoration: _fieldDecor('Property Description')),
                      ),
                      const SizedBox(height: 12),
                      _responsiveGrid(context, [
                        DropdownButtonFormField<String?>(
                          key: ValueKey('fromWhom_${i}_${s['fromWhom']}'),
                          isExpanded: true,
                          decoration: _fieldDecor('From Whom (Deceased)'),
                          initialValue: s['fromWhom'] as String?,
                          hint: const Text('Select Deceased',
                              style: TextStyle(fontSize: 12, color: textMuted)),
                          items: fromWhomItems,
                          onChanged: (v) {
                            setState(() => s['fromWhom'] = v);
                          },
                        ),
                        TextFormField(
                          controller: s['otherName'] as TextEditingController,
                          decoration:
                              _fieldDecor('Other Name (if not in list)'),
                        ),
                      ]),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveBar() {
    Future<void> runClearDraft() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Clear Form'),
          content: const Text('Discard all entered data on this screen?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Clear', style: TextStyle(color: accentRed))),
          ],
        ),
      );
      if (confirmed == true) await clearForm();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final wide = constraints.maxWidth > 500;
            if (wide) {
              return Row(
                children: [
                  Expanded(
                      child: Text(saveBarText,
                          style: const TextStyle(
                              color: textSecondary,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis)),
                  OutlinedButton(
                    onPressed: runClearDraft,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: accentRed,
                        side: const BorderSide(color: accentRed)),
                    child: const Text('CLEAR'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: saveDraft,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: textSecondary,
                        side: const BorderSide(color: inputBorder)),
                    child: const Text('SAVE DRAFT'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: submitForm,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDark,
                        foregroundColor: Colors.white),
                    icon: const Icon(Icons.save_alt, size: 18),
                    label: const Text('SUBMIT',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: Text(
                    saveBarText,
                    style: const TextStyle(
                        color: textSecondary, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.delete_outline, color: accentRed),
                  onPressed: runClearDraft,
                ),
                IconButton(
                  tooltip: 'Save Draft',
                  icon: const Icon(Icons.save_outlined, color: textSecondary),
                  onPressed: saveDraft,
                ),
                ElevatedButton(
                  onPressed: submitForm,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDark,
                      foregroundColor: Colors.white),
                  child: const Text('SUBMIT',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void debouncedSync() {
    if (_hydrating) return;
    _syncDebounce?.cancel();
    _syncDebounce =
        Timer(const Duration(milliseconds: 800), syncChargesToCaseItoV);
  }

  Future<void> syncChargesToCaseItoV() async {
    if (_hydrating) return;
    final adNo = adNoController.text.trim();
    if (adNo.isEmpty) return;
    const romanNumerals = [
      'I',
      'II',
      'III',
      'IV',
      'V',
      'VI',
      'VII',
      'VIII',
      'IX',
      'X'
    ];
    final payload = chargeData.entries
        .toList()
        .asMap()
        .entries
        .where((e) => e.value.value['act'].toString().isNotEmpty)
        .map((e) {
      final roman =
          e.key < romanNumerals.length ? romanNumerals[e.key] : '${e.key + 1}';
      final rawAct = e.value.value['act'] as dynamic;
      return {
        'roman': roman,
        'act': ACT_DATA['$rawAct']?['label'] ?? '$rawAct',
        'sections': (e.value.value['sections'] as Set<String>).toList(),
      };
    }).toList();
    try {
      final ref =
          FirebaseFirestore.instance.collection('case_itov').doc(adNo);
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final data = <String, dynamic>{
          'charges': payload,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (!snap.exists) {
          data['createdAt'] = FieldValue.serverTimestamp();
        }
        tx.set(ref, data, SetOptions(merge: true));
      });
    } catch (e) {
      debugPrint('Sync error: $e');
    }
  }

  Future<void> saveDraft() async {
    final adNo = adNoController.text.trim();
    if (adNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter AD No. first')));
      return;
    }
    try {
      final base = buildAdDocumentMap(status: 'draft', caseListDocId: _caseListDocId);
      await FirebaseFirestore.instance.collection('ad_drafts').doc(adNo).set({
        ...base,
        'savedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      setState(() =>
          saveBarText = 'Draft saved at ${TimeOfDay.now().format(context)}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Draft saved!'), backgroundColor: accentGreen));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Save failed: $e'), backgroundColor: accentRed));
    }
  }

  Future<void> submitForm() async {
    final adNo = adNoController.text.trim();
    if (adNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('AD No. is required'), backgroundColor: accentRed));
      return;
    }
    try {
      _caseListDocId = _caseListDocId ??
          widget.existingRecord?.id ??
          const Uuid().v4();

      final payload = buildAdDocumentMap(
        status: 'submitted',
        caseListDocId: _caseListDocId,
      );
      await FirebaseFirestore.instance.collection('ad_forms').doc(adNo).set({
        ...payload,
        'submittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('ad_drafts')
          .doc(adNo)
          .delete();

      await _caseFirestore.saveCase(_moduleRecordForCaseList());
      await syncChargesToCaseItoV();

      if (!mounted) return;
      setState(() => saveBarText = 'Submitted successfully!');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Form submitted!'),
          backgroundColor: accentGreen));
      if (Navigator.canPop(context)) {
        var left = widget.popCountAfterSubmit.clamp(1, 5);
        while (left > 0 && Navigator.canPop(context)) {
          Navigator.pop(context);
          left--;
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Submit failed: $e'), backgroundColor: accentRed));
    }
  }

  Future<void> clearForm() async {
    _disposeAllSectionControllersBeforeClear();

    unknownFields = {
      'shodhPatrika': {'value': null, 'date': TextEditingController()},
      'gazette': {'value': null, 'date': TextEditingController()},
      'mediaPub': {'value': null, 'date': TextEditingController()},
      'dnaSent': {'value': null, 'date': TextEditingController()},
      'dnaReport': {'value': null, 'date': TextEditingController()},
      'funeralPolice': {'value': null, 'date': TextEditingController()},
      'funeralRelative': {'value': null, 'date': TextEditingController()},
    };
    proceduralDates = {
      'chkMemo': TextEditingController(),
      'chkPanchSpot': TextEditingController(),
      'chkInquest': TextEditingController(),
      'chkIdent': TextEditingController(),
      'chkSearch': TextEditingController(),
      'chkPersSearch': TextEditingController(),
      'chkExhumation': TextEditingController(),
    };

    adNoController.clear();
    crNoController.clear();
    regDateController.clear();
    spotVillageController.clear();
    spotAreaController.clear();
    spotAddressController.clear();
    compNameController.clear();
    compAgeController.clear();
    compGender = 'Male';
    compOccController.clear();
    compMobileController.clear();
    compAadhaarController.clear();
    compReligionController.clear();
    compCasteController.clear();
    compPanController.clear();
    chargeCount = 0;
    chargeData = {};
    isUnknownDeath = false;
    causeOfDeath = null;
    otherCauseController.clear();
    relNameController.clear();
    relRelationController.clear();
    relAgeController.clear();
    relGender = 'Male';
    relOccController.clear();
    relMobileController.clear();
    relAadhaarController.clear();
    relReligionController.clear();
    relCasteController.clear();
    relPanController.clear();
    ioDesig = 'PSI';
    regDesig = 'HC';
    ioNameController.clear();
    regNameController.clear();
    cctvValue = null;
    cctvDateTimeController.clear();
    eshakshValue = null;
    proceduralChecks = {
      'chkMemo': false,
      'chkPanchSpot': false,
      'chkInquest': false,
      'chkIdent': false,
      'chkSearch': false,
      'chkPersSearch': false,
      'chkExhumation': false,
    };
    cdrSentController.clear();
    cdrRecvController.clear();
    sdpoSendController.clear();
    sdpoGrantController.clear();
    appSendController.clear();
    appGrantController.clear();
    dcpSendController.clear();
    dcpGrantController.clear();
    stepAppActive = false;
    stepDcpActive = false;
    peopleNames = [];

    setState(() => saveBarText = 'Form cleared');
    addDeceased();
    syncAllNames();
  }

  Widget _buildSection1() {
    return RepaintBoundary(
      child: _sectionCard(
        title: '1. AD REGISTRATION INFO',
        content: StandardFormFieldRow(
          children: [
            StandardTextField(label: 'AD No.', controller: adNoController),
            StandardTextField(
              label: 'Cr. No. (If applicable)',
              controller: crNoController,
            ),
            StandardDatePicker(
              label: 'Registered Date',
              controller: regDateController,
              lastDate: DateTime.now(),
              onDateChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection2() => RepaintBoundary(child: _section2Charges());

  Widget _buildSection3() {
    return RepaintBoundary(
      child: _sectionCard(
        title: '3. CRIME SPOT',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _responsiveGrid(
              context,
              [
                TextFormField(
                    controller: spotVillageController,
                    decoration: _fieldDecor('Village / Town')),
                TextFormField(
                    controller: spotAreaController,
                    decoration: _fieldDecor('Area Name')),
              ],
            ),
            const SizedBox(height: 14),
            _fullWidth(
              TextFormField(
                controller: spotAddressController,
                maxLines: 3,
                decoration: _fieldDecor('Full Address'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection4() {
    final compGenderItems = const ['Male', 'Female', 'Other']
        .map((g) => DropdownMenuItem<String>(value: g, child: Text(g)))
        .toList();
    return RepaintBoundary(
      child: _sectionCard(
        title: '4. COMPLAINANT KYC',
        content: _responsiveGrid(
          context,
          [
            TextFormField(
                controller: compNameController,
                decoration: _fieldDecor('Name')),
            TextFormField(
              controller: compAgeController,
              keyboardType: TextInputType.number,
              decoration: _fieldDecor('Age'),
            ),
            DropdownButtonFormField<String>(
              key: ValueKey(compGender),
              isExpanded: true,
              decoration: _fieldDecor('Gender'),
              initialValue: compGender,
              items: compGenderItems,
              onChanged: (v) => setState(() => compGender = v ?? compGender),
            ),
            TextFormField(
                controller: compOccController,
                decoration: _fieldDecor('Occupation')),
            TextFormField(
              controller: compMobileController,
              keyboardType: TextInputType.phone,
              decoration: _fieldDecor('Mobile Number'),
            ),
            TextFormField(
                controller: compAadhaarController,
                decoration: _fieldDecor('Aadhaar Number')),
            TextFormField(
                controller: compReligionController,
                decoration: _fieldDecor('Religion')),
            TextFormField(
                controller: compCasteController,
                decoration: _fieldDecor('Caste')),
            TextFormField(
                controller: compPanController,
                decoration: _fieldDecor('PAN Number')),
          ],
        ),
      ),
    );
  }

  Widget _buildSection5() {
    final deceasedGenderItems = const ['Male', 'Female', 'Other']
        .map((g) => DropdownMenuItem<String>(value: g, child: Text(g)))
        .toList();
    return RepaintBoundary(
      child: _sectionCard(
        title: '5. DECEASED KYC DETAILS',
        action: ElevatedButton.icon(
          onPressed: addDeceased,
          style: ElevatedButton.styleFrom(backgroundColor: primaryDark),
          icon: const Icon(Icons.add),
          label: const Text('Add Person'),
        ),
        content: Column(
          children: deceasedList.asMap().entries.map((indexed) {
            final i = indexed.key;
            final p = indexed.value;
            return _dynamicRowCard(
              key: ValueKey('deceased_$i'),
              title: 'Deceased Person #${i + 1}',
              borderColor: accentTeal,
              onRemove: () {
                (p['name'] as TextEditingController).dispose();
                (p['age'] as TextEditingController).dispose();
                (p['occ'] as TextEditingController).dispose();
                (p['mobile'] as TextEditingController).dispose();
                (p['aadhaar'] as TextEditingController).dispose();
                (p['religion'] as TextEditingController).dispose();
                (p['caste'] as TextEditingController).dispose();
                (p['pan'] as TextEditingController).dispose();
                deceasedList.removeAt(i);
                syncAllNames();
              },
              content: _responsiveGrid(context, [
                TextFormField(
                  controller: p['name'] as TextEditingController,
                  decoration: _fieldDecor('Name'),
                  onChanged: (_) => syncAllNames(),
                ),
                TextFormField(
                  controller: p['age'] as TextEditingController,
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecor('Age'),
                ),
                DropdownButtonFormField<String>(
                  key: ValueKey('deceased_gender_${i}_${p['gender']}'),
                  isExpanded: true,
                  decoration: _fieldDecor('Gender'),
                  initialValue: p['gender'] as String,
                  items: deceasedGenderItems,
                  onChanged: (v) {
                    if (v != null) setState(() => p['gender'] = v);
                  },
                ),
                TextFormField(
                    controller: p['occ'] as TextEditingController,
                    decoration: _fieldDecor('Occupation')),
                TextFormField(
                  controller: p['mobile'] as TextEditingController,
                  keyboardType: TextInputType.phone,
                  decoration: _fieldDecor('Mobile Number'),
                ),
                TextFormField(
                  controller: p['aadhaar'] as TextEditingController,
                  decoration: _fieldDecor('Aadhaar Number'),
                ),
                TextFormField(
                  controller: p['religion'] as TextEditingController,
                  decoration: _fieldDecor('Religion'),
                ),
                TextFormField(
                    controller: p['caste'] as TextEditingController,
                    decoration: _fieldDecor('Caste')),
                TextFormField(
                    controller: p['pan'] as TextEditingController,
                    decoration: _fieldDecor('PAN Number')),
              ]),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSection6() {
    return RepaintBoundary(
      child: _sectionCard(
        title: '6. CAUSE OF DEATH',
        action: Row(
          children: [
            const Text('Unknown',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: textSecondary)),
            Switch.adaptive(
              value: isUnknownDeath,
              activeThumbColor: accentTeal,
              activeTrackColor: accentTeal.withValues(alpha: 0.42),
              onChanged: (v) => setState(() => isUnknownDeath = v),
            ),
          ],
        ),
        content: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(
            key: ValueKey<bool>(isUnknownDeath),
            child:
                isUnknownDeath ? _buildUnknownCause() : _buildStandardCause(),
          ),
        ),
      ),
    );
  }

  Widget _buildSection8() {
    final ioDesigItems = PoliceDesignations.adIo
        .map((d) => DropdownMenuItem<String>(value: d, child: Text(d)))
        .toList();
    final regDesigItems = PoliceDesignations.adReg
        .map((d) => DropdownMenuItem<String>(value: d, child: Text(d)))
        .toList();
    return RepaintBoundary(
      child: _sectionCard(
        title: '8. CASE RESPONSIBILITY',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _responsiveGrid(
              context,
              [
                DropdownButtonFormField<String>(
                  key: ValueKey('io_$ioDesig'),
                  isExpanded: true,
                  decoration: _fieldDecor('IO Designation'),
                  initialValue: ioDesig,
                  items: ioDesigItems,
                  onChanged: (v) => setState(() => ioDesig = v ?? ioDesig),
                ),
                TextFormField(
                    controller: ioNameController,
                    decoration: _fieldDecor('IO Name')),
                DropdownButtonFormField<String>(
                  key: ValueKey('reg_$regDesig'),
                  isExpanded: true,
                  decoration: _fieldDecor('Reg. By Designation'),
                  initialValue: regDesig,
                  items: regDesigItems,
                  onChanged: (v) => setState(() => regDesig = v ?? regDesig),
                ),
                TextFormField(
                    controller: regNameController,
                    decoration: _fieldDecor('Registrar Name')),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: inputBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'CCTV Available',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textPrimary),
                        ),
                      ),
                      _yesNoChip('Yes', cctvValue == 'yes', accentGreen, () {
                        setState(() => cctvValue = 'yes');
                      }),
                      const SizedBox(width: 10),
                      _yesNoChip('No', cctvValue == 'no', accentRed, () {
                        setState(() {
                          cctvValue = 'no';
                          cctvDateTimeController.clear();
                        });
                      }),
                    ],
                  ),
                  if (cctvValue == 'yes') ...[
                    const SizedBox(height: 10),
                    TextFormField(
                      readOnly: true,
                      controller: cctvDateTimeController,
                      decoration: _fieldDecor('CCTV Date & Time').copyWith(
                        suffixIcon: const Icon(Icons.access_time,
                            size: 18, color: textMuted),
                      ),
                      onTap: () async {
                        await _pickDateThenTime(cctvDateTimeController);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection10() {
    return RepaintBoundary(
      child: _sectionCard(
        title: '10. PROCEDURAL DETAILS',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: [
                SizedBox(
                    width: 360,
                    child: _buildProceduralLine(
                        'chkMemo', 'Memorandum Panchanama')),
                SizedBox(
                    width: 360,
                    child: _buildProceduralLine(
                        'chkPanchSpot', 'Panchanama Spot')),
                SizedBox(
                    width: 360,
                    child: _buildProceduralLine('chkInquest', 'Inquest')),
                SizedBox(
                    width: 360,
                    child: _buildProceduralLine('chkIdent', 'Identification')),
                SizedBox(
                    width: 360,
                    child: _buildProceduralLine('chkSearch', 'Search')),
                SizedBox(
                    width: 360,
                    child: _buildProceduralLine(
                        'chkPersSearch', 'Personal Search')),
                SizedBox(
                    width: 360,
                    child: _buildProceduralLine('chkExhumation', 'Exhumation')),
              ],
            ),
            const Divider(height: 24, color: inputBorder),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: inputBorder)),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'E-shaksh',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary),
                    ),
                  ),
                  _yesNoChip('Yes', eshakshValue == 'yes', accentGreen, () {
                    setState(() => eshakshValue = 'yes');
                  }),
                  const SizedBox(width: 10),
                  _yesNoChip('No', eshakshValue == 'no', accentRed, () {
                    setState(() => eshakshValue = 'no');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection12() {
    return RepaintBoundary(
      child: _sectionCard(
        title: '12. TECHNICAL RECORDS',
        content: _responsiveGrid(
          context,
          [
            TextFormField(
              readOnly: true,
              controller: cdrSentController,
              decoration: _fieldDecor('CDR Sent Date').copyWith(
                suffixIcon: const Icon(Icons.calendar_today,
                    size: 18, color: textMuted),
              ),
              onTap: () async {
                final d = await _pickDate();
                if (!mounted || d == null) return;
                cdrSentController.text = _formatDateDdMmYyyy(d);
                setState(() {});
              },
            ),
            TextFormField(
              readOnly: true,
              controller: cdrRecvController,
              decoration: _fieldDecor('CDR Received Date').copyWith(
                suffixIcon: const Icon(Icons.calendar_today,
                    size: 18, color: textMuted),
              ),
              onTap: () async {
                final d = await _pickDate();
                if (!mounted || d == null) return;
                cdrRecvController.text = _formatDateDdMmYyyy(d);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection13() {
    return RepaintBoundary(
      child: _sectionCard(
        title: '13. CASE SCRUTINY PIPELINE',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _scrutinyStep(
              title: 'SDPO / ACP Approval',
              active: true,
              sendCtrl: sdpoSendController,
              grantCtrl: sdpoGrantController,
              nextStep: 'APP',
            ),
            _scrutinyStep(
              title: 'APP Scrutiny',
              active: stepAppActive,
              sendCtrl: appSendController,
              grantCtrl: appGrantController,
              nextStep: 'DCP',
            ),
            _scrutinyStep(
              title: 'Addl SP / DCP / Addl CP',
              active: stepDcpActive,
              sendCtrl: dcpSendController,
              grantCtrl: dcpGrantController,
              nextStep: null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseFormLayout(
      title: 'AD FORM',
      subtitle: 'Accidental Deaths',
      darkAppBar: true,
      backgroundColor: pageBg,
      scrollController: _scrollController,
      onScrollNotification: _onScrollNotification,
      onSubmit: submitForm,
      submitLabel: 'SUBMIT',
      bottomBar: _buildSaveBar(),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRemoteUpdateBanner(),
          _buildAdDocumentDeletedBanner(),
          ValueListenableBuilder<double>(
            valueListenable: _scrollProgressNotifier,
            builder: (context, progress, _) {
              return LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 3,
                color: accentTeal,
                backgroundColor: Colors.transparent,
              );
            },
          ),
        ],
      ),
      children: [
        _buildSection1(),
        _buildSection2(),
        _buildSection3(),
        _buildSection4(),
        _buildSection5(),
        _buildSection6(),
        _buildSection8(),
        _buildSection10(),
        _buildSection11(),
        _buildSection12(),
        _buildSection13(),
      ],
    );
  }
}
