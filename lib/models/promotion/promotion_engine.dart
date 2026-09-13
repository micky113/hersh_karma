import '../user_profile.dart';

/// The 2-Dimensional positioning of a user in Karma Grid:
/// Vertical Axis = KARMA (Volume & breadth of positive actions)
/// Horizontal Axis = TRUST (Evidence fidelity, accuracy & reliability)
enum KarmaTrustQuadrant {
  highKarmaHighTrust,   // Pillar of Impact: Eligible for Leadership / Ambassador
  lowKarmaHighTrust,    // High Integrity Emerging Contributor: Progression path active
  highKarmaLowTrust,    // High Volume / Questionable Evidence: BLOCKED from responsibility promotion
  lowKarmaLowTrust;     // Early Stage / Exploring: Building foundational record

  String get label {
    switch (this) {
      case KarmaTrustQuadrant.highKarmaHighTrust:
        return 'Pillar of Impact (High Karma • High Trust)';
      case KarmaTrustQuadrant.lowKarmaHighTrust:
        return 'High-Integrity Emerging Contributor (Low Karma • High Trust)';
      case KarmaTrustQuadrant.highKarmaLowTrust:
        return 'High Volume / Questionable Reliability (Blocked from Promotion)';
      case KarmaTrustQuadrant.lowKarmaLowTrust:
        return 'Early Stage Explorer (Building Foundation)';
    }
  }

  String get description {
    switch (this) {
      case KarmaTrustQuadrant.highKarmaHighTrust:
        return 'Strong track record of verified deeds backed by pristine evidence and community consensus. Prime candidate for Community Leader and Ambassador roles.';
      case KarmaTrustQuadrant.lowKarmaHighTrust:
        return 'Newer or focused contributor with impeccable integrity and accuracy. Trust unlocks progressive responsibility even with modest Karma points.';
      case KarmaTrustQuadrant.highKarmaLowTrust:
        return 'Has accumulated Karma but evidence fidelity or verification reliability is below safety thresholds. Promotion to responsibility is paused until Trust is restored.';
      case KarmaTrustQuadrant.lowKarmaLowTrust:
        return 'Beginning your journey in Karma Grid. Complete initial verified actions and report local issues to establish your Trust baseline.';
    }
  }

  bool get isPromotionEligible {
    return this == KarmaTrustQuadrant.highKarmaHighTrust ||
        this == KarmaTrustQuadrant.lowKarmaHighTrust;
  }
}

/// The 4 Promotion Gates
class PromotionGateResult {
  final bool contributionPassed;
  final String contributionDetail;
  final double contributionProgress;

  final bool verificationPassed;
  final String verificationDetail;
  final double verificationProgress;

  final bool trustPassed;
  final String trustDetail;
  final double trustProgress;

  final bool conductPassed;
  final String conductDetail;
  final double conductProgress;

  final bool isEligibleForNextLevel;
  final CommunityRole targetRole;
  final String statusSummary;
  final List<String> unlockedResponsibilities;

  const PromotionGateResult({
    required this.contributionPassed,
    required this.contributionDetail,
    required this.contributionProgress,
    required this.verificationPassed,
    required this.verificationDetail,
    required this.verificationProgress,
    required this.trustPassed,
    required this.trustDetail,
    required this.trustProgress,
    required this.conductPassed,
    required this.conductDetail,
    required this.conductProgress,
    required this.isEligibleForNextLevel,
    required this.targetRole,
    required this.statusSummary,
    required this.unlockedResponsibilities,
  });

  double get overallProgress =>
      (contributionProgress + verificationProgress + trustProgress + conductProgress) / 4.0;
}

class PromotionEngine {
  /// Evaluates 2D quadrant classification for any user
  static KarmaTrustQuadrant evaluateQuadrant(UserProfile user) {
    final hasHighKarma = user.karmaCredits >= 500 || user.verifiedSubmissions >= 15;
    final hasHighTrust = user.trustScore >= 0.85;

    if (hasHighKarma && hasHighTrust) {
      return KarmaTrustQuadrant.highKarmaHighTrust;
    } else if (!hasHighKarma && hasHighTrust) {
      return KarmaTrustQuadrant.lowKarmaHighTrust;
    } else if (hasHighKarma && !hasHighTrust) {
      return KarmaTrustQuadrant.highKarmaLowTrust;
    } else {
      return KarmaTrustQuadrant.lowKarmaLowTrust;
    }
  }

