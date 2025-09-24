import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDbService {
  static const String _dbName = 'smart_crop.db';
  static const int _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS detections_cache (
        id TEXT PRIMARY KEY,
        disease TEXT,
        confidence REAL,
        imagePath TEXT,
        createdAt INTEGER
      );
    ''');
  }
}

