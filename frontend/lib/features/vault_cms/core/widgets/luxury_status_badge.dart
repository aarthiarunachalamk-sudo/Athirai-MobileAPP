import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/vault_tokens.dart';

class LuxuryStatusBadge extends StatelessWidget {
  const LuxuryStatusBadge({
    super.key,
    required this.status,
    this.customColor,
  });

  final String status;
  final Color? customColor;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;
    Color dot;

    final lower = status.toLowerCase();

    if (lower.contains('published') || lower.contains('in stock') || lower.contains('delivered') || lower.contains('completed')) {
      bg = const Color(0x2E2E7D5C);
      border = const Color(0x662E7D5C);
      text = const Color(0xFF66BB6A);
      dot = const Color(0xFF81C784);
    } else if (lower.contains('draft') || lower.contains('crafting') || lower.contains('pending')) {
      bg = const Color(0x33D4A017);
      border = const Color(0x66D4A017);
      text = const Color(0xFFFFD54F);
      dot = const Color(0xFFFFCA28);
    } else if (lower.contains('low stock') || lower.contains('warning') || lower.contains('hallmarking')) {
      bg = const Color(0x33E65100);
      border = const Color(0x66FFA726);
      text = const Color(0xFFFFB74D);
      dot = const Color(0xFFFF9800);
    } else if (lower.contains('out of stock') || lower.contains('cancelled') || lower.contains('archived')) {
      bg = const Color(0x33BA3C3C);
      border = const Color(0x66BA3C3C);
      text = const Color(0xFFE57373);
      dot = const Color(0xFFEF5350);
    } else if (lower.contains('royal') || lower.contains('vip') || lower.contains('diamond') || lower.contains('confirmed')) {
      bg = const Color(0x33C7A45B);
      border = const Color(0x88E4C982);
      text = VaultTokens.champagneGold;
      dot = VaultTokens.champagneGold;
    } else {
      bg = const Color(0x292C7A8A);
      border = const Color(0x662C7A8A);
      text = const Color(0xFF4DD0E1);
      dot = const Color(0xFF26C6DA);
    }

    if (customColor != null) {
      bg = customColor!.withOpacity(0.18);
      border = customColor!.withOpacity(0.5);
      text = customColor!;
      dot = customColor!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: dot.withOpacity(0.6), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: text,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
