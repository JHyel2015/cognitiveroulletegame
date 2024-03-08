import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cognitiveroulletegame/data/colors_game_dao.dart';
import 'package:cognitiveroulletegame/data/colors_game_service.dart';
import 'package:cognitiveroulletegame/models/colors_game.dart';
import 'package:cognitiveroulletegame/services/sync_service.dart';

class ColorsGameNotifier extends ChangeNotifier {
  final ColorsGameDao _colorsGameDao = ColorsGameDao();
  final ColorsGameService _colorsGameService = ColorsGameService();
  final SyncService _syncService = SyncService();
  List<ColorsGame> _colorsGames = [];

  List<ColorsGame> get colorsGames => _colorsGames;

  Future<void> init() async {
    _colorsGames = await _colorsGameDao.getAllColorsGames();
    notifyListeners();
  }

  Future<ColorsGame?> getColorsGameById(int id) async {
    return await _colorsGameDao.getColorsGameByID(id);
  }

  Future<void> addColorsGame(ColorsGame colorsGame) async {
    int id = await _colorsGameDao.insert(colorsGame);
    colorsGame.gameId = id;
    colorsGame.synced = 1;
    await _colorsGameService.addData(colorsGame);
    await _colorsGameDao.updateColorsGame(colorsGame);
    _colorsGames = await _colorsGameDao.getAllColorsGames();
    notifyListeners();
  }

  Future<void> updateColorsGame(ColorsGame colorsGame) async {
    colorsGame.synced = 0;
    await _colorsGameDao.updateColorsGame(colorsGame);
    colorsGame.synced = 1;
    await _colorsGameService.updateData(colorsGame);
    await _colorsGameDao.updateColorsGame(colorsGame);
    _colorsGames = await _colorsGameDao.getAllColorsGames();
    notifyListeners();
  }

  // get colorsGames list
  List<ColorsGame> getAllColorsGamesList() {
    return _colorsGames;
  }

  // delete colorsGame
  void deleteColorsGameItem(ColorsGame colorsGame) async {
    await _colorsGameDao.deleteColorsGame(colorsGame.gameId);
    await _colorsGameService.deleteData(colorsGame);
    _colorsGames = await _colorsGameDao.getAllColorsGames();
    notifyListeners();
  }

  void clearData() async {
    await _colorsGameDao.clearData();
    await _colorsGameService.clearData();

    notifyListeners();
  }

  void sync() async {
    await _syncService.syncColorsGameData();
    notifyListeners();
  }
}
