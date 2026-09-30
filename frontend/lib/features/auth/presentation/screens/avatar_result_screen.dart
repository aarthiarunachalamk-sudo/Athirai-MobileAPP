import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/athirai_logo.dart';
import '../widgets/cosmic_background.dart';
import 'selfie_capture_screen.dart';

class AvatarResultScreen extends StatelessWidget {
  const AvatarResultScreen({super.key, required this.selfiePath});

  final String selfiePath;

  @override
  Widget build(BuildContext context) {
    final previewSize = (MediaQuery.sizeOf(context).width * 0.76).clamp(
      250.0,
      360.0,
    );
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: CosmicBackground(
        imageAsset: AppAssets.signInReferenceBg,
        overlayOpacity: 0.12,
        showFrame: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            child: Column(
              children: [
                const AthiraiLogo(width: 150),
                const SizedBox(height: 20),
                Text(
                  '04. YOUR AI AVATAR',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    color: AppColors.goldBright,
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: previewSize,
                  height: previewSize * 1.15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(180),
                    border: Border.all(
                      color: AppColors.goldPrimary,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldPrimary.withOpacity(0.2),
                        blurRadius: 26,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(180),
                    child: Image.file(File(selfiePath), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Traditional Saree Avatar',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    color: AppColors.champagne,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderGoldSubtle),
                  ),
                  child: Text(
                    'Your selfie is captured and the avatar flow is ready. A personalized image in a traditional saree will appear here after an AI avatar-generation service is connected.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const SelfieCaptureScreen(),
                      ),
                      (route) => route.isFirst,
                    ),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Take another selfie'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.goldBright,
                      side: const BorderSide(color: AppColors.goldPrimary),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
