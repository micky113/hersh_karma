import 'karma_category.dart';

enum DeedStatus {
  pending,
  verified,
  rejected,
}

class KarmaAction {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final KarmaCategory category;
  final DateTime timestamp;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final String? witnessEmail;
  final double confidenceScore; // 0.0 to 1.0 based on verification completeness
  final DeedStatus status;
  final int creditsAwarded;
  final Map<String, bool> validatorVotes; // validatorId -> vote (true = approve, false = reject)
  final String? blockchainHash; // SHA-256 hash when added to ledger
  final int scale; // Reach / recipient count
  final int rippleCredits; // Logarithmic ripple capacity credits
  final String durationCategory; // Quick, Deep, Impact
  final String impactScope; // Individual, Team, Community, City, Global
  final bool creativityBonus;
  final bool participationBonus;
  final bool rippleInspirationBonus;
  final int verificationLevel; // 1 to 5
  final int provisionalCredits;
  final int verifiedCredits;
  final int outcomeCredits;
  final bool isAudited;
  final bool auditPassed;
  final int proofBondStaked;
  final String? anonymizedWitnessCode; // vulnerability protection QR code/receipt ID
  final bool capturedInApp;
  final int evidenceScore;
  final String? beforeImageUrl;
  final int? wasteBeforeCount;
  final int? wasteAfterCount;
  final double? sceneMatchConfidence;

  KarmaAction({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    required this.category,
    required this.timestamp,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.witnessEmail,
    this.confidenceScore = 0.5,
    this.status = DeedStatus.pending,
    this.creditsAwarded = 0,
    this.validatorVotes = const {},
    this.blockchainHash,
    this.scale = 1,
    this.rippleCredits = 0,
    this.durationCategory = 'Quick',
    this.impactScope = 'Individual',
    this.creativityBonus = false,
    this.participationBonus = false,
    this.rippleInspirationBonus = false,
    this.verificationLevel = 1,
    this.provisionalCredits = 0,
    this.verifiedCredits = 0,
    this.outcomeCredits = 0,
    this.isAudited = false,
    this.auditPassed = false,
    this.proofBondStaked = 0,
    this.anonymizedWitnessCode,
    this.capturedInApp = false,
    this.evidenceScore = 0,
    this.beforeImageUrl,
    this.wasteBeforeCount,
    this.wasteAfterCount,
    this.sceneMatchConfidence,
  });

