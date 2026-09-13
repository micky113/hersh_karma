import '../user_profile.dart';

/// The 2-Dimensional positioning of a user in Karma Grid:
/// Vertical Axis = KARMA (Volume & breadth of positive actions: 0 to 25k+)
/// Horizontal Axis = TRUST (Evidence fidelity, accuracy & reliability: 0 to 100%)
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
        return 'Strong track record of verified deeds backed by pristine evidence (≥80% Trust). Prime candidate for Community Leader and Ambassador roles.';
      case KarmaTrustQuadrant.lowKarmaHighTrust:
        return 'Newer or focused contributor with impeccable integrity and accuracy (≥80% Trust). Trust unlocks progressive responsibility even with modest Karma points.';
      case KarmaTrustQuadrant.highKarmaLowTrust:
        return 'Has accumulated Karma but Trust is below safety thresholds (<80%). Promotion to responsibility is paused until Trust is restored.';
      case KarmaTrustQuadrant.lowKarmaLowTrust:
        return 'Beginning your journey in Karma Grid. Complete initial verified actions and report local issues to establish your Trust baseline.';
    }
  }

  bool get isPromotionEligible {
    return this == KarmaTrustQuadrant.highKarmaHighTrust ||
        this == KarmaTrustQuadrant.lowKarmaHighTrust;
  }
}

/// The 4 Promotion Gates + Impact Diversity & Numerical Breakdown
class PromotionGateResult {
  // Gate 1: Lifetime Karma Gate
  final bool karmaPassed;
  final String karmaDetail;
  final double karmaProgress;

  // Gate 2: Verified Contributions Gate
  final bool verificationPassed;
  final String verificationDetail;
  final double verificationProgress;

  // Gate 3: Mandatory Trust Gate
  final bool trustPassed;
  final String trustDetail;
  final double trustProgress;

  // Gate 4: Role-Specific & Conduct Gate (initiatives, review, violations)
  final bool conductPassed;
  final String conductDetail;
  final double conductProgress;

  // Impact Diversity Gate (5+ distinct categories for Ambassador)
  final bool categoryDiversityPassed;
  final String categoryDiversityDetail;
  final double categoryDiversityProgress;

  final bool isEligibleForNextLevel;
  final CommunityRole targetRole;
  final String statusSummary;
  final List<String> unlockedResponsibilities;

  const PromotionGateResult({
    required this.karmaPassed,
    required this.karmaDetail,
    required this.karmaProgress,
    required this.verificationPassed,
    required this.verificationDetail,
    required this.verificationProgress,
    required this.trustPassed,
    required this.trustDetail,
    required this.trustProgress,
    required this.conductPassed,
    required this.conductDetail,
    required this.conductProgress,
    required this.categoryDiversityPassed,
    required this.categoryDiversityDetail,
    required this.categoryDiversityProgress,
    required this.isEligibleForNextLevel,
    required this.targetRole,
    required this.statusSummary,
    required this.unlockedResponsibilities,
  });

  // Backward compatibility getters
  bool get contributionPassed => karmaPassed;
  String get contributionDetail => karmaDetail;
  double get contributionProgress => karmaProgress;

  double get overallProgress =>
      (karmaProgress + verificationProgress + trustProgress + conductProgress + categoryDiversityProgress) / 5.0;
}

/// Demotion evaluation model
class DemotionRiskResult {
  final bool isAtRisk;
  final bool isCurrentlySuspended;
  final String? warningMessage;
  final double currentTrust;
  final double requiredTrust;
  final int violationCount;

  const DemotionRiskResult({
    required this.isAtRisk,
    required this.isCurrentlySuspended,
    this.warningMessage,
    required this.currentTrust,
    required this.requiredTrust,
    required this.violationCount,
  });
}

