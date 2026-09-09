enum FraudSeverity {
  low,
  medium,
  high,
  critical
}

enum FraudStatus {
  pendingReview,
  investigating,
  dismissed,
  penalized,
  appealed
}

class FraudAlert {
  final String id;
  final String userId;
  final String userName;
  final String? deedId;
  final String alertType; // 'duplicate_image_hash', 'impossible_velocity', 'collusion', 'spam_reports', 'fake_org'
  final String title;
  final String description;
  final double riskScore; // 0.0 to 1.0
  final FraudSeverity severity;
  final FraudStatus status;
  final DateTime detectedAt;
  final String? resolutionReason;
  final String? resolvedByAdmin;
  final DateTime? resolvedAt;
  final Map<String, dynamic> evidenceDetails;

  const FraudAlert({
    required this.id,
    required this.userId,
    required this.userName,
    this.deedId,
    required this.alertType,
    required this.title,
    required this.description,
    required this.riskScore,
    required this.severity,
    this.status = FraudStatus.pendingReview,
    required this.detectedAt,
    this.resolutionReason,
    this.resolvedByAdmin,
    this.resolvedAt,
    this.evidenceDetails = const {},
  });

  FraudAlert copyWith({
    String? id,
    String? userId,
    String? userName,
    String? deedId,
    String? alertType,
    String? title,
    String? description,
    double? riskScore,
    FraudSeverity? severity,
    FraudStatus? status,
    DateTime? detectedAt,
    String? resolutionReason,
    String? resolvedByAdmin,
    DateTime? resolvedAt,
    Map<String, dynamic>? evidenceDetails,
  }) {
    return FraudAlert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      deedId: deedId ?? this.deedId,
      alertType: alertType ?? this.alertType,
      title: title ?? this.title,
      description: description ?? this.description,
      riskScore: riskScore ?? this.riskScore,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      detectedAt: detectedAt ?? this.detectedAt,
      resolutionReason: resolutionReason ?? this.resolutionReason,
      resolvedByAdmin: resolvedByAdmin ?? this.resolvedByAdmin,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      evidenceDetails: evidenceDetails ?? this.evidenceDetails,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'deedId': deedId,
    'alertType': alertType,
    'title': title,
    'description': description,
    'riskScore': riskScore,
    'severity': severity.name,
    'status': status.name,
    'detectedAt': detectedAt.toIso8601String(),
    'resolutionReason': resolutionReason,
    'resolvedByAdmin': resolvedByAdmin,
    'resolvedAt': resolvedAt?.toIso8601String(),
    'evidenceDetails': evidenceDetails,
  };

  factory FraudAlert.fromJson(Map<String, dynamic> json) => FraudAlert(
    id: json['id'] as String,
    userId: json['userId'] as String,
    userName: json['userName'] as String,
    deedId: json['deedId'] as String?,
    alertType: json['alertType'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    riskScore: (json['riskScore'] as num).toDouble(),
    severity: FraudSeverity.values.firstWhere(
      (s) => s.name == json['severity'],
      orElse: () => FraudSeverity.medium,
    ),
    status: FraudStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => FraudStatus.pendingReview,
    ),
    detectedAt: DateTime.parse(json['detectedAt'] as String),
    resolutionReason: json['resolutionReason'] as String?,
    resolvedByAdmin: json['resolvedByAdmin'] as String?,
    resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
    evidenceDetails: (json['evidenceDetails'] as Map<String, dynamic>?) ?? const {},
  );
}
