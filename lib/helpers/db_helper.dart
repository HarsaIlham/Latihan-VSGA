import 'package:latihan_vsga/models/roti.dart';
import 'package:latihan_vsga/models/transaksi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'Rotis.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE Rotis(id INTEGER PRIMARY KEY AUTOINCREMENT, nama TEXT, harga INTEGER, jumlah INTEGER)',
    );
    await db.execute(
      '''CREATE TABLE Transaksi(
      id INTEGER PRIMARY KEY AUTOINCREMENT, produk_id INTEGER, jumlah INTEGER, nama_pembeli TEXT, lokasi_pembeli TEXT, 
      FOREIGN KEY (produk_id) REFERENCES Rotis (id))'''
      );
  }

  static Future<int> insertRoti(Roti roti) async {
    final db = await database;
    return await db.insert('Rotis', roti.toMap());
  }

  static Future<List<Roti>> getRotis() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Rotis',
      orderBy: 'nama ASC',
    );
    return List.generate(maps.length, (i) => Roti.fromMap(maps[i]));
  }

  static Future<int> updateRoti(Roti roti) async {
    final db = await database;
    return await db.update(
      'Rotis',
      roti.toMap(),
      where: 'id = ?',
      whereArgs: [roti.id],
    );
  }

  static Future<int> deleteRoti(int id) async {
    final db = await database;
    return await db.delete('Rotis', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> insertTransaksi(Transaksi transaksi) async {
    final db = await database;
    return await db.insert('Transaksi', transaksi.toMap());
  }

  static Future<List<Map <String, dynamic>>> getTransaksis() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.id as transaksi_id,
        t.produk_id,
        t.jumlah,
        t.nama_pembeli,
        t.lokasi_pembeli,
        r.nama,
        r.harga,
        (t.jumlah * r.harga) as total_harga
      FROM Transaksi t
      JOIN Rotis r ON t.produk_id = r.id
      ORDER BY t.id DESC
    ''');
    return maps;
  }

  static Future<int> deleteTransaksi(int transaksiId) async {
    final db = await database;
    return await db.delete('Transaksi', where: 'id = ?', whereArgs: [transaksiId]);
  }
}
