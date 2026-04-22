#!/bin/bash

# ============================================
#   Assignder - Step 3: Providers
#   Run from inside your assignder project folder
#   bash step3_providers.sh
# ============================================

set -e

echo "📝 Writing Providers..."

# ─── auth_provider.dart ───────────────────────────────────────────────────────
cat > lib/core/providers/auth_provider.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/user_settings_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _status = AuthStatus.unknown;
  User? _firebaseUser;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) {
      _firebaseUser = user;
      _status = user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.signInWithEmail(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      _setLoading(false);
      return false;
    }
  }

  // Register with email and password
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _authService.registerWithEmail(
        email: email,
        password: password,
      );
      // Create user document in Firestore
      if (credential.user != null) {
        final user = UserModel(
          userId: credential.user!.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
          settings: UserSettings.defaults(),
        );
        await _firestoreService.createUser(user);
        await _authService.updateDisplayName(name);
      }
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      _setLoading(false);
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        _setLoading(false);
        return false;
      }
      // Create user doc if first time Google sign in
      if (credential.additionalUserInfo?.isNewUser == true &&
          credential.user != null) {
        final user = UserModel(
          userId: credential.user!.uid,
          name: credential.user!.displayName ?? '',
          email: credential.user!.email ?? '',
          createdAt: DateTime.now(),
          settings: UserSettings.defaults(),
        );
        await _firestoreService.createUser(user);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Google sign in failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Map Firebase error codes to user-friendly messages
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
EOF

echo "✅ AuthProvider written!"

# ─── user_provider.dart ───────────────────────────────────────────────────────
cat > lib/core/providers/user_provider.dart << 'EOF'
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/user_settings_model.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Load user from Firestore
  Future<void> loadUser(String userId) async {
    _setLoading(true);
    try {
      _user = await _firestoreService.getUser(userId);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load user data.');
      _setLoading(false);
    }
  }

  // Update display name
  Future<bool> updateName(String name) async {
    if (_user == null) return false;
    _setLoading(true);
    try {
      await _firestoreService.updateUserName(_user!.userId, name);
      await _authService.updateDisplayName(name);
      _user = _user!.copyWith(name: name);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update name.');
      _setLoading(false);
      return false;
    }
  }

  // Update password
  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    try {
      await _authService.updatePassword(newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update password.');
      _setLoading(false);
      return false;
    }
  }

  // Update notification settings
  Future<bool> updateSettings(UserSettings settings) async {
    if (_user == null) return false;
    _setLoading(true);
    try {
      await _firestoreService.updateUserSettings(
        _user!.userId,
        settings.toMap(),
      );
      _user = _user!.copyWith(settings: settings);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update settings.');
      _setLoading(false);
      return false;
    }
  }

  // Clear user data on logout
  void clearUser() {
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }
}
EOF

echo "✅ UserProvider written!"

# ─── assignment_provider.dart ─────────────────────────────────────────────────
cat > lib/core/providers/assignment_provider.dart << 'EOF'
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../models/assignment_model.dart';
import '../enums/assignment_status.dart';

class AssignmentProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  List<AssignmentModel> _assignments = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<AssignmentModel>>? _subscription;

  List<AssignmentModel> get assignments => _assignments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filtered lists using computedStatus
  List<AssignmentModel> get activeAssignments => _assignments
      .where((a) => a.computedStatus != AssignmentStatus.submitted)
      .toList();

  List<AssignmentModel> get overdueAssignments => _assignments
      .where((a) => a.computedStatus == AssignmentStatus.overdue)
      .toList();

  List<AssignmentModel> get upcomingAssignments => _assignments
      .where((a) => a.computedStatus == AssignmentStatus.pending)
      .toList();

  List<AssignmentModel> get submittedAssignments => _assignments
      .where((a) => a.computedStatus == AssignmentStatus.submitted)
      .toList();

  // Stats for Profile screen
  int get activeCount => activeAssignments.length;
  int get completedCount => submittedAssignments.length;
  double get completionRate => _assignments.isEmpty
      ? 0
      : (completedCount / _assignments.length) * 100;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Start listening to assignments stream from Firestore
  void startListening(String userId) {
    _setLoading(true);
    _subscription = _firestoreService.streamAssignments(userId).listen(
      (assignments) {
        _assignments = assignments;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to load assignments.');
        _setLoading(false);
      },
    );
  }

  // Stop listening (on logout)
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _assignments = [];
    notifyListeners();
  }

  // Add new assignment
  Future<bool> addAssignment(String userId, AssignmentModel assignment) async {
    try {
      final id = await _firestoreService.addAssignment(userId, assignment);
      final savedAssignment = assignment.copyWith(assignmentId: id);
      await _notificationService.scheduleAssignmentReminders(savedAssignment);
      return true;
    } catch (e) {
      _setError('Failed to add assignment.');
      return false;
    }
  }

  // Update assignment
  Future<bool> updateAssignment(
      String userId, AssignmentModel assignment) async {
    try {
      final updated = assignment.copyWith(updatedAt: DateTime.now());
      await _firestoreService.updateAssignment(userId, updated);
      await _notificationService.scheduleAssignmentReminders(updated);
      return true;
    } catch (e) {
      _setError('Failed to update assignment.');
      return false;
    }
  }

  // Delete assignment
  Future<bool> deleteAssignment(
      String userId, String assignmentId) async {
    try {
      await _firestoreService.deleteAssignment(userId, assignmentId);
      await _notificationService.cancelAssignmentReminders(assignmentId);
      return true;
    } catch (e) {
      _setError('Failed to delete assignment.');
      return false;
    }
  }

  // Toggle submitted / unsubmitted (Option B)
  Future<bool> toggleSubmitted(
      String userId, String assignmentId, bool isSubmitted) async {
    try {
      await _firestoreService.toggleSubmitted(userId, assignmentId, isSubmitted);
      // Cancel reminders if submitted, reschedule if unsubmitted
      if (isSubmitted) {
        await _notificationService.cancelAssignmentReminders(assignmentId);
      } else {
        final assignment = _assignments.firstWhere(
          (a) => a.assignmentId == assignmentId,
          orElse: () => throw Exception('Assignment not found'),
        );
        await _notificationService.scheduleAssignmentReminders(assignment);
      }
      return true;
    } catch (e) {
      _setError('Failed to update assignment status.');
      return false;
    }
  }

  // Get single assignment by ID
  AssignmentModel? getAssignmentById(String assignmentId) {
    try {
      return _assignments.firstWhere((a) => a.assignmentId == assignmentId);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
EOF

echo "✅ AssignmentProvider written!"
echo ""
echo "============================================"
echo "  ✅ Step 3 Complete — Providers"
echo "  👉 Run: flutter analyze"
echo "  👉 Then run: bash step4_router.sh"
echo "============================================"
