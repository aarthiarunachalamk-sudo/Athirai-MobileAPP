import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/vault_tokens.dart';

/// Reusable dark emerald glass panel with subtle antique gold border and soft inner glow.
class LuxuryGlassCard extends StatefulWidget {
  const LuxuryGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 18,
    this.borderWidth = 1.0,
    this.borderColor,
    this.backgroundColor,
    this.gradient,
    this.blurSigma = 12.0,
    this.enableHoverEffect = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double borderWidth;
  final Color? borderColor;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double blurSigma;
  final bool enableHoverEffect;
  final VoidCallback? onTap;

  @override
  State<LuxuryGlassCard> createState() => _LuxuryGlassCardState();
}

class _LuxuryGlassCardState extends State<LuxuryGlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = widget.borderColor ??
        (_isHovered ? VaultTokens.borderGoldMedium : VaultTokens.borderGoldMuted);

    final cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? VaultTokens.glassFillMedium,
        gradient: widget.gradient ??
            LinearGradient(
              colors: [
                _isHovered ? const Color(0x660D2D24) : const Color(0x550A221B),
                _isHovered ? const Color(0x44081F19) : const Color(0x38061A14),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: widget.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          if (_isHovered)
            BoxShadow(
              color: VaultTokens.antiqueGold.withOpacity(0.12),
              blurRadius: 20,
              spreadRadius: 1,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.blurSigma,
            sigmaY: widget.blurSigma,
          ),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.onTap != null || widget.enableHoverEffect) {
      return MouseRegion(
        cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
