import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool enabled;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled
          ? () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (picked != null) onDateSelected(picked);
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
          selectedDate != null
              ? DateFormat('MMM d, yyyy').format(selectedDate!)
              : 'Select date',
          style: TextStyle(
            color: selectedDate != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
            fontSize: AppSizes.fontMd,
          ),
        ),
      ),
    );
  }
}
