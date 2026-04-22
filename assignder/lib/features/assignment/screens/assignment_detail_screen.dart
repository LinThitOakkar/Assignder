import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/assignment_provider.dart';
import '../../../core/providers/auth_provider.dart';
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
    final userId = context.read<AuthProvider>().userId;

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
      if (!success) {
        final message = context.read<AssignmentProvider>().errorMessage ??
            'Failed to update assignment. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
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
        final userId = authProvider.userId;

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
