import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/vault_tokens.dart';

/// Primary Metallic Gold Gradient Pill Button
class LuxuryGoldPillButton extends StatefulWidget {
  const LuxuryGoldPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.fontSize = 13.5,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final double fontSize;

  @override
  State<LuxuryGoldPillButton> createState() => _LuxuryGoldPillButtonState();
}

class _LuxuryGoldPillButtonState extends State<LuxuryGoldPillButton> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isLoading ? SystemMouseCursors.wait : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          if (!widget.isLoading) widget.onPressed();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.98 : (_hovered ? 1.015 : 1.0),
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              gradient: VaultTokens.goldGradient,
              borderRadius: BorderRadius.circular(widget.height / 2),
              border: Border.all(
                color: const Color(0xFFFFF0C2).withOpacity(0.6),
                width: 0.9,
              ),
              boxShadow: [
                BoxShadow(
                  color: VaultTokens.antiqueGold.withOpacity(_hovered ? 0.45 : 0.30),
                  blurRadius: _hovered ? 20 : 14,
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
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF161108)),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.label,
                        style: GoogleFonts.inter(
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: const Color(0xFF161108),
                        ),
                      ),
                      if (widget.icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          widget.icon,
                          size: widget.fontSize + 2,
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

/// Secondary Dark Emerald Capsule Button with Gold Border
class LuxuryCapsuleButton extends StatefulWidget {
  const LuxuryCapsuleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = 46,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isDestructive;

  @override
  State<LuxuryCapsuleButton> createState() => _LuxuryCapsuleButtonState();
}

class _LuxuryCapsuleButtonState extends State<LuxuryCapsuleButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isDestructive
        ? VaultTokens.statusDanger.withOpacity(0.6)
        : (_hovered ? VaultTokens.champagneGold : VaultTokens.borderGoldMedium);

    final textColor = widget.isDestructive
        ? const Color(0xFFE57373)
        : (_hovered ? VaultTokens.champagneGold : VaultTokens.warmIvory);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0x33C7A45B) : const Color(0x38061A14),
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 16, color: textColor),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
