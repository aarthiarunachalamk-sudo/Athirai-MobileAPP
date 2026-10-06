import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:athirai_mobile/features/vault_cms/core/theme/vault_tokens.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_buttons.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_glass_card.dart';
import 'package:athirai_mobile/features/vault_cms/core/widgets/luxury_inputs.dart';


class VaultLoginScreen extends StatefulWidget {
  const VaultLoginScreen({
    super.key,
    required this.onLoginSuccess,
    this.onDismiss,
  });

  final VoidCallback onLoginSuccess;
  final VoidCallback? onDismiss;

  @override
  State<VaultLoginScreen> createState() => _VaultLoginScreenState();
}

class _VaultLoginScreenState extends State<VaultLoginScreen> {
  bool _isSignUp = false;
  bool _isLoading = false;
  final _emailController = TextEditingController(text: 'admin@athirai.com');
  final _passwordController = TextEditingController(text: 'secret123');
  final _nameController = TextEditingController(text: 'Ananya Sharma');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  String? _errorMessage;

  void _fillDemo(bool isAdmin) {
    setState(() {
      if (isAdmin) {
        _emailController.text = 'admin@athirai.com';
        _passwordController.text = 'secret123';
      } else {
        _emailController.text = 'patron@athirai.com';
        _passwordController.text = 'secret123';
      }
      _errorMessage = null;
    });
  }

  Future<void> _handleSubmit() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulated authentic authentication with brief luxury delay
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() => _isLoading = false);
      widget.onLoginSuccess();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultTokens.surfaceBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Temple Atmosphere Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/athirai_temple_login_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: VaultTokens.emeraldCanvasGradient,
                ),
              ),
            ),
          ),

          // Deep Dark Green Vignette & Aura Overlays
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    VaultTokens.surfaceBlack.withOpacity(0.85),
                    const Color(0xFF071B16).withOpacity(0.70),
                    VaultTokens.surfaceBlack.withOpacity(0.92),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Main Login Dialog Box
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: LuxuryGlassCard(
                  padding: const EdgeInsets.all(36),
                  borderRadius: 24,
                  borderWidth: 1.2,
                  borderColor: VaultTokens.borderGoldBright.withOpacity(0.6),
                  blurSigma: 24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Emerald & Gold Crest
                      Image.asset(
                        'assets/images/athirai_emerald_crest.png',
                        height: 76,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.diamond_outlined,
                          size: 60,
                          color: VaultTokens.antiqueGold,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Brand Titles
                      Text(
                        'ATHIRAI',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4.0,
                          color: VaultTokens.warmIvory,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TIMELESS JEWELS  •  ESTD 1924',
                        style: VaultTokens.brandLabel(
                          fontSize: 10,
                          letterSpacing: 3.2,
                          color: VaultTokens.champagneGold,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Mode Switcher (Sign In vs Register)
                      Container(
                        height: 42,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0x66061814),
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(color: VaultTokens.borderGoldMuted, width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isSignUp = false),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: !_isSignUp ? VaultTokens.goldGradient : null,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'ENTER VAULT',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: !_isSignUp ? const Color(0xFF161108) : VaultTokens.sageMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isSignUp = true),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: _isSignUp ? VaultTokens.goldGradient : null,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'REQUEST ACCESS',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: _isSignUp ? const Color(0xFF161108) : VaultTokens.sageMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sign Up Fields
                      if (_isSignUp) ...[
                        LuxuryTextField(
                          label: 'FULL NAME',
                          controller: _nameController,
                          hintText: 'e.g. Princess Ananya Sharma',
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        LuxuryTextField(
                          label: 'PHONE NUMBER',
                          controller: _phoneController,
                          hintText: '+91 98765 43210',
                          prefixIcon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email Field
                      LuxuryTextField(
                        label: 'EMAIL ADDRESS',
                        controller: _emailController,
                        hintText: 'patron@athirai.com',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      LuxuryTextField(
                        label: 'PASSWORD',
                        controller: _passwordController,
                        hintText: '••••••••••••',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: VaultTokens.statusDanger,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Submit Primary Button
                      LuxuryGoldPillButton(
                        label: _isSignUp ? 'CREATE VAULT PROFILE' : 'ENTER THE VAULT',
                        icon: Icons.arrow_forward,
                        isLoading: _isLoading,
                        width: double.infinity,
                        height: 50,
                        onPressed: _handleSubmit,
                      ),

                      const SizedBox(height: 20),

                      // Quick 1-Click Demo Fillers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => _fillDemo(true),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                'Quick Fill: Master Admin',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: VaultTokens.champagneGold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const Text('  •  ', style: TextStyle(color: VaultTokens.borderGoldMuted)),
                          InkWell(
                            onTap: () => _fillDemo(false),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                'Quick Fill: VIP Patron',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: VaultTokens.champagneGold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
