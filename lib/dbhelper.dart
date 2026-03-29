import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;
  static const _databaseName = 'journal_database.db';
  static const _databaseVersion = 3;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS entries('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'content TEXT, '
      'timestamp TEXT'
      ')',
    );

    await db.execute(
      'CREATE TABLE IF NOT EXISTS moods('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'date INTEGER, '
      'mood INTEGER, '
      'note TEXT'
      ')',
    );

    await db.execute(
      'CREATE TABLE IF NOT EXISTS schedules('
      'task_key TEXT PRIMARY KEY, '
      'title TEXT NOT NULL, '
      'hour INTEGER NOT NULL, '
      'minute INTEGER NOT NULL, '
      'updated_at INTEGER NOT NULL'
      ')',
    );

    await db.execute(
      'CREATE TABLE IF NOT EXISTS wellness_events('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'task_key TEXT NOT NULL, '
      'title TEXT NOT NULL, '
      'duration_minutes INTEGER NOT NULL DEFAULT 0, '
      'score REAL NOT NULL DEFAULT 0, '
      'details TEXT, '
      'created_at INTEGER NOT NULL'
      ')',
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
