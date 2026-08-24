import 'dart:async';
// IMPORTANT: Uncomment when Firebase Firestore is configured
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/karma_action.dart';
import '../../repositories/karma_repo.dart';

class FirebaseKarmaService implements KarmaRepository {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<KarmaAction>> fetchKarmaActions({String? userId}) async {
    // Query query = _firestore.collection('deeds').orderBy('timestamp', descending: true);
    // if (userId != null) {
    //   query = query.where('userId', isEqualTo: userId);
    // }
    // final snapshot = await query.get();
    // return snapshot.docs.map((doc) => KarmaAction.fromJson(doc.data() as Map<String, dynamic>)).toList();
    throw UnimplementedError('Configure Firebase project first.');
  }

  @override
  Future<KarmaAction> submitKarmaAction(KarmaAction action) async {
    // await _firestore.collection('deeds').doc(action.id).set(action.toJson());
    // return action;
    throw UnimplementedError('Configure Firebase project first.');
  }

  @override
  Future<KarmaAction> voteOnKarmaAction(String deedId, String validatorId, bool approve) async {
    // final docRef = _firestore.collection('deeds').doc(deedId);
    // // Use firestore transactions to update validator votes safely in a multi-user environment.
    // ...
    throw UnimplementedError('Configure Firebase project first.');
  }

  @override
  Stream<List<KarmaAction>> streamKarmaActions({String? userId}) {
    // Query query = _firestore.collection('deeds').orderBy('timestamp', descending: true);
    // if (userId != null) {
    //   query = query.where('userId', isEqualTo: userId);
    // }
    // return query.snapshots().map((snapshot) =>
    //     snapshot.docs.map((doc) => KarmaAction.fromJson(doc.data() as Map<String, dynamic>)).toList());
    throw UnimplementedError('Configure Firebase project first.');
  }

  @override
  Stream<List<KarmaAction>> streamPendingActions() {
    // return _firestore
    //     .collection('deeds')
    //     .where('status', isEqualTo: 'pending')
    //     .snapshots()
    //     .map((snapshot) =>
    //         snapshot.docs.map((doc) => KarmaAction.fromJson(doc.data() as Map<String, dynamic>)).toList());
    throw UnimplementedError('Configure Firebase project first.');
  }
}
