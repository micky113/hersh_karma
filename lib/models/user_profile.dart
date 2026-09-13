enum UserRole {
  individual,
  communityGroup,
  institution,
  ngo,
  corporate,
  government,
  impactPartner
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.individual: return 'Individual 👤';
      case UserRole.communityGroup: return 'Community Group 👥';
      case UserRole.institution: return 'Institution / School 🏫';
      case UserRole.ngo: return 'NGO / Impact Org 🤝';
      case UserRole.corporate: return 'Business / Corporate 🏢';
      case UserRole.government: return 'Government / Civic 🏛️';
      case UserRole.impactPartner: return 'Impact Partner 🌐';
    }
  }
}

enum CommunityRole {
  newMember,
  contributor,
  trustedContributor,
  communityLeader,
  karmaAmbassador;

  static CommunityRole get member => CommunityRole.newMember;

  int get levelNumber {
    switch (this) {
      case CommunityRole.newMember: return 1;
      case CommunityRole.contributor: return 2;
      case CommunityRole.trustedContributor: return 3;
      case CommunityRole.communityLeader: return 4;
      case CommunityRole.karmaAmbassador: return 5;
    }
  }

  String get label {
    switch (this) {
      case CommunityRole.newMember: return 'New Member 👤';
      case CommunityRole.contributor: return 'Contributor 🌱';
      case CommunityRole.trustedContributor: return 'Trusted Contributor 🛡️';
      case CommunityRole.communityLeader: return 'Community Leader 🤝';
      case CommunityRole.karmaAmbassador: return 'Karma Ambassador 🌟';
    }
  }

  String get title {
    switch (this) {
      case CommunityRole.newMember: return 'New Member';
      case CommunityRole.contributor: return 'Contributor';
      case CommunityRole.trustedContributor: return 'Trusted Contributor';
      case CommunityRole.communityLeader: return 'Community Leader';
      case CommunityRole.karmaAmbassador: return 'Karma Ambassador';
    }
  }

  String get description {
    switch (this) {
      case CommunityRole.newMember: return 'Default member • Can do good, report problems & make wishes';
      case CommunityRole.contributor: return 'Proven participant • Verified real-world impact recognition';
      case CommunityRole.trustedContributor: return 'High trust score • Community peer verification permissions';
      case CommunityRole.communityLeader: return 'Coordinates community initiatives, volunteers & local projects';
      case CommunityRole.karmaAmbassador: return 'Values representation • Civic mentor, campaign speaker & expansion';
    }
  }

  String get tagline {
    switch (this) {
      case CommunityRole.newMember: return 'Starting journey • Do good, report problems & earn Karma';
      case CommunityRole.contributor: return 'Active participant • Proven real-world impact recognition';
      case CommunityRole.trustedContributor: return 'High integrity verifier • Peer validation & moderation authority';
      case CommunityRole.communityLeader: return 'Initiative coordinator • Local project leader & volunteer organizer';
      case CommunityRole.karmaAmbassador: return 'Values representation • Civic mentor, campaign speaker & expansion';
    }
  }

  List<String> get responsibilities {
    switch (this) {
      case CommunityRole.newMember:
        return [
          'Do verified good deeds & capture photographic evidence',
          'Report neighborhood problems & civic hazards',
          'Create and support community wishes',
          'Earn Karma Credits and build initial Trust score',
          'Provide community feedback on local initiatives',
        ];
      case CommunityRole.contributor:
        return [
          'Maintain consistent, high-fidelity photographic proof',
          'Participate in open community and institutional challenges',
          'Contribute to verified ecological & kindness categories',
          'Model clean conduct with zero fraud or spam',
        ];
      case CommunityRole.trustedContributor:
        return [
          'Peer-verify low-risk community contributions',
          'Participate in community content moderation',
          'Guide and onboard newcomers in the network',
          'Flag suspicious gaming or duplicate photo evidence',
          'Adhere strictly to conflict-of-interest firewall (no approving friends or self)',
        ];
      case CommunityRole.communityLeader:
        return [
          'Create and lead local community initiatives & cleanups',
          'Organize community challenges and volunteer mobilization',
          'Coordinate with local NGOs, schools, and civic bodies',
          'Access leadership dashboard and coordination tools',
          'Mentor newer members and emerging contributors',
        ];
      case CommunityRole.karmaAmbassador:
        return [
          'Represent the core values and integrity of Karma Grid locally',
          'Mentor Community Leaders across regional chapters',
          'Participate as a key speaker in major civic & ESG campaigns',
          'Assist schools, NGOs, and municipal orgs in launching initiatives',
          'Lead network expansion into new cities and communities',
        ];
    }
  }

