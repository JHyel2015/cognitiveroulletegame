import 'package:cognitiveroulletegame/pages/counter_game_page.dart';
import 'package:cognitiveroulletegame/pages/roullete_game_page.dart';
import 'package:cognitiveroulletegame/services/speaker_service.dart';
import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:flutter_tts/flutter_tts.dart';

class IntroGamePage extends StatefulWidget {
  int gameId;
  String title;
  String textToSpeak;
  IntroGamePage({
    required this.gameId,
    required this.title,
    required this.textToSpeak,
    super.key,
  });

  @override
  State<IntroGamePage> createState() => _IntroGamePageState();
}

class _IntroGamePageState extends State<IntroGamePage> {
  final FlutterTts flutterTts = FlutterTts();
  final SpeakerService speakerService = SpeakerService();
  final UserPreferences userPreferences = UserPreferences();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  // TtsState ttsState = TtsState.stopped;

  // bool get isPlaying => ttsState == TtsState.playing;
  // bool get isStopped => ttsState == TtsState.stopped;
  // bool get isPaused => ttsState == TtsState.paused;
  // bool get isContinued => ttsState == TtsState.continued;

  Future<void> _speak() async {
    await speakerService.speak(widget.textToSpeak);
    // setState(() => ttsState = TtsState.playing);
  }

  Future _stop() async {
    await speakerService.stop();
    // setState(() => ttsState = TtsState.stopped);
  }

  void _getCurrentUser() {
    User? user = _auth.currentUser;
    setState(() {
      _user = user;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _speak();
    _getCurrentUser();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _stop();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      color: kColorSecondary,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(widget.title),
            actions: [
              PopupMenuButton(
                icon: CircleAvatar(
                  child: Text('I'),
                ),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      enabled: false,
                      child: Text(
                        _user != null
                            ? _user!.displayName.toString()
                            : 'Usuario Invitado',
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    _stop();
                    userPreferences.isMute = !userPreferences.isMute;
                    if (!userPreferences.isMute) {
                      _speak();
                    }
                    setState(() {});
                  },
                  icon: userPreferences.isMute
                      ? Icon(
                          Icons.voice_over_off,
                          color: kColorPrimary,
                        )
                      : Icon(
                          Icons.record_voice_over,
                          color: kColorPrimary,
                        ),
                ),
              ),
              SizedBox(width: 5),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(
                      BorderSide(width: 1, color: Colors.blueAccent),
                    ),
                  ),
                  onPressed: _speak,
                  icon: Icon(
                    Icons.volume_up,
                    color: kColorPrimary,
                  ),
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
                TextButton.icon(
                  style: TextButton.styleFrom(backgroundColor: kColorPrimary),
                  onPressed: () {
                    _stop();
                    switch (widget.gameId) {
                      case 1:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoulleteGamePage(
                              gameId: widget.gameId,
                              title: widget.title,
                              textToSpeak: widget.textToSpeak,
                            ),
                          ),
                        );
                        break;
                      case 2:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CounterGamePage(
                              gameId: widget.gameId,
                              title: widget.title,
                              textToSpeak: widget.textToSpeak,
                            ),
                          ),
                        );
                        break;
                      default:
                    }
                  },
                  label: Text(
                    'Continuar',
                    style: TextStyle(color: kColorSecondary),
                  ),
                  icon: Icon(
                    Icons.play_arrow,
                    color: kColorSecondary,
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(backgroundColor: kColorPrimary),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  label: Text(
                    'Regresar',
                    style: TextStyle(color: kColorSecondary),
                  ),
                  icon: Icon(
                    Icons.undo,
                    color: kColorSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
