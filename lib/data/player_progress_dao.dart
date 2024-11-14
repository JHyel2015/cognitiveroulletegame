import 'package:sqflite/sqflite.dart';
import 'package:cognitiveroulletegame/data/database_helper.dart';
import 'package:cognitiveroulletegame/models/player_progress.dart';

class PlayerProgressDao {
  static const _table = 'player_progress';
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(PlayerProgress playerProgress) async {
    Database db = await dbHelper.database;
    return await db.insert(_table, playerProgress.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PlayerProgress>> getAllPlayerProgresss() async {
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> data = await db.query(_table);
    return data.map((e) => PlayerProgress.fromJson(e)).toList();
  }

  Future<PlayerProgress?> getPlayerProgressByID(String id) async {
    Database db = await dbHelper.database;
    try {
      List<Map<String, dynamic>> data = await db.query(
        _table,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (data.isNotEmpty) {
        return PlayerProgress.fromJson(data.first);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<int> updatePlayerProgress(PlayerProgress playerProgress) async {
    Database db = await dbHelper.database;
    return await db.update(
      _table,
      playerProgress.toJson(),
      where: 'id = ?',
      whereArgs: [playerProgress.id],
    );
  }

  Future<int> deletePlayerProgress(String id) async {
    Database db = await dbHelper.database;
    return await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePlayerProgressByPlayerID(String playerUID) async {
    Database db = await dbHelper.database;
    return await db.delete(
      _table,
      where: 'userId = ?',
      whereArgs: [playerUID],
    );
  }

  Future<void> clearData() async {
    await dbHelper.clearData(_table);
  }
}
