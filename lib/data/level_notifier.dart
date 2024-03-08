import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cognitiveroulletegame/data/level_dao.dart';
import 'package:cognitiveroulletegame/data/level_service.dart';
import 'package:cognitiveroulletegame/models/level.dart';
import 'package:cognitiveroulletegame/services/sync_service.dart';

class LevelNotifier extends ChangeNotifier {
  final LevelDao _levelDao = LevelDao();
  final LevelService _levelService = LevelService();
  final SyncService _syncService = SyncService();
  List<Level> _levels = [];

  List<Level> get levels => _levels;

  Future<void> init() async {
    _levels = await _levelDao.getAllLevels();
    notifyListeners();
  }

  Future<Level?> getLevelById(int id) async {
    return await _levelDao.getLevelByID(id);
  }

  Future<void> addLevel(Level level) async {
    int id = await _levelDao.insert(level);
    level.id = id;
    level.synced = 1;
    await _levelService.addData(level);
    await _levelDao.updateLevel(level);
    _levels = await _levelDao.getAllLevels();
    notifyListeners();
  }

  Future<void> updateLevel(Level level) async {
    level.synced = 0;
    await _levelDao.updateLevel(level);
    level.synced = 1;
    await _levelService.updateData(level);
    await _levelDao.updateLevel(level);
    _levels = await _levelDao.getAllLevels();
    notifyListeners();
  }

  // get levels list
  List<Level> getAllLevelsList() {
    return _levels;
  }

  void sync() async {
    await _syncService.syncLevelData();
    notifyListeners();
  }
}
