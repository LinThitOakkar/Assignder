import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/assignment_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../widgets/forgot_password_link.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final assignmentProvider = context.read<AssignmentProvider>();

    final success = await authProvider.signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      final userId = authProvider.firebaseUser!.uid;
      await userProvider.loadUser(userId);
      if (!mounted) return;
      assignmentProvider.startListening(userId);
      if (!mounted) return;
      context.go('/home');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final assignmentProvider = context.read<AssignmentProvider>();

    final success = await authProvider.signInWithGoogle();
    
    if (!mounted) return;
    
    if (success) {
      final userId = authProvider.firebaseUser!.uid;
      await userProvider.loadUser(userId);
      if (!mounted) return;
      assignmentProvider.startListening(userId);
      if (!mounted) return;
      context.go('/home');
    } else {
      // Error message is already set by AuthProvider and will be displayed
      // by the Consumer widget below the form
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Google sign in failed. Please try again.',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF4F7FC), Color(0xFFE8EEF9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),
                        const Text(
                          AppStrings.welcomeBack,
                          style: TextStyle(
                            fontSize: AppSizes.fontXxl,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        const Text(
                          AppStrings.loginSubtitle,
                          style: TextStyle(
                            fontSize: AppSizes.fontMd,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xl),
                        GoogleSignInButton(onPressed: _handleGoogleSignIn),
                        const SizedBox(height: AppSizes.md),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSizes.sm),
                              child: Text(AppStrings.orDivider),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: AppSizes.md),
                        const Text(
                          AppStrings.email,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        AppTextField(
                          controller: _emailController,
                          hint: 'you@example.com',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value == null || value.isEmpty
                              ? AppStrings.errorEmailRequired
                              : null,
                        ),
                        const SizedBox(height: AppSizes.md),
                        const Text(
                          AppStrings.password,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
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
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? AppStrings.errorPasswordRequired
                              : null,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        ForgotPasswordLink(
                          onTap: () => context.push('/auth/forgot-password'),
                        ),
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            if (auth.errorMessage == null) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: AppSizes.sm),
                              child: Text(
                                auth.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.destructive,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSizes.md),
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) => GradientButton(
                            label: AppStrings.signIn,
                            isLoading: auth.isLoading,
                            onPressed: _handleLogin,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(AppStrings.noAccountPrompt),
                            TextButton(
                              onPressed: () => context.go('/register'),
                              child: const Text(AppStrings.createAccountCta),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}