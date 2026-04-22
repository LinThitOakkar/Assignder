import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/assignment_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/assignment_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/empty_submitted_state.dart';

class SubmittedScreen extends StatelessWidget {
  const SubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AssignmentProvider, AuthProvider>(
      builder: (context, assignmentProvider, authProvider, _) {
        final userId = authProvider.userId;
        final submitted = assignmentProvider.submittedAssignments;
        final count = submitted.length;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.pagePadding,
                    AppSizes.lg,
                    AppSizes.pagePadding,
                    AppSizes.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '${AppStrings.submitted} ✓',
                        style: TextStyle(
                          fontSize: AppSizes.fontXxl,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        '$count ${count == 1 ? AppStrings.assignmentCompleted : AppStrings.assignmentsCompleted}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontMd,
                        ),
                      ),
                    ],
                  ),
                ),

                // List
                Expanded(
                  child: submitted.isEmpty
                      ? const EmptySubmittedState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.pagePadding,
                          ),
                          itemCount: submitted.length,
                          itemBuilder: (context, index) {
                            final assignment = submitted[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSizes.sm),
                              child: AssignmentCard(
                                assignment: assignment,
                                onTap: () => context.push(
                                  '/submitted/assignment/${assignment.assignmentId}',
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
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
