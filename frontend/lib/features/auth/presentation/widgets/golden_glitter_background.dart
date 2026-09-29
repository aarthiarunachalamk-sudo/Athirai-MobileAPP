import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

enum ParticleType { tinyDot, fourPointStar, softGlow, largeFlare }

class GlitterParticle {
  final double x; // Normalized 0.0 to 1.0
  final double y; // Normalized 0.0 to 1.0
  final double size;
  final ParticleType type;
  final Color color;
  final double speed; // Phase speed multiplier
  final double phaseOffset; // 0.0 to 2*pi
  final double driftX;
  final double driftY;

  const GlitterParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.type,
    required this.color,
    required this.speed,
    required this.phaseOffset,
    required this.driftX,
    required this.driftY,
  });
}

class GoldenGlitterBackground extends StatefulWidget {
  final Widget? child;
  final int particleCount;
  final bool showTrails;

  const GoldenGlitterBackground({
    super.key,
    this.child,
    this.particleCount = 55,
    this.showTrails = false,
  });

  @override
  State<GoldenGlitterBackground> createState() =>
      _GoldenGlitterBackgroundState();
}

class _GoldenGlitterBackgroundState extends State<GoldenGlitterBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<GlitterParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _particles = _generateDeterministicParticles(widget.particleCount);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static List<GlitterParticle> _generateDeterministicParticles(int count) {
    // Deterministic random seed ensures consistent luxury appearance
    final rng = math.Random(1337);
    final colors = [
      const Color(0xFFFFD978),
      const Color(0xFFE8B84C),
      const Color(0xFFC9902E),
      const Color(0xFFFFF0B8),
    ];

