// lib/utils/ad_form_display_order.dart
// Field order for A.D matches [AdFormScreen.buildAdDocumentMap] and nested structures.
// Used by AdFormDynamicDocumentView and DynamicMapPdf (must stay in sync with the form).

/// Root map: same key sequence as [AdFormScreen.buildAdDocumentMap] (§1 → §13).
const List<String> kAdFormRootDisplayOrder = [
  'adNo',
  'crNo',
  'regDate',
  'spotVillage',
  'spotArea',
  'spotAddress',
  'compName',
  'compAge',
  'compGender',
  'compOcc',
  'compMobile',
  'compAadhaar',
  'compReligion',
  'compCaste',
  'compPan',
  'deceased',
  'chargeData',
  'charges',
  'isUnknownDeath',
  'causeOfDeath',
  'otherCause',
  'unknownFields',
  'relName',
  'relRelation',
  'relAge',
  'relGender',
  'relOcc',
  'relMobile',
  'relAadhaar',
  'relReligion',
  'relCaste',
  'relPan',
  'ioDesig',
  'ioName',
  'regDesig',
  'regName',
  'cctvValue',
  'cctvDateTime',
  'proceduralChecks',
  'proceduralDates',
  'eshakshValue',
  'seizures',
  'cdrSent',
  'cdrRecv',
  'sdpoSend',
  'sdpoGrant',
  'appSend',
  'appGrant',
  'dcpSend',
  'dcpGrant',
  'stepAppActive',
  'stepDcpActive',
  'peopleNames',
  'caseListDocId',
  'status',
];

const List<String> kAdFormAuditTailKeys = [
  'submittedAt',
  'savedAt',
  'updatedAt',
];

const List<String> kAdUnknownFieldsOrder = [
  'shodhPatrika',
  'gazette',
  'mediaPub',
  'dnaSent',
  'dnaReport',
  'funeralPolice',
  'funeralRelative',
];

const List<String> kAdUnknownEntryFieldOrder = ['value', 'date'];

const List<String> kAdProceduralFieldOrder = [
  'chkMemo',
  'chkPanchSpot',
  'chkInquest',
  'chkIdent',
  'chkSearch',
  'chkPersSearch',
  'chkExhumation',
];

const List<String> kAdDeceasedPersonFieldOrder = [
  'name',
  'age',
  'gender',
  'occ',
  'mobile',
  'aadhaar',
  'religion',
  'caste',
  'pan',
];

const List<String> kAdChargeFirestoreEntryOrder = ['act', 'sections'];

const List<String> kAdChargesListEntryOrder = ['roman', 'act', 'sections'];

const List<String> kAdSeizureFieldOrder = ['desc', 'fromWhom', 'otherName'];

bool adMapLooksLikeUnknownSubEntry(Map<String, dynamic> m) {
  final ks = m.keys.map((k) => k.toString()).toSet();
  if (ks.isEmpty) return false;
  return ks.difference({'value', 'date'}).isEmpty;
}

int _compareNumericOrLex(String a, String b) {
  final ia = int.tryParse(a);
  final ib = int.tryParse(b);
  if (ia != null && ib != null) return ia.compareTo(ib);
  return a.compareTo(b);
}

List<String> _preferThenRest(
    List<String> preferred, List<String> allKeys) {
  final set = allKeys.toSet();
  final out = <String>[
    for (final p in preferred)
      if (set.contains(p)) p,
  ];
  final used = out.toSet();
  for (final k in allKeys) {
    if (!used.contains(k)) out.add(k);
  }
  return out;
}

/// Top-level A.D Firestore/document map (root keys only).
List<String> orderedAdFormRootKeys(Map<String, dynamic> data) {
  final keySet = data.keys.map((k) => k.toString()).toSet();
  final out = <String>[];
  for (final k in kAdFormRootDisplayOrder) {
    if (keySet.contains(k)) out.add(k);
  }
  for (final k in kAdFormAuditTailKeys) {
    if (keySet.contains(k)) out.add(k);
  }
  final used = out.toSet();
  for (final k in data.keys.map((x) => x.toString())) {
    if (!used.contains(k)) out.add(k);
  }
  return out;
}

/// How to order keys for a nested map in the A.D tree.
enum AdNestedMapKind {
  unknownFields,
  unknownFieldEntry,
  chargeDataSlots,
  chargeDataRow,
  procedural,
  genericInsertion,
}

AdNestedMapKind adNestedMapKindFor({
  required String? parentFieldKey,
  required Map<String, dynamic> m,
}) {
  if (adMapLooksLikeUnknownSubEntry(m)) {
    return AdNestedMapKind.unknownFieldEntry;
  }
  if (parentFieldKey == 'unknownFields') {
    return AdNestedMapKind.unknownFields;
  }
  if (parentFieldKey == 'chargeData') {
    if (m.containsKey('act') && m.containsKey('sections')) {
      return AdNestedMapKind.chargeDataRow;
    }
    return AdNestedMapKind.chargeDataSlots;
  }
  if (parentFieldKey == 'proceduralChecks' ||
      parentFieldKey == 'proceduralDates') {
    return AdNestedMapKind.procedural;
  }
  return AdNestedMapKind.genericInsertion;
}

List<String> orderedKeysForAdNestedMap({
  required AdNestedMapKind kind,
  required Map<String, dynamic> m,
}) {
  final raw = m.keys.map((k) => k.toString()).toList();
  switch (kind) {
    case AdNestedMapKind.unknownFields:
      return _preferThenRest(kAdUnknownFieldsOrder, raw);
    case AdNestedMapKind.unknownFieldEntry:
      return _preferThenRest(kAdUnknownEntryFieldOrder, raw);
    case AdNestedMapKind.chargeDataSlots:
      final keys = List<String>.from(raw)..sort(_compareNumericOrLex);
      return keys;
    case AdNestedMapKind.chargeDataRow:
      return _preferThenRest(kAdChargeFirestoreEntryOrder, raw);
    case AdNestedMapKind.procedural:
      return _preferThenRest(kAdProceduralFieldOrder, raw);
    case AdNestedMapKind.genericInsertion:
      return List<String>.from(raw);
  }
}

/// Map inside a list under [listFieldKey] at root (deceased / charges / seizures).
List<String> orderedKeysForAdListItemMap({
  required String listFieldKey,
  required Map<String, dynamic> m,
}) {
  final raw = m.keys.map((k) => k.toString()).toList();
  switch (listFieldKey) {
    case 'deceased':
      return _preferThenRest(kAdDeceasedPersonFieldOrder, raw);
    case 'charges':
      return _preferThenRest(kAdChargesListEntryOrder, raw);
    case 'seizures':
      return _preferThenRest(kAdSeizureFieldOrder, raw);
    default:
      return List<String>.from(raw);
  }
}
