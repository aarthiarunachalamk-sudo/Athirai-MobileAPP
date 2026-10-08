import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Central theme & styling helpers matching the exact Athirai luxury design
class HeritageTheme {
  HeritageTheme._();

  // Colors
  static const Color maroon = AppColors.heritageMaroon; // #7A1B2E
  static const Color maroonDark = AppColors.heritageMaroonDark; // #560D1C
  static const Color maroonLight = AppColors.heritageMaroonLight;
  static const Color creamBg = AppColors.heritageCreamBg; // #FAF6F0
  static const Color creamSurface = AppColors.heritageCreamSurface; // #FFFFFF
  static const Color creamBorder = AppColors.heritageCreamBorder; // #ECE3D6
  static const Color gold = AppColors.heritageGold; // #C59A42
  static const Color goldLight = AppColors.heritageGoldLight; // #E5C378
  static const Color ebony = AppColors.heritageEbony; // #1C1917
  static const Color muted = AppColors.heritageMuted; // #78716C
  static const Color green = AppColors.heritageSuccess; // #2E7D32
  static const Color emerald = AppColors.heritageEmerald; // #073B3F (Infisq brand color)
  static const Color emeraldLight = AppColors.heritageEmeraldLight;
  static const Color goldAntique = AppColors.heritageGoldAntique; // #CCA881

  // Luxury Dark Emerald & Obsidian Foundation (exact match for screens 01 to 05)
  static const Color darkBg = Color(0xFF040D0B);
  static const Color darkBg2 = Color(0xFF061512);
  static const Color darkSurface = Color(0xFF081B17);
  static const Color darkCard = Color(0xFF0A201B);
  static const Color glassCard = Color(0xCC091E19);
  static const Color goldPrimary = Color(0xFFE5C07B);
  static const Color goldBright = Color(0xFFFFE082);
  static const Color goldDark = Color(0xFFA67C2E);
  static const Color goldBorder = Color(0x66D4AF37);
  static const Color goldBorderSubtle = Color(0x33D4AF37);
  static const Color emeraldAccent = Color(0xFF0D5C46);
  static const Color emeraldGlow = Color(0x5500A86B);
  static const Color textGold = Color(0xFFF3D389);
  static const Color textLight = Color(0xFFF6F8F7);
  static const Color textMutedDark = Color(0xFFA2B4AF);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      Color(0xFFFFE9A0),
      Color(0xFFDFB35A),
      Color(0xFFB58428),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Luxury Serif Typography (using bundled HeritageSerif with Cormorant fallback)
  static TextStyle serif({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = ebony,
    double? letterSpacing,
    double? height,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: 'HeritageSerif',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: fontStyle,
    );
  }

  // Modern Clean Sans Typography
  static TextStyle sans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = ebony,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}

/// Ornate Temple / Palace Scalloped Arch Clipper
class PalaceArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Start at bottom-left
    path.moveTo(0, h);
    path.lineTo(0, h * 0.28);

    // Left shoulder curve
    path.quadraticBezierTo(0, h * 0.12, w * 0.2, h * 0.12);

    // Left arch foil
    path.arcToPoint(
      Offset(w * 0.38, h * 0.05),
      radius: Radius.circular(w * 0.2),
      clockwise: true,
    );

    // Apex point
    path.quadraticBezierTo(w * 0.46, h * 0.005, w * 0.5, 0);
    path.quadraticBezierTo(w * 0.54, h * 0.005, w * 0.62, h * 0.05);

    // Right arch foil
    path.arcToPoint(
      Offset(w * 0.8, h * 0.12),
      radius: Radius.circular(w * 0.2),
      clockwise: true,
    );

    // Right shoulder curve
    path.quadraticBezierTo(w, h * 0.12, w, h * 0.28);
    path.lineTo(w, h);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Crisp Golden Lotus Motif Icon
class HeritageLotusIcon extends StatelessWidget {
  const HeritageLotusIcon({
    super.key,
    this.size = 24,
    this.color = HeritageTheme.gold,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LotusPainter(color),
    );
  }
}

class _LotusPainter extends CustomPainter {
  _LotusPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Center petal
    final centerPetal = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..cubicTo(w * 0.62, h * 0.35, w * 0.62, h * 0.65, w * 0.5, h * 0.85)
      ..cubicTo(w * 0.38, h * 0.65, w * 0.38, h * 0.35, w * 0.5, h * 0.1)
      ..close();
    canvas.drawPath(centerPetal, strokePaint);

    // Left inner petal
    final leftInner = Path()
      ..moveTo(w * 0.48, h * 0.25)
      ..cubicTo(w * 0.3, h * 0.38, w * 0.26, h * 0.68, w * 0.5, h * 0.85)
      ..cubicTo(w * 0.38, h * 0.65, w * 0.38, h * 0.45, w * 0.48, h * 0.25)
      ..close();
    canvas.drawPath(leftInner, strokePaint);

    // Right inner petal
    final rightInner = Path()
      ..moveTo(w * 0.52, h * 0.25)
      ..cubicTo(w * 0.7, h * 0.38, w * 0.74, h * 0.68, w * 0.5, h * 0.85)
      ..cubicTo(w * 0.62, h * 0.65, w * 0.62, h * 0.45, w * 0.52, h * 0.25)
      ..close();
    canvas.drawPath(rightInner, strokePaint);

    // Left outer petal
    final leftOuter = Path()
      ..moveTo(w * 0.45, h * 0.45)
      ..cubicTo(w * 0.15, h * 0.55, w * 0.18, h * 0.75, w * 0.5, h * 0.85)
      ..cubicTo(w * 0.28, h * 0.75, w * 0.25, h * 0.6, w * 0.45, h * 0.45)
      ..close();
    canvas.drawPath(leftOuter, strokePaint);

    // Right outer petal
    final rightOuter = Path()
      ..moveTo(w * 0.55, h * 0.45)
      ..cubicTo(w * 0.85, h * 0.55, w * 0.82, h * 0.75, w * 0.5, h * 0.85)
      ..cubicTo(w * 0.72, h * 0.75, w * 0.75, h * 0.6, w * 0.55, h * 0.45)
      ..close();
    canvas.drawPath(rightOuter, strokePaint);

    // Base horizontal accent
    final baseArc = Path()
      ..moveTo(w * 0.28, h * 0.88)
      ..quadraticBezierTo(w * 0.5, h * 0.95, w * 0.72, h * 0.88);
    canvas.drawPath(baseArc, strokePaint);

    // Little center dot
    canvas.drawCircle(Offset(w * 0.5, h * 0.68), 1.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Royal Luxury SnackBar / Notification System matching the Athirai dark emerald & gold theme
class AthiraiSnackBar {
  AthiraiSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 2),
    IconData? icon,
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF041914),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        elevation: 12,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isError ? const Color(0xFFEF4444) : const Color(0xFFD4AF37),
            width: 1.1,
          ),
        ),
        content: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isError ? const Color(0x33EF4444) : const Color(0x33D4AF37),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isError ? const Color(0xFFEF4444) : const Color(0xFFFFDF7A),
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: isError ? const Color(0xFFFCA5A5) : const Color(0xFFFFDF7A),
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF7F2E8),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: const Color(0xFFFFDF7A),
                onPressed: onAction ?? () {},
              )
            : null,
        duration: duration,
      ),
    );
  }
}
