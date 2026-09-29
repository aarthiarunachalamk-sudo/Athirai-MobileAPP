import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';
import '../widgets/athirai_logo.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/loading_gold_ring.dart';
import 'auth_success_screen.dart';

class AuthProcessingScreen extends ConsumerStatefulWidget {
  final String authCode;

  const AuthProcessingScreen({
    super.key,
    required this.authCode,
  });

  @override
  ConsumerState<AuthProcessingScreen> createState() => _AuthProcessingScreenState();
}

class _AuthProcessingScreenState extends ConsumerState<AuthProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _processAuthentication();
  }

  void _processAuthentication() async {
    // Elegant transition delay
    await Future.delayed(const Duration(milliseconds: 1600));

    final success = await ref.read(authControllerProvider.notifier).completeSsoCallback(widget.authCode);

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthSuccessScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceBlack,
            content: Text(
              ref.read(authControllerProvider).errorMessage ?? 'Authentication could not be finalized.',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    }
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
              children: [
                const SizedBox(height: 28),
                const AthiraiLogo(width: 155),
                const Spacer(flex: 2),

                // Luminous Gold Ring
                const LoadingGoldRing(size: 110),

                const SizedBox(height: 38),

                // Title
                Text(
                  AppStrings.signingInSecurely,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle
                Text(
                  AppStrings.signingInSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.champagne.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),

                const Spacer(flex: 3),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
