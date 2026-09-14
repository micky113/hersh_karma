import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hersh_karma/models/karma_action.dart';
import 'package:hersh_karma/models/karma_category.dart';
import 'package:hersh_karma/models/karma_activity.dart';
import 'package:hersh_karma/data/karma_grid_presets.dart';
import 'package:hersh_karma/models/transaction.dart';
import 'package:hersh_karma/models/challenge.dart';
import 'package:hersh_karma/models/proposed_action.dart';
import 'package:hersh_karma/models/user_profile.dart';
import 'package:hersh_karma/models/wish.dart';
import 'package:hersh_karma/providers/auth_provider.dart';
import 'package:hersh_karma/providers/karma_provider.dart';
import 'package:hersh_karma/providers/wallet_provider.dart';
import 'package:hersh_karma/providers/governance_provider.dart';
import 'package:hersh_karma/services/mock/mock_auth_service.dart';
import 'package:hersh_karma/services/mock/mock_karma_service.dart';
import 'package:hersh_karma/services/mock/mock_wallet_service.dart';
import 'package:hersh_karma/models/promotion/promotion_engine.dart';
import 'package:hersh_karma/core/localization/app_localizations.dart';
import 'package:hersh_karma/core/config/ai_config.dart';
import 'package:hersh_karma/services/gemini_vision_service.dart';