  String get promotionRequirements {
    switch (this) {
      case CommunityRole.newMember:
        return 'Default starting role for every new user.';
      case CommunityRole.contributor:
        return '≥ 5 verified deeds + clean record (0 violations) + quality evidence.';
      case CommunityRole.trustedContributor:
        return '≥ 15 verified deeds + ≥ 85% Trust Score + accurate evidence + 0 fraud alerts.';
      case CommunityRole.communityLeader:
        return '≥ 30 verified deeds + ≥ 90% Trust Score + ≥ 1 organized initiative/project + peer endorsements.';
      case CommunityRole.karmaAmbassador:
        return '≥ 75 verified deeds + ≥ 95% long-term Trust + multi-thousand ripple reach + Human Governance review.';
    }
  }

  String get reviewType {
    switch (this) {
      case CommunityRole.newMember:
        return 'None (Automatic)';
      case CommunityRole.contributor:
        return 'Automated Contribution & Verification Screening';
      case CommunityRole.trustedContributor:
        return 'Automated Trust & Evidence Screening';
      case CommunityRole.communityLeader:
        return 'Portfolio & Peer Community Review';
      case CommunityRole.karmaAmbassador:
        return 'Human Governance Board Review (Trust Center)';
    }
  }
}

enum AppInterfaceMode {
  simple,
  standard,
  professional
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final int reputationScore; // 0 to 100 (default: 50)
  final int karmaCredits; // current redeemable karma credits
  final double tokensBalance; // current PoG cryptocurrency tokens balance
  final Map<String, int> categoryCredits; // credits earned per category
  final int totalSubmissions;
  final int verifiedSubmissions;
  final double trustScore; // 0.0 to 1.0 (default: 1.0)
  
  // Accessibility & System settings
  final AppInterfaceMode interfaceMode;
  final String preferredLanguage;

  // Role-Specific Impact Statistics
  final int studentsCount;
  final int employeesCount;
  final int projectsCount;
  final int peopleReached;
  final int totalVolunteers;
  final double wasteRecoveredKg;
  final int peopleTaught;
  final int karmaRipplesCount;
  final bool isOrgVerified;

