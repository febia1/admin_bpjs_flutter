import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/peserta_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('peserta_bpjs.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Cek OS Windows/Linux
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE peserta (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nik TEXT NOT NULL,
      nama TEXT NOT NULL,
      alamat TEXT NOT NULL,
      status TEXT NOT NULL
    )
    ''');
  }

  // --- FUNGSI YANG HILANG SEBELUMNYA ---

  // Fungsi Create (Simpan Data)
  Future<int> create(Peserta peserta) async {
    final db = await instance.database;
    return await db.insert('peserta', peserta.toMap());
  }

  // Fungsi Read (Ambil Semua Data)
  Future<List<Peserta>> getAllPeserta({String? keyword}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> maps;
    
    if (keyword != null && keyword.isNotEmpty) {
      maps = await db.query(
        'peserta',
        where: 'nik LIKE ? OR nama LIKE ?',
        whereArgs: ['%$keyword%', '%$keyword%'],
        orderBy: 'nama ASC',
      );
    } else {
      maps = await db.query('peserta', orderBy: 'id DESC');
    }
    return maps.map((json) => Peserta.fromMap(json)).toList();
  }

  // Fungsi Update (Edit Data)
  Future<int> update(Peserta peserta) async {
    final db = await instance.database;
    return db.update(
      'peserta',
      peserta.toMap(),
      where: 'id = ?',
      whereArgs: [peserta.id],
    );
  }

  // Fungsi Delete (Hapus Data)
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'peserta',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}