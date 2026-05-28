import 'package:sqflite/sqflite.dart';
import 'package:cognitiveroulletegame/data/database_helper.dart';
import 'package:cognitiveroulletegame/models/player_data.dart';

class PlayerDao {
  static const _table = 'players';
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(PlayerData player) async {
    Database db = await dbHelper.database;
    return await db.insert(_table, player.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PlayerData>> getAllPlayers() async {
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> data = await db.query(_table);
    return data.map((e) => PlayerData.fromJson(e)).toList();
  }

  Future<PlayerData?> getPlayerByUID(String uid) async {
    Database db = await dbHelper.database;
    try {
      List<Map<String, dynamic>> data = await db.query(
        _table,
        where: 'uid = ?',
        whereArgs: [uid],
      );
      if (data.isNotEmpty) {
        return PlayerData.fromJson(data.first);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<PlayerData> getPlayerByName(String name) async {
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> data = await db.query(
      _table,
      where: 'name = ?',
      whereArgs: [name],
    );
    return PlayerData.fromJson(data.first);
  }

  Future<int> updatePlayer(PlayerData player) async {
    Database db = await dbHelper.database;
    return await db.update(
      _table,
      player.toJson(),
      where: 'uid = ?',
      whereArgs: [player.uid],
    );
  }

  Future<int> deletePlayer(PlayerData player) async {
    Database db = await dbHelper.database;
    return await db.delete(
      _table,
      where: 'uid = ?',
      whereArgs: [player.uid],
    );
  }

  Future<void> clearData() async {
    await dbHelper.clearData(_table);
  }
}
