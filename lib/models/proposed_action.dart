import 'karma_category.dart';

enum ProposalStatus {
  community, // submitted by users
  verified,  // reviewed against standards
  global,    // independently validated & available worldwide
}

class ProposedAction {
  final String id;
  final String proposerId;
  final String proposerName;
  final String title;
  final String problemDescription;
  final KarmaCategory category;
  final String location;
  final String expectedImpact;
  final String evidenceRequired;
  final String estimatedResources;
  final String whoBenefits;
  final int suggestedKarma;
  final ProposalStatus status;
  final int approvals;
  final int rejections;
  final Set<String> votedUserIds;

  ProposedAction({
    required this.id,
    required this.proposerId,
    required this.proposerName,
    required this.title,
    required this.problemDescription,
    required this.category,
    required this.location,
    required this.expectedImpact,
    required this.evidenceRequired,
    required this.estimatedResources,
    required this.whoBenefits,
    required this.suggestedKarma,
    this.status = ProposalStatus.community,
    this.approvals = 0,
    this.rejections = 0,
    this.votedUserIds = const {},
  });

  ProposedAction copyWith({
    String? id,
    String? proposerId,
    String? proposerName,
    String? title,
    String? problemDescription,
    KarmaCategory? category,
    String? location,
    String? expectedImpact,
    String? evidenceRequired,
    String? estimatedResources,
    String? whoBenefits,
    int? suggestedKarma,
    ProposalStatus? status,
    int? approvals,
    int? rejections,
    Set<String>? votedUserIds,
  }) {
    return ProposedAction(
      id: id ?? this.id,
      proposerId: proposerId ?? this.proposerId,
      proposerName: proposerName ?? this.proposerName,
      title: title ?? this.title,
      problemDescription: problemDescription ?? this.problemDescription,
      category: category ?? this.category,
      location: location ?? this.location,
      expectedImpact: expectedImpact ?? this.expectedImpact,
      evidenceRequired: evidenceRequired ?? this.evidenceRequired,
      estimatedResources: estimatedResources ?? this.estimatedResources,
      whoBenefits: whoBenefits ?? this.whoBenefits,
      suggestedKarma: suggestedKarma ?? this.suggestedKarma,
      status: status ?? this.status,
      approvals: approvals ?? this.approvals,
      rejections: rejections ?? this.rejections,
      votedUserIds: votedUserIds ?? this.votedUserIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'proposerId': proposerId,
      'proposerName': proposerName,
      'title': title,
      'problemDescription': problemDescription,
      'category': category.toJson(),
      'location': location,
      'expectedImpact': expectedImpact,
      'evidenceRequired': evidenceRequired,
      'estimatedResources': estimatedResources,
      'whoBenefits': whoBenefits,
      'suggestedKarma': suggestedKarma,
      'status': status.name,
      'approvals': approvals,
      'rejections': rejections,
      'votedUserIds': votedUserIds.toList(),
    };
  }

  factory ProposedAction.fromJson(Map<String, dynamic> json) {
    return ProposedAction(
      id: json['id'] as String,
      proposerId: json['proposerId'] as String,
      proposerName: json['proposerName'] as String? ?? 'Anonymous',
      title: json['title'] as String,
      problemDescription: json['problemDescription'] as String,
      category: KarmaCategory.fromJson(json['category'] as String),
      location: json['location'] as String,
      expectedImpact: json['expectedImpact'] as String,
      evidenceRequired: json['evidenceRequired'] as String,
      estimatedResources: json['estimatedResources'] as String,
      whoBenefits: json['whoBenefits'] as String,
      suggestedKarma: json['suggestedKarma'] as int? ?? 30,
      status: ProposalStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'community'),
        orElse: () => ProposalStatus.community,
      ),
      approvals: json['approvals'] as int? ?? 0,
      rejections: json['rejections'] as int? ?? 0,
      votedUserIds: Set<String>.from(json['votedUserIds'] ?? []),
    );
  }
}
