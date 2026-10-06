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
                  style: GoogleFonts.cinzel(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8.0,
                    color: HeritageTheme.textLight,
                    shadows: [
                      Shadow(
                        color: HeritageTheme.goldPrimary.withOpacity(0.65),
                        blurRadius: 22,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Subtitle: "TIMELESSLY YOURS"
                Text(
                  'TIMELESSLY YOURS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4.8,
                    color: HeritageTheme.goldPrimary,
                  ),
                ),

                const Spacer(flex: 3),

                // Tagline: "JEWELLERY BEYOND TIME & TRENDS"
                Text(
                  'JEWELLERY BEYOND\nTIME & TRENDS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.4,
                    color: HeritageTheme.textMutedDark,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 24),

                // CTA Button: "Enter the Heritage  →"
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 48),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: HeritageTheme.goldPrimary
                                .withOpacity(0.35 * _glowAnimation.value),
                            blurRadius: 18 * _glowAnimation.value,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xCC071B16),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: HeritageTheme.goldPrimary.withOpacity(0.85),
                        width: 1.2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: widget.onBeginJourney,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Enter the Heritage',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                  color: HeritageTheme.textLight,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: HeritageTheme.goldPrimary,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // 3 Pagination Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Active dot: white/light pill
                    Container(
                      width: 16,
                      height: 5,
                      decoration: BoxDecoration(
                        color: HeritageTheme.textLight,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Inactive dot 2
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: HeritageTheme.textMutedDark.withOpacity(0.45),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Inactive dot 3
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: HeritageTheme.textMutedDark.withOpacity(0.45),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
