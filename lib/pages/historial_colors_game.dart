import 'package:cognitiveroulletegame/data/colors_game_notifier.dart';
import 'package:cognitiveroulletegame/data/game_notifier.dart';
import 'package:cognitiveroulletegame/data/player_notifier.dart';
import 'package:cognitiveroulletegame/models/colors_game.dart';
import 'package:cognitiveroulletegame/models/game.dart';
import 'package:cognitiveroulletegame/models/player_data.dart';
import 'package:cognitiveroulletegame/services/app_logger.dart';
import 'package:cognitiveroulletegame/services/speaker_service.dart';
import 'package:cognitiveroulletegame/services/sync_service.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistorialColorsGamePage extends StatefulWidget {
  String playerName;
  String playerProgressId;

  HistorialColorsGamePage({
    super.key,
    required this.playerName,
    required this.playerProgressId,
  });

  @override
  State<HistorialColorsGamePage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialColorsGamePage> {
  final UserPreferences userPreferences = UserPreferences();

  SyncService syncService = SyncService();
  final SpeakerService speakerService = SpeakerService();

  late PlayerData _player;

  late List<ColorsGame> _colorsGames;
  late List<Game> _games;
  final logger = AppLogger();

  final Map<String, Color> _colors = {
    'blue': Colors.blue,
    'purple': Colors.purple,
    'orange': Colors.orange,
    'green': Colors.green,
    'red': Colors.red,
    'yellow': Colors.yellow,
  };

  final Map<String, String> _spanishColors = {
    'blue': 'azul',
    'purple': 'violeta',
    'orange': 'naranja',
    'green': 'verde',
    'red': 'rojo',
    'yellow': 'amarillo',
  };

  @override
  void initState() {
    syncService.syncColorsGameData();
    super.initState();
    // _speak(
    //     'En esta pantalla se muestra los intentos de la partida del jugador.');
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
    final colorsGameNotifier = Provider.of<ColorsGameNotifier>(context);
    final gameNotifier = Provider.of<GameNotifier>(context);

    _colorsGames = colorsGameNotifier.getAllColorsGamesList();
    _games = gameNotifier.games;
    if (widget.playerName != '') {
      _player = playerNotifier.players
          .where((item) => item.name == widget.playerName)
          .first;
      _colorsGames = colorsGameNotifier.getColorsGameByPlayerProgresss(
          _player.uid!, widget.playerProgressId);
    }
    _colorsGames.sort(
      (a, b) => b.timestamp.compareTo(a.timestamp),
    );

    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text('Historal intentos'),
        ),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            ListView.builder(
              itemCount: _colorsGames.length,
              itemBuilder: (context, index) {
                final colorsGame = _colorsGames[index];
                PlayerData player;
                String? playerName;
                if (colorsGame.userId != '') {
                  player = playerNotifier.players
                      .where((item) => item.uid == colorsGame.userId)
                      .first;
                  playerName = player.name;
                }
                Game game;
                game = gameNotifier.games
                    .where((item) => item.id == colorsGame.gameId)
                    .first;

                return ListTile(
                  leading: colorsGame.success
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 40,
                        )
                      : const Icon(
                          Icons.cancel,
                          size: 40,
                          color: Colors.red,
                        ),
                  title: Text(playerName ?? 'Sin nombre'),
                  subtitle: Text(game.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStat(colorsGame.correctColor, 'correcto'),
                      const SizedBox(width: 8),
                      _buildStat(colorsGame.selectedColor, 'seleccionado'),
                    ],
                  ),
                  // Text(
                  // '${playerProgress.attempts} - ${playerProgress.successes} - ${playerProgress.failures}'),
                  onTap: () {
                    // Lógica al seleccionar un jugador
                    _speak(
                        'Intento ${colorsGame.success ? 'correcto' : 'fallido'}, color correcto: ${_spanishColors[colorsGame.correctColor]!}, color seleccionado: ${_spanishColors[colorsGame.selectedColor]!}');
                  },
                );
              },
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: InkWell(
                onTap: () => _speak(
                    'En esta pantalla se muestra los intentos de la partida del jugador.'),
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

  Widget _buildStat(String color, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Color $label'),
        GestureDetector(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Icon(Icons.circle, color: _colors[color.toLowerCase()], size: 40),
              Text(
                _spanishColors[color]!.toUpperCase(),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          onTap: () {
            _speak(_spanishColors[color]!);
          },
        ),
      ],
    );
  }
}
