import 'package:flutter/material.dart';
import '../constants/reminder_options.dart';
import '../constants/app_sizes.dart';
import 'reminder_chip.dart';

class ReminderChipGroup extends StatelessWidget {
  final List<String> selectedOffsets;
  final ValueChanged<List<String>> onChanged;

  const ReminderChipGroup({
    super.key,
    required this.selectedOffsets,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: ReminderOptions.all.map((offset) {
        final isSelected = selectedOffsets.contains(offset);
        return ReminderChip(
          label: ReminderOptions.getLabel(offset),
          isSelected: isSelected,
          onTap: () {
            final updated = List<String>.from(selectedOffsets);
            if (isSelected) {
              updated.remove(offset);
            } else {
              updated.add(offset);
            }
            onChanged(updated);
          },
        );
      }).toList(),
    );
  }
}
