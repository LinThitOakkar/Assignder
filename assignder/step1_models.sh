#!/bin/bash

# ============================================
#   Assignder - Step 1: Models, Enums & Constants
#   Run from inside your assignder project folder
#   bash step1_models.sh
# ============================================

set -e

echo "📝 Writing Enums..."

# ─── assignment_status.dart ───────────────────────────────────────────────────
cat > lib/core/enums/assignment_status.dart << 'EOF'
enum AssignmentStatus {
  pending,
  submitted,
  overdue; // Computed only — never stored in Firestore

  static AssignmentStatus fromString(String value) {
    switch (value) {
      case 'submitted':
        return AssignmentStatus.submitted;
      case 'pending':
      default:
        return AssignmentStatus.pending;
    }
  }

  String toFirestoreString() {
    switch (this) {
      case AssignmentStatus.submitted:
        return 'submitted';
      case AssignmentStatus.pending:
      case AssignmentStatus.overdue:
        return 'pending';
    }
  }
}
EOF

# ─── priority.dart ────────────────────────────────────────────────────────────
cat > lib/core/enums/priority.dart << 'EOF'
enum Priority {
  low,
  medium,
  high;

  static Priority fromString(String value) {
    switch (value) {
      case 'low':
        return Priority.low;
      case 'high':
        return Priority.high;
      case 'medium':
      default:
        return Priority.medium;
    }
  }

  String toFirestoreString() {
    switch (this) {
      case Priority.low:
        return 'low';
      case Priority.medium:
        return 'medium';
      case Priority.high:
        return 'high';
    }
  }

  String get label {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }
}
EOF

echo "✅ Enums written!"
echo ""
echo "📝 Writing Models..."

# ─── reminder_model.dart ──────────────────────────────────────────────────────
cat > lib/core/models/reminder_model.dart << 'EOF'
class ReminderModel {
  final bool enabled;
  final List<String> offsets;

  const ReminderModel({
    required this.enabled,
    required this.offsets,
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      enabled: map['enabled'] as bool? ?? true,
      offsets: List<String>.from(map['offsets'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'offsets': offsets,
    };
  }

  ReminderModel copyWith({
    bool? enabled,
    List<String>? offsets,
  }) {
    return ReminderModel(
      enabled: enabled ?? this.enabled,
      offsets: offsets ?? this.offsets,
    );
  }
}
EOF

# ─── user_settings_model.dart ─────────────────────────────────────────────────
cat > lib/core/models/user_settings_model.dart << 'EOF'
class UserSettings {
  final bool notificationsEnabled;
  final List<String> defaultReminderOffsets;

  const UserSettings({
    required this.notificationsEnabled,
    required this.defaultReminderOffsets,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      defaultReminderOffsets:
          List<String>.from(map['defaultReminderOffsets'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'defaultReminderOffsets': defaultReminderOffsets,
    };
  }

  UserSettings copyWith({
    bool? notificationsEnabled,
    List<String>? defaultReminderOffsets,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultReminderOffsets:
          defaultReminderOffsets ?? this.defaultReminderOffsets,
    );
  }

  factory UserSettings.defaults() {
    return const UserSettings(
      notificationsEnabled: true,
      defaultReminderOffsets: ['24h_before', '2h_before'],
    );
  }
}
EOF

# ─── user_model.dart ──────────────────────────────────────────────────────────
cat > lib/core/models/user_model.dart << 'EOF'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_settings_model.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final DateTime createdAt;
  final UserSettings settings;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.settings,
  });

  factory UserModel.fromMap(String userId, Map<String, dynamic> map) {
    return UserModel(
      userId: userId,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      settings: map['settings'] != null
          ? UserSettings.fromMap(map['settings'] as Map<String, dynamic>)
          : UserSettings.defaults(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'settings': settings.toMap(),
    };
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    DateTime? createdAt,
    UserSettings? settings,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings,
    );
  }

  /// Returns initials from name e.g. "John Doe" → "JD"
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }
}
EOF

# ─── assignment_model.dart ────────────────────────────────────────────────────
cat > lib/core/models/assignment_model.dart << 'EOF'
import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/assignment_status.dart';
import '../enums/priority.dart';
import 'reminder_model.dart';

