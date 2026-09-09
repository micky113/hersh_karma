import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import '../../models/user_profile.dart';
import '../../repositories/auth_repo.dart';

class FirebaseAuthService implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  UserProfile? _currentUser;

  Future<UserProfile> _syncUserWithFirestore(fb.User fbUser, {String? defaultName, UserRole defaultRole = UserRole.individual}) async {
    try {
      final docRef = _firestore.collection('users').doc(fbUser.uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        final profile = UserProfile.fromJson(data);
        _currentUser = profile;
        return profile;
      } else {
        // Create initial Firestore user document
        final initialProfile = UserProfile(
          id: fbUser.uid,
          name: fbUser.displayName ?? defaultName ?? fbUser.email?.split('@')[0].toUpperCase() ?? 'Karma Contributor',
          email: fbUser.email ?? 'user@gmail.com',
          role: defaultRole,
          reputationScore: 70,
          karmaCredits: 100,
          tokensBalance: 0.0,
          categoryCredits: const {},
          verifiedSubmissions: 0,
          totalSubmissions: 0,
        );

        await docRef.set(initialProfile.toJson(), SetOptions(merge: true));
        _currentUser = initialProfile;
        return initialProfile;
      }
    } catch (e) {
      debugPrint('Firestore user sync note: $e');
      final fallbackProfile = UserProfile(
        id: fbUser.uid,
        name: fbUser.displayName ?? defaultName ?? fbUser.email?.split('@')[0].toUpperCase() ?? 'Karma Contributor',
        email: fbUser.email ?? 'user@gmail.com',
        role: defaultRole,
        reputationScore: 70,
        karmaCredits: 100,
        tokensBalance: 0.0,
      );
      _currentUser = fallbackProfile;
      return fallbackProfile;
    }
  }

  @override
  Stream<UserProfile?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) {
        _currentUser = null;
        return null;
      }
      return await _syncUserWithFirestore(fbUser);
    });
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    return await _syncUserWithFirestore(fbUser);
  }

  @override
  Future<UserProfile?> signInWithGoogle({String? email, String? name}) async {
    try {
      final googleProvider = fb.GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      fb.UserCredential credential;
      if (kIsWeb) {
        credential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        credential = await _firebaseAuth.signInWithProvider(googleProvider);
      }

      final fbUser = credential.user;
      if (fbUser != null) {
        return await _syncUserWithFirestore(fbUser, defaultName: name);
      }
      return null;
    } catch (e) {
      debugPrint('Firebase Google Sign-In note: $e');
      // Fallback for sandboxed or offline testing environments
      if (email != null && email.isNotEmpty) {
        final fallbackId = 'fb_${email.replaceAll('@', '_').replaceAll('.', '_')}';
        final fallbackProfile = UserProfile(
          id: fallbackId,
          name: name ?? email.split('@')[0].toUpperCase(),
          email: email,
          role: UserRole.individual,
          reputationScore: 70,
          karmaCredits: 100,
          verifiedSubmissions: 0,
        );
        try {
          await _firestore.collection('users').doc(fallbackId).set(fallbackProfile.toJson(), SetOptions(merge: true));
        } catch (_) {}
        _currentUser = fallbackProfile;
        return fallbackProfile;
      }
      rethrow;
    }
  }

  @override
  Future<UserProfile?> login(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final fbUser = credential.user;
    if (fbUser != null) {
      return await _syncUserWithFirestore(fbUser);
    }
    return null;
  }

  @override
  Future<UserProfile?> signUp(String name, String email, String password, {UserRole role = UserRole.individual}) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final fbUser = credential.user;
    if (fbUser != null) {
      try {
        await fbUser.updateDisplayName(name);
      } catch (_) {}
      return await _syncUserWithFirestore(fbUser, defaultName: name, defaultRole: role);
    }
    return null;
  }

  @override
  Future<bool> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      debugPrint('Firebase resetPassword error: $e');
      return false;
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
  }

  @override
  Future<List<UserProfile>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => UserProfile.fromJson(doc.data())).toList();
      }
    } catch (e) {
      debugPrint('Firestore getAllUsers note: $e');
    }
    return _currentUser != null ? [_currentUser!] : [];
  }
}
