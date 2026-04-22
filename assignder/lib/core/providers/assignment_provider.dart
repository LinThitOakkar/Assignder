import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
    _subscription?.cancel();
    _setLoading(true);
    _subscription = _firestoreService.streamAssignments(userId).listen(
      (assignments) {
        _assignments = assignments;
        _isLoading = false;
        notifyListeners();
        unawaited(_notificationService.syncAssignmentReminders(assignments));
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
    unawaited(_notificationService.cancelAllNotifications());
    notifyListeners();
  }

  // Add new assignment
  Future<bool> addAssignment(String userId, AssignmentModel assignment) async {
    _setError(null);
    try {
      final id = await _firestoreService.addAssignment(userId, assignment);
      final savedAssignment = assignment.copyWith(assignmentId: id);
      try {
        await _notificationService.scheduleAssignmentReminders(savedAssignment);
      } catch (e) {
        // Reminder scheduling should not block successful Firestore writes.
        debugPrint('Reminder scheduling failed for new assignment: $e');
      }
      return true;
    } catch (e) {
      _setError('Failed to add assignment: $e');
      return false;
    }
  }

  // Update assignment
  Future<bool> updateAssignment(
      String userId, AssignmentModel assignment) async {
    _setError(null);
    try {
      final updated = assignment.copyWith(updatedAt: DateTime.now());
      await _firestoreService.updateAssignment(userId, updated);
      try {
        await _notificationService.scheduleAssignmentReminders(updated);
      } catch (e) {
        // Reminder scheduling should not block successful Firestore writes.
        debugPrint('Reminder scheduling failed for updated assignment: $e');
      }
      return true;
    } catch (e) {
      _setError('Failed to update assignment: $e');
      return false;
    }
  }

  // Delete assignment
  Future<bool> deleteAssignment(
      String userId, String assignmentId) async {
    _setError(null);
    try {
      await _firestoreService.deleteAssignment(userId, assignmentId);
      await _notificationService.cancelAssignmentReminders(assignmentId);
      return true;
    } catch (e) {
      _setError('Failed to delete assignment: $e');
      return false;
    }
  }

  // Toggle submitted / unsubmitted (Option B)
  Future<bool> toggleSubmitted(
      String userId, String assignmentId, bool isSubmitted) async {
    _setError(null);
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
      _setError('Failed to update assignment status: $e');
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
