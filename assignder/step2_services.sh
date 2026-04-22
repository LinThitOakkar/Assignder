#!/bin/bash

# ============================================
#   Assignder - Step 2: Services
#   Run from inside your assignder project folder
#   bash step2_services.sh
# ============================================

set -e

echo "📝 Writing Services..."

# ─── auth_service.dart ────────────────────────────────────────────────────────
cat > lib/core/services/auth_service.dart << 'EOF'
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Register with email and password
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Update display name
  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
EOF

echo "✅ AuthService written!"

# ─── firestore_service.dart ───────────────────────────────────────────────────
cat > lib/core/services/firestore_service.dart << 'EOF'
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/assignment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── User ────────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('users');

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _usersRef.doc(userId);

  // Create user document on registration
  Future<void> createUser(UserModel user) async {
    await _userDoc(user.userId).set(user.toMap());
  }

  // Get user document once
  Future<UserModel?> getUser(String userId) async {
    final doc = await _userDoc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(userId, doc.data()!);
  }

  // Update user settings
  Future<void> updateUserSettings(
      String userId, Map<String, dynamic> settings) async {
    await _userDoc(userId).update({'settings': settings});
  }

  // Update user name
  Future<void> updateUserName(String userId, String name) async {
    await _userDoc(userId).update({'name': name});
  }

  // ─── Assignments ─────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _assignmentsRef(String userId) =>
      _userDoc(userId).collection('assignments');

  DocumentReference<Map<String, dynamic>> _assignmentDoc(
          String userId, String assignmentId) =>
      _assignmentsRef(userId).doc(assignmentId);

  // Stream of all assignments for a user
  Stream<List<AssignmentModel>> streamAssignments(String userId) {
    return _assignmentsRef(userId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AssignmentModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get single assignment
  Future<AssignmentModel?> getAssignment(
      String userId, String assignmentId) async {
    final doc = await _assignmentDoc(userId, assignmentId).get();
    if (!doc.exists || doc.data() == null) return null;
    return AssignmentModel.fromMap(doc.id, doc.data()!);
  }

  // Add new assignment
  Future<String> addAssignment(
      String userId, AssignmentModel assignment) async {
    final docRef = _assignmentsRef(userId).doc();
    final newAssignment = assignment.copyWith(assignmentId: docRef.id);
    await docRef.set(newAssignment.toMap());
    return docRef.id;
  }

  // Update assignment
  Future<void> updateAssignment(
      String userId, AssignmentModel assignment) async {
    await _assignmentDoc(userId, assignment.assignmentId)
        .update(assignment.toMap());
  }

  // Delete assignment
  Future<void> deleteAssignment(
      String userId, String assignmentId) async {
    await _assignmentDoc(userId, assignmentId).delete();
  }

  // Toggle submitted status
  Future<void> toggleSubmitted(
      String userId, String assignmentId, bool isSubmitted) async {
    await _assignmentDoc(userId, assignmentId).update({
      'status': isSubmitted ? 'submitted' : 'pending',
      'submittedAt': isSubmitted ? Timestamp.fromDate(DateTime.now()) : null,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
EOF

echo "✅ FirestoreService written!"

# ─── notification_service.dart ────────────────────────────────────────────────
cat > lib/core/services/notification_service.dart << 'EOF'
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/assignment_model.dart';
import '../constants/reminder_options.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Schedule notifications for an assignment based on reminder offsets
  Future<void> scheduleAssignmentReminders(AssignmentModel assignment) async {
    if (!assignment.reminder.enabled) return;

    // Cancel existing notifications for this assignment first
    await cancelAssignmentReminders(assignment.assignmentId);

    for (final offset in assignment.reminder.offsets) {
      final duration = ReminderOptions.getDuration(offset);
      final scheduledTime = assignment.dueDate.subtract(duration);

      // Only schedule if the time is in the future
      if (scheduledTime.isAfter(DateTime.now())) {
        final notificationId = _generateNotificationId(
          assignment.assignmentId,
          offset,
        );

        await _plugin.zonedSchedule(
          notificationId,
          '📚 Assignment Due Soon!',
          '${assignment.title} is due in ${ReminderOptions.getLabel(offset)}',
          tz.TZDateTime.from(scheduledTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'assignment_reminders',
              'Assignment Reminders',
              channelDescription: 'Reminders for upcoming assignments',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  // Cancel all notifications for a specific assignment
  Future<void> cancelAssignmentReminders(String assignmentId) async {
    for (final offset in ReminderOptions.all) {
      final notificationId = _generateNotificationId(assignmentId, offset);
      await _plugin.cancel(notificationId);
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  // Generate a unique int ID from assignmentId + offset
  int _generateNotificationId(String assignmentId, String offset) {
    return '${assignmentId}_$offset'.hashCode.abs() % 100000;
  }
}
EOF

echo "✅ NotificationService written!"
echo ""
echo "============================================"
echo "  ✅ Step 2 Complete — Services"
echo "  👉 Run: flutter analyze"
echo "  👉 Then run: bash step3_providers.sh"
echo "============================================"
