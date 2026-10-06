import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/gold_primary_button.dart';
import 'selfie_capture_screen.dart';

/// Elaborate, complete cinematic model video / avatar displayed at center.
class CinematicAvatarAnimation extends StatefulWidget {
  const CinematicAvatarAnimation({super.key});

  @override
  State<CinematicAvatarAnimation> createState() =>
      _CinematicAvatarAnimationState();
}

class _CinematicAvatarAnimationState extends State<CinematicAvatarAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  VideoPlayerController? _videoCtrl;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final ctrl = VideoPlayerController.asset(AppAssets.entryModelVideo);
      await ctrl.initialize();
      await ctrl.setLooping(true);
      await ctrl.setVolume(0.0);
      await ctrl.play();
      if (mounted) {
        setState(() {
          _videoCtrl = ctrl;
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Video initialization fallback: $e');
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return AnimatedBuilder(
          animation: Listenable.merge([_intro, _ambient]),
          builder: (context, _) {
            final reveal = Curves.easeOutCubic.transform(_intro.value);
            final breathe = (math.sin(_ambient.value * math.pi * 2) + 1) / 2;

            return Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                // Subtle ambient starlight particles
                IgnorePointer(
                  child: CustomPaint(
                    painter: _CelestialStarsPainter(
                      reveal: reveal,
                      ambient: _ambient.value,
                    ),
                  ),
                ),

                // Complete, elaborate model video / artwork in full splendor (no circle crop, no outline)
                Center(
                  child: RepaintBoundary(
                    child: Opacity(
                      opacity: reveal,
                      child: Transform.scale(
                        scale: 0.98 + breathe * 0.025,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: width,
                            maxHeight: height,
                          ),
                          child: _buildModelMedia(width, height),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildModelMedia(double width, double height) {
    Widget media;
    if (_isVideoInitialized && _videoCtrl != null) {
      media = SizedBox(
        width: _videoCtrl!.value.size.width,
        height: _videoCtrl!.value.size.height,
        child: VideoPlayer(_videoCtrl!),
      );
    } else {
      media = Image.asset(
        AppAssets.frontModel,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        gaplessPlayback: true,
      );
    }

    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.center,
      child: _featherEdges(media),
    );
  }

  Widget _featherEdges(Widget child) {
    return ShaderMask(
      // Vertical feathering (top & bottom borders dissolve seamlessly)
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [0.0, 0.12, 0.88, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: ShaderMask(
        // Horizontal feathering (left & right borders dissolve seamlessly)
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            stops: [0.0, 0.08, 0.92, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: child,
      ),
    );
  }
}

/// A celestial reveal screen showcasing the complete, elaborate artwork.
class CinematicRevealScreen extends StatefulWidget {
  const CinematicRevealScreen({super.key});

  @override
  State<CinematicRevealScreen> createState() => _CinematicRevealScreenState();
}

class _CinematicRevealScreenState extends State<CinematicRevealScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..forward();
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  void _continueToSelfie() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SelfieCaptureScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final imageWidth = size.width * 0.92;
    final imageHeight = size.height * 0.58;

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: AnimatedBuilder(
        animation: Listenable.merge([_intro, _ambient]),
        builder: (context, _) {
          final reveal = Curves.easeOutCubic.transform(
            ((_intro.value - 0.20) / 0.50).clamp(0.0, 1.0),
          );
          final breathe = (math.sin(_ambient.value * math.pi * 2) + 1) / 2;

          return Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.05),
                    radius: 0.95,
                    colors: [
                      Color(0xFF221404),
                      Color(0xFF080603),
                      Color(0xFF020202),
                    ],
                    stops: [0, 0.50, 1],
                  ),
                ),
              ),
              IgnorePointer(
                child: CustomPaint(
                  painter: _CelestialStarsPainter(
                    reveal: reveal,
                    ambient: _ambient.value,
                  ),
                ),
              ),
              Center(
                child: RepaintBoundary(
                  child: Opacity(
                    opacity: reveal,
                    child: Transform.scale(
                      scale: 0.97 + breathe * 0.03,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: math.min(imageWidth, imageHeight) * 0.92,
                            height: math.min(imageWidth, imageHeight) * 0.92,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.goldPrimary.withOpacity(
                                    0.18 + breathe * 0.10,
                                  ),
                                  AppColors.goldPrimary.withOpacity(0.04),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.55, 1.0],
                              ),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: imageWidth,
                              maxHeight: imageHeight,
                            ),
                            child: Image.asset(
                              AppAssets.cinematicAvatar,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              gaplessPlayback: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 28,
                right: 28,
                bottom: 38 + MediaQuery.paddingOf(context).bottom,
                child: Opacity(
                  opacity: Curves.easeIn.transform(
                    ((_intro.value - 0.70) / 0.30).clamp(0.0, 1.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'YOUR CELESTIAL JOURNEY BEGINS',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cormorantGaramond(
                          color: AppColors.goldBright,
                          fontSize: 18,
                          letterSpacing: 2.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      GoldPrimaryButton(
                        text: 'Create Your AI Avatar',
                        showArrow: true,
                        onPressed: _intro.isCompleted
                            ? _continueToSelfie
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CelestialStarsPainter extends CustomPainter {
  _CelestialStarsPainter({
    required this.reveal,
    required this.ambient,
  });

  final double reveal;
  final double ambient;

  static final List<_Star> _stars = List.generate(80, (index) {
    final random = math.Random(index * 97 + 13);
    return _Star(
      Offset(random.nextDouble(), random.nextDouble()),
      0.45 + random.nextDouble() * 1.6,
      random.nextDouble() * math.pi * 2,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = ambient * math.pi * 2;

    for (final star in _stars) {
      final twinkle = (math.sin(t * 1.6 + star.phase) + 1) / 2;
      final point = Offset(
        star.position.dx * size.width,
        star.position.dy * size.height,
      );
      final paint = Paint()
        ..color = AppColors.goldBright.withOpacity(
          (0.12 + twinkle * 0.65) * (0.30 + reveal * 0.70),
        )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.radius * 1.1);
      canvas.drawCircle(point, star.radius * (0.6 + twinkle * 0.6), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CelestialStarsPainter oldDelegate) =>
      oldDelegate.reveal != reveal || oldDelegate.ambient != ambient;
}

class _Star {
  const _Star(this.position, this.radius, this.phase);
  final Offset position;
  final double radius;
  final double phase;
}
