import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'lingualearn.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // pending actions jo internet aane pe Firestore sync karni hain
        await db.execute('''
          CREATE TABLE pending_sync(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action_type TEXT,
            data TEXT,
            created_at TEXT
          )
        ''');

        // local progress cache (turant dikhane ke liye, chahe Firestore sync ho ya na ho)
        await db.execute('''
          CREATE TABLE local_progress(
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
    );
  }

  Future<void> addPendingSync(String actionType, String data) async {
    final db = await database;
    await db.insert('pending_sync', {
      'action_type': actionType,
      'data': data,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncs() async {
    final db = await database;
    return await db.query('pending_sync', orderBy: 'created_at ASC');
  }

  Future<void> removePendingSync(int id) async {
    final db = await database;
    await db.delete('pending_sync', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setLocalValue(String key, String value) async {
    final db = await database;
    await db.insert(
      'local_progress',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getLocalValue(String key) async {
    final db = await database;
    final result = await db.query('local_progress', where: 'key = ?', whereArgs: [key]);
    if (result.isEmpty) return null;
    return result.first['value'] as String;
  }
}