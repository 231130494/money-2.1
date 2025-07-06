import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/model/category.dart';
import 'package:money/model/transaction.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryChip({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(category.name),
        backgroundColor: category.flutterColor.withOpacity(0.2),
        labelStyle: TextStyle(color: category.flutterColor),
        side: BorderSide(color: category.flutterColor, width: 1.0),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    final dateFormat = DateFormat('dd MMM, HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: transaction.type == 'income' ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  transaction.type == 'income' ? Icons.add_circle : Icons.remove_circle,
                  color: transaction.type == 'income' ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description ?? 'Tanpa Deskripsi',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.category?.name ?? 'Tanpa Kategori',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(transaction.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(transaction.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: transaction.type == 'income' ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.grey[400]),
                    onPressed: onDelete,
                    tooltip: 'Hapus Transaksi',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}