void main() {
  // Setup Mock SharedPreferences before all tests
  SharedPreferences.setMockInitialValues({});

  late MockAuthService authService;
  late MockKarmaService karmaService;
  late MockWalletService walletService;

  setUp(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    authService = MockAuthService();
    karmaService = MockKarmaService(authService);
    walletService = MockWalletService(authService);
  });

  group('Proof of Good - Authentication Tests', () {
    test('Should authenticate default user John Doe', () async {
      final user = await authService.login('john@karma.com', 'password123');
      expect(user, isNotNull);
      expect(user!.name, equals('John Doe'));
      expect(user.reputationScore, equals(65));
    });

    test('Should authenticate with Google / Gmail', () async {
      final user = await authService.signInWithGoogle(email: 'mohit.sharma@gmail.com', name: 'Mohit Sharma');
      expect(user, isNotNull);
      expect(user!.email, equals('mohit.sharma@gmail.com'));
      expect(user.name, equals('Mohit Sharma'));
      expect(user.karmaCredits, equals(100));
    });

    test('Should restore session automatically when user logs in and app restarts on device', () async {
      final provider1 = AuthProvider(authService);
      final loggedIn = await provider1.signInWithGoogle(email: 'rahul.verma@gmail.com', name: 'Rahul Verma');
      expect(loggedIn, isTrue);
      expect(provider1.isAuthenticated, isTrue);
      expect(provider1.currentUser?.name, equals('Rahul Verma'));

      // Simulate app restart / new session creation on same device
      final freshAuthService = MockAuthService();
      final provider2 = AuthProvider(freshAuthService);
      final restored = await provider2.restoreSession();

      expect(restored, isNotNull);
      expect(provider2.isAuthenticated, isTrue);
      expect(provider2.currentUser?.email, equals('rahul.verma@gmail.com'));
      expect(provider2.currentUser?.name, equals('Rahul Verma'));
    });

    test('Should register new user and immediately create authenticated session', () async {
      final auth = AuthProvider(authService);
      final registered = await auth.signUp('Aarav Patel', 'aarav.patel@karma.org', 'password123');
      expect(registered, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser?.name, equals('Aarav Patel'));
      expect(auth.currentUser?.email, equals('aarav.patel@karma.org'));
    });

    test('Should send password reset link for valid email address', () async {
      final auth = AuthProvider(authService);
      final success = await auth.resetPassword('john@karma.com');
      expect(success, isTrue);

      final failure = await auth.resetPassword('invalid-email');
      expect(failure, isFalse);
      expect(auth.error, contains('valid email'));
    });
  });

  group('Proof of Good - Submission & Validator Tests', () {
    test('Should submit a good deed and increment totalSubmissions', () async {
      // 1. Log in John
      final user = await authService.login('john@karma.com', 'password123');
      expect(user!.totalSubmissions, equals(126));

      // 2. Submit new deed
      final initialDeed = KarmaAction(
        id: 'test_deed_1',
        userId: user.id,
        userName: user.name,
        title: 'Cleaned Beach',
        description: 'Cleaned plastic rubbish off the local beach for 2 hours.',
        category: KarmaCategory.environment,
        timestamp: DateTime.now(),
        latitude: 34.0522,
        longitude: -118.2437,
        beforeImageUrl: 'mock_before.jpg',
        imageUrl: 'mock_after.jpg',
      );

      final submitted = await karmaService.submitKarmaAction(initialDeed);
      
      // Verify confidence calculation (text + before/after images + GPS = 0.4 + 0.25 + 0.2 = 0.85)
      expect(submitted.confidenceScore, equals(0.85));
      expect(submitted.status, equals(DeedStatus.pending));

      // Verify user total submissions updated
      final updatedUser = await authService.getCurrentUser();
      expect(updatedUser!.totalSubmissions, equals(127));
    });

    test('Validator voting should reach consensus and award credits', () async {
      // 1. Log in John (the submitter)
      final john = await authService.login('john@karma.com', 'password123');
      final initialCredits = john!.karmaCredits;

      // 2. Submit a pending deed
      final deed = KarmaAction(
        id: 'consensus_test_deed',
        userId: john.id,
        userName: john.name,
        title: 'Planted Oak Trees',
        description: 'Planted 5 oak tree saplings in the local community park.',
        category: KarmaCategory.environment,
        timestamp: DateTime.now(),
        beforeImageUrl: 'mock_before.png',
        imageUrl: 'mock_path.png', // 0.25
        latitude: 37.7749, // 0.20
        longitude: -122.4194,
        witnessEmail: 'witness@green.org', // 0.15
        verificationLevel: 2,
        capturedInApp: true,
        sceneMatchConfidence: 0.90,
      ); // Total confidence = 0.4 + 0.25 + 0.2 + 0.15 = 1.0

      final submitted = await karmaService.submitKarmaAction(deed);
      expect(submitted.confidenceScore, equals(1.0));

      // Log in Jane (the high-reputation validator, rep = 90)
      final jane = await authService.login('jane@karma.com', 'password123');
      expect(jane!.reputationScore, greaterThanOrEqualTo(80));

      // Jane votes Approve - because Jane has > 80 reputation, it immediately verifies the deed in mock mode
      final votedDeed = await karmaService.voteOnKarmaAction(submitted.id, jane.id, true);
      
      expect(votedDeed.status, equals(DeedStatus.verified));
      expect(votedDeed.creditsAwarded, greaterThan(0));
      expect(votedDeed.blockchainHash, isNotNull);

      final johnUpdated = await authService.login('john@karma.com', 'password123');
      expect(johnUpdated!.karmaCredits, equals(initialCredits + votedDeed.provisionalCredits + votedDeed.verifiedCredits + votedDeed.rippleCredits));
      expect(johnUpdated.reputationScore, equals(67)); // 65 + 2
    });
  });

  group('Proof of Good - Cryptographic Token Wallet & Ledger Tests', () {
    test('Token minting should consume 100 Karma Credits and produce a linked ledger block', () async {
      // John starts with 120 credits (seeding)
      final john = await authService.login('john@karma.com', 'password123');
      expect(john!.karmaCredits, equals(120));
      final initialTokenBalance = john.tokensBalance;

      final latestHashBefore = await walletService.getLatestBlockHash();

      // Mint 1.0 token
      final tx = await walletService.mintTokens(
        john.id,
        john.name,
        1.0,
        'test_mint_deed_association',
        latestHashBefore,
      );

      expect(tx.type, equals(TransactionType.mint));
      expect(tx.amount, equals(1.0));
      expect(tx.previousHash, equals(latestHashBefore));
      expect(tx.hash, isNotNull);

      // Verify John's credits deducted by 100 and tokens increased by 1.0
      final johnUpdated = await authService.getCurrentUser();
      expect(johnUpdated!.karmaCredits, equals(20)); // 120 - 100
      expect(johnUpdated.tokensBalance, equals(initialTokenBalance + 1.0));

      // Verify the new block is now the latest block in the chain
      final latestHashAfter = await walletService.getLatestBlockHash();
      expect(latestHashAfter, equals(tx.hash));
    });

    test('Redeeming tokens for charity should deduct sender balance and log block', () async {
      final john = await authService.login('john@karma.com', 'password123');
      final initialBalance = john!.tokensBalance;

      final latestHashBefore = await walletService.getLatestBlockHash();

      // Donate 0.5 PoG to Greenpeace charity
      final tx = await walletService.transferTokens(
        john.id,
        john.name,
        'charity_greenpeace',
        'Greenpeace Oceans Fund',
        0.5,
        latestHashBefore,
      );

      expect(tx.type, equals(TransactionType.donation));
      expect(tx.amount, equals(0.5));

      // Verify John's balance is deducted
      final johnUpdated = await authService.getCurrentUser();
      expect(johnUpdated!.tokensBalance, equals(initialBalance - 0.5));
    });
  });

  group('Proof of Good - Challenges System Tests', () {
    test('Should accept and complete a challenge, rewarding credits', () async {
      final authProvider = AuthProvider(authService);
      final karmaProvider = KarmaProvider(karmaService);

      // Seed Jane's high-reputation validator profile in SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_user_jane', jsonEncode({
        'id': 'user_jane',
        'name': 'Jane Smith (Validator)',
        'email': 'jane@karma.com',
        'reputationScore': 90,
      }));

      await authProvider.login('john@karma.com', 'password123');
      karmaProvider.update(authProvider);
      
      // Wait for SharedPreferences and initial stream loading to complete
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify challenges loaded
      expect(karmaProvider.challenges.length, equals(4));
      
      final challenge = karmaProvider.challenges.firstWhere((e) => e.id == 'challenge_trees');
      expect(challenge.isAccepted, isFalse);
      expect(challenge.isCompleted, isFalse);

      // Accept challenge
      await karmaProvider.acceptChallenge('challenge_trees');
      
      final acceptedChallenge = karmaProvider.challenges.firstWhere((e) => e.id == 'challenge_trees');
      expect(acceptedChallenge.isAccepted, isTrue);

      final john = authProvider.currentUser!;
      final initialCredits = john.karmaCredits;

      // Submit 4 environment deeds to satisfy challenge (target count: 5, john starts with 1 verified seed environment deed)
      for (int i = 0; i < 4; i++) {
        final action = KarmaAction(
          id: 'challenge_deed_$i',
          userId: john.id,
          userName: john.name,
          title: 'Planted sapling $i',
          description: 'Sapling planted in park.',
          category: KarmaCategory.environment,
          timestamp: DateTime.now(),
          beforeImageUrl: 'before_$i.jpg',
          imageUrl: 'after_$i.jpg',
        );
        final submitted = await karmaService.submitKarmaAction(action);
        await karmaService.voteOnKarmaAction(submitted.id, 'user_jane', true);
      }

      // Wait for stream updates and reactive recalculation to propagate
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify challenge completed
      final completedChallenge = karmaProvider.challenges.firstWhere((e) => e.id == 'challenge_trees');
      
      expect(completedChallenge.isCompleted, isTrue);
      expect(completedChallenge.currentCount, equals(5));

      // Verify John received reward credits (+100)
      final johnFinal = authProvider.currentUser!;
      expect(johnFinal.karmaCredits, greaterThanOrEqualTo(initialCredits + 100));
    });
  });

  group('Proof of Good - Action Taxonomy Tests', () {
    test('Should contain all 367 leap year actions and have unique IDs', () {
      expect(karmaGridPresets.length, equals(367));

      final ids = karmaGridPresets.map((e) => e.id).toSet();
      expect(ids.length, equals(367));
    });

    test('Should support text query filtering for preset titles', () {
      final query = 'cpr';
      final matches = karmaGridPresets.where((act) => act.title.toLowerCase().contains(query.toLowerCase())).toList();
      expect(matches.length, greaterThanOrEqualTo(2));
      expect(matches.any((e) => e.title.contains('CPR')), isTrue);
    });
  });

  group('Proof of Good - Ripple Multiplier Tests', () {
    test('Verification with scale multiplier should calculate linear reward and 20% ripple impact', () async {
      // Log in John (the author of the action) to ensure 1.0 trust score
      await authService.login('john@karma.com', 'password123');

      // Seed Jane as a high-reputation validator
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_user_jane', jsonEncode({
        'id': 'user_jane',
        'name': 'Jane Smith (Validator)',
        'email': 'jane@karma.com',
        'reputationScore': 90,
      }));

      final action = KarmaAction(
        id: 'deed_multiplier_scale_100',
        userId: 'user_john',
        userName: 'John Doe',
        title: 'Teach literacy to an adult who cannot read', // act_073 (base Impact: 70)
        description: 'Taught basic letters and numbers to 100 students.',
        category: KarmaCategory.education,
        timestamp: DateTime.now(),
        scale: 100,
        beforeImageUrl: 'assets/proofs/deed_before_1.jpg',
        imageUrl: 'assets/proofs/deed_proof_1.jpg',
        latitude: 37.7749,
        longitude: -122.4194,
        witnessEmail: 'witness@karma.com',
      );

      final submitted = await karmaService.submitKarmaAction(action);
      final verified = await karmaService.voteOnKarmaAction(submitted.id, 'user_jane', true);

      // baseImpact = 70
      // scale = 100 -> linear scaleMultiplier = 100.0x
      // direct = 70 * 1.0 * 100.0 = 7000
      // ripple = 7000 * 0.20 = 1400
      expect(verified.creditsAwarded, equals(7000));
      expect(verified.rippleCredits, equals(1400));
    });
  });

  group('Proof of Good - Community Governance & Propose Action Tests', () {
    test('Should submit a new action proposal and update status to Verified on consensus', () async {
      final govProvider = GovernanceProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Propose Action
      final success = await govProvider.proposeAction(
        title: 'Community Tree Composting Initiative',
        problemDescription: 'High organic waste leading to methane emissions in urban neighborhoods.',
        category: KarmaCategory.environment,
        location: 'Mumbai, India',
        expectedImpact: 'Diverts 2 tons of wet waste annually, generating organic compost.',
        evidenceRequired: 'Geotagged pictures of compost pits and wet-waste weighing logs.',
        estimatedResources: '₹5,000 pit construction and 2 volunteer hours weekly.',
        whoBenefits: '50 households and local municipal soil systems.',
        suggestedKarma: 80,
        proposerId: 'user_john',
        proposerName: 'John Doe',
      );

      expect(success, isTrue);
      expect(govProvider.proposals.length, equals(4)); // 3 default seeded + 1 new

      final proposal = govProvider.proposals.first;
      expect(proposal.title, equals('Community Tree Composting Initiative'));
      expect(proposal.status, equals(ProposalStatus.community));

      // Vote 1 (Approve)
      await govProvider.voteOnProposal(proposal.id, 'user_voter_1', true);
      // Vote 2 (Approve) -> reaches net 2 consensus
      await govProvider.voteOnProposal(proposal.id, 'user_voter_2', true);

      final updatedProposal = govProvider.proposals.first;
      expect(updatedProposal.approvals, equals(2));
      expect(updatedProposal.status, equals(ProposalStatus.verified)); // Upgraded to Verified!
    });
  });

  group('Proof of Good - Interoperable Impact Exchange Tests', () {
    test('Should execute KGC to Carbon Credits conversion, deduct credits balance and record block', () async {
      final mockAuth = MockAuthService();
      final mockWallet = MockWalletService(mockAuth);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_user_john', jsonEncode({
        'id': 'user_john',
        'name': 'John Doe',
        'email': 'john@karma.com',
        'karmaCredits': 1500,
        'tokensBalance': 0.0,
      }));

      final walletProvider = WalletProvider(mockWallet);
      walletProvider.updateUserId('user_john');

      final latestHash = await mockWallet.getLatestBlockHash();
      final tx = await mockWallet.logExchange(
        'user_john',
        'John Doe',
        'Verified Carbon Credits',
        1.0,
        1000,
        'Option C: Convert into Carbon Offset Certificates',
        latestHash,
      );

      expect(tx.id, startsWith('tx_exchange_'));
      expect(tx.amount, equals(1.0));
      expect(tx.associatedDeedId, equals('exchange_burn_1000_credits'));

      final updatedJson = prefs.getString('profile_user_john');
      final updatedProfile = UserProfile.fromJson(jsonDecode(updatedJson!));
      expect(updatedProfile.karmaCredits, equals(500));
    });
  });

  group('Proof of Good - Fun Actions & Bonus Calculator Tests', () {
    test('Should submit action with Quick duration category, Team scope, and sum all 3 fun bonuses (+45% points)', () async {
      final mockAuth = MockAuthService();
      final mockKarma = MockKarmaService(mockAuth);

      final action = KarmaAction(
        id: 'deed_fun_bonuses_100',
        userId: 'user_john',
        userName: 'John Doe',
        title: 'Zero-Waste Picnic',
        description: 'Organized an eco picnic with 10 friends using glass and metal tiffins.',
        category: KarmaCategory.environment,
        timestamp: DateTime.now(),
        beforeImageUrl: 'before.jpg',
        imageUrl: 'proof.jpg',
        latitude: 12.9716,
        longitude: 77.5946,
        witnessEmail: 'witness@green.org',
        scale: 10,
        durationCategory: 'Quick',
        impactScope: 'Team',
        creativityBonus: true,
        participationBonus: true,
        rippleInspirationBonus: true,
        confidenceScore: 1.0,
      );

      final submitted = await mockKarma.submitKarmaAction(action);
      expect(submitted.durationCategory, equals('Quick'));
      expect(submitted.impactScope, equals('Team'));
      expect(submitted.creativityBonus, isTrue);
      expect(submitted.participationBonus, isTrue);
      expect(submitted.rippleInspirationBonus, isTrue);

      final jane = await mockAuth.login('jane@karma.com', 'password123');
      final verified = await mockKarma.voteOnKarmaAction(submitted.id, jane!.id, true);
      expect(verified.creditsAwarded, equals(725));
    });

    group('Proof-of-Good Firewall & Layered Verification Tests', () {
      test('Should flag duplicate photo submission and downgrade confidence', () async {
        final mockAuth = MockAuthService();
        final mockKarma = MockKarmaService(mockAuth);

        final action1 = KarmaAction(
          id: 'action_pog_1',
          userId: 'user_duplicate',
          userName: 'John Doe',
          title: 'Cleaned park',
          description: 'Cleared plastics from the neighborhood playground.',
          category: KarmaCategory.environment,
          timestamp: DateTime.now(),
          beforeImageUrl: 'before.jpg',
          imageUrl: 'park_proof.jpg',
        );

        final action2 = KarmaAction(
          id: 'action_pog_2',
          userId: 'user_duplicate',
          userName: 'John Doe',
          title: 'Cleaned beach',
          description: 'Cleared plastics from the local beach.',
          category: KarmaCategory.environment,
          timestamp: DateTime.now(),
          beforeImageUrl: 'before.jpg',
          imageUrl: 'park_proof.jpg', // Reused identical image URL
        );

        await mockKarma.submitKarmaAction(action1);
        final submitted2 = await mockKarma.submitKarmaAction(action2);

        expect(submitted2.confidenceScore, equals(0.10));
        expect(submitted2.status, equals(DeedStatus.rejected));
      });

      test('Should flag impossible travel speed velocity and downgrade confidence', () async {
        final mockAuth = MockAuthService();
        final mockKarma = MockKarmaService(mockAuth);

        final action1 = KarmaAction(
          id: 'action_pog_3',
          userId: 'user_speed',
          userName: 'John Doe',
          title: 'Forest Cleanup',
          description: 'Cleared waste from forest edge.',
          category: KarmaCategory.environment,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          latitude: 12.9716,
          longitude: 77.5946,
          beforeImageUrl: 'before_speed_1.jpg',
          imageUrl: 'after_speed_1.jpg',
        );

        final action2 = KarmaAction(
          id: 'action_pog_4',
          userId: 'user_speed',
          userName: 'John Doe',
          title: 'Beach Cleanup',
          description: 'Cleared waste from beach sands.',
          category: KarmaCategory.environment,
          timestamp: DateTime.now(), // Only 5 mins later but 60 km away!
          latitude: 13.5000,
          longitude: 77.9000,
          beforeImageUrl: 'before_speed_2.jpg',
          imageUrl: 'after_speed_2.jpg',
        );

        await mockKarma.submitKarmaAction(action1);
        final submitted2 = await mockKarma.submitKarmaAction(action2);

        expect(submitted2.confidenceScore, equals(0.20));
        expect(submitted2.status, equals(DeedStatus.rejected));
      });

      test('Should calculate diminishing returns on repeated cleanups', () async {
        final mockAuth = MockAuthService();
        final mockKarma = MockKarmaService(mockAuth);

        final action1 = KarmaAction(
          id: 'cleanup_rep_1',
          userId: 'user_diminishing',
          userName: 'John Doe',
          title: 'Litter Cleanup',
          description: 'Picked up plastic water bottles.',
          category: KarmaCategory.environment,
          timestamp: DateTime.now(),
          beforeImageUrl: 'before_rep_1.jpg',
          imageUrl: 'after_rep_1.jpg',
        );

        final action2 = KarmaAction(
          id: 'cleanup_rep_2',
          userId: 'user_diminishing',
          userName: 'John Doe',
          title: 'Litter Cleanup',
          description: 'Picked up aluminum soda cans.',
          category: KarmaCategory.environment,
          timestamp: DateTime.now(),
          beforeImageUrl: 'before_rep_2.jpg',
          imageUrl: 'after_rep_2.jpg',
        );

        final action3 = KarmaAction(
          id: 'cleanup_rep_3',
          userId: 'user_diminishing',
          userName: 'John Doe',
          title: 'Litter Cleanup',
          description: 'Picked up glass bottle pieces.',
          category: KarmaCategory.environment,
          timestamp: DateTime.now(),
          beforeImageUrl: 'before_rep_3.jpg',
          imageUrl: 'after_rep_3.jpg',
        );

        final action4 = KarmaAction(
          id: 'cleanup_rep_4',
          userId: 'user_diminishing',
          userName: 'John Doe',
          title: 'Litter Cleanup',
          description: 'Picked up discarded wrapper sheets.',
          category: KarmaCategory.environment,
          timestamp: DateTime.now(),
          beforeImageUrl: 'before_rep_4.jpg',
          imageUrl: 'after_rep_4.jpg',
        );

        final s1 = await mockKarma.submitKarmaAction(action1);
        final s2 = await mockKarma.submitKarmaAction(action2);
        final s3 = await mockKarma.submitKarmaAction(action3);
        final s4 = await mockKarma.submitKarmaAction(action4);

        expect(s1.provisionalCredits, greaterThan(0));
        expect(s2.provisionalCredits, lessThan(s1.provisionalCredits));
        expect(s3.provisionalCredits, lessThan(s2.provisionalCredits));
        expect(s4.provisionalCredits, equals(3)); // 4th+ cleanup gets a 10% floor (no daily maximum cap)
      });

      test('Should split rewards into provisional, verified, and outcome for Level 2 action', () async {
        final mockAuth = MockAuthService();
        final mockKarma = MockKarmaService(mockAuth);

        final action = KarmaAction(
          id: 'level_2_action',
          userId: 'user_splits',
          userName: 'John Doe',
          title: 'Planted 10 trees',
          description: 'Eco reforestation.',
          category: KarmaCategory.environment,
          timestamp: DateTime.now(),
          verificationLevel: 2, // Level 2 triggers split payouts
          beforeImageUrl: 'before.jpg',
          imageUrl: 'proof.jpg',
          latitude: 12.9716,
          longitude: 77.5946,
          witnessEmail: 'witness@green.org',
        );

        final submitted = await mockKarma.submitKarmaAction(action);
        
        expect(submitted.verificationLevel, equals(2));
        expect(submitted.provisionalCredits, equals(17)); // 30% of 55
        expect(submitted.verifiedCredits, equals(28)); // 50% of 55
        expect(submitted.outcomeCredits, equals(11)); // 20% of 55
      });

      test('Should trigger random audit and adjust user trust score correctly', () async {
        final mockAuth = MockAuthService();
        final mockKarma = MockKarmaService(mockAuth);

        // Seed user with low trust score
        final lowTrustUser = UserProfile(
          id: 'user_audit',
          name: 'John Doe',
          email: 'audit@karma.com',
          trustScore: 0.40,
        );
        mockAuth.updateLocalUserProfile(lowTrustUser);
        await mockAuth.login('audit@karma.com', 'password123'); // Establish session

        final action = KarmaAction(
          id: 'action_pog_audit_20',
          userId: 'user_audit',
          userName: 'John Doe',
          title: 'Community planting',
          description: 'Planted green saplings in public garden.',
          category: KarmaCategory.environment,
          timestamp: DateTime.now(),
          beforeImageUrl: 'before.jpg',
          imageUrl: 'after.jpg',
        );

        final submitted = await mockKarma.submitKarmaAction(action);
        
        expect(submitted.isAudited, isTrue);
        expect(submitted.auditPassed, isFalse); // User had trust < 0.5
        
        final user = await mockAuth.getCurrentUser();
        // Since lowTrustUser is not the active logged-in user in mockAuth,
        // we can fetch it via login first or get the profile from prefs!
        // Wait, in MockAuthService: login loads the user profile from prefs!
        final authenticatedUser = await mockAuth.login('audit@karma.com', 'password123');
        expect(authenticatedUser!.trustScore, closeTo(0.30, 0.01)); // trust score decreased by 0.10
      });

      test('Should calculate 100-point Evidence Score and trigger Auto-Verification if score >= 90', () async {
        final mockAuth = MockAuthService();
        final mockKarma = MockKarmaService(mockAuth);

        // Seed a highly trusted user (trustScore >= 0.90 to get the +5 pts)
        final trustedUser = UserProfile(
          id: 'user_trusted',
          name: 'Trusted User',
          email: 'trusted@karma.com',
          trustScore: 1.0,
          karmaCredits: 100,
        );
        mockAuth.updateLocalUserProfile(trustedUser);
        await mockAuth.login('trusted@karma.com', 'password123');

        // Build action with perfect evidence indicators:
        // - GPS coordinates present (+20 pts)
        // - sceneMatchConfidence >= 0.85 (+20 pts)
        // - capturedInApp is true (+20 pts)
        // - wasteBeforeCount > wasteAfterCount (+15 pts)
        // - GPS & speed consistent (+10 pts)
        // - Not duplicate (+10 pts)
        // - User trust score >= 0.90 (+5 pts)
        // Total points = 20 + 20 + 20 + 15 + 10 + 10 + 5 = 100 pts!
        final action = KarmaAction(
          id: 'perfect_evidence_action',
          userId: 'user_trusted',
          userName: 'Trusted User',
          title: 'Forest Re-planting',
          description: 'Planted many trees in the city forest.',
          category: KarmaCategory.environment,
          timestamp: DateTime.now(),
          latitude: 12.9716,
          longitude: 77.5946,
          capturedInApp: true,
          imageUrl: 'after.jpg',
          beforeImageUrl: 'before.jpg',
          wasteBeforeCount: 120,
          wasteAfterCount: 5,
          sceneMatchConfidence: 0.95,
          verificationLevel: 2,
          witnessEmail: 'witness@green.org',
        );

        final submitted = await mockKarma.submitKarmaAction(action);

        expect(submitted.evidenceScore, equals(100));
        expect(submitted.status, equals(DeedStatus.verified)); // Auto-verified!
        
        // Assert that both provisional + verified + ripple credits were instantly released!
        // baseCredits = 50. confidence = 1.0. finalCredits = 50.
        // splits: prov = 15. verified = 25. outcome = 10.
        // ripple: 20% of (17 + 28 + 11) = 11.
        // Total instantly released = 17 (provisional) + 28 (verified) + 11 (ripple) = 56 credits!
        // Final balance = 100 (initial) + 56 = 156 credits!
        final updatedUser = await mockAuth.getCurrentUser();
        expect(updatedUser!.karmaCredits, equals(156));
      });

      test('Should mark action as Pending if Evidence Score is between 70 and 89', () async {
        final mockAuth = MockAuthService();
        final mockKarma = MockKarmaService(mockAuth);

        final user = UserProfile(
          id: 'user_mod',
          name: 'Regular User',
          email: 'mod@karma.com',
          trustScore: 0.50, // Does not get +5 pts
        );
        mockAuth.updateLocalUserProfile(user);
        await mockAuth.login('mod@karma.com', 'password123');

        // Build action with moderate evidence:
        // - GPS coordinates present (+20 pts)
        // - Captured in app (+20 pts)
        // - Speed consistent (+10 pts)
        // - No duplicate (+10 pts)
        // Total points = 20 + 20 + 10 + 10 = 60 pts?
        // Wait, let's add sceneMatchConfidence 0.95 (+20 pts) -> 80 pts!
        final action = KarmaAction(
          id: 'moderate_evidence_action',
          userId: 'user_mod',
          userName: 'Regular User',
          title: 'Local cleanups',
          description: 'Clearing trash from public garden.',
          category: KarmaCategory.environment,
          timestamp: DateTime.now(),
          latitude: 12.9716,
          longitude: 77.5946,
          capturedInApp: true,
          beforeImageUrl: 'before.jpg',
          imageUrl: 'after.jpg',
          sceneMatchConfidence: 0.90,
          verificationLevel: 2,
        );

        final submitted = await mockKarma.submitKarmaAction(action);

        expect(submitted.evidenceScore, equals(80));
        expect(submitted.status, equals(DeedStatus.pending)); // Requires manual verification!
      });

      test('Should reject action if Evidence Score is below 70', () async {
        final mockAuth = MockAuthService();
        final mockKarma = MockKarmaService(mockAuth);

        final user = UserProfile(
          id: 'user_low',
          name: 'Regular User',
          email: 'low@karma.com',
          trustScore: 0.50,
        );
        mockAuth.updateLocalUserProfile(user);
        await mockAuth.login('low@karma.com', 'password123');

        // Build action with low evidence:
        // - GPS coordinates present (+20 pts)
        // - Speed consistent (+10 pts)
        // - No duplicate (+10 pts)
        // Total points = 40 pts (below 70)
        final action = KarmaAction(
          id: 'low_evidence_action',
          userId: 'user_low',
          userName: 'Regular User',
          title: 'Help groceries',
          description: 'Helped family friend carry grocery bags.',
          category: KarmaCategory.environment,
          timestamp: DateTime.now(),
          latitude: 12.9716,
          longitude: 77.5946,
          beforeImageUrl: 'before.jpg',
          imageUrl: 'after.jpg',
          verificationLevel: 2, // Needs to be level 2 to trigger score rejection
        );

        final submitted = await mockKarma.submitKarmaAction(action);

        expect(submitted.evidenceScore, equals(40));
        expect(submitted.status, equals(DeedStatus.rejected)); // Held/rejected!
      });

      test('Should reject action with confidence 0.0 if Before/After evidence pair is missing', () async {
        final mockAuth = MockAuthService();
        final mockKarma = MockKarmaService(mockAuth);

        final action = KarmaAction(
          id: 'missing_evidence_pair_action',
          userId: 'user_john',
          userName: 'John Doe',
          title: 'Cleaned Beach',
          description: 'No images or witness code attached.',
          category: KarmaCategory.environment,
          timestamp: DateTime.now(),
        );

        final submitted = await mockKarma.submitKarmaAction(action);
        expect(submitted.status, equals(DeedStatus.rejected));
        expect(submitted.confidenceScore, equals(0.0));
        expect(submitted.creditsAwarded, equals(0));
      });
    });

    group('Wish Come True Tests', () {
      late MockAuthService authService;
      late MockKarmaService karmaService;
      late AuthProvider authProvider;
      late KarmaProvider karmaProvider;

      setUp(() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        authService = MockAuthService();
        karmaService = MockKarmaService(authService);
        
        authProvider = AuthProvider(authService);
        karmaProvider = KarmaProvider(karmaService);
      });

      test('Should load seeded default wishes on provider update', () async {
        // Initially empty
        expect(karmaProvider.allWishes, isEmpty);

        // Login user john
        await authProvider.login('john@karma.com', 'password123');
        karmaProvider.update(authProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        // Should load 3 seeded default wishes
        expect(karmaProvider.allWishes.length, equals(3));
        expect(karmaProvider.allWishes[0].title, equals('I want to learn guitar.'));
        expect(karmaProvider.allWishes[1].title, equals('Help my village get clean drinking water.'));
      });

      test('Should submit new wish and generate AI plan steps', () async {
        await authProvider.login('john@karma.com', 'password123');
        karmaProvider.update(authProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        final initialCount = karmaProvider.allWishes.length;

        final success = await karmaProvider.submitWish(
          title: 'I want to build a small garden',
          description: 'I need tools and seeds to start a neighborhood backyard garden.',
          category: WishCategory.community,
          karmaTarget: 400,
        );

        expect(success, isTrue);
        expect(karmaProvider.allWishes.length, equals(initialCount + 1));
        
        final newWish = karmaProvider.allWishes.first;
        expect(newWish.title, equals('I want to build a small garden'));
        expect(newWish.wishPlan.length, equals(4)); // AI roadmap steps
        expect(newWish.wishPlan[0].title, equals('Clarify goals and requirements'));
        expect(newWish.wishPlan[0].isCompleted, isTrue); // First step pre-completed
        expect(newWish.wishPlan[1].isCompleted, isFalse);
      });

      test('Should sponsor a wish, deduct credits, and reward reputation', () async {
        await authProvider.login('john@karma.com', 'password123'); // John has 120 credits
        karmaProvider.update(authProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        final wish = karmaProvider.allWishes.firstWhere((w) => w.id == 'wish_guitar');
        expect(wish.karmaRaised, equals(120));

        // John sponsors 50 Karma
        final success = await karmaProvider.sponsorWish(wish.id, karmaAmount: 50);
        expect(success, isTrue);
        await Future.delayed(const Duration(milliseconds: 100));

        // Reload wish
        final updatedWish = karmaProvider.allWishes.firstWhere((w) => w.id == 'wish_guitar');
        expect(updatedWish.karmaRaised, equals(170));
        expect(updatedWish.sponsorContributions.length, equals(4)); // 3 seeded + 1 new
        expect(updatedWish.sponsorContributions.last.description, contains('Sponsored 50 Karma'));

        // Verify John's profile updates: credits deducted (120 - 50 = 70) and reputation rewarded (+10)
        final user = authProvider.currentUser!;
        expect(user.karmaCredits, equals(70));
        expect(user.reputationScore, equals(75)); // John starts with 65 in mock auth db
      });

      test('Should support offering non-monetary goods/resources in Wish Ripple', () async {
        await authProvider.login('john@karma.com', 'password123');
        karmaProvider.update(authProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        final wish = karmaProvider.allWishes.firstWhere((w) => w.id == 'wish_guitar');

        // John offers a guitar
        final success = await karmaProvider.sponsorWish(
          wish.id,
          customContribution: 'I have an extra acoustic guitar to donate.',
        );
        expect(success, isTrue);

        final updatedWish = karmaProvider.allWishes.firstWhere((w) => w.id == 'wish_guitar');
        expect(updatedWish.sponsorContributions.last.description, equals('I have an extra acoustic guitar to donate.'));
        
        // Target didn't change
        expect(updatedWish.karmaRaised, equals(120));
      });

      test('Should change wish status to fulfilled and complete all plan steps when target is met', () async {
        await authProvider.login('john@karma.com', 'password123');
        // Let's give john extra credits to satisfy target
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_user_john', jsonEncode({
          'id': 'user_john',
          'name': 'John Doe',
          'email': 'john@karma.com',
          'reputationScore': 65,
          'karmaCredits': 1000,
        }));
        await authProvider.login('john@karma.com', 'password123');
        karmaProvider.update(authProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        final wish = karmaProvider.allWishes.firstWhere((w) => w.id == 'wish_guitar'); // Goal is 500, raised 120, needs 380
        expect(wish.status, equals(WishStatus.active));

        final success = await karmaProvider.sponsorWish(wish.id, karmaAmount: 380);
        expect(success, isTrue);

        final updatedWish = karmaProvider.allWishes.firstWhere((w) => w.id == 'wish_guitar');
        expect(updatedWish.status, equals(WishStatus.fulfilled));
        expect(updatedWish.wishPlan.every((step) => step.isCompleted), isTrue);
      });

      test('Should toggle status of individual wish plan steps', () async {
        await authProvider.login('john@karma.com', 'password123');
        karmaProvider.update(authProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        final wish = karmaProvider.allWishes.firstWhere((w) => w.id == 'wish_guitar');
        expect(wish.wishPlan[1].isCompleted, isFalse);

        await karmaProvider.toggleWishStep(wish.id, 1);

        final updatedWish = karmaProvider.allWishes.firstWhere((w) => w.id == 'wish_guitar');
        expect(updatedWish.wishPlan[1].isCompleted, isTrue);
      });

      test('Should reject wish containing prohibited content (safety check)', () async {
        await authProvider.login('john@karma.com', 'password123');
        karmaProvider.update(authProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        // Prohibited request (weapons/guns)
        final success = await karmaProvider.submitWish(
          title: 'I want to buy a gun',
          description: 'I need it for self defense.',
          category: WishCategory.experience,
          karmaTarget: 1000,
        );

        expect(success, isFalse);
        expect(karmaProvider.error, contains('contains prohibited language'));
      });

      test('Should enforce identity verification (KYC) for Level 3/4 wishes', () async {
        await authProvider.login('john@karma.com', 'password123');
        karmaProvider.update(authProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        // Level 3 wish with unverified identity
        final success = await karmaProvider.submitWish(
          title: 'University degree tuition',
          description: 'Need assistance for final semester college fees.',
          category: WishCategory.education,
          karmaTarget: 2000,
          verificationLevel: 3,
          isIdentityVerified: false,
        );

        expect(success, isFalse);
        expect(karmaProvider.error, contains('require completed identity verification'));
      });

      test('Should enforce parental consent check for minors', () async {
        await authProvider.login('john@karma.com', 'password123');
        karmaProvider.update(authProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        // Minor wish without consent
        final success = await karmaProvider.submitWish(
          title: 'Coding course for kids',
          description: 'Would love to study game programming.',
          category: WishCategory.education,
          karmaTarget: 500,
          isMinor: true,
          ageConsentVerified: false,
        );

        expect(success, isFalse);
        expect(karmaProvider.error, contains('require verified parent/guardian consent'));
      });

      test('Should route payments to verified retailers and populate milestones', () async {
        await authProvider.login('john@karma.com', 'password123');
        karmaProvider.update(authProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        // Create direct-to-retailer wish
        final success = await karmaProvider.submitWish(
          title: 'Study Laptop Device',
          description: 'Need a computer to learn software coding.',
          category: WishCategory.education,
          karmaTarget: 100,
          sponsorshipType: SponsorshipType.directItemPurchase,
          retailerName: 'Croma Digital Store',
        );

        expect(success, isTrue);

        final newWish = karmaProvider.allWishes.first;
        expect(newWish.retailerName, equals('Croma Digital Store'));
        expect(newWish.milestones.length, equals(2)); // <=500 target gives 2 milestones

        // Sponsor 50 Karma
        final sponsorSuccess = await karmaProvider.sponsorWish(newWish.id, karmaAmount: 50);
        expect(sponsorSuccess, isTrue);
        await Future.delayed(const Duration(milliseconds: 100));

        final updatedWish = karmaProvider.allWishes.first;
        expect(updatedWish.sponsorContributions.last.description, contains('via Payment Gateway routed to Croma Digital Store'));
        // Milestone 1 (50% of 100 = 50) becomes completed!
        expect(updatedWish.milestones[0].status, equals('completed'));
      });

      test('Should support reporting wishes and flag them', () async {
        await authProvider.login('john@karma.com', 'password123');
        karmaProvider.update(authProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        final wish = karmaProvider.allWishes.firstWhere((w) => w.id == 'wish_guitar');
        expect(wish.isReported, isFalse);

        final success = await karmaProvider.reportWish(wish.id);
        expect(success, isTrue);

        final updatedWish = karmaProvider.allWishes.firstWhere((w) => w.id == 'wish_guitar');
        expect(updatedWish.isReported, isTrue);
      });
    });
  });

  group('Proof of Good - India-First 22 Languages & RTL Localization Tests', () {
    test('Should support all 22 Eighth Schedule Indian languages plus global languages in catalog', () {
      final supported = AppLocalizations.supportedLanguages;
      expect(supported.length, greaterThanOrEqualTo(24));

      final codes = supported.map((l) => l['code']).toSet();
      // 22 Eighth Schedule Languages
      final expectedIndic = [
        'hi', 'bn', 'te', 'mr', 'ta', 'ur', 'gu', 'kn', 'or', 'ml',
        'pa', 'as', 'mai', 'sat', 'ks', 'ne', 'kok', 'doi', 'sd', 'brx', 'sa', 'mni'
      ];
      for (final code in expectedIndic) {
        expect(codes.contains(code), isTrue, reason: 'Expected language code $code to be present');
      }

      // Global languages
      expect(codes.contains('en'), isTrue);
      expect(codes.contains('he'), isTrue);
      expect(codes.contains('ar'), isTrue);
    });

    test('Should detect RTL directionality accurately for Hebrew, Arabic, Urdu, Kashmiri, and Sindhi', () {
      expect(AppLocalizations.isRtlLanguage('he'), isTrue);
      expect(AppLocalizations.isRtlLanguage('Hebrew'), isTrue);
      expect(AppLocalizations.isRtlLanguage('ar'), isTrue);
      expect(AppLocalizations.isRtlLanguage('Arabic'), isTrue);
      expect(AppLocalizations.isRtlLanguage('ur'), isTrue);
      expect(AppLocalizations.isRtlLanguage('Urdu'), isTrue);
      expect(AppLocalizations.isRtlLanguage('ks'), isTrue);
      expect(AppLocalizations.isRtlLanguage('sd'), isTrue);

      // LTR languages should return false
      expect(AppLocalizations.isRtlLanguage('en'), isFalse);
      expect(AppLocalizations.isRtlLanguage('hi'), isFalse);
      expect(AppLocalizations.isRtlLanguage('bn'), isFalse);
      expect(AppLocalizations.isRtlLanguage('te'), isFalse);
      expect(AppLocalizations.isRtlLanguage('ta'), isFalse);
    });

    test('Should translate centralized keys into Hindi, Bengali, Tamil, Telugu, Marathi, and Urdu correctly', () {
      expect(AppLocalizations.translate('app_title', lang: 'hi'), equals('कर्म ग्रिड'));
      expect(AppLocalizations.translate('app_title', lang: 'bn'), equals('কর্ম গ্রিড'));
      expect(AppLocalizations.translate('app_title', lang: 'ta'), equals('கர்மா கிரிட்'));
      expect(AppLocalizations.translate('app_title', lang: 'te'), equals('కర్మ గ్రిడ్'));
      expect(AppLocalizations.translate('app_title', lang: 'mr'), equals('कर्म ग्रिड'));
      expect(AppLocalizations.translate('app_title', lang: 'ur'), equals('کرما گرڈ'));
      expect(AppLocalizations.translate('app_title', lang: 'he'), equals('קארמה גריד'));
      expect(AppLocalizations.translate('app_title', lang: 'ar'), equals('كارما جريد'));

      // Fallback to English on unknown language
      expect(AppLocalizations.translate('app_title', lang: 'xyz'), equals('Karma Grid'));
    });
  });

  group('Proof of Good - Role-Based Hierarchy & Governance Dimensions Tests', () {
    test('Should assign CommunityRole.newMember (Level 1) for new user with zero verified deeds', () {
      final user = UserProfile(
        id: 'u-1',
        name: 'New Member',
        email: 'member@karma.org',
        verifiedSubmissions: 0,
        trustScore: 1.0,
      );
      expect(user.communityRole, equals(CommunityRole.newMember));
      expect(user.communityRole.levelNumber, equals(1));
      expect(user.canVerifyPeerDeeds, isFalse);
      expect(user.canCoordinateCommunityProjects, isFalse);
    });

    test('Should assign CommunityRole.contributor (Level 2) once user meets Level 2 criteria (>=100 Karma, >=5 deeds, >=70% Trust)', () {
      final user = UserProfile(
        id: 'u-2',
        name: 'Active Contributor',
        email: 'contributor@karma.org',
        karmaCredits: 100,
        verifiedSubmissions: 5,
        trustScore: 0.80,
      );
      expect(user.communityRole, equals(CommunityRole.contributor));
      expect(user.communityRole.levelNumber, equals(2));
      expect(user.canVerifyPeerDeeds, isFalse);
    });

    test('Should elevate to CommunityRole.trustedContributor (Level 3) when >= 1000 Karma, >= 25 verified deeds and >= 80% trust score', () {
      final user = UserProfile(
        id: 'u-3',
        name: 'Trusted Contributor',
        email: 'trusted@karma.org',
        karmaCredits: 1000,
        verifiedSubmissions: 25,
        communityHelpContributionsCount: 5,
        distinctCategoriesCount: 2,
        trustScore: 0.85,
      );
      expect(user.communityRole, equals(CommunityRole.trustedContributor));
      expect(user.communityRole.levelNumber, equals(3));
      expect(user.canVerifyPeerDeeds, isTrue);
    });

    test('Should assign CommunityRole.communityLeader (Level 4) for community group user with project coordination rights', () {
      final leader = UserProfile(
        id: 'u-4',
        name: 'Green Delhi Lead',
        email: 'lead@greendelhi.org',
        role: UserRole.communityGroup,
      );
      expect(leader.communityRole, equals(CommunityRole.communityLeader));
      expect(leader.communityRole.levelNumber, equals(4));
      expect(leader.canVerifyPeerDeeds, isTrue);
      expect(leader.canCoordinateCommunityProjects, isTrue);
      expect(leader.canManageChallenges, isTrue);
    });

    test('Institutional and NGO roles should have verified organization capabilities', () {
      final ngoUser = UserProfile(
        id: 'ngo-1',
        name: 'Goonj Foundation',
        email: 'impact@goonj.org',
        role: UserRole.ngo,
        isOrgVerified: true,
      );
      expect(ngoUser.canVerifyPeerDeeds, isTrue);
      expect(ngoUser.canCoordinateCommunityProjects, isTrue);
      expect(ngoUser.canManageChallenges, isTrue);
    });
  });

  group('Proof of Good - 5-Tier Earned Progression & 2D Matrix (Karma vs Trust) Tests', () {
    test('All 5 community levels should have explicit level numbers, titles, numerical thresholds, and review types', () {
      expect(CommunityRole.newMember.levelNumber, equals(1));
      expect(CommunityRole.newMember.title, equals('New Member'));
      expect(CommunityRole.newMember.requiredKarma, equals(0));
      expect(CommunityRole.newMember.minTrustScore, equals(0.0));
      expect(CommunityRole.newMember.minVerifiedContributions, equals(0));
      expect(CommunityRole.newMember.minDistinctCategories, equals(1));
      expect(CommunityRole.newMember.reviewType, equals('None (Automatic)'));

      expect(CommunityRole.contributor.levelNumber, equals(2));
      expect(CommunityRole.contributor.title, equals('Contributor'));
      expect(CommunityRole.contributor.requiredKarma, equals(100));
      expect(CommunityRole.contributor.minTrustScore, equals(0.70));
      expect(CommunityRole.contributor.minVerifiedContributions, equals(5));
      expect(CommunityRole.contributor.minDistinctCategories, equals(1));
      expect(CommunityRole.contributor.reviewType, equals('Automated Contribution & Verification Screening'));

      expect(CommunityRole.trustedContributor.levelNumber, equals(3));
      expect(CommunityRole.trustedContributor.title, equals('Trusted Contributor'));
      expect(CommunityRole.trustedContributor.requiredKarma, equals(1000));
      expect(CommunityRole.trustedContributor.minTrustScore, equals(0.80));
      expect(CommunityRole.trustedContributor.minVerifiedContributions, equals(25));
      expect(CommunityRole.trustedContributor.minDistinctCategories, equals(2));
      expect(CommunityRole.trustedContributor.reviewType, equals('Automated Trust & Evidence Screening'));

      expect(CommunityRole.communityLeader.levelNumber, equals(4));
      expect(CommunityRole.communityLeader.title, equals('Community Leader'));
      expect(CommunityRole.communityLeader.requiredKarma, equals(5000));
      expect(CommunityRole.communityLeader.minTrustScore, equals(0.90));
      expect(CommunityRole.communityLeader.minVerifiedContributions, equals(100));
      expect(CommunityRole.communityLeader.minDistinctCategories, equals(3));
      expect(CommunityRole.communityLeader.reviewType, equals('Portfolio & Peer Community Review'));

      expect(CommunityRole.karmaAmbassador.levelNumber, equals(5));
      expect(CommunityRole.karmaAmbassador.title, equals('Karma Ambassador'));
      expect(CommunityRole.karmaAmbassador.requiredKarma, equals(25000));
      expect(CommunityRole.karmaAmbassador.minTrustScore, equals(0.95));
      expect(CommunityRole.karmaAmbassador.minVerifiedContributions, equals(300));
      expect(CommunityRole.karmaAmbassador.minDistinctCategories, equals(5));
      expect(CommunityRole.karmaAmbassador.reviewType, equals('Human Governance Board Review (Trust Center)'));
    });

    test('Strict ALL-Conditions Rule: 10,000 Karma + 65% Trust is strictly blocked from Trusted Contributor', () {
      final highKarmaLowTrustUser = UserProfile(
        id: 'u-gaming-1',
        name: 'Gaming User',
        email: 'gaming@karma.org',
        karmaCredits: 10000,
        verifiedSubmissions: 50,
        trustScore: 0.65, // Below 80%
      );

      // Cannot qualify as Trusted Contributor or Community Leader due to failed Trust gate
      expect(highKarmaLowTrustUser.communityRole, equals(CommunityRole.newMember));
      expect(highKarmaLowTrustUser.canVerifyPeerDeeds, isFalse);

      final quadrant = PromotionEngine.evaluateQuadrant(highKarmaLowTrustUser);
      expect(quadrant, equals(KarmaTrustQuadrant.highKarmaLowTrust));
      expect(quadrant.isPromotionEligible, isFalse);
    });

    test('Strict ALL-Conditions Rule: 6,000 Karma + 94% Trust + 120 verified deeds qualifies for Community Leader', () {
      final validLeader = UserProfile(
        id: 'u-leader-valid',
        name: 'Valid Leader',
        email: 'leader@karma.org',
        karmaCredits: 6000,
        trustScore: 0.94,
        verifiedSubmissions: 120,
        completedInitiativesCount: 3,
        distinctCategoriesCount: 3,
        conductViolationsCount: 0,
      );

      expect(validLeader.communityRole, equals(CommunityRole.communityLeader));
      expect(validLeader.canVerifyPeerDeeds, isTrue);
      expect(validLeader.canCoordinateCommunityProjects, isTrue);
      expect(validLeader.canManageChallenges, isTrue);
    });

    test('Impact Diversity Engine: Ambassador requires contributions spanning at least 5 distinct categories', () {
      // User with 25,000 Karma and 300 deeds but only 1 category (micro-spamming)
      final spammyUser = UserProfile(
        id: 'u-spam-amb',
        name: 'Single Domain Spammer',
        email: 'spammer@karma.org',
        explicitCommunityRole: CommunityRole.communityLeader,
        karmaCredits: 26000,
        verifiedSubmissions: 310,
        trustScore: 0.96,
        distinctCategoriesCount: 1, // Fails 5-category diversity gate
        accountAgeMonths: 14,
        isAmbassadorApproved: true,
      );

      final gateResult = PromotionEngine.evaluateNextLevelGates(spammyUser);
      expect(gateResult.karmaPassed, isTrue);
      expect(gateResult.verificationPassed, isTrue);
      expect(gateResult.trustPassed, isTrue);
      expect(gateResult.categoryDiversityPassed, isFalse); // Diversity gate blocks promotion!
      expect(gateResult.isEligibleForNextLevel, isFalse);

      // User with 5 distinct categories passes the diversity gate
      final diverseAmbassador = spammyUser.copyWith(distinctCategoriesCount: 5);
      final diverseGateResult = PromotionEngine.evaluateNextLevelGates(diverseAmbassador);
      expect(diverseGateResult.categoryDiversityPassed, isTrue);
      expect(diverseGateResult.isEligibleForNextLevel, isTrue);
    });

    test('Demotion & Suspension: Dropping below required Trust pauses responsibility privileges', () {
      final trustedUser = UserProfile(
        id: 'u-trusted-demo',
        name: 'Trusted Contributor',
        email: 'trusted@karma.org',
        explicitCommunityRole: CommunityRole.trustedContributor,
        karmaCredits: 1200,
        verifiedSubmissions: 30,
        trustScore: 0.72, // Below Level 3 minimum (0.80)
        conductViolationsCount: 0,
      );

      expect(trustedUser.isDemotedOrSuspended, isTrue);
      expect(trustedUser.canVerifyPeerDeeds, isFalse); // Privilege suspended!
      expect(trustedUser.demotionReason, contains('fallen below the required 80% threshold'));

      final demotionRisk = PromotionEngine.evaluateDemotionRisk(trustedUser);
      expect(demotionRisk.isCurrentlySuspended, isTrue);
      expect(demotionRisk.warningMessage, contains('fallen below required 80% threshold'));
    });

    test('Demotion & Suspension: Conduct violation immediately suspends privileges', () {
      final violator = UserProfile(
        id: 'u-leader-violator',
        name: 'Violating Leader',
        email: 'violator@karma.org',
        explicitCommunityRole: CommunityRole.communityLeader,
        karmaCredits: 8000,
        verifiedSubmissions: 150,
        trustScore: 0.95,
        conductViolationsCount: 1, // Violation logged
      );

      expect(violator.isDemotedOrSuspended, isTrue);
      expect(violator.canCoordinateCommunityProjects, isFalse);
      expect(violator.demotionReason, contains('1 conduct violation'));
    });

    test('Cumulative Karma Retention: Karma is never wiped or reset on promotion', () {
      final user = UserProfile(
        id: 'u-prog-1',
        name: 'Progressing User',
        email: 'prog@karma.org',
        karmaCredits: 740,
        verifiedSubmissions: 19,
        trustScore: 0.84,
        explicitCommunityRole: CommunityRole.contributor,
      );

      final gateResult = PromotionEngine.evaluateNextLevelGates(user);
      expect(gateResult.targetRole, equals(CommunityRole.trustedContributor));
      expect(gateResult.karmaDetail, equals('740 / 1,000 Lifetime Karma'));
      expect(gateResult.verificationDetail, equals('19 / 25 Verified Deeds'));
      expect(gateResult.trustPassed, isTrue);
    });
  });

  group('Proof of Good - Gemini Vision Multimodal AI Verification Tests', () {
    test('AiConfig should initialize with default Gemini API key and allow custom key configuration', () async {
      await AiConfig.initialize();
      expect(AiConfig.hasValidApiKey, isTrue);
      expect(AiConfig.apiKey, equals(AiConfig.defaultApiKey));
      expect(AiConfig.modelName, equals('gemini-flash-latest'));
      expect(AiConfig.maskedApiKey, contains('...'));

      await AiConfig.setApiKey('AIzaSyTestMockCustomKey123456789');
      expect(AiConfig.apiKey, equals('AIzaSyTestMockCustomKey123456789'));

      await AiConfig.resetToDefault();
      expect(AiConfig.apiKey, equals(AiConfig.defaultApiKey));
    });

    test('GeminiVerificationResult should parse valid JSON and route score >= 90 to auto-verified', () {
      final json = {
        'evidenceScore': 94,
        'sceneMatchConfidence': 0.96,
        'changeSummary': 'High volume litter removed and sidewalk restored.',
        'measurableBefore': 'Dense plastic waste',
        'measurableAfter': 'Clean sidewalk',
        'isTampered': false,
        'reasoning': 'Identical wall textures and confirmed transformation.',
      };

      final result = GeminiVerificationResult.fromJson(json, isLive: true);
      expect(result.evidenceScore, equals(94));
      expect(result.sceneMatchConfidence, equals(0.96));
      expect(result.isAutoVerified, isTrue);
      expect(result.isQueuedForValidators, isFalse);
      expect(result.isRejected, isFalse);
      expect(result.isLiveAiResult, isTrue);
      expect(result.scoreBreakdown['In-App Live Enclave'], equals(20));
    });

    test('GeminiVerificationResult should route score between 70 and 89 to pending validators', () {
      final json = {
        'evidenceScore': 78,
        'sceneMatchConfidence': 0.82,
        'changeSummary': 'Plausible park cleanup with minor perspective difference.',
        'measurableBefore': 'Park area before',
        'measurableAfter': 'Park area after',
        'isTampered': false,
        'reasoning': 'Good transformation but angle shifted slightly.',
      };

      final result = GeminiVerificationResult.fromJson(json, isLive: true);
      expect(result.evidenceScore, equals(78));
      expect(result.isAutoVerified, isFalse);
      expect(result.isQueuedForValidators, isTrue);
      expect(result.isRejected, isFalse);
    });

    test('GeminiVerificationResult should immediately reject tampered or score < 70 evidence', () {
      final json = {
        'evidenceScore': 45,
        'sceneMatchConfidence': 0.30,
        'changeSummary': 'Suspected computer monitor photo of stock image.',
        'isTampered': true,
        'reasoning': 'Moiré pattern detected and location mismatch.',
      };

      final result = GeminiVerificationResult.fromJson(json, isLive: true);
      expect(result.isRejected, isTrue);
      expect(result.isTampered, isTrue);
      expect(result.isAutoVerified, isFalse);
      expect(result.isQueuedForValidators, isFalse);
    });

    test('GeminiVisionService should provide resilient fallback when running without network or bytes', () async {
      final fallbackResult = await GeminiVisionService.analyzeEvidence(
        beforeImageBytes: null,
        afterImageBytes: null,
        deedTitle: 'Tree Plantation Drive',
        category: 'Environment',
        latitude: 12.9716,
        longitude: 77.5946,
        capturedInApp: true,
      );

      expect(fallbackResult.evidenceScore, greaterThanOrEqualTo(70));
      expect(fallbackResult.sceneMatchConfidence, greaterThanOrEqualTo(0.80));
      expect(fallbackResult.isTampered, isFalse);
      expect(fallbackResult.scoreBreakdown.isNotEmpty, isTrue);
    });

    test('GeminiVisionService testApiKeyDetailed should reject empty key', () async {
      final emptyResult = await GeminiVisionService.testApiKeyDetailed('');
      expect(emptyResult['success'], isFalse);
      expect(emptyResult['message'], contains('empty'));

      final testSuccess = await GeminiVisionService.testApiKey('   ');
      expect(testSuccess, isFalse);
    });

    test('GeminiVisionService should immediately detect duplicate identical photos and reject them', () async {
      final sampleBytes = Uint8List.fromList(List.generate(500, (i) => i % 256));
      final duplicateBytes = Uint8List.fromList(List.generate(500, (i) => i % 256));

      final diff = GeminiVisionService.calculateByteDifference(sampleBytes, duplicateBytes);
      expect(diff, equals(0.0));

      final result = await GeminiVisionService.analyzeEvidence(
        beforeImageBytes: sampleBytes,
        afterImageBytes: duplicateBytes,
        deedTitle: 'Stray Animal Feeding',
        category: 'Animal Welfare',
      );

      expect(result.isRejected, isTrue);
      expect(result.isTampered, isTrue);
      expect(result.evidenceScore, lessThanOrEqualTo(40));
      expect(result.changeSummary, contains('Duplicate'));
    });
  });
}

