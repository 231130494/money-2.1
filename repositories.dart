// lib/model/repositories.dart
// Jika Anda tidak menggunakan SQLite, Anda bisa menghapus baris-baris ini dan file database_helper.dart
// import 'package:sqflite/sqflite.dart' as sql;
// import 'package:money/model/database_helper.dart';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore_db;
import 'package:money/model/category.dart';
import 'package:money/model/transaction.dart';

class CategoryRepository {
  // Jika tidak menggunakan SQLite, Anda bisa menghapus baris ini
  // final DatabaseHelper _dbHelper = DatabaseHelper();
  final firestore_db.CollectionReference _categoriesCollection =
      firestore_db.FirebaseFirestore.instance.collection('categories');

  // Hapus semua method *Local (SQLite) jika tidak digunakan. Contoh:
  // Future<int> insertCategoryLocal(Category category) async { /* ... */ }
  // Future<List<Category>> getCategoriesLocal({String? type}) async { /* ... */ }
  // Future<int> updateCategoryLocal(Category category) async { /* ... */ }
  // Future<int> deleteCategoryLocal(int id) async { /* ... */ }
  // Future<Category?> getCategoryByIdLocal(int id) async { /* ... */ }

  Future<void> addCategory(Category category) async {
    if (category.id == null) {
      firestore_db.DocumentReference docRef = await _categoriesCollection.add({
        'name': category.name,
        'type': category.type,
        'color': category.color,
        'userId': category.userId,
      });
      category.id = docRef.id; // Harus String
    } else {
      await _categoriesCollection.doc(category.id!).set({ // ID harus String
        'name': category.name,
        'type': category.type,
        'color': category.color,
        'userId': category.userId,
      });
    }
    // Hapus panggilan ke method Local jika tidak digunakan. Contoh:
    // await updateCategoryLocal(category);
  }

  Future<List<Category>> getCategories({String? type, String? userId}) async {
    firestore_db.Query query = _categoriesCollection.orderBy('name');
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    firestore_db.QuerySnapshot snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Category.fromMap({...data, 'id': doc.id}); // Ambil ID dokumen langsung (String)
    }).toList();
  }

  Future<void> updateCategory(Category category) async {
    if (category.id == null) {
      throw Exception("Category ID cannot be null for update operation.");
    }
    await _categoriesCollection.doc(category.id!).update({ // ID harus String
      'name': category.name,
      'type': category.type,
      'color': category.color,
      'userId': category.userId,
    });
    // Hapus panggilan ke method Local jika tidak digunakan
    // await updateCategoryLocal(category);
  }

  Future<void> deleteCategory(String id) async { // Parameter harus String
    await _categoriesCollection.doc(id).delete();
    // Hapus panggilan ke method Local jika tidak digunakan
    // await deleteCategoryLocal(id);
  }

  Future<Category?> getCategoryById(String id) async { // Parameter harus String
    firestore_db.DocumentSnapshot doc = await _categoriesCollection.doc(id).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return Category.fromMap({...data, 'id': doc.id});
    }
    return null;
  }
}

class TransactionRepository {
  // Jika tidak menggunakan SQLite, Anda bisa menghapus baris ini
  // final DatabaseHelper _dbHelper = DatabaseHelper();
  final firestore_db.CollectionReference _transactionsCollection =
      firestore_db.FirebaseFirestore.instance.collection('transactions');
  final CategoryRepository _categoryRepository = CategoryRepository();

  // Hapus semua method *Local (SQLite) jika tidak digunakan. Contoh:
  // Future<int> insertTransactionLocal(Transaction transaction) async { ... }
  // Future<List<Transaction>> getTransactionsLocal() async { ... }
  // Future<int> updateTransactionLocal(Transaction transaction) async { ... }
  // Future<int> deleteTransactionLocal(int id) async { ... }

  Future<void> addTransaction(Transaction transaction) async {
    if (transaction.id == null) {
      firestore_db.DocumentReference docRef = await _transactionsCollection.add({
        'amount': transaction.amount,
        'description': transaction.description,
        'type': transaction.type,
        'date': firestore_db.Timestamp.fromMicrosecondsSinceEpoch(transaction.date.microsecondsSinceEpoch),
        'categoryId': transaction.categoryId, // categoryId juga String
        'userId': transaction.userId,
      });
      transaction.id = docRef.id; // Harus String
    } else {
      await _transactionsCollection.doc(transaction.id!).set({ // ID harus String
        'amount': transaction.amount,
        'description': transaction.description,
        'type': transaction.type,
        'date': firestore_db.Timestamp.fromMicrosecondsSinceEpoch(transaction.date.microsecondsSinceEpoch),
        'categoryId': transaction.categoryId, // categoryId juga String
        'userId': transaction.userId,
      });
    }
    // Hapus panggilan ke method Local jika tidak digunakan
    // await insertTransactionLocal(transaction);
  }

  Future<List<Transaction>> getTransactions(String userId) async {
    firestore_db.QuerySnapshot snapshot = await _transactionsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();
    List<Transaction> transactions = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final transaction = Transaction(
        id: doc.id, // Ambil ID dokumen langsung (String)
        amount: (data['amount'] as num).toDouble(),
        description: data['description'] as String?,
        type: data['type'] as String,
        date: (data['date'] as firestore_db.Timestamp).toDate(),
        categoryId: data['categoryId'] as String?, // categoryId harus String
        userId: data['userId'] as String?,
      );

      if (transaction.categoryId != null) {
        transaction.category = await _categoryRepository.getCategoryById(transaction.categoryId!);
      }
      transactions.add(transaction);
    }
    return transactions;
  }

  Future<void> updateTransaction(Transaction transaction) async {
    if (transaction.id == null) {
      throw Exception("Transaction ID cannot be null for update operation.");
    }
    await _transactionsCollection.doc(transaction.id!).update({ // ID harus String
      'amount': transaction.amount,
      'description': transaction.description,
      'type': transaction.type,
      'date': firestore_db.Timestamp.fromMicrosecondsSinceEpoch(transaction.date.microsecondsSinceEpoch),
      'categoryId': transaction.categoryId, // categoryId juga String
      'userId': transaction.userId,
    });
    // Hapus panggilan ke method Local jika tidak digunakan
    // await updateTransactionLocal(transaction);
  }

  Future<void> deleteTransaction(String id) async { // Parameter harus String
    await firestore_db.FirebaseFirestore.instance.collection('transactions').doc(id).delete();
    // Hapus panggilan ke method Local jika tidak digunakan
    // await deleteTransactionLocal(id);
  }
}