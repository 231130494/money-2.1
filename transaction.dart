import 'package:money/model/category.dart';

class Transaction {
  String? id; // HARUS String?
  double amount;
  String? description;
  String type;
  DateTime date;
  String? categoryId; // HARUS String?
  Category? category;
  String? userId;

  Transaction({
    this.id,
    required this.amount,
    this.description,
    required this.type,
    required this.date,
    this.categoryId,
    this.category,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'type': type,
      'date': date.millisecondsSinceEpoch,
      'categoryId': categoryId,
      'userId': userId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String?, // HARUS di-cast sebagai String?
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String?,
      type: map['type'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      categoryId: map['categoryId'] as String?, // HARUS di-cast sebagai String?
      userId: map['userId'] as String?,
    );
  }
}