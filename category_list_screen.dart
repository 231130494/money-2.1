import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money/model/category.dart';
import 'package:money/controller/category_provider.dart';
import 'package:money/view/manage_category_screen.dart';
import 'package:money/view/widgets.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ManageCategoryScreen()),
              );
              categoryProvider.fetchCategories();
            },
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.categories.isEmpty) {
            return const Center(
              child: Text('Belum ada kategori. Tambahkan yang pertama!'),
            );
          }
          return RefreshIndicator(
            onRefresh: categoryProvider.fetchCategories,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildCategorySection(
                  context,
                  'Kategori Pemasukan',
                  categoryProvider.incomeCategories,
                  categoryProvider,
                ),
                const SizedBox(height: 24),
                _buildCategorySection(
                  context,
                  'Kategori Pengeluaran',
                  categoryProvider.expenseCategories,
                  categoryProvider,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ManageCategoryScreen()),
          );
          categoryProvider.fetchCategories();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String title,
    List<Category> categories,
    CategoryProvider categoryProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: categories.map((category) {
            return GestureDetector(
              onLongPress: () => _showDeleteEditCategoryDialog(context, category, categoryProvider),
              child: CategoryChip(category: category),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showDeleteEditCategoryDialog(
      BuildContext context, Category category, CategoryProvider categoryProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(category.name),
          content: const Text('Pilih tindakan untuk kategori ini:'),
          actions: <Widget>[
            TextButton(
              child: const Text('Edit'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageCategoryScreen(category: category),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (category.id != null) {
                  _confirmDeleteCategory(context, category.id!, categoryProvider);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: ID kategori tidak ditemukan.')),
                  );
                }
              },
            ),
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteCategory(
      BuildContext context, String categoryId, CategoryProvider categoryProvider) { // Parameter harus String
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus kategori ini?'),
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
                categoryProvider.deleteCategory(categoryId).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kategori berhasil dihapus')),
                  );
                  Navigator.of(dialogContext).pop();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus kategori: $error')),
                  );
                  Navigator.of(dialogContext).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }
}