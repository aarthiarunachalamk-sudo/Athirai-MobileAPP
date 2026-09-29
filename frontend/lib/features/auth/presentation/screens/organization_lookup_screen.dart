import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';
import '../widgets/athirai_logo.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/gold_primary_button.dart';
import '../widgets/loading_gold_ring.dart';
import 'external_auth_screen.dart';

class OrganizationLookupScreen extends ConsumerStatefulWidget {
  final String workEmail;

  const OrganizationLookupScreen({
    super.key,
    required this.workEmail,
  });

  @override
  ConsumerState<OrganizationLookupScreen> createState() => _OrganizationLookupScreenState();
}

class _OrganizationLookupScreenState extends ConsumerState<OrganizationLookupScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  void _startDiscovery() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Provide smooth luxury transition time for the glowing ring loading state (Screen 3)
    await Future.delayed(const Duration(milliseconds: 1400));
    final success = await ref.read(authControllerProvider.notifier).discoverSSO(widget.workEmail);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (!success) {
          _errorMessage = ref.read(authControllerProvider).errorMessage ?? AppStrings.errorOrgNotFound;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final org = authState.currentOrganization;

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: CosmicBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26.0),
            child: _isLoading
                ? _buildLoadingView() // Screen 3: Finding your organization...
                : (_errorMessage != null
                    ? _buildErrorView()
                    : _buildFoundView(org?.name ?? 'Organization Found')), // Screen 4: Organization Found
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Screen 3: Finding your organization...
  // ==========================================
  Widget _buildLoadingView() {
    return Column(
      children: [
        const SizedBox(height: 28),
        const AthiraiLogo(width: 155),
        const Spacer(flex: 2),

        // Glowing Animated Gold Ring
        const LoadingGoldRing(size: 110),

        const SizedBox(height: 38),

        // Title
        Text(
          AppStrings.findingOrgTitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          AppStrings.findingOrgSubtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.champagne.withOpacity(0.85),
          ),
        ),

        const Spacer(flex: 3),
        const SizedBox(height: 40),
      ],
    );
  }

  // ==========================================
  // Screen 4: Organization Found
  // ==========================================
  Widget _buildFoundView(String orgName) {
    return Column(
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

        const SizedBox(height: 12),
        const AthiraiLogo(width: 155),

        const SizedBox(height: 16),

        Text(
          'Organization Found',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.goldPrimary,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 36),

        // Organization Found Glass Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF16130F).withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGold.withOpacity(0.8), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldBright.withOpacity(0.08),
                blurRadius: 24,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Gold building icon with soft glow
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cardBlack,
                  border: Border.all(color: AppColors.borderGoldSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldGlow.withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: AppColors.goldBright,
                  size: 34,
                ),
              ),

              const SizedBox(height: 20),

              // Organization Name / Header
              Text(
                orgName,
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldBright,
                ),
              ),

              const SizedBox(height: 10),

              // Description
              Text(
                AppStrings.orgFoundSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        // Continue with SSO Primary Button
        GoldPrimaryButton(
          text: AppStrings.continueWithSSO,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ExternalAuthScreen(
                  email: widget.workEmail,
                  organizationName: orgName,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 22),

        // Use another email Link
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.useAnotherEmail,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.goldPrimary,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.goldPrimary,
            ),
          ),
        ),

        const Spacer(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.goldPrimary, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const SizedBox(height: 20),
        const AthiraiLogo(width: 155),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBlack,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.error.withOpacity(0.6)),
          ),
          child: Column(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 36),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'Unable to find organization',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        GoldPrimaryButton(
          text: 'Try Again',
          onPressed: _startDiscovery,
        ),
        const Spacer(),
      ],
    );
  }
}
