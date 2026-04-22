import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import 'stat_card.dart';

class StatsRow extends StatelessWidget {
  final int activeCount;
  final int completedCount;
  final double completionRate;

  const StatsRow({
    super.key,
    required this.activeCount,
    required this.completedCount,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatCard(
          icon: Icons.menu_book_outlined,
          value: '$activeCount',
          label: AppStrings.active,
        ),
        const SizedBox(width: AppSizes.sm),
        StatCard(
          icon: Icons.workspace_premium_outlined,
          value: '$completedCount',
          label: AppStrings.completed,
        ),
        const SizedBox(width: AppSizes.sm),
        StatCard(
          icon: Icons.trending_up,
          value: '${completionRate.toStringAsFixed(0)}%',
          label: AppStrings.rate,
        ),
      ],
    );
  }
}
