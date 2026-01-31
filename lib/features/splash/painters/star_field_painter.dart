import 'dart:math';
import 'package:flutter/material.dart';

class Star {
  final Offset position;
  final double radius;
  final double opacity;

  const Star({
    required this.position,
    required this.radius,
    required this.opacity,
  });
}

class StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final List<(int, int)> connections;
  final double animationValue;

  StarFieldPainter({
    required this.stars,
    required this.connections,
    required this.animationValue,
  });

  static List<Star> generateStars(Size size, {int seed = 42}) {
    final random = Random(seed);
    final stars = <Star>[];
    final starCount = 80;

    for (var i = 0; i < starCount; i++) {
      final sizeCategory = random.nextInt(3);
      double radius;
      double opacity;

      switch (sizeCategory) {
        case 0:
          radius = 1.0 + random.nextDouble() * 0.5;
          opacity = 0.4 + random.nextDouble() * 0.2;
          break;
        case 1:
          radius = 1.5 + random.nextDouble() * 0.5;
          opacity = 0.5 + random.nextDouble() * 0.2;
          break;
        default:
          radius = 2.0 + random.nextDouble() * 1.0;
          opacity = 0.6 + random.nextDouble() * 0.3;
      }

      stars.add(Star(
        position: Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        radius: radius,
        opacity: opacity,
      ));
    }

    return stars;
  }

  static List<(int, int)> generateConnections(List<Star> stars, {int seed = 42}) {
    final random = Random(seed + 100);
    final connections = <(int, int)>[];
    final connectionCount = 15;

    for (var i = 0; i < connectionCount && i < stars.length - 1; i++) {
      final from = random.nextInt(stars.length);
      var to = random.nextInt(stars.length);
      while (to == from) {
        to = random.nextInt(stars.length);
      }

      final distance = (stars[from].position - stars[to].position).distance;
      if (distance < 250) {
        connections.add((from, to));
      }
    }

    return connections;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const starColor = Color(0xFF8B7FFF);

    for (final star in stars) {
      final paint = Paint()
        ..color = starColor.withValues(alpha: star.opacity * animationValue)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(star.position, star.radius, paint);
    }

    for (final connection in connections) {
      if (connection.$1 < stars.length && connection.$2 < stars.length) {
        final from = stars[connection.$1];
        final to = stars[connection.$2];

        final paint = Paint()
          ..color = starColor.withValues(alpha: 0.25 * animationValue)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke;

        canvas.drawLine(from.position, to.position, paint);
      }
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
