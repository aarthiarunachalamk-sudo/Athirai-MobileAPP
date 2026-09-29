import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/gold_primary_button.dart';
import '../widgets/gold_text_field.dart';
import 'athirai_entry_screen.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).currentUser;
    final email = user?.email ?? ref.read(authControllerProvider).currentSsoEmail ?? 'user@company.com';
    _emailController.text = email;
    _nameController.text = user?.fullName.isNotEmpty == true ? user!.fullName : 'Athirai User';
    _mobileController.text = user?.mobileNumber ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _inlineError = 'Please enter your full name.');
      return;
    }

    setState(() => _inlineError = null);

    final success = await ref.read(authControllerProvider.notifier).updateProfile(
      fullName: name,
      mobileNumber: _mobileController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AthiraiEntryScreen()),
      );
    } else {
      final err = ref.read(authControllerProvider).errorMessage;
      setState(() => _inlineError = err ?? 'Failed to update profile.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back navigation
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.goldPrimary, size: 24),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Title
                  Text(
                    AppStrings.completeProfileTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    AppStrings.completeProfileSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.champagne.withOpacity(0.85),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Avatar with Camera edit badge
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 94,
                          height: 94,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.goldBright, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldGlow.withOpacity(0.35),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              AppAssets.profileAvatar,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF14110D),
                              border: Border.all(color: AppColors.goldBright, width: 1.2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.goldBright,
                              size: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Full Name input
                  GoldTextField(
                    label: AppStrings.fullNameLabel,
                    hintText: AppStrings.fullNameHint,
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    errorText: _inlineError,
                  ),

                  const SizedBox(height: 18),

                  // Work Email input (locked)
                  GoldTextField(
                    label: 'Work Email',
                    hintText: 'user@company.com',
                    controller: _emailController,
                    readOnly: true,
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                    suffixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Mobile Number (Optional) input
                  GoldTextField(
                    label: AppStrings.mobileLabel,
                    hintText: AppStrings.mobileHint,
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),

                  const SizedBox(height: 32),

                  // Continue to Athirai Primary CTA
                  GoldPrimaryButton(
                    text: AppStrings.continueToAthirai,
                    isLoading: authState.isLoading,
                    onPressed: _saveProfile,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
