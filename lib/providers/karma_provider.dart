import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../models/karma_action.dart';
import '../models/karma_category.dart';
import '../models/karma_activity.dart';
import '../models/challenge.dart';
import '../models/wish.dart';
import '../repositories/karma_repo.dart';
import '../services/firebase/firebase_storage_service.dart';
import '../services/firebase/firebase_karma_service.dart';
import 'auth_provider.dart';
import '../models/app_feedback.dart';
import '../models/community_problem.dart';
import '../models/user_profile.dart';

class KarmaProvider extends ChangeNotifier {
  final KarmaRepository _karmaRepository;
  
  List<KarmaAction> _allActions = [];
  List<KarmaAction> _myActions = [];
  List<KarmaAction> _pendingValidationActions = [];
  List<KarmaChallenge> _challenges = [];
  List<Wish> _allWishes = [];
  List<CommunityProblem> _problems = [];
  
  List<AppFeedback> _feedbacks = [
    AppFeedback(
      id: 'fb_1',
      screenContext: 'ChallengesScreen',
      category: FeedbackCategory.idea,
      details: 'Schools should be able to create challenges.',
      usefulVotes: 14,
      notUsefulVotes: 2,
      status: FeedbackStatus.reviewing,
      aiClassification: 'Usability',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
    AppFeedback(
      id: 'fb_2',
      screenContext: 'ProofCaptureScreen',
      category: FeedbackCategory.idea,
      details: 'Add Hindi voice support to the capture screens.',
      usefulVotes: 28,
      notUsefulVotes: 0,
      status: FeedbackStatus.implemented,
      aiClassification: 'Language',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),
    AppFeedback(
      id: 'fb_3',
      screenContext: 'DashboardScreen',
      category: FeedbackCategory.broken,
      details: 'This action isn\'t possible in my village due to offline GPS geofence restrictions.',
      usefulVotes: 9,
      notUsefulVotes: 1,
      status: FeedbackStatus.testing,
      aiClassification: 'Local Need',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
  
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  KarmaActivity? _prefilledPreset;

  StreamSubscription<List<KarmaAction>>? _allActionsSub;
  StreamSubscription<List<KarmaAction>>? _pendingActionsSub;
  
  String? _activeUserId;
  AuthProvider? _authProvider;

  KarmaProvider(this._karmaRepository);

  List<KarmaAction> get allActions => _allActions;
  List<KarmaAction> get myActions => _myActions;
  List<KarmaAction> get pendingValidationActions => _pendingValidationActions;
  List<KarmaChallenge> get challenges => _challenges;
  List<Wish> get allWishes => _allWishes;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  KarmaActivity? get prefilledPreset => _prefilledPreset;

  set prefilledPreset(KarmaActivity? p) {
    _prefilledPreset = p;
    notifyListeners();
  }

  void clearPrefilledPreset() {
    _prefilledPreset = null;
  }

  void update(AuthProvider auth) {
    _authProvider = auth;
    final userId = auth.currentUser?.id;
    if (_activeUserId == userId) {
      // If user is logged in, recalculate challenges in case deeds got verified
      if (userId != null) {
        _recalculateChallengesProgress();
      }
      return;
    }
    
    _activeUserId = userId;
    _allActionsSub?.cancel();
    _pendingActionsSub?.cancel();

    if (userId != null) {
      _isLoading = true;
      notifyListeners();

      _loadChallenges(userId);
      _loadWishes(userId);
      _loadProblems(userId);

      // Listen to all actions (includes my own and others)
      _allActionsSub = _karmaRepository.streamKarmaActions().listen((actions) {
        _allActions = actions;
        _myActions = actions.where((e) => e.userId == userId).toList();
        _recalculateChallengesProgress();
        _isLoading = false;
        notifyListeners();
      }, onError: (err) {
        _error = err.toString();
        _isLoading = false;
        notifyListeners();
      });

      // Listen to pending actions for validator review (excluding user's own actions so they can't vote on their own!)
      _pendingActionsSub = _karmaRepository.streamPendingActions().listen((actions) {
        _pendingValidationActions = actions.where((e) => e.userId != userId).toList();
        notifyListeners();
      });
    } else {
      _allActions = [];
      _myActions = [];
      _pendingValidationActions = [];
      _challenges = [];
      _allWishes = [];
      _problems = [];
      notifyListeners();
    }
  }

  Future<void> _loadChallenges(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'challenges_$userId';
    final storedJson = prefs.getString(key);

    if (storedJson != null) {
      try {
        final List<dynamic> list = jsonDecode(storedJson);
        _challenges = list.map((item) => KarmaChallenge.fromJson(item as Map<String, dynamic>)).toList();
      } catch (e) {
        _seedDefaultChallenges(userId);
      }
    } else {
      _seedDefaultChallenges(userId);
    }
    notifyListeners();
  }

  void _seedDefaultChallenges(String userId) async {
    _challenges = [
      KarmaChallenge(
        id: 'challenge_trees',
        title: 'Plant 5 Saplings',
        description: 'Plant 5 tree saplings in your community to rebuild the ecosystem.',
        category: KarmaCategory.environment,
        targetCount: 5,
        rewardCredits: 100,
      ),
      KarmaChallenge(
        id: 'challenge_animals',
        title: 'Stray Animal Protector',
        description: 'Provide food and clean water to stray dogs, cats, or birds 5 times.',
        category: KarmaCategory.animalWelfare,
        targetCount: 5,
        rewardCredits: 80,
      ),
      KarmaChallenge(
        id: 'challenge_mentorship',
        title: 'Share Knowledge',
        description: 'Mentor or teach someone from underprivileged backgrounds 3 times.',
        category: KarmaCategory.education,
        targetCount: 3,
        rewardCredits: 70,
      ),
      KarmaChallenge(
        id: 'challenge_cleanup',
        title: 'Keep it Clean',
        description: 'Organize or participate in a public space cleaning drive 3 times.',
        category: KarmaCategory.communityService,
        targetCount: 3,
        rewardCredits: 60,
      ),
    ];
    _saveChallenges(userId);
  }

  Future<void> _saveChallenges(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'challenges_$userId';
    await prefs.setString(key, jsonEncode(_challenges.map((e) => e.toJson()).toList()));
  }

  Future<void> acceptChallenge(String challengeId) async {
    if (_activeUserId == null) return;
    
    final idx = _challenges.indexWhere((e) => e.id == challengeId);
    if (idx != -1 && !_challenges[idx].isAccepted) {
      _challenges[idx] = _challenges[idx].copyWith(isAccepted: true);
      await _saveChallenges(_activeUserId!);
      _recalculateChallengesProgress();
      notifyListeners();
    }
  }

  void _recalculateChallengesProgress() async {
    if (_activeUserId == null || _challenges.isEmpty) return;

    bool updated = false;
    for (int i = 0; i < _challenges.length; i++) {
      final challenge = _challenges[i];
      if (challenge.isAccepted && !challenge.isCompleted) {
        // Count matching verified actions the user completed
        final count = _myActions
            .where((action) =>
                action.category == challenge.category &&
                action.status == DeedStatus.verified)
            .length;

        if (count != challenge.currentCount) {
          final isNowCompleted = count >= challenge.targetCount;
          _challenges[i] = challenge.copyWith(
            currentCount: count.clamp(0, challenge.targetCount),
            isCompleted: isNowCompleted,
          );
          updated = true;
        }
      }
    }

    if (updated) {
      await _saveChallenges(_activeUserId!);
      notifyListeners();
    }
  }

  Future<bool> submitDeed({
    required String title,
    required String description,
    required KarmaCategory category,
    required String userName,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? witnessEmail,
    int scale = 1,
    double confidenceScore = 0.5,
    String durationCategory = 'Quick',
    String impactScope = 'Individual',
    bool creativityBonus = false,
    bool participationBonus = false,
    bool rippleInspirationBonus = false,
    int verificationLevel = 1,
    int proofBondStaked = 0,
    String? anonymizedWitnessCode,
    bool capturedInApp = false,
    int evidenceScore = 0,
    String? beforeImageUrl,
    int? wasteBeforeCount,
    int? wasteAfterCount,
    double? sceneMatchConfidence,
    XFile? beforeImageFile,
    XFile? afterImageFile,
  }) async {
    if (_activeUserId == null) return false;
    
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final deedId = 'deed_${const Uuid().v4()}';
      String? finalBeforeUrl = beforeImageUrl;
      String? finalAfterUrl = imageUrl;

      // Upload actual captured files to Firebase Storage if provided
      if (beforeImageFile != null || afterImageFile != null) {
        final uploadResults = await FirebaseStorageService().uploadProofPair(
          userId: _activeUserId!,
          deedId: deedId,
          beforeFile: beforeImageFile,
          afterFile: afterImageFile,
        );
        if (uploadResults['beforeImageUrl'] != null) {
          finalBeforeUrl = uploadResults['beforeImageUrl'];
        }
        if (uploadResults['afterImageUrl'] != null) {
          finalAfterUrl = uploadResults['afterImageUrl'];
        }
      }

      int baseCredits = 350;
      if (verificationLevel == 2) {
        baseCredits = 100;
      } else if (evidenceScore >= 90) {
        baseCredits = 450;
      }
      if (creativityBonus) baseCredits += 50;
      if (participationBonus) baseCredits += 30;
      if (rippleInspirationBonus) baseCredits += 70;
      final totalAwardedCredits = baseCredits * scale;

      final action = KarmaAction(
        id: deedId,
        userId: _activeUserId!,
        userName: userName,
        title: title,
        description: description,
        category: category,
        timestamp: DateTime.now(),
        imageUrl: finalAfterUrl,
        latitude: latitude,
        longitude: longitude,
        witnessEmail: witnessEmail,
        status: (evidenceScore >= 90) ? DeedStatus.verified : DeedStatus.pending,
        creditsAwarded: totalAwardedCredits,
        scale: scale,
        confidenceScore: confidenceScore,
        durationCategory: durationCategory,
        impactScope: impactScope,
        creativityBonus: creativityBonus,
        participationBonus: participationBonus,
        rippleInspirationBonus: rippleInspirationBonus,
        verificationLevel: verificationLevel,
        proofBondStaked: proofBondStaked,
        anonymizedWitnessCode: anonymizedWitnessCode,
        capturedInApp: capturedInApp,
        evidenceScore: evidenceScore,
        beforeImageUrl: finalBeforeUrl,
        wasteBeforeCount: wasteBeforeCount,
        wasteAfterCount: wasteAfterCount,
        sceneMatchConfidence: sceneMatchConfidence,
      );

      await _karmaRepository.submitKarmaAction(action);

      // Increment user total submissions and add earned credits
      if (_authProvider != null) {
        await _authProvider!.addCredits(
          totalAwardedCredits,
          isVerified: (action.status == DeedStatus.verified),
        );
      }

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> voteOnDeed(String deedId, bool approve) async {
    if (_activeUserId == null) return false;
    
    try {
      final updated = await _karmaRepository.voteOnKarmaAction(deedId, _activeUserId!, approve);
      if (updated.status == DeedStatus.verified && _authProvider != null && updated.userId == _activeUserId) {
        await _authProvider!.addCredits(updated.creditsAwarded, isVerified: true);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadWishes(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'wishes_$userId';
    final storedJson = prefs.getString(key);

    if (storedJson != null) {
      try {
        final List<dynamic> list = jsonDecode(storedJson);
        _allWishes = list.map((item) => Wish.fromJson(item as Map<String, dynamic>)).toList();
      } catch (e) {
        _seedDefaultWishes(userId);
      }
    } else {
      _seedDefaultWishes(userId);
    }
    notifyListeners();
  }

  void _seedDefaultWishes(String userId) async {
    _allWishes = [
      Wish(
        id: 'wish_guitar',
        userId: 'user_jane',
        userName: 'Jane Smith (Validator)',
        title: 'I want to learn guitar.',
        description: 'I\'ve always wanted to learn to play the guitar but never had the chance or instrument.',
        category: WishCategory.creativity,
        karmaTarget: 500,
        karmaRaised: 120,
        wishPlan: [
          WishPlanStep(title: 'Find a mentor', isCompleted: true),
          WishPlanStep(title: 'Acquire acoustic guitar', isCompleted: false),
          WishPlanStep(title: 'Practice basic chords plan', isCompleted: false),
          WishPlanStep(title: 'Record a first song cover', isCompleted: false),
        ],
        sponsorContributions: [
          SponsorContribution(
            sponsorName: 'John Doe',
            description: 'Contributed 120 Karma credits towards a sponsor discount.',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
          ),
          SponsorContribution(
            sponsorName: 'Local Music Hub',
            description: 'Offered 20% discount on acoustic guitars for verified Karma users.',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
          SponsorContribution(
            sponsorName: 'Aarav Sharma',
            description: 'मैने एक अतिरिक्त गिटार बुक किया है, मैं उसे दान करना चाहता हूँ।',
            timestamp: DateTime.now().subtract(const Duration(hours: 12)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Wish(
        id: 'wish_water',
        userId: 'user_john',
        userName: 'John Doe',
        title: 'Help my village get clean drinking water.',
        description: 'Our village community well needs a reverse osmosis water filter installation.',
        category: WishCategory.socialImpact,
        karmaTarget: 2000,
        karmaRaised: 1500,
        wishPlan: [
          WishPlanStep(title: 'Survey filtration installation site', isCompleted: true),
          WishPlanStep(title: 'Purchase filtration unit hardware', isCompleted: true),
          WishPlanStep(title: 'Plumbing and electrical integration', isCompleted: false),
          WishPlanStep(title: 'Conduct water purity test', isCompleted: false),
        ],
        sponsorContributions: [
          SponsorContribution(
            sponsorName: 'Jane Smith (Validator)',
            description: 'Contributed 1000 Karma credits towards purchasing unit hardware.',
            timestamp: DateTime.now().subtract(const Duration(days: 4)),
          ),
          SponsorContribution(
            sponsorName: 'WaterAid India NGO',
            description: 'Will provide expert technician services for plumbing setup.',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
          ),
          SponsorContribution(
            sponsorName: 'Electrocorp Ltd',
            description: 'Contributed 500 Karma worth of solar backup panel integrations.',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Wish(
        id: 'wish_laptop',
        userId: 'user_student_raj',
        userName: 'Rajesh Kumar',
        title: 'I need a laptop for my Flutter engineering studies.',
        description: 'I\'m a college student learning software engineering, but lack a decent computer to compile apps.',
        category: WishCategory.education,
        karmaTarget: 1200,
        karmaRaised: 300,
        wishPlan: [
          WishPlanStep(title: 'Complete Git/Flutter basics', isCompleted: true),
          WishPlanStep(title: 'Crowdfund laptop device', isCompleted: false),
          WishPlanStep(title: 'Setup development workstation environment', isCompleted: false),
        ],
        sponsorContributions: [
          SponsorContribution(
            sponsorName: 'TechSponsors NGO',
            description: 'Contributed 300 Karma worth of refurbished device stock availability.',
            timestamp: DateTime.now().subtract(const Duration(hours: 12)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      )
    ];
    _saveWishes(userId);
  }

  Future<void> _saveWishes(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'wishes_$userId';
    await prefs.setString(key, jsonEncode(_allWishes.map((e) => e.toJson()).toList()));
  }

  Future<bool> submitWish({
    required String title,
    required String description,
    required WishCategory category,
    required int karmaTarget,
    int verificationLevel = 1,
    PrivacyLevel privacyLevel = PrivacyLevel.public,
    List<String> evidenceDocumentUrls = const [],
    bool isIdentityVerified = false,
    bool ageConsentVerified = false,
    SponsorshipType sponsorshipType = SponsorshipType.volunteerService,
    String? retailerName,
    bool isMinor = false,
  }) async {
    if (_activeUserId == null || _authProvider?.currentUser == null) return false;

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Prohibited content safety checks
      final prohibitedKeywords = [
        'drugs', 'drug', 'cocaine', 'marijuana', 'weed', 'heroin', 'weapons', 'weapon', 'guns', 'gun', 'rifle', 
        'gambling', 'casino', 'betting', 'cheat', 'fraud', 'begging', 'urgent cash', 
        'send money', 'gimme money', 'cash app me', 'direct cash transfer'
      ];
      final combinedText = '$title $description'.toLowerCase();
      for (final keyword in prohibitedKeywords) {
        if (combinedText.contains(keyword)) {
          throw Exception('Wish contains prohibited language or policy violations (keyword: "$keyword").');
        }
      }

      // 2. Enhanced verification levels constraint
      if ((verificationLevel == 3 || verificationLevel == 4) && !isIdentityVerified) {
        throw Exception('Level 3 and Level 4 wishes require completed identity verification (KYC) first.');
      }

      // 3. Minors protection check
      if (isMinor && !ageConsentVerified) {
        throw Exception('Minor accounts require verified parent/guardian consent to submit a wish.');
      }

      // 4. Calculate dynamic Wish Trust Score
      int score = 40; // base score
      if (isIdentityVerified) score += 30;
      if (evidenceDocumentUrls.isNotEmpty) score += 15;
      if (sponsorshipType != SponsorshipType.directItemPurchase && sponsorshipType != SponsorshipType.serviceProviderPayment) {
        // Volunteer/mentorship focus
        score += 15;
      } else if (retailerName != null && retailerName.isNotEmpty) {
        // Direct-to-retailer routing setup
        score += 15;
      }

      // 5. Generate custom Milestones list if target is monetary (> 0)
      final List<WishMilestone> milestones = [];
      if (sponsorshipType != SponsorshipType.volunteerService && karmaTarget > 0) {
        if (karmaTarget > 500) {
          milestones.addAll([
            WishMilestone(title: 'Admission / Provider Setup', percentage: 0.20, amount: karmaTarget * 0.20),
            WishMilestone(title: 'Milestone 1 progress delivery', percentage: 0.30, amount: karmaTarget * 0.30),
            WishMilestone(title: 'Milestone 2 progress delivery', percentage: 0.25, amount: karmaTarget * 0.25),
            WishMilestone(title: 'Final outcome validation', percentage: 0.25, amount: karmaTarget * 0.25),
          ]);
        } else {
          milestones.addAll([
            WishMilestone(title: 'Retailer purchase setup', percentage: 0.50, amount: karmaTarget * 0.50),
            WishMilestone(title: 'Final item delivery verification', percentage: 0.50, amount: karmaTarget * 0.50),
          ]);
        }
      }

      // Simulate AI understanding the wish and generating plan steps
      final List<WishPlanStep> wishPlan = [
        WishPlanStep(title: 'Clarify goals and requirements', isCompleted: true),
        WishPlanStep(title: 'Establish network connections', isCompleted: false),
        WishPlanStep(title: 'Sponsorship and resource matching', isCompleted: false),
        WishPlanStep(title: 'Fulfillment milestone delivery', isCompleted: false),
      ];

      final newWish = Wish(
        id: 'wish_${const Uuid().v4()}',
        userId: _activeUserId!,
        userName: _authProvider!.currentUser!.name,
        title: title,
        description: description,
        category: category,
        karmaTarget: karmaTarget,
        wishPlan: wishPlan,
        createdAt: DateTime.now(),
        verificationLevel: verificationLevel,
        privacyLevel: privacyLevel,
        wishTrustScore: score,
        evidenceDocumentUrls: evidenceDocumentUrls,
        isIdentityVerified: isIdentityVerified,
        ageConsentVerified: ageConsentVerified,
        sponsorshipType: sponsorshipType,
        milestones: milestones,
        retailerName: retailerName,
        isReported: false,
      );

      _allWishes.insert(0, newWish);
      await _saveWishes(_activeUserId!);
      if (_karmaRepository is FirebaseKarmaService) {
        await (_karmaRepository as FirebaseKarmaService).saveWish(newWish);
      }
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sponsorWish(
    String wishId, {
    int? karmaAmount,
    String? customContribution,
  }) async {
    if (_activeUserId == null || _authProvider?.currentUser == null) return false;
    final currentUser = _authProvider!.currentUser!;

    final idx = _allWishes.indexWhere((e) => e.id == wishId);
    if (idx == -1) return false;

    final wish = _allWishes[idx];

    try {
      String contributionText = '';
      int newRaised = wish.karmaRaised;

      if (karmaAmount != null && karmaAmount > 0) {
        if (currentUser.karmaCredits < karmaAmount) {
          _error = 'Insufficient Karma Credits';
          notifyListeners();
          return false;
        }

        // Deduct Karma credits from active user
        final updatedUser = currentUser.copyWith(
          karmaCredits: currentUser.karmaCredits - karmaAmount,
          reputationScore: (currentUser.reputationScore + 10).clamp(0, 100), // Reward sponsor!
        );
        _authProvider!.updateLocalUserProfile(updatedUser);

        newRaised += karmaAmount;
        
        final targetRetailer = wish.retailerName ?? 'Verified Provider';
        contributionText = 'Sponsored $karmaAmount Karma credits via Payment Gateway routed to $targetRetailer.';
      } else if (customContribution != null && customContribution.isNotEmpty) {
        contributionText = customContribution;

        // Reward sponsor with reputation for offering expertise/goods
        final updatedUser = currentUser.copyWith(
          reputationScore: (currentUser.reputationScore + 10).clamp(0, 100),
        );
        _authProvider!.updateLocalUserProfile(updatedUser);
      } else {
        return false;
      }

      final newContributions = List<SponsorContribution>.from(wish.sponsorContributions)
        ..add(SponsorContribution(
          sponsorName: currentUser.name,
          description: contributionText,
          timestamp: DateTime.now(),
        ));

      // Calculate milestone status updates
      final List<WishMilestone> updatedMilestones = wish.milestones.map((milestone) {
        final milestoneIdx = wish.milestones.indexOf(milestone);
        double cumulativePortion = 0.0;
        for (int i = 0; i <= milestoneIdx; i++) {
          cumulativePortion += wish.milestones[i].amount;
        }

        String newMilestoneStatus = milestone.status;
        if (newRaised >= cumulativePortion) {
          newMilestoneStatus = 'completed';
        } else if (newRaised > (cumulativePortion - milestone.amount)) {
          newMilestoneStatus = 'released';
        }
        return milestone.copyWith(status: newMilestoneStatus);
      }).toList();

      // Determine status and mark steps completed accordingly
      WishStatus newStatus = wish.status;
      List<WishPlanStep> newPlan = List<WishPlanStep>.from(wish.wishPlan);

      if (newRaised >= wish.karmaTarget) {
        newStatus = WishStatus.fulfilled;
        newPlan = wish.wishPlan.map((e) => e.copyWith(isCompleted: true)).toList();
      }

      _allWishes[idx] = wish.copyWith(
        karmaRaised: newRaised,
        sponsorContributions: newContributions,
        status: newStatus,
        wishPlan: newPlan,
        milestones: updatedMilestones,
      );

      await _saveWishes(_activeUserId!);
      if (_karmaRepository is FirebaseKarmaService) {
        await (_karmaRepository as FirebaseKarmaService).saveWish(_allWishes[idx]);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleWishStep(String wishId, int stepIdx) async {
    if (_activeUserId == null) return;
    final idx = _allWishes.indexWhere((e) => e.id == wishId);
    if (idx == -1) return;

    final wish = _allWishes[idx];
    final steps = List<WishPlanStep>.from(wish.wishPlan);
    steps[stepIdx] = steps[stepIdx].copyWith(isCompleted: !steps[stepIdx].isCompleted);

    _allWishes[idx] = wish.copyWith(wishPlan: steps);
    await _saveWishes(_activeUserId!);
    if (_karmaRepository is FirebaseKarmaService) {
      await (_karmaRepository as FirebaseKarmaService).saveWish(_allWishes[idx]);
    }
    notifyListeners();
  }

  Future<bool> reportWish(String wishId) async {
    if (_activeUserId == null) return false;
    final idx = _allWishes.indexWhere((e) => e.id == wishId);
    if (idx == -1) return false;

    _allWishes[idx] = _allWishes[idx].copyWith(isReported: true);
    await _saveWishes(_activeUserId!);
    if (_karmaRepository is FirebaseKarmaService) {
      await (_karmaRepository as FirebaseKarmaService).saveWish(_allWishes[idx]);
    }
    notifyListeners();
    return true;
  }

  List<AppFeedback> get feedbacks => _feedbacks;

  void submitFeedback(AppFeedback fb) {
    _feedbacks.insert(0, fb);
    notifyListeners();
  }

  void voteFeedback(String id, bool useful) {
    final idx = _feedbacks.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final fb = _feedbacks[idx];
      _feedbacks[idx] = fb.copyWith(
        usefulVotes: useful ? fb.usefulVotes + 1 : fb.usefulVotes,
        notUsefulVotes: !useful ? fb.notUsefulVotes + 1 : fb.notUsefulVotes,
      );
      notifyListeners();
    }
  }

  AppFeedback parseSpeechImprovement(String rawSpeech, String screenContext) {
    String structuredText = rawSpeech;
    String classification = 'Usability';

    final lower = rawSpeech.toLowerCase();
    if (lower.contains('school') || lower.contains('institution')) {
      structuredText = 'Allow educational institutions to create custom community challenges.';
      classification = 'Usability';
    } else if (lower.contains('hindi') || lower.contains('language') || lower.contains('translation')) {
      structuredText = 'Expand speech translation and localize the user interfaces in regional Indian dialects.';
      classification = 'Language';
    } else if (lower.contains('village') || lower.contains('offline') || lower.contains('network')) {
      structuredText = 'Support offline proof capture caching for rural action verification.';
      classification = 'Local Need';
    } else if (lower.contains('button') || lower.contains('confusing') || lower.contains('text')) {
      structuredText = 'Increase font sizes, simplify text prompts, and optimize spacing on main action pages.';
      classification = 'Accessibility';
    }

    return AppFeedback(
      id: const Uuid().v4(),
      screenContext: screenContext,
      category: FeedbackCategory.idea,
      details: structuredText,
      hasVoiceNote: true,
      timestamp: DateTime.now(),
      aiClassification: classification,
      status: FeedbackStatus.suggested,
    );
  }

  List<CommunityProblem> get problems => _problems;

  Future<void> _loadProblems(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final storedJson = prefs.getString('community_problems');
    if (storedJson != null) {
      try {
        final List<dynamic> list = jsonDecode(storedJson);
        _problems = list.map((item) => CommunityProblem.fromJson(item as Map<String, dynamic>)).toList();
      } catch (e) {
        _problems = _seedProblems();
        await _saveProblems();
      }
    } else {
      _problems = _seedProblems();
      await _saveProblems();
    }
    await _loadFeedbacks();
    notifyListeners();
  }

  List<CommunityProblem> _seedProblems() {
    return [
      CommunityProblem(
        id: 'prob_1',
        reporterId: 'user_john',
        reporterName: 'John Doe',
        title: 'Huge Garbage Pile near Sector-4 Park',
        description: 'Over 200kg of visible plastic and organic wastes dumped by the roadside.',
        category: KarmaCategory.environment,
        latitude: 12.9716,
        longitude: 77.5946,
        beforeImageUrl: 'captured_before.png',
        status: ProblemStatus.reported,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CommunityProblem(
        id: 'prob_2',
        reporterId: 'user_aarav',
        reporterName: 'Aarav Sharma',
        title: 'Injured Stray Dog near Temple Road',
        description: 'A stray street dog has an injured leg and needs immediate veterinary aid.',
        category: KarmaCategory.animalWelfare,
        latitude: 12.9616,
        longitude: 77.5846,
        beforeImageUrl: 'dog_injured.png',
        status: ProblemStatus.underReview,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  Future<void> _saveProblems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('community_problems', jsonEncode(_problems.map((e) => e.toJson()).toList()));
  }

  Future<void> _loadFeedbacks() async {
    final prefs = await SharedPreferences.getInstance();
    final storedJson = prefs.getString('user_feedbacks');
    if (storedJson != null) {
      try {
        final List<dynamic> list = jsonDecode(storedJson);
        _feedbacks = list.map((item) => AppFeedback.fromJson(item as Map<String, dynamic>)).toList();
      } catch (e) {
        // Use seeded feedbacks
      }
    }
  }

  Future<void> _saveFeedbacks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_feedbacks', jsonEncode(_feedbacks.map((e) => e.toJson()).toList()));
  }

  Future<bool> submitProblem({
    required String title,
    required String description,
    required KarmaCategory category,
    double? latitude,
    double? longitude,
    String? beforeImageUrl,
  }) async {
    if (_activeUserId == null) return false;
    _isSubmitting = true;
    notifyListeners();

    final newProb = CommunityProblem(
      id: 'prob_${DateTime.now().millisecondsSinceEpoch}',
      reporterId: _activeUserId!,
      reporterName: _authProvider?.currentUser?.name ?? 'Anonymous',
      title: title,
      description: description,
      category: category,
      latitude: latitude,
      longitude: longitude,
      beforeImageUrl: beforeImageUrl,
      status: ProblemStatus.reported,
      timestamp: DateTime.now(),
    );

    _problems.insert(0, newProb);
    await _saveProblems();

    // Reward reporter +5 Reputation points
    if (_authProvider != null && _authProvider!.currentUser != null) {
      final user = _authProvider!.currentUser!;
      final updated = user.copyWith(
        reputationScore: user.reputationScore + 5,
      );
      _authProvider!.updateLocalUserProfile(updated);
    }

    _isSubmitting = false;
    notifyListeners();
    return true;
  }

  Future<bool> resolveProblem(String id, String resolverName, String afterImageUrl) async {
    final idx = _problems.indexWhere((e) => e.id == id);
    if (idx == -1) return false;

    final prob = _problems[idx];
    final updatedProb = prob.copyWith(
      status: ProblemStatus.resolved,
      resolverName: resolverName,
      afterImageUrl: afterImageUrl,
    );

    _problems[idx] = updatedProb;
    await _saveProblems();

    // Reward reporter +20 Karma credits and +10 reputation
    if (_authProvider != null) {
      final prefs = await SharedPreferences.getInstance();
      final reporterProfileJson = prefs.getString('profile_${prob.reporterId}');
      if (reporterProfileJson != null) {
        final reporter = UserProfile.fromJson(jsonDecode(reporterProfileJson));
        final updatedReporter = reporter.copyWith(
          karmaCredits: reporter.karmaCredits + prob.reporterReward,
          reputationScore: (reporter.reputationScore + 10).clamp(0, 100),
        );
        await prefs.setString('profile_${prob.reporterId}', jsonEncode(updatedReporter.toJson()));
        if (_activeUserId == prob.reporterId) {
          _authProvider!.updateLocalUserProfile(updatedReporter);
        }
      }
    }

    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _allActionsSub?.cancel();
    _pendingActionsSub?.cancel();
    super.dispose();
  }
}
