import '../models/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile?> login(String email, String password);
  Future<UserProfile?> signUp(String name, String email, String password, {UserRole role = UserRole.individual});
  Future<void> logout();
  Future<UserProfile?> getCurrentUser();
  Stream<UserProfile?> get authStateChanges;
}
