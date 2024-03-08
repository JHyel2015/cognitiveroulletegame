import 'package:sqflite/sqflite.dart';
import 'package:cognitiveroulletegame/data/database_helper.dart';
import 'package:cognitiveroulletegame/models/level.dart';

class LevelDao {
  static const _table = 'levels';
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Level level) async {
    Database db = await dbHelper.database;
    return await db.insert(_table, level.toJson());
  }

  Future<List<Level>> getAllLevels() async {
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> data = await db.query(_table);
    return data.map((e) => Level.fromJson(e)).toList();
  }

  Future<Level> getLevelByID(int id) async {
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> data = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
    return Level.fromJson(data.first);
  }

  Future<int> updateLevel(Level level) async {
    Database db = await dbHelper.database;
    return await db.update(
      _table,
      level.toJson(),
      where: 'id = ?',
      whereArgs: [level.id],
    );
  }
}
