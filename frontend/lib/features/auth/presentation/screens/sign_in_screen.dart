import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../controllers/auth_controller.dart';
import '../../data/services/secure_storage_service.dart';
import '../widgets/athirai_logo.dart';
import '../widgets/cosmic_background.dart';
import 'athirai_entry_screen.dart';
import 'complete_profile_screen.dart';
import 'register_screen.dart';

/// Login screen — matches infisq.com/login exactly:
/// "WELCOME BACK / Sign in to Athirai"
/// Identifier field (email, phone or ID) + password field + ENTER YOUR WORKSPACE CTA
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _idFocus = FocusNode();
  final _pwFocus = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRemembered();
  }

  Future<void> _loadRemembered() async {
    final saved = await SecureStorageService().getRememberedIdentifier();
    if (!mounted || saved == null || saved.isEmpty) return;
    _identifierCtrl.text = saved;
    setState(() => _rememberMe = true);
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    _idFocus.dispose();
    _pwFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final id = _identifierCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (id.isEmpty) {
      setState(() => _error = 'Enter your email, phone or ID.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Enter your password.');
      return;
    }
    setState(() => _error = null);

    if (_rememberMe) {
      await SecureStorageService().saveRememberedIdentifier(id);
    } else {
      await SecureStorageService().clearRememberedIdentifier();
    }

    final ok = await ref
        .read(authControllerProvider.notifier)
        .loginWithIdentifier(id, password: password);
    if (!mounted) return;

    if (ok) {
      final s = ref.read(authControllerProvider);
      if (s.requiresProfileCompletion) {
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
      setState(
        () => _error = err ?? 'Unable to sign in. Please verify your details.',
      );
    }
  }

  void _showForgotPassword() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.borderGoldSubtle),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reset Your Password',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.goldBright,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'For help recovering access, contact concierge@athirai.com. '
              'Include the email address linked to your account.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      resizeToAvoidBottomInset: true,
      body: CosmicBackground(
        imageAsset: AppAssets.signInReferenceBg,
        showFrame: false,
        overlayOpacity: 0.04,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: (constraints.maxWidth * 0.08).clamp(20.0, 40.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 28),

                      // ── Logo ──────────────────────────────────────────────
                      AthiraiLogo(
                        width: (constraints.maxWidth * 0.50).clamp(
                          160.0,
                          230.0,
                        ),
                        imageAsset: AppAssets.referenceLogo,
                        showGlow: false,
                      ),

                      const SizedBox(height: 28),

                      // ── "WELCOME BACK" eyebrow ────────────────────────────
                      Text(
                        'WELCOME BACK',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3.2,
                          color: AppColors.goldPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ── Main heading ──────────────────────────────────────
                      Text(
                        'Sign in to Athirai',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.4,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Enter your credentials to continue to your workspace.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: AppColors.champagne.withOpacity(0.8),
                          height: 1.45,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Identifier field ──────────────────────────────────
                      _AuthField(
                        controller: _identifierCtrl,
                        focusNode: _idFocus,
                        label: 'Email, Phone or ID',
                        hint: 'name@example.com or +91 98765 43210',
                        prefixIcon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _pwFocus.requestFocus(),
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                      ),

                      const SizedBox(height: 14),

                      // ── Password field ────────────────────────────────────
                      _AuthField(
                        controller: _passwordCtrl,
                        focusNode: _pwFocus,
                        label: 'Password',
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        errorText: _error,
                      ),

                      // ── Remember me + Forgot password ─────────────────────
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              activeColor: AppColors.goldPrimary,
                              checkColor: AppColors.backgroundBlack,
                              side: const BorderSide(
                                color: AppColors.goldPrimary,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (v) =>
                                  setState(() => _rememberMe = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _rememberMe = !_rememberMe),
                            child: Text(
                              'Remember me',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _showForgotPassword,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.goldPrimary,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot password?',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: AppColors.goldPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      // ── ENTER YOUR WORKSPACE button ───────────────────────
                      _WorkspaceButton(
                        label: 'ENTER YOUR WORKSPACE',
                        isLoading: auth.isLoading,
                        onPressed: _submit,
                      ),

                      const SizedBox(height: 22),

                      // ── Encrypted & secure badge ──────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock_rounded,
                            size: 12,
                            color: AppColors.goldPrimary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Encrypted & secure',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Divider ───────────────────────────────────────────
                      _GoldDivider(label: 'OR'),

                      const SizedBox(height: 24),

                      // ── Register CTA ──────────────────────────────────────
                      _OutlineButton(
                        label: 'New to Athirai? Register / Create Account',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Legal ─────────────────────────────────────────────
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'By continuing, you agree to Athirai\'s ',
                            ),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: const TextStyle(
                                color: AppColors.goldPrimary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.goldPrimary,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Notice',
                              style: const TextStyle(
                                color: AppColors.goldPrimary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.goldPrimary,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),

                      // ── Copyright ─────────────────────────────────────────
                      const SizedBox(height: 20),
                      Text(
                        '© 2026 Athirai',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),

                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Register screen — matches infisq.com/register exactly:
// 3-step stepper: Personal Details → Delivery Address → Account Security
// ─────────────────────────────────────────────────────────────────────────────

// ── Shared input field widget ─────────────────────────────────────────────────
class _AuthField extends StatefulWidget {
  const _AuthField({
    required this.controller,
    required this.label,
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
    this.readOnly = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final String? errorText;
  final bool readOnly;

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
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
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFF14110D),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : (_isFocused
                        ? AppColors.goldBright
                        : AppColors.borderGold.withOpacity(0.7)),
              width: _isFocused ? 1.4 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.goldBright.withOpacity(0.18),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(
                  widget.prefixIcon,
                  size: 19,
                  color: hasError
                      ? AppColors.error
                      : (_isFocused
                            ? AppColors.goldBright
                            : AppColors.goldPrimary),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  readOnly: widget.readOnly,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  onChanged: widget.onChanged,
                  cursorColor: AppColors.goldBright,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (widget.suffixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: widget.suffixIcon!,
                ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 4),
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

// ── "ENTER YOUR WORKSPACE" primary button ─────────────────────────────────────
class _WorkspaceButton extends StatefulWidget {
  const _WorkspaceButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  State<_WorkspaceButton> createState() => _WorkspaceButtonState();
}

class _WorkspaceButtonState extends State<_WorkspaceButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
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
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE9A3), Color(0xFFF3B951), Color(0xFFFFD47A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFFF4D1).withOpacity(0.7)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE8B44B).withOpacity(0.40),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
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
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(AppColors.textDark),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Gold divider with label ────────────────────────────────────────────────────
class _GoldDivider extends StatelessWidget {
  const _GoldDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.borderGoldSubtle, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.borderGoldSubtle, thickness: 1),
        ),
      ],
    );
  }
}

// ── Outline secondary button ───────────────────────────────────────────────────
class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.borderGold, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.champagne,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
