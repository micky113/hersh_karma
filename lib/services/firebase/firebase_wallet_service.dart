import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/transaction.dart';
import '../../models/user_profile.dart';
import '../../repositories/wallet_repo.dart';
import 'web_google_auth.dart';

class FirebaseWalletService implements WalletRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  Future<List<CryptoTransaction>> fetchTransactions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CryptoTransaction.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Firestore fetchTransactions note: $e');
      return [];
    }
  }

  @override
  Future<String> getLatestBlockHash() async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        if (data.containsKey('hash') && data['hash'] != null) {
          return data['hash'] as String;
        }
      }
    } catch (e) {
      debugPrint('Firestore getLatestBlockHash note: $e');
    }
    return '0000000000000000000000000000000000000000000000000000000000000000';
  }

  @override
  Future<CryptoTransaction> mintTokens(
    String userId,
    String userName,
    double amount,
    String associatedDeedId,
    String previousHash,
  ) async {
    final newTx = CryptoTransaction(
      id: 'tx_mint_${DateTime.now().millisecondsSinceEpoch}',
      senderId: '0xMINT_PROTOCOL',
      senderName: 'PoG Minting Contract',
      receiverId: userId,
      receiverName: userName,
      amount: amount,
      timestamp: DateTime.now(),
      type: TransactionType.mint,
      associatedDeedId: associatedDeedId,
      previousHash: previousHash,
    );

    try {
      // 1. Save transaction in Firestore
      await _firestore.collection('transactions').doc(newTx.id).set(newTx.toJson());

      // 2. Update user profile in Firestore
      final userDocRef = _firestore.collection('users').doc(userId);
      final userSnapshot = await userDocRef.get();

      final creditsToDeduct = (amount * 100).round();
      if (userSnapshot.exists && userSnapshot.data() != null) {
        final profile = UserProfile.fromJson(userSnapshot.data()!);
        final updatedProfile = profile.copyWith(
          karmaCredits: (profile.karmaCredits - creditsToDeduct).clamp(0, 9999999),
          tokensBalance: profile.tokensBalance + amount,
        );
        await userDocRef.set(updatedProfile.toJson(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore mintTokens note: $e');
    }

    if (kIsWeb) {
      try {
        await WebGoogleAuth.setFirestoreDoc('transactions', newTx.id, jsonEncode(newTx.toJson()));
      } catch (_) {}
    }

    return newTx;
  }

  @override
  Future<CryptoTransaction> transferTokens(
    String senderId,
    String senderName,
    String receiverId,
    String receiverName,
    double amount,
    String previousHash,
  ) async {
    final newTx = CryptoTransaction(
      id: 'tx_transfer_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      amount: amount,
      timestamp: DateTime.now(),
      type: receiverId.startsWith('charity_') ? TransactionType.donation : TransactionType.transfer,
      previousHash: previousHash,
    );

    try {
      // 1. Save transaction
      await _firestore.collection('transactions').doc(newTx.id).set(newTx.toJson());

      // 2. Decrement sender balance in Firestore
      final senderRef = _firestore.collection('users').doc(senderId);
      final senderSnap = await senderRef.get();
      if (senderSnap.exists && senderSnap.data() != null) {
        final sender = UserProfile.fromJson(senderSnap.data()!);
        await senderRef.update({
          'tokensBalance': (sender.tokensBalance - amount).clamp(0.0, 9999999.0),
        });
      }

      // 3. Increment receiver balance if receiver is a registered user
      final receiverRef = _firestore.collection('users').doc(receiverId);
      final receiverSnap = await receiverRef.get();
      if (receiverSnap.exists && receiverSnap.data() != null) {
        final receiver = UserProfile.fromJson(receiverSnap.data()!);
        await receiverRef.update({
          'tokensBalance': receiver.tokensBalance + amount,
        });
      }
    } catch (e) {
      debugPrint('Firestore transferTokens note: $e');
    }

    return newTx;
  }

  @override
  Future<CryptoTransaction> logExchange(
    String userId,
    String userName,
    String assetName,
    double assetUnits,
    int karmaCreditsBurned,
    String optionSelected,
    String previousHash,
  ) async {
    final newTx = CryptoTransaction(
      id: 'tx_exchange_${DateTime.now().millisecondsSinceEpoch}',
      senderId: userId,
      senderName: userName,
      receiverId: '0xEXCHANGE_PROTOCOL',
      receiverName: '$assetName ($optionSelected)',
      amount: assetUnits,
      timestamp: DateTime.now(),
      type: TransactionType.redeem,
      associatedDeedId: 'exchange_burn_${karmaCreditsBurned}_credits',
      previousHash: previousHash,
    );

    try {
      await _firestore.collection('transactions').doc(newTx.id).set(newTx.toJson());

      final userRef = _firestore.collection('users').doc(userId);
      final userSnap = await userRef.get();
      if (userSnap.exists && userSnap.data() != null) {
        final profile = UserProfile.fromJson(userSnap.data()!);
        await userRef.update({
          'karmaCredits': (profile.karmaCredits - karmaCreditsBurned).clamp(0, 9999999),
        });
      }
    } catch (e) {
      debugPrint('Firestore logExchange note: $e');
    }

    return newTx;
  }

  @override
  Stream<List<CryptoTransaction>> streamTransactions(String userId) {
    try {
      return _firestore
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => CryptoTransaction.fromJson(doc.data()))
              .toList());
    } catch (e) {
      debugPrint('Firestore streamTransactions note: $e');
      return const Stream.empty();
    }
  }
}
