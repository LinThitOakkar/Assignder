#!/bin/bash

# ============================================
#   Assignder - Step 8-11: Features
#   bash step8_11_features.sh
# ============================================

set -e

echo "📝 Writing Home Feature..."

# ─── home_header.dart ─────────────────────────────────────────────────────────
cat > lib/features/home/widgets/home_header.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppStrings.welcomeBack} 👋',
          style: const TextStyle(
            fontSize: AppSizes.fontXxl,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          dateStr,
          style: const TextStyle(
            fontSize: AppSizes.fontMd,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
EOF

# ─── add_assignment_fab.dart ──────────────────────────────────────────────────
cat > lib/features/home/widgets/add_assignment_fab.dart << 'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AddAssignmentFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const AddAssignmentFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
EOF

# ─── home_screen.dart ─────────────────────────────────────────────────────────
cat > lib/features/home/screens/home_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/assignment_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/assignment_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/home_header.dart';
import '../widgets/add_assignment_fab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AssignmentProvider, AuthProvider>(
      builder: (context, assignmentProvider, authProvider, _) {
        final userId = authProvider.firebaseUser?.uid ?? '';
        final overdue = assignmentProvider.overdueAssignments;
        final upcoming = assignmentProvider.upcomingAssignments;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: assignmentProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {},
                    child: CustomScrollView(
                      slivers: [
                        // Header
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              AppSizes.pagePadding,
                              AppSizes.lg,
                              AppSizes.pagePadding,
                              AppSizes.md,
                            ),
                            child: HomeHeader(),
                          ),
                        ),

                        // Overdue Section
                        if (overdue.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSizes.pagePadding,
                                AppSizes.md,
                                AppSizes.pagePadding,
                                AppSizes.sm,
                              ),
                              child: SectionHeader(
                                label: AppStrings.overdue,
                                count: overdue.length,
                                color: AppColors.overdue,
                                icon: Icons.error_outline,
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final assignment = overdue[index];
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSizes.pagePadding,
                                    0,
                                    AppSizes.pagePadding,
                                    AppSizes.sm,
                                  ),
                                  child: AssignmentCard(
                                    assignment: assignment,
                                    onTap: () => context.push(
                                      '/home/assignment/${assignment.assignmentId}',
                                    ),
                                    onCheckChanged: (isSubmitted) {
                                      assignmentProvider.toggleSubmitted(
                                        userId,
                                        assignment.assignmentId,
                                        isSubmitted,
                                      );
                                    },
                                  ),
                                );
                              },
                              childCount: overdue.length,
                            ),
                          ),
                        ],

                        // Upcoming Section
                        if (upcoming.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSizes.pagePadding,
                                AppSizes.md,
                                AppSizes.pagePadding,
                                AppSizes.sm,
                              ),
                              child: SectionHeader(
                                label: AppStrings.upcoming,
                                count: upcoming.length,
                                color: AppColors.pending,
                                icon: Icons.access_time,
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final assignment = upcoming[index];
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSizes.pagePadding,
                                    0,
                                    AppSizes.pagePadding,
                                    AppSizes.sm,
                                  ),
                                  child: AssignmentCard(
                                    assignment: assignment,
                                    onTap: () => context.push(
                                      '/home/assignment/${assignment.assignmentId}',
                                    ),
                                    onCheckChanged: (isSubmitted) {
                                      assignmentProvider.toggleSubmitted(
                                        userId,
                                        assignment.assignmentId,
                                        isSubmitted,
                                      );
                                    },
                                  ),
                                );
                              },
                              childCount: upcoming.length,
                            ),
                          ),
                        ],

                        // Empty State
                        if (overdue.isEmpty && upcoming.isEmpty)
                          const SliverFillRemaining(
                            child: Center(
                              child: Text(
                                AppStrings.noAssignments,
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          ),

                        const SliverToBoxAdapter(
                          child: SizedBox(height: 80),
                        ),
                      ],
                    ),
                  ),
          ),
          floatingActionButton: AddAssignmentFAB(
            onPressed: () => context.push('/home/add-assignment'),
          ),
        );
      },
    );
  }
}
EOF

