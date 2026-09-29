import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';
import '../widgets/athirai_logo.dart';
import '../widgets/celestial_accents.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/gold_primary_button.dart';
import 'sign_in_screen.dart';

class AthiraiEntryScreen extends ConsumerStatefulWidget {
  const AthiraiEntryScreen({super.key});

  @override
  ConsumerState<AthiraiEntryScreen> createState() => _AthiraiEntryScreenState();
}

class _AthiraiEntryScreenState extends ConsumerState<AthiraiEntryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _portraitMotion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat(reverse: true);
  late final AnimationController _celestialMotion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..repeat();

  @override
  void dispose() {
    _portraitMotion.dispose();
    _celestialMotion.dispose();
    super.dispose();
  }

  void _onBeginJourney(BuildContext context, WidgetRef ref) {
    final user = ref.read(authControllerProvider).currentUser;
    final userName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'Cherished Patron';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.borderGoldSubtle, width: 1.2),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderGoldSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome, $userName',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldBright,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You have entered the inner sanctum of Athirai.\nImmerse yourself in AI-driven bespoke jewelry design, interactive 3D gemology, and celestial gold mastery.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              GoldPrimaryButton(
                text: 'Explore High Jewelry Atelier',
                showArrow: true,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: CosmicBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _celestialMotion,
                builder: (context, child) => CustomPaint(
                  painter: CelestialAccents(progress: _celestialMotion.value),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: Column(
                  children: [
                    // Top header with logout / profile action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        const AthiraiLogo(width: 155),
                        IconButton(
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.goldPrimary,
                            size: 22,
                          ),
                          tooltip: 'Sign Out',
                          onPressed: () => _handleLogout(context, ref),
                        ),
                      ],
                    ),

                    const Spacer(flex: 3),

                    // Animated patron portrait fills the open center of the welcome screen.
                    AnimatedBuilder(
                      animation: _portraitMotion,
                      builder: (context, child) {
                        final phase = Curves.easeInOutSine.transform(
                          _portraitMotion.value,
                        );
                        return Transform.scale(
                          scale: 0.97 + phase * 0.06,
                          child: Transform.rotate(
                            angle: -0.012 + phase * 0.024,
                            child: Transform.translate(
                              // The blue-blazer portrait sweeps diagonally, then reverses.
                              offset: Offset(18 - phase * 36, -26 + phase * 52),
                              child: Center(
                                child: Container(
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.78,
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.38,
                                  constraints: const BoxConstraints(
                                    maxHeight: 330,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(180),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.goldPrimary
                                            .withOpacity(0.12 + phase * 0.12),
                                        blurRadius: 28 + phase * 16,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(180),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.asset(
                                          AppAssets.profileAvatar,
                                          fit: BoxFit.cover,
                                        ),
                                        IgnorePointer(
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.goldPrimary
                                                    .withOpacity(
                                                      0.48 + phase * 0.3,
                                                    ),
                                                width: 1.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(180),
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
                        );
                      },
                    ),
                    const Spacer(flex: 2),

                    // Inspiring Tagline
                    Text(
                      AppStrings.journeyHeading,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.8,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // BEGIN JOURNEY Button
                    GoldPrimaryButton(
                      text: AppStrings.beginJourneyBtn,
                      showArrow: false,
                      height: 60,
                      borderRadius: 30,
                      onPressed: () => _onBeginJourney(context, ref),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
