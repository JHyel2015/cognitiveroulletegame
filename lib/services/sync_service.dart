import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitiveroulletegame/data/level_dao.dart';
import 'package:cognitiveroulletegame/data/level_service.dart';
import 'package:cognitiveroulletegame/data/player_progress_dao.dart';
import 'package:cognitiveroulletegame/data/player_progress_service.dart';
import 'package:cognitiveroulletegame/data/game_dao.dart';
import 'package:cognitiveroulletegame/data/game_service.dart';
import 'package:cognitiveroulletegame/data/colors_game_dao.dart';
import 'package:cognitiveroulletegame/data/colors_game_service.dart';
import 'package:cognitiveroulletegame/data/user_dao.dart';
import 'package:cognitiveroulletegame/data/user_service.dart';
import 'package:cognitiveroulletegame/data/player_dao.dart';
import 'package:cognitiveroulletegame/data/player_service.dart';
import 'package:cognitiveroulletegame/models/level.dart';
import 'package:cognitiveroulletegame/models/player_progress.dart';
import 'package:cognitiveroulletegame/models/game.dart';
import 'package:cognitiveroulletegame/models/colors_game.dart';
import 'package:cognitiveroulletegame/models/user_data.dart';
import 'package:cognitiveroulletegame/models/player_data.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';

class SyncService {
  final UserPreferences userPreferences = UserPreferences();
  final UserDao userDao = UserDao();
  final UserService userService = UserService();
  final LevelDao levelDao = LevelDao();
  final LevelService levelService = LevelService();
  final PlayerProgressDao playerProgressDao = PlayerProgressDao();
  final PlayerProgressService playerProgressService = PlayerProgressService();
  final GameDao gameDao = GameDao();
  final GameService gameService = GameService();
  final ColorsGameDao colorsGameDao = ColorsGameDao();
  final ColorsGameService colorsGameService = ColorsGameService();
  final PlayerDao playerDao = PlayerDao();
  final PlayerService playerService = PlayerService();

  Future<void> syncLevelData() async {
    try {
      // Obtener datos de SQLite
      List<Level> localLevels = await levelDao.getAllLevels();

      localLevels =
          localLevels.where((element) => element.synced == 0).toList();

      // Sincronizar con Firestore
      for (Level level in localLevels) {
        // Verificar si el elemento ya existe en Firestore
        var firestoreItem =
            await levelService.getItemFromFirestore(level.id.toString());

        if (firestoreItem != null) {
          // Actualizar el elemento en Firestore si ya existe y el timestamp es mayor
          if (level.timestamp.compareTo(firestoreItem.timestamp) == 1 &&
              level.timestamp.isAfter(firestoreItem.timestamp)) {
            await levelService.updateData(level);
          }
        } else {
          // Agregar el elemento a Firestore si no existe
          await levelService.addData(level);
        }
      }

      // sync from firestore to sqlite

      // Obtener datos de Firestore
      QuerySnapshot firestoreLevelsSnapshot =
          await levelService.getAllItemsFromFirestore();

      // Sincronizar con SQLite
      for (QueryDocumentSnapshot firestoreDoc in firestoreLevelsSnapshot.docs) {
        var itemId = int.tryParse(firestoreDoc.id);
        var firestoreLevel =
            Level.fromJson(firestoreDoc.data() as Map<String, dynamic>);

        // Verificar si el elemento ya existe en SQLite
        var localLevel = await levelDao.getLevelByID(itemId!);

        localLevel.id = itemId;

        if (localLevel != null) {
          // Actualizar el elemento en SQLite si ya existe
          if (firestoreLevel.timestamp.compareTo(localLevel.timestamp) == 1 &&
              firestoreLevel.timestamp.isAfter(localLevel.timestamp)) {
            await levelDao.updateLevel(firestoreLevel);
          }
        } else {
          // Agregar el elemento a SQLite si no existe
          await levelDao.insert(firestoreLevel);
        }
      }

      // Puedes implementar lógica adicional para manejar eliminaciones o conflictos.
    } catch (e) {
      print('Level Error en la sincronización: $e');
    }
  }

