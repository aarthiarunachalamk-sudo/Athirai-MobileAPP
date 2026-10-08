import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../controllers/auth_controller.dart';
import 'athirai_otp_verification_screen.dart';
import 'sso_email_screen.dart';

/// Screen-accurate luxury registration screen matching Screen 3 of the Athirai reference:
/// - Dark emerald temple courtyard architecture background
/// - Top bar with left-aligned back button
/// - Athirai emerald drop jewel crest + "ATHIRAI / TIMELESS JEWELS"
/// - "Create Your Account" serif headline & luxury onboarding subtitle
/// - Translucent dark emerald pill capsule fields for Full Name, Email, Mobile, Password, Confirm Password
/// - "I agree to the Terms & Conditions and Privacy Policy" checkbox
/// - Golden gradient pill button "Register →"
/// - "OR" divider & "Register with SSO" capsule button
/// - "Already have an account? Login" footer
/// - Golden geometric lotus ornament at bottom
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _mobileFocus = FocusNode();
  final _pwFocus = FocusNode();
  final _confirmPwFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  String? _error;
  String? _nameError;
  String? _emailError;
  String? _mobileError;
  String? _pwError;
  String? _confirmError;
  String? _termsError;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _mobileFocus.dispose();
    _pwFocus.dispose();
    _confirmPwFocus.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final name = _fullNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmPasswordCtrl.text;

    String? nameErr;
    String? emailErr;
    String? mobileErr;
    String? pwErr;
    String? confirmErr;
    String? termsErr;

    if (name.isEmpty) {
      nameErr = 'Please enter your full name.';
    } else if (name.length < 2) {
      nameErr = 'Name must be at least 2 characters.';
    }

    if (email.isEmpty) {
      emailErr = 'Please enter your email address.';
    } else {
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(email)) {
        emailErr = 'Please enter a valid email address.';
      }
    }

    if (mobile.isEmpty) {
      mobileErr = 'Please enter your mobile number.';
    } else {
      final digits = mobile.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 10) {
        mobileErr = 'Please enter a valid 10-digit mobile number.';
      } else if (digits.length == 10 && !RegExp(r'^[6-9]').hasMatch(digits)) {
        mobileErr = 'Mobile number must start with 6, 7, 8, or 9.';
      }
    }

    if (password.isEmpty) {
      pwErr = 'Please enter your password.';
    } else if (password.length < 6) {
      pwErr = 'Password must be at least 6 characters.';
    }

    if (confirm.isEmpty) {
      confirmErr = 'Please confirm your password.';
    } else if (confirm != password) {
      confirmErr = 'Passwords do not match.';
    }

    if (!_agreedToTerms) {
      termsErr = 'Please agree to the Terms & Conditions.';
    }

    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _mobileError = mobileErr;
      _pwError = pwErr;
      _confirmError = confirmErr;
      _termsError = termsErr;
      _error = nameErr ?? emailErr ?? mobileErr ?? pwErr ?? confirmErr ?? termsErr;
    });

    return nameErr == null &&
        emailErr == null &&
        mobileErr == null &&
        pwErr == null &&
        confirmErr == null &&
        termsErr == null;
  }

  void _clearErrors() {
    if (_error != null ||
        _nameError != null ||
        _emailError != null ||
        _mobileError != null ||
        _pwError != null ||
        _confirmError != null ||
        _termsError != null) {
      setState(() {
        _error = null;
        _nameError = null;
        _emailError = null;
        _mobileError = null;
        _pwError = null;
        _confirmError = null;
        _termsError = null;
      });
    }
  }

  Future<void> _submit() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    final fullName = _fullNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();
    final password = _passwordCtrl.text;

    final parts = fullName.split(' ');
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : 'Customer';

    final delivery = await ref.read(authControllerProvider.notifier).register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      mobile: mobile,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (delivery != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AthiraiOtpVerificationScreen(
            phoneNumber: mobile.startsWith('+') ? mobile : '+91 $mobile',
            registrationEmail: email,
            mobileNumber: mobile,
            emailInitiallySent: delivery['email_sent'] ?? false,
            mobileInitiallySent: delivery['mobile_sent'] ?? false,
          ),
        ),
      );
    } else {
      final err = ref.read(authControllerProvider).errorMessage;
      setState(() {
        _error = err ?? 'Registration could not be completed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030D0A),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Background: Temple courtyard ────────────────────────────
          Positioned.fill(
            child: Image.asset(
              AppAssets.templeArchChandelier,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // ── Atmospheric Dark Emerald Gradient Vignette ─────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC030E0B),
                    Color(0xEE020907),
                    Color(0xFC010605),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // ── Bottom Foliage Botanical Vines ──────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 120,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _RegisterFoliagePainter(),
              ),
            ),
          ),

          // ── Scrollable Form Content ─────────────────────────────────
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: (constraints.maxWidth * 0.08).clamp(20.0, 38.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Top Navigation Row: Back Button ─────────────────
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              tooltip: 'Back',
                              onPressed: () => Navigator.of(context).maybePop(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xFFC5A059),
                                size: 18,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // ── Brand Crest: Emerald Drop Jewel Emblem ─────────
                        Image.asset(
                          AppAssets.emeraldCrest,
                          height: 58,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),

                        const SizedBox(height: 10),

                        // ── ATHIRAI Brand Typography ───────────────────────
                        Text(
                          'ATHIRAI',
                          textAlign: TextAlign.center,
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
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4.5,
                            color: const Color(0xFFC5A059),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ── Heading: Create Your Account ───────────────────
                        Text(
                          'Create Your Account',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFF7F2E8),
                            letterSpacing: 0.4,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Join Athirai and be a part of an exclusive\njewellery experience.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: const Color(0xFF8E9E94),
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ── Field 1: Full Name ─────────────────────────────
                        _RegisterCapsuleField(
                          controller: _fullNameCtrl,
                          focusNode: _nameFocus,
                          hint: 'Full Name',
                          prefixIcon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _emailFocus.requestFocus(),
                          onChanged: (_) => _clearErrors(),
                          errorText: _nameError,
                        ),

                        const SizedBox(height: 12),

                        // ── Field 2: Email Address ─────────────────────────
                        _RegisterCapsuleField(
                          controller: _emailCtrl,
                          focusNode: _emailFocus,
                          hint: 'Email Address',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _mobileFocus.requestFocus(),
                          onChanged: (_) => _clearErrors(),
                          errorText: _emailError,
                        ),

                        const SizedBox(height: 12),

                        // ── Field 3: Mobile Number ─────────────────────────
                        _RegisterCapsuleField(
                          controller: _mobileCtrl,
                          focusNode: _mobileFocus,
                          hint: 'Mobile Number',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _pwFocus.requestFocus(),
                          onChanged: (_) => _clearErrors(),
                          errorText: _mobileError,
                        ),

                        const SizedBox(height: 12),

                        // ── Field 4: Password ──────────────────────────────
                        _RegisterCapsuleField(
                          controller: _passwordCtrl,
                          focusNode: _pwFocus,
                          hint: 'Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _confirmPwFocus.requestFocus(),
                          onChanged: (_) => _clearErrors(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 19,
                              color: const Color(0xFF8E9E94),
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          errorText: _pwError,
                        ),

                        const SizedBox(height: 12),

                        // ── Field 5: Confirm Password ──────────────────────
                        _RegisterCapsuleField(
                          controller: _confirmPasswordCtrl,
                          focusNode: _confirmPwFocus,
                          hint: 'Confirm Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          onChanged: (_) => _clearErrors(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 19,
                              color: const Color(0xFF8E9E94),
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword,
                            ),
                          ),
                          errorText: _confirmError,
                        ),

                        const SizedBox(height: 12),

                        // ── Agreement Checkbox ─────────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _agreedToTerms,
                                activeColor: const Color(0xFFC5A059),
                                checkColor: const Color(0xFF04120F),
                                side: const BorderSide(
                                  color: Color(0xFF6B7E74),
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (v) {
                                  setState(() {
                                    _agreedToTerms = v ?? false;
                                    if (_agreedToTerms) _termsError = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    color: const Color(0xFF8E9E94),
                                    height: 1.4,
                                  ),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style: const TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()..onTap = () {},
                                    ),
                                    const TextSpan(text: '\nand '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: const TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()..onTap = () {},
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (_termsError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _termsError!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ),

                        // ── Top-level error message ────────────────────────
                        if (_error != null &&
                            _error != _nameError &&
                            _error != _emailError &&
                            _error != _mobileError &&
                            _error != _pwError &&
                            _error != _confirmError &&
                            _error != _termsError) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 16,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: GoogleFonts.inter(
                                      color: AppColors.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // ── Primary Action: Register → ──────────────────────
                        _RegisterGoldButton(
                          isLoading: _isLoading,
                          onPressed: _submit,
                        ),

                        const SizedBox(height: 20),

                        // ── Divider with OR ─────────────────────────────────
                        Row(
                          children: const [
                            Expanded(
                              child: Divider(
                                color: Color(0x3DC5A059),
                                thickness: 0.9,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  color: Color(0xFF7E8F85),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Color(0x3DC5A059),
                                thickness: 0.9,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ── Secondary Action: Register with SSO ─────────────
                        _RegisterSsoButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SSOEmailScreen(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Footer: Already have an account? Login ──────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: const Color(0xFF8E9E94),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).maybePop(),
                              child: Text(
                                'Login',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFD4AF37),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ── Bottom Sacred Lotus Ornament ────────────────────
                        const CustomPaint(
                          size: Size(54, 32),
                          painter: _RegisterLotusPainter(color: Color(0xFFC5A059)),
                        ),

                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Capsule Input Field ───────────────────────────────────────────────────────
class _RegisterCapsuleField extends StatefulWidget {
  const _RegisterCapsuleField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.onChanged,
    this.suffixIcon,
    this.errorText,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final String? errorText;

  @override
  State<_RegisterCapsuleField> createState() => _RegisterCapsuleFieldState();
}

class _RegisterCapsuleFieldState extends State<_RegisterCapsuleField> {
  late final FocusNode _focus;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(() {
      if (mounted) setState(() => _isFocused = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0x38061A14),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : (_isFocused
                      ? const Color(0xFFE5C170)
                      : const Color(0x66C5A059)),
              width: _isFocused ? 1.3 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFFE5C170).withOpacity(0.18),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 12),
                child: Icon(
                  widget.prefixIcon,
                  size: 19,
                  color: hasError
                      ? AppColors.error
                      : (_isFocused
                          ? const Color(0xFFE5C170)
                          : const Color(0xFFC5A059)),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  onChanged: widget.onChanged,
                  cursorColor: const Color(0xFFE5C170),
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    color: const Color(0xFFF7F2E8),
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: const Color(0xFF7A8C82),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (widget.suffixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: widget.suffixIcon!,
                ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 18),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 13,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Golden Gradient "Register →" Pill Button ──────────────────────────────────
class _RegisterGoldButton extends StatefulWidget {
  const _RegisterGoldButton({
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  State<_RegisterGoldButton> createState() => _RegisterGoldButtonState();
}

class _RegisterGoldButtonState extends State<_RegisterGoldButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: Container(
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
              BoxShadow(
                color: Colors.black.withOpacity(0.40),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF161108)),
                    ),
                  ),
                )
              : Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Register',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: const Color(0xFF161108),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Color(0xFF161108),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Secondary Capsule "Register with SSO" Button ──────────────────────────────
class _RegisterSsoButton extends StatelessWidget {
  const _RegisterSsoButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0x66C5A059), width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: const Color(0x22051612),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_outline_rounded,
              size: 18,
              color: Color(0xFFC5A059),
            ),
            const SizedBox(width: 8),
            Text(
              'Register with SSO',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFE6D6B8),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sacred Geometry Lotus Ornament ────────────────────────────────────────────
class _RegisterLotusPainter extends CustomPainter {
  const _RegisterLotusPainter({this.color = const Color(0xFFC5A059)});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Center petal
    final pCenter = Path();
    pCenter.moveTo(cx, cy + size.height * 0.42);
    pCenter.quadraticBezierTo(cx - size.width * 0.12, cy, cx, cy - size.height * 0.45);
    pCenter.quadraticBezierTo(cx + size.width * 0.12, cy, cx, cy + size.height * 0.42);
    canvas.drawPath(pCenter, paint);

    // Inner left petal
    final pInLeft = Path();
    pInLeft.moveTo(cx - size.width * 0.05, cy + size.height * 0.38);
    pInLeft.quadraticBezierTo(
      cx - size.width * 0.28,
      cy - size.height * 0.05,
      cx - size.width * 0.22,
      cy - size.height * 0.35,
    );
    pInLeft.quadraticBezierTo(
      cx - size.width * 0.12,
      cy - size.height * 0.1,
      cx,
      cy + size.height * 0.2,
    );
    canvas.drawPath(pInLeft, paint);

    // Inner right petal
    final pInRight = Path();
    pInRight.moveTo(cx + size.width * 0.05, cy + size.height * 0.38);
    pInRight.quadraticBezierTo(
      cx + size.width * 0.28,
      cy - size.height * 0.05,
      cx + size.width * 0.22,
      cy - size.height * 0.35,
    );
    pInRight.quadraticBezierTo(
      cx + size.width * 0.12,
      cy - size.height * 0.1,
      cx,
      cy + size.height * 0.2,
    );
    canvas.drawPath(pInRight, paint);

    // Outer left petal
    final pOutLeft = Path();
    pOutLeft.moveTo(cx - size.width * 0.08, cy + size.height * 0.35);
    pOutLeft.quadraticBezierTo(
      cx - size.width * 0.45,
      cy + size.height * 0.1,
      cx - size.width * 0.42,
      cy - size.height * 0.18,
    );
    pOutLeft.quadraticBezierTo(
      cx - size.width * 0.25,
      cy - size.height * 0.02,
      cx - size.width * 0.06,
      cy + size.height * 0.25,
    );
    canvas.drawPath(pOutLeft, paint);

    // Outer right petal
    final pOutRight = Path();
    pOutRight.moveTo(cx + size.width * 0.08, cy + size.height * 0.35);
    pOutRight.quadraticBezierTo(
      cx + size.width * 0.45,
      cy + size.height * 0.1,
      cx + size.width * 0.42,
      cy - size.height * 0.18,
    );
    pOutRight.quadraticBezierTo(
      cx + size.width * 0.25,
      cy - size.height * 0.02,
      cx + size.width * 0.06,
      cy + size.height * 0.25,
    );
    canvas.drawPath(pOutRight, paint);

    // Central diamond jewel
    final diamond = Path();
    diamond.moveTo(cx, cy + size.height * 0.12);
    diamond.lineTo(cx + 3.2, cy + size.height * 0.22);
    diamond.lineTo(cx, cy + size.height * 0.32);
    diamond.lineTo(cx - 3.2, cy + size.height * 0.22);
    diamond.close();
    canvas.drawPath(diamond, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Subtle Bottom Filigree Corner Painter ─────────────────────────────────────
class _RegisterFoliagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC5A059).withOpacity(0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    // Bottom left vine curve
    final leftVine = Path();
    leftVine.moveTo(0, size.height * 0.75);
    leftVine.cubicTo(
      size.width * 0.12,
      size.height * 0.60,
      size.width * 0.24,
      size.height * 0.88,
      size.width * 0.38,
      size.height * 0.96,
    );
    canvas.drawPath(leftVine, paint);

    // Bottom right vine curve
    final rightVine = Path();
    rightVine.moveTo(size.width, size.height * 0.75);
    rightVine.cubicTo(
      size.width * 0.88,
      size.height * 0.60,
      size.width * 0.76,
      size.height * 0.88,
      size.width * 0.62,
      size.height * 0.96,
    );
    canvas.drawPath(rightVine, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
