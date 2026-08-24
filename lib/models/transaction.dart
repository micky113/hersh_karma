import 'dart:convert';
import 'package:crypto/crypto.dart';

enum TransactionType {
  mint,
  transfer,
  donation,
  redeem,
}

class CryptoTransaction {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final double amount;
  final DateTime timestamp;
  final TransactionType type;
  final String? associatedDeedId;
  final String previousHash;
  late final String hash;

  CryptoTransaction({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.amount,
    required this.timestamp,
    required this.type,
    this.associatedDeedId,
    required this.previousHash,
    String? hash,
  }) {
    if (hash != null) {
      this.hash = hash;
    } else {
      this.hash = calculateHash();
    }
  }

  String calculateHash() {
    final payload = jsonEncode({
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'associatedDeedId': associatedDeedId,
      'previousHash': previousHash,
    });
    return sha256.convert(utf8.encode(payload)).toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'associatedDeedId': associatedDeedId,
      'previousHash': previousHash,
      'hash': hash,
    };
  }

  factory CryptoTransaction.fromJson(Map<String, dynamic> json) {
    return CryptoTransaction(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String? ?? 'System',
      receiverId: json['receiverId'] as String,
      receiverName: json['receiverName'] as String? ?? 'User',
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'] as String,
        orElse: () => TransactionType.transfer,
      ),
      associatedDeedId: json['associatedDeedId'] as String?,
      previousHash: json['previousHash'] as String? ?? '0',
      hash: json['hash'] as String,
    );
  }
}
