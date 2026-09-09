import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/karma_action.dart';
import '../../repositories/karma_repo.dart';

class FirebaseKarmaService implements KarmaRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  Future<List<KarmaAction>> fetchKarmaActions({String? userId}) async {
    try {
      Query query = _firestore.collection('deeds').orderBy('timestamp', descending: true);
      if (userId != null && userId.isNotEmpty) {
        query = query.where('userId', isEqualTo: userId);
      }
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => KarmaAction.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Firestore fetchKarmaActions note: $e');
      return [];
    }
  }

  @override
  Future<KarmaAction> submitKarmaAction(KarmaAction action) async {
    try {
      final data = action.toJson();
      await _firestore.collection('deeds').doc(action.id).set(data);
      debugPrint('KarmaAction submitted to Firestore deeds: ${action.id}');
      return action;
    } catch (e) {
      debugPrint('Firestore submitKarmaAction note: $e');
      return action;
    }
  }

  @override
  Future<KarmaAction> voteOnKarmaAction(String deedId, String validatorId, bool approve) async {
    try {
      final docRef = _firestore.collection('deeds').doc(deedId);
      return await _firestore.runTransaction<KarmaAction>((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception('Deed $deedId does not exist');
        }
        final currentData = snapshot.data() as Map<String, dynamic>;
        final currentAction = KarmaAction.fromJson(currentData);

        final updatedVotes = Map<String, bool>.from(currentAction.validatorVotes);
        updatedVotes[validatorId] = approve;

        final approveCount = updatedVotes.values.where((v) => v).length;
        final rejectCount = updatedVotes.values.where((v) => !v).length;

        DeedStatus newStatus = currentAction.status;
        int credits = currentAction.creditsAwarded;

        if (approveCount >= 3) {
          newStatus = DeedStatus.verified;
          credits = 350;
        } else if (rejectCount >= 2) {
          newStatus = DeedStatus.rejected;
          credits = 0;
        }

        final updatedAction = currentAction.copyWith(
          validatorVotes: updatedVotes,
          status: newStatus,
          creditsAwarded: credits,
        );

        transaction.update(docRef, updatedAction.toJson());
        return updatedAction;
      });
    } catch (e) {
      debugPrint('Firestore voteOnKarmaAction note: $e');
      throw Exception('Failed to vote: $e');
    }
  }

  @override
  Stream<List<KarmaAction>> streamKarmaActions({String? userId}) {
    try {
      Query query = _firestore.collection('deeds').orderBy('timestamp', descending: true);
      if (userId != null && userId.isNotEmpty) {
        query = query.where('userId', isEqualTo: userId);
      }
      return query.snapshots().map((snapshot) => snapshot.docs
          .map((doc) => KarmaAction.fromJson(doc.data() as Map<String, dynamic>))
          .toList());
    } catch (e) {
      debugPrint('Firestore streamKarmaActions note: $e');
      return const Stream.empty();
    }
  }

  @override
  Stream<List<KarmaAction>> streamPendingActions() {
    try {
      return _firestore
          .collection('deeds')
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => KarmaAction.fromJson(doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      debugPrint('Firestore streamPendingActions note: $e');
      return const Stream.empty();
    }
  }
}
