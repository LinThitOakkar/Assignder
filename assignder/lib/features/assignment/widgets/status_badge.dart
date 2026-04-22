import 'package:flutter/material.dart';
import '../../../core/enums/assignment_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class StatusBadge extends StatelessWidget {
  final AssignmentStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case AssignmentStatus.submitted:
        color = AppColors.submitted;
        label = 'Submitted';
        icon = Icons.check_circle_outline;
        break;
      case AssignmentStatus.overdue:
        color = AppColors.overdue;
        label = 'Overdue';
        icon = Icons.error_outline;
        break;
      case AssignmentStatus.pending:
        color = AppColors.pending;
        label = 'Upcoming';
        icon = Icons.access_time;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
