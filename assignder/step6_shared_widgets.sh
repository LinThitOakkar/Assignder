#!/bin/bash

# ============================================
#   Assignder - Step 6: Shared Widgets
#   bash step6_shared_widgets.sh
# ============================================

set -e

echo "📝 Writing Shared Widgets..."

# ─── app_text_field.dart ──────────────────────────────────────────────────────
cat > lib/core/widgets/app_text_field.dart << 'EOF'
import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: AppSizes.iconSm)
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
EOF

# ─── app_text_area.dart ───────────────────────────────────────────────────────
cat > lib/core/widgets/app_text_area.dart << 'EOF'
import 'package:flutter/material.dart';

class AppTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool enabled;

  const AppTextArea({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 4,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        alignLabelWithHint: true,
      ),
    );
  }
}
EOF

# ─── gradient_button.dart ─────────────────────────────────────────────────────
cat > lib/core/widgets/gradient_button.dart << 'EOF'
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_sizes.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: MaterialButton(
          onPressed: isLoading ? null : onPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
EOF

# ─── section_header.dart ──────────────────────────────────────────────────────
cat > lib/core/widgets/section_header.dart << 'EOF'
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
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
EOF

# ─── form_section_label.dart ──────────────────────────────────────────────────
cat > lib/core/widgets/form_section_label.dart << 'EOF'
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
EOF

# ─── reminder_chip.dart ───────────────────────────────────────────────────────
cat > lib/core/widgets/reminder_chip.dart << 'EOF'
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_sizes.dart';

class ReminderChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ReminderChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: isSelected
              ? null
              : Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
EOF

# ─── reminder_chip_group.dart ─────────────────────────────────────────────────
cat > lib/core/widgets/reminder_chip_group.dart << 'EOF'
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
EOF

# ─── assignment_card.dart ─────────────────────────────────────────────────────
cat > lib/core/widgets/assignment_card.dart << 'EOF'
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
EOF

# ─── app_bottom_nav_bar.dart ──────────────────────────────────────────────────
cat > lib/core/widgets/app_bottom_nav_bar.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;

  const AppScaffoldWithBottomNav({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/submitted')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/submitted');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTabTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: 'Submitted',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
EOF

echo "✅ Shared Widgets written!"
echo ""
echo "============================================"
echo "  ✅ Step 6 Complete — Shared Widgets"
echo "  👉 Run: flutter analyze"
echo "============================================"
