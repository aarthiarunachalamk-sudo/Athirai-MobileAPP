import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class GoldTextField extends StatefulWidget {
  final String? label;
  final String hintText;
  final TextEditingController controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool readOnly;
  final FocusNode? focusNode;

  const GoldTextField({
    super.key,
    this.label,
    required this.hintText,
    required this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.onChanged,
    this.errorText,
    this.readOnly = false,
    this.focusNode,
  });

  @override
  State<GoldTextField> createState() => _GoldTextFieldState();
}

class _GoldTextFieldState extends State<GoldTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Input Container with Luxury Glowing Gold Border
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF14110D).withOpacity(0.85),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : (_isFocused ? AppColors.goldBright : AppColors.borderGold.withOpacity(0.85)),
              width: _isFocused ? 1.4 : 1.1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: hasError
                          ? AppColors.error.withOpacity(0.25)
                          : AppColors.goldBright.withOpacity(0.20),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: IconTheme(
                    data: IconThemeData(
                      color: hasError
                          ? AppColors.error
                          : (_isFocused ? AppColors.goldBright : AppColors.goldPrimary),
                      size: 21,
                    ),
                    child: widget.prefixIcon!,
                  ),
                ),
              ] else ...[
                const SizedBox(width: 16),
              ],

              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  readOnly: widget.readOnly,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  onChanged: (val) {
                    if (widget.onChanged != null) widget.onChanged!(val);
                    if (hasError && mounted) setState(() {});
                  },
                  cursorColor: AppColors.goldBright,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),

              if (widget.suffixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: widget.suffixIcon!,
                ),
            ],
          ),
        ),

        // Inline error state
        if (hasError) ...[
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
