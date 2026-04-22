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