  Future<void> syncPlayerProgressData() async {
    try {
      // Obtener datos de SQLite

      List<PlayerProgress> localPlayerProgress =
          await playerProgressDao.getAllPlayerProgresss();
      localPlayerProgress =
          localPlayerProgress.where((element) => element.synced == 0).toList();

      // Sincronizar con Firestore
      for (PlayerProgress trnPlayerProgress in localPlayerProgress) {
        // Verificar si el elemento ya existe en Firestore
        var firestoreItem = await playerProgressService
            .getItemFromFirestore(trnPlayerProgress.id.toString());

        trnPlayerProgress.userId = userPreferences.storedUID;
        if (firestoreItem != null) {
          // Actualizar el elemento en Firestore si ya existe
          if (trnPlayerProgress.timestamp.compareTo(firestoreItem.timestamp) ==
                  1 &&
              trnPlayerProgress.timestamp.isAfter(firestoreItem.timestamp)) {
            await playerProgressService.updateData(trnPlayerProgress);
          }
        } else {
          // Agregar el elemento a Firestore si no existe
          await playerProgressService.addData(trnPlayerProgress);
        }
      }

      // sync from firestore to sqlite

      // Obtener datos de Firestore
      QuerySnapshot firestorePlayerProgressSnapshot =
          await playerProgressService.getAllItemsFromFirestore();

      // Sincronizar con SQLite
      for (QueryDocumentSnapshot firestoreDoc
          in firestorePlayerProgressSnapshot.docs) {
        var itemId = firestoreDoc.id;
        var firestorePlayerProgress = PlayerProgress.fromJson(
            firestoreDoc.data() as Map<String, dynamic>);

        // Verificar si el elemento ya existe en SQLite
        var localPlayerProgress =
            await playerProgressDao.getPlayerProgressByID(itemId);
        firestorePlayerProgress.userId = userPreferences.storedUID;
        firestorePlayerProgress.id = itemId;

        if (localPlayerProgress != null) {
          // Actualizar el elemento en SQLite si ya existe
          if (firestorePlayerProgress.timestamp
                      .compareTo(localPlayerProgress.timestamp) ==
                  1 &&
              firestorePlayerProgress.timestamp
                  .isAfter(localPlayerProgress.timestamp)) {
            await playerProgressDao
                .updatePlayerProgress(firestorePlayerProgress);
          }
        } else {
          // Agregar el elemento a SQLite si no existe
          await playerProgressDao.insert(firestorePlayerProgress);
        }
      }

      // Puedes implementar lógica adicional para manejar eliminaciones o conflictos.
    } catch (e) {
      print('PlayerProgress Error en la sincronización: $e');
    }
  }

  Future<void> syncGameData() async {
    try {
      // Obtener datos de SQLite

      List<Game> localGames = await gameDao.getAllGames();
      localGames = localGames.where((element) => element.synced == 0).toList();

      for (Game game in localGames) {
        // Verificar si el elemento ya existe en Firestore
        var firestoreItem =
            await gameService.getItemFromFirestore(game.id.toString());

        if (firestoreItem != null) {
          // Actualizar el elemento en Firestore si ya existe
          if (game.timestamp.compareTo(firestoreItem.timestamp) == 1 &&
              game.timestamp.isAfter(firestoreItem.timestamp)) {
            await gameService.updateData(game);
          }
        } else {
          // Agregar el elemento a Firestore si no existe
          await gameService.addData(game);
        }
      }

      // sync from firestore to sqlite

      // Obtener datos de Firestore
      QuerySnapshot firestoreGamesSnapshot =
          await gameService.getAllItemsFromFirestore();

      // Sincronizar con SQLite
      for (QueryDocumentSnapshot firestoreDoc in firestoreGamesSnapshot.docs) {
        var itemId = int.tryParse(firestoreDoc.id);
        var firestoreGame =
            Game.fromJson(firestoreDoc.data() as Map<String, dynamic>);

        // Verificar si el elemento ya existe en SQLite
        var localGame = await gameDao.getGameByID(itemId!);

        localGame?.id = itemId;

        if (localGame != null) {
          // Actualizar el elemento en SQLite si ya existe
          if (firestoreGame.timestamp.compareTo(localGame.timestamp) == 1 &&
              firestoreGame.timestamp.isAfter(localGame.timestamp)) {
            await gameDao.updateGame(firestoreGame);
          }
        } else {
          // Agregar el elemento a SQLite si no existe
          await gameDao.insert(firestoreGame);
        }
      }

      // Puedes implementar lógica adicional para manejar eliminaciones o conflictos.
    } catch (e) {
      print('Game Error en la sincronización: $e');
    }
  }

