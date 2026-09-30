import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/athirai_logo.dart';
import '../widgets/cosmic_background.dart';
import 'avatar_result_screen.dart';

class AvatarCreationScreen extends StatefulWidget {
  const AvatarCreationScreen({super.key, required this.selfiePath});

  final String selfiePath;

  @override
  State<AvatarCreationScreen> createState() => _AvatarCreationScreenState();
}

class _AvatarCreationScreenState extends State<AvatarCreationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);
  Timer? _progressTimer;
  double _progress = 0;
  bool _openingResult = false;

  String get _status {
    if (_progress < 0.34) return 'Analyzing facial features...';
    if (_progress < 0.68) return 'Building your AI model...';
    return 'Designing your traditional saree look...';
  }

  @override
  void initState() {
    super.initState();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted) return;
      setState(() => _progress = (_progress + 0.018).clamp(0, 1));
      if (_progress >= 1 && !_openingResult) {
        _openingResult = true;
        timer.cancel();
        Future<void>.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => AvatarResultScreen(selfiePath: widget.selfiePath),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width * 0.78;
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: CosmicBackground(
        imageAsset: AppAssets.signInReferenceBg,
        overlayOpacity: 0.14,
        showFrame: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
            child: Column(
              children: [
                const AthiraiLogo(width: 150),
                const SizedBox(height: 24),
                Text(
                  '03. AI MODEL CREATING',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    color: AppColors.goldBright,
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.8,
                  ),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: _glow,
                  builder: (context, child) => Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.goldPrimary.withOpacity(
                          0.58 + _glow.value * 0.4,
                        ),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withOpacity(
                            0.12 + _glow.value * 0.22,
                          ),
                          blurRadius: 30 + _glow.value * 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(widget.selfiePath),
                            fit: BoxFit.cover,
                          ),
                          Container(color: Colors.black.withOpacity(0.42)),
                          CustomPaint(painter: _AvatarScanPainter(_glow.value)),
                          Center(
                            child: Icon(
                              Icons.auto_awesome,
                              size: 48 + _glow.value * 10,
                              color: AppColors.goldBright.withOpacity(
                                0.72 + _glow.value * 0.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Creating Your AI Model',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    color: AppColors.champagne,
                    fontSize: 29,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    color: AppColors.textSecondary,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 22),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 12,
                    backgroundColor: const Color(0xFF38210C),
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.goldPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${(_progress * 100).round()}%',
                  style: GoogleFonts.cormorantGaramond(
                    color: AppColors.goldBright,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
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

class _AvatarScanPainter extends CustomPainter {
  const _AvatarScanPainter(this.phase);
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.goldBright.withOpacity(0.28 + phase * 0.48)
      ..strokeWidth = 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    for (var row = -2; row <= 2; row++) {
      for (var column = -2; column <= 2; column++) {
        final point =
            center +
            Offset(column * size.width * 0.12, row * size.height * 0.12);
        if (point.distance < size.width * 0.43) {
          canvas.drawCircle(point, 1.2 + phase, paint);
          if (column < 2) {
            canvas.drawLine(point, point + Offset(size.width * 0.12, 0), paint);
          }
          if (row < 2) {
            canvas.drawLine(
              point,
              point + Offset(0, size.height * 0.12),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AvatarScanPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
