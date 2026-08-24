import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/karma_action.dart';
import '../../models/karma_category.dart';
import '../../models/user_profile.dart';
import '../../models/challenge.dart';
import '../../data/karma_grid_presets.dart';
import '../../models/karma_activity.dart';
import '../../repositories/karma_repo.dart';
import 'mock_auth_service.dart';
import 'mock_firewall_service.dart';

class MockKarmaService implements KarmaRepository {
  final MockAuthService _authService;
  final StreamController<List<KarmaAction>> _actionsStreamController = StreamController<List<KarmaAction>>.broadcast();
  final List<KarmaAction> _inMemoryActions = [];

  MockKarmaService(this._authService) {
    _initActions();
  }

  Future<void> _initActions() async {
    final prefs = await SharedPreferences.getInstance();
    final storedJson = prefs.getString('mock_karma_actions');

    if (storedJson != null) {
      try {
        final List<dynamic> list = jsonDecode(storedJson);
        _inMemoryActions.clear();
        _inMemoryActions.addAll(list.map((item) => KarmaAction.fromJson(item as Map<String, dynamic>)));
      } catch (e) {
        _loadSeedActions();
      }
    } else {
      _loadSeedActions();
    }
    _broadcast();
  }

  void _loadSeedActions() {
    _inMemoryActions.clear();
    _inMemoryActions.addAll([
      KarmaAction(
        id: 'action_seed_1',
        userId: 'user_john',
        userName: 'John Doe',
        title: 'Planted 5 Saplings',
        description: 'Planted 5 oak tree saplings in the local community park to restore green cover.',
        category: KarmaCategory.environment,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        status: DeedStatus.verified,
        confidenceScore: 0.95,
        creditsAwarded: 50,
        latitude: 37.7749,
        longitude: -122.4194,
        witnessEmail: 'park_commissioner@city.org',
        blockchainHash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      ),
      KarmaAction(
        id: 'action_seed_2',
        userId: 'user_john',
        userName: 'John Doe',
        title: 'Fed Stray Animals',
        description: 'Provided water and dry food for 10 stray dogs and cats in the neighborhood.',
        category: KarmaCategory.animalWelfare,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        status: DeedStatus.verified,
        confidenceScore: 0.88,
        creditsAwarded: 40,
        latitude: 37.7752,
        longitude: -122.4178,
        blockchainHash: 'a589f68298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b369',
      ),
      KarmaAction(
        id: 'action_seed_3',
        userId: 'user_jane',
        userName: 'Jane Smith (Validator)',
        title: 'Free Coding Mentorship',
        description: 'Spent 2 hours mentoring students from underrepresented backgrounds in Dart/Flutter.',
        category: KarmaCategory.education,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        status: DeedStatus.verified,
        confidenceScore: 0.90,
        creditsAwarded: 30,
        witnessEmail: 'students@academy.org',
        blockchainHash: 'bc7f9e8298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b123',
      ),
      KarmaAction(
        id: 'action_seed_4',
        userId: 'user_john',
        userName: 'John Doe',
        title: 'Helped Elderly Neighbor',
        description: 'Assisted Mr. Abernathy with groceries, carrying them up three flights of stairs.',
        category: KarmaCategory.humanKindness,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        status: DeedStatus.pending,
        confidenceScore: 0.60,
        creditsAwarded: 0,
        witnessEmail: 'abernathy@email.com',
      ),
    ]);
    _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'mock_karma_actions',
      jsonEncode(_inMemoryActions.map((e) => e.toJson()).toList()),
    );
  }

  void _broadcast() {
    _actionsStreamController.add(List.unmodifiable(_inMemoryActions));
  }

  @override
  Future<List<KarmaAction>> fetchKarmaActions({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (userId != null) {
      return _inMemoryActions.where((element) => element.userId == userId).toList();
    }
    return _inMemoryActions;
  }

  @override
  Future<KarmaAction> submitKarmaAction(KarmaAction action) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final currentUser = await _authService.getCurrentUser();
    final userHistory = _inMemoryActions.where((e) => e.userId == action.userId).toList();

    final verdict = MockFirewallService.evaluate(
      action: action,
      user: currentUser ?? UserProfile(id: action.userId, name: action.userName, email: 'user@karma.com'),
      userHistory: userHistory,
    );

    // Apply audit impact to trust score
    UserProfile profileToUpdate = currentUser ?? UserProfile(id: action.userId, name: action.userName, email: 'user@karma.com');
    if (verdict.isAudited) {
      double newTrust = profileToUpdate.trustScore;
      if (verdict.auditPassed) {
        newTrust = (newTrust + 0.02).clamp(0.0, 1.0);
      } else {
        newTrust = (newTrust - 0.10).clamp(0.0, 1.0);
      }
      profileToUpdate = profileToUpdate.copyWith(trustScore: newTrust);
    }

    final int calculatedRipple = ((verdict.provisionalCredits + verdict.verifiedCredits + verdict.outcomeCredits) * 0.20).round();

    final newAction = action.copyWith(
      confidenceScore: verdict.confidenceScore,
      provisionalCredits: verdict.provisionalCredits,
      verifiedCredits: verdict.verifiedCredits,
      outcomeCredits: verdict.outcomeCredits,
      isAudited: verdict.isAudited,
      auditPassed: verdict.auditPassed,
      status: verdict.status,
      evidenceScore: verdict.evidenceScore,
      rippleCredits: verdict.status == DeedStatus.verified ? calculatedRipple : 0,
      creditsAwarded: verdict.status == DeedStatus.verified ? (verdict.provisionalCredits + verdict.verifiedCredits) : 0,
    );

    _inMemoryActions.insert(0, newAction);
    await _saveToPrefs();
    _broadcast();

    // Update submitter's total submissions and add provisional credits
    final submitterId = action.userId;
    if (currentUser != null && currentUser.id == submitterId) {
      int addedCredits = verdict.provisionalCredits;
      if (newAction.status == DeedStatus.verified) {
        addedCredits += verdict.verifiedCredits + calculatedRipple;
      }
      final finalProfile = profileToUpdate.copyWith(
        totalSubmissions: profileToUpdate.totalSubmissions + 1,
        verifiedSubmissions: newAction.status == DeedStatus.verified 
            ? profileToUpdate.verifiedSubmissions + 1 
            : profileToUpdate.verifiedSubmissions,
        karmaCredits: profileToUpdate.karmaCredits + addedCredits,
      );
      _authService.updateLocalUserProfile(finalProfile);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_$submitterId', jsonEncode(finalProfile.toJson()));
    }

    return newAction;
  }

  @override
  Future<KarmaAction> voteOnKarmaAction(String deedId, String validatorId, bool approve) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final idx = _inMemoryActions.indexWhere((element) => element.id == deedId);
    if (idx == -1) throw Exception('Karma action not found');

    var action = _inMemoryActions[idx];
    final Map<String, bool> newVotes = Map.from(action.validatorVotes);
    newVotes[validatorId] = approve;

    DeedStatus newStatus = action.status;
    int creditsAwarded = action.creditsAwarded;
    String? hash = action.blockchainHash;

    // Calculate verification consensus
    // In our mock logic, let's say if it gets 2 approvals or an approval from a validator with high reputation, it gets verified.
    // Let's assume user Jane has high reputation and her vote triggers verification. Or 2 net votes verify it.
    final approvals = newVotes.values.where((v) => v).length;
    final rejections = newVotes.values.where((v) => !v).length;

    // Fetch the validator's profile to check reputation weight
    final prefs = await SharedPreferences.getInstance();
    final validatorProfileJson = prefs.getString('profile_$validatorId');
    int validatorRep = 50;
    if (validatorProfileJson != null) {
      final valMap = jsonDecode(validatorProfileJson);
      validatorRep = valMap['reputationScore'] ?? 50;
    }

    // High reputation validator vote or net 2 approvals verifies the action
    bool shouldCredit = false;
    bool shouldPenalize = false;

    if (action.status == DeedStatus.pending) {
      if ((approve && validatorRep >= 80) || (approvals - rejections >= 2)) {
        newStatus = DeedStatus.verified;
        
        // 1. Fetch base impact from taxonomy presets if title matches
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

        int baseCredits = 30;
        if (matchedPreset != null) {
          baseCredits = matchedPreset.baseImpact;
        } else {
          switch (action.category) {
            case KarmaCategory.environment:
              baseCredits = 50;
              break;
            case KarmaCategory.animalWelfare:
              baseCredits = 40;
              break;
            case KarmaCategory.innovation:
              baseCredits = 80;
              break;
            case KarmaCategory.healthcare:
              baseCredits = 45;
              break;
            case KarmaCategory.education:
              baseCredits = 35;
              break;
            default:
              baseCredits = 30;
          }
        }

        // 2. Dynamic Impact splits mapping
        creditsAwarded = action.provisionalCredits + action.verifiedCredits;
        final calculatedRipple = ((action.provisionalCredits + action.verifiedCredits + action.outcomeCredits) * 0.20).round();

        // Generate simulated SHA-256 block hash for this verified deed
        final blockData = '${action.id}-${action.userId}-${action.timestamp.toIso8601String()}-$creditsAwarded-$calculatedRipple';
        hash = sha256.convert(utf8.encode(blockData)).toString();

        action = action.copyWith(
          rippleCredits: calculatedRipple,
        );

        shouldCredit = true;
      } else if (rejections - approvals >= 2) {
        newStatus = DeedStatus.rejected;
        shouldPenalize = true;
      }
    }

    final updatedAction = action.copyWith(
      validatorVotes: newVotes,
      status: newStatus,
      creditsAwarded: creditsAwarded,
      blockchainHash: hash,
    );

    _inMemoryActions[idx] = updatedAction;
    await _saveToPrefs();
    _broadcast();

    // Perform profile changes after broadcasting deed status to avoid provider race conditions
    if (shouldCredit) {
      final totalCredits = updatedAction.verifiedCredits + updatedAction.rippleCredits;
      await _creditUserForVerifiedDeed(action.userId, totalCredits, action.category.name);
    } else if (shouldPenalize) {
      await _adjustUserReputation(action.userId, -5);
    }

    return updatedAction;
  }

  Future<void> _creditUserForVerifiedDeed(String userId, int credits, String categoryName) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('profile_$userId');
    if (profileJson != null) {
      final userMap = jsonDecode(profileJson);
      final profile = UserProfile.fromJson(userMap);
      
      final Map<String, int> catCredits = Map.from(profile.categoryCredits);
      catCredits[categoryName] = (catCredits[categoryName] ?? 0) + credits;

      // Reputation logic: Increase reputation score slightly on verification (+2)
      int newRep = (profile.reputationScore + 2).clamp(0, 100);
      int bonusCredits = 0;

      // Check challenges progress
      final challengeKey = 'challenges_$userId';
      final storedChallenges = prefs.getString(challengeKey);
      if (storedChallenges != null) {
        final List<dynamic> challengeList = jsonDecode(storedChallenges);
        final List<KarmaChallenge> challenges = challengeList.map((e) => KarmaChallenge.fromJson(e)).toList();
        
        bool challengeUpdated = false;
        // Count verified deeds in this category (including this one!)
        final count = _inMemoryActions
            .where((action) =>
                action.userId == userId &&
                action.category.name == categoryName &&
                action.status == DeedStatus.verified)
            .length;

        for (int i = 0; i < challenges.length; i++) {
          final ch = challenges[i];
          if (ch.category.name == categoryName && ch.isAccepted && !ch.isCompleted) {
            if (count >= ch.targetCount) {
              challenges[i] = ch.copyWith(
                currentCount: ch.targetCount,
                isCompleted: true,
              );
              bonusCredits += ch.rewardCredits;
              newRep = (newRep + 5).clamp(0, 100); // bump reputation by 5 on challenge completion!
              challengeUpdated = true;
            } else if (count != ch.currentCount) {
              challenges[i] = ch.copyWith(currentCount: count);
              challengeUpdated = true;
            }
          }
        }

        if (challengeUpdated) {
          await prefs.setString(challengeKey, jsonEncode(challenges.map((e) => e.toJson()).toList()));
        }
      }

      final updatedProfile = profile.copyWith(
        karmaCredits: profile.karmaCredits + credits + bonusCredits,
        reputationScore: newRep,
        verifiedSubmissions: profile.verifiedSubmissions + 1,
        categoryCredits: catCredits,
      );

      // Save user profile back to prefs
      await prefs.setString('profile_$userId', jsonEncode(updatedProfile.toJson()));

      // If this is currently logged in user, notify Auth Service to update in-memory state
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null && currentUser.id == userId) {
        _authService.updateLocalUserProfile(updatedProfile);
      }
    }
  }

  Future<void> _adjustUserReputation(String userId, int change) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('profile_$userId');
    if (profileJson != null) {
      final userMap = jsonDecode(profileJson);
      final profile = UserProfile.fromJson(userMap);
      
      final int newRep = (profile.reputationScore + change).clamp(0, 100);
      final updatedProfile = profile.copyWith(reputationScore: newRep);

      await prefs.setString('profile_$userId', jsonEncode(updatedProfile.toJson()));

      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null && currentUser.id == userId) {
        _authService.updateLocalUserProfile(updatedProfile);
      }
    }
  }

  @override
  Stream<List<KarmaAction>> streamKarmaActions({String? userId}) {
    // Return filtered or unfiltered actions
    Timer.run(() => _broadcast()); // trigger initial broadcast
    return _actionsStreamController.stream.map((list) {
      if (userId != null) {
        return list.where((element) => element.userId == userId).toList();
      }
      return list;
    });
  }

  @override
  Stream<List<KarmaAction>> streamPendingActions() {
    Timer.run(() => _broadcast());
    return _actionsStreamController.stream.map((list) {
      return list.where((element) => element.status == DeedStatus.pending).toList();
    });
  }
}
