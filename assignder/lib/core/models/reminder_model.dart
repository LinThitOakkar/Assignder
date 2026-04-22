class ReminderModel {
  final bool enabled;
  final List<String> offsets;

  const ReminderModel({
    required this.enabled,
    required this.offsets,
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      enabled: map['enabled'] as bool? ?? true,
      offsets: List<String>.from(map['offsets'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'offsets': offsets,
    };
  }

  ReminderModel copyWith({
    bool? enabled,
    List<String>? offsets,
  }) {
    return ReminderModel(
      enabled: enabled ?? this.enabled,
      offsets: offsets ?? this.offsets,
    );
  }
}
