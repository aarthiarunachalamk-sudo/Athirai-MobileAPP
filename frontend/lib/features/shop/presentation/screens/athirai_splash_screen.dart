import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../theme/heritage_theme.dart';

/// Screen 01: Welcome / Onboarding ("Enter the Heritage")
/// Displays the majestic dark emerald temple archway, hanging celestial
/// jewel pendant with orbital rings, luxury Athirai typography,
/// "Enter the Heritage  →" CTA capsule button, and pagination dots.
class AthiraiSplashScreen extends StatefulWidget {
  const AthiraiSplashScreen({
    super.key,
    required this.onBeginJourney,
  });

  final VoidCallback onBeginJourney;

  @override
  State<AthiraiSplashScreen> createState() => _AthiraiSplashScreenState();
}

class _AthiraiSplashScreenState extends State<AthiraiSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  late final Animation<double> _glowAnimation = Tween<double>(
    begin: 0.85,
    end: 1.15,
  ).animate(
    CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Cinematic Image: Palace Archway + Chandelier
          Image.asset(
            AppAssets.templeArchChandelier,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF04100D),
              child: const Center(
                child: Icon(
                  Icons.diamond_outlined,
                  color: HeritageTheme.goldPrimary,
                  size: 72,
                ),
              ),
            ),
          ),

          // Vignette & Atmosphere Overlays
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.25, 0.65, 0.90, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.transparent,
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),

          // Radial ambient glow behind text and button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            height: 320,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    HeritageTheme.emeraldGlow,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content Layer
          SafeArea(
            child: Column(
              children: [
                // Top status bar spacing
                const SizedBox(height: 12),

                const Spacer(flex: 7),

                // Brand Title: "ATHIRAI"
                Text(
                  'ATHIRAI',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 6.5,
                    color: const Color(0xFFF7F2E8),
                    shadows: [
                      Shadow(
                        color: const Color(0xFFE5C170).withOpacity(0.55),
                        blurRadius: 18,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Subtitle: "TIMELESS JEWELS"
                Text(
                  'TIMELESS JEWELS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4.5,
                    color: const Color(0xFFC5A059),
                  ),
                ),

                const Spacer(flex: 3),

                // Headline: "Where Tradition Meets Tomorrow"
                Text(
                  'Where Tradition\nMeets Tomorrow',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 27,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF7F2E8),
                    letterSpacing: 0.5,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle: "Step into a world of heritage..."
                Text(
                  'Step into a world of heritage,\nbeauty and timeless elegance.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: const Color(0xFF8E9E94),
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 20),

                // CTA Button: "Enter the Heritage  →"
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 42),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC59F4E)
                                .withOpacity(0.35 * _glowAnimation.value),
                            blurRadius: 16 * _glowAnimation.value,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE8C87A),
                          Color(0xFFC59F4E),
                          Color(0xFFDFB75E),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: const Color(0xFFFFF0C2).withOpacity(0.6),
                        width: 0.9,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(26),
                        onTap: widget.onBeginJourney,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Enter the Heritage',
                              style: GoogleFonts.inter(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: const Color(0xFF161108),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xFF161108),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // 4 Pagination Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Active dot: white/light pill
                    Container(
                      width: 18,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    for (int i = 0; i < 3; i++) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8E9E94).withOpacity(0.45),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 18),

                // Bottom Sacred Lotus Ornament
                const CustomPaint(
                  size: Size(48, 28),
                  painter: _SplashLotusPainter(color: Color(0xFFC5A059)),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashLotusPainter extends CustomPainter {
  const _SplashLotusPainter({this.color = const Color(0xFFC5A059)});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Center petal
    final pCenter = Path();
    pCenter.moveTo(cx, cy + size.height * 0.42);
    pCenter.quadraticBezierTo(cx - size.width * 0.12, cy, cx, cy - size.height * 0.45);
    pCenter.quadraticBezierTo(cx + size.width * 0.12, cy, cx, cy + size.height * 0.42);
    canvas.drawPath(pCenter, paint);

    // Inner left petal
    final pInLeft = Path();
    pInLeft.moveTo(cx - size.width * 0.05, cy + size.height * 0.38);
    pInLeft.quadraticBezierTo(
      cx - size.width * 0.28,
      cy - size.height * 0.05,
      cx - size.width * 0.22,
      cy - size.height * 0.35,
    );
    pInLeft.quadraticBezierTo(
      cx - size.width * 0.12,
      cy - size.height * 0.1,
      cx,
      cy + size.height * 0.2,
    );
    canvas.drawPath(pInLeft, paint);

    // Inner right petal
    final pInRight = Path();
    pInRight.moveTo(cx + size.width * 0.05, cy + size.height * 0.38);
    pInRight.quadraticBezierTo(
      cx + size.width * 0.28,
      cy - size.height * 0.05,
      cx + size.width * 0.22,
      cy - size.height * 0.35,
    );
    pInRight.quadraticBezierTo(
      cx + size.width * 0.12,
      cy - size.height * 0.1,
      cx,
      cy + size.height * 0.2,
    );
    canvas.drawPath(pInRight, paint);

    // Outer left petal
    final pOutLeft = Path();
    pOutLeft.moveTo(cx - size.width * 0.08, cy + size.height * 0.35);
    pOutLeft.quadraticBezierTo(
      cx - size.width * 0.45,
      cy + size.height * 0.1,
      cx - size.width * 0.42,
      cy - size.height * 0.18,
    );
    pOutLeft.quadraticBezierTo(
      cx - size.width * 0.25,
      cy - size.height * 0.02,
      cx - size.width * 0.06,
      cy + size.height * 0.25,
    );
    canvas.drawPath(pOutLeft, paint);

    // Outer right petal
    final pOutRight = Path();
    pOutRight.moveTo(cx + size.width * 0.08, cy + size.height * 0.35);
    pOutRight.quadraticBezierTo(
      cx + size.width * 0.45,
      cy + size.height * 0.1,
      cx + size.width * 0.42,
      cy - size.height * 0.18,
    );
    pOutRight.quadraticBezierTo(
      cx + size.width * 0.25,
      cy - size.height * 0.02,
      cx + size.width * 0.06,
      cy + size.height * 0.25,
    );
    canvas.drawPath(pOutRight, paint);

    // Central diamond
    final diamond = Path();
    diamond.moveTo(cx, cy + size.height * 0.12);
    diamond.lineTo(cx + 3, cy + size.height * 0.22);
    diamond.lineTo(cx, cy + size.height * 0.32);
    diamond.lineTo(cx - 3, cy + size.height * 0.22);
    diamond.close();
    canvas.drawPath(diamond, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
