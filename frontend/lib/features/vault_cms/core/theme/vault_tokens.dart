import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Primary design tokens matching the Athirai reference visual language:
/// - Deep emerald / green-black environment
/// - Antique gold & champagne detailing
/// - Dark glass surfaces with thin gold borders
/// - Cormorant Garamond luxury serif & Inter UI sans-serif
class VaultTokens {
  VaultTokens._();

  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color deepEmerald = Color(0xFF061B18);
  static const Color darkGreen = Color(0xFF0B2925);
  static const Color blackGreen = Color(0xFF071310);
  static const Color surfaceBlack = Color(0xFF040F0D);
  static const Color darkCanvas = Color(0xFF030D0A);

  static const Color antiqueGold = Color(0xFFC7A45B);
  static const Color champagneGold = Color(0xFFE4C982);
  static const Color satinGold = Color(0xFFDFB75E);
  static const Color mutedGold = Color(0xFF8E7542);
  static const Color darkGold = Color(0xFF6B582C);

  static const Color warmIvory = Color(0xFFF2EBDD);
  static const Color pureIvory = Color(0xFFFAF7F0);
  static const Color sageMuted = Color(0xFF8E9E94);
  static const Color sageLight = Color(0xFFA5B8AD);

  static const Color statusSuccess = Color(0xFF2E7D5C);
  static const Color statusWarning = Color(0xFFD4A017);
  static const Color statusDanger = Color(0xFFBA3C3C);
  static const Color statusInfo = Color(0xFF2C7A8A);

  // ── Glassmorphic Fills & Borders ──────────────────────────────────────────
  static const Color glassFillLight = Color(0x38061A14);
  static const Color glassFillMedium = Color(0x550A221B);
  static const Color glassFillDark = Color(0x73051410);

  static const Color borderGoldMuted = Color(0x33C7A45B);
  static const Color borderGoldMedium = Color(0x66C7A45B);
  static const Color borderGoldBright = Color(0x99E4C982);

  // ── Luxury Gradients ──────────────────────────────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      Color(0xFFE8C87A),
      Color(0xFFC59F4E),
      Color(0xFFDFB75E),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient goldGradientVertical = LinearGradient(
    colors: [
      Color(0xFFE8C87A),
      Color(0xFFC59F4E),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient emeraldCanvasGradient = LinearGradient(
    colors: [
      Color(0xFF071A15),
      Color(0xFF04100D),
      Color(0xFF020705),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    colors: [
      Color(0x550B2720),
      Color(0x33061A14),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Typography ────────────────────────────────────────────────────────────
  // Large editorial serif headings
  static TextStyle headlineDisplay({double fontSize = 34, Color color = warmIvory, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.cormorantGaramond(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.8,
      height: 1.15,
    );
  }

  static TextStyle titleSerif({double fontSize = 22, Color color = warmIvory, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.cormorantGaramond(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.5,
    );
  }

  // Brand uppercase tracked labels
  static TextStyle brandLabel({double fontSize = 11, Color color = champagneGold, double letterSpacing = 3.5}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  // Modern UI body & labels
  static TextStyle bodyText({double fontSize = 13.5, Color color = sageMuted, FontWeight fontWeight = FontWeight.w400, double height = 1.45}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle bodyMedium({double fontSize = 13.5, Color color = warmIvory, FontWeight fontWeight = FontWeight.w500}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle monoLabel({double fontSize = 12, Color color = champagneGold}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }
}
