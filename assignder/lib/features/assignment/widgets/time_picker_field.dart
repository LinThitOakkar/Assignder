import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class TimePickerField extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final bool enabled;

  const TimePickerField({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled
          ? () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? TimeOfDay.now(),
              );
              if (picked != null) onTimeSelected(picked);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          selectedTime != null
              ? selectedTime!.format(context)
              : 'Select time',
          style: TextStyle(
            color: selectedTime != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
            fontSize: AppSizes.fontMd,
          ),
        ),
      ),
    );
  }
}
