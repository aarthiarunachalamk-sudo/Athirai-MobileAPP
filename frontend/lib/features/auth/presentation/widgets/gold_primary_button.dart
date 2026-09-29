import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class GoldPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool showArrow;
  final double? width;
  final double height;
  final double borderRadius;

  const GoldPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.showArrow = true,
    this.width,
    this.height = 58,
    this.borderRadius = 30,
  });

  @override
  State<GoldPrimaryButton> createState() => _GoldPrimaryButtonState();
}

class _GoldPrimaryButtonState extends State<GoldPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedScale(
      scale: _isPressed && isEnabled ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: isEnabled
              ? const LinearGradient(
                  colors: [
                    Color(0xFFFFE9A3),
                    Color(0xFFF3B951),
                    Color(0xFFFFD47A),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : LinearGradient(
                  colors: [
                    const Color(0xFFFFD978).withOpacity(0.4),
                    const Color(0xFFE8B44B).withOpacity(0.4),
                  ],
                ),
          border: Border.all(
            color: const Color(0xFFFFF4D1).withOpacity(0.7),
            width: 1.0,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xFFE8B44B).withOpacity(0.35),
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            onHighlightChanged: (val) {
              if (mounted) setState(() => _isPressed = val);
            },
            onTap: isEnabled ? widget.onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: widget.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textDark,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 20), // Balance arrow
                        Expanded(
                          child: Text(
                            widget.text,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (widget.showArrow)
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.textDark,
                            size: 20,
                          )
                        else
                          const SizedBox(width: 20),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
