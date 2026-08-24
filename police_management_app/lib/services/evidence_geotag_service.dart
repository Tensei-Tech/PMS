import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'geotag_helper.dart';

class GeotagLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String timestamp;
  final String? address;

  GeotagLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
    this.address,
  });

  String get mapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
}

/// Service to capture tamper-resistant geolocation and burn forensic overlays onto evidence photos.
class EvidenceGeotagService {
  static final EvidenceGeotagService _instance = EvidenceGeotagService._internal();
  factory EvidenceGeotagService() => _instance;
  EvidenceGeotagService._internal();

  /// Obtains current GPS coordinates with accuracy
  Future<GeotagLocation?> getCurrentLocation() async {
    if (kIsWeb) {
      return await getWebCurrentLocation();
    }
    return null;
  }

  /// Forensic image stamper: Burns GPS Coordinates, Timestamp, and Officer/Station info
  /// directly onto the bottom of the image using Flutter canvas painting.
  Future<Uint8List> stampEvidencePhoto({
    required Uint8List rawImageBytes,
    required GeotagLocation location,
    required String officerName,
    required String officerSevaNo,
    required String stationName,
  }) async {
    try {
      final codec = await ui.instantiateImageCodec(rawImageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final width = image.width.toDouble();
      final height = image.height.toDouble();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

      // 1. Draw base photo
      canvas.drawImage(image, Offset.zero, Paint());

      // 2. Overlay Forensic Header / Footer banner
      final bannerHeight = (height * 0.14).clamp(70.0, 140.0);
      final bannerRect = Rect.fromLTWH(0, height - bannerHeight, width, bannerHeight);

      // Dark translucent banner with orange/yellow forensic border
      final bannerPaint = Paint()..color = const Color(0xDD0B132B);
      canvas.drawRect(bannerRect, bannerPaint);

      final borderPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..strokeWidth = (width * 0.004).clamp(2.0, 6.0)
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(0, height - bannerHeight),
        Offset(width, height - bannerHeight),
        borderPaint,
      );

      // 3. Prepare Forensic Text
      final fontSizeMain = (bannerHeight * 0.22).clamp(10.0, 20.0);
      final fontSizeSub = (bannerHeight * 0.18).clamp(9.0, 16.0);

      final textStyleTitle = TextStyle(
        color: const Color(0xFFF59E0B),
        fontSize: fontSizeMain,
        fontWeight: FontWeight.bold,
      );

      final textStyleBody = TextStyle(
        color: Colors.white,
        fontSize: fontSizeSub,
        fontWeight: FontWeight.w500,
      );

      final latStr = location.latitude.toStringAsFixed(6);
      final lngStr = location.longitude.toStringAsFixed(6);
      final accStr = location.accuracy != null
          ? ' (±${location.accuracy!.toStringAsFixed(1)}m)'
          : '';

      final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

      // Row 1: Header + Police Badge Stamp
      final line1 = '🛡️ POLICE EVIDENCE SEAL | $stationName';
      textPainter.text = TextSpan(text: line1, style: textStyleTitle);
      textPainter.layout(maxWidth: width - 24);
      textPainter.paint(
        canvas,
        Offset(16, height - bannerHeight + (bannerHeight * 0.12)),
      );

      // Row 2: GPS Coordinates + Time
      final line2 = '📍 GPS: $latStr, $lngStr$accStr  •  🕒 ${location.timestamp} IST';
      textPainter.text = TextSpan(text: line2, style: textStyleBody);
      textPainter.layout(maxWidth: width - 24);
      textPainter.paint(
        canvas,
        Offset(16, height - bannerHeight + (bannerHeight * 0.42)),
      );

      // Row 3: Officer Name + Seva No
      final line3 = '👮 IO: $officerName [Seva: $officerSevaNo]  •  ORIGINAL SCENE CAPTURE';
      textPainter.text = TextSpan(
        text: line3,
        style: textStyleBody.copyWith(color: const Color(0xFFE2E8F0)),
      );
      textPainter.layout(maxWidth: width - 24);
      textPainter.paint(
        canvas,
        Offset(16, height - bannerHeight + (bannerHeight * 0.70)),
      );

      final picture = recorder.endRecording();
      final stampedImage = await picture.toImage(image.width, image.height);
      final byteData = await stampedImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
    } catch (e) {
      debugPrint('Error stamping evidence photo: $e');
    }
    return rawImageBytes;
  }
}
