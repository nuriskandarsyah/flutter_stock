import 'package:flutter/material.dart';
import 'db/db_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StockPage(),
    );
  }
}

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  _loadItems() async {
    final items = await _databaseHelper.getAllItems();
    setState(() {
      _items = items;
    });
  }

  _showAddItemDialog() {
    final _nameController = TextEditingController();
    final _stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Barang'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Barang'),
              ),
              TextField(
                controller: _stockController,
                decoration: InputDecoration(labelText: 'Stok Barang'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                String name = _nameController.text;
                int stock = int.tryParse(_stockController.text) ?? 0;

                if (name.isNotEmpty && stock > 0) {
                  await _databaseHelper.addItem(name, stock);
                  _loadItems();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  _showEditItemDialog(int id, String name, int stock) {
    final _nameController = TextEditingController(text: name);
    final _stockController = TextEditingController(text: stock.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Barang'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Barang'),
              ),
              TextField(
                controller: _stockController,
                decoration: InputDecoration(labelText: 'Stok Barang'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                String name = _nameController.text;
                int stock = int.tryParse(_stockController.text) ?? 0;

                if (name.isNotEmpty && stock > 0) {
                  await _databaseHelper.updateItem(id, name, stock);
                  _loadItems();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  _showDeleteItemDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Barang'),
          content: Text('Apakah Anda yakin ingin menghapus barang ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await _databaseHelper.deleteItem(id);
                _loadItems();
                Navigator.of(context).pop();
              },
              child: Text('Hapus'),
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
        title: Text('Manajemen Stok Barang'),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          var item = _items[index];
          return ListTile(
            title: Text(item['name']),
            subtitle: Text('Stok: ${item['stock']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditItemDialog(
                        item['id'], item['name'], item['stock']);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteItemDialog(item['id']);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
