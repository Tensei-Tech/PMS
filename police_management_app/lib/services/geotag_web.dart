// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'evidence_geotag_service.dart';

Future<GeotagLocation?> getWebCurrentLocation() async {
  try {
    final completer = Completer<GeotagLocation?>();
    if (html.window.navigator.geolocation != null) {
      html.window.navigator.geolocation.getCurrentPosition(
        enableHighAccuracy: true,
        timeout: const Duration(seconds: 10),
      ).then((pos) {
        final coords = pos.coords;
        if (coords != null) {
          final loc = GeotagLocation(
            latitude: coords.latitude?.toDouble() ?? 0.0,
            longitude: coords.longitude?.toDouble() ?? 0.0,
            accuracy: coords.accuracy?.toDouble(),
            timestamp: DateFormat('dd-MMM-yyyy HH:mm:ss').format(DateTime.now()),
          );
          completer.complete(loc);
        } else {
          completer.complete(null);
        }
      }).catchError((err) {
        debugPrint('Geolocation error: $err');
        completer.complete(null);
      });
      return await completer.future;
    }
  } catch (e) {
    debugPrint('Web Geolocation exception: $e');
  }
  return null;
}
