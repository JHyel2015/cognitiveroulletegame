import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cognitiveroulletegame/data/user_dao.dart';
import 'package:cognitiveroulletegame/data/user_service.dart';
import 'package:cognitiveroulletegame/models/user_data.dart';

class UserNotifier extends ChangeNotifier {
  final UserDao _userDao = UserDao();
  final UserService _userService = UserService();
  final UserPreferences _userPreferences = UserPreferences();
  final List<UserData> _users = [];

  UserData get user => _users.first;

  Future<void> init() async {
    if (_users.isNotEmpty) {
      _users[0] = await _userDao.getUserByEmail(user.email);
    }
    notifyListeners();
  }

  Future<UserData> getUserByEmail(String email) async {
    return await _userDao.getUserByEmail(email);
  }

  Future<void> addUser(UserData user) async {
    await _userDao.insert(user);
    user.uid = _userPreferences.storedUID;
    user.synced = 1;
    await _userService.addData(user);
    await _userDao.updateUser(user);
    _users.add(await _userDao.getUserByEmail(user.email));
    notifyListeners();
  }

  Future<void> updateUser(UserData user) async {
    user.synced = 0;
    await _userDao.updateUser(user);
    user.synced = 1;
    await _userService.updateData(user);
    await _userDao.updateUser(user);
    _users[0] = await _userDao.getUserByEmail(user.email);
    notifyListeners();
  }

  // get user list
  List<UserData> getAllUsersList() {
    return _users;
  }

  // Future<void> sync() async {
  //   await _syncService.syncUserData();
  //   notifyListeners();
  // }

  Future<void> clearData() async {
    await _userDao.clearData();

    notifyListeners();
  }
}
