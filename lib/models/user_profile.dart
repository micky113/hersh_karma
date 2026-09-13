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

  int get requiredKarma {
    switch (this) {
      case CommunityRole.newMember: return 0;
      case CommunityRole.contributor: return 100;
      case CommunityRole.trustedContributor: return 1000;
      case CommunityRole.communityLeader: return 5000;
      case CommunityRole.karmaAmbassador: return 25000;
    }
  }

  double get minTrustScore {
    switch (this) {
      case CommunityRole.newMember: return 0.0;
      case CommunityRole.contributor: return 0.70;
      case CommunityRole.trustedContributor: return 0.80;
      case CommunityRole.communityLeader: return 0.90;
      case CommunityRole.karmaAmbassador: return 0.95;
    }
  }

  int get minVerifiedContributions {
    switch (this) {
      case CommunityRole.newMember: return 0;
      case CommunityRole.contributor: return 5;
      case CommunityRole.trustedContributor: return 25;
      case CommunityRole.communityLeader: return 100;
      case CommunityRole.karmaAmbassador: return 300;
    }
  }

  int get minDistinctCategories {
    switch (this) {
      case CommunityRole.newMember: return 1;
      case CommunityRole.contributor: return 1;
      case CommunityRole.trustedContributor: return 2;
      case CommunityRole.communityLeader: return 3;
      case CommunityRole.karmaAmbassador: return 5;
    }
  }

  String get otherRequirement {
    switch (this) {
      case CommunityRole.newMember: return 'Account verified';
      case CommunityRole.contributor: return 'No serious violations';
      case CommunityRole.trustedContributor: return '≥5 successful community/help contributions';
      case CommunityRole.communityLeader: return '≥3 completed community initiatives';
      case CommunityRole.karmaAmbassador: return 'Human review + ≥12 months good standing + ≥5 impact categories';
    }
  }

  String get description {
    switch (this) {
      case CommunityRole.newMember: return '0–99 Lifetime Karma • Basic participation (Do good, Report, Wishes)';
      case CommunityRole.contributor: return '100+ Lifetime Karma • Verified participant with enhanced passport';
      case CommunityRole.trustedContributor: return '1,000+ Lifetime Karma • Community verification & mentoring permissions';
      case CommunityRole.communityLeader: return '5,000+ Lifetime Karma • Coordinates cleanups, projects & volunteer mobilizations';
      case CommunityRole.karmaAmbassador: return '25,000+ Lifetime Karma • Values representation, regional mentorship & ESG campaigns';
    }
  }

  String get tagline {
    switch (this) {
      case CommunityRole.newMember: return 'Starting journey • Do good, report problems & earn Karma';
      case CommunityRole.contributor: return '100+ Karma • Active verified participant';
      case CommunityRole.trustedContributor: return '1,000+ Karma • Peer validation & moderation authority';
      case CommunityRole.communityLeader: return '5,000+ Karma • Local project leader & volunteer organizer';
      case CommunityRole.karmaAmbassador: return '25,000+ Karma • High-diversity values ambassador';
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
          'Unlock enhanced Karma Passport credentials',
          'Model clean conduct with zero fraud or spam',
        ];
      case CommunityRole.trustedContributor:
        return [
          'Peer-verify low-risk community contributions',
          'Mentor new users and assist in onboarding',
          'Access advanced community reporting tools',
          'Flag suspicious gaming or duplicate photo evidence',
          'Adhere strictly to conflict-of-interest firewall',
        ];
      case CommunityRole.communityLeader:
        return [
          'Create and lead local community initiatives & cleanups',
          'Organize challenges and coordinate volunteers',
          'Coordinate with local NGOs, schools, and civic bodies',
          'Access leadership dashboard and coordination tools',
          'Mentor newer members and emerging contributors',
        ];
      case CommunityRole.karmaAmbassador:
        return [
          'Represent Karma Grid in approved programs and keynote panels',
          'Mentor Community Leaders across regional chapters',
          'Participate in major ESG and corporate civic campaigns',
          'Advise municipal and international impact partners',
          'Lead network expansion across diverse impact domains',
        ];
    }
  }

  String get promotionRequirements {
    switch (this) {
      case CommunityRole.newMember:
        return 'Default starting role: 0–99 Karma • 0–4 verified deeds • Account verified.';
      case CommunityRole.contributor:
        return '≥ 100 Karma + ≥ 5 verified deeds + ≥ 70% Trust + No serious violations.';
      case CommunityRole.trustedContributor:
        return '≥ 1,000 Karma + ≥ 25 verified deeds + ≥ 80% Trust + ≥ 5 help contributions.';
      case CommunityRole.communityLeader:
        return '≥ 5,000 Karma + ≥ 100 verified deeds + ≥ 90% Trust + ≥ 3 completed initiatives.';
      case CommunityRole.karmaAmbassador:
        return '≥ 25,000 Karma + ≥ 300 verified deeds + ≥ 95% Trust + ≥ 5 distinct categories + Human review.';
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

  // Exact Numerical Hierarchy & Diversity Metrics
  final int distinctCategoriesCount; // categories contributed to (1-8)
  final int accountAgeMonths; // months in good standing
  final int communityHelpContributionsCount; // successful community/help deeds
  final int completedInitiativesCount; // completed community initiatives

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
    this.distinctCategoriesCount = 1,
    this.accountAgeMonths = 3,
    this.communityHelpContributionsCount = 0,
    this.completedInitiativesCount = 0,
  });

  int get effectiveDistinctCategoriesCount {
    if (categoryCredits.isNotEmpty) return categoryCredits.keys.length;
    return distinctCategoriesCount;
  }

  /// Evaluates community role based on strict ALL-Conditions enforcement
  CommunityRole get communityRole {
    if (explicitCommunityRole != null) return explicitCommunityRole!;

    // Level 5: Karma Ambassador (25,000+ Karma, >= 95% Trust, >= 300 deeds, >= 5 categories, >= 12 months, Approved)
    if (karmaCredits >= 25000 &&
        trustScore >= 0.95 &&
        verifiedSubmissions >= 300 &&
        effectiveDistinctCategoriesCount >= 5 &&
        accountAgeMonths >= 12 &&
        isAmbassadorApproved &&
        conductViolationsCount == 0) {
      return CommunityRole.karmaAmbassador;
    }

    // Level 4: Community Leader (5,000+ Karma, >= 90% Trust, >= 100 deeds, >= 3 completed initiatives, Clean record)
    if ((karmaCredits >= 5000 &&
            trustScore >= 0.90 &&
            verifiedSubmissions >= 100 &&
            (completedInitiativesCount >= 3 || organizedInitiativesCount >= 3) &&
            conductViolationsCount == 0) ||
        (role == UserRole.communityGroup && trustScore >= 0.85)) {
      return CommunityRole.communityLeader;
    }

    // Level 3: Trusted Contributor (1,000+ Karma, >= 80% Trust, >= 25 deeds, >= 5 help deeds, Clean record)
    if (karmaCredits >= 1000 &&
        trustScore >= 0.80 &&
        verifiedSubmissions >= 25 &&
        (communityHelpContributionsCount >= 5 || verifiedSubmissions >= 25) &&
        conductViolationsCount == 0) {
      return CommunityRole.trustedContributor;
    }

    // Level 2: Contributor (100+ Karma, >= 70% Trust, >= 5 deeds, Clean record)
    if (karmaCredits >= 100 &&
        trustScore >= 0.70 &&
        verifiedSubmissions >= 5 &&
        conductViolationsCount == 0) {
      return CommunityRole.contributor;
    }

    // Level 1: New Member (0–99 Karma, 0–4 deeds)
    return CommunityRole.newMember;
  }

  /// Demotion & Suspension Detection:
  /// If trust score drops below the active level's minimum requirement, privileges are suspended.
  bool get isDemotedOrSuspended {
    if (communityRole == CommunityRole.newMember) return false;
    return trustScore < communityRole.minTrustScore || conductViolationsCount > 0;
  }

  String? get demotionReason {
    if (conductViolationsCount > 0) {
      return 'Account privileges suspended due to $conductViolationsCount conduct violation(s).';
    }
    if (communityRole.minTrustScore > 0 && trustScore < communityRole.minTrustScore) {
      return 'Trust score (${(trustScore * 100).toInt()}%) has fallen below the required ${(communityRole.minTrustScore * 100).toInt()}% threshold for ${communityRole.title}. Responsibilities temporarily suspended.';
    }
    return null;
  }

  bool get canVerifyPeerDeeds =>
      !isDemotedOrSuspended &&
      (communityRole.levelNumber >= 3 ||
          isOrgVerified ||
          role == UserRole.ngo ||
          role == UserRole.institution);

  bool get canCoordinateCommunityProjects =>
      !isDemotedOrSuspended &&
      (communityRole.levelNumber >= 4 ||
          role == UserRole.communityGroup ||
          role == UserRole.ngo ||
          isOrgVerified);

  bool get canManageChallenges =>
      !isDemotedOrSuspended &&
      (role == UserRole.institution ||
          role == UserRole.corporate ||
          role == UserRole.ngo ||
          communityRole.levelNumber >= 4);

  bool get canRepresentAsAmbassador =>
      !isDemotedOrSuspended &&
      (communityRole == CommunityRole.karmaAmbassador || role == UserRole.government);

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
    int? distinctCategoriesCount,
    int? accountAgeMonths,
    int? communityHelpContributionsCount,
    int? completedInitiativesCount,
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
      distinctCategoriesCount: distinctCategoriesCount ?? this.distinctCategoriesCount,
      accountAgeMonths: accountAgeMonths ?? this.accountAgeMonths,
      communityHelpContributionsCount: communityHelpContributionsCount ?? this.communityHelpContributionsCount,
      completedInitiativesCount: completedInitiativesCount ?? this.completedInitiativesCount,
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
      'distinctCategoriesCount': distinctCategoriesCount,
      'accountAgeMonths': accountAgeMonths,
      'communityHelpContributionsCount': communityHelpContributionsCount,
      'completedInitiativesCount': completedInitiativesCount,
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
      distinctCategoriesCount: json['distinctCategoriesCount'] as int? ?? 1,
      accountAgeMonths: json['accountAgeMonths'] as int? ?? 3,
      communityHelpContributionsCount: json['communityHelpContributionsCount'] as int? ?? 0,
      completedInitiativesCount: json['completedInitiativesCount'] as int? ?? 0,
    );
  }
}
