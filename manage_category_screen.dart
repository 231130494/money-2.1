// lib/view/manage_category_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:money/model/category.dart';
import 'package:money/controller/category_provider.dart';
import 'package:money/auth/auth_provider.dart';

class ManageCategoryScreen extends StatefulWidget {
  final Category? category;

  const ManageCategoryScreen({super.key, this.category});

  @override
  State<ManageCategoryScreen> createState() => _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends State<ManageCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _type;
  late Color _pickedColor;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    _currentUserId = authProvider.user?.uid;

    if (widget.category != null) {
      _name = widget.category!.name;
      _type = widget.category!.type;
      _pickedColor = widget.category!.flutterColor;
    } else {
      _name = '';
      _type = 'expense';
      _pickedColor = Colors.blue;
    }
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User ID tidak ditemukan.')),
        );
        return;
      }

      final newCategory = Category(
        id: widget.category?.id, 
        name: _name,
        type: _type,
        color: _pickedColor.value,
        userId: _currentUserId,
      );

      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

      if (widget.category == null) {
        categoryProvider.addCategory(newCategory);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil ditambahkan')),
        );
      } else {
        categoryProvider.updateCategory(newCategory);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil diperbarui')),
        );
      }
      Navigator.pop(context);
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Warna Kategori'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _pickedColor,
              onColorChanged: (color) {
                setState(() {
                  _pickedColor = color;
                });
              },
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsv,
              labelTypes: const [],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Selesai'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Tambah Kategori' : 'Edit Kategori'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan nama kategori';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Jenis Kategori',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _type,
                    onChanged: (String? newValue) {
                      setState(() {
                        _type = newValue!;
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
              ListTile(
                title: const Text('Pilih Warna Kategori'),
                trailing: CircleAvatar(
                  backgroundColor: _pickedColor,
                  radius: 15,
                ),
                onTap: _showColorPicker,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveCategory,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.category == null ? 'Tambah Kategori' : 'Perbarui Kategori',
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
