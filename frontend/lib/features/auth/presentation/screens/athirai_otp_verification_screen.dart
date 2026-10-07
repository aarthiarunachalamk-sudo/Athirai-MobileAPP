import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shop/presentation/theme/heritage_theme.dart';
import '../../../shop/presentation/screens/athirai_flow_container.dart';

/// Screen 4 (Image 2): Verify Your Number (OTP)
/// Displays 6-digit verification code input with countdown timer,
/// luxury gold styling, and the illuminated sacred deity artwork at the bottom.
class AthiraiOtpVerificationScreen extends StatefulWidget {
  const AthiraiOtpVerificationScreen({
    super.key,
    this.phoneNumber = '+91 98765 43210',
    this.onVerified,
  });

  final String phoneNumber;
  final VoidCallback? onVerified;

  @override
  State<AthiraiOtpVerificationScreen> createState() =>
      _AthiraiOtpVerificationScreenState();
}

class _AthiraiOtpVerificationScreenState
    extends State<AthiraiOtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendSeconds = 45;
  Timer? _timer;
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Pre-fill a sample cursor or first digit for preview fidelity
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (value.length > 1) {
        _controllers[index].text = value.substring(value.length - 1);
      }
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyCode();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  void _verifyCode() {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      _showRegistrationSuccessDialog(context);
    });
  }

  void _showRegistrationSuccessDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF061B18),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.25),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 40,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Golden Laurel & Check Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFFFFDF7A),
                      Color(0xFFC7A45B),
                      Color(0xFF8A623D),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFDF7A).withOpacity(0.4),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.verified_rounded, color: Color(0xFF04120E), size: 40),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                'Registration Successful!',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF7F2E8),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'பதிவு வெற்றிகரமாக முடிந்தது!',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: HeritageTheme.goldBright,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Welcome Bonus Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x33D4AF37),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFFFFDF7A), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '+100 AUG Coins Welcome Gift (₹1)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFDF7A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'Welcome, Royal Patron! Your account for ${widget.phoneNumber} is verified. Your AUG Coins vault is ready for gold purchases.',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  height: 1.45,
                  color: const Color(0xFFD1DFDE),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Action: Go to Profile Dashboard
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    if (widget.onVerified != null) {
                      widget.onVerified!();
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const AthiraiFlowContainer(initialScreenIndex: 9),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HeritageTheme.goldPrimary,
                    foregroundColor: const Color(0xFF041814),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Go to Profile Dashboard / தொடர்க',
                    style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeritageTheme.darkBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background subtle dark emerald gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.4),
                radius: 1.2,
                colors: [
                  Color(0xFF081C17),
                  Color(0xFF040F0D),
                  Color(0xFF020706),
                ],
              ),
            ),
          ),

          // Bottom Sacred Deity Artwork with Diyas & Lotus
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 290,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  AppAssets.otpDeity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.transparent,
                  ),
                ),
                // Gradient feather at the top of the deity image
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.45, 1.0],
                        colors: [
                          HeritageTheme.darkBg,
                          HeritageTheme.darkBg.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Form Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),

                  // Header with Back Button
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: HeritageTheme.goldPrimary,
                          size: 19,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Athirai Jewel Logo Emblem
                  _buildBrandLogo(),

                  const SizedBox(height: 26),

                  // Title: "Verify Your Number"
                  Text(
                    'Verify Your Number',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: HeritageTheme.textLight,
                      letterSpacing: 0.4,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle: "We have sent a 6 digit code to +91 98765 43210"
                  Text(
                    'We have sent a 6 digit code to\n${widget.phoneNumber}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: HeritageTheme.textMutedDark,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 6 OTP Digit Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) => _buildOtpBox(index)),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.error,
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // "Resend code in 00:45"
                  Text(
                    'Resend code in ${_formatTimer(_resendSeconds)}',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: HeritageTheme.textMutedDark,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // "Verify" Gold Gradient Button
                  _buildVerifyButton(),

                  const SizedBox(height: 20),

                  // "─── OR ───"
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: HeritageTheme.goldBorderSubtle,
                          thickness: 0.8,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'OR',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: HeritageTheme.textMutedDark,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: HeritageTheme.goldBorderSubtle,
                          thickness: 0.8,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // "Change Mobile Number"
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Text(
                      'Change Mobile Number',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: HeritageTheme.textLight,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.emeraldCrest,
          height: 56,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(height: 10),
        Text(
          'ATHIRAI',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 6.0,
            color: const Color(0xFFE2C479),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'TIMELESS JEWELS',
          style: GoogleFonts.inter(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 4.5,
            color: const Color(0xFFC5A059),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    final isFocused = _focusNodes[index].hasFocus;
    return Container(
      width: 48,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0x38061A14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused
              ? const Color(0xFFE5C170)
              : const Color(0x66C5A059),
          width: isFocused ? 1.5 : 1.0,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFFE5C170).withOpacity(0.22),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF7F2E8),
          ),
          cursorColor: const Color(0xFFE5C170),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (val) => _onDigitChanged(index, val),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE8C87A),
            Color(0xFFC59F4E),
            Color(0xFFDFB75E),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFFFF0C2).withOpacity(0.6),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC59F4E).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: _isVerifying ? null : _verifyCode,
          child: Center(
            child: _isVerifying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF161108)),
                    ),
                  )
                : Text(
                    'Verify',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: const Color(0xFF161108),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
