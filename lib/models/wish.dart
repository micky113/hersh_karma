enum WishCategory {
  education('Education', '📚'),
  career('Career', '💼'),
  travel('Travel', '✈️'),
  creativity('Creativity', '🎨'),
  health('Health/Well-being', '🩺'),
  family('Family', '👪'),
  entrepreneurship('Entrepreneurship', '🚀'),
  community('Community', '🏛️'),
  experience('Experience', '🌟'),
  socialImpact('Social Impact', '🌍');

  final String label;
  final String icon;
  const WishCategory(this.label, this.icon);
}

enum WishStatus {
  active('Active'),
  fulfilled('Fulfilled');

  final String label;
  const WishStatus(this.label);
}

enum PrivacyLevel {
  public('Public'),
  communityOnly('Community Only'),
  private('Private');

  final String label;
  const PrivacyLevel(this.label);
}

enum SponsorshipType {
  directItemPurchase('Direct Item Purchase (Retailer)'),
  serviceProviderPayment('Service Provider Payment'),
  volunteerService('Volunteer / Mentorship');

  final String label;
  const SponsorshipType(this.label);
}

class WishMilestone {
  final String title;
  final double percentage; // e.g. 0.20
  final double amount; // calculated target contribution portion
  final String status; // 'pending', 'released', 'completed'

  WishMilestone({
    required this.title,
    required this.percentage,
    required this.amount,
    this.status = 'pending',
  });

  WishMilestone copyWith({
    String? title,
    double? percentage,
    double? amount,
    String? status,
  }) {
    return WishMilestone(
      title: title ?? this.title,
      percentage: percentage ?? this.percentage,
      amount: amount ?? this.amount,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'percentage': percentage,
      'amount': amount,
      'status': status,
    };
  }

