import 'dart:math';
import '../models/karma_activity.dart';
import '../models/karma_category.dart';
import '../models/wish.dart';
import '../models/challenge.dart';
import '../models/community_problem.dart';
import '../models/user_profile.dart';
import '../data/karma_grid_presets.dart';

class SearchResult {
  final List<KarmaActivity> activities;
  final List<CommunityProblem> problems;
  final List<Wish> wishes;
  final List<KarmaChallenge> challenges;
  final List<UserProfile> profiles;

  SearchResult({
    required this.activities,
    required this.problems,
    required this.wishes,
    required this.challenges,
    required this.profiles,
  });

  bool get isEmpty =>
      activities.isEmpty &&
      problems.isEmpty &&
      wishes.isEmpty &&
      challenges.isEmpty &&
      profiles.isEmpty;
}

class SearchService {
  static const Map<String, String> _translations = {
    // Hindi
    'पेड़': 'tree',
    'पौधा': 'plant',
    'कचरा': 'garbage',
    'कूड़ा': 'waste',
    'कुत्ता': 'dog',
    'बिल्ली': 'cat',
    'जानवर': 'animal',
    'पानी': 'water',
    'पढ़ाना': 'teach',
    'स्कूल': 'school',
    'मदद': 'help',
    // Hebrew
    'עץ': 'tree',
    'עצים': 'tree',
    'שתיל': 'plant',
    'לשתול': 'plant',
    'זבל': 'garbage',
    'אשפה': 'waste',
    'כלב': 'dog',
    'חתול': 'cat',
    'חיה': 'animal',
    'חיות': 'animal',
    'מים': 'water',
    'ללמד': 'teach',
    'חינוך': 'school',
    'עזרה': 'help',
  };

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final p = pi / 180;
    final a = 0.5 - cos((lat2 - lat1) * p)/2 + 
          cos(lat1 * p) * cos(lat2 * p) * 
          (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  static String _normalizeQuery(String query) {
    String normalized = query.toLowerCase();
    _translations.forEach((key, val) {
      if (normalized.contains(key.toLowerCase())) {
        normalized = normalized.replaceAll(key.toLowerCase(), val);
      }
    });
    return normalized;
  }

  static SearchResult search({
    required String query,
    required List<CommunityProblem> problems,
    required List<Wish> wishes,
    required List<KarmaChallenge> challenges,
    required List<UserProfile> profiles,
    double? userLat,
    double? userLon,
  }) {
    if (query.trim().isEmpty) {
      return SearchResult(
        activities: [],
        problems: [],
        wishes: [],
        challenges: [],
        profiles: [],
      );
    }

    String normalized = _normalizeQuery(query);
    final isLocationQuery = normalized.contains('near me') || normalized.contains('मेरे पास') || normalized.contains('लीडी') || normalized.contains('לידי') || normalized.contains('proximity');
    
    if (isLocationQuery) {
      normalized = normalized
          .replaceAll('near me', '')
          .replaceAll('मेरे पास', '')
          .replaceAll('लीडी', '')
          .replaceAll('לידי', '')
          .replaceAll('proximity', '')
          .trim();
    }

    final isDurationQuery = normalized.contains('hour') || normalized.contains('sunday') || normalized.contains('quick');
    final matchAll = normalized.isEmpty;

    // 1. Presets / Activities matching
    List<KarmaActivity> matchedActivities = karmaGridPresets.where((act) {
      if (matchAll) return true;
      final text = '${act.title} ${act.category.label} ${act.effortRating}'.toLowerCase();
      if (normalized.contains('animal') && act.category == KarmaCategory.animalWelfare) return true;
      if (normalized.contains('tree') && act.title.toLowerCase().contains('tree')) return true;
      if (normalized.contains('plant') && act.title.toLowerCase().contains('plant')) return true;
      if (normalized.contains('water') && act.title.toLowerCase().contains('water')) return true;
      if (normalized.contains('school') && act.category == KarmaCategory.education) return true;
      return text.contains(normalized);
    }).toList();

    if (isDurationQuery) {
      matchedActivities = matchedActivities.where((act) => act.effortRating == 'Low' || act.effortRating == 'Medium').toList();
    }

    // 2. Problems/Reports matching
    List<CommunityProblem> matchedProblems = problems.where((prob) {
      if (matchAll) return true;
      final text = '${prob.title} ${prob.description} ${prob.category.label}'.toLowerCase();
      return text.contains(normalized);
    }).toList();

    // 3. Wishes matching
    List<Wish> matchedWishes = wishes.where((wish) {
      if (matchAll) return true;
      final text = '${wish.title} ${wish.description} ${wish.category.label} ${wish.retailerName ?? ""}'.toLowerCase();
      return text.contains(normalized);
    }).toList();

    // 4. Challenges matching
    List<KarmaChallenge> matchedChallenges = challenges.where((ch) {
      if (matchAll) return true;
      final text = '${ch.title} ${ch.description} ${ch.category.label}'.toLowerCase();
      return text.contains(normalized);
    }).toList();

    // 5. User/Org profiles matching
    List<UserProfile> matchedProfiles = profiles.where((prof) {
      if (matchAll) return true;
      final text = '${prof.name} ${prof.role.label}'.toLowerCase();
      return text.contains(normalized);
    }).toList();

    // Proximity Sorting
    if (isLocationQuery && userLat != null && userLon != null) {
      matchedProblems.sort((a, b) {
        if (a.latitude == null || b.latitude == null) return 0;
        final distA = _calculateDistance(userLat, userLon, a.latitude!, a.longitude!);
        final distB = _calculateDistance(userLat, userLon, b.latitude!, b.longitude!);
        return distA.compareTo(distB);
      });
    }

    return SearchResult(
      activities: matchedActivities.take(15).toList(),
      problems: matchedProblems,
      wishes: matchedWishes,
      challenges: matchedChallenges,
      profiles: matchedProfiles,
    );
  }
}
