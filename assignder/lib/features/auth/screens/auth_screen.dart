import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/assignment_provider.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/auth_tab_switcher.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/or_divider.dart';
import '../widgets/forgot_password_link.dart';
import '../widgets/terms_and_privacy_text.dart';

class AuthScreen extends StatefulWidget {
  final int initialTabIndex;

  const AuthScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late int _selectedTab;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final assignmentProvider = context.read<AssignmentProvider>();

    bool success;
    if (_selectedTab == 0) {
      success = await authProvider.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      success = await authProvider.registerWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
      );
    }

    if (success && mounted) {
      final userId = authProvider.firebaseUser!.uid;
      await userProvider.loadUser(userId);
      if (!mounted) return;
      assignmentProvider.startListening(userId);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final assignmentProvider = context.read<AssignmentProvider>();
    final success = await authProvider.signInWithGoogle();
    if (success && mounted) {
      final userId = authProvider.firebaseUser!.uid;
      await userProvider.loadUser(userId);
      if (!mounted) return;
      assignmentProvider.startListening(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.menu_book,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        const Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: AppSizes.fontXl,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // Tab Switcher
                    AuthTabSwitcher(
                      selectedIndex: _selectedTab,
                      onChanged: (index) {
                        setState(() => _selectedTab = index);
                        context.read<AuthProvider>().clearError();
                      },
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // Google Button
                    GoogleSignInButton(onPressed: _handleGoogleSignIn),
                    const SizedBox(height: AppSizes.md),

                    // Or Divider
                    const OrDivider(),
                    const SizedBox(height: AppSizes.md),

                    // Name field (Register only)
                    if (_selectedTab == 1) ...[
                      const Text('Name', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSizes.sm),
                      AppTextField(
                        controller: _nameController,
                        hint: 'Your full name',
                        prefixIcon: Icons.person_outline,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: AppSizes.md),
                    ],

                    // Email
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
                    const SizedBox(height: AppSizes.md),

                    // Password
                    const Text(AppStrings.password,
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppSizes.sm),
                    AppTextField(
                      controller: _passwordController,
                      hint: '••••••••',
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
                      validator: (v) =>
                          v == null || v.isEmpty ? AppStrings.errorPasswordRequired : null,
                    ),
                    const SizedBox(height: AppSizes.sm),

                    // Forgot Password (Login only)
                    if (_selectedTab == 0)
                      ForgotPasswordLink(
                        onTap: () => context.push('/auth/forgot-password'),
                      ),

                    // Error message
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

                    const SizedBox(height: AppSizes.md),

                    // Submit Button
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => GradientButton(
                        label: _selectedTab == 0
                            ? AppStrings.signIn
                            : AppStrings.createAccount,
                        isLoading: auth.isLoading,
                        onPressed: _handleEmailAuth,
                      ),
                    ),

                    // Terms (Register only)
                    if (_selectedTab == 1) ...[
                      const SizedBox(height: AppSizes.md),
                      const TermsAndPrivacyText(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
