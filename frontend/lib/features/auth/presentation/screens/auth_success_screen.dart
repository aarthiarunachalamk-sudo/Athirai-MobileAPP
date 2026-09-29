import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';
import '../widgets/athirai_logo.dart';
import '../widgets/cosmic_background.dart';
import 'athirai_entry_screen.dart';
import 'complete_profile_screen.dart';

class AuthSuccessScreen extends ConsumerStatefulWidget {
  const AuthSuccessScreen({super.key});

  @override
  ConsumerState<AuthSuccessScreen> createState() => _AuthSuccessScreenState();
}

class _AuthSuccessScreenState extends ConsumerState<AuthSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final authState = ref.read(authControllerProvider);
      if (authState.requiresProfileCompletion) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AthiraiEntryScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: CosmicBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.goldPrimary, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                const SizedBox(height: 12),
                const AthiraiLogo(width: 155),

                const Spacer(flex: 2),

                // Glowing Gold Success Checkmark Badge
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + 0.05 * _pulseController.value;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF14110D).withOpacity(0.85),
                          border: Border.all(color: AppColors.goldBright, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldBright.withOpacity(0.35 * _pulseController.value + 0.2),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.goldBright,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 34),

                // Title
                Text(
                  AppStrings.welcomeTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  AppStrings.authSuccessful,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.goldPrimary,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 12),

                // Body text
                Text(
                  AppStrings.authSuccessBody,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),

                const Spacer(flex: 3),

                // Setting things up note
                Text(
                  AppStrings.settingThingsUp,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.champagne.withOpacity(0.7),
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
