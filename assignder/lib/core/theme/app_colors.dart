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
