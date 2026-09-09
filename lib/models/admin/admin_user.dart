import 'admin_role.dart';

class AdminUser {
  final String id;
  final String email;
  final String name;
  final AdminRole role;
  final String department;
  final DateTime lastLogin;
  final bool isActive;

  const AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.department = 'Trust & Governance',
    required this.lastLogin,
    this.isActive = true,
  });

  AdminUser copyWith({
    String? id,
    String? email,
    String? name,
    AdminRole? role,
    String? department,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      department: department ?? this.department,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role.name,
    'department': department,
    'lastLogin': lastLogin.toIso8601String(),
    'isActive': isActive,
  };

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String,
    role: AdminRole.values.firstWhere(
      (r) => r.name == json['role'],
      orElse: () => AdminRole.verificationAdmin,
    ),
    department: json['department'] as String? ?? 'Trust & Governance',
    lastLogin: DateTime.parse(json['lastLogin'] as String),
    isActive: json['isActive'] as bool? ?? true,
  );
}
