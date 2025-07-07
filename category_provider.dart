// lib/controller/category_provider.dart
import 'package:flutter/material.dart';
import 'package:money/model/category.dart';
import 'package:money/model/repositories.dart';
import 'package:money/auth/auth_provider.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();
  final AppAuthProvider _authProvider;
  List<Category> _categories = [];
  List<Category> _incomeCategories = [];
  List<Category> _expenseCategories = [];

  List<Category> get categories => _categories;
  List<Category> get incomeCategories => _incomeCategories;
  List<Category> get expenseCategories => _expenseCategories;

  CategoryProvider(this._authProvider) {
    _authProvider.addListener(_onAuthChange);
    _onAuthChange();
  }

  void _onAuthChange() {
    if (_authProvider.isLoggedIn) {
      fetchCategories();
    } else {
      _categories = [];
      _incomeCategories = [];
      _expenseCategories = [];
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    if (_authProvider.user == null) {
      _categories = [];
      notifyListeners();
      return;
    }
    _categories = await _repository.getCategories(userId: _authProvider.user!.uid);
    _incomeCategories = _categories.where((c) => c.type == 'income').toList();
    _expenseCategories = _categories.where((c) => c.type == 'expense').toList();
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    if (_authProvider.user == null) return;
    category.userId = _authProvider.user!.uid;
    await _repository.addCategory(category);
    await fetchCategories();
  }

  Future<void> updateCategory(Category category) async {
    if (_authProvider.user == null) return;
    category.userId = _authProvider.user!.uid;
    await _repository.updateCategory(category);
    await fetchCategories();
  }

  Future<void> deleteCategory(String id) async { 
    if (_authProvider.user == null) return;
    await _repository.deleteCategory(id);
    await fetchCategories();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChange);
    super.dispose();
  }
}
