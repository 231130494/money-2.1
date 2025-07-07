// lib/model/repositories.dart
import 'package:cloud_firestore/cloud_firestore.dart' as firestore_db;
import 'package:money/model/category.dart';
import 'package:money/model/transaction.dart';

class CategoryRepository {
  final firestore_db.CollectionReference _categoriesCollection =
      firestore_db.FirebaseFirestore.instance.collection('categories');

  Future<void> addCategory(Category category) async {
    if (category.id == null) {
      firestore_db.DocumentReference docRef = await _categoriesCollection.add({
        'name': category.name,
        'type': category.type,
        'color': category.color,
        'userId': category.userId,
      });
      category.id = docRef.id;
    } else {
      await _categoriesCollection.doc(category.id!).set({
        'name': category.name,
        'type': category.type,
        'color': category.color,
        'userId': category.userId,
      });
    }
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
      return Category.fromMap({...data, 'id': doc.id}); 
    }).toList();
  }

  Future<void> updateCategory(Category category) async {
    if (category.id == null) {
      throw Exception("Category ID cannot be null for update operation.");
    }
    await _categoriesCollection.doc(category.id!).update({
      'name': category.name,
      'type': category.type,
      'color': category.color,
      'userId': category.userId,
    });
  }

  Future<void> deleteCategory(String id) async {
    await _categoriesCollection.doc(id).delete();
  }

  Future<Category?> getCategoryById(String id) async {
    firestore_db.DocumentSnapshot doc = await _categoriesCollection.doc(id).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return Category.fromMap({...data, 'id': doc.id});
    }
    return null;
  }
}

class TransactionRepository {
  final firestore_db.CollectionReference _transactionsCollection =
      firestore_db.FirebaseFirestore.instance.collection('transactions');
  final CategoryRepository _categoryRepository = CategoryRepository();

  Future<void> addTransaction(Transaction transaction) async {
    if (transaction.id == null) {
      firestore_db.DocumentReference docRef = await _transactionsCollection.add({
        'amount': transaction.amount,
        'description': transaction.description,
        'type': transaction.type,
        'date': firestore_db.Timestamp.fromMicrosecondsSinceEpoch(transaction.date.microsecondsSinceEpoch),
        'categoryId': transaction.categoryId, 
        'userId': transaction.userId,
      });
      transaction.id = docRef.id; 
    } else {
      await _transactionsCollection.doc(transaction.id!).set({ 
        'amount': transaction.amount,
        'description': transaction.description,
        'type': transaction.type,
        'date': firestore_db.Timestamp.fromMicrosecondsSinceEpoch(transaction.date.microsecondsSinceEpoch),
        'categoryId': transaction.categoryId, 
        'userId': transaction.userId,
      });
    }
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
        id: doc.id, 
        amount: (data['amount'] as num).toDouble(),
        description: data['description'] as String?,
        type: data['type'] as String,
        date: (data['date'] as firestore_db.Timestamp).toDate(),
        categoryId: data['categoryId'] as String?, 
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
    await _transactionsCollection.doc(transaction.id!).update({ 
      'description': transaction.description,
      'type': transaction.type,
      'date': firestore_db.Timestamp.fromMicrosecondsSinceEpoch(transaction.date.microsecondsSinceEpoch),
      'categoryId': transaction.categoryId, 
      'userId': transaction.userId,
    });
  }

  Future<void> deleteTransaction(String id) async {
    await firestore_db.FirebaseFirestore.instance.collection('transactions').doc(id).delete();
  }
}
