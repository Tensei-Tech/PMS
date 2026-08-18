import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool isLight;

  const AppLogo({
    super.key,
    this.size = 80,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShieldLogoPainter(
          primaryColor: const Color(0xFF1A3A6B), // Deep Navy
          accentColor: const Color(0xFFC8A951), // Khaki Gold
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                size: size * 0.18,
                color: Colors.white,
              ),
              Icon(
                Icons.menu_book_rounded,
                size: size * 0.35,
                color: Colors.white,
              ),
              SizedBox(height: size * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShieldLogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  _ShieldLogoPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04;

    final Path path = Path();
    double w = size.width;
    double h = size.height;

    // Draw Shield Shape
    path.moveTo(w * 0.5, h * 0.05); // Top center
    path.quadraticBezierTo(w * 0.85, h * 0.05, w * 0.95, h * 0.15); // Top right
    path.lineTo(w * 0.95, h * 0.5); // Right side
    path.quadraticBezierTo(w * 0.95, h * 0.85, w * 0.5, h * 0.98); // Bottom center
    path.quadraticBezierTo(w * 0.05, h * 0.85, w * 0.05, h * 0.5); // Left side
    path.lineTo(w * 0.05, h * 0.15); // Left side up
    path.quadraticBezierTo(w * 0.15, h * 0.05, w * 0.5, h * 0.05); // Back to top
    path.close();

    // Shadow
    canvas.drawShadow(path.shift(const Offset(0, 4)), Colors.black.withValues(alpha: 0.3), 8.0, true);
    
    // Fill
    canvas.drawPath(path, paint);
    
    // Gradient accent overlay
    final Paint accentPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [accentColor.withValues(alpha: 0.2), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, accentPaint);

    // Border
    canvas.drawPath(path, borderPaint);
    
    // Inner Glow
    final Paint glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path.shift(const Offset(1, 1)), glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
