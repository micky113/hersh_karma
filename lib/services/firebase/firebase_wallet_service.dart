import 'dart:async';
// IMPORTANT: Uncomment when Firebase Firestore is configured
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/transaction.dart';
import '../../repositories/wallet_repo.dart';

class FirebaseWalletService implements WalletRepository {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<CryptoTransaction>> fetchTransactions(String userId) async {
    // final snapshot = await _firestore
    //     .collection('transactions')
    //     .where('senderId', isEqualTo: userId)
    //     .get();
    // // combine with query where receiverId == userId...
    throw UnimplementedError('Configure Firebase project first.');
  }

  @override
  Future<String> getLatestBlockHash() async {
    // final snapshot = await _firestore
    //     .collection('transactions')
    //     .orderBy('timestamp', descending: true)
    //     .limit(1)
    //     .get();
    // if (snapshot.docs.isEmpty) return '0000000000000000000000000000000000000000000000000000000000000000';
    // return snapshot.docs.first.data()['hash'] as String;
    throw UnimplementedError('Configure Firebase project first.');
  }

  @override
  Future<CryptoTransaction> mintTokens(
    String userId,
    String userName,
    double amount,
    String associatedDeedId,
    String previousHash,
  ) async {
    // Add transaction block to 'transactions' collection in firestore
    // Update user profile doc with decreased credits and increased token balance
    throw UnimplementedError('Configure Firebase project first.');
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
    // Add transaction record
    // Atomically decrement sender tokenBalance and increment receiver tokenBalance
    throw UnimplementedError('Configure Firebase project first.');
  }

  @override
  Stream<List<CryptoTransaction>> streamTransactions(String userId) {
    // return _firestore
    //     .collection('transactions')
    //     .orderBy('timestamp', descending: true)
    //     .snapshots()
    //     .map((snapshot) =>
    //         snapshot.docs.map((doc) => CryptoTransaction.fromJson(doc.data() as Map<String, dynamic>)).toList());
    throw UnimplementedError('Configure Firebase project first.');
  }
}
