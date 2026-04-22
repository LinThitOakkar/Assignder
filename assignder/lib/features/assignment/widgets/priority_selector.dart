import 'package:flutter/material.dart';
import '../../../core/enums/priority.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class PrioritySelector extends StatelessWidget {
  final Priority selected;
  final ValueChanged<Priority> onChanged;

  const PrioritySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  Color _colorForPriority(Priority p) {
    switch (p) {
      case Priority.low:
        return AppColors.priorityLow;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.high:
        return AppColors.priorityHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Priority.values.map((priority) {
        final isSelected = selected == priority;
        final color = _colorForPriority(priority);
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(priority),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: AppSizes.sm),
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: isSelected ? color : AppColors.cardBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                priority.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: AppSizes.fontSm,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
