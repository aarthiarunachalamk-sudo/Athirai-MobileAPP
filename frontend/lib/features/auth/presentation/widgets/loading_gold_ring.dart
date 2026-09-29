import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LoadingGoldRing extends StatefulWidget {
  final double size;

  const LoadingGoldRing({
    super.key,
    this.size = 100,
  });

  @override
  State<LoadingGoldRing> createState() => _LoadingGoldRingState();
}

class _LoadingGoldRingState extends State<LoadingGoldRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final val = _controller.value;
        final pulse = 0.95 + 0.05 * math.sin(val * 2 * math.pi);

        return Transform.scale(
          scale: pulse,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft background radial aura
                Container(
                  width: widget.size * 0.9,
                  height: widget.size * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.goldBright.withOpacity(0.18),
                        AppColors.goldPrimary.withOpacity(0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                // Rotating glowing gold sweep ring
                Transform.rotate(
                  angle: val * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _GoldRingPainter(),
                  ),
                ),

                // Center subtle star flare
                Transform.rotate(
                  angle: -val * math.pi,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.goldChampagne.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldBright,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GoldRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Glowing track
    final sweepGradient = SweepGradient(
      colors: [
        AppColors.goldBright.withOpacity(0.0),
        AppColors.goldPrimary.withOpacity(0.4),
        AppColors.goldBright,
        Colors.white,
      ],
      stops: const [0.0, 0.6, 0.92, 1.0],
    );

    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    // Draw the glowing arc (~280 degrees)
    canvas.drawArc(rect, 0.0, 5.0, false, paint);

    // Head flare bead
    final headAngle = 5.0;
    final hx = center.dx + radius * math.cos(headAngle);
    final hy = center.dy + radius * math.sin(headAngle);

    final beadPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawCircle(Offset(hx, hy), 3.0, beadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
