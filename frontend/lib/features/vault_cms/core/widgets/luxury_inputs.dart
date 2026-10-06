import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/vault_tokens.dart';

/// Reusable dark emerald glass text field with gold focus border and subtle warm glow.
class LuxuryTextField extends StatefulWidget {
  const LuxuryTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixText,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.inputFormatters,
    this.helperText,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? suffixText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? minLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final String? helperText;

  @override
  State<LuxuryTextField> createState() => _LuxuryTextFieldState();
}

class _LuxuryTextFieldState extends State<LuxuryTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isFocused ? VaultTokens.champagneGold : VaultTokens.sageLight,
                letterSpacing: 0.3,
              ),
            ),
            if (widget.helperText != null)
              Text(
                widget.helperText!,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: VaultTokens.mutedGold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _isFocused ? const Color(0x73071F19) : const Color(0x4D051612),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused ? VaultTokens.champagneGold : VaultTokens.borderGoldMuted,
              width: _isFocused ? 1.2 : 1.0,
            ),
            boxShadow: [
              if (_isFocused)
                BoxShadow(
                  color: VaultTokens.antiqueGold.withOpacity(0.18),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            focusNode: _focusNode,
            readOnly: widget.readOnly,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            validator: widget.validator,
            onChanged: widget.onChanged,
            inputFormatters: widget.inputFormatters,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: VaultTokens.warmIvory,
            ),
            cursorColor: VaultTokens.champagneGold,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              hintText: widget.hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: 13.5,
                color: VaultTokens.sageMuted.withOpacity(0.55),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: 18,
                      color: _isFocused ? VaultTokens.champagneGold : VaultTokens.mutedGold,
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              suffixText: widget.suffixText,
              suffixStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: VaultTokens.champagneGold,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: VaultTokens.statusDanger, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: VaultTokens.statusDanger, width: 1.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Pill-shaped luxury search input
class LuxurySearchInput extends StatelessWidget {
  const LuxurySearchInput({
    super.key,
    required this.onChanged,
    this.hintText = 'Search by jewel name, SKU, gem or category...',
    this.controller,
    this.onClear,
    this.width,
  });

  final ValueChanged<String> onChanged;
  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onClear;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0x55071F19),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: VaultTokens.borderGoldMuted, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: VaultTokens.champagneGold),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: VaultTokens.warmIvory,
              ),
              cursorColor: VaultTokens.champagneGold,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: hintText,
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: VaultTokens.sageMuted.withOpacity(0.6),
                ),
              ),
            ),
          ),
          if (controller != null && controller!.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller!.clear();
                onChanged('');
                onClear?.call();
              },
              child: const Icon(Icons.close, size: 16, color: VaultTokens.sageMuted),
            ),
        ],
      ),
    );
  }
}

/// Luxury Dropdown with dark emerald background and gold border
class LuxuryDropdown<T> extends StatelessWidget {
  const LuxuryDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: VaultTokens.sageLight,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0x4D051612),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: VaultTokens.borderGoldMuted, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              dropdownColor: const Color(0xFF09211B),
              icon: const Icon(Icons.keyboard_arrow_down, color: VaultTokens.champagneGold, size: 20),
              isExpanded: true,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: VaultTokens.warmIvory,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Luxury Counter Stepper (- and + buttons)
class LuxuryCounterInput extends StatelessWidget {
  const LuxuryCounterInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 9999,
    this.suffix = '',
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: VaultTokens.sageLight,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0x4D051612),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: VaultTokens.borderGoldMuted, width: 1),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove, size: 16, color: VaultTokens.champagneGold),
                splashRadius: 18,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$value$suffix',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: VaultTokens.warmIvory,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add, size: 16, color: VaultTokens.champagneGold),
                splashRadius: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
