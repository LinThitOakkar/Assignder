import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const SectionHeader({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: AppSizes.iconSm),
        const SizedBox(width: AppSizes.xs),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSizes.xs),
        Text(
          '($count)',
          style: TextStyle(
            color: color,
            fontSize: AppSizes.fontMd,
          ),
        ),
      ],
    );
  }
}
