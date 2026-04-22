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
      if (_user == null) {
        final guestUser = UserModel(
          userId: userId,
          name: 'Guest User',
          email: 'guest@assignder.local',
          createdAt: DateTime.now(),
          settings: UserSettings.defaults(),
        );
        await _firestoreService.createUser(guestUser);
        _user = guestUser;
      }
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
    _setError('Password updates are disabled in no-login mode.');
    return false;
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
