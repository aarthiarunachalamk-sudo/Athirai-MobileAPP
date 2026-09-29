import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class AuthSectionDivider extends StatelessWidget {
  final String text;

  const AuthSectionDivider({super.key, this.text = 'OR'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left thin elegant gold gradient line
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.goldPrimary, AppColors.goldBright],
              ),
            ),
          ),
        ),

        // Centered OR text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.goldBright,
              letterSpacing: 1.0,
            ),
          ),
        ),

        // Right thin elegant gold gradient line
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.goldBright, AppColors.goldPrimary],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
