import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class EmptySubmittedState extends StatelessWidget {
  const EmptySubmittedState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.submitted.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 40,
              color: AppColors.submitted.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            AppStrings.noSubmittedAssignments,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontMd,
            ),
          ),
        ],
      ),
    );
  }
}