echo "✅ Home Feature written!"
echo ""
echo "📝 Writing Assignment Feature..."

# ─── priority_selector.dart ───────────────────────────────────────────────────
cat > lib/features/assignment/widgets/priority_selector.dart << 'EOF'
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
                color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
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
EOF

# ─── date_picker_field.dart ───────────────────────────────────────────────────
cat > lib/features/assignment/widgets/date_picker_field.dart << 'EOF'
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
EOF

# ─── time_picker_field.dart ───────────────────────────────────────────────────
cat > lib/features/assignment/widgets/time_picker_field.dart << 'EOF'
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
EOF

# ─── status_badge.dart ────────────────────────────────────────────────────────
cat > lib/features/assignment/widgets/status_badge.dart << 'EOF'
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withOpacity(0.4)),
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
EOF

# ─── add_assignment_screen.dart ───────────────────────────────────────────────
cat > lib/features/assignment/screens/add_assignment_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/assignment_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/models/assignment_model.dart';
import '../../../core/models/reminder_model.dart';
import '../../../core/enums/priority.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_text_area.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/form_section_label.dart';
import '../../../core/widgets/reminder_chip_group.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/priority_selector.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/time_picker_field.dart';

class AddAssignmentScreen extends StatefulWidget {
  const AddAssignmentScreen({super.key});

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Priority _selectedPriority = Priority.medium;
  List<String> _selectedReminders = ['24h_before', '2h_before'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill reminders from user default settings
    final userSettings = context.read<UserProvider>().user?.settings;
    if (userSettings != null) {
      _selectedReminders = List.from(userSettings.defaultReminderOffsets);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorDueDateRequired)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final time = _selectedTime ?? const TimeOfDay(hour: 23, minute: 59);
    final dueDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      time.hour,
      time.minute,
    );

    final userId = context.read<AuthProvider>().firebaseUser!.uid;
    final assignment = AssignmentModel(
      assignmentId: const Uuid().v4(),
      userId: userId,
      title: _titleController.text.trim(),
      course: _courseController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: Priority.medium == _selectedPriority
          ? Priority.medium == Priority.medium
              ? const AssignmentModel(
                      assignmentId: '',
                      userId: '',
                      title: '',
                      course: '',
                      dueDate: null,
                      createdAt: null,
                      updatedAt: null,
                      status: null,
                      priority: Priority.medium,
                      reminder: ReminderModel(enabled: true, offsets: []))
                  .status
              : null
          : null,
      priority: _selectedPriority,
      reminder: ReminderModel(
        enabled: _selectedReminders.isNotEmpty,
        offsets: _selectedReminders,
      ),
    );

    // Build the assignment correctly
    final newAssignment = AssignmentModel(
      assignmentId: const Uuid().v4(),
      userId: userId,
      title: _titleController.text.trim(),
      course: _courseController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: AssignmentStatus.pending,
      priority: _selectedPriority,
      reminder: ReminderModel(
        enabled: _selectedReminders.isNotEmpty,
        offsets: _selectedReminders,
      ),
    );