    final particles = <GlitterParticle>[];
    for (int i = 0; i < count; i++) {
      ParticleType type;
      double size;
      if (i % 12 == 0) {
        type = ParticleType.largeFlare;
        size = 9.0 + rng.nextDouble() * 6.0;
      } else if (i % 4 == 0) {
        type = ParticleType.fourPointStar;
        size = 3.0 + rng.nextDouble() * 4.0;
      } else if (i % 3 == 0) {
        type = ParticleType.softGlow;
        size = 2.0 + rng.nextDouble() * 3.0;
      } else {
        type = ParticleType.tinyDot;
        size = 0.7 + rng.nextDouble() * 1.2;
      }

      particles.add(
        GlitterParticle(
          x: rng.nextDouble(),
          y: rng.nextDouble(),
          size: size,
          type: type,
          color: colors[rng.nextInt(colors.length)],
          speed: 1.0 + rng.nextInt(2),
          phaseOffset: rng.nextDouble() * 2 * math.pi,
          driftX: (rng.nextDouble() - 0.5) * 16.0,
          driftY: (rng.nextDouble() - 0.5) * 20.0,
        ),
      );
    }
    return particles;
  }

  @override
  Widget build(BuildContext context) {
    // Respect accessibility: if user prefers reduced motion, render static particles
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: _GlitterPainter(
              particles: _particles,
              animation: _controller,
              reduceMotion: reduceMotion,
              showTrails: widget.showTrails,
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _GlitterPainter extends CustomPainter {
  final List<GlitterParticle> particles;
  final Animation<double> animation;
  final bool reduceMotion;
  final bool showTrails;
  double get progress => reduceMotion ? 0.5 : animation.value;

  _GlitterPainter({
    required this.particles,
    required this.animation,
    required this.reduceMotion,
    required this.showTrails,
  }) : super(repaint: reduceMotion ? null : animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    if (showTrails) _drawTrails(canvas, size);

    for (final p in particles) {
      final t = (progress * 2 * math.pi * p.speed + p.phaseOffset);

      // Twinkle opacity from 0.15 to 1.0
      final wave = (math.sin(t) + 1.0) / 2.0; // 0.0 to 1.0
      final opacity = (0.05 + 0.95 * wave * wave).clamp(0.0, 1.0);

      // Slight scale 0.75 to 1.15
      final scale = 0.5 + 0.85 * wave;

      // Slow drift
      final driftWave = math.sin(t);
      final px = (p.x * size.width + p.driftX * driftWave) % size.width;
      final py = (p.y * size.height + p.driftY * driftWave) % size.height;

      final currentSize = p.size * scale;

      switch (p.type) {
        case ParticleType.tinyDot:
          paint.color = p.color.withOpacity(opacity);
          paint.maskFilter = null;
          canvas.drawCircle(Offset(px, py), currentSize / 2, paint);
          break;

        case ParticleType.softGlow:
          paint.color = p.color.withOpacity(opacity * 0.7);
          paint.maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            currentSize * 0.6,
          );
          canvas.drawCircle(Offset(px, py), currentSize / 2, paint);
          break;

        case ParticleType.fourPointStar:
          _drawFourPointStar(
            canvas,
            Offset(px, py),
            currentSize,
            p.color.withOpacity(opacity),
          );
          break;

        case ParticleType.largeFlare:
          _drawLargeFlare(
            canvas,
            Offset(px, py),
            currentSize,
            p.color,
            opacity,
          );
          break;
      }
    }
  }

  void _drawTrails(Canvas canvas, Size size) {
    // Four streams follow the gold ribbons in the sign-in artwork.
    final paths = [
      Path()
        ..moveTo(1.03, 0.065)
        ..cubicTo(0.95, 0.12, 0.79, 0.14, 0.65, 0.165),
      Path()
        ..moveTo(0.15, 0.22)
        ..cubicTo(-0.07, 0.27, -0.04, 0.33, 0.105, 0.365),
      Path()
        ..moveTo(-0.025, 0.625)
        ..cubicTo(0.015, 0.68, 0.11, 0.73, 0.26, 0.765),
      Path()
        ..moveTo(1.025, 0.74)
        ..cubicTo(0.99, 0.80, 0.85, 0.84, 0.63, 0.865),
    ];
    final transform = Matrix4.diagonal3Values(size.width, size.height, 1);
    final dustPaint = Paint()..isAntiAlias = true;
    for (var ribbon = 0; ribbon < paths.length; ribbon++) {
      final metric = paths[ribbon]
          .transform(transform.storage)
          .computeMetrics()
          .first;
      // Deterministic seeds keep each grain on its own lane across frames.
      final random = math.Random(812 + ribbon);
      for (var i = 0; i < 150; i++) {
        final offset = random.nextDouble();
        final lane = (random.nextDouble() - 0.5) * size.width * 0.055;
        final radius = 0.35 + random.nextDouble() * 1.15;
        final phase = random.nextDouble() * math.pi * 2;
        final position = (progress + offset) % 1;
        final tangent = metric.getTangentForOffset(metric.length * position)!;
        final normal = Offset(-tangent.vector.dy, tangent.vector.dx);
        final flutter = math.sin(progress * math.pi * 4 + phase) * 2;
        final center = tangent.position + normal * (lane + flutter);
        final fade = (math.sin(math.pi * position) * 4).clamp(0.0, 1.0);
        final shimmer =
            0.35 + 0.65 * math.pow(math.sin(progress * math.pi * 6 + phase), 2);
        final opacity = (fade * shimmer).clamp(0.0, 1.0);
        dustPaint.color =
            (i.isEven ? const Color(0xFFFFE9B0) : const Color(0xFFFFB82E))
                .withOpacity(opacity);
        canvas.drawCircle(center, radius, dustPaint);
      }
      // Bright clusters sweep through the dust, making the ribbons visibly flow.
      for (var i = 0; i < 3; i++) {
        final position = (progress + i / 3 + ribbon * 0.17) % 1;
        final tangent = metric.getTangentForOffset(metric.length * position)!;
        final fade = math.sin(math.pi * position);
        for (var tail = 1; tail <= 6; tail++) {
          final tailPosition = position - tail * 0.008;
          if (tailPosition <= 0) continue;
          final point = metric
              .getTangentForOffset(metric.length * tailPosition)!
              .position;
          dustPaint.color = const Color(0xFFFFC653)
              .withOpacity(fade * (1 - tail / 7) * 0.65);
          canvas.drawCircle(point, 2.8 - tail * 0.25, dustPaint);
        }
        _drawLargeFlare(
          canvas,
          tangent.position,
          10,
          const Color(0xFFFFD578),
          fade,
        );
      }
    }
  }

  void _drawFourPointStar(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
  ) {
    final half = size / 2;
    final thin = size * 0.14;

    final path = Path();
    // Top
    path.moveTo(center.dx, center.dy - half);
    path.quadraticBezierTo(
      center.dx + thin,
      center.dy - thin,
      center.dx + half,
      center.dy,
    );
    // Right
    path.quadraticBezierTo(
      center.dx + thin,
      center.dy + thin,
      center.dx,
      center.dy + half,
    );
    // Bottom
    path.quadraticBezierTo(
      center.dx - thin,
      center.dy + thin,
      center.dx - half,
      center.dy,
    );
    // Left
    path.quadraticBezierTo(
      center.dx - thin,
      center.dy - thin,
      center.dx,
      center.dy - half,
    );
    path.close();

    final starPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = null;
    canvas.drawPath(path, starPaint);

    // Subtle center glow
    final glowPaint = Paint()
      ..color = AppColors.goldChampagne.withOpacity(color.opacity * 0.8)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.25);
    canvas.drawCircle(center, thin * 1.2, glowPaint);
  }

  void _drawLargeFlare(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double opacity,
  ) {
    final gradient = RadialGradient(
      colors: [
        AppColors.goldBright.withOpacity(opacity * 0.9),
        color.withOpacity(opacity * 0.45),
        color.withOpacity(0.0),
      ],
      stops: const [0.0, 0.4, 1.0],
    );

    final rect = Rect.fromCircle(center: center, radius: radius);
    final flarePaint = Paint()
      ..shader = gradient.createShader(rect)
      ..maskFilter = null;
    canvas.drawCircle(center, radius, flarePaint);

    // Subtle 4-point beam crossing the flare
    _drawFourPointStar(
      canvas,
      center,
      radius * 1.5,
      color.withOpacity(opacity * 0.75),
    );
  }

  @override
  bool shouldRepaint(covariant _GlitterPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.particles != particles ||
        oldDelegate.reduceMotion != reduceMotion ||
        oldDelegate.showTrails != showTrails;
  }
}
