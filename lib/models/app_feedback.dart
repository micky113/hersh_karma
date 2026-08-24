import '../services/voice_service.dart';

enum FeedbackCategory {
  like,
  dontUnderstand,
  broken,
  idea
}

extension FeedbackCategoryExtension on FeedbackCategory {
  String get label {
    switch (this) {
      case FeedbackCategory.like:
        return KarmaVoice.getTranslation('feedback_like', defaultValue: '❤️ I LIKE THIS');
      case FeedbackCategory.dontUnderstand:
        return KarmaVoice.getTranslation('feedback_dont_understand', defaultValue: '😕 I DON\'T UNDERSTAND');
      case FeedbackCategory.broken:
        return KarmaVoice.getTranslation('feedback_broken', defaultValue: '🐛 SOMETHING IS WRONG');
      case FeedbackCategory.idea:
        return KarmaVoice.getTranslation('feedback_idea', defaultValue: '💡 I HAVE AN IDEA');
    }
  }
}

enum FeedbackStatus {
  suggested,
  reviewing,
  testing,
  implemented
}

class AppFeedback {
  final String id;
  final String? userId;
  final String screenContext;
  final FeedbackCategory category;
  final String details;
  final bool hasVoiceNote;
  final bool hasScreenshot;
  
  // Community Voting & Status
  final int usefulVotes;
  final int notUsefulVotes;
  final FeedbackStatus status;
  final String aiClassification; // New Feature, Usability, Accessibility, Safety, etc.
  final DateTime timestamp;

  AppFeedback({
    required this.id,
    this.userId,
    required this.screenContext,
    required this.category,
    required this.details,
    this.hasVoiceNote = false,
    this.hasScreenshot = false,
    this.usefulVotes = 0,
    this.notUsefulVotes = 0,
    this.status = FeedbackStatus.suggested,
    this.aiClassification = 'Usability',
    required this.timestamp,
  });

  AppFeedback copyWith({
    String? id,
    String? userId,
    String? screenContext,
    FeedbackCategory? category,
    String? details,
    bool? hasVoiceNote,
    bool? hasScreenshot,
    int? usefulVotes,
    int? notUsefulVotes,
    FeedbackStatus? status,
    String? aiClassification,
    DateTime? timestamp,
  }) {
    return AppFeedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      screenContext: screenContext ?? this.screenContext,
      category: category ?? this.category,
      details: details ?? this.details,
      hasVoiceNote: hasVoiceNote ?? this.hasVoiceNote,
      hasScreenshot: hasScreenshot ?? this.hasScreenshot,
      usefulVotes: usefulVotes ?? this.usefulVotes,
      notUsefulVotes: notUsefulVotes ?? this.notUsefulVotes,
      status: status ?? this.status,
      aiClassification: aiClassification ?? this.aiClassification,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'screenContext': screenContext,
      'category': category.name,
      'details': details,
      'hasVoiceNote': hasVoiceNote,
      'hasScreenshot': hasScreenshot,
      'usefulVotes': usefulVotes,
      'notUsefulVotes': notUsefulVotes,
      'status': status.name,
      'aiClassification': aiClassification,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AppFeedback.fromJson(Map<String, dynamic> json) {
    return AppFeedback(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      screenContext: json['screenContext'] as String? ?? 'Unknown',
      category: FeedbackCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => FeedbackCategory.idea,
      ),
      details: json['details'] as String? ?? '',
      hasVoiceNote: json['hasVoiceNote'] as bool? ?? false,
      hasScreenshot: json['hasScreenshot'] as bool? ?? false,
      usefulVotes: json['usefulVotes'] as int? ?? 0,
      notUsefulVotes: json['notUsefulVotes'] as int? ?? 0,
      status: FeedbackStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FeedbackStatus.suggested,
      ),
      aiClassification: json['aiClassification'] as String? ?? 'Usability',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
