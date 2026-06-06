class AuthProfile {
  final String id;
  final String phone;
  final String? email;
  final String displayName;
  final String businessName;
  final String role;
  final String createdBy;
  final bool isActive;
  final DateTime createdAt;

  AuthProfile({
    required this.id,
    required this.phone,
    this.email,
    required this.displayName,
    required this.businessName,
    required this.role,
    required this.createdBy,
    required this.isActive,
    required this.createdAt,
  });

  factory AuthProfile.fromMap(Map<String, dynamic> map) {
    return AuthProfile(
      id: map['id'],
      phone: map['phone'],
      email: map['email'],
      displayName: map['display_name'],
      businessName: map['business_name'],
      role: map['role'] ?? 'employee',
      createdBy: map['created_by'],
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  bool get isOwner => role == 'owner';
}