  Future<void> syncColorsGameData() async {
    try {
      // Obtener datos de SQLite
      List<ColorsGame> localColorsGames =
          await colorsGameDao.getAllColorsGames();
      localColorsGames =
          localColorsGames.where((element) => element.synced == 0).toList();

      for (ColorsGame colorsGame in localColorsGames) {
        // Verificar si el elemento ya existe en Firestore
        var firestoreItem = await colorsGameService
            .getItemFromFirestore(colorsGame.gameId.toString());

        colorsGame.userId = userPreferences.storedUID;

        if (firestoreItem != null) {
          // Actualizar el elemento en Firestore si ya existe
          if (colorsGame.timestamp.compareTo(firestoreItem.timestamp) == 1 &&
              colorsGame.timestamp.isAfter(firestoreItem.timestamp)) {
            await colorsGameService.updateData(colorsGame);
          }
        } else {
          // Agregar el elemento a Firestore si no existe
          await colorsGameService.addData(colorsGame);
        }
      }

      // sync from firestore to sqlite

      // Obtener datos de Firestore
      QuerySnapshot firestoreColorsGamesSnapshot =
          await colorsGameService.getAllItemsFromFirestore();

      // Sincronizar con SQLite
      for (QueryDocumentSnapshot firestoreDoc
          in firestoreColorsGamesSnapshot.docs) {
        var itemId = firestoreDoc.id;
        var firestoreColorsGame =
            ColorsGame.fromJson(firestoreDoc.data() as Map<String, dynamic>);

        // Verificar si el elemento ya existe en SQLite
        var localColorsGame = await colorsGameDao.getColorsGameByID(itemId);

        firestoreColorsGame.userId = userPreferences.storedUID;
        firestoreColorsGame.id = itemId;

        if (localColorsGame != null) {
          // Actualizar el elemento en SQLite si ya existe
          if (firestoreColorsGame.timestamp
                      .compareTo(localColorsGame.timestamp) ==
                  1 &&
              firestoreColorsGame.timestamp
                  .isAfter(localColorsGame.timestamp)) {
            await colorsGameDao.updateColorsGame(firestoreColorsGame);
          }
        } else {
          // Agregar el elemento a SQLite si no existe
          await colorsGameDao.insert(firestoreColorsGame);
        }
      }

      // Puedes implementar lógica adicional para manejar eliminaciones o conflictos.
    } catch (e) {
      print('ColorsGame Error en la sincronización: $e');
    }
  }

  Future<void> syncUserData() async {
    try {
      // Obtener datos de SQLite
      UserData localUser =
          await userDao.getUserByUID(userPreferences.storedUID);

      // Verificar si el elemento ya existe en Firestore
      var firestoreItem =
          await userService.getItemFromFirestore(localUser.uid.toString());

      if (firestoreItem != null) {
        // Actualizar el elemento en Firestore si ya existe
        if (localUser.timestamp.compareTo(firestoreItem.timestamp) == 1) {
          await userService.updateData(localUser);
        }
      } else {
        // Agregar el elemento a Firestore si no existe
        await userService.addData(localUser);
      }

      // sync from firestore to sqlite

      // Obtener datos de Firestore
      UserData? firestoreUser =
          await userService.getItemFromFirestore(userPreferences.storedUID);

      // Sincronizar con SQLite
      var itemId = firestoreUser?.uid;

      // Verificar si el elemento ya existe en SQLite
      var localUserData = await userDao.getUserByUID(itemId!);

      if (localUserData != null) {
        // Actualizar el elemento en SQLite si ya existe
        if (firestoreUser?.timestamp.compareTo(localUserData.timestamp) == 1) {
          await userDao.updateUser(firestoreUser!);
        }
      } else {
        // Agregar el elemento a SQLite si no existe
        await userDao.insert(firestoreUser!);
      }

      // Puedes implementar lógica adicional para manejar eliminaciones o conflictos.
    } catch (e) {
      print('Error en la sincronización: $e');
    }
  }

  Future<void> syncPlayerData() async {
    try {
      // Obtener datos de SQLite

      List<PlayerData> localPlayers = await playerDao.getAllPlayers();
      localPlayers =
          localPlayers.where((element) => element.synced == 0).toList();

      for (PlayerData player in localPlayers) {
        // Verificar si el elemento ya existe en Firestore
        var firestoreItem =
            await playerService.getItemFromFirestore(player.uid.toString());

        if (firestoreItem != null) {
          // Actualizar el elemento en Firestore si ya existe
          if (player.timestamp.compareTo(firestoreItem.timestamp) == 1 &&
              player.timestamp.isAfter(firestoreItem.timestamp)) {
            await playerService.updateData(player);
          }
        } else {
          // Agregar el elemento a Firestore si no existe
          await playerService.addData(player);
        }
      }

      // sync from firestore to sqlite

      // Obtener datos de Firestore
      QuerySnapshot firestorePlayersSnapshot =
          await playerService.getAllItemsFromFirestore();

      // Sincronizar con SQLite
      for (QueryDocumentSnapshot firestoreDoc
          in firestorePlayersSnapshot.docs) {
        var itemId = firestoreDoc.id;
        var firestorePlayer =
            PlayerData.fromJson(firestoreDoc.data() as Map<String, dynamic>);

        // Verificar si el elemento ya existe en SQLite
        var localPlayer = await playerDao.getPlayerByUID(itemId);
        localPlayer.uid = itemId;

        if (localPlayer != null) {
          // Actualizar el elemento en SQLite si ya existe
          if (firestorePlayer.timestamp.compareTo(localPlayer.timestamp) == 1 &&
              firestorePlayer.timestamp.isAfter(localPlayer.timestamp)) {
            await playerDao.updatePlayer(firestorePlayer);
          }
        } else {
          // Agregar el elemento a SQLite si no existe
          await playerDao.insert(firestorePlayer);
        }
      }

      // Puedes implementar lógica adicional para manejar eliminaciones o conflictos.
    } catch (e) {
      print('Player Error en la sincronización: $e');
    }
  }
}
