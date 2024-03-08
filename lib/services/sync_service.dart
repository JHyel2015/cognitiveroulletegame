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
import 'package:cognitiveroulletegame/models/level.dart';
import 'package:cognitiveroulletegame/models/player_progress.dart';
import 'package:cognitiveroulletegame/models/game.dart';
import 'package:cognitiveroulletegame/models/colors_game.dart';

class SyncService {
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
          if (level.timestamp.compareTo(firestoreItem.timestamp) == 1) {
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

        if (localLevel != null) {
          // Actualizar el elemento en SQLite si ya existe
          if (firestoreLevel.timestamp.compareTo(localLevel.timestamp) == 1) {
            await levelDao.updateLevel(firestoreLevel);
          }
        } else {
          // Agregar el elemento a SQLite si no existe
          await levelDao.insert(firestoreLevel);
        }
      }

      // Puedes implementar lógica adicional para manejar eliminaciones o conflictos.
    } catch (e) {
      print('Error en la sincronización: $e');
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

        if (firestoreItem != null) {
          // Actualizar el elemento en Firestore si ya existe
          if (trnPlayerProgress.timestamp.compareTo(firestoreItem.timestamp) ==
              1) {
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
        var itemId = int.tryParse(firestoreDoc.id);
        var firestorePlayerProgress = PlayerProgress.fromJson(
            firestoreDoc.data() as Map<String, dynamic>);

        // Verificar si el elemento ya existe en SQLite
        var localPlayerProgress =
            await playerProgressDao.getPlayerProgressByID(itemId!);

        if (localPlayerProgress != null) {
          // Actualizar el elemento en SQLite si ya existe
          if (firestorePlayerProgress.timestamp
                  .compareTo(localPlayerProgress.timestamp) ==
              1) {
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
      print('Error en la sincronización: $e');
    }
  }

  Future<void> syncGameData() async {
    try {
      // Obtener datos de SQLite

      List<Game> localCreditcards = await gameDao.getAllGames();
      localCreditcards =
          localCreditcards.where((element) => element.synced == 0).toList();

      for (Game game in localCreditcards) {
        // Verificar si el elemento ya existe en Firestore
        var firestoreItem =
            await gameService.getItemFromFirestore(game.id.toString());

        if (firestoreItem != null) {
          // Actualizar el elemento en Firestore si ya existe
          if (game.timestamp.compareTo(firestoreItem.timestamp) == 1) {
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

        if (localGame != null) {
          // Actualizar el elemento en SQLite si ya existe
          if (firestoreGame.timestamp.compareTo(localGame.timestamp) == 1) {
            await gameDao.updateGame(firestoreGame);
          }
        } else {
          // Agregar el elemento a SQLite si no existe
          await gameDao.insert(firestoreGame);
        }
      }

      // Puedes implementar lógica adicional para manejar eliminaciones o conflictos.
    } catch (e) {
      print('Error en la sincronización: $e');
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

        if (firestoreItem != null) {
          // Actualizar el elemento en Firestore si ya existe
          if (colorsGame.timestamp.compareTo(firestoreItem.timestamp) == 1) {
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
        var itemId = int.tryParse(firestoreDoc.id);
        var firestoreColorsGame =
            ColorsGame.fromJson(firestoreDoc.data() as Map<String, dynamic>);

        // Verificar si el elemento ya existe en SQLite
        var localColorsGame = await colorsGameDao.getColorsGameByID(itemId!);

        if (localColorsGame != null) {
          // Actualizar el elemento en SQLite si ya existe
          if (firestoreColorsGame.timestamp
                  .compareTo(localColorsGame.timestamp) ==
              1) {
            await colorsGameDao.updateColorsGame(firestoreColorsGame);
          }
        } else {
          // Agregar el elemento a SQLite si no existe
          await colorsGameDao.insert(firestoreColorsGame);
        }
      }

      // Puedes implementar lógica adicional para manejar eliminaciones o conflictos.
    } catch (e) {
      print('Error en la sincronización: $e');
    }
  }

  // Future<void> syncUserData() async {
  //   try {
  //     // Obtener datos de SQLite
  //     User localUser = await userDao.getUserByID();

  //     // Verificar si el elemento ya existe en Firestore
  //     var firestoreItem =
  //         await userService.getItemFromFirestore(localUser.id.toString());

  //     if (firestoreItem != null) {
  //       // Actualizar el elemento en Firestore si ya existe
  //       if (localUser.timestamp.compareTo(firestoreItem.timestamp) == 1) {
  //         await userService.updateData(localUser);
  //       }
  //     } else {
  //       // Agregar el elemento a Firestore si no existe
  //       await userService.addData(localUser);
  //     }

  //     // sync from firestore to sqlite

  //     // Obtener datos de Firestore
  //     User firestoreUser = await userService.getItemFromFirestore();

  //     // Sincronizar con SQLite
  //     var itemId = firestoreUser.id;

  //     // Verificar si el elemento ya existe en SQLite
  //     var localColorsGame = await userDao.getUserByID(itemId!);

  //     if (localColorsGame != null) {
  //       // Actualizar el elemento en SQLite si ya existe
  //       if (firestoreUser.timestamp.compareTo(localColorsGame.timestamp) ==
  //           1) {
  //         await userDao.updateUser(firestoreUser);
  //       }
  //     } else {
  //       // Agregar el elemento a SQLite si no existe
  //       await userDao.insert(firestoreUser);
  //     }

  //     // Puedes implementar lógica adicional para manejar eliminaciones o conflictos.
  //   } catch (e) {
  //     print('Error en la sincronización: $e');
  //   }
  // }
}
