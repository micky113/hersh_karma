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
  });

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
    );
  }
}
