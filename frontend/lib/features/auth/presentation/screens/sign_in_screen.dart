import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../controllers/auth_controller.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/secure_storage_service.dart';
import '../../../shop/presentation/screens/athirai_flow_container.dart';
import '../../../shop/domain/shop_store.dart';
import 'complete_profile_screen.dart';

import 'register_screen.dart';
import 'sso_email_screen.dart';

/// Screen-accurate luxury login screen matching Screen 2 of the Athirai reference:
/// - Dark emerald temple courtyard architecture background with warm diya glow
/// - Top bar with right-aligned "Skip" action
/// - Athirai emerald drop jewel crest + "ATHIRAI / TIMELESS JEWELS"
/// - "Welcome Back" serif headline & luxury journey subtitle
/// - Translucent dark emerald pill capsule fields for Email/Mobile & Password
/// - "Remember me" checkbox & "Forgot Password?" link
/// - Golden gradient pill button "Log In →"
/// - "OR" divider & "Login with SSO" capsule button
/// - "Don't have an account? Register" footer
/// - Golden geometric lotus ornament at bottom
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
  String? _idError;
  String? _pwError;

  @override
  void initState() {
    super.initState();
    _loadRemembered();
    _identifierCtrl.addListener(_onIdentifierChanged);
  }

  void _onIdentifierChanged() {
    if (_rememberMe) {
      final id = _identifierCtrl.text.trim();
      if (id.isNotEmpty) {
        SecureStorageService().saveRememberedIdentifier(id);
      }
    }
  }

  Future<void> _loadRemembered() async {
    final saved = await SecureStorageService().getRememberedIdentifier();
    if (!mounted) return;
    if (saved != null && saved.isNotEmpty) {
      _identifierCtrl.text = saved;
      setState(() => _rememberMe = true);
    }
  }

  @override
  void dispose() {
    _identifierCtrl.removeListener(_onIdentifierChanged);
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    _idFocus.dispose();
    _pwFocus.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final id = _identifierCtrl.text.trim();
    final password = _passwordCtrl.text;
    String? idErr;
    String? pwErr;

    if (id.isEmpty) {
      idErr = 'Please enter your email, phone or ID.';
    } else if (id.contains('@')) {
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(id)) {
        idErr = 'Please enter a valid email address.';
      }
    } else if (RegExp(r'^[0-9+() -]+$').hasMatch(id)) {
      final digits = id.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 10) {
        idErr = 'Please enter a valid 10-digit phone number.';
      }
    } else if (id.length < 3) {
      idErr = 'Identifier must be at least 3 characters.';
    }

    if (password.isEmpty) {
      pwErr = 'Please enter your password.';
    } else if (password.length < 6) {
      pwErr = 'Password must be at least 6 characters.';
    }

    setState(() {
      _idError = idErr;
      _pwError = pwErr;
      _error = idErr ?? pwErr;
    });

    return idErr == null && pwErr == null;
  }

  void _clearErrors() {
    if (_error != null || _idError != null || _pwError != null) {
      setState(() {
        _error = null;
        _idError = null;
        _pwError = null;
      });
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const AthiraiFlowContainer(initialScreenIndex: 1),
      ),
      (route) => false,
    );
  }

  void _navigateToProfileDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const AthiraiFlowContainer(initialScreenIndex: 9),
      ),
      (route) => false,
    );
  }

  Future<void> _submit() async {
    if (!_validateInputs()) return;

    final id = _identifierCtrl.text.trim();
    final password = _passwordCtrl.text;

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
      // Customer login paninadhum avangalukku one credit reward earn aagum.
      final earnedReward = await ShopStore.session.claimDailyLoginReward();
      if (!mounted) return;

      final s = ref.read(authControllerProvider);
      if (s.requiresProfileCompletion) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
        );
      } else {
        if (earnedReward && mounted) {
          _showDailyRewardClaimedDialog(context);
        } else {
          _navigateToProfileDashboard();
        }
      }
    } else {
      final err = ref.read(authControllerProvider).errorMessage;
      setState(
        () => _error = err ?? 'Unable to sign in. Please verify your details.',
      );
    }
  }

  void _showDailyRewardClaimedDialog(BuildContext context) {
    final store = ShopStore.session;
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
              // Shimmering Golden Coin Icon with Radiance
              Container(
                width: 76,
                height: 76,
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
                      color: const Color(0xFFFFDF7A).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '🪙',
                    style: TextStyle(fontSize: 38),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                'Royal Login Reward!',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF7F2E8),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Credit Reward Badge
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
                      '+1 AUG Coin Earned (1 Credit)',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFDF7A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'Welcome to Athirai! As your daily patron privilege, 1 credit reward has been deposited into your vault.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.45,
                  color: const Color(0xFFD1DFDE),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // Balance Vault Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0x66020907),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x44C7A45B), width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR VAULT BALANCE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: const Color(0xFF9FAFA9),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${store.augCoins.toStringAsFixed(1)} AUG Coins',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFE5C882),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0x3316A34A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Worth ₹${(store.augCoins * store.augCoinValueInRupees).round()}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4ADE80),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                '🪙 Redeem your AUG Coins to buy 24K gold coins and jewellery.',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFC7A45B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Action: Claim & Enter Vault
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    _navigateToProfileDashboard();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 6,
                    shadowColor: const Color(0x66D4AF37),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE5C882),
                          Color(0xFFC7A45B),
                          Color(0xFF9E7B36),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        'Buy Gold with Coins  →',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF041A13),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPassword() {

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) => _ForgotPasswordSheet(
        initialIdentifier: _identifierCtrl.text.trim(),
        onPasswordResetSuccess: (identifier) {
          setState(() {
            _identifierCtrl.text = identifier;
            _passwordCtrl.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF041A13),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFC5A059), width: 1),
              ),
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Password updated successfully! Please log in.',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFF7F2E8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: const Color(0xFF030D0A),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // ── Background: Temple courtyard with ambient diya glow & enhanced light ──
            Positioned.fill(
              child: Image.asset(
                AppAssets.templeLoginBg,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            // ── Atmospheric Dark Emerald Gradient Vignette with Enhanced Temple Light ──
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x8C030E0B),
                      Color(0xB3020907),
                      Color(0xEE010605),
                    ],
                    stops: [0.0, 0.48, 1.0],
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
                  painter: _BottomFoliagePainter(),
                ),
              ),
            ),

            // ── Main Content Scroll ──────────────────────────────────────
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
                          // ── Top Navigation Row: Back (if canPop) + Skip ───
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (Navigator.of(context).canPop())
                                  IconButton(
                                    tooltip: 'Back',
                                    onPressed: () => Navigator.of(context).maybePop(),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Color(0xFFC5A059),
                                      size: 18,
                                    ),
                                  )
                                else
                                  const SizedBox(width: 24),

                                TextButton(
                                  onPressed: _navigateToDashboard,
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFD4AF37),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Skip',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFFD4AF37),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),

                          // ── Brand Crest: Emerald Drop Jewel Emblem ─────────
                          Image.asset(
                            AppAssets.emeraldCrest,
                            height: 64,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),

                          const SizedBox(height: 12),

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

                          const SizedBox(height: 28),

                          // ── Welcome Heading ────────────────────────────────
                          Text(
                            'Welcome Back',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 29,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFF7F2E8),
                              letterSpacing: 0.4,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Log in to continue your journey\ninto the world of timeless jewels.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: const Color(0xFF8E9E94),
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // ── Field 1: Email / Mobile Number ─────────────────
                          _CapsuleAuthField(
                            controller: _identifierCtrl,
                            focusNode: _idFocus,
                            hint: 'Email / Mobile Number',
                            prefixIcon: Icons.person_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _pwFocus.requestFocus(),
                            onChanged: (_) => _clearErrors(),
                            errorText: _idError,
                          ),

                          const SizedBox(height: 14),

                          // ── Field 2: Password ──────────────────────────────
                          _CapsuleAuthField(
                            controller: _passwordCtrl,
                            focusNode: _pwFocus,
                            hint: 'Password',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
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

                          // ── Remember me & Forgot Password Row ──────────────
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: const Color(0xFFC5A059),
                                  checkColor: const Color(0xFF04120F),
                                  side: const BorderSide(
                                    color: Color(0xFF6B7E74),
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (v) async {
                                    final val = v ?? false;
                                    setState(() => _rememberMe = val);
                                    if (!val) {
                                      await SecureStorageService().clearRememberedIdentifier();
                                    } else if (_identifierCtrl.text.trim().isNotEmpty) {
                                      await SecureStorageService().saveRememberedIdentifier(
                                        _identifierCtrl.text.trim(),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  final val = !_rememberMe;
                                  setState(() => _rememberMe = val);
                                  if (!val) {
                                    await SecureStorageService().clearRememberedIdentifier();
                                  } else if (_identifierCtrl.text.trim().isNotEmpty) {
                                    await SecureStorageService().saveRememberedIdentifier(
                                      _identifierCtrl.text.trim(),
                                    );
                                  }
                                },
                                child: Text(
                                  'Remember me',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF8E9E94),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: _showForgotPassword,
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFD4AF37),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // ── Top-level Auth Error Banner (if any) ────────────
                          if (_error != null &&
                              _error != _idError &&
                              _error != _pwError) ...[
                            const SizedBox(height: 14),
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

                          const SizedBox(height: 22),

                          // ── Primary Action: Log In → ────────────────────────
                          _GoldGradientButton(
                            isLoading: auth.isLoading,
                            onPressed: _submit,
                          ),

                          const SizedBox(height: 22),

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

                          const SizedBox(height: 20),

                          // ── Secondary Action: Login with SSO ────────────────
                          _SsoCapsuleButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SSOEmailScreen(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // ── Footer: Don't have an account? Register ─────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: const Color(0xFF8E9E94),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                ),
                                child: Text(
                                  'Register',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFD4AF37),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── Bottom Sacred Lotus Ornament ────────────────────
                          const CustomPaint(
                            size: Size(54, 32),
                            painter: _LotusPainter(color: Color(0xFFC5A059)),
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
      ),
    );
  }
}

// ── Capsule Input Field Matching Screen 2 ─────────────────────────────────────
class _CapsuleAuthField extends StatefulWidget {
  const _CapsuleAuthField({
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
  State<_CapsuleAuthField> createState() => _CapsuleAuthFieldState();
}

class _CapsuleAuthFieldState extends State<_CapsuleAuthField> {
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

// ── Golden Gradient "Log In →" Pill Button ────────────────────────────────────
class _GoldGradientButton extends StatefulWidget {
  const _GoldGradientButton({
    required this.onPressed,
    this.label = 'Log In',
    this.icon = Icons.arrow_forward_rounded,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  State<_GoldGradientButton> createState() => _GoldGradientButtonState();
}

class _GoldGradientButtonState extends State<_GoldGradientButton> {
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
                        widget.label,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: const Color(0xFF161108),
                        ),
                      ),
                      if (widget.icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          widget.icon,
                          size: 16,
                          color: const Color(0xFF161108),
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

// ── Secondary Capsule "Login with SSO" Button ─────────────────────────────────
class _SsoCapsuleButton extends StatelessWidget {
  const _SsoCapsuleButton({required this.onPressed});

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
              Icons.badge_outlined,
              size: 17,
              color: Color(0xFFC5A059),
            ),
            const SizedBox(width: 8),
            Text(
              'Login with SSO',
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
class _LotusPainter extends CustomPainter {
  const _LotusPainter({this.color = const Color(0xFFC5A059)});

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
class _BottomFoliagePainter extends CustomPainter {
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

// ── Interactive Luxury Forgot Password Bottom Sheet ───────────────────────────
class _ForgotPasswordSheet extends StatefulWidget {
  const _ForgotPasswordSheet({
    required this.initialIdentifier,
    required this.onPasswordResetSuccess,
  });

  final String initialIdentifier;
  final ValueChanged<String> onPasswordResetSuccess;

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  int _step = 1; // 1: Request code, 2: Reset password, 3: Success
  late final TextEditingController _identifierCtrl;
  final _tokenCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _idFocus = FocusNode();
  final _tokenFocus = FocusNode();
  final _newPwFocus = FocusNode();
  final _confirmPwFocus = FocusNode();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _demoTokenHint;

  @override
  void initState() {
    super.initState();
    _identifierCtrl = TextEditingController(text: widget.initialIdentifier);
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _tokenCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _idFocus.dispose();
    _tokenFocus.dispose();
    _newPwFocus.dispose();
    _confirmPwFocus.dispose();
    super.dispose();
  }

  Future<void> _handleRequestCode() async {
    final identifier = _identifierCtrl.text.trim();
    if (identifier.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email or mobile number.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await AuthRepository().requestPasswordReset(identifier);
      if (!mounted) return;

      if (res.isSuccess) {
        final token = res.data != null ? res.data!['reset_token']?.toString() : null;
        setState(() {
          _step = 2;
          _isLoading = false;
          _demoTokenHint = token;
          if (token != null && token.isNotEmpty) {
            _tokenCtrl.text = token;
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = res.errorMessage ?? 'Unable to send recovery code. Please check your details.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not connect to the reset service. Please try again.';
      });
    }
  }

  Future<void> _handleConfirmReset() async {
    final identifier = _identifierCtrl.text.trim();
    final token = _tokenCtrl.text.trim();
    final newPass = _newPasswordCtrl.text;
    final confirmPass = _confirmPasswordCtrl.text;

    if (token.isEmpty) {
      setState(() => _errorMessage = 'Please enter the verification code.');
      return;
    }
    if (newPass.isEmpty) {
      setState(() => _errorMessage = 'Please enter your new password.');
      return;
    }
    if (newPass.length < 6) {
      setState(() => _errorMessage = 'New password must be at least 6 characters.');
      return;
    }
    if (newPass != confirmPass) {
      setState(() => _errorMessage = 'New passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await AuthRepository().confirmPasswordReset(
        identifier: identifier,
        otp: token,
        newPassword: newPass,
      );

      if (!mounted) return;

      if (res.isSuccess) {
        setState(() {
          _step = 3;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = res.errorMessage ?? 'Invalid verification code or unable to reset password.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not connect to the reset service. Please try again.';
      });
    }
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(color: AppColors.error, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0x26C5A059),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x4DC5A059)),
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Forgot Password',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF7F2E8),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF8E9E94), size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Enter your registered email address or mobile number. We will send a secure password recovery code to verify your account.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF8E9E94),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        _CapsuleAuthField(
          controller: _identifierCtrl,
          focusNode: _idFocus,
          hint: 'Email / Mobile Number',
          prefixIcon: Icons.person_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleRequestCode(),
          onChanged: (_) {
            if (_errorMessage != null) setState(() => _errorMessage = null);
          },
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          _buildErrorBanner(_errorMessage!),
        ],
        const SizedBox(height: 22),
        _GoldGradientButton(
          label: 'Send Recovery Code',
          isLoading: _isLoading,
          onPressed: _handleRequestCode,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0x26C5A059),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x4DC5A059)),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Set New Password',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF7F2E8),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF8E9E94), size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Recovery code sent for ${_identifierCtrl.text.trim()}',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: const Color(0xFF8E9E94),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _step = 1),
              child: Text(
                'Change',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ),
          ],
        ),
        if (_demoTokenHint != null && _demoTokenHint!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0x1AD4AF37),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x4DD4AF37)),
            ),
            child: Row(
              children: [
                const Icon(Icons.vpn_key_outlined, size: 16, color: Color(0xFFD4AF37)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Verification code: $_demoTokenHint',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFE5C170),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        _CapsuleAuthField(
          controller: _tokenCtrl,
          focusNode: _tokenFocus,
          hint: 'Verification Code',
          prefixIcon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _newPwFocus.requestFocus(),
          onChanged: (_) {
            if (_errorMessage != null) setState(() => _errorMessage = null);
          },
        ),
        const SizedBox(height: 12),
        _CapsuleAuthField(
          controller: _newPasswordCtrl,
          focusNode: _newPwFocus,
          hint: 'New Password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureNew,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _confirmPwFocus.requestFocus(),
          onChanged: (_) {
            if (_errorMessage != null) setState(() => _errorMessage = null);
          },
          suffixIcon: IconButton(
            icon: Icon(
              _obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 19,
              color: const Color(0xFF8E9E94),
            ),
            onPressed: () => setState(() => _obscureNew = !_obscureNew),
          ),
        ),
        const SizedBox(height: 12),
        _CapsuleAuthField(
          controller: _confirmPasswordCtrl,
          focusNode: _confirmPwFocus,
          hint: 'Confirm New Password',
          prefixIcon: Icons.lock_reset_rounded,
          obscureText: _obscureConfirm,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleConfirmReset(),
          onChanged: (_) {
            if (_errorMessage != null) setState(() => _errorMessage = null);
          },
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 19,
              color: const Color(0xFF8E9E94),
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          _buildErrorBanner(_errorMessage!),
        ],
        const SizedBox(height: 20),
        _GoldGradientButton(
          label: 'Reset Password',
          isLoading: _isLoading,
          onPressed: _handleConfirmReset,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x26C5A059),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFFD4AF37),
              size: 48,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Password Reset Complete',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF7F2E8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your password has been updated successfully.\nYou can now sign in with your new credentials.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF8E9E94),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _GoldGradientButton(
            label: 'Back to Sign In',
            icon: Icons.check_rounded,
            onPressed: () {
              Navigator.of(context).pop();
              widget.onPasswordResetSuccess(_identifierCtrl.text.trim());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF04120E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0x66C5A059), width: 1.2),
          left: BorderSide(color: Color(0x33C5A059), width: 0.8),
          right: BorderSide(color: Color(0x33C5A059), width: 0.8),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Pull Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0x4DC5A059),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              if (_step == 1) _buildStep1(),
              if (_step == 2) _buildStep2(),
              if (_step == 3) _buildStep3(),
            ],
          ),
        ),
      ),
    );
  }
}

