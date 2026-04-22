import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/assignment_provider.dart';
import '../../../core/providers/user_provider.dart';
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
    return Consumer2<UserProvider, AssignmentProvider>(
      builder: (context, userProvider, assignmentProvider, _) {
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

                        const SizedBox(height: AppSizes.md),
                        ProfileMenuItem(
                          icon: Icons.logout,
                          label: AppStrings.logOut,
                          isDestructive: true,
                          onTap: () async {
                            final userProvider = context.read<UserProvider>();
                            final assignmentProvider =
                                context.read<AssignmentProvider>();
                            final router = GoRouter.of(context);
                            await context.read<AuthProvider>().signOut();
                            userProvider.clearUser();
                            assignmentProvider.stopListening();
                            router.go('/login');
                          },
                        ),

                        const Divider(height: AppSizes.xl),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
