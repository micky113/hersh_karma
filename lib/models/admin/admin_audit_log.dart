import 'admin_role.dart';

class AdminAuditLogEntry {
  final String id;
  final String adminId;
  final String adminName;
  final AdminRole adminRole;
  final String actionCategory; // 'verification', 'karma_adjustment', 'org_approval', 'fraud_resolution', 'moderation', 'role_change'
  final String actionDescription;
  final String targetId;
  final String targetType; // 'action', 'user', 'organization', 'problem_report', 'wish', 'fraud_alert'
  final String reason; // Mandatory justification
  final Map<String, dynamic> previousState;
  final Map<String, dynamic> newState;
  final DateTime timestamp;
  final String ipAddress;

  const AdminAuditLogEntry({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.adminRole,
    required this.actionCategory,
    required this.actionDescription,
    required this.targetId,
    required this.targetType,
    required this.reason,
    this.previousState = const {},
    this.newState = const {},
    required this.timestamp,
    this.ipAddress = '127.0.0.1 (Secured Admin Console)',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'adminId': adminId,
    'adminName': adminName,
    'adminRole': adminRole.name,
    'actionCategory': actionCategory,
    'actionDescription': actionDescription,
    'targetId': targetId,
    'targetType': targetType,
    'reason': reason,
    'previousState': previousState,
    'newState': newState,
    'timestamp': timestamp.toIso8601String(),
    'ipAddress': ipAddress,
  };

  factory AdminAuditLogEntry.fromJson(Map<String, dynamic> json) => AdminAuditLogEntry(
    id: json['id'] as String,
    adminId: json['adminId'] as String,
    adminName: json['adminName'] as String,
    adminRole: AdminRole.values.firstWhere(
      (r) => r.name == json['adminRole'],
      orElse: () => AdminRole.superAdmin,
    ),
    actionCategory: json['actionCategory'] as String,
    actionDescription: json['actionDescription'] as String,
    targetId: json['targetId'] as String,
    targetType: json['targetType'] as String,
    reason: json['reason'] as String,
    previousState: (json['previousState'] as Map<String, dynamic>?) ?? const {},
    newState: (json['newState'] as Map<String, dynamic>?) ?? const {},
    timestamp: DateTime.parse(json['timestamp'] as String),
    ipAddress: json['ipAddress'] as String? ?? '127.0.0.1',
  );
}
