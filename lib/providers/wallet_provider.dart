import 'dart:async';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../repositories/wallet_repo.dart';

class WalletProvider extends ChangeNotifier {
  final WalletRepository _walletRepository;
  List<CryptoTransaction> _ledger = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;
  String? _activeUserId;
  StreamSubscription<List<CryptoTransaction>>? _ledgerSubscription;

  WalletProvider(this._walletRepository);

  List<CryptoTransaction> get ledger => _ledger;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  void updateUserId(String? userId) {
    if (_activeUserId == userId) return;
    _activeUserId = userId;

    _ledgerSubscription?.cancel();

    if (userId != null) {
      _isLoading = true;
      notifyListeners();

      _ledgerSubscription = _walletRepository.streamTransactions(userId).listen((transactions) {
        _ledger = transactions;
        _isLoading = false;
        notifyListeners();
      }, onError: (err) {
        _error = err.toString();
        _isLoading = false;
        notifyListeners();
      });
    } else {
      _ledger = [];
      notifyListeners();
    }
  }

  Future<bool> mintPoGTokens(String userName, double amount, {String? deedId}) async {
    if (_activeUserId == null) return false;
    
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final prevHash = await _walletRepository.getLatestBlockHash();
      final associatedId = deedId ?? 'mint_batch_${DateTime.now().millisecondsSinceEpoch}';
      
      await _walletRepository.mintTokens(
        _activeUserId!,
        userName,
        amount,
        associatedId,
        prevHash,
      );
      
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> transferTokens({
    required String senderName,
    required String receiverId,
    required String receiverName,
    required double amount,
  }) async {
    if (_activeUserId == null) return false;

    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final prevHash = await _walletRepository.getLatestBlockHash();
      
      await _walletRepository.transferTokens(
        _activeUserId!,
        senderName,
        receiverId,
        receiverName,
        amount,
        prevHash,
      );

      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> exchangeKarmaCredits({
    required String userName,
    required String assetName,
    required double assetUnits,
    required int karmaCreditsBurned,
    required String optionSelected,
  }) async {
    if (_activeUserId == null) return false;

    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final prevHash = await _walletRepository.getLatestBlockHash();

      await _walletRepository.logExchange(
        _activeUserId!,
        userName,
        assetName,
        assetUnits,
        karmaCreditsBurned,
        optionSelected,
        prevHash,
      );

      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _ledgerSubscription?.cancel();
    super.dispose();
  }
}
