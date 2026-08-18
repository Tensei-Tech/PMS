// lib/utils/ad_firestore_payload.dart
// Load A.D form/draft from Firestore and merge hub list fallbacks — shared by View + PDF.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../modules/core/models/base_record.dart';

class AdFirestorePayload {
  AdFirestorePayload._();

  static String adNoFromRecord(ModuleRecord r) {
    final n = r.caseNumber.trim();
    if (n.isNotEmpty) return n;
    return (r.extraFields['adNo']?.toString() ?? '').trim();
  }

  static bool _empty(dynamic v) =>
      v == null || v.toString().trim().isEmpty;

  /// Fills missing/empty form fields from the case hub record (same rules as detail screen).
  static Map<String, dynamic> mergeHubIntoForm(
    Map<String, dynamic> form,
    ModuleRecord hub,
  ) {
    final m = Map<String, dynamic>.from(form);
    final adNo = adNoFromRecord(hub);
    if (_empty(m['adNo']) && adNo.isNotEmpty) {
      m['adNo'] = adNo;
    }
    if (_empty(m['compName'])) {
      m['compName'] = hub.complainant;
    }
    if (_empty(m['spotAddress'])) {
      m['spotAddress'] = hub.location;
    }
    if (_empty(m['regDate'])) {
      m['regDate'] = DateFormat('dd/MM/yyyy').format(hub.incidentDate);
    }
    if (_empty(m['ioName'])) {
      m['ioName'] = hub.assignedOfficer;
    }
    return m;
  }

  /// Reads `ad_forms` then `ad_drafts` for [adNo]. Returns `{}` if missing or on error.
  static Future<Map<String, dynamic>> loadFormMapByAdNo(String adNo) async {
    final r = await loadFormWithSource(adNo);
    return r.data;
  }

  /// Same as [loadFormMapByAdNo] but indicates whether the payload came from submitted form or draft.
  static Future<({Map<String, dynamic> data, AdFirestoreFormSource source})>
      loadFormWithSource(String adNo) async {
    if (adNo.isEmpty) {
      return (data: <String, dynamic>{}, source: AdFirestoreFormSource.none);
    }
    try {
      final formSnap = await FirebaseFirestore.instance
          .collection('ad_forms')
          .doc(adNo)
          .get();
      if (formSnap.exists && formSnap.data() != null) {
        return (
          data: Map<String, dynamic>.from(formSnap.data()!),
          source: AdFirestoreFormSource.submitted,
        );
      }
      final draftSnap = await FirebaseFirestore.instance
          .collection('ad_drafts')
          .doc(adNo)
          .get();
      if (draftSnap.exists && draftSnap.data() != null) {
        return (
          data: Map<String, dynamic>.from(draftSnap.data()!),
          source: AdFirestoreFormSource.draft,
        );
      }
    } catch (e) {
      debugPrint('AdFirestorePayload.loadFormWithSource: $e');
    }
    return (data: <String, dynamic>{}, source: AdFirestoreFormSource.none);
  }
}

enum AdFirestoreFormSource { submitted, draft, none }
