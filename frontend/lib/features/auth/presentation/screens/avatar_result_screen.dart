import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shop/presentation/shop_screen.dart';
import '../widgets/athirai_logo.dart';
import '../widgets/cosmic_background.dart';
import 'selfie_capture_screen.dart';

class AvatarResultScreen extends StatefulWidget {
  const AvatarResultScreen({
    super.key,
    required this.selfiePath,
    this.avatarUrl,
    this.selfieUrl,
  });

  final String selfiePath;
  final String? avatarUrl;
  final String? selfieUrl;

  @override
  State<AvatarResultScreen> createState() => _AvatarResultScreenState();
}

class _AvatarResultScreenState extends State<AvatarResultScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final portraitWidth = (size.width * 0.82).clamp(280.0, 390.0);
    final portraitHeight = portraitWidth * 1.34;

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: CosmicBackground(
        imageAsset: AppAssets.signInReferenceBg,
        overlayOpacity: 0.08,
        showFrame: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            child: Column(
              children: [
                // Top bar: Back button + Step title
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.goldBright,
                        size: 18,
                      ),
                      style: IconButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.borderGoldSubtle,
                        ),
                        shape: const CircleBorder(),
                        fixedSize: const Size(40, 40),
                        backgroundColor: Colors.black.withOpacity(0.35),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '04. VOICE MEETS YOU (AFTER AI CREATION)',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cormorantGaramond(
                          color: AppColors.goldBright,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 6),

                // Athirai Lotus Logo & Branding (Matching Mockup 04)
                const AthiraiLogo(width: 148),
                const SizedBox(height: 8),

                // Main Elaborate Portrait Stack (NO circle outline or circle aura behind the avatar)
                SizedBox(
                  width: portraitWidth,
                  height: portraitHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Full elaborate front-facing royal avatar artwork (Unclipped, clean background)
                      Positioned.fill(child: _buildPortraitImage()),

                      // Floating Speech Bubble with Pointer over lower saree (Matching Mockup 04)
                      Positioned(
                        left: 4,
                        right: 4,
                        bottom: 12,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                12,
                                14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xF2090704),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: AppColors.goldPrimary.withOpacity(
                                    0.85,
                                  ),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.goldPrimary.withOpacity(
                                      0.18,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Hello! I’m your AI Stylist.\nShall we explore the world\nof timeless gold?',
                                      style: GoogleFonts.cormorantGaramond(
                                        color: AppColors.champagne,
                                        fontSize: 17,
                                        height: 1.35,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.goldPrimary,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: _VoiceSoundwave(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Speech bubble triangular beak pointing up to the model girl
                            Positioned(
                              top: -6,
                              child: Transform.rotate(
                                angle: math.pi / 4,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF090704),
                                    border: Border(
                                      top: BorderSide(
                                        color: AppColors.goldPrimary
                                            .withOpacity(0.85),
                                        width: 1.2,
                                      ),
                                      left: BorderSide(
                                        color: AppColors.goldPrimary
                                            .withOpacity(0.85),
                                        width: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // AI LISTENS AND SPEAKS TO YOU Subtitle
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: AppColors.borderGoldSubtle),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'AI LISTENS AND SPEAKS TO YOU',
                        style: GoogleFonts.cormorantGaramond(
                          color: AppColors.goldBright,
                          fontSize: 12.5,
                          letterSpacing: 2.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: AppColors.borderGoldSubtle),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Continue into the mobile jewellery store.
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const SelfieCaptureScreen(),
                              ),
                              (route) => route.isFirst,
                            ),
                        icon: const Icon(Icons.camera_alt_rounded, size: 17),
                        label: const Text('New Selfie'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.goldBright,
                          side: const BorderSide(color: AppColors.goldPrimary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ShopScreen()),
                        ),
                        icon: const Icon(Icons.auto_awesome_rounded, size: 17),
                        label: const Text('Shop Jewellery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldPrimary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitImage() {
    if (widget.avatarUrl != null && widget.avatarUrl!.startsWith('http')) {
      return Image.network(
        widget.avatarUrl!,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        gaplessPlayback: true,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.goldPrimary,
              strokeWidth: 2.2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            AppAssets.userAvatar,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          );
        },
      );
    }
    return Image.asset(
      AppAssets.userAvatar,
      fit: BoxFit.contain,
      alignment: Alignment.center,
    );
  }
}

class _VoiceSoundwave extends StatefulWidget {
  const _VoiceSoundwave();

  @override
  State<_VoiceSoundwave> createState() => _VoiceSoundwaveState();
}

class _VoiceSoundwaveState extends State<_VoiceSoundwave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final val = _ctrl.value;
        const heights = [9.0, 16.0, 24.0, 16.0, 9.0];
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(5, (index) {
            final mod = math.sin((val + index * 0.22) * math.pi);
            final h = heights[index] * (0.65 + 0.35 * mod);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              width: 3.0,
              height: h,
              decoration: BoxDecoration(
                color: AppColors.goldBright,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
