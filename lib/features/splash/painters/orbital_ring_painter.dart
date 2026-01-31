import 'dart:math';
import 'package:flutter/material.dart';

class OrbitalRingPainter extends CustomPainter {
  final double rotationAngle;
  final double animationValue;

  OrbitalRingPainter({
    required this.rotationAngle,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.35;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    final glowPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.3 * animationValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(center, radius, glowPaint);

    final ringPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.6 * animationValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, ringPaint);

    final dotCount = 60;
    final dotPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.5 * animationValue)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < dotCount; i++) {
      final angle = (2 * pi / dotCount) * i;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      if (i % 5 == 0) {
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(OrbitalRingPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.animationValue != animationValue;
  }
}
