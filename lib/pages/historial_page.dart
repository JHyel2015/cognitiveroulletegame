import 'package:cognitiveroulletegame/data/game_notifier.dart';
import 'package:cognitiveroulletegame/data/player_notifier.dart';
import 'package:cognitiveroulletegame/data/player_progress_notifier.dart';
import 'package:cognitiveroulletegame/models/game.dart';
import 'package:cognitiveroulletegame/models/player_data.dart';
import 'package:cognitiveroulletegame/models/player_progress.dart';
import 'package:cognitiveroulletegame/pages/historial_colors_game.dart';
import 'package:cognitiveroulletegame/services/app_logger.dart';
import 'package:cognitiveroulletegame/services/speaker_service.dart';
import 'package:cognitiveroulletegame/services/sync_service.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final SpeakerService speakerService = SpeakerService();

  late PlayerData _player;

  late List<PlayerProgress> _playerProgress;
  late List<Game> _games;
  final logger = AppLogger();

  @override
  void initState() {
    syncService.syncPlayerProgressData();
    super.initState();
    _speak('En esta pantalla se muestra el historial de partidas del jugador.');
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  Future<void> _speak(String textToSpeak) async {
    await speakerService.stop();
    await speakerService.speak(textToSpeak);
  }

  Future _stop() async {
    await speakerService.stop();
    // setState(() => ttsState = TtsState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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

    return SizedBox(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text('Historal'),
        ),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            if (_playerProgress.isEmpty)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      size: 50,
                    ),
                    Text('Parece que aún no hay datos.'),
                  ],
                ),
              ),
            if (_playerProgress.isNotEmpty)
              ListView.builder(
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
                    leading: const Icon(
                      Icons.color_lens,
                      size: 30,
                    ),
                    title: Text(playerName ?? 'Sin nombre'),
                    subtitle: Text(
                        '${game.name} - ${playerProgress.playedTime} - ${playerProgress.timestamp} - ${playerProgress.comment}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStat(Icons.hourglass_top, playerProgress.attempts,
                            Colors.blue),
                        const SizedBox(width: 8),
                        _buildStat(Icons.check_circle, playerProgress.successes,
                            Colors.green),
                        const SizedBox(width: 8),
                        _buildStat(
                            Icons.cancel, playerProgress.failures, Colors.red),
                      ],
                    ),
                    // Text(
                    // '${playerProgress.attempts} - ${playerProgress.successes} - ${playerProgress.failures}'),
                    onTap: () {
                      String attempts = playerProgress.attempts == 1
                          ? 'un intento'
                          : '${playerProgress.attempts} intentos';
                      String failures = playerProgress.failures == 1
                          ? 'un fallo'
                          : '${playerProgress.failures} fallos';
                      String successes = playerProgress.successes == 1
                          ? 'un acierto'
                          : '${playerProgress.successes} aciertos';
                      _speak(
                          'En esta partida se hizo $attempts con $successes y $failures');
                      // Lógica al seleccionar un registro
                      if (game.id == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // builder: (context) => LevelsPage(),
                            builder: (context) => HistorialColorsGamePage(
                              playerName: playerName ?? '',
                              playerProgressId: playerProgress.id!,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            Positioned(
              left: 10,
              bottom: 10,
              child: InkWell(
                onTap: () => _speak(
                    'En esta pantalla se muestra el historial de partidas del jugador.'),
                child: Hero(
                  tag: 'robot',
                  child: Image.asset(
                    'assets/robot.gif',
                    width: width * .40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, int value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
