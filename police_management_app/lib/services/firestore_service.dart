// lib/services/firestore_service.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../modules/core/models/base_record.dart';
import '../models/user_model.dart';
import '../utils/pending_approvals_scope.dart';

class FirestoreService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  static bool _loggedStationNamesPermissionDenied = false;

  static const String colUsers = 'users';
  static const String colCases = 'cases';
  static const String colPending = 'pending_cases';
  static const String colDisposal = 'disposal_cases';
  static const String colFirs = 'firs';
  static const String colWanted = 'wanted';
  static const String colStations = 'stations';

  /// Per-user inbox (auth-scoped). Document id is fixed so reads/writes merge.
  static const String userSubAppSettings = 'app_settings';

  Future<void> saveUser(UserModel user) async {
    await _db.collection(colUsers).doc(user.uid).set(user.toMap());
    if (kDebugMode) {
      debugPrint(
        '[FirestoreService] saveUser ok uid=${user.uid} accountStatus=${user.accountStatus}',
      );
    }
  }

  /// Update a single field on a user document (merge).
  Future<void> updateUserField(String uid, String field, dynamic value) async {
    await _db.collection(colUsers).doc(uid).update({field: value});
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(colUsers).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  /// Real-time profile updates (grant toggles, admin posting changes, etc.).
  Stream<UserModel?> watchUser(String uid) {
    if (uid.isEmpty) return Stream.value(null);
    return _db.collection(colUsers).doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserModel.fromMap(snap.data()!, snap.id);
    });
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final query = await _db
        .collection(colUsers)
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return UserModel.fromMap(query.docs.first.data(), query.docs.first.id);
  }

  Future<void> saveCase(ModuleRecord record, {bool isCreate = false}) async {
    try {
      final batch = _db.batch();
      final caseRef = _db.collection(colCases).doc(record.id);

      // ✅ DEBUG — remove after confirmed working
      debugPrint(
          '>>> stationName: "${record.stationName}" | createdBy: "${record.createdBy}" | isCreate: $isCreate');

      if (record.stationName.isEmpty || record.createdBy.isEmpty) {
        throw Exception(
            'Security violation: Missing stationName or createdBy fields.');
      }
      if (record.moduleKey.isEmpty) {
        throw Exception(
            'Security violation: Missing moduleKey for categorized storage.');
      }

      if (record.moduleKey == 'detected' || record.moduleKey == 'undetected') {
        final isDisposal = record.status == 'Disposal' ||
            record.status == 'Closed' ||
            record.status == 'Resolved';
        final normalizedStatus = isDisposal ? 'Disposal' : 'Pending';
        final recordToSave = record.copyWith(status: normalizedStatus);

        batch.set(caseRef, recordToSave.toMap());

        if (normalizedStatus == 'Disposal') {
          batch.set(
              _db.collection(colDisposal).doc(recordToSave.id), recordToSave.toMap());
          if (!isCreate) {
            batch.delete(_db.collection(colPending).doc(recordToSave.id));
          }
        } else {
          batch.set(
              _db.collection(colPending).doc(recordToSave.id), recordToSave.toMap());
          if (!isCreate) {
            batch.delete(_db.collection(colDisposal).doc(recordToSave.id));
          }
        }
      } else {
        batch.set(caseRef, record.toMap());

        if (record.status == 'Closed' || record.status == 'Disposal') {
          batch.set(_db.collection(colDisposal).doc(record.id), record.toMap());
          if (!isCreate) {
            batch.delete(_db.collection(colPending).doc(record.id));
          }
        } else {
          batch.set(_db.collection(colPending).doc(record.id), record.toMap());
          if (!isCreate) {
            batch.delete(_db.collection(colDisposal).doc(record.id));
          }
        }
      }

      await batch.commit();
    } catch (e) {
      debugPrint('FirestoreService.saveCase failed: $e');
      rethrow;
    }
  }

  Future<void> deleteCase(String id, {required String moduleKey}) async {
    final batch = _db.batch();
    batch.delete(_db.collection(colCases).doc(id));
    batch.delete(_db.collection(colPending).doc(id));
    batch.delete(_db.collection(colDisposal).doc(id));
    await batch.commit();
  }

  /// Live updates for a single case document (`cases/{id}`).
  /// Emits `null` when the document is missing or deleted.
  Stream<ModuleRecord?> watchCaseById(String id) {
    if (id.isEmpty) return Stream.value(null);
    return _db.collection(colCases).doc(id).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return ModuleRecord.fromMap(snap.data()!, snap.id);
    });
  }

  /// Live updates for any single Firestore document (e.g. `ad_forms/{adNo}`).
  /// Emits `null` when the document is missing or deleted.
  Stream<Map<String, dynamic>?> watchDocumentData(
      String collection, String docId) {
    if (docId.isEmpty) return Stream.value(null);
    return _db.collection(collection).doc(docId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return Map<String, dynamic>.from(snap.data()!);
    });
  }

  Stream<List<ModuleRecord>> getCasesStream(
      String moduleKey, String stationId) {
    return _db
        .collection(colCases)
        .where('moduleKey', isEqualTo: moduleKey)
        .where('stationName', isEqualTo: stationId)
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs
          .map((doc) => ModuleRecord.fromMap(doc.data(), doc.id))
          .toList();
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return records;
    });
  }

  static bool _isActiveCaseStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'open':
      case 'active':
        return true;
      default:
        return false;
    }
  }

  static bool _isClosedCaseStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'closed':
      case 'resolved':
        return true;
      default:
        return false;
    }
  }

  /// Real-time cases assigned to the signed-in officer (`assignedOfficerUid`).
  Stream<List<ModuleRecord>> watchAssignedCasesStream(
    String officerUid, {
    required bool activeOnly,
  }) {
    if (officerUid.trim().isEmpty) {
      return Stream.value(const []);
    }

    return _db
        .collection(colCases)
        .where('assignedOfficerUid', isEqualTo: officerUid.trim())
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs
          .map((doc) => ModuleRecord.fromMap(doc.data(), doc.id))
          .where((r) => activeOnly
              ? _isActiveCaseStatus(r.status)
              : _isClosedCaseStatus(r.status))
          .toList();
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return records;
    });
  }

  Stream<List<ModuleRecord>> getRecentCasesStream(int limit, String stationId) {
    return getStationCasesStream(stationId).map(
      (records) => records.take(limit).toList(),
    );
  }

  Stream<List<ModuleRecord>> getStationCasesStream(String stationId) {
    if (stationId.trim().isEmpty) {
      return Stream.value(const []);
    }

    StreamController<List<ModuleRecord>>? controller;
    final casesMap = <String, ModuleRecord>{};
    final pendingMap = <String, ModuleRecord>{};
    final disposalMap = <String, ModuleRecord>{};

    void emitMerged() {
      if (controller == null || controller!.isClosed) return;
      final all = <String, ModuleRecord>{
        ...casesMap,
        ...pendingMap,
        ...disposalMap,
      };
      final list = all.values
          .where((r) => r.moduleKey != 'form_1_5')
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller!.add(list);
    }

    StreamSubscription? subCases;
    StreamSubscription? subPending;
    StreamSubscription? subDisposal;

    controller = StreamController<List<ModuleRecord>>(
      onListen: () {
        subCases = _db
            .collection(colCases)
            .where('stationName', isEqualTo: stationId)
            .snapshots()
            .listen((snap) {
          casesMap.clear();
          for (final doc in snap.docs) {
            casesMap[doc.id] = ModuleRecord.fromMap(doc.data(), doc.id);
          }
          emitMerged();
        }, onError: (e) {
          if (controller != null && !controller!.isClosed) {
            controller!.addError(e);
          }
        });

        subPending = _db
            .collection(colPending)
            .where('stationName', isEqualTo: stationId)
            .snapshots()
            .listen((snap) {
          pendingMap.clear();
          for (final doc in snap.docs) {
            pendingMap[doc.id] = ModuleRecord.fromMap(doc.data(), doc.id);
          }
          emitMerged();
        }, onError: (e) {
          if (controller != null && !controller!.isClosed) {
            controller!.addError(e);
          }
        });

        subDisposal = _db
            .collection(colDisposal)
            .where('stationName', isEqualTo: stationId)
            .snapshots()
            .listen((snap) {
          disposalMap.clear();
          for (final doc in snap.docs) {
            disposalMap[doc.id] = ModuleRecord.fromMap(doc.data(), doc.id);
          }
          emitMerged();
        }, onError: (e) {
          if (controller != null && !controller!.isClosed) {
            controller!.addError(e);
          }
        });
      },
      onCancel: () {
        subCases?.cancel();
        subPending?.cancel();
        subDisposal?.cancel();
      },
    );

    return controller.stream;
  }

  Stream<List<ModuleRecord>> getPendingCasesStream(String stationId) {
    if (stationId.trim().isEmpty) {
      return Stream.value(const []);
    }
    return _db
        .collection(colPending)
        .where('stationName', isEqualTo: stationId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ModuleRecord.fromMap(doc.data(), doc.id))
            .where((r) => r.moduleKey != 'nc')
            .toList());
  }

  /// One-shot pending read — same query as [getPendingCasesStream], no listener.
  Future<List<ModuleRecord>> fetchPendingCasesOnce(String stationId) async {
    if (stationId.isEmpty) return [];
    try {
      final snapshot = await _db
          .collection(colPending)
          .where('stationName', isEqualTo: stationId)
          .get();
      final records = snapshot.docs
          .map((doc) => ModuleRecord.fromMap(doc.data(), doc.id))
          .where((r) => r.moduleKey != 'nc')
          .toList();
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return records;
    } catch (e, st) {
      debugPrint('FirestoreService.fetchPendingCasesOnce failed: $e\n$st');
      return [];
    }
  }

  Stream<List<ModuleRecord>> getDisposalCasesStream(String stationId) {
    if (stationId.trim().isEmpty) {
      return Stream.value(const []);
    }
    return _db
        .collection(colDisposal)
        .where('stationName', isEqualTo: stationId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ModuleRecord.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> saveFir(Map<String, dynamic> firData) async {
    final id = firData['firNumber'] ??
        DateTime.now().millisecondsSinceEpoch.toString();
    await _db.collection(colFirs).doc(id).set(firData);
  }

  Future<void> saveWanted(Map<String, dynamic> wantedData) async {
    final id =
        wantedData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _db.collection(colWanted).doc(id).set(wantedData);
  }

  /// Exact match search for floating (unassigned) user by email or 10-digit mobile.
  Future<UserModel?> findFloatingUserByEmailOrPhone(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      if (trimmed.contains('@')) {
        snapshot = await _db
            .collection(colUsers)
            .where('email', isEqualTo: trimmed.toLowerCase())
            .limit(1)
            .get();
      } else {
        final digits = trimmed.replaceAll(RegExp(r'\D'), '');
        if (digits.length != 10) return null;
        snapshot = await _db
            .collection(colUsers)
            .where('phone', isEqualTo: digits)
            .limit(1)
            .get();
      }

      if (snapshot.docs.isEmpty) return null;
      final user =
          UserModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      if (user.stationName.trim().isNotEmpty) return null;
      if ((user.district ?? '').trim().isNotEmpty) return null;
      return user;
    } catch (e) {
      debugPrint('FirestoreService.findFloatingUserByEmailOrPhone failed: $e');
      return null;
    }
  }

  /// Assign a floating user to a station (PI or senior officer flow).
  Future<void> assignFloatingUserToStation({
    required String uid,
    required String stationName,
    required String district,
    required String stationAddress,
  }) async {
    await _db.collection(colUsers).doc(uid).update({
      'stationName': stationName.trim(),
      'district': district.trim(),
      'stationAddress': stationAddress.trim(),
    });
  }

  Future<List<UserModel>> getUsersAtStation(String stationName) async {
    final trimmed = stationName.trim();
    if (trimmed.isEmpty) return [];
    try {
      final snapshot = await _db
          .collection(colUsers)
          .where('stationName', isEqualTo: trimmed)
          .get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
      users.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return users;
    } catch (e) {
      debugPrint('FirestoreService.getUsersAtStation failed: $e');
      return [];
    }
  }

  /// Fetches police station names from the [stations] collection.
  /// Falls back to [getAllStationNames] when the collection is empty or unreadable.
  Future<List<String>> getPoliceStationNames() async {
    try {
      final snapshot = await _db.collection(colStations).get();
      if (snapshot.docs.isEmpty) {
        return getAllStationNames();
      }
      final stations = <String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final name = (data['stationName'] ?? data['name'] ?? doc.id)
            .toString()
            .trim();
        if (name.isNotEmpty) stations.add(name);
      }
      if (stations.isEmpty) return getAllStationNames();
      final sorted = stations.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return sorted;
    } on FirebaseException catch (e) {
      debugPrint('FirestoreService.getPoliceStationNames failed: $e');
      return getAllStationNames();
    } catch (e) {
      debugPrint('FirestoreService.getPoliceStationNames failed: $e');
      return getAllStationNames();
    }
  }

  /// Fetches all unique station names from the users collection.
  /// Note: Replace with a proper officer-to-jurisdiction mapping
  /// (e.g., a `station_jurisdictions` collection) once the backend supports it.
  Future<List<String>> getAllStationNames() async {
    try {
      final snapshot = await _db.collection(colUsers).get();
      final stations = <String>{};
      for (final doc in snapshot.docs) {
        final name = (doc.data()['stationName'] ?? '').toString().trim();
        if (name.isNotEmpty) stations.add(name);
      }
      final sorted = stations.toList()..sort();
      return sorted;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        if (!_loggedStationNamesPermissionDenied) {
          _loggedStationNamesPermissionDenied = true;
          debugPrint(
              'FirestoreService.getAllStationNames: permission-denied (users collection not readable for this account).');
        }
        return [];
      }
      debugPrint('FirestoreService.getAllStationNames failed: $e');
      return [];
    } catch (e) {
      debugPrint('FirestoreService.getAllStationNames failed: $e');
      return [];
    }
  }

  /// Real-time preferences for the signed-in account (cross-device UI sync).
  /// [uid] must be non-empty.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUserAppPreferences(
      String uid) {
    return _db
        .collection(colUsers)
        .doc(uid)
        .collection(userSubAppSettings)
        .doc('preferences')
        .snapshots();
  }

  /// Merges non-sensitive UI preferences under [users/{uid}/app_settings/preferences].
  /// Sets [createdAt] only when the document is first created.
  Future<void> mergeUserAppPreferences(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    if (uid.isEmpty) return;
    try {
      final ref = _db
          .collection(colUsers)
          .doc(uid)
          .collection(userSubAppSettings)
          .doc('preferences');
      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final next = Map<String, dynamic>.from(fields);
        next['updatedAt'] = FieldValue.serverTimestamp();
        if (!snap.exists) {
          next['createdAt'] = FieldValue.serverTimestamp();
        }
        tx.set(ref, next, SetOptions(merge: true));
      });
    } catch (e) {
      debugPrint('FirestoreService.mergeUserAppPreferences failed: $e');
    }
  }

  /// Stores feedback in Firestore central collection [/feedback] for Master Admin Dashboard
  /// and mirrors to user subcollection [users/{uid}/feedback].
  Future<String?> addUserFeedback({
    required String uid,
    required String name,
    required String email,
    required String message,
    String category = 'General',
    String? clientTimestampIso,
  }) async {
    try {
      final docRef = _db.collection('feedback').doc();
      final payload = {
        'id': docRef.id,
        'uid': uid.isNotEmpty ? uid : 'anonymous',
        'name': name,
        'email': email,
        'category': category,
        'message': message,
        if (clientTimestampIso != null) 'clientTimestamp': clientTimestampIso,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 1. Central collection for Master Admin Dashboard
      await docRef.set(payload);

      // 2. User subcollection (if signed in)
      if (uid.isNotEmpty) {
        try {
          await _db
              .collection(colUsers)
              .doc(uid)
              .collection('feedback')
              .doc(docRef.id)
              .set(payload);
        } catch (e) {
          debugPrint('FirestoreService user subcollection feedback save error: $e');
        }
      }
      return docRef.id;
    } catch (e) {
      debugPrint('FirestoreService.addUserFeedback failed: $e');
      return null;
    }
  }

  static const _pendingRegistrationStatuses = [
    UserAccountStatus.pendingApproval,
    UserAccountStatus.pending,
  ];

  List<UserModel> _mapPendingUsers(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final users = snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .where(
          (u) => _pendingRegistrationStatuses.contains(u.accountStatus.trim()),
        )
        .toList();
    users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return users;
  }

  /// Pending officer registration/access requests visible to the signed-in approver.
  Stream<List<UserModel>> watchPendingRegistrationRequests({
    required bool isSuperAdmin,
    required bool canReview,
    required String approverDesignation,
    required String approverZone,
    required String approverStation,
  }) {
    if (!canReview) return Stream.value(const []);

    if (isSuperAdmin) {
      return _db
          .collection(colUsers)
          .where('accountStatus', isEqualTo: UserAccountStatus.pendingApproval)
          .snapshots()
          .map(_mapPendingUsers);
    }

    if (PendingApprovalsScope.usesStationFilter(approverDesignation) &&
        !PendingApprovalsScope.usesZoneFilter(approverDesignation) &&
        approverStation.trim().isNotEmpty) {
      return _db
          .collection(colUsers)
          .where('accountStatus', isEqualTo: UserAccountStatus.pendingApproval)
          .where('stationName', isEqualTo: approverStation.trim())
          .snapshots()
          .map(_mapPendingUsers);
    }

    final zone = approverZone.trim();
    if (zone.isNotEmpty &&
        PendingApprovalsScope.usesZoneFilter(approverDesignation)) {
      return _db
          .collection(colUsers)
          .where('accountStatus', isEqualTo: UserAccountStatus.pendingApproval)
          .where('zone', isEqualTo: zone)
          .snapshots()
          .map(_mapPendingUsers);
    }

    return Stream.value(const []);
  }

  Future<void> approveUserRegistration(String uid) async {
    if (uid.trim().isEmpty) return;
    await _db.collection(colUsers).doc(uid.trim()).update({
      'accountStatus': UserAccountStatus.active,
    });
  }

  Future<void> rejectUserRegistration(String uid) async {
    if (uid.trim().isEmpty) return;
    await _db.collection(colUsers).doc(uid.trim()).update({
      'accountStatus': UserAccountStatus.rejected,
    });
  }

  // ── CASE REMINDERS & SUPERVISION NOTICES ─────────────────────────────────
  static const String colReminders = 'case_reminders';

  Future<void> sendCaseReminder({
    required String caseId,
    required String caseNumber,
    required String caseTitle,
    required String stationName,
    required String ioName,
    required String ioUid,
    required String sentByUid,
    required String sentByName,
    required String sentByDesignation,
    required String reminderType,
    String notes = '',
  }) async {
    final reminderId = '${DateTime.now().millisecondsSinceEpoch}';
    final reminderData = {
      'id': reminderId,
      'caseId': caseId,
      'caseNumber': caseNumber,
      'caseTitle': caseTitle,
      'stationName': stationName,
      'ioName': ioName,
      'ioUid': ioUid,
      'sentByUid': sentByUid,
      'sentByName': sentByName,
      'sentByDesignation': sentByDesignation,
      'reminderType': reminderType,
      'notes': notes,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    };

    // 1. Update case directly in Firestore (permitted by existing rules)
    if (caseId.trim().isNotEmpty) {
      try {
        await _db.collection(colCases).doc(caseId.trim()).set({
          'activeReminder': reminderData,
          'hasActiveReminder': true,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[FirestoreService] Case document reminder update: $e');
      }
    }

    // 2. Also save to colReminders if collection rules are enabled
    try {
      await _db.collection(colReminders).doc(reminderId).set(reminderData);
    } catch (e) {
      debugPrint('[FirestoreService] case_reminders write notice: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getIoRemindersStream(String ioUid) {
    return _db
        .collection(colCases)
        .where('hasActiveReminder', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => d.data()['activeReminder'] as Map<String, dynamic>?)
            .where((r) => r != null)
            .cast<Map<String, dynamic>>()
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getStationRemindersStream(String stationName) {
    return _db
        .collection(colCases)
        .where('hasActiveReminder', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => d.data()['activeReminder'] as Map<String, dynamic>?)
            .where((r) => r != null)
            .cast<Map<String, dynamic>>()
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getSentRemindersStream(String sentByUid) {
    return _db
        .collection(colCases)
        .where('hasActiveReminder', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => d.data()['activeReminder'] as Map<String, dynamic>?)
            .where((r) => r != null)
            .cast<Map<String, dynamic>>()
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getAllRemindersStream() {
    return _db
        .collection(colCases)
        .where('hasActiveReminder', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => d.data()['activeReminder'] as Map<String, dynamic>?)
            .where((r) => r != null)
            .cast<Map<String, dynamic>>()
            .toList());
  }
}
