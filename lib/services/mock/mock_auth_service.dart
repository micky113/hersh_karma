import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_profile.dart';
import '../../repositories/auth_repo.dart';

class MockAuthService implements AuthRepository {
  final StreamController<UserProfile?> _authStateController = StreamController<UserProfile?>.broadcast();
  UserProfile? _currentUser;

  // Static user store simulator
  static final Map<String, Map<String, dynamic>> _mockUserDatabase = {
    'john@karma.com': {
      'id': 'user_john',
      'name': 'John Doe',
      'email': 'john@karma.com',
      'password': 'password123',
      'role': 'individual',
      'reputationScore': 65,
      'karmaCredits': 120,
      'tokensBalance': 2.5,
      'categoryCredits': {'environment': 50, 'animalWelfare': 40, 'humanKindness': 30},
      'totalSubmissions': 126,
      'verifiedSubmissions': 118,
      'wasteRecoveredKg': 4200.0,
      'peopleTaught': 37,
      'karmaRipplesCount': 12,
    },
    'jane@karma.com': {
      'id': 'user_jane',
      'name': 'Green Earth Foundation (NGO)',
      'email': 'jane@karma.com',
      'password': 'password123',
      'role': 'ngo',
      'reputationScore': 90,
      'karmaCredits': 450,
      'tokensBalance': 100.0,
      'categoryCredits': {'environment': 300, 'healthcare': 150},
      'totalSubmissions': 62,
      'verifiedSubmissions': 62,
      'isOrgVerified': true,
      'projectsCount': 14,
      'peopleReached': 28400,
      'totalVolunteers': 1200,
    },
    'school@karma.com': {
      'id': 'user_school',
      'name': 'Apex Academy (School)',
      'email': 'school@karma.com',
      'password': 'password123',
      'role': 'institution',
      'reputationScore': 85,
      'karmaCredits': 500,
      'tokensBalance': 0.0,
      'categoryCredits': {'education': 400},
      'totalSubmissions': 3820,
      'verifiedSubmissions': 3800,
      'isOrgVerified': true,
      'studentsCount': 640,
    },
    'corp@karma.com': {
      'id': 'user_corp',
      'name': 'CSR TechCorp (Business)',
      'email': 'corp@karma.com',
      'password': 'password123',
      'role': 'corporate',
      'reputationScore': 95,
      'karmaCredits': 2500,
      'tokensBalance': 500.0,
      'categoryCredits': {'environment': 1000},
      'totalSubmissions': 37,
      'verifiedSubmissions': 37,
      'isOrgVerified': true,
      'employeesCount': 2450,
      'projectsCount': 37,
    }
  };

  MockAuthService() {
    _initSession();
  }

  Future<void> _initSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString('current_session_user');
    if (sessionData != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(sessionData);
        _currentUser = UserProfile.fromJson(userMap);
        _authStateController.add(_currentUser);
      } catch (e) {
        // error parsing session
        _authStateController.add(null);
      }
    } else {
      _authStateController.add(null);
    }
  }

  Future<void> _saveSession(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_session_user', jsonEncode(user.toJson()));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_session_user');
  }

  @override
  Stream<UserProfile?> get authStateChanges => _authStateController.stream;

  @override
  Future<UserProfile?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserProfile?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulate network lag

    final normalizedEmail = email.trim().toLowerCase();
    if (_mockUserDatabase.containsKey(normalizedEmail)) {
      final userData = _mockUserDatabase[normalizedEmail]!;
      if (userData['password'] == password) {
        // Load custom profile changes if saved in local prefs previously
        final prefs = await SharedPreferences.getInstance();
        final storedProfileJson = prefs.getString('profile_${userData['id']}');
        
        if (storedProfileJson != null) {
          _currentUser = UserProfile.fromJson(jsonDecode(storedProfileJson));
        } else {
          _currentUser = UserProfile.fromJson(userData);
          await prefs.setString('profile_${userData['id']}', jsonEncode(_currentUser!.toJson()));
        }
        
        await _saveSession(_currentUser!);
        _authStateController.add(_currentUser);
        return _currentUser;
      } else {
        throw Exception('Incorrect password');
      }
    } else {
      // Dynamic profile creation if user does not exist (so user can log in with custom emails!)
      final newUserId = 'user_${normalizedEmail.split('@')[0]}';
      final prefs = await SharedPreferences.getInstance();
      final storedProfileJson = prefs.getString('profile_$newUserId');

      if (storedProfileJson != null) {
        _currentUser = UserProfile.fromJson(jsonDecode(storedProfileJson));
      } else {
        _currentUser = UserProfile(
          id: newUserId,
          name: normalizedEmail.split('@')[0].toUpperCase(),
          email: normalizedEmail,
        );
        await prefs.setString('profile_$newUserId', jsonEncode(_currentUser!.toJson()));
      }
      
      await _saveSession(_currentUser!);
      _authStateController.add(_currentUser);
      return _currentUser;
    }
  }

  @override
  Future<UserProfile?> signUp(String name, String email, String password, {UserRole role = UserRole.individual}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final normalizedEmail = email.trim().toLowerCase();
    
    final newUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final newProfile = UserProfile(
      id: newUserId,
      name: name,
      email: normalizedEmail,
      role: role,
      reputationScore: 50,
      karmaCredits: 0,
      tokensBalance: 0.0,
      categoryCredits: const {},
    );

    _currentUser = newProfile;
    // Save to prefs
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_$newUserId', jsonEncode(newProfile.toJson()));
    await _saveSession(_currentUser!);
    
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await _clearSession();
    _authStateController.add(null);
  }

  // Helper method for other services to update the current user profile state
  void updateLocalUserProfile(UserProfile updatedProfile) async {
    _currentUser = updatedProfile;
    await _saveSession(updatedProfile);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_${updatedProfile.id}', jsonEncode(updatedProfile.toJson()));
    _authStateController.add(updatedProfile);
  }
}
