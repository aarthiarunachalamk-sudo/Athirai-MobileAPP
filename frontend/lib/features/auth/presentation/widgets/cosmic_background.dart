import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import 'animated_ribbon_image.dart';

class CosmicBackground extends StatelessWidget {
  final Widget child;
  final String imageAsset;
  final double overlayOpacity;
  final bool showGlitter;
  final bool showFrame;

  const CosmicBackground({
    super.key,
    required this.child,
    this.imageAsset = AppAssets.signInReferenceBg,
    this.overlayOpacity = 0.04,
    this.showGlitter = false,
    this.showFrame = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Cinematic Celestial Cosmic Background Image
        if (showGlitter && imageAsset == AppAssets.signInReferenceBg)
          AnimatedRibbonImage(key: ValueKey(imageAsset), asset: imageAsset)
        else
          Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
          ),

        // Keep the artwork subdued beneath the form.
        Container(color: Colors.black.withOpacity(overlayOpacity)),

        // Inset gold frame follows the phone's safe area.
        if (showFrame)
          Positioned.fill(
            child: IgnorePointer(
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: const Color(0xFFBA8A38),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33DFA63C),
                        blurRadius: 7,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 4. Foreground Content
        child,
      ],
    );
  }
}
