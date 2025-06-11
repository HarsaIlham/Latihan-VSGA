import 'package:latihan_vsga/models/senjata.dart';
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
    String path = join(await getDatabasesPath(), 'Senjatas.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE Senjatas(id INTEGER PRIMARY KEY AUTOINCREMENT, nama TEXT, jumlah INTEGER)');
  }

  static Future<int> insertSenjata(Senjata senjata) async {
    final db = await database;
    return await db.insert('Senjatas', senjata.toMap());
  }

  static Future<List<Senjata>> getSenjatas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Senjatas',
      orderBy: 'nama ASC',
    );
    return List.generate(maps.length, (i) => Senjata.fromMap(maps[i]));
  }

  static Future<int> updateSenjata(Senjata Senjata) async {
    final db = await database;
    return await db.update(
      'Senjatas',
      Senjata.toMap(),
      where: 'id = ?',
      whereArgs: [Senjata.id],
    );
  }

  static Future<int> deleteSenjata(int id) async {
    final db = await database;
    return await db.delete('Senjatas', where: 'id = ?', whereArgs: [id]);
  }
}
