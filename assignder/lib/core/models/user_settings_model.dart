class UserSettings {
  final bool notificationsEnabled;
  final List<String> defaultReminderOffsets;

  const UserSettings({
    required this.notificationsEnabled,
    required this.defaultReminderOffsets,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      defaultReminderOffsets:
          List<String>.from(map['defaultReminderOffsets'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'defaultReminderOffsets': defaultReminderOffsets,
    };
  }

  UserSettings copyWith({
    bool? notificationsEnabled,
    List<String>? defaultReminderOffsets,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultReminderOffsets:
          defaultReminderOffsets ?? this.defaultReminderOffsets,
    );
  }

  factory UserSettings.defaults() {
    return const UserSettings(
      notificationsEnabled: true,
      defaultReminderOffsets: ['24h_before', '2h_before'],
    );
  }
}
