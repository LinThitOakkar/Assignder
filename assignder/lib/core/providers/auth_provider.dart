import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/push_notification_service.dart';
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
  String get userId => _firebaseUser?.uid ?? '';
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) {
      final previousUserId = _firebaseUser?.uid;
      _firebaseUser = user;
      _status = user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;

      if (previousUserId != null && previousUserId != user?.uid) {
        unawaited(PushNotificationService().detachUser(previousUserId));
      }
      if (user != null) {
        unawaited(PushNotificationService().attachUser(user.uid));
      }

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
        // User cancelled the sign-in
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
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      _setLoading(false);
      return false;
    } on GoogleSignInException catch (e) {
      _setError(_mapGoogleSignInError(e.code));
      _setLoading(false);
      return false;
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
    final userId = _firebaseUser?.uid;
    if (userId != null) {
      await PushNotificationService().detachUser(userId);
    }
    await _authService.signOut();
  }

  // Delete the current account and its Firestore data
  Future<bool> deleteAccount({String? password}) async {
    final currentUser = _firebaseUser;
    if (currentUser == null) {
      _setError('No signed-in user found.');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final providerIds = currentUser.providerData
          .map((provider) => provider.providerId)
          .toSet();

      if (providerIds.contains('password')) {
        if (password == null || password.isEmpty) {
          _setError('Password is required to delete this account.');
          _setLoading(false);
          return false;
        }
        final email = currentUser.email;
        if (email == null || email.isEmpty) {
          throw FirebaseAuthException(
            code: 'invalid-email',
            message: 'Email is missing for this account.',
          );
        }
        await _authService.reauthenticateWithPassword(
          email: email,
          password: password,
        );
      } else if (providerIds.contains('google.com')) {
        await _authService.reauthenticateWithGoogle();
      }

      await _firestoreService.deleteUserData(currentUser.uid);
      await PushNotificationService().detachUser(currentUser.uid);
      await _authService.deleteCurrentUser();

      _firebaseUser = null;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapDeleteError(e));
      _setLoading(false);
      return false;
    } on GoogleSignInException catch (e) {
      _setError(_mapGoogleSignInError(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to delete account. Please try again.');
      _setLoading(false);
      return false;
    }
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

  // Map Google Sign-In error codes to user-friendly messages
  String _mapGoogleSignInError(GoogleSignInExceptionCode code) {
    switch (code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Google Sign-In was cancelled by the device credential flow. If you selected an account, check Google Play Services and your Firebase SHA keys.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google Sign-In UI is not available.';
      case GoogleSignInExceptionCode.interrupted:
        return 'Sign in was interrupted. Please try again.';
      default:
        return 'Google sign in failed. Please try again.';
    }
  }

  String _mapDeleteError(FirebaseAuthException e) {
    switch (e.code) {
      case 'requires-recent-login':
        return 'Please sign in again before deleting your account.';
      case 'user-mismatch':
        return 'The account could not be verified. Please sign in again.';
      case 'invalid-credential':
        return 'The account credentials are no longer valid. Please try again.';
      default:
        return _mapFirebaseError(e.code);
    }
  }
}
