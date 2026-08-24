import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repo.dart';
import '../services/mock/mock_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<UserProfile?>? _authSubscription;

  AuthProvider(this._authRepository) {
    _listenToAuthChanges();
  }

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _listenToAuthChanges() {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    });
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

  Future<bool> signUp(String name, String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authRepository.signUp(name, email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authRepository.logout();
      _currentUser = null;
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

  void updateLocalUserProfile(UserProfile updatedProfile) {
    if (_authRepository is MockAuthService) {
      (_authRepository as MockAuthService).updateLocalUserProfile(updatedProfile);
    } else {
      _currentUser = updatedProfile;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