    final success = await context
        .read<AssignmentProvider>()
        .addAssignment(userId, newAssignment);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.addAssignment),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const FormSectionLabel(label: AppStrings.title, required: true),
                const SizedBox(height: AppSizes.sm),
                AppTextField(
                  controller: _titleController,
                  hint: AppStrings.titleHint,
                  validator: (v) =>
                      v == null || v.isEmpty ? AppStrings.errorTitleRequired : null,
                ),
                const SizedBox(height: AppSizes.md),

                // Course
                const FormSectionLabel(label: AppStrings.courseSubject, required: true),
                const SizedBox(height: AppSizes.sm),
                AppTextField(
                  controller: _courseController,
                  hint: AppStrings.courseHint,
                  validator: (v) =>
                      v == null || v.isEmpty ? AppStrings.errorCourseRequired : null,
                ),
                const SizedBox(height: AppSizes.md),

                // Description
                const FormSectionLabel(label: AppStrings.description),
                const SizedBox(height: AppSizes.sm),
                AppTextArea(
                  controller: _descriptionController,
                  hint: AppStrings.descriptionHint,
                ),
                const SizedBox(height: AppSizes.md),

                // Due Date & Time
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FormSectionLabel(
                              label: AppStrings.dueDate, required: true),
                          const SizedBox(height: AppSizes.sm),
                          DatePickerField(
                            selectedDate: _selectedDate,
                            onDateSelected: (date) =>
                                setState(() => _selectedDate = date),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FormSectionLabel(
                              label: AppStrings.time, required: true),
                          const SizedBox(height: AppSizes.sm),
                          TimePickerField(
                            selectedTime: _selectedTime,
                            onTimeSelected: (time) =>
                                setState(() => _selectedTime = time),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),

                // Priority
                const FormSectionLabel(label: AppStrings.priority, required: true),
                const SizedBox(height: AppSizes.sm),
                PrioritySelector(
                  selected: _selectedPriority,
                  onChanged: (p) => setState(() => _selectedPriority = p),
                ),
                const SizedBox(height: AppSizes.md),

                // Smart Reminders
                const Row(
                  children: [
                    Icon(Icons.notifications_outlined, size: 18),
                    SizedBox(width: 6),
                    Text(
                      AppStrings.smartReminders,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.fontMd,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                ReminderChipGroup(
                  selectedOffsets: _selectedReminders,
                  onChanged: (offsets) =>
                      setState(() => _selectedReminders = offsets),
                ),
                const SizedBox(height: AppSizes.xl),

                // Save Button
                GradientButton(
                  label: AppStrings.saveAssignment,
                  isLoading: _isLoading,
                  onPressed: _handleSave,
                ),
                const SizedBox(height: AppSizes.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
EOF

# ─── assignment_detail_screen.dart ────────────────────────────────────────────
cat > lib/features/assignment/screens/assignment_detail_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/assignment_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/assignment_model.dart';
import '../../../core/models/reminder_model.dart';
import '../../../core/enums/priority.dart';
import '../../../core/enums/assignment_status.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_text_area.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/form_section_label.dart';
import '../../../core/widgets/reminder_chip_group.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/priority_selector.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/time_picker_field.dart';
import '../widgets/status_badge.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final String assignmentId;

  const AssignmentDetailScreen({super.key, required this.assignmentId});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  bool _isEditMode = false;
  bool _isLoading = false;

  late TextEditingController _titleController;
  late TextEditingController _courseController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Priority _selectedPriority = Priority.medium;
  List<String> _selectedReminders = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _courseController = TextEditingController();
    _descriptionController = TextEditingController();
    _populateFields();
  }

  void _populateFields() {
    final assignment = context
        .read<AssignmentProvider>()
        .getAssignmentById(widget.assignmentId);
    if (assignment == null) return;

    _titleController.text = assignment.title;
    _courseController.text = assignment.course;
    _descriptionController.text = assignment.description ?? '';
    _selectedDate = assignment.dueDate;
    _selectedTime = TimeOfDay.fromDateTime(assignment.dueDate);
    _selectedPriority = assignment.priority;
    _selectedReminders = List.from(assignment.reminder.offsets);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave(AssignmentModel original) async {
    setState(() => _isLoading = true);
    final userId = context.read<AuthProvider>().firebaseUser!.uid;

    final dueDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final updated = original.copyWith(
      title: _titleController.text.trim(),
      course: _courseController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: dueDate,
      updatedAt: DateTime.now(),
      priority: _selectedPriority,
      reminder: ReminderModel(
        enabled: _selectedReminders.isNotEmpty,
        offsets: _selectedReminders,
      ),
    );

    final success = await context
        .read<AssignmentProvider>()
        .updateAssignment(userId, updated);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (success) _isEditMode = false;
      });
    }
  }

  Future<void> _handleDelete(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteConfirmTitle),
        content: const Text(AppStrings.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.destructive),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context
          .read<AssignmentProvider>()
          .deleteAssignment(userId, widget.assignmentId);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AssignmentProvider, AuthProvider>(
      builder: (context, assignmentProvider, authProvider, _) {
        final assignment =
            assignmentProvider.getAssignmentById(widget.assignmentId);
        final userId = authProvider.firebaseUser?.uid ?? '';

        if (assignment == null) {
          return const Scaffold(
            body: Center(child: Text('Assignment not found')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Text(_isEditMode
                ? AppStrings.editAssignment
                : AppStrings.assignmentDetail),
            actions: [
              if (!_isEditMode) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => setState(() => _isEditMode = true),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.destructive),
                  onPressed: () => _handleDelete(userId),
                ),
              ] else
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _populateFields();
                    setState(() => _isEditMode = false);
                  },
                ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge (view mode only)
                  if (!_isEditMode) ...[
                    StatusBadge(status: assignment.computedStatus),
                    const SizedBox(height: AppSizes.md),
                  ],

                  // Title
                  const FormSectionLabel(label: AppStrings.title, required: true),
                  const SizedBox(height: AppSizes.sm),
                  AppTextField(
                    controller: _titleController,
                    hint: AppStrings.titleHint,
                    enabled: _isEditMode,
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Course
                  const FormSectionLabel(
                      label: AppStrings.courseSubject, required: true),
                  const SizedBox(height: AppSizes.sm),
                  AppTextField(
                    controller: _courseController,
                    hint: AppStrings.courseHint,
                    enabled: _isEditMode,
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Description
                  const FormSectionLabel(label: AppStrings.description),
                  const SizedBox(height: AppSizes.sm),
                  AppTextArea(
                    controller: _descriptionController,
                    hint: AppStrings.descriptionHint,
                    enabled: _isEditMode,
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Due Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const FormSectionLabel(label: AppStrings.dueDate),
                            const SizedBox(height: AppSizes.sm),
                            DatePickerField(
                              selectedDate: _selectedDate,
                              onDateSelected: (date) =>
                                  setState(() => _selectedDate = date),
                              enabled: _isEditMode,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const FormSectionLabel(label: AppStrings.time),
                            const SizedBox(height: AppSizes.sm),
                            TimePickerField(
                              selectedTime: _selectedTime,
                              onTimeSelected: (time) =>
                                  setState(() => _selectedTime = time),
                              enabled: _isEditMode,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Priority
                  const FormSectionLabel(label: AppStrings.priority),
                  const SizedBox(height: AppSizes.sm),
                  PrioritySelector(
                    selected: _selectedPriority,
                    onChanged: _isEditMode
                        ? (p) => setState(() => _selectedPriority = p)
                        : (_) {},
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Reminders
                  const Row(
                    children: [
                      Icon(Icons.notifications_outlined, size: 18),
                      SizedBox(width: 6),
                      Text(
                        AppStrings.smartReminders,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: AppSizes.fontMd,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  ReminderChipGroup(
                    selectedOffsets: _selectedReminders,
                    onChanged: _isEditMode
                        ? (offsets) =>
                            setState(() => _selectedReminders = offsets)
                        : (_) {},
                  ),

                  // Save button (edit mode only)
                  if (_isEditMode) ...[
                    const SizedBox(height: AppSizes.xl),
                    GradientButton(
                      label: AppStrings.saveChanges,
                      isLoading: _isLoading,
                      onPressed: () => _handleSave(assignment),
                    ),
                  ],

                  const SizedBox(height: AppSizes.lg),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
EOF

echo "✅ Assignment Feature written!"
echo ""
echo "📝 Writing Submitted Feature..."

# ─── empty_submitted_state.dart ───────────────────────────────────────────────
cat > lib/features/submitted/widgets/empty_submitted_state.dart << 'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class EmptySubmittedState extends StatelessWidget {
  const EmptySubmittedState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.submitted.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 40,
              color: AppColors.submitted.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            AppStrings.noSubmittedAssignments,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontMd,
            ),
          ),
        ],
      ),
    );
  }
}
EOF

# ─── submitted_screen.dart ────────────────────────────────────────────────────
cat > lib/features/submitted/screens/submitted_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/assignment_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/assignment_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/empty_submitted_state.dart';

class SubmittedScreen extends StatelessWidget {
  const SubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AssignmentProvider, AuthProvider>(
      builder: (context, assignmentProvider, authProvider, _) {
        final userId = authProvider.firebaseUser?.uid ?? '';
        final submitted = assignmentProvider.submittedAssignments;
        final count = submitted.length;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.pagePadding,
                    AppSizes.lg,
                    AppSizes.pagePadding,
                    AppSizes.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '${AppStrings.submitted} ✓',
                        style: TextStyle(
                          fontSize: AppSizes.fontXxl,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        '$count ${count == 1 ? AppStrings.assignmentCompleted : AppStrings.assignmentsCompleted}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontMd,
                        ),
                      ),
                    ],
                  ),
                ),

                // List
                Expanded(
                  child: submitted.isEmpty
                      ? const EmptySubmittedState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.pagePadding,
                          ),
                          itemCount: submitted.length,
                          itemBuilder: (context, index) {
                            final assignment = submitted[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSizes.sm),
                              child: AssignmentCard(
                                assignment: assignment,
                                onTap: () => context.push(
                                  '/submitted/assignment/${assignment.assignmentId}',
                                ),
                                onCheckChanged: (isSubmitted) {
                                  assignmentProvider.toggleSubmitted(
                                    userId,
                                    assignment.assignmentId,
                                    isSubmitted,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
EOF

echo "✅ Submitted Feature written!"
echo ""
echo "📝 Writing Profile Feature..."

# ─── user_info_card.dart ──────────────────────────────────────────────────────
cat > lib/features/profile/widgets/user_info_card.dart << 'EOF'
import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class UserInfoCard extends StatelessWidget {
  final UserModel user;

  const UserInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: AppSizes.avatarMd,
            height: AppSizes.avatarMd,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder, width: 2),
              color: AppColors.surface,
            ),
            child: Center(
              child: Text(
                user.initials,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: AppSizes.fontLg,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Row(
                  children: [
                    const Icon(Icons.mail_outline,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        user.email,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontSm,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
EOF

# ─── stat_card.dart ───────────────────────────────────────────────────────────
cat > lib/features/profile/widgets/stat_card.dart << 'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: AppSizes.iconMd, color: AppColors.textSecondary),
            const SizedBox(height: AppSizes.sm),
            Text(
              value,
              style: const TextStyle(
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppSizes.fontXs,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# ─── stats_row.dart ───────────────────────────────────────────────────────────
cat > lib/features/profile/widgets/stats_row.dart << 'EOF'
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
EOF

# ─── profile_menu_item.dart ───────────────────────────────────────────────────
cat > lib/features/profile/widgets/profile_menu_item.dart << 'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.destructive : AppColors.textPrimary;
    final bgColor = isDestructive
        ? AppColors.destructive.withOpacity(0.1)
        : AppColors.inputBackground;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(icon, color: color, size: AppSizes.iconSm),
            ),
            const SizedBox(width: AppSizes.md),
            Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.fontMd,
                color: color,
                fontWeight:
                    isDestructive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# ─── profile_screen.dart ──────────────────────────────────────────────────────
cat > lib/features/profile/screens/profile_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/assignment_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/user_info_card.dart';
import '../widgets/stats_row.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserProvider, AssignmentProvider, AuthProvider>(
      builder: (context, userProvider, assignmentProvider, authProvider, _) {
        final user = userProvider.user;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: user == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.pagePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSizes.sm),

                        // Title
                        const Text(
                          AppStrings.profile,
                          style: TextStyle(
                            fontSize: AppSizes.fontXxl,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        const Text(
                          AppStrings.profileSubtitle,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppSizes.fontMd,
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),

                        // User Info Card
                        UserInfoCard(user: user),
                        const SizedBox(height: AppSizes.md),

                        // Stats Row
                        StatsRow(
                          activeCount: assignmentProvider.activeCount,
                          completedCount: assignmentProvider.completedCount,
                          completionRate: assignmentProvider.completionRate,
                        ),
                        const SizedBox(height: AppSizes.lg),

                        // Menu Items
                        ProfileMenuItem(
                          icon: Icons.settings_outlined,
                          label: AppStrings.settings,
                          onTap: () => context.push('/profile/settings'),
                        ),
                        ProfileMenuItem(
                          icon: Icons.notifications_outlined,
                          label: AppStrings.notifications,
                          onTap: () => context
                              .push('/profile/settings/notifications'),
                        ),

                        const Divider(height: AppSizes.xl),

                        // Log Out
                        ProfileMenuItem(
                          icon: Icons.logout,
                          label: AppStrings.logOut,
                          isDestructive: true,
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(AppStrings.logOut),
                                content:
                                    const Text(AppStrings.logOutConfirm),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text(AppStrings.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      AppStrings.logOut,
                                      style: TextStyle(
                                          color: AppColors.destructive),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              assignmentProvider.stopListening();
                              userProvider.clearUser();
                              await authProvider.signOut();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
EOF

# ─── settings_screen.dart ─────────────────────────────────────────────────────
cat > lib/features/profile/screens/settings_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _nameController.text = user?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.settingsTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Section
              const Text(
                AppStrings.account,
                style: TextStyle(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Edit Name
              const Text(AppStrings.editName,
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSizes.sm),
              AppTextField(
                controller: _nameController,
                hint: 'Your full name',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: AppSizes.sm),
              Consumer<UserProvider>(
                builder: (context, userProvider, _) => GradientButton(
                  label: 'Update Name',
                  isLoading: userProvider.isLoading,
                  onPressed: () async {
                    final success = await userProvider
                        .updateName(_nameController.text.trim());
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name updated!')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Change Password
              const Text(AppStrings.changePassword,
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSizes.sm),
              AppTextField(
                controller: _passwordController,
                hint: 'New password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Consumer<UserProvider>(
                builder: (context, userProvider, _) => GradientButton(
                  label: 'Update Password',
                  isLoading: userProvider.isLoading,
                  onPressed: () async {
                    if (_passwordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Password must be at least 6 characters.')),
                      );
                      return;
                    }
                    final success = await userProvider
                        .updatePassword(_passwordController.text);
                    if (success && context.mounted) {
                      _passwordController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password updated!')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

# ─── notification_settings_screen.dart ───────────────────────────────────────
cat > lib/features/profile/screens/notification_settings_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/models/user_settings_model.dart';
import '../../../core/widgets/reminder_chip_group.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late bool _notificationsEnabled;
  late List<String> _defaultOffsets;

  @override
  void initState() {
    super.initState();
    final settings = context.read<UserProvider>().user?.settings;
    _notificationsEnabled = settings?.notificationsEnabled ?? true;
    _defaultOffsets = List.from(settings?.defaultReminderOffsets ?? []);
  }

  Future<void> _saveSettings() async {
    final newSettings = UserSettings(
      notificationsEnabled: _notificationsEnabled,
      defaultReminderOffsets: _defaultOffsets,
    );
    final success =
        await context.read<UserProvider>().updateSettings(newSettings);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification settings saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.notificationSettings),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enable Notifications Toggle
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.enableNotifications,
                      style: TextStyle(
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) =>
                          setState(() => _notificationsEnabled = value),
                      activeColor: AppColors.accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Default Reminders
              const Text(
                AppStrings.defaultReminders,
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              const Text(
                'These will be pre-selected when you add a new assignment.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppSizes.fontSm,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              ReminderChipGroup(
                selectedOffsets: _defaultOffsets,
                onChanged: (offsets) =>
                    setState(() => _defaultOffsets = offsets),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

echo "✅ Profile Feature written!"
echo ""
echo "============================================"
echo "  ✅ Steps 8-11 Complete — All Features"
echo "  👉 Run: flutter analyze"
echo "============================================"
