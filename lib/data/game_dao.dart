import 'package:sqflite/sqflite.dart';
import 'package:cognitiveroulletegame/data/database_helper.dart';
import 'package:cognitiveroulletegame/models/game.dart';

class GameDao {
  static const _table = 'games';
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Game game) async {
    Database db = await dbHelper.database;
    return await db.insert(_table, game.toJson());
  }

  Future<List<Game>> getAllGames() async {
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> data = await db.query(_table);
    return data.map((e) => Game.fromJson(e)).toList();
  }

  Future<Game?> getGameByID(int id) async {
    Database db = await dbHelper.database;
    try {
      List<Map<String, dynamic>> data = await db.query(
        _table,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (data.isNotEmpty) {
        return Game.fromJson(data.first);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<int> updateGame(Game game) async {
    Database db = await dbHelper.database;
    return await db.update(
      _table,
      game.toJson(),
      where: 'id = ?',
      whereArgs: [game.id],
    );
  }

  Future<int> deleteGame(int id) async {
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
