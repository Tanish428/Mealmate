class UserModel {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final List messIds;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.messIds,
  });

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? role,
    List? messIds,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      messIds: messIds ?? this.messIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'messIds': messIds,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      role: map['role'] as String,
      messIds: map['messIds'] as List,
    );
  }
}