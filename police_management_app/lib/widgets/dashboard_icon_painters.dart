// lib/widgets/dashboard_icon_painters.dart
// Custom icon painters extracted from dashboard_screen.dart for faster builds.

import 'package:flutter/material.dart';

class CardsIconPainter extends CustomPainter {
  final Color color;
  CardsIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background card
    canvas.save();
    canvas.translate(w * 0.65, h * 0.45);
    canvas.rotate(0.3);
    final bgRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w * 0.55, height: h * 0.75),
        const Radius.circular(3));
    canvas.drawRRect(bgRect, Paint()..color = color);
    canvas.restore();

    // Foreground card
    canvas.save();
    canvas.translate(w * 0.35, h * 0.55);
    canvas.rotate(-0.15);
    final fgRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w * 0.6, height: h * 0.8),
        const Radius.circular(3));

    canvas.drawRRect(fgRect, Paint()..color = Colors.white);
    canvas.drawRRect(fgRect, Paint()..color = color);

    final spadePaint = Paint()..color = Colors.white;
    final path = Path();
    final sh = h * 0.3;
    final sw = w * 0.25;

    path.moveTo(0, -sh * 0.5);
    path.cubicTo(sw * 0.8, -sh * 0.1, sw * 0.8, sh * 0.3, sw * 0.4, sh * 0.3);
    path.cubicTo(sw * 0.2, sh * 0.3, 0, sh * 0.1, 0, sh * 0.1);
    path.cubicTo(0, sh * 0.1, -sw * 0.2, sh * 0.3, -sw * 0.4, sh * 0.3);
    path.cubicTo(-sw * 0.8, sh * 0.3, -sw * 0.8, -sh * 0.1, 0, -sh * 0.5);

    path.moveTo(0, sh * 0.1);
    path.lineTo(sw * 0.2, sh * 0.6);
    path.lineTo(-sw * 0.2, sh * 0.6);
    path.close();

    canvas.drawPath(path, spadePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class JuvenileIconPainter extends CustomPainter {
  final Color color;
  JuvenileIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final headCenterY = h * 0.25;
    final headRadius = w * 0.2;

    canvas.drawCircle(Offset(w * 0.5, headCenterY), headRadius, paint);
    canvas.drawCircle(Offset(w * 0.28, headCenterY), headRadius * 0.35, paint);
    canvas.drawCircle(Offset(w * 0.72, headCenterY), headRadius * 0.35, paint);

    final hairPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;

    final hairPath = Path();
    hairPath.moveTo(w * 0.5, headCenterY - headRadius);
    hairPath.cubicTo(w * 0.55, headCenterY - headRadius - h * 0.1, w * 0.4,
        headCenterY - headRadius - h * 0.1, w * 0.48, headCenterY - headRadius - h * 0.03);
    canvas.drawPath(hairPath, hairPaint);

    final whiteStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;

    final leftEyePath = Path();
    leftEyePath.moveTo(w * 0.37, headCenterY - h * 0.02);
    leftEyePath.quadraticBezierTo(w * 0.42, headCenterY + h * 0.04, w * 0.47, headCenterY - h * 0.02);
    canvas.drawPath(leftEyePath, whiteStroke);

    final rightEyePath = Path();
    rightEyePath.moveTo(w * 0.53, headCenterY - h * 0.02);
    rightEyePath.quadraticBezierTo(w * 0.58, headCenterY + h * 0.04, w * 0.63, headCenterY - h * 0.02);
    canvas.drawPath(rightEyePath, whiteStroke);

    final smilePath = Path();
    smilePath.moveTo(w * 0.42, headCenterY + h * 0.07);
    smilePath.quadraticBezierTo(w * 0.5, headCenterY + h * 0.12, w * 0.58, headCenterY + h * 0.07);
    canvas.drawPath(smilePath, whiteStroke);

    final barY = headCenterY + headRadius + h * 0.02;
    final scaleBottom = h * 0.95;

    canvas.drawLine(Offset(w * 0.25, barY), Offset(w * 0.75, barY), strokePaint);
    canvas.drawLine(Offset(w * 0.5, barY), Offset(w * 0.5, scaleBottom - h * 0.08), strokePaint);

    final basePath = Path();
    basePath.moveTo(w * 0.38, scaleBottom - h * 0.08);
    basePath.lineTo(w * 0.62, scaleBottom - h * 0.08);
    basePath.lineTo(w * 0.7, scaleBottom);
    basePath.lineTo(w * 0.3, scaleBottom);
    basePath.close();
    canvas.drawPath(basePath, paint);

    final stringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final panY = h * 0.78;
    canvas.drawLine(Offset(w * 0.25, barY), Offset(w * 0.15, panY), stringPaint);
    canvas.drawLine(Offset(w * 0.25, barY), Offset(w * 0.35, panY), stringPaint);

    final leftPanPath = Path();
    leftPanPath.arcTo(Rect.fromLTRB(w * 0.15, panY - (w * 0.1), w * 0.35, panY + (w * 0.1)), 0, 3.14159265359, false);
    leftPanPath.close();
    canvas.drawPath(leftPanPath, paint);

    canvas.drawLine(Offset(w * 0.75, barY), Offset(w * 0.65, panY), stringPaint);
    canvas.drawLine(Offset(w * 0.75, barY), Offset(w * 0.85, panY), stringPaint);

    final rightPanPath = Path();
    rightPanPath.arcTo(Rect.fromLTRB(w * 0.65, panY - (w * 0.1), w * 0.85, panY + (w * 0.1)), 0, 3.14159265359, false);
    rightPanPath.close();
    canvas.drawPath(rightPanPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SandTheftIconPainter extends CustomPainter {
  final Color color;
  SandTheftIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final chassisYTop = h * 0.75;
    final chassisYBot = h * 0.85;

    final r = w * 0.12;
    canvas.drawCircle(Offset(w * 0.25, h * 0.8), r, strokePaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.8), r, strokePaint);

    canvas.drawLine(Offset(w * 0.05, chassisYTop), Offset(w * 0.13, chassisYTop), strokePaint);
    canvas.drawLine(Offset(w * 0.05, chassisYBot), Offset(w * 0.13, chassisYBot), strokePaint);
    canvas.drawLine(Offset(w * 0.05, chassisYTop), Offset(w * 0.05, chassisYBot), strokePaint);
    canvas.drawLine(Offset(w * 0.37, chassisYTop), Offset(w * 0.63, chassisYTop), strokePaint);
    canvas.drawLine(Offset(w * 0.37, chassisYBot), Offset(w * 0.63, chassisYBot), strokePaint);
    canvas.drawLine(Offset(w * 0.87, chassisYTop), Offset(w * 0.95, chassisYTop), strokePaint);
    canvas.drawLine(Offset(w * 0.87, chassisYBot), Offset(w * 0.95, chassisYBot), strokePaint);
    canvas.drawLine(Offset(w * 0.95, chassisYTop), Offset(w * 0.95, chassisYBot), strokePaint);

    final cabPath = Path();
    cabPath.moveTo(w * 0.6, chassisYTop);
    cabPath.lineTo(w * 0.6, h * 0.3);
    cabPath.lineTo(w * 0.8, h * 0.3);
    cabPath.lineTo(w * 0.95, h * 0.55);
    cabPath.lineTo(w * 0.95, chassisYTop);
    canvas.drawPath(cabPath, strokePaint);

    final winPath = Path();
    winPath.moveTo(w * 0.68, h * 0.38);
    winPath.lineTo(w * 0.78, h * 0.38);
    winPath.lineTo(w * 0.86, h * 0.52);
    winPath.lineTo(w * 0.68, h * 0.52);
    winPath.close();
    canvas.drawPath(winPath, strokePaint);

    final bedPath = Path();
    bedPath.moveTo(w * 0.15, chassisYTop);
    bedPath.lineTo(w * 0.05, h * 0.4);
    bedPath.lineTo(w * 0.45, h * 0.2);
    bedPath.lineTo(w * 0.55, h * 0.15);
    bedPath.lineTo(w * 0.55, h * 0.5);
    bedPath.close();
    canvas.drawPath(bedPath, strokePaint);

    canvas.drawLine(Offset(w * 0.4, chassisYTop), Offset(w * 0.35, h * 0.6), strokePaint);

    final sandPath = Path();
    sandPath.moveTo(w * 0.1, h * 0.45);
    sandPath.quadraticBezierTo(w * 0.2, h * 0.35, w * 0.3, h * 0.45);
    sandPath.quadraticBezierTo(w * 0.4, h * 0.55, w * 0.5, h * 0.45);
    canvas.drawPath(sandPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class UndetectedIconPainter extends CustomPainter {
  final Color color;
  UndetectedIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22
      ..strokeCap = StrokeCap.round;

    final whiteStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = w * 0.6;
    final cy = h * 0.4;
    final r = w * 0.35;

    final handleStartX = cx - r * 0.707;
    final handleStartY = cy + r * 0.707;
    final handleEndX = w * 0.15;
    final handleEndY = h * 0.85;

    canvas.drawLine(Offset(handleStartX, handleStartY), Offset(handleEndX, handleEndY), handlePaint);

    final gapWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.butt;

    canvas.drawLine(Offset(handleStartX - w * 0.15, handleStartY - h * 0.15),
        Offset(handleStartX + w * 0.15, handleStartY + h * 0.15), gapWhite);

    canvas.drawCircle(Offset(cx, cy), r, paint);
    canvas.drawCircle(Offset(cx, cy), r * 0.5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.07);

    final xSize = r * 0.3;
    canvas.drawLine(Offset(cx - xSize, cy - xSize), Offset(cx + xSize, cy + xSize), whiteStroke);
    canvas.drawLine(Offset(cx + xSize, cy - xSize), Offset(cx - xSize, cy + xSize), whiteStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HurtIconPainter extends CustomPainter {
  final Color color;
  HurtIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawLine(Offset(w * 0.82, h * 0.15), Offset(w * 0.55, h * 0.42),
        Paint()
          ..color = color
          ..strokeWidth = w * 0.12
          ..strokeCap = StrokeCap.round);

    final blade = Path();
    blade.moveTo(w * 0.62, h * 0.3);
    blade.lineTo(w * 0.15, h * 0.77);
    blade.quadraticBezierTo(w * 0.3, h * 0.85, w * 0.52, h * 0.5);
    blade.close();
    canvas.drawPath(blade, paint);

    final cutPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.butt;

    canvas.drawLine(Offset(w * 0.58, h * 0.28), Offset(w * 0.72, h * 0.42), cutPaint);
    canvas.drawLine(Offset(w * 0.54, h * 0.32), Offset(w * 0.68, h * 0.46), cutPaint);

    final splat = Path();
    splat.moveTo(w * 0.35, h * 0.5);
    splat.cubicTo(w * 0.35, h * 0.4, w * 0.55, h * 0.4, w * 0.55, h * 0.5);
    splat.cubicTo(w * 0.65, h * 0.5, w * 0.65, h * 0.65, w * 0.6, h * 0.65);
    splat.cubicTo(w * 0.55, h * 0.65, w * 0.5, h * 0.55, w * 0.45, h * 0.6);
    splat.cubicTo(w * 0.4, h * 0.75, w * 0.3, h * 0.75, w * 0.3, h * 0.7);
    splat.cubicTo(w * 0.3, h * 0.6, w * 0.25, h * 0.6, w * 0.35, h * 0.5);

    canvas.drawPath(splat, Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeJoin = StrokeJoin.round);
    canvas.drawPath(splat, paint);

    void drawDrop(double cx, double cy, double s) {
      final drop = Path();
      drop.moveTo(cx, cy - s);
      drop.quadraticBezierTo(cx + s, cy, cx + s, cy + s * 0.5);
      drop.arcToPoint(Offset(cx - s, cy + s * 0.5), radius: Radius.circular(s), clockwise: true);
      drop.quadraticBezierTo(cx - s, cy, cx, cy - s);
      canvas.drawPath(drop, paint);

      final inner = Path();
      final innerS = s * 0.4;
      final innerCy = cy + s * 0.35;
      inner.moveTo(cx, innerCy - innerS);
      inner.quadraticBezierTo(cx + innerS, innerCy, cx + innerS, innerCy + innerS * 0.5);
      inner.arcToPoint(Offset(cx - innerS, innerCy + innerS * 0.5),
          radius: Radius.circular(innerS), clockwise: true);
      inner.quadraticBezierTo(cx - innerS, innerCy, cx, innerCy - innerS);
      canvas.drawPath(inner, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.015);
    }

    drawDrop(w * 0.5, h * 0.78, w * 0.06);
    drawDrop(w * 0.62, h * 0.88, w * 0.045);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class KidnappingIconPainter extends CustomPainter {
  final Color color;
  KidnappingIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final pStrokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(Offset(w * 0.75, h * 0.18), w * 0.12, fillPaint);

    canvas.drawLine(Offset(w * 0.75, h * 0.32), Offset(w * 0.75, h * 0.62),
        Paint()
          ..color = color
          ..strokeWidth = w * 0.2
          ..strokeCap = StrokeCap.round);

    canvas.drawLine(Offset(w * 0.67, h * 0.6), Offset(w * 0.67, h * 0.95), pStrokePaint);
    canvas.drawLine(Offset(w * 0.83, h * 0.6), Offset(w * 0.83, h * 0.95), pStrokePaint);

    final arms = Path();
    arms.moveTo(w * 0.52, h * 0.15);
    arms.lineTo(w * 0.52, h * 0.35);
    arms.lineTo(w * 0.75, h * 0.38);
    arms.lineTo(w * 0.98, h * 0.35);
    arms.lineTo(w * 0.98, h * 0.15);
    canvas.drawPath(arms, pStrokePaint);

    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.08, h * 0.45, w * 0.48, h * 0.57), Radius.circular(w * 0.02)),
        fillPaint);

    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.1, h * 0.41, w * 0.15, h * 0.45), Radius.circular(w * 0.01)),
        fillPaint);

    final grip = Path();
    grip.moveTo(w * 0.18, h * 0.57);
    grip.lineTo(w * 0.1, h * 0.88);
    grip.lineTo(w * 0.0, h * 0.88);
    grip.lineTo(w * 0.08, h * 0.57);
    grip.close();
    canvas.drawPath(grip, fillPaint);
    canvas.drawPath(grip, strokePaint..strokeWidth = w * 0.02);

    final guard = Path();
    guard.moveTo(w * 0.18, h * 0.57);
    guard.lineTo(w * 0.18, h * 0.65);
    guard.lineTo(w * 0.35, h * 0.65);
    guard.lineTo(w * 0.35, h * 0.57);
    canvas.drawPath(guard, strokePaint..strokeWidth = w * 0.035);

    canvas.drawLine(Offset(w * 0.25, h * 0.57), Offset(w * 0.23, h * 0.61),
        strokePaint..strokeWidth = w * 0.02);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ADIconPainter extends CustomPainter {
  final Color color;
  ADIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final puddle = Path();
    puddle.moveTo(w * 0.32, h * 0.63);
    puddle.cubicTo(w * 0.32, h * 0.85, w * 0.55, h * 1.0, w * 0.55, h * 0.75);
    puddle.cubicTo(w * 0.75, h * 0.75, w * 0.8, h * 0.5, w * 0.58, h * 0.37);
    puddle.close();
    canvas.drawPath(puddle, fillPaint);

    canvas.drawCircle(Offset(w * 0.7, h * 0.82), w * 0.05, fillPaint);

    canvas.drawLine(Offset(w * 0.1, h * 0.85), Offset(w * 0.7, h * 0.25),
        Paint()
          ..color = color
          ..strokeWidth = w * 0.05
          ..strokeCap = StrokeCap.round);

    canvas.drawCircle(Offset(w * 0.7, h * 0.18), w * 0.08, fillPaint);

    canvas.drawLine(Offset(w * 0.62, h * 0.28), Offset(w * 0.42, h * 0.48),
        Paint()
          ..color = color
          ..strokeWidth = w * 0.13
          ..strokeCap = StrokeCap.round);

    final lArm = Path();
    lArm.moveTo(w * 0.58, h * 0.32);
    lArm.lineTo(w * 0.35, h * 0.32);
    lArm.lineTo(w * 0.35, h * 0.46);
    canvas.drawPath(lArm, strokePaint);

    final rArm = Path();
    rArm.moveTo(w * 0.62, h * 0.28);
    rArm.lineTo(w * 0.72, h * 0.45);
    rArm.lineTo(w * 0.88, h * 0.28);
    canvas.drawPath(rArm, strokePaint);

    final lLeg = Path();
    lLeg.moveTo(w * 0.42, h * 0.48);
    lLeg.lineTo(w * 0.18, h * 0.48);
    lLeg.lineTo(w * 0.15, h * 0.65);
    canvas.drawPath(lLeg, strokePaint);

    final rLeg = Path();
    rLeg.moveTo(w * 0.42, h * 0.48);
    rLeg.lineTo(w * 0.32, h * 0.62);
    canvas.drawPath(rLeg, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
