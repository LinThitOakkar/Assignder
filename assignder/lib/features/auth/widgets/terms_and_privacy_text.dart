import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TermsAndPrivacyText extends StatelessWidget {
  const TermsAndPrivacyText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        children: [
          TextSpan(text: 'By creating an account, you agree to our '),
          TextSpan(
            text: 'Terms',
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