  // 4-Gate Promotion & Conduct Metadata
  final double evidenceAccuracyRate; // 0.0 to 1.0 (default: 0.95)
  final int conductViolationsCount; // fraud or abuse flags
  final int organizedInitiativesCount; // community projects organized
  final int peerEndorsementsCount; // peer validations/endorsements
  final bool isAmbassadorNominated;
  final bool isAmbassadorApproved;
  final CommunityRole? explicitCommunityRole;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.individual,
    this.reputationScore = 50,
    this.karmaCredits = 0,
    this.tokensBalance = 0.0,
    this.categoryCredits = const {},
    this.totalSubmissions = 0,
    this.verifiedSubmissions = 0,
    this.trustScore = 1.0,
    this.interfaceMode = AppInterfaceMode.standard,
    this.preferredLanguage = 'English',
    this.studentsCount = 0,
    this.employeesCount = 0,
    this.projectsCount = 0,
    this.peopleReached = 0,
    this.totalVolunteers = 0,
    this.wasteRecoveredKg = 0.0,
    this.peopleTaught = 0,
    this.karmaRipplesCount = 0,
    this.isOrgVerified = false,
    this.evidenceAccuracyRate = 0.95,
    this.conductViolationsCount = 0,
    this.organizedInitiativesCount = 0,
    this.peerEndorsementsCount = 0,
    this.isAmbassadorNominated = false,
    this.isAmbassadorApproved = false,
    this.explicitCommunityRole,
  });

  CommunityRole get communityRole {
    if (explicitCommunityRole != null) return explicitCommunityRole!;
    if (isAmbassadorApproved) return CommunityRole.karmaAmbassador;
    if (role == UserRole.communityGroup ||
        organizedInitiativesCount >= 1 ||
        (verifiedSubmissions >= 30 && trustScore >= 0.90 && peerEndorsementsCount >= 3)) {
      return CommunityRole.communityLeader;
    }
    if (verifiedSubmissions >= 5 && trustScore >= 0.85) return CommunityRole.trustedContributor;
    if (verifiedSubmissions > 0) return CommunityRole.contributor;
    return CommunityRole.newMember;
  }

  bool get canVerifyPeerDeeds =>
      communityRole.levelNumber >= 3 ||
      isOrgVerified ||
      role == UserRole.ngo ||
      role == UserRole.institution;

  bool get canCoordinateCommunityProjects =>
      communityRole.levelNumber >= 4 ||
      role == UserRole.communityGroup ||
      role == UserRole.ngo ||
      isOrgVerified;

  bool get canManageChallenges =>
      role == UserRole.institution ||
      role == UserRole.corporate ||
      role == UserRole.ngo ||
      communityRole.levelNumber >= 4;

  bool get canRepresentAsAmbassador =>
      communityRole == CommunityRole.karmaAmbassador ||
      role == UserRole.government;

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    int? reputationScore,
    int? karmaCredits,
    double? tokensBalance,
    Map<String, int>? categoryCredits,
    int? totalSubmissions,
    int? verifiedSubmissions,
    double? trustScore,
    AppInterfaceMode? interfaceMode,
    String? preferredLanguage,
    int? studentsCount,
    int? employeesCount,
    int? projectsCount,
    int? peopleReached,
    int? totalVolunteers,
    double? wasteRecoveredKg,
    int? peopleTaught,
    int? karmaRipplesCount,
    bool? isOrgVerified,
    double? evidenceAccuracyRate,
    int? conductViolationsCount,
    int? organizedInitiativesCount,
    int? peerEndorsementsCount,
    bool? isAmbassadorNominated,
    bool? isAmbassadorApproved,
    CommunityRole? explicitCommunityRole,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      reputationScore: reputationScore ?? this.reputationScore,
      karmaCredits: karmaCredits ?? this.karmaCredits,
      tokensBalance: tokensBalance ?? this.tokensBalance,
      categoryCredits: categoryCredits ?? this.categoryCredits,
      totalSubmissions: totalSubmissions ?? this.totalSubmissions,
      verifiedSubmissions: verifiedSubmissions ?? this.verifiedSubmissions,
      trustScore: trustScore ?? this.trustScore,
      interfaceMode: interfaceMode ?? this.interfaceMode,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      studentsCount: studentsCount ?? this.studentsCount,
      employeesCount: employeesCount ?? this.employeesCount,
      projectsCount: projectsCount ?? this.projectsCount,
      peopleReached: peopleReached ?? this.peopleReached,
      totalVolunteers: totalVolunteers ?? this.totalVolunteers,
      wasteRecoveredKg: wasteRecoveredKg ?? this.wasteRecoveredKg,
      peopleTaught: peopleTaught ?? this.peopleTaught,
      karmaRipplesCount: karmaRipplesCount ?? this.karmaRipplesCount,
      isOrgVerified: isOrgVerified ?? this.isOrgVerified,
      evidenceAccuracyRate: evidenceAccuracyRate ?? this.evidenceAccuracyRate,
      conductViolationsCount: conductViolationsCount ?? this.conductViolationsCount,
      organizedInitiativesCount: organizedInitiativesCount ?? this.organizedInitiativesCount,
      peerEndorsementsCount: peerEndorsementsCount ?? this.peerEndorsementsCount,
      isAmbassadorNominated: isAmbassadorNominated ?? this.isAmbassadorNominated,
      isAmbassadorApproved: isAmbassadorApproved ?? this.isAmbassadorApproved,
      explicitCommunityRole: explicitCommunityRole ?? this.explicitCommunityRole,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'reputationScore': reputationScore,
      'karmaCredits': karmaCredits,
      'tokensBalance': tokensBalance,
      'categoryCredits': categoryCredits,
      'totalSubmissions': totalSubmissions,
      'verifiedSubmissions': verifiedSubmissions,
      'trustScore': trustScore,
      'interfaceMode': interfaceMode.name,
      'preferredLanguage': preferredLanguage,
      'studentsCount': studentsCount,
      'employeesCount': employeesCount,
      'projectsCount': projectsCount,
      'peopleReached': peopleReached,
      'totalVolunteers': totalVolunteers,
      'wasteRecoveredKg': wasteRecoveredKg,
      'peopleTaught': peopleTaught,
      'karmaRipplesCount': karmaRipplesCount,
      'isOrgVerified': isOrgVerified,
      'evidenceAccuracyRate': evidenceAccuracyRate,
      'conductViolationsCount': conductViolationsCount,
      'organizedInitiativesCount': organizedInitiativesCount,
      'peerEndorsementsCount': peerEndorsementsCount,
      'isAmbassadorNominated': isAmbassadorNominated,
      'isAmbassadorApproved': isAmbassadorApproved,
      if (explicitCommunityRole != null) 'explicitCommunityRole': explicitCommunityRole!.name,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.individual,
      ),
      reputationScore: json['reputationScore'] as int? ?? 50,
      karmaCredits: json['karmaCredits'] as int? ?? 0,
      tokensBalance: (json['tokensBalance'] as num?)?.toDouble() ?? 0.0,
      categoryCredits: Map<String, int>.from(json['categoryCredits'] ?? {}),
      totalSubmissions: json['totalSubmissions'] as int? ?? 0,
      verifiedSubmissions: json['verifiedSubmissions'] as int? ?? 0,
      trustScore: (json['trustScore'] as num?)?.toDouble() ?? 1.0,
      interfaceMode: AppInterfaceMode.values.firstWhere(
        (e) => e.name == json['interfaceMode'],
        orElse: () => AppInterfaceMode.standard,
      ),
      preferredLanguage: json['preferredLanguage'] as String? ?? 'English',
      studentsCount: json['studentsCount'] as int? ?? 0,
      employeesCount: json['employeesCount'] as int? ?? 0,
      projectsCount: json['projectsCount'] as int? ?? 0,
      peopleReached: json['peopleReached'] as int? ?? 0,
      totalVolunteers: json['totalVolunteers'] as int? ?? 0,
      wasteRecoveredKg: (json['wasteRecoveredKg'] as num?)?.toDouble() ?? 0.0,
      peopleTaught: json['peopleTaught'] as int? ?? 0,
      karmaRipplesCount: json['karmaRipplesCount'] as int? ?? 0,
      isOrgVerified: json['isOrgVerified'] as bool? ?? false,
      evidenceAccuracyRate: (json['evidenceAccuracyRate'] as num?)?.toDouble() ?? 0.95,
      conductViolationsCount: json['conductViolationsCount'] as int? ?? 0,
      organizedInitiativesCount: json['organizedInitiativesCount'] as int? ?? 0,
      peerEndorsementsCount: json['peerEndorsementsCount'] as int? ?? 0,
      isAmbassadorNominated: json['isAmbassadorNominated'] as bool? ?? false,
      isAmbassadorApproved: json['isAmbassadorApproved'] as bool? ?? false,
      explicitCommunityRole: json['explicitCommunityRole'] != null
          ? CommunityRole.values.firstWhere(
              (r) => r.name == json['explicitCommunityRole'],
              orElse: () => CommunityRole.newMember,
            )
          : null,
    );
  }
}
