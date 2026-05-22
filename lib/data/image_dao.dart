import 'package:sqflite/sqflite.dart';
import 'package:cognitiveroulletegame/data/database_helper.dart';
import 'package:cognitiveroulletegame/models/saved_image.dart';

class ImageDao {
  static const _table = 'images';
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(SavedImage image) async {
    Database db = await dbHelper.database;
    return await db.insert(
      _table,
      image.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SavedImage>> getAllImages() async {
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> data = await db.query(_table);
    return data.map((e) => SavedImage.fromJson(e)).toList();
  }

  Future<SavedImage?> getImageByName(String name) async {
    Database db = await dbHelper.database;
    try {
      List<Map<String, dynamic>> data = await db.query(
        _table,
        where: 'name = ?',
        whereArgs: [name],
      );
      if (data.isNotEmpty) {
        return SavedImage.fromJson(data.first);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<int> updateImage(SavedImage image) async {
    Database db = await dbHelper.database;
    return await db.update(
      _table,
      image.toJson(),
      where: 'name = ?',
      whereArgs: [image.name],
    );
  }

  Future<int> deleteImage(String name) async {
    Database db = await dbHelper.database;
    return await db.delete(
      _table,
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<void> clearData() async {
    await dbHelper.clearData(_table);
  }
}
