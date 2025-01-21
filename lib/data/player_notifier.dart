import 'package:cognitiveroulletegame/data/colors_game_dao.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cognitiveroulletegame/data/player_dao.dart';
import 'package:cognitiveroulletegame/data/player_service.dart';
import 'package:cognitiveroulletegame/models/player_data.dart';
import 'package:cognitiveroulletegame/services/sync_service.dart';

class PlayerNotifier extends ChangeNotifier {
  final PlayerDao _playerDao = PlayerDao();
  final ColorsGameDao _colorsGameDao = ColorsGameDao();
  final PlayerService _playerService = PlayerService();
  final SyncService _syncService = SyncService();
  List<PlayerData> _players = [];
  PlayerData? _selectedProfile;

  PlayerData? get player => _selectedProfile;

  List<PlayerData> get players => _players;

  Future<void> init() async {
    _players = await _playerDao.getAllPlayers();
    notifyListeners();
  }

  void selectProfile(PlayerData profile) {
    _selectedProfile = profile;
    notifyListeners(); // Notifica a los widgets que el estado ha cambiado
  }

  Future<PlayerData> getPlayerByName(String name) async {
    return await _playerDao.getPlayerByName(name);
  }

  Future<PlayerData> getPlayerByUID(String uid) async {
    return _players.where((item) => item.uid == uid).first;
  }

  // get playerProgresss list
  List<PlayerData> getPlayer() {
    return _players;
  }

  Future<void> addPlayer(PlayerData player) async {
    String id = await _playerService.addData(player);
    player.uid = id;
    await _playerDao.insert(player);
    player.synced = 1;
    await _playerService.updateData(player);
    await _playerDao.updatePlayer(player);
    _players = await _playerDao.getAllPlayers();
    notifyListeners();
  }

  Future<void> updatePlayer(PlayerData player) async {
    player.synced = 0;
    await _playerDao.updatePlayer(player);
    player.synced = 1;
    await _playerService.updateData(player);
    await _playerDao.updatePlayer(player);
    _players = await _playerDao.getAllPlayers();
    notifyListeners();
  }

  Future<void> deletePlayer(PlayerData player) async {
    player.synced = 0;
    await _playerDao.deletePlayer(player);
    player.synced = 1;
    await _playerService.deleteData(player);
    _players = await _playerDao.getAllPlayers();
    await _colorsGameDao.deleteColorsGameByPlayerID(player.uid!);
    notifyListeners();
  }

  // get player list
  List<PlayerData> getAllPlayersList() {
    return _players;
  }

  void sync() async {
    await _syncService.syncPlayerData();
    notifyListeners();
  }

  void clearData() async {
    await _playerDao.clearData();

    notifyListeners();
  }
}
