import 'package:cognitiveroulletegame/pages/game_page.dart';
import 'package:cognitiveroulletegame/pages/intro_game_page.dart';
import 'package:flutter/material.dart';

import '../components/game_card.dart';

class DivinerPage extends StatefulWidget {
  DivinerPage({Key? key}) : super(key: key);

  @override
  State<DivinerPage> createState() => _DivinerPageState();
}

class _DivinerPageState extends State<DivinerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Menu'),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            height: 300,
            child: PageView(
              controller: PageController(viewportFraction: 0.60),
              physics: BouncingScrollPhysics(),
              children: [
                GameCard(
                  color: Colors.amber,
                  name: 'Perfiles',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IntroGamePage(
                          title: 'Perfiles',
                          textToSpeak:
                              'Mira la silueta y selecciona la imagen que le corresponde',
                        ),
                      ),
                    );
                  },
                ),
                GameCard(
                  color: Colors.red,
                  name: 'Luces y sombras',
                  onPressed: () {},
                ),
                GameCard(
                  color: Colors.blue,
                  name: 'Caras y gestos',
                  onPressed: () {},
                ),
                GameCard(
                  color: Colors.blueGrey,
                  name: 'Animales',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
