import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/vault_tokens.dart';


class StepItem {
  final int index;
  final String title;
  final String subtitle;
  final IconData icon;

  const StepItem({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// 9-step glowing gold workflow timeline indicator
class LuxuryStepIndicator extends StatelessWidget {
  const LuxuryStepIndicator({
    super.key,
    required this.currentStep,
    required this.onStepTapped,
    this.steps = defaultWorkflowSteps,
  });

  final int currentStep;
  final ValueChanged<int> onStepTapped;
  final List<StepItem> steps;

  static const List<StepItem> defaultWorkflowSteps = [
    StepItem(index: 1, title: 'Basic Info', subtitle: 'Title & Category', icon: Icons.edit_note),
    StepItem(index: 2, title: 'Media', subtitle: 'Photos & 360', icon: Icons.photo_library_outlined),
    StepItem(index: 3, title: 'Specifications', subtitle: 'Metals & Gems', icon: Icons.diamond_outlined),
    StepItem(index: 4, title: 'Pricing', subtitle: 'Live Gold Calc', icon: Icons.account_balance_wallet_outlined),
    StepItem(index: 5, title: 'Inventory', subtitle: 'Stock & Vault', icon: Icons.inventory_2_outlined),
    StepItem(index: 6, title: 'Variants', subtitle: 'Sizes & Karats', icon: Icons.auto_awesome_mosaic_outlined),
    StepItem(index: 7, title: 'SEO', subtitle: 'Meta & Discovery', icon: Icons.travel_explore_outlined),
    StepItem(index: 8, title: 'Preview', subtitle: 'Client View', icon: Icons.visibility_outlined),
    StepItem(index: 9, title: 'Publish', subtitle: 'Go Live', icon: Icons.check_circle_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;

        if (isCompact) {
          // Horizontal compact scrolling pill row
          return SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: steps.length,
              separatorBuilder: (context, index) => Container(
                width: 24,
                alignment: Alignment.center,
                child: Container(
                  height: 1.5,
                  color: steps[index].index < currentStep
                      ? VaultTokens.antiqueGold
                      : VaultTokens.borderGoldMuted,
                ),
              ),
              itemBuilder: (context, index) {
                final step = steps[index];
                final isCurrent = step.index == currentStep;
                final isPassed = step.index < currentStep;

                return GestureDetector(
                  onTap: () => onStepTapped(step.index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0x660B2925)
                          : (isPassed ? const Color(0x33061A14) : Colors.transparent),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isCurrent
                            ? VaultTokens.champagneGold
                            : (isPassed ? VaultTokens.antiqueGold.withOpacity(0.5) : VaultTokens.borderGoldMuted),
                        width: isCurrent ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCircleNode(step.index, isCurrent, isPassed, 24),
                        const SizedBox(width: 8),
                        Text(
                          step.title,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                            color: isCurrent ? VaultTokens.champagneGold : (isPassed ? VaultTokens.warmIvory : VaultTokens.sageMuted),
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

        // Full desktop wide timeline with numbered nodes & subtitles
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0x40051612),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: VaultTokens.borderGoldMuted, width: 1),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: math.max(0, constraints.maxWidth - 32)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(steps.length * 2 - 1, (i) {
                  if (i.isOdd) {
                    final stepIdx = (i ~/ 2) + 1;
                    final isPassed = stepIdx < currentStep;
                    return Container(
                      width: 24,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPassed
                              ? [VaultTokens.antiqueGold, VaultTokens.champagneGold]
                              : [VaultTokens.borderGoldMuted, VaultTokens.borderGoldMuted.withOpacity(0.3)],
                        ),
                      ),
                    );
                  }

                  final stepIndex = (i ~/ 2);
                  final step = steps[stepIndex];
                  final isCurrent = step.index == currentStep;
                  final isPassed = step.index < currentStep;

                  return InkWell(
                    onTap: () => onStepTapped(step.index),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCircleNode(step.index, isCurrent, isPassed, 28),
                          const SizedBox(height: 6),
                          Text(
                            step.title,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: isCurrent
                                  ? VaultTokens.champagneGold
                                  : (isPassed ? VaultTokens.warmIvory : VaultTokens.sageMuted),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step.subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: VaultTokens.sageMuted.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );

  }

  Widget _buildCircleNode(int stepNum, bool isCurrent, bool isPassed, double size) {
    if (isPassed) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: VaultTokens.goldGradient,
          boxShadow: [
            BoxShadow(
              color: VaultTokens.antiqueGold.withOpacity(0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.check, size: 16, color: Color(0xFF161108)),
        ),
      );
    }

    if (isCurrent) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: VaultTokens.goldGradient,
          boxShadow: [
            BoxShadow(
              color: VaultTokens.champagneGold.withOpacity(0.6),
              blurRadius: 14,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$stepNum',
            style: GoogleFonts.inter(
              fontSize: size * 0.42,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF161108),
            ),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x33061A14),
        border: Border.all(color: VaultTokens.borderGoldMuted, width: 1.2),
      ),
      child: Center(
        child: Text(
          '$stepNum',
          style: GoogleFonts.inter(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: VaultTokens.sageMuted,
          ),
        ),
      ),
    );
  }
}
