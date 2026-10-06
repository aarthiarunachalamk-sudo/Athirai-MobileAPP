import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../widgets/athirai_logo.dart';
import '../widgets/cosmic_background.dart';
import '../../../shop/presentation/screens/athirai_flow_container.dart';
import 'athirai_otp_verification_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dateController = TextEditingController();
  final _doorController = TextEditingController();
  final _streetController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _townController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _step = 0;
  String? _gender;
  DateTime? _dateOfBirth;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _dateController.dispose();
    _doorController.dispose();
    _streetController.dispose();
    _pincodeController.dispose();
    _townController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;

  String? _validateCurrentStep() {
    if (!_formKey.currentState!.validate()) {
      return 'Please check the required details.';
    }
    if (_step == 0) {
      if (_firstNameController.text.trim().length < 2) {
        return 'First name must be at least 2 characters.';
      }
      if (_gender == null) {
        return 'Please select your gender.';
      }
      if (_dateOfBirth == null) {
        return 'Please select your date of birth.';
      }
    }
    if (_step == 1) {
      if (_pincodeController.text.trim().length != 6) {
        return 'Pincode must be exactly 6 digits.';
      }
    }
    if (_step == 2) {
      final email = _emailController.text.trim();
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(email)) {
        return 'Please enter a valid email address.';
      }
      if (_passwordController.text.length < 6) {
        return 'Password must be at least 6 characters.';
      }
      if (_confirmPasswordController.text != _passwordController.text) {
        return 'Passwords do not match.';
      }
    }
    return null;
  }

  void _handleBack() {
    if (_step > 0) {
      setState(() {
        _step--;
        _error = null;
      });
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _continue() {
    final validationError = _validateCurrentStep();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }
    setState(() {
      _error = null;
      _step++;
    });
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.goldPrimary,
            onPrimary: AppColors.backgroundBlack,
            surface: AppColors.surfaceBlack,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dateOfBirth = picked;
      _dateController.text =
          '${picked.day.toString().padLeft(2, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      _error = null;
    });
  }

  Future<void> _register() async {
    final validationError = _validateCurrentStep();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final response = await ref
        .read(authRepositoryProvider)
        .register(
          email: email,
          password: password,
          confirmPassword: _confirmPasswordController.text,
          firstName: firstName,
          lastName: lastName,
          fullName: '$firstName $lastName',
          mobileNumber: _mobileController.text.trim(),
          gender: _gender!,
          dateOfBirth:
              '${_dateOfBirth!.year.toString().padLeft(4, '0')}-'
              '${_dateOfBirth!.month.toString().padLeft(2, '0')}-'
              '${_dateOfBirth!.day.toString().padLeft(2, '0')}',
          doorNo: _doorController.text.trim(),
          streetName: _streetController.text.trim(),
          pincode: _pincodeController.text.trim(),
          town: _townController.text.trim(),
          city: _cityController.text.trim(),
          district: _districtController.text.trim(),
          state: _stateController.text.trim(),
        );

    if (!mounted) return;
    if (!response.isSuccess) {
      setState(() {
        _isLoading = false;
        _error =
            response.errorMessage ?? 'Registration failed. Please try again.';
      });
      return;
    }

    final signedIn = await ref
        .read(authControllerProvider.notifier)
        .loginWithIdentifier(email, password: password);
    if (!mounted) return;
    if (!signedIn) {
      setState(() {
        _isLoading = false;
        _error =
            ref.read(authControllerProvider).errorMessage ??
            'Your account was created. Please sign in to continue.';
      });
      return;
    }

    final phone = _mobileController.text.trim();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => AthiraiOtpVerificationScreen(
          phoneNumber: phone.isNotEmpty ? '+91 $phone' : '+91 98765 43210',
          onVerified: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const AthiraiFlowContainer(initialScreenIndex: 1),
              ),
              (route) => false,
            );
          },
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _step > 0) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundBlack,
        body: CosmicBackground(
          imageAsset: AppAssets.signInReferenceBg,
          overlayOpacity: 0.06,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: _step > 0 ? 'Previous step' : 'Back to Login',
                          onPressed: _handleBack,
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.goldBright,
                            size: 18,
                          ),
                        ),
                      ),
                    const SizedBox(height: 2),
                    Center(
                      child: AthiraiLogo(
                        width: (constraints.maxWidth * 0.42).clamp(
                          145.0,
                          190.0,
                        ),
                        imageAsset: AppAssets.referenceLogo,
                        showGlow: false,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ATHIRAI USER ONBOARDING',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.goldPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Register User',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        color: AppColors.textPrimary,
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your profile to unlock verified jewellery, rate tracking, and priority service.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.champagne.withOpacity(0.82),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '100% BIS HALLMARKED   ·   RATE TRACKING   ·   OTP SECURITY',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.goldBright,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 26),
                    _buildStepIndicator(),
                    const SizedBox(height: 22),
                    Form(key: _formKey, child: _buildCurrentStep()),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildNavigationButton(),
                    const SizedBox(height: 18),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Already have an Athirai account? ',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.goldBright,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Sign in here',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppColors.borderGoldSubtle),
                    const SizedBox(height: 12),
                    Text(
                      'FREE INSURED SHIPPING   ·   EASY RETURNS   ·   SECURE PAYMENTS',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
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

  Widget _buildStepIndicator() {
    const titles = ['PERSONAL DETAILS', 'DELIVERY ADDRESS', 'ACCOUNT SECURITY'];
    return Row(
      children: List.generate(titles.length, (index) {
        final active = index == _step;
        final complete = index < _step;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == titles.length - 1 ? 0 : 8),
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active || complete
                        ? AppColors.goldPrimary
                        : AppColors.surfaceBlack,
                    border: Border.all(
                      color: active || complete
                          ? AppColors.goldBright
                          : AppColors.borderGoldSubtle,
                    ),
                  ),
                  child: Center(
                    child: complete
                        ? const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Colors.black,
                          )
                        : Text(
                            '${index + 1}',
                            style: GoogleFonts.inter(
                              color: active
                                  ? Colors.black
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  titles[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: active ? AppColors.goldBright : AppColors.textMuted,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _section(
          title: 'Personal Details',
          subtitle: 'Tell us a little about yourself.',
          children: [
            _field(_firstNameController, 'First name', 'Enter your first name'),
            const SizedBox(height: 14),
            _field(_lastNameController, 'Last name', 'Enter your last name'),
            const SizedBox(height: 14),
            _field(
              _mobileController,
              'Phone number',
              '+91 98765 43210',
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+() -]')),
              ],
              validator: (value) {
                final requiredError = _required(value);
                if (requiredError != null) return requiredError;
                return value!.replaceAll(RegExp(r'\D'), '').length >= 10
                    ? null
                    : 'Enter a valid phone number.';
              },
            ),
            const SizedBox(height: 14),
            _dateOfBirthField(),
            const SizedBox(height: 14),
            _genderField(),
          ],
        );
      case 1:
        return _section(
          title: 'Delivery & Billing Address',
          subtitle: 'Where should we send your order?',
          children: [
            _field(_doorController, 'Door no', 'House or flat number'),
            const SizedBox(height: 14),
            _field(
              _streetController,
              'Street name',
              'Street, area or locality',
            ),
            const SizedBox(height: 14),
            _field(
              _pincodeController,
              'Pincode (6-digit)',
              'Enter your pincode',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                final requiredError = _required(value);
                if (requiredError != null) return requiredError;
                return value!.length == 6 ? null : 'Enter a 6-digit pincode.';
              },
            ),
            const SizedBox(height: 14),
            _field(_townController, 'Town', 'Enter your town'),
            const SizedBox(height: 14),
            _field(_cityController, 'City', 'Enter your city'),
            const SizedBox(height: 14),
            _field(_districtController, 'District', 'Enter your district'),
            const SizedBox(height: 14),
            _field(_stateController, 'State', 'Enter your state'),
          ],
        );
      default:
        return _section(
          title: 'Account Security & Verification',
          subtitle: 'Secure your Athirai account.',
          children: [
            _field(
              _emailController,
              'Email address',
              'name@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final requiredError = _required(value);
                if (requiredError != null) return requiredError;
                return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!)
                    ? null
                    : 'Enter a valid email address.';
              },
            ),
            const SizedBox(height: 14),
            _field(
              _passwordController,
              'Create password',
              'At least 6 characters',
              obscureText: _obscurePassword,
              suffix: _visibilityButton(
                _obscurePassword,
                () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) {
                final requiredError = _required(value);
                if (requiredError != null) return requiredError;
                return value!.length >= 6
                    ? null
                    : 'Password must be at least 6 characters.';
              },
            ),
            const SizedBox(height: 14),
            _field(
              _confirmPasswordController,
              'Confirm password',
              'Re-enter your password',
              obscureText: _obscureConfirmation,
              suffix: _visibilityButton(
                _obscureConfirmation,
                () => setState(
                  () => _obscureConfirmation = !_obscureConfirmation,
                ),
              ),
              validator: (value) => value == _passwordController.text
                  ? null
                  : 'Passwords do not match.',
            ),
          ],
        );
    }
  }

  Widget _section({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xE90A0805),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.borderGoldSubtle),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: GoogleFonts.cormorantGaramond(
            color: AppColors.goldBright,
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          color: AppColors.champagne,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      const SizedBox(height: 7),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        validator: validator ?? _required,
        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
        cursorColor: AppColors.goldBright,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
          filled: true,
          fillColor: const Color(0xFF14110D),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          suffixIcon: suffix,
          errorMaxLines: 2,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.borderGoldSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.goldBright),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),
      ),
    ],
  );

  Widget _dateOfBirthField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'DATE OF BIRTH (DOB)',
        style: GoogleFonts.inter(
          color: AppColors.champagne,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      const SizedBox(height: 7),
      TextFormField(
        controller: _dateController,
        readOnly: true,
        onTap: _selectDateOfBirth,
        validator: (_) =>
            _dateOfBirth == null ? 'Select your date of birth.' : null,
        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'DD-MM-YYYY',
          hintStyle: GoogleFonts.inter(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
          filled: true,
          fillColor: const Color(0xFF14110D),
          suffixIcon: const Icon(
            Icons.calendar_month_outlined,
            color: AppColors.goldPrimary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.borderGoldSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.goldBright),
          ),
        ),
      ),
    ],
  );

  Widget _genderField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'GENDER',
        style: GoogleFonts.inter(
          color: AppColors.champagne,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      const SizedBox(height: 7),
      DropdownButtonFormField<String>(
        value: _gender,
        dropdownColor: AppColors.surfaceBlack,
        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Select gender',
          hintStyle: GoogleFonts.inter(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
          filled: true,
          fillColor: const Color(0xFF14110D),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.borderGoldSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.goldBright),
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'Female', child: Text('Female')),
          DropdownMenuItem(value: 'Male', child: Text('Male')),
          DropdownMenuItem(value: 'Other', child: Text('Other')),
          DropdownMenuItem(
            value: 'Prefer not to say',
            child: Text('Prefer not to say'),
          ),
        ],
        onChanged: (value) => setState(() {
          _gender = value;
          _error = null;
        }),
      ),
    ],
  );

  Widget _visibilityButton(bool obscure, VoidCallback onPressed) => IconButton(
    tooltip: obscure ? 'Show password' : 'Hide password',
    onPressed: onPressed,
    icon: Icon(
      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      color: AppColors.textSecondary,
      size: 19,
    ),
  );

  Widget _buildNavigationButton() => Row(
    children: [
      if (_step > 0) ...[
        IconButton(
          tooltip: 'Previous step',
          onPressed: _isLoading
              ? null
              : () => setState(() {
                  _step--;
                  _error = null;
                }),
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.goldBright,
          style: IconButton.styleFrom(
            side: const BorderSide(color: AppColors.borderGold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
      Expanded(
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : (_step == 2 ? _register : _continue),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.textDark,
              disabledBackgroundColor: AppColors.goldDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textDark,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _step == 2 ? 'REGISTER' : 'CONTINUE',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _step == 2
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ],
  );
}
