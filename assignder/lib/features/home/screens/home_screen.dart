import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/assignment_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/widgets/assignment_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/home_header.dart';
import '../widgets/add_assignment_fab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _listeningUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authProvider = context.read<AuthProvider>();
    final assignmentProvider = context.read<AssignmentProvider>();
    final userProvider = context.read<UserProvider>();
    final userId = authProvider.userId;

    if (userId.isNotEmpty && _listeningUserId != userId) {
      assignmentProvider.startListening(userId);
      unawaited(userProvider.loadUser(userId));
      _listeningUserId = userId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AssignmentProvider, AuthProvider>(
      builder: (context, assignmentProvider, authProvider, _) {
        final userId = authProvider.userId;
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
