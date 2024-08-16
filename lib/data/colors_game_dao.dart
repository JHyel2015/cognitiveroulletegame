import 'package:sqflite/sqflite.dart';
import 'package:cognitiveroulletegame/data/database_helper.dart';
import 'package:cognitiveroulletegame/models/colors_game.dart';

class ColorsGameDao {
  static const _table = 'colors_games';
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(ColorsGame colorsGame) async {
    Database db = await dbHelper.database;
    return await db.insert(_table, colorsGame.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ColorsGame>> getAllColorsGames() async {
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> data = await db.query(_table);
    return data.map((e) => ColorsGame.fromJson(e)).toList();
  }

  Future<ColorsGame?> getColorsGameByID(String gameId) async {
    Database db = await dbHelper.database;
    try {
      List<Map<String, dynamic>> data = await db.query(
        _table,
        where: 'gameId = ?',
        whereArgs: [gameId],
      );
      if (data.isNotEmpty) {
        return ColorsGame.fromJson(data.first);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<int> updateColorsGame(ColorsGame colorsGame) async {
    Database db = await dbHelper.database;
    return await db.update(
      _table,
      colorsGame.toJson(),
      where: 'id = ?',
      whereArgs: [colorsGame.id],
    );
  }

  Future<int> deleteColorsGame(String id) async {
    Database db = await dbHelper.database;
    return await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearData() async {
    await dbHelper.clearData(_table);
  }
}