class AssignmentModel {
  final String assignmentId;
  final String userId;
  final String title;
  final String course;
  final String? description;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AssignmentStatus status;
  final DateTime? submittedAt;
  final Priority priority;
  final ReminderModel reminder;

  const AssignmentModel({
    required this.assignmentId,
    required this.userId,
    required this.title,
    required this.course,
    this.description,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.submittedAt,
    required this.priority,
    required this.reminder,
  });

  /// Computed status — overdue is never stored, always derived at runtime
  AssignmentStatus get computedStatus {
    if (status == AssignmentStatus.submitted) {
      return AssignmentStatus.submitted;
    }
    if (dueDate.isBefore(DateTime.now())) {
      return AssignmentStatus.overdue;
    }
    return AssignmentStatus.pending;
  }

  bool get isOverdue =>
      status != AssignmentStatus.submitted &&
      dueDate.isBefore(DateTime.now());

  bool get isSubmitted => status == AssignmentStatus.submitted;

  factory AssignmentModel.fromMap(
      String assignmentId, Map<String, dynamic> map) {
    return AssignmentModel(
      assignmentId: assignmentId,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      course: map['course'] as String? ?? '',
      description: map['description'] as String?,
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: AssignmentStatus.fromString(map['status'] as String? ?? ''),
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate(),
      priority: Priority.fromString(map['priority'] as String? ?? 'medium'),
      reminder: map['reminder'] != null
          ? ReminderModel.fromMap(map['reminder'] as Map<String, dynamic>)
          : const ReminderModel(enabled: true, offsets: []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'course': course,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status.toFirestoreString(),
      'submittedAt':
          submittedAt != null ? Timestamp.fromDate(submittedAt!) : null,
      'priority': priority.toFirestoreString(),
      'reminder': reminder.toMap(),
    };
  }

  AssignmentModel copyWith({
    String? assignmentId,
    String? userId,
    String? title,
    String? course,
    String? description,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    AssignmentStatus? status,
    DateTime? submittedAt,
    Priority? priority,
    ReminderModel? reminder,
  }) {
    return AssignmentModel(
      assignmentId: assignmentId ?? this.assignmentId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      course: course ?? this.course,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      priority: priority ?? this.priority,
      reminder: reminder ?? this.reminder,
    );
  }
}
EOF

echo "✅ Models written!"
echo ""
echo "📝 Writing Constants..."

# ─── app_strings.dart ─────────────────────────────────────────────────────────
cat > lib/core/constants/app_strings.dart << 'EOF'
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Assignder';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String signIn = 'Sign In';
  static const String createAccount = 'Create Account';
  static const String continueWithGoogle = 'Continue with Google';
  static const String forgotPassword = 'Forgot password?';
  static const String forgotPasswordTitle = 'Forgot Password';
  static const String forgotPasswordSubtitle =
      'Enter your email and we\'ll send you a reset link';
  static const String sendResetLink = 'Send Reset Link';
  static const String resetLinkSent =
      'Reset link sent! Please check your email.';
  static const String orDivider = 'or';
  static const String termsAndPrivacy =
      'By creating an account, you agree to our Terms and Privacy Policy';

  // Home
  static const String welcomeBack = 'Welcome back!';
  static const String overdue = 'Overdue';
  static const String upcoming = 'Upcoming';
  static const String noAssignments = 'No assignments yet. Add one!';

  // Add Assignment
  static const String addAssignment = 'Add Assignment';
  static const String title = 'Title';
  static const String titleHint = 'e.g., Final Project Report';
  static const String courseSubject = 'Course / Subject';
  static const String courseHint = 'e.g., Computer Science 101';
  static const String description = 'Description (optional)';
  static const String descriptionHint =
      'Add any additional notes or details...';
  static const String dueDate = 'Due Date';
  static const String time = 'Time';
  static const String smartReminders = 'Smart Reminders';
  static const String saveAssignment = 'Save Assignment';
  static const String priority = 'Priority';

  // Assignment Detail
  static const String assignmentDetail = 'Assignment Detail';
  static const String editAssignment = 'Edit Assignment';
  static const String saveChanges = 'Save Changes';
  static const String deleteAssignment = 'Delete Assignment';
  static const String deleteConfirmTitle = 'Delete Assignment?';
  static const String deleteConfirmMessage = 'This action cannot be undone.';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';

