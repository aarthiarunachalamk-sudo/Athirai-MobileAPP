import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';
import '../widgets/athirai_logo.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/gold_primary_button.dart';
import '../widgets/gold_text_field.dart';
import 'organization_lookup_screen.dart';

class SSOEmailScreen extends ConsumerStatefulWidget {
  const SSOEmailScreen({super.key});

  @override
  ConsumerState<SSOEmailScreen> createState() => _SSOEmailScreenState();
}

class _SSOEmailScreenState extends ConsumerState<SSOEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _inlineError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _inlineError = 'Please enter your work email.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _inlineError = AppStrings.errorInvalidEmail);
      return;
    }

    setState(() => _inlineError = null);
    ref.read(authControllerProvider.notifier).setSsoEmail(email);

    // Navigate to OrganizationLookupScreen which handles discovery and shows Screen 3 & 4
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrganizationLookupScreen(workEmail: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  // Top navigation row
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.goldPrimary, size: 24),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  // Logo
                  const SizedBox(height: 12),
                  const AthiraiLogo(width: 155),

                  const SizedBox(height: 30),

                  // Heading
                  Text(
                    AppStrings.ssoEmailTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    AppStrings.ssoEmailSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      color: AppColors.champagne.withOpacity(0.85),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Work Email Input
                  GoldTextField(
                    label: AppStrings.workEmailLabel,
                    hintText: AppStrings.workEmailHint,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                    errorText: _inlineError,
                    onSubmitted: (_) => _submit(),
                    onChanged: (_) {
                      if (_inlineError != null) setState(() => _inlineError = null);
                    },
                  ),

                  const SizedBox(height: 22),

                  // Continue Button
                  GoldPrimaryButton(
                    text: AppStrings.continueBtn,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 24),

                  // Secure Redirect Badge Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14110D).withOpacity(0.75),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderGoldSubtle.withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          color: AppColors.goldPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppStrings.ssoRedirectHelper,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Back to Sign In Link
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      AppStrings.backToSignIn,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.goldPrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.goldPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