  KarmaAction copyWith({
    String? id,
    String? userId,
    String? userName,
    String? title,
    String? description,
    KarmaCategory? category,
    DateTime? timestamp,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? witnessEmail,
    double? confidenceScore,
    DeedStatus? status,
    int? creditsAwarded,
    Map<String, bool>? validatorVotes,
    String? blockchainHash,
    int? scale,
    int? rippleCredits,
    String? durationCategory,
    String? impactScope,
    bool? creativityBonus,
    bool? participationBonus,
    bool? rippleInspirationBonus,
    int? verificationLevel,
    int? provisionalCredits,
    int? verifiedCredits,
    int? outcomeCredits,
    bool? isAudited,
    bool? auditPassed,
    int? proofBondStaked,
    String? anonymizedWitnessCode,
    bool? capturedInApp,
    int? evidenceScore,
    String? beforeImageUrl,
    int? wasteBeforeCount,
    int? wasteAfterCount,
    double? sceneMatchConfidence,
  }) {
    return KarmaAction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      witnessEmail: witnessEmail ?? this.witnessEmail,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      status: status ?? this.status,
      creditsAwarded: creditsAwarded ?? this.creditsAwarded,
      validatorVotes: validatorVotes ?? this.validatorVotes,
      blockchainHash: blockchainHash ?? this.blockchainHash,
      scale: scale ?? this.scale,
      rippleCredits: rippleCredits ?? this.rippleCredits,
      durationCategory: durationCategory ?? this.durationCategory,
      impactScope: impactScope ?? this.impactScope,
      creativityBonus: creativityBonus ?? this.creativityBonus,
      participationBonus: participationBonus ?? this.participationBonus,
      rippleInspirationBonus: rippleInspirationBonus ?? this.rippleInspirationBonus,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      provisionalCredits: provisionalCredits ?? this.provisionalCredits,
      verifiedCredits: verifiedCredits ?? this.verifiedCredits,
      outcomeCredits: outcomeCredits ?? this.outcomeCredits,
      isAudited: isAudited ?? this.isAudited,
      auditPassed: auditPassed ?? this.auditPassed,
      proofBondStaked: proofBondStaked ?? this.proofBondStaked,
      anonymizedWitnessCode: anonymizedWitnessCode ?? this.anonymizedWitnessCode,
      capturedInApp: capturedInApp ?? this.capturedInApp,
      evidenceScore: evidenceScore ?? this.evidenceScore,
      beforeImageUrl: beforeImageUrl ?? this.beforeImageUrl,
      wasteBeforeCount: wasteBeforeCount ?? this.wasteBeforeCount,
      wasteAfterCount: wasteAfterCount ?? this.wasteAfterCount,
      sceneMatchConfidence: sceneMatchConfidence ?? this.sceneMatchConfidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'title': title,
      'description': description,
      'category': category.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'witnessEmail': witnessEmail,
      'confidenceScore': confidenceScore,
      'status': status.name,
      'creditsAwarded': creditsAwarded,
      'validatorVotes': validatorVotes,
      'blockchainHash': blockchainHash,
      'scale': scale,
      'rippleCredits': rippleCredits,
      'durationCategory': durationCategory,
      'impactScope': impactScope,
      'creativityBonus': creativityBonus,
      'participationBonus': participationBonus,
      'rippleInspirationBonus': rippleInspirationBonus,
      'verificationLevel': verificationLevel,
      'provisionalCredits': provisionalCredits,
      'verifiedCredits': verifiedCredits,
      'outcomeCredits': outcomeCredits,
      'isAudited': isAudited,
      'auditPassed': auditPassed,
      'proofBondStaked': proofBondStaked,
      'anonymizedWitnessCode': anonymizedWitnessCode,
      'capturedInApp': capturedInApp,
      'evidenceScore': evidenceScore,
      'beforeImageUrl': beforeImageUrl,
      'wasteBeforeCount': wasteBeforeCount,
      'wasteAfterCount': wasteAfterCount,
      'sceneMatchConfidence': sceneMatchConfidence,
    };
  }

  factory KarmaAction.fromJson(Map<String, dynamic> json) {
    return KarmaAction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? 'Anonymous',
      title: json['title'] as String,
      description: json['description'] as String,
      category: KarmaCategory.fromJson(json['category'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      imageUrl: json['imageUrl'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      witnessEmail: json['witnessEmail'] as String?,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.5,
      status: DeedStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => DeedStatus.pending,
      ),
      creditsAwarded: json['creditsAwarded'] as int? ?? 0,
      validatorVotes: Map<String, bool>.from(json['validatorVotes'] ?? {}),
      blockchainHash: json['blockchainHash'] as String?,
      scale: json['scale'] as int? ?? 1,
      rippleCredits: json['rippleCredits'] as int? ?? 0,
      durationCategory: json['durationCategory'] as String? ?? 'Quick',
      impactScope: json['impactScope'] as String? ?? 'Individual',
      creativityBonus: json['creativityBonus'] as bool? ?? false,
      participationBonus: json['participationBonus'] as bool? ?? false,
      rippleInspirationBonus: json['rippleInspirationBonus'] as bool? ?? false,
      verificationLevel: json['verificationLevel'] as int? ?? 1,
      provisionalCredits: json['provisionalCredits'] as int? ?? 0,
      verifiedCredits: json['verifiedCredits'] as int? ?? 0,
      outcomeCredits: json['outcomeCredits'] as int? ?? 0,
      isAudited: json['isAudited'] as bool? ?? false,
      auditPassed: json['auditPassed'] as bool? ?? false,
      proofBondStaked: json['proofBondStaked'] as int? ?? 0,
      anonymizedWitnessCode: json['anonymizedWitnessCode'] as String?,
      capturedInApp: json['capturedInApp'] as bool? ?? false,
      evidenceScore: json['evidenceScore'] as int? ?? 0,
      beforeImageUrl: json['beforeImageUrl'] as String?,
      wasteBeforeCount: json['wasteBeforeCount'] as int?,
      wasteAfterCount: json['wasteAfterCount'] as int?,
      sceneMatchConfidence: (json['sceneMatchConfidence'] as num?)?.toDouble(),
    );
  }
}
