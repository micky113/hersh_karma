import 'package:flutter_test/flutter_test.dart';
import 'package:hersh_karma/models/karma_category.dart';
import 'package:hersh_karma/models/community_problem.dart';
import 'package:hersh_karma/models/wish.dart';
import 'package:hersh_karma/models/challenge.dart';
import 'package:hersh_karma/models/user_profile.dart';
import 'package:hersh_karma/services/search_service.dart';

void main() {
  group('Universal Search Engine Tests', () {
    final List<CommunityProblem> mockProblems = [
      CommunityProblem(
        id: 'prob_env',
        reporterId: 'user_1',
        reporterName: 'John',
        title: 'Roadside garbage dump',
        description: 'Huge waste dumped near sector park.',
        category: KarmaCategory.environment,
        latitude: 12.9716,
        longitude: 77.5946,
        timestamp: DateTime.now(),
      ),
      CommunityProblem(
        id: 'prob_ani',
        reporterId: 'user_2',
        reporterName: 'Alice',
        title: 'Injured street dog',
        description: 'Stray dog needs vet aid.',
        category: KarmaCategory.animalWelfare,
        latitude: 12.9000,
        longitude: 77.5000,
        timestamp: DateTime.now(),
      ),
    ];

    final List<Wish> mockWishes = [
      Wish(
        id: 'wish_edu',
        userId: 'user_1',
        userName: 'John',
        title: 'Books for school kids',
        description: 'Need textbooks for secondary classes.',
        category: WishCategory.education,
        karmaTarget: 1000,
        karmaRaised: 200,
        wishPlan: const [],
        milestones: const [],
        sponsorContributions: const [],
        createdAt: DateTime.now(),
      ),
    ];

    final List<KarmaChallenge> mockChallenges = [
      KarmaChallenge(
        id: 'ch_water',
        title: 'Save Water Challenge',
        description: 'Reduce usage and fix leaks.',
        category: KarmaCategory.environment,
        targetCount: 5,
        rewardCredits: 50,
      ),
    ];

    final List<UserProfile> mockProfiles = [
      UserProfile(
        id: 'user_jane',
        name: 'Jane Smith NGO',
        email: 'jane@karma.com',
        role: UserRole.ngo,
      ),
      UserProfile(
        id: 'user_apex',
        name: 'Apex Academy School',
        email: 'apex@karma.com',
        role: UserRole.institution,
      ),
    ];

    test('Should translate Hindi queries and find correct presets and categories', () {
      // "पेड़" (tree) should match tree planting presets
      final results = SearchService.search(
        query: 'पेड़',
        problems: mockProblems,
        wishes: mockWishes,
        challenges: mockChallenges,
        profiles: mockProfiles,
      );

      expect(results.activities.isNotEmpty, isTrue);
      expect(results.activities.any((act) => act.title.toLowerCase().contains('tree')), isTrue);
    });

    test('Should translate Hebrew queries and find correct animal welfare category presets', () {
      // "חיות" (animal) should match animal welfare category presets
      final results = SearchService.search(
        query: 'חיות',
        problems: mockProblems,
        wishes: mockWishes,
        challenges: mockChallenges,
        profiles: mockProfiles,
      );

      expect(results.activities.isNotEmpty, isTrue);
      expect(results.activities.any((act) => act.category == KarmaCategory.animalWelfare), isTrue);
    });

    test('Should match synonyms and category labels semantically', () {
      final results = SearchService.search(
        query: 'dog',
        problems: mockProblems,
        wishes: mockWishes,
        challenges: mockChallenges,
        profiles: mockProfiles,
      );

      expect(results.problems.length, equals(1));
      expect(results.problems.first.id, equals('prob_ani'));
    });

    test('Should sort community problems based on distance proximity to user coordinates', () {
      // User is located near 12.9716, 77.5946 (same location as prob_env)
      final results = SearchService.search(
        query: 'near me',
        problems: mockProblems,
        wishes: mockWishes,
        challenges: mockChallenges,
        profiles: mockProfiles,
        userLat: 12.9710,
        userLon: 77.5940,
      );

      expect(results.problems.length, equals(2));
      expect(results.problems.first.id, equals('prob_env')); // closer
      expect(results.problems.last.id, equals('prob_ani')); // further
    });

    test('Should filter and sort presets based on quick duration queries', () {
      // "quick" matches low/medium effort presets
      final results = SearchService.search(
        query: 'quick tree',
        problems: mockProblems,
        wishes: mockWishes,
        challenges: mockChallenges,
        profiles: mockProfiles,
      );

      expect(results.activities.every((act) => act.effortRating == 'Low' || act.effortRating == 'Medium'), isTrue);
    });
  });
}
