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
    await _userDoc(user.userId).set(user.toMap(), SetOptions(merge: true));
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

  // Delete user document and all assignment documents under it
  Future<void> deleteUserData(String userId) async {
    final assignmentsSnapshot = await _assignmentsRef(userId).get();
    const batchSize = 400;

    for (var i = 0; i < assignmentsSnapshot.docs.length; i += batchSize) {
      final batch = _db.batch();
      final end = i + batchSize < assignmentsSnapshot.docs.length
          ? i + batchSize
          : assignmentsSnapshot.docs.length;

      for (final doc in assignmentsSnapshot.docs.sublist(i, end)) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    }

    await _userDoc(userId).delete();
  }

  Future<void> addUserDeviceToken(String userId, String token) async {
    await _userDoc(userId).set({
      'deviceTokens': FieldValue.arrayUnion([token]),
      'lastPushTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeUserDeviceToken(String userId, String token) async {
    await _userDoc(userId).set({
      'deviceTokens': FieldValue.arrayRemove([token]),
      'lastPushTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
    final data = newAssignment.toMap()
      ..['sentReminderOffsets'] = []
      ..['lastReminderSentAt'] = null;
    await docRef.set(data);
    return docRef.id;
  }

  // Update assignment
  Future<void> updateAssignment(
      String userId, AssignmentModel assignment) async {
    final data = assignment.toMap()
      ..['sentReminderOffsets'] = []
      ..['lastReminderSentAt'] = null;
    await _assignmentDoc(userId, assignment.assignmentId).update(data);
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
      if (!isSubmitted) 'sentReminderOffsets': [],
      if (!isSubmitted) 'lastReminderSentAt': null,
    });
  }
}
