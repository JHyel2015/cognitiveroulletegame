import 'package:cognitiveroulletegame/data/game_notifier.dart';
import 'package:cognitiveroulletegame/data/player_notifier.dart';
import 'package:cognitiveroulletegame/data/player_progress_notifier.dart';
import 'package:cognitiveroulletegame/models/game.dart';
import 'package:cognitiveroulletegame/models/player_data.dart';
import 'package:cognitiveroulletegame/models/player_progress.dart';
import 'package:cognitiveroulletegame/services/sync_service.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistorialPage extends StatefulWidget {
  String playerName;

  HistorialPage({
    super.key,
    required this.playerName,
  });

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  final UserPreferences userPreferences = UserPreferences();

  final _user = FirebaseAuth.instance.currentUser;
  SyncService syncService = SyncService();

  late PlayerData _player;

  late List<PlayerProgress> _playerProgress;
  late List<Game> _games;

  @override
  void initState() {
    // TODO: implement initState

    syncService.syncPlayerProgressData();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerNotifier = Provider.of<PlayerNotifier>(context);
    final gameNotifier = Provider.of<GameNotifier>(context);
    final playerProgressNotifier = Provider.of<PlayerProgressNotifier>(context);

    _playerProgress = playerProgressNotifier.getAllPlayerProgresssList();
    _games = gameNotifier.games;
    if (widget.playerName != '') {
      _player = playerNotifier.player!;
      _playerProgress =
          playerProgressNotifier.getPlayerProgresssByPlayer(_player.uid!);
    }
    _playerProgress.sort(
      (a, b) => b.timestamp.compareTo(a.timestamp),
    );

    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text('Historal'),
        ),
        body: ListView.builder(
          itemCount: _playerProgress.length,
          itemBuilder: (context, index) {
            final playerProgress = _playerProgress[index];
            PlayerData player;
            String? playerName;
            if (playerProgress.userId != '') {
              player = playerNotifier.players
                  .where((item) => item.uid == playerProgress.userId)
                  .first;
              playerName = player.name;
            }
            Game game;
            game = gameNotifier.games
                .where((item) => item.id == playerProgress.gameId)
                .first;

            return ListTile(
              leading: Icon(Icons.color_lens),
              title: Text(playerName ?? 'Sin nombre'),
              subtitle: Text(
                  '${game.name} - ${playerProgress.playedTime} - ${playerProgress.timestamp} - '),
              trailing: Text(
                  '${playerProgress.attempts} - ${playerProgress.successes} - ${playerProgress.failures}'),
              onTap: () {
                // Lógica al seleccionar un jugador
              },
            );
          },
        ),
      ),
    );
  }
}
