import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthProvider>().sendPasswordResetEmail(
          _emailController.text,
        );
    if (success && mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.forgotPasswordTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.xl),

                // Lock Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                      decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Title and subtitle
                const Center(
                  child: Text(
                    AppStrings.forgotPasswordTitle,
                    style: TextStyle(
                      fontSize: AppSizes.fontXl,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                const Center(
                  child: Text(
                    AppStrings.forgotPasswordSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontMd,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),

                // Success message
                if (_emailSent)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    margin: const EdgeInsets.only(bottom: AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.submitted.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: AppColors.submitted),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.submitted),
                        SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            AppStrings.resetLinkSent,
                            style: TextStyle(color: AppColors.submitted),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Email field
                const Text(AppStrings.email,
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSizes.sm),
                AppTextField(
                  controller: _emailController,
                  hint: 'you@example.com',
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || v.isEmpty ? AppStrings.errorEmailRequired : null,
                ),

                // Error
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.errorMessage == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSizes.sm),
                      child: Text(
                        auth.errorMessage!,
                        style: const TextStyle(color: AppColors.destructive),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSizes.lg),

                // Send button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => GradientButton(
                    label: AppStrings.sendResetLink,
                    isLoading: auth.isLoading,
                    onPressed: _emailSent ? null : _handleSendReset,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
