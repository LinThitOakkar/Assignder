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
                      activeThumbColor: AppColors.accent,
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
