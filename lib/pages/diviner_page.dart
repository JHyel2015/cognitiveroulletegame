import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/data/game_notifier.dart';
import 'package:cognitiveroulletegame/pages/intro_game_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/game_card.dart';

class DivinerPage extends StatefulWidget {
  const DivinerPage({super.key});

  @override
  State<DivinerPage> createState() => _DivinerPageState();
}

class _DivinerPageState extends State<DivinerPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gameNotifier = Provider.of<GameNotifier>(context);

    return Container(
      color: kColorSecondary,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Menu'),
          ),
          body: Center(
            child: Container(
              width: double.infinity,
              height: 300,
              child: PageView.builder(
                itemCount: gameNotifier.games.length,
                controller: PageController(viewportFraction: 0.60),
                physics: BouncingScrollPhysics(),
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
                            textToSpeak: gameNotifier.games[index].instructions,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
