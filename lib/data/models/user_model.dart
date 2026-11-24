enum UserRole {
  customer,
  admin,
  manager;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      default:
        return UserRole.customer;
    }
  }
}

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final UserRole role;
  final String preferredLanguage;
  final String preferredCurrency;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.role = UserRole.customer,
    this.preferredLanguage = 'en',
    this.preferredCurrency = 'USD',
    this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin || role == UserRole.manager;

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    UserRole? role,
    String? preferredLanguage,
    String? preferredCurrency,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'VIP Customer',
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.fromString(json['role'] as String?),
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      preferredCurrency: json['preferred_currency'] as String? ?? 'USD',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'role': role.name,
      'preferred_language': preferredLanguage,
      'preferred_currency': preferredCurrency,
    };
  }
}
