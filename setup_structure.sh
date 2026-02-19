#!/bin/bash

# Assignder - Flutter Project Structure Setup Script
# Feature-based architecture with Provider + GoRouter

echo "Creating Assignder project structure..."

# Create main lib directory structure
mkdir -p lib/{core,features,services,models}

# Core directories (shared utilities, theme, constants, widgets)
mkdir -p lib/core/{theme,constants,widgets,utils,routes}

# Features directories (feature-based organization)
mkdir -p lib/features/dashboard/{widgets,providers}
mkdir -p lib/features/add_assignment/{widgets,providers}
mkdir -p lib/features/assignment_details/{widgets,providers}
mkdir -p lib/features/loading/{widgets}

# Services directories (Firebase, notifications, etc.)
mkdir -p lib/services/{firebase,notification,storage}

# Models directory
mkdir -p lib/models

# Create placeholder files for core
touch lib/core/theme/app_theme.dart
touch lib/core/constants/app_constants.dart
touch lib/core/widgets/custom_app_bar.dart
touch lib/core/routes/app_router.dart
touch lib/core/utils/date_utils.dart

# Create placeholder files for Dashboard feature
touch lib/features/dashboard/dashboard_screen.dart
touch lib/features/dashboard/providers/dashboard_provider.dart
touch lib/features/dashboard/widgets/assignment_card.dart
touch lib/features/dashboard/widgets/tab_section.dart

# Create placeholder files for Add Assignment feature
touch lib/features/add_assignment/add_assignment_screen.dart
touch lib/features/add_assignment/providers/add_assignment_provider.dart
touch lib/features/add_assignment/widgets/assignment_form.dart
touch lib/features/add_assignment/widgets/reminder_settings.dart

# Create placeholder files for Assignment Details feature
touch lib/features/assignment_details/assignment_details_screen.dart
touch lib/features/assignment_details/providers/assignment_details_provider.dart
touch lib/features/assignment_details/widgets/status_banner.dart
touch lib/features/assignment_details/widgets/deadline_info.dart

# Create placeholder files for Loading feature
touch lib/features/loading/loading_screen.dart

# Create models
touch lib/models/assignment_model.dart
touch lib/models/reminder_settings_model.dart

# Create services
touch lib/services/firebase/firebase_service.dart
touch lib/services/notification/notification_service.dart
touch lib/services/storage/local_storage_service.dart

# Create main.dart
touch lib/main.dart

echo "✅ Folder structure created successfully!"
echo ""
echo "Project Structure:"
echo "lib/"
echo "├── core/"
echo "│   ├── theme/"
echo "│   ├── constants/"
echo "│   ├── widgets/"
echo "│   ├── utils/"
echo "│   └── routes/"
echo "├── features/"
echo "│   ├── dashboard/"
echo "│   ├── add_assignment/"
echo "│   ├── assignment_details/"
echo "│   └── loading/"
echo "├── services/"
echo "│   ├── firebase/"
echo "│   ├── notification/"
echo "│   └── storage/"
echo "└── models/"
echo ""
echo "Ready to start development! 🚀"