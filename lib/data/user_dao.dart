import 'package:sqflite/sqflite.dart';
import 'package:cognitiveroulletegame/data/database_helper.dart';
import 'package:cognitiveroulletegame/models/user.dart';

class UserDao {
  static const _table = 'users';
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(User user) async {
    Database db = await dbHelper.database;
    return await db.insert(_table, user.toJson());
  }

  Future<User> getUserByEmail(String email) async {
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> data = await db.query(
      _table,
      where: 'email = ?',
      whereArgs: [email],
    );
    return User.fromJson(data.first);
  }

  Future<int> updateUser(User user) async {
    Database db = await dbHelper.database;
    return await db.update(
      _table,
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
