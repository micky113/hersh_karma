import 'karma_category.dart';

enum ProblemStatus {
  reported,
  underReview,
  assigned,
  resolved,
}

class CommunityProblem {
  final String id;
  final String reporterId;
  final String reporterName;
  final String title;
  final String description;
  final KarmaCategory category;
  final double? latitude;
  final double? longitude;
  final String? beforeImageUrl;
  final String? afterImageUrl;
  final ProblemStatus status;
  final String? resolverName;
  final int reporterReward;
  final DateTime timestamp;

  CommunityProblem({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.title,
    required this.description,
    required this.category,
    this.latitude,
    this.longitude,
    this.beforeImageUrl,
    this.afterImageUrl,
    this.status = ProblemStatus.reported,
    this.resolverName,
    this.reporterReward = 20,
    required this.timestamp,
  });

  CommunityProblem copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    String? title,
    String? description,
    KarmaCategory? category,
    double? latitude,
    double? longitude,
    String? beforeImageUrl,
    String? afterImageUrl,
    ProblemStatus? status,
    String? resolverName,
    int? reporterReward,
    DateTime? timestamp,
  }) {
    return CommunityProblem(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      beforeImageUrl: beforeImageUrl ?? this.beforeImageUrl,
      afterImageUrl: afterImageUrl ?? this.afterImageUrl,
      status: status ?? this.status,
      resolverName: resolverName ?? this.resolverName,
      reporterReward: reporterReward ?? this.reporterReward,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'title': title,
      'description': description,
      'category': category.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'beforeImageUrl': beforeImageUrl,
      'afterImageUrl': afterImageUrl,
      'status': status.name,
      'resolverName': resolverName,
      'reporterReward': reporterReward,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CommunityProblem.fromJson(Map<String, dynamic> json) {
    return CommunityProblem(
      id: json['id'],
      reporterId: json['reporterId'],
      reporterName: json['reporterName'],
      title: json['title'],
      description: json['description'],
      category: KarmaCategory.fromJson(json['category']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      beforeImageUrl: json['beforeImageUrl'],
      afterImageUrl: json['afterImageUrl'],
      status: ProblemStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => ProblemStatus.reported),
      resolverName: json['resolverName'],
      reporterReward: json['reporterReward'] ?? 20,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
