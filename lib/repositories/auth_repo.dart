import '../models/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile?> login(String email, String password);
  Future<UserProfile?> signUp(String name, String email, String password, {UserRole role = UserRole.individual});
  Future<UserProfile?> signInWithGoogle({String? email, String? name});
  Future<bool> resetPassword(String email);
  Future<void> logout();
  Future<UserProfile?> getCurrentUser();
  Stream<UserProfile?> get authStateChanges;
  Future<List<UserProfile>> getAllUsers();
  Future<void> updateUserProfile(UserProfile profile);
}
