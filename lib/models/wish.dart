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
  final String description; // e.g. "Contributed 100 Karma", "I'll offer free guitar lessons"
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
    );
  }
}