  /// Evaluates 4-Gate criteria for next level progression
  static PromotionGateResult evaluateNextLevelGates(UserProfile user) {
    final currentRole = user.communityRole;

    switch (currentRole) {
      case CommunityRole.newMember:
        // Target: Contributor (>= 5 total deeds, >= 3 verified, >= 70% trust, clean record)
        final contribPass = user.totalSubmissions >= 5 || user.verifiedSubmissions >= 1;
        final contribProg = ((user.totalSubmissions + user.verifiedSubmissions) / 5.0).clamp(0.0, 1.0);

        final verifPass = user.verifiedSubmissions >= 1;
        final verifProg = (user.verifiedSubmissions / 1.0).clamp(0.0, 1.0);

        final trustPass = user.trustScore >= 0.70;
        final trustProg = (user.trustScore / 0.70).clamp(0.0, 1.0);

        final conductPass = user.conductViolationsCount == 0;
        final conductProg = conductPass ? 1.0 : 0.0;

        final eligible = contribPass && verifPass && trustPass && conductPass;

        return PromotionGateResult(
          contributionPassed: contribPass,
          contributionDetail: '${user.totalSubmissions}/5 Submissions',
          contributionProgress: contribProg,
          verificationPassed: verifPass,
          verificationDetail: '${user.verifiedSubmissions}/1 Verified Proof',
          verificationProgress: verifProg,
          trustPassed: trustPass,
          trustDetail: '${(user.trustScore * 100).toInt()}% / 70% Baseline Trust',
          trustProgress: trustProg,
          conductPassed: conductPass,
          conductDetail: conductPass ? 'Clean record (0 violations)' : '${user.conductViolationsCount} violations',
          conductProgress: conductProg,
          isEligibleForNextLevel: eligible,
          targetRole: CommunityRole.contributor,
          statusSummary: eligible
              ? 'Eligible for Contributor status! Automatic elevation ready.'
              : 'Complete your first verified deeds with accurate photo proof to qualify for Contributor.',
          unlockedResponsibilities: CommunityRole.contributor.responsibilities,
        );

      case CommunityRole.contributor:
        // Target: Trusted Contributor (>= 15 verified deeds, >= 85% trust, clean record)
        final contribPass = user.verifiedSubmissions >= 15;
        final contribProg = (user.verifiedSubmissions / 15.0).clamp(0.0, 1.0);

        final verifPass = user.verifiedSubmissions >= 10;
        final verifProg = (user.verifiedSubmissions / 10.0).clamp(0.0, 1.0);

        final trustPass = user.trustScore >= 0.85;
        final trustProg = (user.trustScore / 0.85).clamp(0.0, 1.0);

        final conductPass = user.conductViolationsCount == 0 && user.evidenceAccuracyRate >= 0.80;
        final conductProg = conductPass ? 1.0 : 0.5;

        final eligible = contribPass && verifPass && trustPass && conductPass;

        return PromotionGateResult(
          contributionPassed: contribPass,
          contributionDetail: '${user.verifiedSubmissions}/15 Verified Impact Actions',
          contributionProgress: contribProg,
          verificationPassed: verifPass,
          verificationDetail: '${user.verifiedSubmissions}/10 Consensus Verified',
          verificationProgress: verifProg,
          trustPassed: trustPass,
          trustDetail: '${(user.trustScore * 100).toInt()}% / 85% Trust Score',
          trustProgress: trustProg,
          conductPassed: conductPass,
          conductDetail: 'High evidence fidelity • 0 abuse flags',
          conductProgress: conductProg,
          isEligibleForNextLevel: eligible,
          targetRole: CommunityRole.trustedContributor,
          statusSummary: eligible
              ? 'Eligible for Trusted Contributor! Unlocks peer verification responsibility.'
              : 'Requires ≥15 verified actions and ≥85% Trust score.',
          unlockedResponsibilities: CommunityRole.trustedContributor.responsibilities,
        );

      case CommunityRole.trustedContributor:
        // Target: Community Leader (>= 30 verified deeds, >= 90% trust, >= 1 initiative, peer endorsements)
        final contribPass = user.verifiedSubmissions >= 30;
        final contribProg = (user.verifiedSubmissions / 30.0).clamp(0.0, 1.0);

        final verifPass = user.organizedInitiativesCount >= 1 || user.projectsCount >= 1;
        final verifProg = verifPass ? 1.0 : (user.verifiedSubmissions >= 25 ? 0.7 : 0.3);

        final trustPass = user.trustScore >= 0.90;
        final trustProg = (user.trustScore / 0.90).clamp(0.0, 1.0);

        final conductPass = user.conductViolationsCount == 0 && user.peerEndorsementsCount >= 3;
        final conductProg = (user.peerEndorsementsCount / 3.0).clamp(0.0, 1.0);

        final eligible = contribPass && verifPass && trustPass && conductPass;

        return PromotionGateResult(
          contributionPassed: contribPass,
          contributionDetail: '${user.verifiedSubmissions}/30 Verified Actions',
          contributionProgress: contribProg,
          verificationPassed: verifPass,
          verificationDetail: verifPass ? '1+ Local Projects Organized' : '0 Community Projects Led',
          verificationProgress: verifProg,
          trustPassed: trustPass,
          trustDetail: '${(user.trustScore * 100).toInt()}% / 90% Trust Score',
          trustProgress: trustProg,
          conductPassed: conductPass,
          conductDetail: '${user.peerEndorsementsCount}/3 Peer Endorsements',
          conductProgress: conductProg,
          isEligibleForNextLevel: eligible,
          targetRole: CommunityRole.communityLeader,
          statusSummary: eligible
              ? 'Eligible for Community Leader nomination! Submit portfolio for community endorsement.'
              : 'Lead a local initiative and gather 3 peer endorsements to qualify.',
          unlockedResponsibilities: CommunityRole.communityLeader.responsibilities,
        );

      case CommunityRole.communityLeader:
        // Target: Karma Ambassador (>= 75 verified deeds, >= 95% trust, multi-thousand ripple, human review)
        final contribPass = user.verifiedSubmissions >= 75 || user.karmaCredits >= 5000;
        final contribProg = (user.verifiedSubmissions / 75.0).clamp(0.0, 1.0);

        final verifPass = user.karmaRipplesCount >= 10 || user.peopleReached >= 1000;
        final verifProg = verifPass ? 1.0 : 0.5;

        final trustPass = user.trustScore >= 0.95;
        final trustProg = (user.trustScore / 0.95).clamp(0.0, 1.0);

        final conductPass = user.conductViolationsCount == 0 && user.isAmbassadorApproved;
        final conductProg = user.isAmbassadorApproved ? 1.0 : (user.isAmbassadorNominated ? 0.75 : 0.4);

        final eligible = contribPass && verifPass && trustPass && user.isAmbassadorApproved;

        return PromotionGateResult(
          contributionPassed: contribPass,
          contributionDetail: '${user.verifiedSubmissions}/75 Verified Impact Deeds',
          contributionProgress: contribProg,
          verificationPassed: verifPass,
          verificationDetail: '${user.karmaRipplesCount} Ripples • ${user.peopleReached} Reached',
          verificationProgress: verifProg,
          trustPassed: trustPass,
          trustDetail: '${(user.trustScore * 100).toInt()}% / 95% Long-term Trust',
          trustProgress: trustProg,
          conductPassed: user.isAmbassadorApproved,
          conductDetail: user.isAmbassadorApproved
              ? 'Governance Board Approved'
              : (user.isAmbassadorNominated ? 'Nomination Pending Governance Review' : 'Requires Governance Review'),
          conductProgress: conductProg,
          isEligibleForNextLevel: eligible,
          targetRole: CommunityRole.karmaAmbassador,
          statusSummary: user.isAmbassadorApproved
              ? 'Conferred Karma Ambassador! Highest honor of values representation.'
              : 'Requires Governance Board review and long-term 95%+ Trust record.',
          unlockedResponsibilities: CommunityRole.karmaAmbassador.responsibilities,
        );

      case CommunityRole.karmaAmbassador:
        return PromotionGateResult(
          contributionPassed: true,
          contributionDetail: 'Exemplary lifetime record (${user.verifiedSubmissions} deeds)',
          contributionProgress: 1.0,
          verificationPassed: true,
          verificationDetail: 'Audited Master Proof Portfolio',
          verificationProgress: 1.0,
          trustPassed: true,
          trustDetail: '${(user.trustScore * 100).toInt()}% Trust Score',
          trustProgress: 1.0,
          conductPassed: true,
          conductDetail: 'Exemplary civic & community conduct',
          conductProgress: 1.0,
          isEligibleForNextLevel: false,
          targetRole: CommunityRole.karmaAmbassador,
          statusSummary: 'You hold the highest community responsibility: Karma Ambassador.',
          unlockedResponsibilities: CommunityRole.karmaAmbassador.responsibilities,
        );
    }
  }
}