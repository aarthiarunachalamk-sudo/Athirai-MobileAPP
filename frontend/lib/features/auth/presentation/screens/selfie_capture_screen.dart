import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/athirai_logo.dart';
import '../widgets/cosmic_background.dart';
import 'avatar_creation_screen.dart';

class SelfieCaptureScreen extends StatefulWidget {
  const SelfieCaptureScreen({super.key});

  @override
  State<SelfieCaptureScreen> createState() => _SelfieCaptureScreenState();
}

class _SelfieCaptureScreenState extends State<SelfieCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _selfiePath;
  bool _openingCamera = false;

  Future<void> _takeSelfie({ImageSource source = ImageSource.camera}) async {
    setState(() => _openingCamera = true);
    try {
      final selfie = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 92,
      );
      if (!mounted) return;
      if (selfie != null) {
        setState(() => _selfiePath = selfie.path);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AvatarCreationScreen(selfiePath: selfie.path),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open camera/gallery. Please check permissions.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingCamera = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final previewSize = (screen.width * 0.70).clamp(230.0, 330.0);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: CosmicBackground(
        imageAsset: AppAssets.signInReferenceBg,
        overlayOpacity: 0.08,
        showFrame: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
            child: Column(
              children: [
                Row(
                  children: [
                    _BackButton(onPressed: () => Navigator.pop(context)),
                    const Spacer(),
                    const AthiraiLogo(width: 132),
                    const Spacer(),
                    const SizedBox(width: 42),
                  ],
                ),
                const SizedBox(height: 4),
                const _GoldDivider(),
                const SizedBox(height: 12),
                Text(
                  '02. AI SELFIE & SCAN',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    color: AppColors.goldBright,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: previewSize * 1.13,
                  height: previewSize * 1.13,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: previewSize,
                        height: previewSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.goldBright.withOpacity(0.88),
                            width: 1.7,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldPrimary.withOpacity(0.25),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _selfiePath == null
                              ? Image.asset(
                                  AppAssets.frontModel,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                )
                              : Image.file(
                                  File(_selfiePath!),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(painter: _FaceCornersPainter()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _selfiePath == null ? 'Take a Selfie' : 'Selfie captured',
                  style: GoogleFonts.cormorantGaramond(
                    color: AppColors.champagne,
                    fontSize: 27,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _selfiePath == null
                      ? 'We will create your AI model'
                      : 'Creating your royal AI model...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Gallery pick button
                    IconButton(
                      tooltip: 'Choose from Gallery',
                      onPressed: _openingCamera
                          ? null
                          : () => _takeSelfie(source: ImageSource.gallery),
                      icon: const Icon(
                        Icons.photo_library_outlined,
                        color: AppColors.goldBright,
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.borderGoldSubtle,
                        ),
                        shape: const CircleBorder(),
                        fixedSize: const Size(48, 48),
                        backgroundColor: Colors.black.withOpacity(0.35),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Main Camera Shutter Button (as shown in Mockup)
                    InkWell(
                      onTap: _openingCamera ? null : () => _takeSelfie(source: ImageSource.camera),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xE6080603),
                          border: Border.all(
                            color: AppColors.goldBright,
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldPrimary.withOpacity(0.32),
                              blurRadius: 22,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: _openingCamera
                              ? const SizedBox.square(
                                  dimension: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.goldBright,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  color: AppColors.goldBright,
                                  size: 38,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Spacer for symmetry
                    const SizedBox(width: 48),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Back',
    onPressed: onPressed,
    icon: const Icon(
      Icons.arrow_back_ios_new_rounded,
      color: AppColors.goldBright,
      size: 18,
    ),
    style: IconButton.styleFrom(
      side: const BorderSide(color: AppColors.borderGoldSubtle),
      shape: const CircleBorder(),
      fixedSize: const Size(42, 42),
      backgroundColor: Colors.black.withOpacity(0.28),
    ),
  );
}

class _GoldDivider extends StatelessWidget {
  const _GoldDivider();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider(color: AppColors.borderGoldSubtle)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9),
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.goldPrimary),
            ),
          ),
        ),
      ),
      const Expanded(child: Divider(color: AppColors.borderGoldSubtle)),
    ],
  );
}

class _FaceCornersPainter extends CustomPainter {
  const _FaceCornersPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 8.0;
    const length = 24.0;
    final paint = Paint()
      ..color = AppColors.goldBright
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final corners = <(Offset, Offset, Offset)>[
      (Offset(inset, inset), Offset(length, 0), Offset(0, length)),
      (
        Offset(size.width - inset, inset),
        Offset(-length, 0),
        Offset(0, length),
      ),
      (
        Offset(inset, size.height - inset),
        Offset(length, 0),
        Offset(0, -length),
      ),
      (
        Offset(size.width - inset, size.height - inset),
        Offset(-length, 0),
        Offset(0, -length),
      ),
    ];
    for (final (origin, horizontal, vertical) in corners) {
      canvas.drawLine(origin, origin + horizontal, paint);
      canvas.drawLine(origin, origin + vertical, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FaceCornersPainter oldDelegate) => false;
}
