import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class UserInfoCard extends StatelessWidget {
  final UserModel user;

  const UserInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: AppSizes.avatarMd,
            height: AppSizes.avatarMd,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder, width: 2),
              color: AppColors.surface,
            ),
            child: Center(
              child: Text(
                user.initials,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: AppSizes.fontLg,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Row(
                  children: [
                    const Icon(Icons.mail_outline,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        user.email,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontSm,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
