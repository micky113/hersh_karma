import 'dart:async';
// IMPORTANT: Uncomment these when you have configured Firebase in your project
// import 'package:firebase_auth/firebase_auth.dart' as fb;
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile.dart';
import '../../repositories/auth_repo.dart';

class FirebaseAuthService implements AuthRepository {
  // final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<UserProfile?> get authStateChanges {
    // TODO: Implement real Firebase Auth state changes mapping to Firestore profiles
    // return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
    //   if (fbUser == null) return null;
    //   final doc = await _firestore.collection('users').doc(fbUser.uid).get();
    //   if (doc.exists) {
    //     return UserProfile.fromJson(doc.data()!);
    //   }
    //   return null;
    // });
    throw UnimplementedError('Configure Firebase project and uncomment dependencies first.');
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    // final fbUser = _firebaseAuth.currentUser;
    // if (fbUser == null) return null;
    // final doc = await _firestore.collection('users').doc(fbUser.uid).get();
    // return doc.exists ? UserProfile.fromJson(doc.data()!) : null;
    throw UnimplementedError('Configure Firebase project first.');
  }

  @override
  Future<UserProfile?> login(String email, String password) async {
    // final credential = await _firebaseAuth.signInWithEmailAndPassword(
    //   email: email,
    //   password: password,
    // );
    // final uid = credential.user!.uid;
    // final doc = await _firestore.collection('users').doc(uid).get();
    // return UserProfile.fromJson(doc.data()!);
    throw UnimplementedError('Configure Firebase project first.');
  }

  @override
  Future<UserProfile?> signUp(String name, String email, String password) async {
    // final credential = await _firebaseAuth.createUserWithEmailAndPassword(
    //   email: email,
    //   password: password,
    // );
    // final uid = credential.user!.uid;
    // final newProfile = UserProfile(
    //   id: uid,
    //   name: name,
    //   email: email,
    // );
    // await _firestore.collection('users').doc(uid).set(newProfile.toJson());
    // return newProfile;
    throw UnimplementedError('Configure Firebase project first.');
  }

  @override
  Future<void> logout() async {
    throw UnimplementedError('Configure Firebase project first.');
  }

  @override
  Future<List<UserProfile>> getAllUsers() async {
    throw UnimplementedError('Configure Firebase project first.');
  }
}
