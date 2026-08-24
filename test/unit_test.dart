import 'dart:convert';
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

    test('Should create a dynamic user if not exist', () async {
      final user = await authService.login('new_tester@karma.com', 'password123');
      expect(user, isNotNull);
      expect(user!.name, equals('NEW_TESTER'));
      expect(user.reputationScore, equals(50)); // Default reputation
    });
  });

  group('Proof of Good - Submission & Validator Tests', () {
    test('Should submit a good deed and increment totalSubmissions', () async {
      // 1. Log in John
      final user = await authService.login('john@karma.com', 'password123');
      expect(user!.totalSubmissions, equals(8));

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
      expect(updatedUser!.totalSubmissions, equals(9));
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
        expect(submitted.provisionalCredits, equals(15)); // 30% of 50
        expect(submitted.verifiedCredits, equals(25)); // 50% of 50
        expect(submitted.outcomeCredits, equals(10)); // 20% of 50
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
        // ripple: 20% of (15 + 25 + 10) = 10.
        // Total instantly released = 15 (provisional) + 25 (verified) + 10 (ripple) = 50 credits!
        // Final balance = 100 (initial) + 50 = 150 credits!
        final updatedUser = await mockAuth.getCurrentUser();
        expect(updatedUser!.karmaCredits, equals(150));
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
        expect(updatedWish.sponsorContributions.length, equals(3)); // 2 seeded + 1 new
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
    });
  });
}
