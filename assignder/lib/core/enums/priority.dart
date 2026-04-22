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
