import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'evidence_geotag_service.dart';

class OfficerSosService {
  static final OfficerSosService _instance = OfficerSosService._internal();
  factory OfficerSosService() => _instance;
  OfficerSosService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Broadcasts an Emergency Duress SOS Alert to Control Room & Admin Console
  Future<String> triggerEmergencySos({
    required String officerName,
    required String sevaNumber,
    required String designation,
    required String stationName,
    required String contactNumber,
    String? note,
  }) async {
    try {
      final user = _auth.currentUser;
      final location = await EvidenceGeotagService().getCurrentLocation();

      final alertDoc = _firestore.collection('officer_sos_alerts').doc();
      final now = DateTime.now();

      final lat = location?.latitude ?? 0.0;
      final lng = location?.longitude ?? 0.0;
      final mapsUrl = (lat != 0.0 && lng != 0.0)
          ? 'https://www.google.com/maps/search/?api=1&query=$lat,$lng'
          : null;

      final payload = {
        'id': alertDoc.id,
        'officerId': user?.uid ?? 'unknown',
        'officerName': officerName,
        'sevaNumber': sevaNumber,
        'designation': designation,
        'stationName': stationName,
        'contactNumber': contactNumber,
        'status': 'ACTIVE_DURESS',
        'note': note ?? 'Officer triggered Emergency SOS in field',
        'latitude': lat,
        'longitude': lng,
        'accuracy': location?.accuracy,
        'mapsUrl': mapsUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'timestampStr': now.toIso8601String(),
        'isResolved': false,
      };

      // 1. Write to SOS alerts collection
      await alertDoc.set(payload);

      // 2. Also write high-priority announcement for admin console / app broadcast
      try {
        await _firestore.collection('app_announcements').add({
          'title': '🚨 OFFICER SOS: $officerName ($stationName)',
          'content': 'Emergency Duress Alert triggered by $designation $officerName [Seva: $sevaNumber] at $stationName. Location: ${lat != 0.0 ? "$lat, $lng" : "GPS Pending"}. Contact: $contactNumber',
          'isAlert': true,
          'priority': 'CRITICAL_SOS',
          'sosAlertId': alertDoc.id,
          'mapsUrl': mapsUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Announcement broadcast error: $e');
      }

      return alertDoc.id;
    } catch (e) {
      debugPrint('Emergency SOS trigger failed: $e');
      rethrow;
    }
  }

  /// Resolve an existing SOS alert
  Future<void> resolveSosAlert(String alertId, {String? resolutionNote}) async {
    await _firestore.collection('officer_sos_alerts').doc(alertId).update({
      'status': 'RESOLVED',
      'isResolved': true,
      'resolvedAt': FieldValue.serverTimestamp(),
      'resolutionNote': resolutionNote ?? 'Resolved by Control Room',
    });
  }
}
