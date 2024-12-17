import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  // Membuat instance database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initializeDatabase();
      return _database!;
    }
  }

  // Membuat dan menginisialisasi database
  Future<Database> _initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'stock_management.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE items(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, stock INTEGER)',
        );
      },
    );
  }

// Menambahkan barang baru atau menambah stok jika barang sudah ada
  Future<void> addItem(String name, int stock) async {
    final db = await database;
    var result = await db.query(
      'items',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (result.isNotEmpty) {
      // Jika barang sudah ada, tambahkan stoknya
      var existingItem = result.first;
      int existingStock = existingItem['stock'] as int? ?? 0; // Cast ke int
      int updatedStock = existingStock + stock;
      await db.update(
        'items',
        {'stock': updatedStock},
        where: 'id = ?',
        whereArgs: [existingItem['id']],
      );
    } else {
      // Jika barang baru, tambahkan ke database
      await db.insert(
        'items',
        {'name': name, 'stock': stock},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

// Memperbarui barang yang sudah ada
  Future<void> updateItem(int id, String name, int stock) async {
    final db = await database;
    await db.update(
      'items',
      {'name': name, 'stock': stock},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Mengurangi stok barang
  Future<void> reduceStock(int id, int stock) async {
    final db = await database;
    var result = await db.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      var existingItem = result.first;
      int existingStock = existingItem['stock'] as int? ?? 0; // Cast ke int
      int updatedStock = existingStock - stock;

      // Pastikan stok tidak menjadi negatif
      if (updatedStock < 0) {
        updatedStock = 0; // Atau tampilkan pesan kesalahan jika perlu
      }

      await db.update(
        'items',
        {'stock': updatedStock},
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      throw Exception('Item with id $id not found.');
    }
  }

  // Mengambil semua data barang
  Future<List<Map<String, dynamic>>> getAllItems() async {
    final db = await database;
    return await db.query('items');
  }

  // Menghapus barang berdasarkan id
  Future<void> deleteItem(int id) async {
    final db = await database;
    var result = await db.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      await db.delete(
        'items',
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      throw Exception('Item with id $id not found.');
    }
  }
}
