#!/bin/bash

# ============================================
#   Assignder - Flutter Project Setup Script
#   Run: bash create_assignder.sh
# ============================================

set -e

PROJECT_NAME="assignder"

echo "🚀 Creating Assignder Flutter project..."
echo ""

# ─── Create Flutter Project ───────────────────────────────────────────────────
flutter create $PROJECT_NAME
cd $PROJECT_NAME

echo ""
echo "📁 Setting up feature-based folder structure..."
echo ""

# ─── Core: Enums ──────────────────────────────────────────────────────────────
mkdir -p lib/core/enums
touch lib/core/enums/assignment_status.dart
touch lib/core/enums/priority.dart

# ─── Core: Models ─────────────────────────────────────────────────────────────
mkdir -p lib/core/models
touch lib/core/models/user_model.dart
touch lib/core/models/user_settings_model.dart
touch lib/core/models/assignment_model.dart
touch lib/core/models/reminder_model.dart

# ─── Core: Constants ──────────────────────────────────────────────────────────
mkdir -p lib/core/constants
touch lib/core/constants/app_strings.dart
touch lib/core/constants/app_sizes.dart
touch lib/core/constants/reminder_options.dart

# ─── Core: Providers ──────────────────────────────────────────────────────────
mkdir -p lib/core/providers
touch lib/core/providers/auth_provider.dart
touch lib/core/providers/assignment_provider.dart
touch lib/core/providers/user_provider.dart

# ─── Core: Router ─────────────────────────────────────────────────────────────
mkdir -p lib/core/router
touch lib/core/router/app_router.dart

# ─── Core: Services ───────────────────────────────────────────────────────────
mkdir -p lib/core/services
touch lib/core/services/auth_service.dart
touch lib/core/services/firestore_service.dart
touch lib/core/services/notification_service.dart

# ─── Core: Theme ──────────────────────────────────────────────────────────────
mkdir -p lib/core/theme
touch lib/core/theme/app_theme.dart
touch lib/core/theme/app_colors.dart

# ─── Core: Shared Widgets ─────────────────────────────────────────────────────
mkdir -p lib/core/widgets
touch lib/core/widgets/app_text_field.dart
touch lib/core/widgets/app_text_area.dart
touch lib/core/widgets/gradient_button.dart
touch lib/core/widgets/assignment_card.dart
touch lib/core/widgets/app_bottom_nav_bar.dart
touch lib/core/widgets/section_header.dart
touch lib/core/widgets/form_section_label.dart
touch lib/core/widgets/reminder_chip.dart
touch lib/core/widgets/reminder_chip_group.dart

# ─── Feature: Auth ────────────────────────────────────────────────────────────
mkdir -p lib/features/auth/screens
mkdir -p lib/features/auth/widgets
touch lib/features/auth/screens/auth_screen.dart
touch lib/features/auth/screens/forgot_password_screen.dart
touch lib/features/auth/widgets/auth_tab_switcher.dart
touch lib/features/auth/widgets/google_sign_in_button.dart
touch lib/features/auth/widgets/or_divider.dart
touch lib/features/auth/widgets/forgot_password_link.dart
touch lib/features/auth/widgets/terms_and_privacy_text.dart

# ─── Feature: Home ────────────────────────────────────────────────────────────
mkdir -p lib/features/home/screens
mkdir -p lib/features/home/widgets
touch lib/features/home/screens/home_screen.dart
touch lib/features/home/widgets/home_header.dart
touch lib/features/home/widgets/add_assignment_fab.dart

# ─── Feature: Assignment ──────────────────────────────────────────────────────
mkdir -p lib/features/assignment/screens
mkdir -p lib/features/assignment/widgets
touch lib/features/assignment/screens/add_assignment_screen.dart
touch lib/features/assignment/screens/assignment_detail_screen.dart
touch lib/features/assignment/widgets/priority_selector.dart
touch lib/features/assignment/widgets/date_picker_field.dart
touch lib/features/assignment/widgets/time_picker_field.dart
touch lib/features/assignment/widgets/status_badge.dart

# ─── Feature: Submitted ───────────────────────────────────────────────────────
mkdir -p lib/features/submitted/screens
mkdir -p lib/features/submitted/widgets
touch lib/features/submitted/screens/submitted_screen.dart
touch lib/features/submitted/widgets/empty_submitted_state.dart

# ─── Feature: Profile ─────────────────────────────────────────────────────────
mkdir -p lib/features/profile/screens
mkdir -p lib/features/profile/widgets
touch lib/features/profile/screens/profile_screen.dart
touch lib/features/profile/screens/settings_screen.dart
touch lib/features/profile/screens/notification_settings_screen.dart
touch lib/features/profile/widgets/user_info_card.dart
touch lib/features/profile/widgets/stats_row.dart
touch lib/features/profile/widgets/stat_card.dart
touch lib/features/profile/widgets/profile_menu_item.dart

echo ""
echo "✅ Folder structure created successfully!"
echo ""

# ─── pubspec.yaml ─────────────────────────────────────────────────────────────
echo "📦 Updating pubspec.yaml with dependencies..."

cat > pubspec.yaml << 'EOF'
name: assignder
description: "Assignment reminder app for university students."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  google_sign_in: ^6.2.1

  # State Management
  provider: ^6.1.2

  # Navigation
  go_router: ^14.2.7

  # Local Notifications
  flutter_local_notifications: ^17.2.2
  timezone: ^0.9.4

  # Utilities
  intl: ^0.19.0
  equatable: ^2.0.5
  uuid: ^4.4.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
EOF

echo ""
echo "📦 Installing dependencies..."
flutter pub get

echo ""
echo "============================================"
echo "  ✅ Assignder project is ready!"
echo "  👉 cd $PROJECT_NAME"
echo "  👉 Next: Add firebase_options.dart using FlutterFire CLI"
echo "  👉 Run: flutterfire configure"
echo "============================================"
echo ""