  factory WishMilestone.fromJson(Map<String, dynamic> json) {
    return WishMilestone(
      title: json['title'] as String,
      percentage: (json['percentage'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
    );
  }
}

class WishPlanStep {
  final String title;
  final bool isCompleted;

  WishPlanStep({
    required this.title,
    this.isCompleted = false,
  });

  WishPlanStep copyWith({
    String? title,
    bool? isCompleted,
  }) {
    return WishPlanStep(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory WishPlanStep.fromJson(Map<String, dynamic> json) {
    return WishPlanStep(
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class SponsorContribution {
  final String sponsorName;
  final String description; // e.g. "Contributed 100 Karma to Croma Store for device stock"
  final DateTime timestamp;

  SponsorContribution({
    required this.sponsorName,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'sponsorName': sponsorName,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SponsorContribution.fromJson(Map<String, dynamic> json) {
    return SponsorContribution(
      sponsorName: json['sponsorName'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class Wish {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final WishCategory category;
  final WishStatus status;
  final int karmaTarget;
  final int karmaRaised;
  final List<WishPlanStep> wishPlan;
  final List<SponsorContribution> sponsorContributions;
  final DateTime createdAt;

  // New trust & safety fields
  final int verificationLevel; // 1 to 4
  final PrivacyLevel privacyLevel;
  final int wishTrustScore; // 0 to 100
  final List<String> evidenceDocumentUrls;
  final bool isIdentityVerified;
  final bool ageConsentVerified;
  final SponsorshipType sponsorshipType;
  final List<WishMilestone> milestones;
  final String? retailerName;
  final bool isReported;

  Wish({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    required this.category,
    this.status = WishStatus.active,
    required this.karmaTarget,
    this.karmaRaised = 0,
    required this.wishPlan,
    this.sponsorContributions = const [],
    required this.createdAt,
    this.verificationLevel = 1,
    this.privacyLevel = PrivacyLevel.public,
    this.wishTrustScore = 50,
    this.evidenceDocumentUrls = const [],
    this.isIdentityVerified = false,
    this.ageConsentVerified = false,
    this.sponsorshipType = SponsorshipType.volunteerService,
    this.milestones = const [],
    this.retailerName,
    this.isReported = false,
  });

  Wish copyWith({
    String? id,
    String? userId,
    String? userName,
    String? title,
    String? description,
    WishCategory? category,
    WishStatus? status,
    int? karmaTarget,
    int? karmaRaised,
    List<WishPlanStep>? wishPlan,
    List<SponsorContribution>? sponsorContributions,
    DateTime? createdAt,
    int? verificationLevel,
    PrivacyLevel? privacyLevel,
    int? wishTrustScore,
    List<String>? evidenceDocumentUrls,
    bool? isIdentityVerified,
    bool? ageConsentVerified,
    SponsorshipType? sponsorshipType,
    List<WishMilestone>? milestones,
    String? retailerName,
    bool? isReported,
  }) {
    return Wish(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      karmaTarget: karmaTarget ?? this.karmaTarget,
      karmaRaised: karmaRaised ?? this.karmaRaised,
      wishPlan: wishPlan ?? this.wishPlan,
      sponsorContributions: sponsorContributions ?? this.sponsorContributions,
      createdAt: createdAt ?? this.createdAt,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      wishTrustScore: wishTrustScore ?? this.wishTrustScore,
      evidenceDocumentUrls: evidenceDocumentUrls ?? this.evidenceDocumentUrls,
      isIdentityVerified: isIdentityVerified ?? this.isIdentityVerified,
      ageConsentVerified: ageConsentVerified ?? this.ageConsentVerified,
      sponsorshipType: sponsorshipType ?? this.sponsorshipType,
      milestones: milestones ?? this.milestones,
      retailerName: retailerName ?? this.retailerName,
      isReported: isReported ?? this.isReported,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'title': title,
      'description': description,
      'category': category.name,
      'status': status.name,
      'karmaTarget': karmaTarget,
      'karmaRaised': karmaRaised,
      'wishPlan': wishPlan.map((e) => e.toJson()).toList(),
      'sponsorContributions': sponsorContributions.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'verificationLevel': verificationLevel,
      'privacyLevel': privacyLevel.name,
      'wishTrustScore': wishTrustScore,
      'evidenceDocumentUrls': evidenceDocumentUrls,
      'isIdentityVerified': isIdentityVerified,
      'ageConsentVerified': ageConsentVerified,
      'sponsorshipType': sponsorshipType.name,
      'milestones': milestones.map((e) => e.toJson()).toList(),
      'retailerName': retailerName,
      'isReported': isReported,
    };
  }

  factory Wish.fromJson(Map<String, dynamic> json) {
    return Wish(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: WishCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => WishCategory.experience,
      ),
      status: WishStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WishStatus.active,
      ),
      karmaTarget: json['karmaTarget'] as int? ?? 1000,
      karmaRaised: json['karmaRaised'] as int? ?? 0,
      wishPlan: (json['wishPlan'] as List? ?? [])
          .map((e) => WishPlanStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      sponsorContributions: (json['sponsorContributions'] as List? ?? [])
          .map((e) => SponsorContribution.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      verificationLevel: json['verificationLevel'] as int? ?? 1,
      privacyLevel: PrivacyLevel.values.firstWhere(
        (e) => e.name == json['privacyLevel'],
        orElse: () => PrivacyLevel.public,
      ),
      wishTrustScore: json['wishTrustScore'] as int? ?? 50,
      evidenceDocumentUrls: List<String>.from(json['evidenceDocumentUrls'] ?? []),
      isIdentityVerified: json['isIdentityVerified'] as bool? ?? false,
      ageConsentVerified: json['ageConsentVerified'] as bool? ?? false,
      sponsorshipType: SponsorshipType.values.firstWhere(
        (e) => e.name == json['sponsorshipType'],
        orElse: () => SponsorshipType.volunteerService,
      ),
      milestones: (json['milestones'] as List? ?? [])
          .map((e) => WishMilestone.fromJson(e as Map<String, dynamic>))
          .toList(),
      retailerName: json['retailerName'] as String?,
      isReported: json['isReported'] as bool? ?? false,
    );
  }
}
