import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assignment_model.dart';
import '../enums/assignment_status.dart';
import '../theme/app_colors.dart';
import '../constants/app_sizes.dart';

class AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback onTap;
  final ValueChanged<bool> onCheckChanged;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
    required this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    final status = assignment.computedStatus;
    final isSubmitted = status == AssignmentStatus.submitted;
    final isOverdue = status == AssignmentStatus.overdue;

    final statusColor = isSubmitted
        ? AppColors.submitted
        : isOverdue
            ? AppColors.overdue
            : AppColors.pending;

    final statusIcon = isSubmitted
        ? Icons.check_circle_outline
        : isOverdue
            ? Icons.error_outline
            : Icons.access_time;

    final statusText = isSubmitted
        ? 'Due: ${DateFormat('MMM d, yyyy \'at\' HH:mm').format(assignment.dueDate)}'
        : isOverdue
            ? 'Overdue - ${DateFormat('MMM d, h:mm a').format(assignment.dueDate)}'
            : 'Due: ${DateFormat('MMM d, yyyy \'at\' HH:mm').format(assignment.dueDate)}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => onCheckChanged(!isSubmitted),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSubmitted
                        ? AppColors.submitted
                        : AppColors.textSecondary,
                    width: 2,
                  ),
                  color: isSubmitted ? AppColors.submitted : Colors.transparent,
                ),
                child: isSubmitted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.title,
                    style: TextStyle(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      decoration: isSubmitted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    assignment.course,
                    style: const TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Row(
                    children: [
                      Icon(statusIcon, size: 13, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: AppSizes.fontXs,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
