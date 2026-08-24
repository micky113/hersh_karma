import 'dart:math';
import '../../models/karma_action.dart';
import '../../models/user_profile.dart';
import '../../data/karma_grid_presets.dart';
import '../../models/karma_activity.dart';

class FirewallVerdict {
  final double confidenceScore;
  final int provisionalCredits;
  final int verifiedCredits;
  final int outcomeCredits;
  final double diminishingReturnsMultiplier;
  final bool isAudited;
  final bool auditPassed;
  final bool speedWarningTriggered;
  final bool duplicateEvidenceTriggered;
  final String message;
  final int evidenceScore;
  final DeedStatus status;

  FirewallVerdict({
    required this.confidenceScore,
    required this.provisionalCredits,
    required this.verifiedCredits,
    required this.outcomeCredits,
    required this.diminishingReturnsMultiplier,
    required this.isAudited,
    required this.auditPassed,
    required this.speedWarningTriggered,
    required this.duplicateEvidenceTriggered,
    required this.message,
    required this.evidenceScore,
    required this.status,
  });
}

class MockFirewallService {
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simple Euclidean distance approximation for local geofence testing
    final p = pi / 180;
    final a = 0.5 - cos((lat2 - lat1) * p)/2 + 
          cos(lat1 * p) * cos(lat2 * p) * 
          (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  static FirewallVerdict evaluate({
    required KarmaAction action,
    required UserProfile user,
    required List<KarmaAction> userHistory,
  }) {
    double confidence = 0.5;
    double diminishingReturns = 1.0;
    bool isAudited = false;
    bool auditPassed = true;
    bool speedWarning = false;
    bool duplicateEvidence = false;
    String statusMessage = 'Shield Active: Security analysis completed.';

    // 1. Anti-Repetition Check (Diminishing returns)
    final sameTitleActions = userHistory.where((e) => e.title == action.title).toList();
    if (sameTitleActions.isNotEmpty) {
      if (sameTitleActions.length == 1) {
        diminishingReturns = 0.70;
        statusMessage = 'Diminishing Returns: 2nd cleanup today (70% reward).';
      } else if (sameTitleActions.length == 2) {
        diminishingReturns = 0.40;
        statusMessage = 'Diminishing Returns: 3rd cleanup today (40% reward).';
      } else {
        diminishingReturns = 0.10;
        statusMessage = 'Diminishing Returns: 4th+ cleanup today (10% reward).';
      }
    }

    // 2. Double-Submit / Photo Duplicate Check
    if (action.imageUrl != null && action.imageUrl!.isNotEmpty) {
      final imageMatches = userHistory.where((e) => e.imageUrl == action.imageUrl);
      if (imageMatches.isNotEmpty) {
        duplicateEvidence = true;
        confidence = 0.10;
        statusMessage = 'CRITICAL: Reused/Duplicate photo evidence detected. Rejected.';
      }
    }

    // 3. Travel Speed Velocity Check
    if (userHistory.isNotEmpty && action.latitude != null && action.longitude != null) {
      final lastAction = userHistory.first;
      if (lastAction.latitude != null && lastAction.longitude != null) {
        final dist = _calculateDistance(action.latitude!, action.longitude!, lastAction.latitude!, lastAction.longitude!);
        final timeDeltaHrs = action.timestamp.difference(lastAction.timestamp).inSeconds.abs() / 3600.0;
        
        if (timeDeltaHrs > 0.0) {
          final speed = dist / timeDeltaHrs;
          if (speed > 200.0) { // Speed > 200 km/h is impossible/suspicious
            speedWarning = true;
            confidence = 0.20;
            statusMessage = 'WARNING: Impossible travel speed detected (${speed.toStringAsFixed(1)} km/h). Scrutiny flagged.';
          }
        }
      }
    }

    // 4. Random Audit selection (5% chance based on action ID hash)
    if (action.id.contains('audit') || action.id.hashCode % 20 == 0) {
      isAudited = true;
      if (user.trustScore < 0.5) {
        auditPassed = false;
        confidence = 0.15;
        statusMessage = 'AUDIT FAILED: Background account risk audit failed due to low trust.';
      } else {
        auditPassed = true;
        statusMessage = 'AUDIT PASSED: Account trust audit completed successfully.';
      }
    }

    // 5. Calculate base confidence score based on verification proof details
    if (!duplicateEvidence && !speedWarning) {
      double proofStrength = 0.4; // Self-verification base
      if (action.imageUrl != null && action.imageUrl!.isNotEmpty) proofStrength += 0.25;
      if (action.latitude != null && action.longitude != null) proofStrength += 0.20;
      if (action.witnessEmail != null && action.witnessEmail!.isNotEmpty) proofStrength += 0.15;
      if (action.anonymizedWitnessCode != null && action.anonymizedWitnessCode!.isNotEmpty) proofStrength += 0.30; // organization check

      // Factor in user trust score
      confidence = (proofStrength * user.trustScore).clamp(0.1, 1.0);
    }

    // 6. Calculate 100-point Evidence Score
    int evidenceScore = 0;
    if (action.latitude != null && action.longitude != null) {
      evidenceScore += 20;
    }
    if (action.sceneMatchConfidence != null && action.sceneMatchConfidence! >= 0.85) {
      evidenceScore += 20;
    }
    if (action.capturedInApp) {
      evidenceScore += 20;
    }
    if (action.wasteBeforeCount != null && action.wasteAfterCount != null && action.wasteBeforeCount! > action.wasteAfterCount!) {
      evidenceScore += 15;
    }
    if (action.latitude != null && !speedWarning) {
      evidenceScore += 10;
    }
    if (!duplicateEvidence) {
      evidenceScore += 10;
    }
    if (user.trustScore >= 0.90) {
      evidenceScore += 5;
    }

    DeedStatus routingStatus = DeedStatus.pending;
    if (action.verificationLevel == 1) {
      routingStatus = DeedStatus.pending;
      statusMessage = 'PENDING: Level 1 self-verification queued for validation.';
    } else if (evidenceScore >= 90) {
      routingStatus = DeedStatus.verified;
      statusMessage = 'AUTO-VERIFIED: Evidence score is excellent ($evidenceScore/100).';
    } else if (evidenceScore >= 70) {
      routingStatus = DeedStatus.pending;
      statusMessage = 'PENDING: Adequate evidence score ($evidenceScore/100). Queueing for manual review.';
    } else {
      routingStatus = DeedStatus.rejected;
      statusMessage = 'REJECTED: Insufficient evidence score ($evidenceScore/100). Hold placed.';
    }

    if (duplicateEvidence || speedWarning) {
      routingStatus = DeedStatus.rejected;
    }

    final bool hasBefore = action.beforeImageUrl != null && action.beforeImageUrl!.isNotEmpty;
    final bool hasAfter = action.imageUrl != null && action.imageUrl!.isNotEmpty;
    final bool hasWitnessCode = action.anonymizedWitnessCode != null && action.anonymizedWitnessCode!.isNotEmpty;
    final bool hasEvidencePair = (hasBefore && hasAfter) || hasWitnessCode;

    if (!hasEvidencePair) {
      routingStatus = DeedStatus.rejected;
      confidence = 0.0;
      evidenceScore = 0;
      statusMessage = 'REJECTED: No Proof of Change, No Impact Credit. Both BEFORE and AFTER evidence must be provided.';
    }

    // 7. Split reward calculations
    int baseCredits = 30;
    
    // Fetch base impact from taxonomy presets if title matches
    KarmaActivity? matchedPreset;
    for (final p in karmaGridPresets) {
      if (p.title.trim().toLowerCase() == action.title.trim().toLowerCase()) {
        matchedPreset = p;
        break;
      }
    }
    if (matchedPreset == null) {
      for (final p in karmaGridPresets) {
        if (action.title.toLowerCase().contains(p.title.toLowerCase()) ||
            p.title.toLowerCase().contains(action.title.toLowerCase())) {
          matchedPreset = p;
          break;
        }
      }
    }

    if (matchedPreset != null) {
      baseCredits = matchedPreset.baseImpact;
    } else {
      switch (action.category.name) {
        case 'environment': baseCredits = 50; break;
        case 'animalWelfare': baseCredits = 40; break;
        case 'innovation': baseCredits = 80; break;
        case 'healthcare': baseCredits = 45; break;
        case 'education': baseCredits = 35; break;
        default: baseCredits = 30;
      }
    }
    
    // Scale multiplier: linear scale
    final double scaleMultiplier = action.scale.toDouble();

    // Effort multiplier: Quick (1.0), Deep (2.0), Impact (5.0)
    double effortMultiplier = 1.0;
    if (action.durationCategory == 'Deep') {
      effortMultiplier = 2.0;
    } else if (action.durationCategory == 'Impact') {
      effortMultiplier = 5.0;
    }

    // Quality factor: creativity, participation, ripple bonuses
    double qualityFactor = 1.0;
    if (action.creativityBonus) qualityFactor += 0.10;
    if (action.participationBonus) qualityFactor += 0.15;
    if (action.rippleInspirationBonus) qualityFactor += 0.20;

    // Payout calculation: Verified Impact * Quality * Scale * Effort * Confidence * Diminishing Returns
    final double rawCredits = baseCredits * qualityFactor * scaleMultiplier * effortMultiplier * confidence * diminishingReturns;
    final int finalCredits = rawCredits.round();

    int prov = 0;
    int verified = 0;
    int outcome = 0;

    if (action.verificationLevel == 1) {
      // Level 1: 100% provisional (no hard ceiling anymore!)
      prov = finalCredits;
    } else {
      // Level 2-5 splits: 30% provisional, 50% verified, 20% outcome milestones
      prov = (finalCredits * 0.30).round();
      verified = (finalCredits * 0.50).round();
      outcome = (finalCredits * 0.20).round();
      
      // Ensure rounding errors don't lose points
      final sum = prov + verified + outcome;
      if (sum < finalCredits) {
        verified += (finalCredits - sum);
      }
    }

    return FirewallVerdict(
      confidenceScore: double.parse(confidence.toStringAsFixed(2)),
      provisionalCredits: prov,
      verifiedCredits: verified,
      outcomeCredits: outcome,
      diminishingReturnsMultiplier: diminishingReturns,
      isAudited: isAudited,
      auditPassed: auditPassed,
      speedWarningTriggered: speedWarning,
      duplicateEvidenceTriggered: duplicateEvidence,
      message: statusMessage,
      evidenceScore: evidenceScore,
      status: routingStatus,
    );
  }
}
