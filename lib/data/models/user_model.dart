import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;
  final String? messId;
  final List<String> messIds;
  final DateTime? createdAt;
  final Color? customAvatarBgColor;
  final Color? customAvatarTextColor;

  const UserModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    required this.role,
    this.messId,
    this.messIds = const [],
    this.createdAt,
    this.customAvatarBgColor,
    this.customAvatarTextColor,
  });

  // Backward compatibility & convenience getters
  String get userId => id;
  String get name => fullName;
  bool get isOwner => role.trim().toLowerCase() == 'owner';
  bool get isMember => role.trim().toLowerCase() == 'member';

  String get initials => extractInitials(fullName);

  Color get avatarBgColor => customAvatarBgColor ?? _palette[0].$1;
  Color get avatarTextColor => customAvatarTextColor ?? _palette[0].$2;

  static final List<(Color, Color)> _palette = [
    (Colors.red.shade50, Colors.red.shade700),
    (Colors.orange.shade50, Colors.orange.shade800),
    (Colors.green.shade50, Colors.green.shade800),
    (Colors.blue.shade50, Colors.blue.shade800),
    (Colors.purple.shade50, Colors.purple.shade800),
    (Colors.teal.shade50, Colors.teal.shade800),
    (Colors.pink.shade50, Colors.pink.shade800),
  ];

  static String extractInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'M';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static (Color, Color) avatarColorPair(int index) {
    return _palette[index % _palette.length];
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? messId,
    List<String>? messIds,
    DateTime? createdAt,
    Color? customAvatarBgColor,
    Color? customAvatarTextColor,
    String? userId,
    String? name,
  }) {
    return UserModel(
      id: id ?? userId ?? this.id,
      fullName: fullName ?? name ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      messId: messId ?? this.messId,
      messIds: messIds ?? this.messIds,
      createdAt: createdAt ?? this.createdAt,
      customAvatarBgColor: customAvatarBgColor ?? this.customAvatarBgColor,
      customAvatarTextColor: customAvatarTextColor ?? this.customAvatarTextColor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'role': role,
      if (messId != null) 'mess_id': messId,
      'messIds': messIds,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      // Legacy compatibility keys
      'userId': id,
      'name': fullName,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {int index = 0}) {
    DateTime? parsedCreatedAt;
    final rawDate = map['created_at'] ?? map['createdAt'];
    if (rawDate != null) {
      if (rawDate is DateTime) {
        parsedCreatedAt = rawDate;
      } else if (rawDate is String) {
        parsedCreatedAt = DateTime.tryParse(rawDate);
      }
    }

    final id = (map['id'] ?? map['userId'] ?? index.toString()).toString();
    final rawName = (map['full_name'] ?? map['name'] ?? map['fullName']) as String?;
    final role = (map['role'] ?? 'member').toString();
    final messId = (map['mess_id'] ?? map['messId'])?.toString();

    final name = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : (role.isNotEmpty ? 'Member (${role.toUpperCase()})' : 'Active Member');

    List<String> messList = [];
    if (map['messIds'] is List) {
      messList = (map['messIds'] as List).map((e) => e.toString()).toList();
    } else if (messId != null && messId.isNotEmpty) {
      messList = [messId];
    }

    final colorPair = avatarColorPair(index);

    return UserModel(
      id: id,
      fullName: name,
      email: map['email']?.toString(),
      phone: map['phone']?.toString(),
      role: role,
      messId: messId,
      messIds: messList,
      createdAt: parsedCreatedAt,
      customAvatarBgColor: colorPair.$1,
      customAvatarTextColor: colorPair.$2,
    );
  }
}

/// Backward compatibility aliases
typedef MemberModel = UserModel;
typedef MemberData = UserModel;
