import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/data/game_notifier.dart';
import 'package:cognitiveroulletegame/pages/intro_game_page.dart';
import 'package:cognitiveroulletegame/services/speaker_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/game_card.dart';

class DivinerPage extends StatefulWidget {
  const DivinerPage({super.key});

  @override
  State<DivinerPage> createState() => _DivinerPageState();
}

class _DivinerPageState extends State<DivinerPage> {
  final SpeakerService speakerService = SpeakerService();
  final String _textToSpeak =
      'En esta pantalla puedes seleccionar el juego que deseas deslizando de izquierda a derecha';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _stop();
  }

  Future<void> _speak() async {
    await speakerService.stop();
    await speakerService.speak(_textToSpeak);
  }

  Future _stop() async {
    await speakerService.stop();
    // setState(() => ttsState = TtsState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    final gameNotifier = Provider.of<GameNotifier>(context);
    double width = MediaQuery.of(context).size.width;

    return Container(
      color: kColorSecondary,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text('Menu'),
          ),
          body: Stack(
            children: [
              Positioned(
                left: 10,
                bottom: 10,
                child: InkWell(
                  onTap: _speak,
                  child: Hero(
                    tag: 'robot',
                    child: Image.asset(
                      'assets/robot.gif',
                      width: width * .40,
                    ),
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: PageView.builder(
                    itemCount: gameNotifier.games.length,
                    controller: PageController(viewportFraction: 0.60),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return GameCard(
                        color: Colors.amber,
                        name: gameNotifier.games[index].name,
                        image:
                            'assets/portada-${gameNotifier.games[index].name.toLowerCase()}.jpeg',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IntroGamePage(
                                gameId: gameNotifier.games[index].id!,
                                title: gameNotifier.games[index].name,
                                textToSpeak:
                                    gameNotifier.games[index].instructions,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
