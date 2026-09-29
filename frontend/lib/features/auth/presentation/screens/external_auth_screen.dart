import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';
import '../widgets/cosmic_background.dart';
import 'auth_processing_screen.dart';

class ExternalAuthScreen extends ConsumerStatefulWidget {
  final String email;
  final String organizationName;

  const ExternalAuthScreen({
    super.key,
    required this.email,
    required this.organizationName,
  });

  @override
  ConsumerState<ExternalAuthScreen> createState() => _ExternalAuthScreenState();
}

class _ExternalAuthScreenState extends ConsumerState<ExternalAuthScreen> {
  // Mode: 0 = Organization Sign-In (Screen 5), 1 = MFA Verification (Screen 6)
  int _currentStep = 0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _loginError;

  // MFA 6-digit OTP controllers
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  String? _mfaError;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _submitCredentials() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _loginError = 'Please enter your corporate password.');
      return;
    }

    setState(() {
      _loginError = null;
      _isProcessing = true;
    });

    final res = await ref
        .read(authControllerProvider.notifier)
        .submitIdpCredentials(_emailController.text.trim(), password);

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (res != null) {
      if (res['requires_mfa'] == true) {
        setState(() {
          _currentStep = 1; // Move to Screen 6: Verification (MFA)
        });
      } else {
        final code = res['code'] as String?;
        if (code != null) {
          _proceedToProcessing(code);
        }
      }
    } else {
      final err = ref.read(authControllerProvider).errorMessage;
      setState(() => _loginError = err ?? 'Authentication failed');
    }
  }

  void _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      setState(() => _mfaError = 'Please enter the complete 6-digit code.');
      return;
    }

    setState(() {
      _mfaError = null;
      _isProcessing = true;
    });

    final code = await ref
        .read(authControllerProvider.notifier)
        .verifyMfaCode(otp);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (code != null) {
      _proceedToProcessing(code);
    } else {
      final err = ref.read(authControllerProvider).errorMessage;
      setState(() => _mfaError = err ?? 'Invalid code');
    }
  }

  void _proceedToProcessing(String code) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => AuthProcessingScreen(authCode: code)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.goldPrimary,
          ),
          onPressed: () {
            if (_currentStep == 1) {
              setState(() => _currentStep = 0);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, kToolbarHeight, 24, 24),
              child: _currentStep == 0
                  ? _buildIdpLoginCard()
                  : _buildMfaVerificationCard(),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Screen 5: Organization Sign-In (IdP)
  // ==========================================
  Widget _buildIdpLoginCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.idpSignInTitle,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1D2939),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.idpSignInSubtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 24),

          // Email Input (pre-filled)
          Text(
            AppStrings.idpEmailLabel,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF344054),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _emailController,
            readOnly: true,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF1D2939),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Password Input
          Text(
            AppStrings.idpPasswordLabel,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF344054),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitCredentials(),
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF1D2939),
            ),
            decoration: InputDecoration(
              hintText: AppStrings.idpPasswordHint,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF98A2B3),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF667085),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),

          if (_loginError != null) ...[
            const SizedBox(height: 8),
            Text(
              _loginError!,
              style: GoogleFonts.inter(fontSize: 12.5, color: Colors.redAccent),
            ),
          ],

          const SizedBox(height: 22),

          // Corporate Blue Sign In Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.idpBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isProcessing ? null : _submitCredentials,
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : Text(
                      AppStrings.idpSignInBtn,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              AppStrings.forgotPassword,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppColors.idpBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEAECF0)),
          const SizedBox(height: 12),

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.apartment_outlined,
                  size: 18,
                  color: Color(0xFF475467),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.idpAnotherMethod,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: const Color(0xFF475467),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Screen 6: Verification (MFA)
  // ==========================================
  Widget _buildMfaVerificationCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Blue Shield Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.idpBlue.withOpacity(0.12),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: AppColors.idpBlue,
              size: 30,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            AppStrings.mfaTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1D2939),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            AppStrings.mfaSubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: const Color(0xFF667085),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 28),

          // 6-digit OTP code inputs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (i) {
              return SizedBox(
                width: 44,
                height: 52,
                child: TextField(
                  controller: _otpControllers[i],
                  focusNode: _otpFocusNodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D2939),
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.idpBlue,
                        width: 1.8,
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && i < 5) {
                      _otpFocusNodes[i + 1].requestFocus();
                    } else if (val.isEmpty && i > 0) {
                      _otpFocusNodes[i - 1].requestFocus();
                    }
                    if (_otpControllers.every((c) => c.text.isNotEmpty)) {
                      _verifyOtp();
                    }
                  },
                ),
              );
            }),
          ),

          if (_mfaError != null) ...[
            const SizedBox(height: 10),
            Text(
              _mfaError!,
              style: GoogleFonts.inter(fontSize: 12.5, color: Colors.redAccent),
            ),
          ],

          const SizedBox(height: 26),

          // Blue Verify Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.idpBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isProcessing ? null : _verifyOtp,
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : Text(
                      AppStrings.verifyBtn,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            AppStrings.resendCode,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.idpBlue,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Use another method',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}
