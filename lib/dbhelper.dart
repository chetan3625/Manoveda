import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'journal_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE entries(id INTEGER PRIMARY KEY, content TEXT, timestamp TEXT)",
        );
      },
    );
  }

  Future<void> insertEntry(Map<String, dynamic> entry) async {
    final db = await database;
    await db.insert('entries', entry, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getEntries() async {
    final db = await database;
    return await db.query('entries', orderBy: 'timestamp DESC');
  }
}