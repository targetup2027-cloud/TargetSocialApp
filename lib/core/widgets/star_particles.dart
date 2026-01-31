import 'package:flutter/material.dart';
import 'dart:math' as math;

class StarParticles extends StatelessWidget {
  final int count;
  final Color color;

  const StarParticles({
    super.key, 
    this.count = 20,
    this.color = const Color(0xFFFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarParticlesPainter(
        count: count,
        color: color,
      ),
      size: Size.infinite,
    );
  }
}

class _StarParticlesPainter extends CustomPainter {
  final int count;
  final Color color;
  final math.Random _random = math.Random(42); // Seeded for consistency

  _StarParticlesPainter({
    required this.count,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      // Position
      final double x = _random.nextDouble() * size.width;
      final double y = _random.nextDouble() * size.height;
      final Offset offset = Offset(x, y);

      // Size variation (Small, Medium, Large as per design)
      // 60% Small, 30% Medium, 10% Large
      final double r = _random.nextDouble();
      double radius;
      double opacity = 0.15; // Base opacity from spec

      if (r < 0.6) {
        // Small
        radius = _random.nextDouble() * 0.5 + 1.0; // 1.0 - 1.5
        opacity = 0.15;
      } else if (r < 0.9) {
        // Medium
        radius = _random.nextDouble() * 0.5 + 2.0; // 2.0 - 2.5
        opacity = 0.20;
      } else {
        // Large
        radius = _random.nextDouble() * 1.0 + 3.0; // 3.0 - 4.0
        opacity = 0.25;
      }

      paint.color = color.withValues(alpha: opacity);
      
      // Draw Main Star
      canvas.drawCircle(offset, radius, paint);

      // Optional: Add subtle glow to Large stars
      if (radius > 3.0) {
        final glowPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = color.withValues(alpha: 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(offset, radius * 2.5, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
