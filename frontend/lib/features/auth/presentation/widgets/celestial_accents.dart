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
    _paintSaturnRings(canvas, size);
    _paintSaturn(canvas, size);
    _paintSaturnFrontRings(canvas, size);
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

  Offset _saturnCenter(Size size) =>
      Offset(size.width * 0.965, size.height * 0.255);

  double _saturnRadius(Size size) => size.width * 0.105;

  void _withRingTransform(Canvas canvas, Size size, VoidCallback paint) {
    final center = _saturnCenter(size);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.34 + progress * math.pi * 2);
    paint();
    canvas.restore();
  }

  void _drawRingLines(Canvas canvas, double radius) {
    for (var i = 0; i < 4; i++) {
      final inset = i * radius * 0.13;
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: radius * 3.2 - inset * 2,
        height: radius * 0.78 - inset * 0.45,
      );
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 1 ? 1.7 : 0.85
          ..color = const Color(0xFFFFC65A).withOpacity(0.24 + i * 0.055),
      );
    }
  }

  void _paintSaturnRings(Canvas canvas, Size size) {
    // The still image already contains Saturn here; these luminous rings animate over it.
    _withRingTransform(canvas, size, () => _drawRingLines(canvas, _saturnRadius(size)));
  }

  void _paintSaturn(Canvas canvas, Size size) {
    final center = _saturnCenter(size);
    final radius = _saturnRadius(size);
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.25),
          radius: 1.1,
          colors: [
            Color(0xFFFFE8A1),
            Color(0xFFD99A3F),
            Color(0xFF754016),
            Color(0xFF24130B),
          ],
          stops: [0, 0.38, 0.78, 1],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    for (var band = 0; band < 7; band++) {
      final y = center.dy - radius + (band + 1) * radius * 0.27 +
          math.sin(progress * math.pi * 2 + band) * radius * 0.08;
      final path = Path()
        ..moveTo(center.dx - radius, y)
        ..quadraticBezierTo(center.dx, y + radius * 0.12, center.dx + radius, y - radius * 0.04);
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFFFD77A).withOpacity(0.12 + (band % 3) * 0.035)
          ..strokeWidth = 1.2 + (band % 2)
          ..style = PaintingStyle.stroke,
      );
    }
    canvas.restore();
  }

  void _paintSaturnFrontRings(Canvas canvas, Size size) {
    _withRingTransform(canvas, size, () {
      final radius = _saturnRadius(size);
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(-radius * 2, 0, radius * 2, radius * 2));
      _drawRingLines(canvas, radius);
      canvas.restore();
    });
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
