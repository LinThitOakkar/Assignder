import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_settings_model.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final DateTime createdAt;
  final UserSettings settings;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.settings,
  });

  factory UserModel.fromMap(String userId, Map<String, dynamic> map) {
    return UserModel(
      userId: userId,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      settings: map['settings'] != null
          ? UserSettings.fromMap(map['settings'] as Map<String, dynamic>)
          : UserSettings.defaults(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'settings': settings.toMap(),
    };
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    DateTime? createdAt,
    UserSettings? settings,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings,
    );
  }

  /// Returns initials from name e.g. "John Doe" → "JD"
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }
}
