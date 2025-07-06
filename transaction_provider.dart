// lib/controller/transaction_provider.dart
import 'package:flutter/material.dart';
import 'package:money/model/transaction.dart';
import 'package:money/model/repositories.dart';
import 'package:money/auth/auth_provider.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();
  final AppAuthProvider _authProvider;
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;
  double get totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0.0, (sum, item) => sum + item.amount);
  double get totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, item) => sum + item.amount);
  double get balance => totalIncome - totalExpense;

  TransactionProvider(this._authProvider) {
    _authProvider.addListener(_onAuthChange);
    _onAuthChange();
  }

  void _onAuthChange() {
    if (_authProvider.isLoggedIn) {
      fetchTransactions();
    } else {
      _transactions = [];
      notifyListeners();
    }
  }

  Future<void> fetchTransactions() async {
    debugPrint('--- fetchTransactions START ---');
    if (_authProvider.user == null) {
      debugPrint('fetchTransactions: User is null, cannot fetch.');
      _transactions = [];
      notifyListeners();
      return;
    }
    final currentUserUid = _authProvider.user!.uid;
    debugPrint('fetchTransactions: Current User UID from AuthProvider: $currentUserUid'); // <-- PENTING: Tambahkan ini

    try {
      _transactions = (await _repository.getTransactions(currentUserUid)).cast<Transaction>();
      debugPrint('fetchTransactions: Fetched ${_transactions.length} transactions.');
      notifyListeners();
    } catch (e) {
      debugPrint('fetchTransactions: ERROR: $e');
    }
    debugPrint('--- fetchTransactions END ---');
  }

  Future<void> addTransaction(Transaction transaction) async {
    if (_authProvider.user == null) return;
    transaction.userId = _authProvider.user!.uid;
    await _repository.addTransaction(transaction);
    await fetchTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    if (_authProvider.user == null) return;
    transaction.userId = _authProvider.user!.uid;
    await _repository.updateTransaction(transaction);
    await fetchTransactions();
  }

  Future<void> deleteTransaction(String id) async { // Parameter harus String
    if (_authProvider.user == null) return;
    await _repository.deleteTransaction(id);
    await fetchTransactions();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChange);
    super.dispose();
  }
}