// lib/services/transfer_request_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/transfer_request_model.dart';
import '../utils/app_constants.dart';

class TransferRequestService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  static const String colTransferRequests = 'transfer_requests';
  static const String colUsers = 'users';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection(colTransferRequests);

  /// Registration-style station address for a transfer target posting.
  static String buildTargetStationAddress(TransferRequest request) {
    return '${request.toDistrict}, ${request.toState} • ${request.toUnitType}';
  }

  /// Pending request blocking a new submission.
  Future<TransferRequest?> getActiveRequestForUser(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final snap = await _collection
          .where('requestedByUid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      for (final doc in snap.docs) {
        final request = TransferRequest.fromMap(doc.data(), doc.id);
        if (request.isActive) return request;
      }
      return null;
    } catch (e) {
      debugPrint('TransferRequestService.getActiveRequestForUser failed: $e');
      rethrow;
    }
  }

  Stream<TransferRequest?> watchActiveRequestForUser(String uid) {
    if (uid.isEmpty) return Stream.value(null);
    return _collection
        .where('requestedByUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) {
      for (final doc in snap.docs) {
        final request = TransferRequest.fromMap(doc.data(), doc.id);
        if (request.isActive) return request;
      }
      return null;
    });
  }

  /// Most recent non-terminal request for status UI (pending / approved / rejected).
  Future<TransferRequest?> getLatestStatusRequestForUser(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final snap = await _collection
          .where('requestedByUid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      for (final doc in snap.docs) {
        final request = TransferRequest.fromMap(doc.data(), doc.id);
        if (request.status == TransferRequestStatus.cancelled ||
            request.status == TransferRequestStatus.completed) {
          continue;
        }
        return request;
      }
      return null;
    } catch (e) {
      debugPrint('TransferRequestService.getLatestStatusRequestForUser failed: $e');
      rethrow;
    }
  }

  /// Pending requests for destination approvers (PI/API or SP/CP).
  Future<List<TransferRequest>> getPendingForApprover({
    required String homeStationName,
    required String district,
    String? approverDesignation,
  }) async {
    final byId = <String, TransferRequest>{};

    Future<void> mergeQuery(Query<Map<String, dynamic>> query) async {
      final snap = await query.get();
      for (final doc in snap.docs) {
        byId[doc.id] = TransferRequest.fromMap(doc.data(), doc.id);
      }
    }

    try {
      if (homeStationName.trim().isNotEmpty) {
        await mergeQuery(
          _collection
              .where('status', isEqualTo: TransferRequestStatus.pending)
              .where('toStationName', isEqualTo: homeStationName.trim()),
        );
      }
      if (district.trim().isNotEmpty) {
        await mergeQuery(
          _collection
              .where('status', isEqualTo: TransferRequestStatus.pending)
              .where('toDistrict', isEqualTo: district.trim()),
        );
      }
    } catch (e) {
      debugPrint('TransferRequestService.getPendingForApprover failed: $e');
      rethrow;
    }

    final list = byId.values
        .where((r) =>
            r.toStationName.trim().isNotEmpty || r.toDistrict.trim().isNotEmpty)
        .where((r) => approverDesignation == null ||
            approverDesignation.trim().isEmpty ||
            TransferRequestRoles.isApproverForTransfer(
              approverDesignation: approverDesignation,
              fromDesignation: r.fromDesignation,
            ))
        .toList()
      ..sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
    return list;
  }

  Future<String> createRequest(TransferRequest request) async {
    final now = DateTime.now().toUtc();
    final data = {
      ...request.toMap(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
    final doc = await _collection.add(data);
    return doc.id;
  }

  Future<void> cancelRequest(String requestId) async {
    await _collection.doc(requestId).update({
      'status': TransferRequestStatus.cancelled,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Rules-only cross-user approve: transfer doc + in-place posting update.
  ///
  /// TODO: migrate to Cloud Function (Admin SDK) for stronger security/auditability
  /// once Blaze is actively adopted — see firestore.rules `canPiApproveTransferRequest`.
  Future<void> approveTransfer({
    required TransferRequest request,
    required String approverUid,
  }) async {
    if (request.toStationName.trim().isEmpty ||
        request.toDistrict.trim().isEmpty) {
      throw StateError(
        'Transfer request is missing destination fields required for approval.',
      );
    }

    final now = DateTime.now().toUtc().toIso8601String();
    final batch = _db.batch();

    batch.update(_collection.doc(request.id), {
      'status': TransferRequestStatus.approved,
      'approvedByUid': approverUid,
      'approvedAt': now,
      'updatedAt': now,
    });

    batch.update(_db.collection(colUsers).doc(request.requestedByUid), {
      'designation': request.toDesignation,
      'stationName': request.toStationName,
      'stationAddress': buildTargetStationAddress(request),
      'district': request.toDistrict,
      'additionalStations': <String>[],
      'transferRequestId': request.id,
    });

    await batch.commit();
  }

  /// Rules-only reject — transfer doc only; requester profile unchanged.
  ///
  /// TODO: migrate to Cloud Function — see firestore.rules `canPiRejectTransferRequest`.
  Future<void> rejectTransfer({
    required String requestId,
    required String approverUid,
    String? rejectionReason,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _collection.doc(requestId).update({
      'status': TransferRequestStatus.rejected,
      'rejectedByUid': approverUid,
      if (rejectionReason != null && rejectionReason.trim().isNotEmpty)
        'rejectionReason': rejectionReason.trim(),
      'rejectedAt': now,
      'updatedAt': now,
    });
  }
}
