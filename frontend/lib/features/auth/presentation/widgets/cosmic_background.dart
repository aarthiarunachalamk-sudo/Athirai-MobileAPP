import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';

class CosmicBackground extends StatefulWidget {
  final Widget child;
  final String imageAsset;
  final double overlayOpacity;
  final bool showGlitter;
  final bool showFrame;

  const CosmicBackground({
    super.key,
    required this.child,
    this.imageAsset = AppAssets.signInReferenceBg,
    this.overlayOpacity = 0.04,
    this.showGlitter = true,
    this.showFrame = false,
  });

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glitterMotion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _glitterMotion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Keep the supplied artwork fixed; animate only the fine glitter.
        Image.asset(
          widget.imageAsset,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
        ),
        if (widget.showGlitter && !reducedMotion)
          IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _CrosswiseGlitterPainter(_glitterMotion),
              ),
            ),
          ),
        Container(color: Colors.black.withOpacity(widget.overlayOpacity)),
        if (widget.showFrame)
          Positioned.fill(
            child: IgnorePointer(
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: const Color(0xFFBA8A38),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33DFA63C),
                        blurRadius: 7,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        widget.child,
      ],
    );
  }
}

class _CrosswiseGlitterPainter extends CustomPainter {
  _CrosswiseGlitterPainter(Animation<double> motion)
    : motion = motion,
      super(repaint: motion);

  final Animation<double> motion;

  static final List<_GlitterParticle> _particles = List.generate(70, (index) {
    final random = math.Random(index * 137 + 29);
    return _GlitterParticle(
      Offset(random.nextDouble(), random.nextDouble()),
      0.75 + random.nextDouble() * 0.80,
      random.nextDouble() * math.pi * 2,
      0.24 + random.nextDouble() * 0.22,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final phase = motion.value;
    final twinklePhase = phase * math.pi * 2;

    for (final particle in _particles) {
      // Travel diagonally across the fixed artwork, then wrap quietly to repeat.
      final x = (particle.position.dx + phase * 0.48) % 1.0;
      final y = (particle.position.dy - phase * 0.48) % 1.0;
      final point = Offset(x * size.width, y * size.height);
      final shimmer = (math.sin(twinklePhase + particle.phase) + 1) / 2;
      final opacity = particle.opacity * (0.38 + shimmer * 0.62);
      final radius = particle.radius * (0.76 + shimmer * 0.42);

      final glow = Paint()
        ..color = const Color(0xFFFFCF72).withOpacity(opacity * 0.36)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 3.2);
      final core = Paint()
        ..color = const Color(0xFFFFE7AE).withOpacity(opacity);
      final trail = Paint()
        ..color = const Color(0xFFFFCF72).withOpacity(opacity * 0.34)
        ..strokeWidth = math.max(0.45, radius * 0.38)
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        point + Offset(-radius * 4.5, radius * 4.5),
        point,
        trail,
      );
      canvas.drawCircle(point, radius * 2.2, glow);
      canvas.drawCircle(point, radius * 0.62, core);
    }
  }

  @override
  bool shouldRepaint(covariant _CrosswiseGlitterPainter oldDelegate) => false;
}

class _GlitterParticle {
  const _GlitterParticle(this.position, this.radius, this.phase, this.opacity);

  final Offset position;
  final double radius;
  final double phase;
  final double opacity;
}
