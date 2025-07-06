import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money/controller/transaction_provider.dart';
import 'package:money/view/add_edit_transaction_screen.dart';
import 'package:money/view/widgets.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddEditTransactionScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          if (transactionProvider.transactions.isEmpty) {
            return const Center(
              child: Text('Belum ada transaksi. Tambahkan yang pertama!'),
            );
          }
          return RefreshIndicator(
            onRefresh: transactionProvider.fetchTransactions,
            child: ListView.builder(
              itemCount: transactionProvider.transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactionProvider.transactions[index];
                return TransactionCard(
                  transaction: transaction,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddEditTransactionScreen(transaction: transaction),
                      ),
                    );
                  },
                  onDelete: () {
                    if (transaction.id != null) {
                      _showDeleteConfirmationDialog(context, transaction.id!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error: ID transaksi tidak ditemukan.')),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddEditTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String transactionId) { // Parameter harus String
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Transaksi?'),
          content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                Provider.of<TransactionProvider>(context, listen: false)
                    .deleteTransaction(transactionId);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaksi berhasil dihapus')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}