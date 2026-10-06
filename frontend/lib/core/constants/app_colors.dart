import 'package:flutter/material.dart';

/// Centralized luxury color palette for Athirai Timeless Jewels
class AppColors {
  AppColors._();

  // Dark Emerald Foundations (Exact match for luxury reference screens)
  static const Color backgroundBlack = Color(0xFF030D0A);
  static const Color surfaceBlack = Color(0xFF071B16);
  static const Color cardBlack = Color(0xFF0A221C);
  static const Color overlayBlack = Color(0x66020705);

  // Metallic Golds
  static const Color goldPrimary = Color(0xFFE5C170);
  static const Color goldBright = Color(0xFFFFDF88);
  static const Color goldDark = Color(0xFFC59F4E);
  static const Color goldMuted = Color(0xFFC5A059);
  static const Color goldChampagne = Color(0xFFFFF0B8);
  static const Color champagne = Color(0xFFF5E8C8);

  // Border & Glows
  static const Color borderGold = Color(0xFFE5C170);
  static const Color borderGoldSubtle = Color(0x55C5A059);
  static const Color borderWhiteGold = Color(0x77EAD8A7);
  static const Color goldGlow = Color(0x40E5C170);
  static const Color goldGlowStrong = Color(0x80E5C170);

  // Typography
  static const Color textPrimary = Color(0xFFF6F1E8);
  static const Color textSecondary = Color(0xFFB9B3AA);
  static const Color textTertiary = Color(0xFF8E8880);
  static const Color textMuted = Color(0xFF7E7870);
  static const Color textDark = Color(0xFF0B0A08);

  // Status & Utility
  static const Color error = Color(0xFFFF6B6B);
  static const Color successGreen = Color(0xFF4EBE7E);
  static const Color idpBlue = Color(0xFF0067B8);

  // Gradients
  static const LinearGradient primaryGoldGradient = LinearGradient(
    colors: [
      Color(0xFFFFD978),
      Color(0xFFE8B44B),
      Color(0xFFF4C35C),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [
      Color(0x28FFD978),
      Color(0x0C14110D),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient borderGoldGradient = LinearGradient(
    colors: [
      Color(0xFFFFD978),
      Color(0xFFE7B653),
      Color(0xFFA87524),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Exact Heritage Luxury Palette (from design mockups & infisq brand)
  static const Color heritageMaroon = Color(0xFF7A1B2E);
  static const Color heritageMaroonDark = Color(0xFF560D1C);
  static const Color heritageMaroonLight = Color(0xFF8F2239);
  static const Color heritageCreamBg = Color(0xFFFAF6F0);
  static const Color heritageCreamSurface = Color(0xFFFFFFFF);
  static const Color heritageCreamBorder = Color(0xFFECE3D6);
  static const Color heritageGold = Color(0xFFC59A42);
  static const Color heritageGoldLight = Color(0xFFE5C378);
  static const Color heritageEbony = Color(0xFF1C1917);
  static const Color heritageMuted = Color(0xFF78716C);
  static const Color heritageSuccess = Color(0xFF2E7D32);

  // Infisq Athirai Signature Peacock Emerald & Antique Gold
  static const Color heritageEmerald = Color(0xFF073B3F);
  static const Color heritageEmeraldLight = Color(0xFF0C4E53);
  static const Color heritageGoldAntique = Color(0xFFCCA881);
}
