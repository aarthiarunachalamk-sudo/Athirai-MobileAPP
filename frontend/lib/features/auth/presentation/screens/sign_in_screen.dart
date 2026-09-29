import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';
import '../../data/services/secure_storage_service.dart';
import '../widgets/athirai_logo.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/gold_outline_button.dart';
import '../widgets/gold_primary_button.dart';
import '../widgets/gold_text_field.dart';
import 'athirai_entry_screen.dart';
import 'complete_profile_screen.dart';
import 'register_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _identifierController = TextEditingController();
  String? _inlineError;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedIdentifier();
  }

  Future<void> _loadRememberedIdentifier() async {
    final remembered = await SecureStorageService().getRememberedIdentifier();
    if (!mounted || remembered == null || remembered.isEmpty) return;
    _identifierController.text = remembered;
    setState(() => _rememberMe = true);
  }

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() async {
    final text = _identifierController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _inlineError = AppStrings.errorEmptyIdentifier;
      });
      return;
    }

    setState(() {
      _inlineError = null;
    });

    final storage = SecureStorageService();
    if (_rememberMe) {
      await storage.saveRememberedIdentifier(text);
    } else {
      await storage.clearRememberedIdentifier();
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .loginWithIdentifier(text);
    if (!mounted) return;

    if (success) {
      final authState = ref.read(authControllerProvider);
      if (authState.requiresProfileCompletion) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AthiraiEntryScreen()),
        );
      }
    } else {
      final err = ref.read(authControllerProvider).errorMessage;
      setState(() {
        _inlineError = err ?? AppStrings.errorGenericAuth;
      });
    }
  }

  void _showForgotPassword() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.borderGoldSubtle, width: 1),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reset your password', style: GoogleFonts.cormorantGaramond(
              fontSize: 25, fontWeight: FontWeight.w600, color: AppColors.goldBright,
            )),
            const SizedBox(height: 12),
            Text(
              'For help recovering access, contact concierge@athirai.com. Include the email address on your account.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showHelpModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.borderGoldSubtle, width: 1),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Athirai Concierge Assistance',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.goldBright,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'For membership assistance, bespoke inquiries, or corporate SSO onboarding, our dedicated concierge team is available 24/7.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBlack,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGoldSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.support_agent_rounded,
                      color: AppColors.goldPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'concierge@athirai.com\n+1 (800) 888-JEWELS',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: AppColors.champagne,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showLegalModal(String title, String content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.borderGoldSubtle, width: 1),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldBright,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      resizeToAvoidBottomInset: true,
      body: CosmicBackground(
        imageAsset: AppAssets.signInReferenceBg,
        showFrame: false,
        overlayOpacity: 0.04,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top Logo with breathing space (20–30 px from SafeArea top)
                        const SizedBox(height: 16),
                        AthiraiLogo(
                          width: (constraints.maxWidth * 0.52).clamp(
                            180.0,
                            245.0,
                          ),
                          imageAsset: AppAssets.referenceLogo,
                          showGlow: false,
                        ),

                        // Logo → heading: 24–34 px
                        const SizedBox(height: 14),

                        // Sign in Heading
                        Text(
                          AppStrings.signInTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),

                        // Heading → subtitle: 8–10 px
                        const SizedBox(height: 9),

                        // Subtitle
                        Text(
                          AppStrings.signInSubtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.champagne.withOpacity(0.85),
                            letterSpacing: 0.1,
                          ),
                        ),

                        // Subtitle → input: 26–32 px
                        const SizedBox(height: 28),

                        // Email or mobile number input
                        GoldTextField(
                          label: AppStrings.emailOrMobileLabel,
                          hintText: AppStrings.emailOrMobileHint,
                          controller: _identifierController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          errorText: _inlineError,
                          onSubmitted: (_) => _validateAndSubmit(),
                          onChanged: (_) {
                            if (_inlineError != null) {
                              setState(() => _inlineError = null);
                            }
                          },
                        ),

                        // Input → primary CTA: 18–22 px
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              activeColor: AppColors.goldPrimary,
                              checkColor: AppColors.backgroundBlack,
                              side: const BorderSide(color: AppColors.goldPrimary),
                              onChanged: (value) => setState(() => _rememberMe = value ?? false),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _rememberMe = !_rememberMe),
                              child: Text('Remember me', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _showForgotPassword,
                              style: TextButton.styleFrom(foregroundColor: AppColors.goldPrimary),
                              child: Text('Forgot password?', style: GoogleFonts.inter(fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Continue Primary Button
                        GoldPrimaryButton(
                          text: AppStrings.continueBtn,
                          isLoading: authState.isLoading,
                          onPressed: _validateAndSubmit,
                        ),

                        // CTA → terms: 16 px
                        const SizedBox(height: 16),

                        // Terms text
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                            children: [
                              const TextSpan(
                                text: 'By continuing, you agree to Athirai’s\n',
                              ),
                              TextSpan(
                                text: AppStrings.termsConditions,
                                style: const TextStyle(
                                  color: AppColors.goldPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _showLegalModal(
                                      'Conditions of Use',
                                      'By accessing Athirai - Timeless Jewels, you accept our bespoke digital concierge and luxury jewelry terms, ensuring highest authenticity, digital encryption, and certified provenance for all collections.',
                                    );
                                  },
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: AppStrings.privacyNotice,
                                style: const TextStyle(
                                  color: AppColors.goldPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _showLegalModal(
                                      'Privacy Notice',
                                      'Your privacy is guarded with enterprise-grade security. Athirai will never share or disclose your personal details, biometric tokens, or private collection credentials.',
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),

                        // Terms → divider: 24–28 px
                        const SizedBox(height: 18),

                        // OR Divider
                        const SizedBox(height: 28),

                        // Create your Athirai account Button
                        GoldOutlineButton(
                          text: AppStrings.createAccount,
                          height: 48,
                          showArrow: true,
                          borderColor: const Color(0xFFF2EDD8),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                        ),

                        // Create account → Need help: 25–32 px
                        const SizedBox(height: 26),

                        // Need help?
                        GestureDetector(
                          onTap: _showHelpModal,
                          child: Text(
                            AppStrings.needHelp,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              color: AppColors.goldPrimary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.goldPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),

                        // Bottom padding allowing the glowing Earth horizon to shine through beautifully
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
