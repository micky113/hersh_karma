import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/karma_action.dart';
import '../../models/wish.dart';
import '../../models/proposed_action.dart';
import '../../models/challenge.dart';
import '../../models/app_feedback.dart';
import '../../models/admin/admin_audit_log.dart';
import '../../models/admin/fraud_alert.dart';
import '../../repositories/karma_repo.dart';
import 'web_google_auth.dart';

class FirebaseKarmaService implements KarmaRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // ================= DEEDS & SUBMISSIONS =================
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
    final data = action.toJson();
    final jsonStr = jsonEncode(data);

    try {
      await _firestore.collection('deeds').doc(action.id).set(data);
      debugPrint('KarmaAction registered in Firestore collection "deeds": ${action.id}');

      // Increment submitter's stats in users collection
      if (action.userId.isNotEmpty) {
        final updateMap = <String, dynamic>{
          'totalSubmissions': FieldValue.increment(1),
          'karmaCredits': FieldValue.increment(action.creditsAwarded),
        };
        if (action.status == DeedStatus.verified) {
          updateMap['verifiedSubmissions'] = FieldValue.increment(1);
        }
        try {
          await _firestore.collection('users').doc(action.userId).set(updateMap, SetOptions(merge: true));
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Firestore submitKarmaAction SDK error: $e');
    }

    if (kIsWeb) {
      try {
        await WebGoogleAuth.setFirestoreDoc('deeds', action.id, jsonStr);
      } catch (e) {
        debugPrint('Direct JS setFirestoreDoc error: $e');
      }
    }

    return action;
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

  // ================= WISHES =================
  Future<void> saveWish(Wish wish) async {
    try {
      await _firestore.collection('wishes').doc(wish.id).set(wish.toJson());
      debugPrint('Wish registered in Firestore collection "wishes": ${wish.id}');
    } catch (e) {
      debugPrint('Firestore saveWish note: $e');
    }

    if (kIsWeb) {
      try {
        await WebGoogleAuth.setFirestoreDoc('wishes', wish.id, jsonEncode(wish.toJson()));
      } catch (_) {}
    }
  }

  Stream<List<Wish>> streamWishes() {
    try {
      return _firestore
          .collection('wishes')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Wish.fromJson(doc.data()))
              .toList());
    } catch (e) {
      debugPrint('Firestore streamWishes note: $e');
      return const Stream.empty();
    }
  }

  // ================= COMMUNITY GOVERNANCE PROPOSALS =================
  Future<void> saveProposal(ProposedAction proposal) async {
    try {
      await _firestore.collection('proposals').doc(proposal.id).set(proposal.toJson());
      debugPrint('Proposal registered in Firestore collection "proposals": ${proposal.id}');
    } catch (e) {
      debugPrint('Firestore saveProposal note: $e');
    }

    if (kIsWeb) {
      try {
        await WebGoogleAuth.setFirestoreDoc('proposals', proposal.id, jsonEncode(proposal.toJson()));
      } catch (_) {}
    }
  }

  Stream<List<ProposedAction>> streamProposals() {
    try {
      return _firestore
          .collection('proposals')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProposedAction.fromJson(doc.data()))
              .toList());
    } catch (e) {
      debugPrint('Firestore streamProposals note: $e');
      return const Stream.empty();
    }
  }

  // ================= FEEDBACK & USER REPORTS =================
  Future<void> saveFeedback(AppFeedback feedback) async {
    try {
      await _firestore.collection('feedback').doc(feedback.id).set(feedback.toJson());
    } catch (e) {
      debugPrint('Firestore saveFeedback note: $e');
    }

    if (kIsWeb) {
      try {
        await WebGoogleAuth.setFirestoreDoc('feedback', feedback.id, jsonEncode(feedback.toJson()));
      } catch (_) {}
    }
  }

  // ================= ADMIN & TRUST CENTER AUDIT LOGS =================
  Future<void> saveAuditLog(AdminAuditLogEntry log) async {
    try {
      await _firestore.collection('audit_logs').doc(log.id).set(log.toJson());
      debugPrint('Admin Audit Log registered in Firestore "audit_logs": ${log.id}');
    } catch (e) {
      debugPrint('Firestore saveAuditLog note: $e');
    }

    if (kIsWeb) {
      try {
        await WebGoogleAuth.setFirestoreDoc('audit_logs', log.id, jsonEncode(log.toJson()));
      } catch (_) {}
    }
  }

  Stream<List<AdminAuditLogEntry>> streamAuditLogs() {
    try {
      return _firestore
          .collection('audit_logs')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => AdminAuditLogEntry.fromJson(doc.data()))
              .toList());
    } catch (e) {
      debugPrint('Firestore streamAuditLogs note: $e');
      return const Stream.empty();
    }
  }

  // ================= FRAUD & ANTI-GAMING ALERTS =================
  Future<void> saveFraudAlert(FraudAlert alert) async {
    try {
      await _firestore.collection('fraud_alerts').doc(alert.id).set(alert.toJson());
      debugPrint('Fraud Alert registered in Firestore "fraud_alerts": ${alert.id}');
    } catch (e) {
      debugPrint('Firestore saveFraudAlert note: $e');
    }

    if (kIsWeb) {
      try {
        await WebGoogleAuth.setFirestoreDoc('fraud_alerts', alert.id, jsonEncode(alert.toJson()));
      } catch (_) {}
    }
  }

  Stream<List<FraudAlert>> streamFraudAlerts() {
    try {
      return _firestore
          .collection('fraud_alerts')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => FraudAlert.fromJson(doc.data()))
              .toList());
    } catch (e) {
      debugPrint('Firestore streamFraudAlerts note: $e');
      return const Stream.empty();
    }
  }
}
