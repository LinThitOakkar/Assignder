import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/assignment_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/models/assignment_model.dart';
import '../../../core/models/reminder_model.dart';
import '../../../core/enums/assignment_status.dart';
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
    if (userSettings != null && userSettings.defaultReminderOffsets.isNotEmpty) {
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

    final userId = context.read<AuthProvider>().userId;
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
      if (success) {
        context.pop();
      } else {
        final message = context.read<AssignmentProvider>().errorMessage ??
            'Failed to save assignment. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
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
