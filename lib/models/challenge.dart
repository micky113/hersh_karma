import 'karma_category.dart';

class KarmaChallenge {
  final String id;
  final String title;
  final String description;
  final KarmaCategory category;
  final int targetCount;
  final int currentCount;
  final int rewardCredits;
  final bool isAccepted;
  final bool isCompleted;

  KarmaChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetCount,
    this.currentCount = 0,
    required this.rewardCredits,
    this.isAccepted = false,
    this.isCompleted = false,
  });

  KarmaChallenge copyWith({
    String? id,
    String? title,
    String? description,
    KarmaCategory? category,
    int? targetCount,
    int? currentCount,
    int? rewardCredits,
    bool? isAccepted,
    bool? isCompleted,
  }) {
    return KarmaChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      rewardCredits: rewardCredits ?? this.rewardCredits,
      isAccepted: isAccepted ?? this.isAccepted,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toJson(),
      'targetCount': targetCount,
      'currentCount': currentCount,
      'rewardCredits': rewardCredits,
      'isAccepted': isAccepted,
      'isCompleted': isCompleted,
    };
  }

  factory KarmaChallenge.fromJson(Map<String, dynamic> json) {
    return KarmaChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: KarmaCategory.fromJson(json['category'] as String),
      targetCount: json['targetCount'] as int,
      currentCount: json['currentCount'] as int? ?? 0,
      rewardCredits: json['rewardCredits'] as int,
      isAccepted: json['isAccepted'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
