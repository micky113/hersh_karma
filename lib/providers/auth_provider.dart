import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repo.dart';
import '../services/mock/mock_auth_service.dart';
import '../services/voice_service.dart';
import '../services/firebase/web_google_auth.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<UserProfile?>? _authSubscription;

  AuthProvider(this._authRepository) {
    _listenToAuthChanges();
    loadSavedLanguage();
    restoreSession();
  }

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _listenToAuthChanges() {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        _currentUser = user;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<UserProfile?> restoreSession() async {
    try {
      // 1. Check if auth repository already has the current user
      final repoUser = await _authRepository.getCurrentUser();
      if (repoUser != null) {
        _currentUser = repoUser;
        notifyListeners();
        return _currentUser;
      }

      // 2. Check web Firebase Auth session if running on Web
      if (kIsWeb) {
        final webUser = await WebGoogleAuth.getFirebaseCurrentUser();
        if (webUser != null && webUser['email']?.isNotEmpty == true) {
          final success = await signInWithGoogle(
            email: webUser['email'],
            name: webUser['displayName'],
          );
          if (success && _currentUser != null) {
            return _currentUser;
          }
        }
      }

      // 3. Check device SharedPreferences / localStorage for persistent session
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString('current_session_user');
      if (sessionData != null && sessionData.isNotEmpty) {
        final Map<String, dynamic> userMap = jsonDecode(sessionData);
        final restoredUser = UserProfile.fromJson(userMap);
        _currentUser = restoredUser;
        notifyListeners();
        return _currentUser;
      }
    } catch (e) {
      debugPrint('Restore session note: $e');
    }
    return null;
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authRepository.login(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password, {UserRole role = UserRole.individual}) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authRepository.signUp(name, email, password, role: role);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle({String? email, String? name}) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authRepository.signInWithGoogle(email: email, name: name);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    try {
      final res = await _authRepository.resetPassword(email);
      _setLoading(false);
      return res;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      if (kIsWeb) {
        await WebGoogleAuth.signOutWeb();
      }
      await _authRepository.logout();
      _currentUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_session_user');
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> updateLocalUserProfile(UserProfile updatedProfile) async {
    _currentUser = updatedProfile;
    notifyListeners();
    try {
      await _authRepository.updateUserProfile(updatedProfile);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_session_user', jsonEncode(updatedProfile.toJson()));
    } catch (e) {
      debugPrint('updateLocalUserProfile error: $e');
    }
  }

  Future<void> addCredits(int creditsToAdd, {bool isVerified = false}) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      karmaCredits: _currentUser!.karmaCredits + creditsToAdd,
      totalSubmissions: _currentUser!.totalSubmissions + 1,
      verifiedSubmissions: isVerified ? _currentUser!.verifiedSubmissions + 1 : _currentUser!.verifiedSubmissions,
      reputationScore: (_currentUser!.reputationScore + (isVerified ? 5 : 2)).clamp(0, 100),
    );
    await updateLocalUserProfile(updated);
  }

  String _guestLanguage = 'English';

  String get currentLanguage {
    return _currentUser?.preferredLanguage ?? _guestLanguage;
  }

  Future<void> setLanguage(String lang) async {
    KarmaVoice.currentLanguage = lang;
    if (_currentUser != null) {
      final updated = _currentUser!.copyWith(preferredLanguage: lang);
      updateLocalUserProfile(updated);
    } else {
      _guestLanguage = lang;
      notifyListeners();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('guest_preferred_language', lang);
  }

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('guest_preferred_language') ?? 'English';
    _guestLanguage = saved;
    KarmaVoice.currentLanguage = saved;
    notifyListeners();
  }

  Future<List<UserProfile>> getAllUsers() async {
    return _authRepository.getAllUsers();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
