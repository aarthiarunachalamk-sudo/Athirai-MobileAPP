import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lightweight sparkle and rotating ring accents over a static cosmic image.
class CelestialAccents extends CustomPainter {
  CelestialAccents({required this.progress});

  final double progress;
  static final List<_Star> _stars = _makeStars();

  static List<_Star> _makeStars() {
    final random = math.Random(41);
    return List.generate(
      62,
      (_) => _Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: 0.6 + random.nextDouble() * 1.5,
        phase: random.nextDouble() * math.pi * 2,
        speed: 1 + random.nextInt(3),
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintStars(canvas, size);
  }


  void _paintStars(Canvas canvas, Size size) {
    for (final star in _stars) {
      final pulse = (math.sin(progress * math.pi * 2 * star.speed + star.phase) + 1) / 2;
      final alpha = 0.12 + pulse * 0.72;
      final center = Offset(size.width * star.x, size.height * star.y);
      final paint = Paint()..color = const Color(0xFFFFD77A).withOpacity(alpha);
      canvas.drawCircle(center, star.radius * (0.65 + pulse * 0.55), paint);

      if (star.radius > 1.65 && pulse > 0.72) {
        final flare = Paint()
          ..color = const Color(0xFFFFE8B0).withOpacity(alpha * 0.75)
          ..strokeWidth = 0.7
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          center.translate(-star.radius * 2.2, 0),
          center.translate(star.radius * 2.2, 0),
          flare,
        );
        canvas.drawLine(
          center.translate(0, -star.radius * 2.2),
          center.translate(0, star.radius * 2.2),
          flare,
        );
      }
    }
  }
  @override
  bool shouldRepaint(covariant CelestialAccents oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Star {
  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.phase,
    required this.speed,
  });

  final double x;
  final double y;
  final double radius;
  final double phase;
  final int speed;
}
