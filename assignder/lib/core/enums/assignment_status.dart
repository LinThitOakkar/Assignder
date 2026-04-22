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
