#!/bin/bash

# ============================================
#   Assignder - Step 5: Theme
#   bash step5_theme.sh
# ============================================

set -e

echo "📝 Writing Theme..."

cat > lib/core/theme/app_colors.dart << 'EOF'
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Gradient
  static const Color gradientStart = Color(0xFF4A90E2);
  static const Color gradientEnd = Color(0xFF9B51E0);

  // Background
  static const Color background = Color(0xFFEEF1F8);
  static const Color surface = Color(0xFFFFFFFF);

  // Input
  static const Color inputBackground = Color(0xFFF0F0F0);

  // Text
  static const Color textPrimary = Color(0xFF0D0D2B);
  static const Color textSecondary = Color(0xFF9E9E9E);

  // Accent
  static const Color accent = Color(0xFF7B2FBE);

  // Status
  static const Color overdue = Color(0xFFE53935);
  static const Color pending = Color(0xFF1E88E5);
  static const Color submitted = Color(0xFF43A047);

  // Priority
  static const Color priorityLow = Color(0xFF43A047);
  static const Color priorityMedium = Color(0xFFFB8C00);
  static const Color priorityHigh = Color(0xFFE53935);

  // Misc
  static const Color divider = Color(0xFFE0E0E0);
  static const Color cardBorder = Color(0xFFE0E0E0);
  static const Color destructive = Color(0xFFE53935);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
EOF

cat > lib/core/theme/app_theme.dart << 'EOF'
import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../constants/app_sizes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gradientStart,
        background: AppColors.background,
        surface: AppColors.surface,
      ),
      fontFamily: 'SF Pro Display',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppSizes.fontLg,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.gradientStart, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.destructive),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: AppSizes.fontMd,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }
}
EOF

echo "✅ Theme written!"
echo ""
echo "============================================"
echo "  ✅ Step 5 Complete — Theme"
echo "  👉 Run: flutter analyze"
echo "============================================"
