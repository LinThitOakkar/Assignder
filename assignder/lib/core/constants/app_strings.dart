class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Assignder';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
    static const String loginSubtitle =
            'Sign in to manage your assignments and reminders.';
    static const String noAccountPrompt = 'Don\'t have an account?';
    static const String createAccountCta = 'Create one';
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
    static const String deleteAccount = 'Delete Account';
    static const String deleteAccountTitle = 'Delete Account?';
    static const String deleteAccountMessage =
            'This will permanently remove your account, assignments, and settings. This action cannot be undone.';

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
