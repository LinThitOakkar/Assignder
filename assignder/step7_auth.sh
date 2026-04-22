#!/bin/bash

# ============================================
#   Assignder - Step 7: Auth Feature
#   bash step7_auth.sh
# ============================================

set -e

echo "📝 Writing Auth Feature..."

# ─── auth_tab_switcher.dart ───────────────────────────────────────────────────
cat > lib/features/auth/widgets/auth_tab_switcher.dart << 'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class AuthTabSwitcher extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const AuthTabSwitcher({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          _Tab(
            label: AppStrings.login,
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _Tab(
            label: AppStrings.register,
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontSize: AppSizes.fontMd,
            ),
          ),
        ),
      ),
    );
  }
}
EOF

# ─── google_sign_in_button.dart ───────────────────────────────────────────────
cat > lib/features/auth/widgets/google_sign_in_button.dart << 'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.g_mobiledata, size: 28),
        label: const Text(
          AppStrings.continueWithGoogle,
          style: TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.cardBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      ),
    );
  }
}
EOF

# ─── or_divider.dart ──────────────────────────────────────────────────────────
cat > lib/features/auth/widgets/or_divider.dart << 'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            AppStrings.orDivider,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}
EOF

# ─── forgot_password_link.dart ────────────────────────────────────────────────
cat > lib/features/auth/widgets/forgot_password_link.dart << 'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class ForgotPasswordLink extends StatelessWidget {
  final VoidCallback onTap;

  const ForgotPasswordLink({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: const Text(
          AppStrings.forgotPassword,
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
EOF

# ─── terms_and_privacy_text.dart ─────────────────────────────────────────────
cat > lib/features/auth/widgets/terms_and_privacy_text.dart << 'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TermsAndPrivacyText extends StatelessWidget {
  const TermsAndPrivacyText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        children: [
          TextSpan(text: 'By creating an account, you agree to our '),
          TextSpan(
            text: 'Terms',
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
EOF

# ─── auth_screen.dart ─────────────────────────────────────────────────────────
cat > lib/features/auth/screens/auth_screen.dart << 'EOF'
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
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _selectedTab = 0;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

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
      await context.read<UserProvider>().loadUser(userId);
      context.read<AssignmentProvider>().startListening(userId);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();
    if (success && mounted) {
      final userId = authProvider.firebaseUser!.uid;
      await context.read<UserProvider>().loadUser(userId);
      context.read<AssignmentProvider>().startListening(userId);
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
                    color: Colors.black.withOpacity(0.06),
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
EOF

# ─── forgot_password_screen.dart ──────────────────────────────────────────────
cat > lib/features/auth/screens/forgot_password_screen.dart << 'EOF'
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
                    decoration: BoxDecoration(
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
                      color: AppColors.submitted.withOpacity(0.1),
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
EOF

echo "✅ Auth Feature written!"
echo ""
echo "============================================"
echo "  ✅ Step 7 Complete — Auth Feature"
echo "  👉 Run: flutter analyze"
echo "============================================"
