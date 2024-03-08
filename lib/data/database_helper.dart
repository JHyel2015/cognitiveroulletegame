import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static const _databaseName = 'cognitiveroulletegame.db';
  static const _databaseVersion = 1;

  DatabaseHelper._internal();

  static DatabaseHelper get instance =>
      _databaseHelper ??= DatabaseHelper._internal();
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      _databaseName,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        displayName TEXT,
        name TEXT,
        email TEXT,
        phoneNumber TEXT,
        photoURL TEXT,
        synced INTEGER DEFAULT 0,
        timestamp TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS levels (
        id INTEGER PRIMARY KEY,
        name TEXT,
        description TEXT,
        difficulty INTEGER,
        previousLevelRequirement INTEGER,
        synced INTEGER DEFAULT 0,
        timestamp TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS player_progress (
        id INTEGER PRIMARY KEY,
        userId INTEGER,
        levelId INTEGER,
        score INTEGER,
        status TEXT,
        synced INTEGER DEFAULT 0,
        timestamp TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS games (
        id INTEGER PRIMARY KEY,
        userId INTEGER,
        levelId INTEGER,
        score INTEGER,
        playedTime TEXT,
        playDate TEXT,
        synced INTEGER DEFAULT 0,
        timestamp TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS colors_games (
        gameId INTEGER,
        selectedColor TEXT,
        correctColor TEXT,
        success BLOB,
        synced INTEGER DEFAULT 0,
        timestamp TEXT
      )
    ''');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {}
  }

  Future<void> sendDataToBackend(String table) async {
    // Obtener solo los datos no sincronizados de SQLite
    List<Map<String, dynamic>> unsyncedData = await getUnsyncedData(table);

    // URL del endpoint de tu API backend
    String apiUrl = 'https://tu-api-backend.com/$table';

    // Realizar la solicitud HTTP POST al backend con los datos no sincronizados
    // TODO
    // await http.post(
    //   Uri.parse(apiUrl),
    //   body: {
    //     'data': unsyncedData.toString()
    //   }, // Puedes personalizar cómo envías los datos
    // );

    // Marcar los datos como sincronizados después de enviarlos al backend
    // await markDataAsSynced(table, unsyncedData);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedData(String table) async {
    Database db = await database;
    return await db.query(table, where: 'synced = ?', whereArgs: [0]);
  }

  Future<void> markDataAsSynced(
      String table, List<Map<String, dynamic>> data) async {
    Database db = await database;
    for (var record in data) {
      await db.update(table, {'synced': 1},
          where: 'id = ?', whereArgs: [record['id']]);
    }
  }

  Future<void> clearData(String table) async {
    Database db = await database;
    await db.rawDelete('DELETE FROM ${table}');
    await db.rawUpdate(
        'UPDATE sqlite_sequence SET seq = 1 WHERE name = ?', [table]);
  }

  Future<bool> isFieldExist(String tableName, String fieldName) async {
    bool isExist = false;
    Database db = await database;

    List<Map<String, dynamic>> columns =
        await db.rawQuery("PRAGMA table_info($tableName)");

    for (Map<String, dynamic> column in columns) {
      String currentColumn = column['name'];
      if (currentColumn == fieldName) {
        isExist = true;
        break;
      }
    }

    return isExist;
  }
}