class PromotionEngine {
  /// Evaluates 2D quadrant classification for any user
  static KarmaTrustQuadrant evaluateQuadrant(UserProfile user) {
    final hasHighKarma = user.karmaCredits >= 1000 || user.verifiedSubmissions >= 25;
    final hasHighTrust = user.trustScore >= 0.80;

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

  /// Evaluates Demotion & Privilege Suspension
  static DemotionRiskResult evaluateDemotionRisk(UserProfile user) {
    final role = user.communityRole;
    final requiredTrust = role.minTrustScore;
    final currentTrust = user.trustScore;
    final violations = user.conductViolationsCount;

    if (violations > 0) {
      return DemotionRiskResult(
        isAtRisk: true,
        isCurrentlySuspended: true,
        warningMessage: 'Privileges suspended due to $violations conduct violation(s). Contact Trust & Safety to appeal.',
        currentTrust: currentTrust,
        requiredTrust: requiredTrust,
        violationCount: violations,
      );
    }

    if (requiredTrust > 0 && currentTrust < requiredTrust) {
      return DemotionRiskResult(
        isAtRisk: true,
        isCurrentlySuspended: true,
        warningMessage: 'Trust score (${(currentTrust * 100).toInt()}%) has fallen below required ${(requiredTrust * 100).toInt()}% threshold for ${role.title}. Privileges temporarily paused.',
        currentTrust: currentTrust,
        requiredTrust: requiredTrust,
        violationCount: 0,
      );
    }

    // Near threshold warning (within 3%)
    if (requiredTrust > 0 && (currentTrust - requiredTrust) <= 0.03) {
      return DemotionRiskResult(
        isAtRisk: true,
        isCurrentlySuspended: false,
        warningMessage: 'Warning: Trust score (${(currentTrust * 100).toInt()}%) is close to minimum ${(requiredTrust * 100).toInt()}% threshold for ${role.title}.',
        currentTrust: currentTrust,
        requiredTrust: requiredTrust,
        violationCount: 0,
      );
    }

    return DemotionRiskResult(
      isAtRisk: false,
      isCurrentlySuspended: false,
      currentTrust: currentTrust,
      requiredTrust: requiredTrust,
      violationCount: 0,
    );
  }

  /// Evaluates exact numerical criteria for next level progression
  static PromotionGateResult evaluateNextLevelGates(UserProfile user) {
    final currentRole = user.communityRole;

    switch (currentRole) {
      case CommunityRole.newMember:
        // Target: Level 2 Contributor (100+ Karma, >= 5 verified deeds, >= 70% trust, clean record)
        final karmaPass = user.karmaCredits >= 100;
        final karmaProg = (user.karmaCredits / 100.0).clamp(0.0, 1.0);

        final verifPass = user.verifiedSubmissions >= 5;
        final verifProg = (user.verifiedSubmissions / 5.0).clamp(0.0, 1.0);

        final trustPass = user.trustScore >= 0.70;
        final trustProg = (user.trustScore / 0.70).clamp(0.0, 1.0);

        final conductPass = user.conductViolationsCount == 0;
        final conductProg = conductPass ? 1.0 : 0.0;

        final diversityPass = user.effectiveDistinctCategoriesCount >= 1;
        final diversityProg = 1.0;

        final eligible = karmaPass && verifPass && trustPass && conductPass;

        return PromotionGateResult(
          karmaPassed: karmaPass,
          karmaDetail: '${user.karmaCredits} / 100 Lifetime Karma',
          karmaProgress: karmaProg,
          verificationPassed: verifPass,
          verificationDetail: '${user.verifiedSubmissions} / 5 Verified Deeds',
          verificationProgress: verifProg,
          trustPassed: trustPass,
          trustDetail: '${(user.trustScore * 100).toInt()}% / 70% Trust',
          trustProgress: trustProg,
          conductPassed: conductPass,
          conductDetail: conductPass ? 'Clean record (0 violations)' : '${user.conductViolationsCount} violations',
          conductProgress: conductProg,
          categoryDiversityPassed: diversityPass,
          categoryDiversityDetail: '${user.effectiveDistinctCategoriesCount} / 1 Category',
          categoryDiversityProgress: diversityProg,
          isEligibleForNextLevel: eligible,
          targetRole: CommunityRole.contributor,
          statusSummary: eligible
              ? 'Eligible for Contributor! All 4 promotion criteria met.'
              : 'Requires 100 Lifetime Karma, 5 verified deeds, and ≥70% Trust.',
          unlockedResponsibilities: CommunityRole.contributor.responsibilities,
        );

      case CommunityRole.contributor:
        // Target: Level 3 Trusted Contributor (1,000+ Karma, >= 25 verified deeds, >= 80% trust, >= 5 help deeds)
        final karmaPass = user.karmaCredits >= 1000;
        final karmaProg = (user.karmaCredits / 1000.0).clamp(0.0, 1.0);

        final verifPass = user.verifiedSubmissions >= 25;
        final verifProg = (user.verifiedSubmissions / 25.0).clamp(0.0, 1.0);

        final trustPass = user.trustScore >= 0.80;
        final trustProg = (user.trustScore / 0.80).clamp(0.0, 1.0);

        final conductPass = user.conductViolationsCount == 0 &&
            (user.communityHelpContributionsCount >= 5 || user.verifiedSubmissions >= 25);
        final helpCount = user.communityHelpContributionsCount > 0
            ? user.communityHelpContributionsCount
            : (user.verifiedSubmissions ~/ 5).clamp(0, 5);
        final conductProg = (helpCount / 5.0).clamp(0.0, 1.0);

        final diversityPass = user.effectiveDistinctCategoriesCount >= 2;
        final diversityProg = (user.effectiveDistinctCategoriesCount / 2.0).clamp(0.0, 1.0);

        final eligible = karmaPass && verifPass && trustPass && conductPass && diversityPass;

        return PromotionGateResult(
          karmaPassed: karmaPass,
          karmaDetail: '${user.karmaCredits} / 1,000 Lifetime Karma',
          karmaProgress: karmaProg,
          verificationPassed: verifPass,
          verificationDetail: '${user.verifiedSubmissions} / 25 Verified Deeds',
          verificationProgress: verifProg,
          trustPassed: trustPass,
          trustDetail: '${(user.trustScore * 100).toInt()}% / 80% Trust',
          trustProgress: trustProg,
          conductPassed: conductPass,
          conductDetail: '$helpCount / 5 Community/Help Contributions',
          conductProgress: conductProg,
          categoryDiversityPassed: diversityPass,
          categoryDiversityDetail: '${user.effectiveDistinctCategoriesCount} / 2 Impact Categories',
          categoryDiversityProgress: diversityProg,
          isEligibleForNextLevel: eligible,
          targetRole: CommunityRole.trustedContributor,
          statusSummary: eligible
              ? 'Eligible for Trusted Contributor! Unlocks peer verification authority.'
              : 'Requires 1,000 Karma, 25 verified deeds, ≥80% Trust, and 5 help contributions.',
          unlockedResponsibilities: CommunityRole.trustedContributor.responsibilities,
        );

      case CommunityRole.trustedContributor:
        // Target: Level 4 Community Leader (5,000+ Karma, >= 100 verified deeds, >= 90% trust, >= 3 initiatives)
        final karmaPass = user.karmaCredits >= 5000;
        final karmaProg = (user.karmaCredits / 5000.0).clamp(0.0, 1.0);

        final verifPass = user.verifiedSubmissions >= 100;
        final verifProg = (user.verifiedSubmissions / 100.0).clamp(0.0, 1.0);

        final trustPass = user.trustScore >= 0.90;
        final trustProg = (user.trustScore / 0.90).clamp(0.0, 1.0);

        final initiativesCount = user.completedInitiativesCount > 0
            ? user.completedInitiativesCount
            : user.organizedInitiativesCount;
        final conductPass = user.conductViolationsCount == 0 && initiativesCount >= 3;
        final conductProg = (initiativesCount / 3.0).clamp(0.0, 1.0);

        final diversityPass = user.effectiveDistinctCategoriesCount >= 3;
        final diversityProg = (user.effectiveDistinctCategoriesCount / 3.0).clamp(0.0, 1.0);

        final eligible = karmaPass && verifPass && trustPass && conductPass && diversityPass;

        return PromotionGateResult(
          karmaPassed: karmaPass,
          karmaDetail: '${user.karmaCredits} / 5,000 Lifetime Karma',
          karmaProgress: karmaProg,
          verificationPassed: verifPass,
          verificationDetail: '${user.verifiedSubmissions} / 100 Verified Deeds',
          verificationProgress: verifProg,
          trustPassed: trustPass,
          trustDetail: '${(user.trustScore * 100).toInt()}% / 90% Trust',
          trustProgress: trustProg,
          conductPassed: conductPass,
          conductDetail: '$initiativesCount / 3 Completed Initiatives',
          conductProgress: conductProg,
          categoryDiversityPassed: diversityPass,
          categoryDiversityDetail: '${user.effectiveDistinctCategoriesCount} / 3 Impact Categories',
          categoryDiversityProgress: diversityProg,
          isEligibleForNextLevel: eligible,
          targetRole: CommunityRole.communityLeader,
          statusSummary: eligible
              ? 'Eligible for Community Leader nomination! Ready for portfolio review.'
              : 'Requires 5,000 Karma, 100 verified deeds, ≥90% Trust, and 3 initiatives.',
          unlockedResponsibilities: CommunityRole.communityLeader.responsibilities,
        );

      case CommunityRole.communityLeader:
        // Target: Level 5 Karma Ambassador (25,000+ Karma, >= 300 deeds, >= 95% trust, >= 5 categories, >= 12 mo, Human review)
        final karmaPass = user.karmaCredits >= 25000;
        final karmaProg = (user.karmaCredits / 25000.0).clamp(0.0, 1.0);

        final verifPass = user.verifiedSubmissions >= 300;
        final verifProg = (user.verifiedSubmissions / 300.0).clamp(0.0, 1.0);

        final trustPass = user.trustScore >= 0.95;
        final trustProg = (user.trustScore / 0.95).clamp(0.0, 1.0);

        // Impact Diversity Gate: Must span at least 5 distinct categories
        final diversityPass = user.effectiveDistinctCategoriesCount >= 5;
        final diversityProg = (user.effectiveDistinctCategoriesCount / 5.0).clamp(0.0, 1.0);

        final conductPass = user.conductViolationsCount == 0 &&
            user.accountAgeMonths >= 12 &&
            user.isAmbassadorApproved;
        final conductProg = user.isAmbassadorApproved ? 1.0 : (user.isAmbassadorNominated ? 0.75 : 0.4);

        final eligible = karmaPass && verifPass && trustPass && diversityPass && user.isAmbassadorApproved;

        return PromotionGateResult(
          karmaPassed: karmaPass,
          karmaDetail: '${user.karmaCredits} / 25,000 Lifetime Karma',
          karmaProgress: karmaProg,
          verificationPassed: verifPass,
          verificationDetail: '${user.verifiedSubmissions} / 300 Verified Deeds',
          verificationProgress: verifProg,
          trustPassed: trustPass,
          trustDetail: '${(user.trustScore * 100).toInt()}% / 95% Trust',
          trustProgress: trustProg,
          conductPassed: user.isAmbassadorApproved,
          conductDetail: user.isAmbassadorApproved
              ? 'Governance Board Approved (${user.accountAgeMonths} mo standing)'
              : (user.isAmbassadorNominated ? 'Nomination Under Board Review' : 'Requires Governance Review + ≥12 mo standing'),
          conductProgress: conductProg,
          categoryDiversityPassed: diversityPass,
          categoryDiversityDetail: '${user.effectiveDistinctCategoriesCount} / 5 Impact Categories (Diversity Gate)',
          categoryDiversityProgress: diversityProg,
          isEligibleForNextLevel: eligible,
          targetRole: CommunityRole.karmaAmbassador,
          statusSummary: user.isAmbassadorApproved
              ? 'Conferred Karma Ambassador! Highest honor of values representation.'
              : 'Requires 25,000 Karma, 300 deeds, ≥95% Trust, 5+ categories & Board Approval.',
          unlockedResponsibilities: CommunityRole.karmaAmbassador.responsibilities,
        );

      case CommunityRole.karmaAmbassador:
        return const PromotionGateResult(
          karmaPassed: true,
          karmaDetail: '25,000+ Lifetime Karma achieved',
          karmaProgress: 1.0,
          verificationPassed: true,
          verificationDetail: '300+ Verified Master Portfolio',
          verificationProgress: 1.0,
          trustPassed: true,
          trustDetail: '95%+ Audited Long-term Trust',
          trustProgress: 1.0,
          conductPassed: true,
          conductDetail: 'Governance Board Approved & In Good Standing',
          conductProgress: 1.0,
          categoryDiversityPassed: true,
          categoryDiversityDetail: '5+ Cross-Domain Impact Categories Active',
          categoryDiversityProgress: 1.0,
          isEligibleForNextLevel: false,
          targetRole: CommunityRole.karmaAmbassador,
          statusSummary: 'You hold the highest community responsibility: Karma Ambassador.',
          unlockedResponsibilities: [
            'Represent Karma Grid in approved programs and keynote panels',
            'Mentor Community Leaders across regional chapters',
            'Participate in major ESG and corporate civic campaigns',
            'Advise municipal and international impact partners',
            'Lead network expansion across diverse impact domains',
          ],
        );
    }
  }
}