import '../models/transaction.dart';

abstract class WalletRepository {
  Future<List<CryptoTransaction>> fetchTransactions(String userId);
  Future<CryptoTransaction> mintTokens(
    String userId,
    String userName,
    double amount,
    String associatedDeedId,
    String previousHash,
  );
  Future<CryptoTransaction> transferTokens(
    String senderId,
    String senderName,
    String receiverId,
    String receiverName,
    double amount,
    String previousHash,
  );
  Future<CryptoTransaction> logExchange(
    String userId,
    String userName,
    String assetName,
    double assetUnits,
    int karmaCreditsBurned,
    String optionSelected,
    String previousHash,
  );
  Stream<List<CryptoTransaction>> streamTransactions(String userId);
  Future<String> getLatestBlockHash();
}
