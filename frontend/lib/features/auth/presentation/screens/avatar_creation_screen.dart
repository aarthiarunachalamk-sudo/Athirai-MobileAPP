import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../widgets/athirai_logo.dart';
import '../widgets/cosmic_background.dart';
import 'avatar_result_screen.dart';

class AvatarCreationScreen extends ConsumerStatefulWidget {
  const AvatarCreationScreen({super.key, required this.selfiePath});

  final String selfiePath;

  @override
  ConsumerState<AvatarCreationScreen> createState() => _AvatarCreationScreenState();
}

class _AvatarCreationScreenState extends ConsumerState<AvatarCreationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  Timer? _progressTimer;
  double _progress = 0;
  bool _openingResult = false;
  bool _uploadDone = false;
  String? _avatarUrl;
  String? _selfieUrl;

  String get _status {
    if (_progress < 0.28) return 'Uploading selfie to Cloudinary...';
    if (_progress < 0.58) return 'Analyzing facial contours & jewelry points...';
    if (_progress < 0.88) return 'Synthesizing your royal Athirai avatar...';
    return 'Harmonizing temple gold luster...';
  }

  @override
  void initState() {
    super.initState();
    _startUploadAndCreation();
    _startProgressAnimation();
  }

  Future<void> _startUploadAndCreation() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final res = await repo.uploadSelfieAndCreateAvatar(
        filePath: widget.selfiePath,
      );

      if (res.isSuccess && res.data != null) {
        _avatarUrl = res.data!['avatar_url'] as String?;
        _selfieUrl = res.data!['selfie_url'] as String?;
      }
    } catch (e) {
      debugPrint('Selfie upload / creation notice: $e');
    } finally {
      if (mounted) {
        setState(() => _uploadDone = true);
      }
    }
  }

  void _startProgressAnimation() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;

      setState(() {
        if (!_uploadDone) {
          // Progress smoothly up to 88% while waiting for network synthesis
          if (_progress < 0.88) {
            _progress = (_progress + 0.022).clamp(0, 0.88);
          }
        } else {
          // Network completed, finish progress quickly to 100%
          _progress = (_progress + 0.05).clamp(0, 1.0);
        }
      });

      if (_progress >= 1.0 && !_openingResult && _uploadDone) {
        _openingResult = true;
        timer.cancel();
        Future<void>.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => AvatarResultScreen(
                selfiePath: widget.selfiePath,
                avatarUrl: _avatarUrl,
                selfieUrl: _selfieUrl,
              ),
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
    final screen = MediaQuery.sizeOf(context);
    final portraitSize = (screen.width * 0.67).clamp(220.0, 330.0);
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: CosmicBackground(
        imageAsset: AppAssets.signInReferenceBg,
        overlayOpacity: 0.10,
        showFrame: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
            child: Column(
              children: [
                const SizedBox(height: 6),
                const AthiraiLogo(width: 145),
                const SizedBox(height: 16),

                // Main Sleek Bordered Card (Matching Mockup Image 2)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
                  decoration: BoxDecoration(
                    color: const Color(0xE6080603),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.goldPrimary.withOpacity(0.85),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldPrimary.withOpacity(0.12),
                        blurRadius: 24,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header Row: Back Button + Title
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Back',
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.goldBright,
                              size: 16,
                            ),
                            style: IconButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.borderGoldSubtle,
                              ),
                              shape: const CircleBorder(),
                              fixedSize: const Size(38, 38),
                              backgroundColor: Colors.black.withOpacity(0.35),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.goldPrimary,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '03. AI MODEL CREATING',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cormorantGaramond(
                                    color: AppColors.goldBright,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.goldPrimary,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 38), // Balance back button
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Center: Golden Constellation Hologram Profile (Matching Mockup Image 2)
                      AnimatedBuilder(
                        animation: _glow,
                        builder: (context, child) => Container(
                          width: portraitSize,
                          height: portraitSize,
                          alignment: Alignment.center,
                          child: Transform.scale(
                            scale: 0.96 + _glow.value * 0.05,
                            child: Image.asset(
                              AppAssets.aiConstellation,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Title & Subtitle
                      Text(
                        'Creating Your AI Model',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cormorantGaramond(
                          color: AppColors.champagne,
                          fontSize: 27,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cormorantGaramond(
                          color: AppColors.textSecondary,
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Sleek Gold Glowing Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 12,
                            backgroundColor: const Color(0xFF28190B),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.goldPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Percentage Display
                      Text(
                        '${(_progress * 100).round()}%',
                        style: GoogleFonts.cormorantGaramond(
                          color: AppColors.goldBright,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

