import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cognitiveroulletegame/data/player_progress_dao.dart';
import 'package:cognitiveroulletegame/data/player_progress_service.dart';
import 'package:cognitiveroulletegame/models/player_progress.dart';
import 'package:cognitiveroulletegame/services/sync_service.dart';

class PlayerProgressNotifier extends ChangeNotifier {
  final PlayerProgressDao _playerProgressDao = PlayerProgressDao();
  final PlayerProgressService _playerProgressService = PlayerProgressService();
  final SyncService _syncService = SyncService();
  List<PlayerProgress> _playerProgresss = [];

  List<PlayerProgress> get playerProgresss => _playerProgresss;

  Future<void> init() async {
    _playerProgresss = await _playerProgressDao.getAllPlayerProgresss();
    notifyListeners();
  }

  Future<PlayerProgress?> getPlayerProgressById(String id) async {
    return await _playerProgressDao.getPlayerProgressByID(id);
  }

  Future<String> addPlayerProgress(PlayerProgress playerProgress) async {
    String id = await _playerProgressService.addData(playerProgress);
    playerProgress.id = id;
    await _playerProgressDao.insert(playerProgress);
    playerProgress.synced = 1;
    await _playerProgressDao.updatePlayerProgress(playerProgress);
    _playerProgresss = await _playerProgressDao.getAllPlayerProgresss();
    notifyListeners();
    return playerProgress.id!;
  }

  Future<void> updatePlayerProgress(PlayerProgress playerProgress) async {
    playerProgress.synced = 0;
    await _playerProgressDao.updatePlayerProgress(playerProgress);
    playerProgress.synced = 1;
    await _playerProgressService.updateData(playerProgress);
    await _playerProgressDao.updatePlayerProgress(playerProgress);
    _playerProgresss = await _playerProgressDao.getAllPlayerProgresss();
    notifyListeners();
  }

  // get playerProgresss list
  List<PlayerProgress> getAllPlayerProgresssList() {
    return _playerProgresss;
  }

  // delete playerProgress
  void deletePlayerProgressItem(PlayerProgress playerProgress) async {
    await _playerProgressDao.deletePlayerProgress(playerProgress.id!);
    await _playerProgressService.deleteData(playerProgress);
    _playerProgresss = await _playerProgressDao.getAllPlayerProgresss();
    notifyListeners();
  }

  void clearData() async {
    await _playerProgressDao.clearData();

    notifyListeners();
  }

  void sync() async {
    await _syncService.syncPlayerProgressData();
    notifyListeners();
  }
}
