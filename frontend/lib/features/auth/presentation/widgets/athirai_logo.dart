import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';

class AthiraiLogo extends StatelessWidget {
  final double? width;
  final bool showGlow;
  final String imageAsset;

  const AthiraiLogo({
    super.key,
    this.width,
    this.showGlow = true,
    this.imageAsset = AppAssets.logoGold,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetWidth = width ?? (screenWidth * 0.40).clamp(140.0, 200.0);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft ambient golden aura behind the lotus emblem
          if (showGlow)
            Container(
              width: targetWidth * 0.75,
              height: targetWidth * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.goldGlow.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

          // Metallic Gold Logo Image Asset
          Image.asset(
            imageAsset,
            width: targetWidth,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ],
      ),
    );
  }
}
