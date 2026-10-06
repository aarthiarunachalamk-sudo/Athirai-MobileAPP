import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../theme/heritage_theme.dart';

/// Dynamic, Interactive 360° Jewellery Showcase
/// Replaces flat static images with:
/// - Smooth horizontal drag 360° turntable rotation
/// - Real-time dynamic specular light reflection (gold sheen sweep)
/// - Periodic gemstone sparkles & twinkling particles
/// - Interactive 3x Optical Hallmark & Stone Loupe (Magnifying Glass)
/// - Perspective angle switching
class DynamicJewelViewer extends StatefulWidget {
  const DynamicJewelViewer({
    super.key,
    required this.image,
    this.altImages = const [],
    this.productName = 'Cosmic Temple Necklace',
    this.tag = '22K BIS 916 Hallmarked',
    this.onOpenStudio,
    this.onOpenAr,
    this.onOpenVideo,
  });

  final String image;
  final List<String> altImages;
  final String productName;
  final String tag;
  final VoidCallback? onOpenStudio;
  final VoidCallback? onOpenAr;
  final VoidCallback? onOpenVideo;

  @override
  State<DynamicJewelViewer> createState() => _DynamicJewelViewerState();
}

class _DynamicJewelViewerState extends State<DynamicJewelViewer>
    with TickerProviderStateMixin {
  // 360 Rotation state
  double _rotationAngle = 0.0; // in degrees 0..360
  bool _isAutoSpinning = false;
  late final AnimationController _autoSpinController;

  // Shimmer / Gleam animation
  late final AnimationController _shimmerController;

  // Hallmark Loupe mode
  bool _isLoupeActive = false;
  Offset _loupePosition = const Offset(160, 140);

  // Sparkles
  final List<_SparklePoint> _sparkles = [
    _SparklePoint(Offset(0.48, 0.42), 0.0),
    _SparklePoint(Offset(0.35, 0.55), 0.3),
    _SparklePoint(Offset(0.62, 0.58), 0.6),
    _SparklePoint(Offset(0.50, 0.70), 0.8),
  ];
  late final AnimationController _sparkleController;

  late final List<String> _allAngles;

  @override
  void initState() {
    super.initState();
    _allAngles = [
      widget.image,
      if (widget.altImages.isNotEmpty) ...widget.altImages else ...[
        AppAssets.heritageHome,
        AppAssets.shopHero,
        AppAssets.heritageOnboarding,
      ]
    ];

    _autoSpinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addListener(() {
        if (_isAutoSpinning) {
          setState(() {
            _rotationAngle = (_autoSpinController.value * 360) % 360;
          });
        }
      });

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _autoSpinController.dispose();
    _shimmerController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isAutoSpinning) {
      setState(() => _isAutoSpinning = false);
      _autoSpinController.stop();
    }
    setState(() {
      _rotationAngle = (_rotationAngle + details.delta.dx * 0.85) % 360;
      if (_rotationAngle < 0) _rotationAngle += 360;
    });
  }

  void _toggleAutoSpin() {
    setState(() {
      _isAutoSpinning = !_isAutoSpinning;
      if (_isAutoSpinning) {
        _autoSpinController.repeat();
      } else {
        _autoSpinController.stop();
      }
    });
  }

  int get _activeAngleIndex {
    final step = 360 / _allAngles.length;
    final idx = ((_rotationAngle + step / 2) ~/ step) % _allAngles.length;
    return idx.clamp(0, _allAngles.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8DCCB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Luxury Palace Arch Background with Ambient Spotlight
            CustomPaint(
              painter: _ShowcaseLightingPainter(),
            ),

            // 2. Interactive 360 Turntable Touch Area
            GestureDetector(
              onHorizontalDragUpdate: _isLoupeActive ? null : _onHorizontalDragUpdate,
              onPanUpdate: _isLoupeActive
                  ? (details) {
                      setState(() => _loupePosition = details.localPosition);
                    }
                  : null,
              child: Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_shimmerController, _sparkleController]),
                  builder: (context, _) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // The Jewellery Image with dynamic 3D turntable tilt
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // perspective
                            ..rotateY(math.sin(_rotationAngle * math.pi / 180) * 0.38)
                            ..rotateZ(math.sin(_rotationAngle * math.pi / 180) * 0.03),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 250, maxWidth: 280),
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              _allAngles[_activeAngleIndex],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.diamond_outlined,
                                size: 80,
                                color: HeritageTheme.gold,
                              ),
                            ),
                          ),
                        ),

                        // Metallic Specular Reflection Sweep
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _MetallicReflectionPainter(
                                angleProgress: _rotationAngle / 360,
                                shimmerProgress: _shimmerController.value,
                              ),
                            ),
                          ),
                        ),

                        // Twinkling Gemstone Sparkles
                        if (!_isLoupeActive)
                          for (final sp in _sparkles)
                            Positioned(
                              left: 280 * sp.position.dx,
                              top: 250 * sp.position.dy,
                              child: IgnorePointer(
                                child: _buildSparkleWidget(sp),
                              ),
                            ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // 3. Optical Hallmark Loupe Overlay (when active)
            if (_isLoupeActive)
              Positioned(
                left: _loupePosition.dx - 55,
                top: _loupePosition.dy - 55,
                child: IgnorePointer(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: HeritageTheme.gold, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Container(
                        color: Colors.white,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 3x Zoomed image
                            Transform.scale(
                              scale: 2.8,
                              child: Image.asset(
                                _allAngles[_activeAngleIndex],
                                fit: BoxFit.contain,
                              ),
                            ),
                            // Crosshair inspection reticle
                            CustomPaint(
                              size: const Size(110, 110),
                              painter: _LoupeReticlePainter(),
                            ),
                            // Hallmark certified indicator
                            Positioned(
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: HeritageTheme.maroon.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'BIS 916 • 3X',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 4. Header Badges: Dynamic Angle & Hallmark
            Positioned(
              top: 14,
              left: 14,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: HeritageTheme.gold.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.threed_rotation_rounded, size: 14, color: HeritageTheme.gold),
                        const SizedBox(width: 5),
                        Text(
                          '${_rotationAngle.toInt()}° 360 View',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF073B3F), // Infisq Emerald
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.tag,
                      style: const TextStyle(
                        color: Color(0xFFCCA881),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 5. Floating Interactive Controls (Right Side)
            Positioned(
              right: 12,
              top: 48,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 3D View Interactive Turntable Toggle
                  _buildControlPill(
                    icon: _isAutoSpinning ? Icons.pause_circle_rounded : Icons.threed_rotation_rounded,
                    label: '3D View',
                    isActive: _isAutoSpinning,
                    onTap: _toggleAutoSpin,
                  ),
                  const SizedBox(height: 6),

                  // AR Try-on Flow
                  _buildControlPill(
                    icon: Icons.auto_awesome_rounded,
                    label: 'AR Try',
                    isActive: false,
                    onTap: widget.onOpenAr,
                  ),
                  const SizedBox(height: 6),

                  // Video Showcase Flow
                  _buildControlPill(
                    icon: Icons.play_circle_outline_rounded,
                    label: 'Video',
                    isActive: false,
                    onTap: widget.onOpenVideo ?? _toggleAutoSpin,
                  ),
                  const SizedBox(height: 6),

                  // 3x Hallmark Loupe Inspection
                  _buildControlPill(
                    icon: Icons.zoom_in_rounded,
                    label: _isLoupeActive ? 'Exit' : '3X Loupe',
                    isActive: _isLoupeActive,
                    onTap: () => setState(() => _isLoupeActive = !_isLoupeActive),
                  ),
                  const SizedBox(height: 6),

                  // Live Camera Studio & Valuation Flow
                  _buildControlPill(
                    icon: Icons.camera_alt_outlined,
                    label: 'Studio',
                    isActive: false,
                    onTap: widget.onOpenStudio,
                  ),
                ],
              ),
            ),

            // 6. Bottom Turntable Slider Hint
            Positioned(
              bottom: 10,
              left: 14,
              right: 14,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8DCCB)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.swipe_rounded, size: 14, color: HeritageTheme.maroon),
                      const SizedBox(width: 6),
                      Text(
                        _isLoupeActive
                            ? 'Drag finger to inspect hallmark & gemstones'
                            : 'Drag left/right to rotate jewellery 360°',
                        style: HeritageTheme.sans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: HeritageTheme.ebony,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSparkleWidget(_SparklePoint sp) {
    final phase = (_sparkleController.value + sp.phaseOffset) % 1.0;
    final scale = math.sin(phase * math.pi);
    if (scale <= 0.01) return const SizedBox.shrink();

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFFF7C2),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.star_rounded,
          size: 14,
          color: Color(0xFFFFF092),
        ),
      ),
    );
  }

  Widget _buildControlPill({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? HeritageTheme.maroon
              : Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? HeritageTheme.gold : const Color(0xFFE0D5C5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : HeritageTheme.ebony,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : HeritageTheme.ebony,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparklePoint {
  _SparklePoint(this.position, this.phaseOffset);
  final Offset position;
  final double phaseOffset;
}

/// Dynamic metallic gold reflection shader painter
class _MetallicReflectionPainter extends CustomPainter {
  _MetallicReflectionPainter({
    required this.angleProgress,
    required this.shimmerProgress,
  });

  final double angleProgress;
  final double shimmerProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final sweepProgress = (angleProgress * 1.5 + shimmerProgress * 0.5) % 1.5 - 0.25;
    final startX = size.width * sweepProgress;
    const bandWidth = 90.0;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.transparent,
        HeritageTheme.goldLight.withValues(alpha: 0.12),
        Colors.white.withValues(alpha: 0.28),
        HeritageTheme.goldLight.withValues(alpha: 0.12),
        Colors.transparent,
      ],
      stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(startX - bandWidth, 0, bandWidth * 2, size.height),
      );

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _MetallicReflectionPainter oldDelegate) =>
      angleProgress != oldDelegate.angleProgress ||
      shimmerProgress != oldDelegate.shimmerProgress;
}

/// Ambient spotlight painter inside the showcase arch
class _ShowcaseLightingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final radial = RadialGradient(
      colors: [
        Colors.white.withValues(alpha: 0.9),
        const Color(0xFFF7F2E9).withValues(alpha: 0.6),
        const Color(0xFFECE3D4),
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = radial.createShader(
        Rect.fromCircle(center: center, radius: size.width * 0.6),
      );

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Loupe inspection crosshair painter
class _LoupeReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HeritageTheme.gold.withValues(alpha: 0.8)
      ..strokeWidth = 0.8;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawLine(Offset(cx - 15, cy), Offset(cx - 4, cy), paint);
    canvas.drawLine(Offset(cx + 4, cy), Offset(cx + 15, cy), paint);
    canvas.drawLine(Offset(cx, cy - 15), Offset(cx, cy - 4), paint);
    canvas.drawLine(Offset(cx, cy + 4), Offset(cx, cy + 15), paint);

    canvas.drawCircle(
      Offset(cx, cy),
      8,
      paint..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
