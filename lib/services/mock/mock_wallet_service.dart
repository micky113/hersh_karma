import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/transaction.dart';
import '../../models/user_profile.dart';
import '../../repositories/wallet_repo.dart';
import 'mock_auth_service.dart';

class MockWalletService implements WalletRepository {
  final MockAuthService _authService;
  final StreamController<List<CryptoTransaction>> _transactionsStreamController = StreamController<List<CryptoTransaction>>.broadcast();
  final List<CryptoTransaction> _inMemoryTransactions = [];

  MockWalletService(this._authService) {
    _initTransactions();
  }

  Future<void> _initTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final storedJson = prefs.getString('mock_wallet_transactions');

    if (storedJson != null) {
      try {
        final List<dynamic> list = jsonDecode(storedJson);
        _inMemoryTransactions.clear();
        _inMemoryTransactions.addAll(list.map((item) => CryptoTransaction.fromJson(item as Map<String, dynamic>)));
      } catch (e) {
        _loadSeedTransactions();
      }
    } else {
      _loadSeedTransactions();
    }
    _broadcast();
  }

  void _loadSeedTransactions() {
    _inMemoryTransactions.clear();

    // Genesis Block
    final genesisTx = CryptoTransaction(
      id: 'tx_genesis',
      senderId: '0xSYSTEM',
      senderName: 'PoG Genesis Engine',
      receiverId: '0xSYSTEM',
      receiverName: 'Genesis Pool',
      amount: 1000000.0,
      timestamp: DateTime.now().subtract(const Duration(days: 30)),
      type: TransactionType.mint,
      previousHash: '0000000000000000000000000000000000000000000000000000000000000000',
    );

    final mint1 = CryptoTransaction(
      id: 'tx_seed_1',
      senderId: '0xMINT_PROTOCOL',
      senderName: 'PoG Minting Contract',
      receiverId: 'user_john',
      receiverName: 'John Doe',
      amount: 1.0,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: TransactionType.mint,
      associatedDeedId: 'action_seed_1',
      previousHash: genesisTx.hash,
    );

    final mint2 = CryptoTransaction(
      id: 'tx_seed_2',
      senderId: '0xMINT_PROTOCOL',
      senderName: 'PoG Minting Contract',
      receiverId: 'user_john',
      receiverName: 'John Doe',
      amount: 1.5,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: TransactionType.mint,
      associatedDeedId: 'action_seed_2',
      previousHash: mint1.hash,
    );

    _inMemoryTransactions.addAll([genesisTx, mint1, mint2]);
    _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'mock_wallet_transactions',
      jsonEncode(_inMemoryTransactions.map((e) => e.toJson()).toList()),
    );
  }

  void _broadcast() {
    _transactionsStreamController.add(List.unmodifiable(_inMemoryTransactions));
  }

  @override
  Future<List<CryptoTransaction>> fetchTransactions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _inMemoryTransactions
        .where((element) => element.senderId == userId || element.receiverId == userId)
        .toList();
  }

  @override
  Future<String> getLatestBlockHash() async {
    if (_inMemoryTransactions.isEmpty) {
      return '0000000000000000000000000000000000000000000000000000000000000000';
    }
    return _inMemoryTransactions.last.hash;
  }

  @override
  Future<CryptoTransaction> mintTokens(
    String userId,
    String userName,
    double amount,
    String associatedDeedId,
    String previousHash,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1000));

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

    _inMemoryTransactions.add(newTx);
    await _saveToPrefs();
    _broadcast();

    // Deduct karma credits and add token balance in User Profile
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('profile_$userId');
    if (profileJson != null) {
      final userMap = jsonDecode(profileJson);
      final profile = UserProfile.fromJson(userMap);

      // 100 credits consumed per 1.0 token minted
      final creditsToDeduct = (amount * 100).round();
      final updatedProfile = profile.copyWith(
        karmaCredits: (profile.karmaCredits - creditsToDeduct).clamp(0, 9999999),
        tokensBalance: profile.tokensBalance + amount,
      );

      await prefs.setString('profile_$userId', jsonEncode(updatedProfile.toJson()));

      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null && currentUser.id == userId) {
        _authService.updateLocalUserProfile(updatedProfile);
      }
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
    await Future.delayed(const Duration(milliseconds: 1000));

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

    _inMemoryTransactions.add(newTx);
    await _saveToPrefs();
    _broadcast();

    // Deduct sender balance and add receiver balance (if receiver is a user in our DB)
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Update Sender
    final senderJson = prefs.getString('profile_$senderId');
    if (senderJson != null) {
      final senderMap = jsonDecode(senderJson);
      final senderProfile = UserProfile.fromJson(senderMap);
      final updatedSender = senderProfile.copyWith(
        tokensBalance: (senderProfile.tokensBalance - amount).clamp(0.0, 9999999.0),
      );
      await prefs.setString('profile_$senderId', jsonEncode(updatedSender.toJson()));

      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null && currentUser.id == senderId) {
        _authService.updateLocalUserProfile(updatedSender);
      }
    }

    // 2. Update Receiver (if user)
    final receiverJson = prefs.getString('profile_$receiverId');
    if (receiverJson != null) {
      final receiverMap = jsonDecode(receiverJson);
      final receiverProfile = UserProfile.fromJson(receiverMap);
      final updatedReceiver = receiverProfile.copyWith(
        tokensBalance: receiverProfile.tokensBalance + amount,
      );
      await prefs.setString('profile_$receiverId', jsonEncode(updatedReceiver.toJson()));
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
    await Future.delayed(const Duration(milliseconds: 1000));

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

    _inMemoryTransactions.add(newTx);
    await _saveToPrefs();
    _broadcast();

    // Deduct karma credits from User Profile
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('profile_$userId');
    if (profileJson != null) {
      final userMap = jsonDecode(profileJson);
      final profile = UserProfile.fromJson(userMap);

      final updatedProfile = profile.copyWith(
        karmaCredits: (profile.karmaCredits - karmaCreditsBurned).clamp(0, 9999999),
      );

      await prefs.setString('profile_$userId', jsonEncode(updatedProfile.toJson()));

      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null && currentUser.id == userId) {
        _authService.updateLocalUserProfile(updatedProfile);
      }
    }

    return newTx;
  }

  @override
  Stream<List<CryptoTransaction>> streamTransactions(String userId) {
    Timer.run(() => _broadcast());
    return _transactionsStreamController.stream.map((list) {
      // In a real blockchain wallet, you'd see all blocks, or filter by your address.
      // Let's return the full ledger list so users can inspect the ledger, but ordered newest first.
      return list.reversed.toList();
    });
  }
}
