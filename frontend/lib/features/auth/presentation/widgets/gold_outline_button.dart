import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class GoldOutlineButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;
  final bool showArrow;
  final double height;
  final double borderRadius;
  final Color? borderColor;
  final Color? textColor;

  const GoldOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.leadingIcon,
    this.showArrow = true,
    this.height = 54,
    this.borderRadius = 28,
    this.borderColor,
    this.textColor,
  });

  @override
  State<GoldOutlineButton> createState() => _GoldOutlineButtonState();
}

class _GoldOutlineButtonState extends State<GoldOutlineButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = widget.borderColor ?? const Color(0xFFF2EDD8);
    final effectiveText = widget.textColor ?? AppColors.textPrimary;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: _isPressed ? AppColors.goldBright : effectiveBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            onHighlightChanged: (val) {
              if (mounted) setState(() => _isPressed = val);
            },
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (widget.leadingIcon != null) ...[
                    IconTheme(
                      data: const IconThemeData(
                        color: AppColors.goldPrimary,
                        size: 20,
                      ),
                      child: widget.leadingIcon!,
                    ),
                    const SizedBox(width: 14),
                  ] else ...[
                    const SizedBox(width: 10),
                  ],

                  Expanded(
                    child: Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: effectiveText,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  if (widget.showArrow)
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.textSecondary,
                      size: 19,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
