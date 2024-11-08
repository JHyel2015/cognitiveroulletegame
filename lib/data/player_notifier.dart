import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cognitiveroulletegame/data/player_dao.dart';
import 'package:cognitiveroulletegame/data/player_service.dart';
import 'package:cognitiveroulletegame/models/player_data.dart';
import 'package:cognitiveroulletegame/services/sync_service.dart';

class PlayerNotifier extends ChangeNotifier {
  final PlayerDao _playerDao = PlayerDao();
  final PlayerService _playerService = PlayerService();
  final SyncService _syncService = SyncService();
  final UserPreferences _userPreferences = UserPreferences();
  final List<PlayerData> _players = [];

  PlayerData get player => _players.first;

  Future<void> init() async {
    if (_players.isNotEmpty) {
      _players[0] = await _playerDao.getPlayerByUID(player.uid!);
    }
    notifyListeners();
  }

  Future<PlayerData> getPlayerByName(String name) async {
    return await _playerDao.getPlayerByName(name);
  }

  Future<void> addPlayer(PlayerData player) async {
    await _playerDao.insert(player);
    player.uid = _userPreferences.storedUID;
    player.synced = 1;
    await _playerService.addData(player);
    await _playerDao.updatePlayer(player);
    _players.add(await _playerDao.getPlayerByName(player.name!));
    notifyListeners();
  }

  Future<void> updatePlayer(PlayerData player) async {
    player.synced = 0;
    await _playerDao.updatePlayer(player);
    player.synced = 1;
    await _playerService.updateData(player);
    await _playerDao.updatePlayer(player);
    _players[0] = await _playerDao.getPlayerByName(player.name!);
    notifyListeners();
  }

  // get player list
  List<PlayerData> getAllTransactionList() {
    return _players;
  }

  // void sync() async {
  //   await _syncService.syncPlayerData();
  //   notifyListeners();
  // }

  void clearData() async {
    await _playerDao.clearData();

    notifyListeners();
  }
}
