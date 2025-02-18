// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';

import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/data/colors_game_notifier.dart';
import 'package:cognitiveroulletegame/data/player_notifier.dart';
import 'package:cognitiveroulletegame/data/player_progress_notifier.dart';
import 'package:cognitiveroulletegame/models/colors_game.dart';
import 'package:cognitiveroulletegame/models/player_data.dart';
import 'package:cognitiveroulletegame/models/player_progress.dart';
import 'package:cognitiveroulletegame/services/app_logger.dart';
import 'package:cognitiveroulletegame/services/speaker_service.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:cognitiveroulletegame/components/star_rating.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';

import 'package:flutter_image_filters/flutter_image_filters.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class CounterGamePage extends StatefulWidget {
  final int gameId;
  final String title;
  final String textToSpeak;
  const CounterGamePage({
    required this.gameId,
    required this.title,
    required this.textToSpeak,
    super.key,
  });

  @override
  State<CounterGamePage> createState() => _CounterGamePageState();
}

class _CounterGamePageState extends State<CounterGamePage>
    with TickerProviderStateMixin {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  int nElements = 6;
  final commentController = TextEditingController();
  // PageController
  final _controller = PageController(viewportFraction: 0.8);
  // TextController
  final UserPreferences userPreferences = UserPreferences();

  late PlayerData _player;
  final SpeakerService speakerService = SpeakerService();
  final logger = AppLogger();

  bool _exited = false;
  bool _ledOn = false;
  int _counter = 0;
  // final FirebaseDatabase _databaseReference = FirebaseDatabase.instance;
  late FirebaseApp _secondaryApp;
  late FirebaseDatabase _databaseReference;
  late StreamSubscription<DatabaseEvent> _ledOnSubscription;
  late StreamSubscription<DatabaseEvent> _counterSubscription;
  late DatabaseReference _ledOnRef;
  late DatabaseReference _levelRef;
  late DatabaseReference _aciertoRef;
  late DatabaseReference _counterRef;

  int isTappedOut = 0;
  int isCorrect = 0;
  int _randomNum = 0;
  int scoreMax = 4;
  int currentScore = 0;
  int selectedItem = -1;
  int _segmentIndex = 0;

  int _intentos = 0;
  int _aciertos = 0;
  int _fallos = 0;

  bool _visible = false;

  late Duration elapsedTime;

  late AnimationController _animationController;
  late Animation<double> _animation;

  late AnimationController _animationController2;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;
  late Animation<double> _animation4;

  double _currentAngle = pi / 6;
  final int _segments = 6;

  int _time = 0;

  List<String> fileURLs = [];
  List<String> randomFileURLs = [];

  final List<String> _colorList = [
    'blue',
    'purple',
    'orange',
    'green',
    'red',
    'yellow',
  ];

  final List<Color> _colors = [
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.yellow,
  ];

  late TextureSource texture;
  late BrightnessShaderConfiguration configuration;
  bool textureLoaded = false;

  String? _playerProgressId;

  bool _isWakelockEnabled = false;

  bool stopAnimation = false;
  List<int> cardNumbers = [-1, -1, -1];
  bool _isDisposed = false;

  Future<void> init() async {
    _secondaryApp = Firebase.app('esp32colores');
    _databaseReference = FirebaseDatabase.instanceFor(
      app: _secondaryApp,
      databaseURL: 'https://esp32colores-default-rtdb.firebaseio.com',
    );

    _ledOnRef = _databaseReference.ref(kFirebaseLEDStatus);
    _levelRef = _databaseReference.ref(kFirebaseLevel);
    _aciertoRef = _databaseReference.ref(kFirebaseAcierto);
    _counterRef = _databaseReference.ref(kFirebaseCount);

    _databaseReference.setPersistenceEnabled(true);
    _databaseReference.setPersistenceCacheSizeBytes(10000000);

    await _ledOnRef.keepSynced(true);
    await _counterRef.keepSynced(true);
    await _levelRef.keepSynced(true);
    await _aciertoRef.keepSynced(true);

    _levelRef.set(widget.gameId);

    try {
      final counterSnapshot = await _ledOnRef.get();

      logger.i(
        'Connected to directly configured database and read'
        '${counterSnapshot.value}',
      );
    } catch (err) {
      logger.e(err.toString());
    }

    _ledOnSubscription = _ledOnRef.onValue.listen(
      (DatabaseEvent event) {
        setState(() {
          _ledOn = (event.snapshot.value ?? false) as bool;
          logger.d(event.snapshot.value.toString());
        });
      },
    );

    _counterSubscription = _counterRef.onValue.listen(
      (DatabaseEvent event) async {
        setState(() {
          _counter = (event.snapshot.value ?? 0) as int;
          logger.d('$_counter');
          if (_counter > 0) {
            stopAndGenerateNumbers();
            _speak('Escoge entre las cartas el número que contaste');
          }
        });
      },
    );
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
  void initState() {
    super.initState();
    _ledOn = userPreferences.isLedOn;

    WakelockPlus.enable();
    _isWakelockEnabled = true;

    _time = userPreferences.time * 2;
    int time = _time >= 60 ? 15 : _time;

    _animationController = AnimationController(
      duration: Duration(seconds: time),
      vsync: this,
    )
      ..addListener(() {
        if (!_ledOn) {
          _currentAngle = _animation.value;
        }
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _showResult();
        }
      });

    getRandomInt();

    _animationController2 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation1 = Tween<double>(begin: 80, end: 500).animate(
      _animationController2,
    );
    _animation2 = Tween<double>(begin: 500, end: 80).animate(
      _animationController2,
    );
    _animation3 = Tween<double>(begin: 80, end: 500).animate(
      _animationController2,
    );
    _animation4 = Tween<double>(begin: 0, end: 6).animate(
      _animationController2,
    );

    _animationController2.addListener(() {
      if (stopAnimation) {
        _animationController2.stop();
        setState(() {
          Random random = Random();
          _segmentIndex = _counter;
          cardNumbers = List.generate(3, (_) => random.nextInt(_counter) + 5);
          if (!cardNumbers.contains(_counter)) {
            cardNumbers[random.nextInt(2)] = _counter;
          }
        });
      } else {
        _animationController2.repeat();
        setState(() {});
      }
    });

    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );
    _animation = Tween<double>(begin: -(pi / 2), end: (2 * pi * 4) - (pi / 2))
        .animate(curvedAnimation);

    init();

    configuration = BrightnessShaderConfiguration();
    configuration.brightness = 0.5;
    TextureSource.fromAsset('assets/roulette.png')
        .then((value) => texture = value)
        .whenComplete(
          () => setState(() {
            textureLoaded = true;
          }),
        );
    addGameProgress();
    _speak(widget.textToSpeak);
    _stopwatch.start();
    Future.delayed(Duration(seconds: _time), () {
      if (!_isDisposed) {
        _animationController.stop();
        _animationController2.stop();
        logger.i('Se cumplio el tiempo');
        if (_isWakelockEnabled) {
          WakelockPlus.disable();
        }
        _isWakelockEnabled = false;
        openBox();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel(); // Cancelar el temporizador al salir de la pantalla
    _stopwatch.stop();
    _animationController.dispose();
    _controller.dispose();
    _animationController2.dispose();
    super.dispose();
    _ledOnSubscription.cancel();
    _counterSubscription.cancel();
    WakelockPlus.disable();
    _isWakelockEnabled = false;
  }

  void stopAndGenerateNumbers() {
    setState(() {
      stopAnimation = true;
    });
    _animationController2.forward(from: 0);
  }

  Future<void> getRandomInt() async {
    final random = Random();
    int number = random.nextInt(_segments);
    if (_ledOn) {
      logger.d(
          'entra primera vez ${_colorList[number].substring(0, 1).toUpperCase()}${_colorList[number].substring(1).toLowerCase()}');
    }
    setState(() {
      _randomNum = number;
    });
  }

  void _spinAnimation() {
    if (_animationController.isAnimating) return;
    _animationController.forward(from: 0);
  }

  void _stopAnimation() {
    if (_animationController.isAnimating) {
      _animationController.stop();
      _showResult();
    }
  }

  Future<void> _showResult() async {
    _visible = true;
    setState(() {});
    _intentos++;

    if (_randomNum == _segmentIndex) {
      _aciertos++;
      await _aciertoRef.set(_aciertos);
    } else {
      _fallos++;
    }
    await _counterRef.set(0);
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isDisposed) {
        stopAnimation = false;
        _animationController2.forward(from: 0);
        cardNumbers = [-1, -1, -1];
        _visible = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final playerNotifier = Provider.of<PlayerNotifier>(context);

    _player = playerNotifier.player!;

    return Container(
      color: kColorSecondary,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(widget.title),
            actions: [
              IconButton(
                onPressed: () {
                  _stop();
                  userPreferences.isMute = !userPreferences.isMute;
                  if (!userPreferences.isMute) {
                    _speak(widget.textToSpeak);
                  }
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
              IconButton(
                onPressed: () {
                  _speak(widget.textToSpeak);
                },
                icon: Icon(
                  Icons.volume_up,
                  color: kColorPrimary,
                ),
              ),
            ],
          ),
          body: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Positioned(
                top: 60,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text(Duration(seconds: _stopwatch.elapsed.inSeconds)
                      .toString()
                      .split('.')[0]
                      .substring(2)),
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text(
                    widget.textToSpeak,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: InkWell(
                  onTap: () {
                    _speak(widget.textToSpeak);
                  },
                  child: Hero(
                    tag: 'robot',
                    child: Image.asset(
                      'assets/robot.gif',
                      width: width * .25,
                    ),
                  ),
                ),
              ),
              Center(
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Positioned(
                      top: _animation1.value,
                      left: 50,
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.01)
                          ..rotateY(_animation4.value),
                        alignment: FractionalOffset.center,
                        child: _buildCard(cardNumbers[0]),
                      ),
                    ),
                    Positioned(
                      top: _animation2.value,
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.01)
                          ..rotateY(_animation4.value),
                        alignment: FractionalOffset.center,
                        child: _buildCard(cardNumbers[1]),
                      ),
                    ),
                    Positioned(
                      top: _animation3.value,
                      right: 50,
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.01)
                          ..rotateY(_animation4.value),
                        alignment: FractionalOffset.center,
                        child: _buildCard(cardNumbers[2]),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: kColorPrimary,
                  ),
                  onPressed: () {
                    elapsedTime = _stopwatch.elapsed;
                    _time = elapsedTime.inSeconds;
                    _stopwatch.stop();
                    if (_isWakelockEnabled) {
                      WakelockPlus.disable();
                    }
                    _isWakelockEnabled = false;
                    openBox();
                  },
                  icon: Icon(
                    Icons.close,
                    color: kColorSecondary,
                  ),
                  label: Text(
                    'Salir',
                    style: TextStyle(color: kColorSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(int number) {
    return GestureDetector(
      onTap: () {
        if (!_animationController2.isAnimating) {
          setState(() {
            _randomNum = number;
          });
          _showResult();
        }
      },
      child: Container(
        width: 100,
        height: 150,
        decoration: BoxDecoration(
          color: kColorPrimary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
            if (_visible && _segmentIndex == number)
              BoxShadow(
                color: Colors.green,
                blurRadius: 1,
                spreadRadius: 8,
                offset: Offset(0, 0),
              ),
          ],
        ),
        child: Center(
          child: Text(
            number == -1 ? '?' : number.toString(),
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }

  void openBox() {
    BuildContext dialogContext;
    _exited = true;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Container(
                padding: EdgeInsets.all(15),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Fin del juego',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 15),
                      StarRating(
                          attempts: _intentos, correctAnswers: _aciertos),
                      SizedBox(height: 15),
                      Text(
                        'Resultados',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Chip(
                                //avatar: Icon(Icons.schedule),
                                label: Text(
                                    'Tiempo ${Duration(seconds: _time).toString().split('.')[0].substring(2)}'),
                              ),
                              Chip(
                                //avatar: Icon(Icons.sunny),
                                label: Text('Aciertos ${_aciertos.toString()}'),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Chip(
                                //avatar: Icon(Icons.sunny),
                                label: Text('Intentos ${_intentos.toString()}'),
                              ),
                              Chip(
                                //avatar: Icon(Icons.sunny),
                                label: Text('Fallos ${_fallos.toString()}'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Comentarios',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: commentController,
                        maxLines: 6,
                        readOnly: userPreferences.isAnonymous,
                        decoration: InputDecoration(
                          hintText: userPreferences.isAnonymous
                              ? 'Usuario invitado no puede ingresar comentarios ni guardar resultados'
                              : '',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: kColorPrimary),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: kColorPrimary),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Para enviar los resultados y regresar al menú principal, presiona el boton finalizar',
                      ),
                      SizedBox(height: 15),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: kColorPrimary,
                        ),
                        onPressed: () {
                          addGameProgress();
                          Navigator.pop(dialogContext);
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/homepage', ModalRoute.withName('/'));
                        },
                        label: Text(
                          'Finalizar',
                          style: TextStyle(color: kColorSecondary),
                        ),
                        icon: Icon(
                          Icons.undo,
                          color: kColorSecondary,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> addGameProgress() async {
    final playerProgressNotifier = Provider.of<PlayerProgressNotifier>(
      context,
      listen: false,
    );

    PlayerProgress playerProgress = PlayerProgress(
      userId: _player.uid!,
      gameId: widget.gameId,
      levelId: 0,
      score: _aciertos > 0 ? (_intentos / _aciertos).floor() : 0,
      successes: _aciertos,
      failures: _fallos,
      attempts: _intentos,
      playedTime:
          Duration(seconds: _time).toString().split('.')[0].substring(2),
      comment: commentController.text,
      status: 'DONE',
      timestamp: DateTime.now(),
    );

    _playerProgressId = await playerProgressNotifier
        .addPlayerProgress(playerProgress) as String?;
  }

  void addColorsGame(String selectedColor, String correctColor, bool success) {
    final colorsGameNotifier = Provider.of<ColorsGameNotifier>(
      context,
      listen: false,
    );

    ColorsGame colorsGame = ColorsGame(
      playerProgressId: _playerProgressId!,
      gameId: widget.gameId,
      userId: _player.uid!,
      selectedColor: selectedColor,
      correctColor: correctColor,
      success: success,
      timestamp: DateTime.now(),
    );

    colorsGameNotifier.addColorsGame(colorsGame);
  }
}
