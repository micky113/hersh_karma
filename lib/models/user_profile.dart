class UserProfile {
  final String id;
  final String name;
  final String email;
  final int reputationScore; // 0 to 100 (default: 50)
  final int karmaCredits; // current redeemable karma credits
  final double tokensBalance; // current PoG cryptocurrency tokens balance
  final Map<String, int> categoryCredits; // credits earned per category
  final int totalSubmissions;
  final int verifiedSubmissions;
  final double trustScore; // 0.0 to 1.0 (default: 1.0)

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.reputationScore = 50,
    this.karmaCredits = 0,
    this.tokensBalance = 0.0,
    this.categoryCredits = const {},
    this.totalSubmissions = 0,
    this.verifiedSubmissions = 0,
    this.trustScore = 1.0,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    int? reputationScore,
    int? karmaCredits,
    double? tokensBalance,
    Map<String, int>? categoryCredits,
    int? totalSubmissions,
    int? verifiedSubmissions,
    double? trustScore,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      reputationScore: reputationScore ?? this.reputationScore,
      karmaCredits: karmaCredits ?? this.karmaCredits,
      tokensBalance: tokensBalance ?? this.tokensBalance,
      categoryCredits: categoryCredits ?? this.categoryCredits,
      totalSubmissions: totalSubmissions ?? this.totalSubmissions,
      verifiedSubmissions: verifiedSubmissions ?? this.verifiedSubmissions,
      trustScore: trustScore ?? this.trustScore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'reputationScore': reputationScore,
      'karmaCredits': karmaCredits,
      'tokensBalance': tokensBalance,
      'categoryCredits': categoryCredits,
      'totalSubmissions': totalSubmissions,
      'verifiedSubmissions': verifiedSubmissions,
      'trustScore': trustScore,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      reputationScore: json['reputationScore'] as int? ?? 50,
      karmaCredits: json['karmaCredits'] as int? ?? 0,
      tokensBalance: (json['tokensBalance'] as num?)?.toDouble() ?? 0.0,
      categoryCredits: Map<String, int>.from(json['categoryCredits'] ?? {}),
      totalSubmissions: json['totalSubmissions'] as int? ?? 0,
      verifiedSubmissions: json['verifiedSubmissions'] as int? ?? 0,
      trustScore: (json['trustScore'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
