// lib/view/add_edit_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:money/model/category.dart';
import 'package:money/model/transaction.dart';
import 'package:money/controller/category_provider.dart';
import 'package:money/controller/transaction_provider.dart';
import 'package:money/auth/auth_provider.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late double _amount;
  String? _description;
  late String _type;
  late DateTime _selectedDate;
  Category? _selectedCategory;
  String? _initialCategoryId; // HARUS String?
  String? _currentUserId;

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    _currentUserId = authProvider.user?.uid;

    if (widget.transaction != null) {
      _amount = widget.transaction!.amount;
      _description = widget.transaction!.description;
      _type = widget.transaction!.type;
      _selectedDate = widget.transaction!.date;
      _initialCategoryId = widget.transaction!.categoryId;
    } else {
      _amount = 0.0;
      _description = '';
      _type = 'expense';
      _selectedDate = DateTime.now();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      _updateSelectedCategoryBasedOnType(categoryProvider);
    });
  }

  void _updateSelectedCategoryBasedOnType(CategoryProvider categoryProvider) {
    final List<Category> availableCategories = _type == 'income'
        ? categoryProvider.incomeCategories
        : categoryProvider.expenseCategories;

    Category? newSelectedCategory;

    if (_initialCategoryId != null) {
      newSelectedCategory = availableCategories.firstWhereOrNull(
          (cat) => cat.id == _initialCategoryId);
      _initialCategoryId = null;
    }

    if (newSelectedCategory == null && availableCategories.isNotEmpty) {
      newSelectedCategory = availableCategories.first;
    }

    if (_selectedCategory?.id != newSelectedCategory?.id) {
      setState(() {
        _selectedCategory = newSelectedCategory;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih kategori')),
        );
        return;
      }

      if (_currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User ID tidak ditemukan.')),
        );
        return;
      }

      final newTransaction = Transaction(
        id: widget.transaction?.id,
        amount: _amount,
        description: _description,
        type: _type,
        date: _selectedDate,
        categoryId: _selectedCategory!.id, // categoryId sekarang String
        category: _selectedCategory,
        userId: _currentUserId,
      );

      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

      if (widget.transaction == null) {
        transactionProvider.addTransaction(newTransaction);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil ditambahkan')),
        );
      } else {
        transactionProvider.updateTransaction(newTransaction);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil diperbarui')),
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final List<Category> availableCategories = _type == 'income'
        ? categoryProvider.incomeCategories
        : categoryProvider.expenseCategories;

    if (_selectedCategory != null &&
        !availableCategories.any((cat) => cat.id == _selectedCategory!.id)) {
      _selectedCategory = null;
    }

    if (_selectedCategory == null && availableCategories.isNotEmpty) {
      _selectedCategory = availableCategories.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Tambah Transaksi' : 'Edit Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _amount == 0.0 ? '' : _amount.toString(),
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jumlah';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Jumlah harus lebih besar dari 0';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) {
                  _description = value;
                },
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Jenis Transaksi',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _type,
                    onChanged: (String? newValue) {
                      setState(() {
                        _type = newValue!;
                        _selectedCategory = null;
                        _updateSelectedCategoryBasedOnType(categoryProvider);
                      });
                    },
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'expense',
                        child: Text('Pengeluaran'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'income',
                        child: Text('Pemasukan'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Category>(
                    value: _selectedCategory,
                    hint: const Text('Pilih Kategori'),
                    onChanged: (Category? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    items: availableCategories.map((Category category) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: category.flutterColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              if (availableCategories.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Tidak ada kategori "${_type == 'income' ? 'pemasukan' : 'pengeluaran'}" yang tersedia. Harap tambahkan di menu kategori.',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Tanggal: ${DateFormat('dd MMMM HH:mm').format(_selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.transaction == null ? 'Tambah Transaksi' : 'Perbarui Transaksi',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension ini HARUS berada di luar kelas AddEditTransactionScreen atau _AddEditTransactionScreenState
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}