import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/athirai_logo.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/gold_primary_button.dart';
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

  Future<void> _takeSelfie() async {
    setState(() => _openingCamera = true);
    try {
      final selfie = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 92,
      );
      if (!mounted) return;
      if (selfie != null) setState(() => _selfiePath = selfie.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open the camera. Check camera permission and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingCamera = false);
    }
  }

  void _continue() {
    final path = _selfiePath;
    if (path == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AvatarCreationScreen(selfiePath: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final previewSize = (screen.width * 0.76).clamp(250.0, 360.0);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: CosmicBackground(
        imageAsset: AppAssets.signInReferenceBg,
        overlayOpacity: 0.12,
        showFrame: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                    const Spacer(),
                    const AthiraiLogo(width: 142),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '02. AI SELFIE & SCAN',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    color: AppColors.goldBright,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.1,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: previewSize,
                  height: previewSize * 1.08,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.goldPrimary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldPrimary.withOpacity(0.28),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _selfiePath == null
                        ? Container(
                            color: const Color(0xAA090704),
                            child: const Icon(
                              Icons.face_retouching_natural_rounded,
                              size: 104,
                              color: AppColors.goldPrimary,
                            ),
                          )
                        : Image.file(File(_selfiePath!), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _selfiePath == null ? 'Take a Selfie' : 'Selfie captured',
                  style: GoogleFonts.cormorantGaramond(
                    color: AppColors.champagne,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Face the camera in good light. We will use this photo for your Athirai avatar.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                if (_selfiePath == null)
                  InkWell(
                    onTap: _openingCamera ? null : _takeSelfie,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldPrimary,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldPrimary.withOpacity(0.24),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _openingCamera
                            ? const CircularProgressIndicator(
                                color: AppColors.goldPrimary,
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.goldBright,
                                size: 42,
                              ),
                      ),
                    ),
                  )
                else ...[
                  GoldPrimaryButton(
                    text: 'Create AI Avatar',
                    showArrow: true,
                    onPressed: _continue,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _takeSelfie,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retake selfie'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.goldPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
