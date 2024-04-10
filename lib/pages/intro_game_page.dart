import 'package:cognitiveroulletegame/pages/game_page.dart';
import 'package:cognitiveroulletegame/shared/function.dart';
import 'package:cognitiveroulletegame/constans.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:flutter_tts/flutter_tts.dart';

class IntroGamePage extends StatefulWidget {
  String title;
  String textToSpeak;
  IntroGamePage({
    required this.title,
    required this.textToSpeak,
    super.key,
  });

  @override
  State<IntroGamePage> createState() => _IntroGamePageState();
}

class _IntroGamePageState extends State<IntroGamePage> {
  final FlutterTts flutterTts = FlutterTts();
  final DataSource dataSource = DataSource();

  Future<void> _speak() async {
    await dataSource.speak(widget.textToSpeak);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _speak();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _speak,
            icon: Icon(
              Icons.volume_up,
              color: kColorPrimary,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: width * .8,
              height: 300,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: Center(
                child: Text(
                  widget.textToSpeak,
                  style: TextStyle(fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GamePage(
                      title: widget.title,
                      textToSpeak: widget.textToSpeak,
                    ),
                  ),
                );
              },
              child: Text('Jugar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Atras'),
            ),
          ],
        ),
      ),
    );
  }
}
