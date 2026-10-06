import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../shop/domain/shop_store.dart';
import '../controllers/auth_controller.dart';
import '../widgets/athirai_logo.dart';
import '../widgets/celestial_accents.dart';
import '../widgets/gold_primary_button.dart';
import 'cinematic_reveal_screen.dart';
import 'shopping_dashboard_screen.dart';
import 'sign_in_screen.dart';

class AthiraiEntryScreen extends ConsumerStatefulWidget {
  const AthiraiEntryScreen({super.key});

  @override
  ConsumerState<AthiraiEntryScreen> createState() => _AthiraiEntryScreenState();
}

class _AthiraiEntryScreenState extends ConsumerState<AthiraiEntryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _celestialMotion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..repeat();

  @override
  void dispose() {
    _celestialMotion.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await ref.read(authControllerProvider.notifier).logout();
    ShopStore.session.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundBlack,
    body: Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.05),
              radius: 0.95,
              colors: [Color(0xFF1E1304), Color(0xFF090602), Color(0xFF020202)],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _celestialMotion,
            builder: (context, child) => CustomPaint(
              painter: CelestialAccents(progress: _celestialMotion.value),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    const AthiraiLogo(width: 155),
                    IconButton(
                      tooltip: 'Sign Out',
                      onPressed: _logout,
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.goldPrimary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Expanded(child: CinematicAvatarAnimation()),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.journeyHeading,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.8,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 18),
                    GoldPrimaryButton(
                      text: AppStrings.beginJourneyBtn,
                      showArrow: false,
                      height: 56,
                      borderRadius: 28,
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => const ShoppingDashboardScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