  // Submitted
  static const String submitted = 'Submitted';
  static const String assignmentCompleted = 'assignment completed';
  static const String assignmentsCompleted = 'assignments completed';
  static const String noSubmittedAssignments = 'No submitted assignments yet.';

  // Profile
  static const String profile = 'Profile';
  static const String profileSubtitle =
      'Manage your account and preferences';
  static const String active = 'Active';
  static const String completed = 'Completed';
  static const String rate = 'Rate';
  static const String settings = 'Settings';
  static const String notifications = 'Notifications';
  static const String logOut = 'Log Out';
  static const String logOutConfirm = 'Are you sure you want to log out?';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String account = 'Account';
  static const String editName = 'Edit Display Name';
  static const String changePassword = 'Change Password';
  static const String preferences = 'Preferences';

  // Notification Settings
  static const String notificationSettings = 'Notification Settings';
  static const String enableNotifications = 'Enable Notifications';
  static const String defaultReminders = 'Default Reminder Offsets';

  // Errors
  static const String errorGeneric =
      'Something went wrong. Please try again.';
  static const String errorEmailRequired = 'Email is required';
  static const String errorPasswordRequired = 'Password is required';
  static const String errorTitleRequired = 'Title is required';
  static const String errorCourseRequired = 'Course is required';
  static const String errorDueDateRequired = 'Due date is required';
}
EOF

# ─── app_sizes.dart ───────────────────────────────────────────────────────────
cat > lib/core/constants/app_sizes.dart << 'EOF'
class AppSizes {
  AppSizes._();

  // Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 100.0;

  // Font Sizes
  static const double fontXs = 11.0;
  static const double fontSm = 13.0;
  static const double fontMd = 15.0;
  static const double fontLg = 17.0;
  static const double fontXl = 22.0;
  static const double fontXxl = 28.0;

  // Icon Sizes
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;

  // Component Heights
  static const double inputHeight = 52.0;
  static const double buttonHeight = 54.0;
  static const double bottomNavHeight = 64.0;
  static const double appBarHeight = 56.0;

  // Card
  static const double cardPadding = 16.0;
  static const double cardRadius = 12.0;

  // Avatar
  static const double avatarMd = 56.0;
  static const double avatarLg = 72.0;

  // FAB
  static const double fabSize = 56.0;

  // Page Padding
  static const double pagePadding = 20.0;
}
EOF

# ─── reminder_options.dart ────────────────────────────────────────────────────
cat > lib/core/constants/reminder_options.dart << 'EOF'
class ReminderOptions {
  ReminderOptions._();

  static const String oneWeekBefore = '1_week_before';
  static const String threeDaysBefore = '3_days_before';
  static const String twentyFourHoursBefore = '24h_before';
  static const String twoHoursBefore = '2h_before';
  static const String oneHourBefore = '1h_before';

  static const List<String> all = [
    oneWeekBefore,
    threeDaysBefore,
    twentyFourHoursBefore,
    twoHoursBefore,
    oneHourBefore,
  ];

  static String getLabel(String offset) {
    switch (offset) {
      case oneWeekBefore:
        return '1 week before';
      case threeDaysBefore:
        return '3 days before';
      case twentyFourHoursBefore:
        return '24 hours before';
      case twoHoursBefore:
        return '2 hours before';
      case oneHourBefore:
        return '1 hour before';
      default:
        return offset;
    }
  }

  static Duration getDuration(String offset) {
    switch (offset) {
      case oneWeekBefore:
        return const Duration(days: 7);
      case threeDaysBefore:
        return const Duration(days: 3);
      case twentyFourHoursBefore:
        return const Duration(hours: 24);
      case twoHoursBefore:
        return const Duration(hours: 2);
      case oneHourBefore:
        return const Duration(hours: 1);
      default:
        return const Duration(hours: 1);
    }
  }
}
EOF

echo "✅ Constants written!"
echo ""
echo "============================================"
echo "  ✅ Step 1 Complete — Models, Enums & Constants"
echo "  👉 Run: flutter analyze"
echo "  👉 Then run: bash step2_services.sh"
echo "============================================"
