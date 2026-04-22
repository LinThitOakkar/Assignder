import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_sizes.dart';

class FormSectionLabel extends StatelessWidget {
  final String label;
  final bool required;

  const FormSectionLabel({
    super.key,
    required this.label,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              color: AppColors.destructive,
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
