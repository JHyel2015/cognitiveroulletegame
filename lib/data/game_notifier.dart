import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cognitiveroulletegame/data/game_dao.dart';
import 'package:cognitiveroulletegame/data/game_service.dart';
import 'package:cognitiveroulletegame/models/game.dart';
import 'package:cognitiveroulletegame/services/sync_service.dart';

class GameNotifier extends ChangeNotifier {
  final GameDao _gameDao = GameDao();
  final GameService _gameService = GameService();
  final SyncService _syncService = SyncService();
  List<Game> _games = [];

  List<Game> get games => _games;

  Future<void> init() async {
    _games = await _gameDao.getAllGames();
    notifyListeners();
  }

  Future<Game?> getGameById(int id) async {
    return await _gameDao.getGameByID(id);
  }

  Future<void> addGame(Game game) async {
    int id = await _gameDao.insert(game);
    game.id = id;
    game.synced = 1;
    await _gameService.addData(game);
    await _gameDao.updateGame(game);
    _games = await _gameDao.getAllGames();
    notifyListeners();
  }

  Future<void> updateGame(Game game) async {
    game.synced = 0;
    await _gameDao.updateGame(game);
    game.synced = 1;
    await _gameService.updateData(game);
    await _gameDao.updateGame(game);
    _games = await _gameDao.getAllGames();
    notifyListeners();
  }

  // get games list
  List<Game> getAllGamesList() {
    return _games;
  }

  // delete game
  void deleteGameItem(Game game) async {
    await _gameDao.deleteGame(game.id!);
    await _gameService.deleteData(game);
    _games = await _gameDao.getAllGames();
    notifyListeners();
  }

  void clearData() async {
    await _gameDao.clearData();
    await _gameService.clearData();

    notifyListeners();
  }

  void sync() async {
    await _syncService.syncGameData();
    notifyListeners();
  }
}
