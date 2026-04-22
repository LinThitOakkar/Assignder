import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/assignment_provider.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/profile_menu_item.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();

  Future<String?> _promptForPassword() async {
    final passwordController = TextEditingController();

    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Enter your password',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext)
                  .pop(passwordController.text.trim()),
              child: const Text(AppStrings.delete),
            ),
          ],
        );
      },
    );

    passwordController.dispose();
    return password?.isEmpty == true ? null : password;
  }

  Future<bool> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.deleteAccountTitle),
          content: const Text(AppStrings.deleteAccountMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(AppStrings.deleteAccount),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _handleDeleteAccount() async {
    final authProvider = context.read<AuthProvider>();
    final firebaseUser = authProvider.firebaseUser;
    if (firebaseUser == null) return;

    final userProvider = context.read<UserProvider>();
    final assignmentProvider = context.read<AssignmentProvider>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await _confirmDeleteAccount();
    if (!confirmed || !mounted) return;

    String? password;
    final needsPassword = firebaseUser.providerData
        .any((provider) => provider.providerId == 'password');
    if (needsPassword) {
      password = await _promptForPassword();
      if (password == null || !mounted) return;
    }

    final deleted = await authProvider.deleteAccount(password: password);
    if (!mounted) return;

    if (deleted) {
      userProvider.clearUser();
      assignmentProvider.stopListening();
      router.go('/login');
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(authProvider.errorMessage ?? 'Failed to delete account.'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _nameController.text = user?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
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
              const SizedBox(height: AppSizes.xl),
              const Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) => IgnorePointer(
                  ignoring: authProvider.isLoading,
                  child: ProfileMenuItem(
                    icon: Icons.delete_outline,
                    label: AppStrings.deleteAccount,
                    isDestructive: true,
                    onTap: _handleDeleteAccount,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
