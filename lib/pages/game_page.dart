// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/data/colors_game_notifier.dart';
import 'package:cognitiveroulletegame/data/player_progress_notifier.dart';
import 'package:cognitiveroulletegame/models/colors_game.dart';
import 'package:cognitiveroulletegame/models/esp32.dart';
import 'package:cognitiveroulletegame/models/player_progress.dart';
import 'package:cognitiveroulletegame/services/speaker_service.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:cognitiveroulletegame/widgets/ruleta_painter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:http/http.dart' as http;

import 'package:image/image.dart' as img;
import 'package:flutter_image_filters/flutter_image_filters.dart';
import 'package:provider/provider.dart';

class GamePage extends StatefulWidget {
  int gameId;
  String title;
  String textToSpeak;
  GamePage({
    required this.gameId,
    required this.title,
    required this.textToSpeak,
    super.key,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  int nElements = 6;
  final commentController = TextEditingController();
  // PageController
  final _controller = PageController(viewportFraction: 0.8);
  // TextController
  final UserPreferences userPreferences = UserPreferences();

  final _user = FirebaseAuth.instance.currentUser;
  final SpeakerService speakerService = SpeakerService();

  bool _ledOn = false;
  int _valorEnvio = 0;
  Sensores _sensores = Sensores();
  // final FirebaseDatabase _databaseReference = FirebaseDatabase.instance;
  late FirebaseApp _secondaryApp;
  late FirebaseDatabase _databaseReference;
  late StreamSubscription<DatabaseEvent> _ledOnSubscription;
  late StreamSubscription<DatabaseEvent> _sensoresSubscription;
  late DatabaseReference _ledOnRef;
  late DatabaseReference _sensoresRef;

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

  bool _btnActive = false;
  bool _visible = false;
  bool _firstTime = true;

  late Duration elapsedTime;

  late AnimationController _animationController;
  late Animation<double> _animation;
  double _currentAngle = pi / 6;
  double _angle = pi / 2;
  int _segments = 6;

  int _time = 0;

  List<String> fileURLs = [];
  List<String> randomFileURLs = [];

  final List<double> _angleList = [
    (2 * pi) - (pi / 6),
  ];

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

  List<String> _imagePaths = [];

  Map<String, String> _imageName = Map<String, String>();
  Map<String, Image> _imagesMap = Map<String, Image>();

  List<Image> _images = [];
  late List<Image> _randomImages = [];

  late TextureSource texture;
  late BrightnessShaderConfiguration configuration;
  bool textureLoaded = false;

  // FlutterBlue bluetooth = FlutterBlue.instance;

  double _downloadPercentage = 0;

  String? _playerProgressId;

  Future<void> init() async {
    _secondaryApp = Firebase.app('esp32colores');
    _databaseReference = FirebaseDatabase.instanceFor(
      app: _secondaryApp,
      databaseURL: 'https://esp32colores-default-rtdb.firebaseio.com',
    );

    _ledOnRef = _databaseReference.ref('EstadoLED');
    _sensoresRef = _databaseReference.ref('esp32DataBase/Sensores');

    _databaseReference.setPersistenceEnabled(true);
    _databaseReference.setPersistenceCacheSizeBytes(10000000);

    await _ledOnRef.keepSynced(true);
    await _sensoresRef.keepSynced(true);

    try {
      final counterSnapshot = await _ledOnRef.get();

      print(
        'Connected to directly configured database and read'
        '${counterSnapshot.value}',
      );
    } catch (err) {
      print(err);
    }

    _ledOnSubscription = _ledOnRef.onValue.listen(
      (DatabaseEvent event) {
        setState(() {
          _ledOn = (event.snapshot.value ?? false) as bool;
          print(event.snapshot.value);
        });
      },
    );

    _sensoresSubscription = _sensoresRef.onValue.listen(
      (DatabaseEvent event) async {
        if (_ledOn) {
          setState(() {
            print('1 ${event.snapshot.value}');
            final value = Map<String, dynamic>.from(
                event.snapshot.value as Map<Object?, Object?>);
            _sensores = (Sensores.fromJson(value));
            _angle = 0;
            switch (_sensores.indiceColorEncendido) {
              case 0:
                _angle = pi / 6;
              case 1:
                _angle = pi / 2;
              case 2:
                _angle = pi - pi / 6;
              case 3:
                _angle = pi + pi / 6;
              case 4:
                _angle = 3 * pi / 2;
              case 5:
                _angle = 2 * pi - pi / 6;
              default:
                _angle = 3 * pi / 2;
            }
            _currentAngle = _angle;
            print('3 ${_sensores.toJson().toString()}');
          });
          await _sensoresRef.update({"puntaje": 0});

          if (_sensores.valorEnvioBoton == 1) {
            _valorEnvio = _sensores.valorEnvioBoton;
            if (_animationController.isAnimating) {
              _stopAnimation();
            } else {
              _fallos++;
              _intentos++;
              _spinAnimation();
            }
            await _sensoresRef.update({"valorEnvioBoton": 0});
          }
        }
      },
    );
  }

  Future<void> _speak() async {
    await speakerService.stop();
    await speakerService.speak(widget.textToSpeak);
  }

  Future _stop() async {
    await speakerService.stop();
    // setState(() => ttsState = TtsState.stopped);
  }

  Future<void> _getFiles() async {
    try {
      ListResult result = await FirebaseStorage.instance.ref().listAll();
      for (var ref in result.items) {
        String downloadURL = await ref.getDownloadURL();
        if (ref.name.startsWith('animal-')) {
          fileURLs.add(downloadURL);
          _imagePaths.add(downloadURL);
          _imageName[ref.name] = downloadURL;
        }
      }

      _imageName.forEach((key, value) async {
        _imagesMap[key] = Image.network(value);
      });

      // _images = _imagePaths.map((path) => Image.network(path)).toList();
      _images = _imagesMap.values.toList();
      await Future.wait(_images.map((image) {
        return _loadImage(image);
      }));

      randomElements();

      // _randomImages = getRandomElements(_images, nElements);
      randomFileURLs = getRandomElements(fileURLs, nElements);
      setState(() {});
      _animationController.forward(from: 0);
      _speak();
      _stopwatch.start();
      Future.delayed(Duration(seconds: _time), () {
        _animationController.stop();
        print('Se cumplio el tiempo');
        openBox();
      });
    } catch (e) {
      print('Error al obtener los archivos del bucket de Firebase Storage: $e');
    }
  }

  List<T> getRandomElements<T>(List<T> list, int n) {
    list.shuffle();
    return list.take(n).toList();
  }

  void randomElements() {
    List<Image> randomImages = [];

    for (var i = 0; i < _colorList.length; i++) {
      var keyList = _imagesMap.keys
          .toList()
          .where((item) => item.contains('-${_colorList[i]}-'))
          .toList();
      keyList.shuffle();
      keyList.first;
      randomImages.add(_imagesMap[keyList.first]!);
    }

    _randomImages = randomImages;
  }

  @override
  void initState() {
    super.initState();
    _ledOn = userPreferences.isLedOn;
    init();

    _time = userPreferences.time;
    int time = _time >= 60 ? 15 : _time;
    _getFiles();

    // print(bluetooth.connectedDevices);
    getRandomInt();

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

    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );
    _animation = Tween<double>(begin: -(pi / 2), end: (2 * pi * 4) - (pi / 2))
        .animate(curvedAnimation);

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
    // _stopwatch.start();
    // print(time);
    // Future.delayed(Duration(seconds: time), () {
    //   print('Se cumplio el tiempo');
    //   // openBox();
    // });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelar el temporizador al salir de la pantalla
    _stopwatch.stop();
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
    _ledOnSubscription.cancel();
    _sensoresSubscription.cancel();
  }

  void getRandomInt() async {
    final random = Random();
    int number = random.nextInt(_segments);
    if (_ledOn) {
      print(
          'entra primera vez ${_colorList[number].substring(0, 1).toUpperCase()}${_colorList[number].substring(1).toLowerCase()}');
      await _sensoresRef.update(
        {
          "color_que_juega":
              '${_colorList[number].substring(0, 1).toUpperCase()}${_colorList[number].substring(1).toLowerCase()}'
        },
      );
    }
    setState(() {
      _randomNum = number;
    });
  }

  Future<Uint8List> _loadIamges(String path) async {
    Uint8List result = await _getSilhouette(path);
    if (_firstTime) {
      await Future.delayed(Duration(seconds: 1));
    }
    _firstTime = false;
    return result;
  }

  Future<void> _loadImages() async {
    _images = _imagePaths.map((path) => Image.network(path)).toList();
    await Future.wait(_images.map((image) => _loadImage(image)));

    _randomImages = getRandomElements(_images, nElements);
    setState(() {});
    _animationController.forward(from: 0);
    _spinAnimation();
  }

  Future<void> _loadImage(Image image) {
    final Completer<void> completer = Completer();
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool synchronousCall) {
        completer.complete();
      }),
    );
    return completer.future;
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

  void _showResult() async {
    final double normalizedAngle = (_currentAngle % (2 * pi));
    final double segmentAngle = (2 * pi / _segments);
    _segmentIndex =
        (_segments + (normalizedAngle / segmentAngle).floor()) % _segments;

    _visible = true;
    setState(() {});
    _intentos++;
    // int colorSeleccionado = _colorList.indexWhere(
    //     (color) => color.contains(_sensores.colorSeleccionado.toLowerCase()));

    // if (_ledOn && colorSeleccionado != _segmentIndex) {
    //   _segmentIndex = colorSeleccionado;
    // }

    if (_randomNum == _segmentIndex) {
      _aciertos++;
      await _sensoresRef.update({"puntaje": _aciertos});
    } else {
      _fallos++;
    }
    addColorsGame(_colorList[_randomNum], _colorList[_segmentIndex],
        _randomNum == _segmentIndex);
    Future.delayed(const Duration(seconds: 2), () {
      _animationController.forward(from: 0);
      getRandomInt();
      randomElements();
      _visible = false;
    });
  }

  List<Widget> _buildPositionedImages() {
    List<Widget> positionedImages = [];
    final int imageCount = _randomImages.length;
    final double centerX = 175; // half of the container width
    final double centerY = 175; // half of the container height
    final double radius = 120; // radius of the circle

    for (int i = 0; i < imageCount; i++) {
      final double angle = ((2 * pi * i) / imageCount) + (pi / 6);
      final double x = centerX + radius * cos(angle);
      final double y = centerY + radius * sin(angle);

      positionedImages.add(
        Positioned(
          left: x - 50, // Adjust the offset to center the image
          top: y - 50, // Adjust the offset to center the image
          width: 100,
          height: 100,
          child: _randomImages[i],
        ),
      );
    }

    return positionedImages;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    if (_images.isEmpty) {
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
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

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
                    _speak();
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
                onPressed: _speak,
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
                left: 10,
                bottom: 10,
                child: InkWell(
                  onTap: _speak,
                  child: Image.asset(
                    'assets/robot.gif',
                    width: width * .25,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
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
                    const SizedBox(height: 35),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: CircularProgressIndicator(
                        backgroundColor: _colors[_randomNum],
                        color: Colors.grey,
                        value: _animationController.value,
                        strokeWidth: 40.0,
                      ),
                    ),
                    if (_randomImages.isNotEmpty)
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: _animationController.isAnimating
                                ? _stopAnimation
                                : _spinAnimation,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: Size(350, 350),
                                  painter: RuletaPainter(0.0, 6, _colors, []),
                                ),
                                ..._buildPositionedImages(),
                                Transform.rotate(
                                  angle: _currentAngle,
                                  child: Image.asset(
                                    'assets/flecha.png',
                                    width: 225,
                                    height: 225,
                                  ),
                                ),
                                Visibility(
                                  visible: _visible,
                                  child: Image.asset(
                                    _segmentIndex == _randomNum
                                        ? 'assets/check.png'
                                        : 'assets/fail.webp',
                                    width: 350,
                                    height: 350,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  void openBox() {
    BuildContext dialogContext;
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Fin del juego',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Para enviar los resultados y regresar al menú principal, presiona el boton finalizar',
                    ),
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
        );
      },
    );
  }

  void addGameProgress() async {
    final playerProgressNotifier = Provider.of<PlayerProgressNotifier>(
      context,
      listen: false,
    );

    PlayerProgress playerProgress = PlayerProgress(
      userId: _user!.uid,
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
      userId: _user!.uid,
      selectedColor: selectedColor,
      correctColor: correctColor,
      success: success,
      timestamp: DateTime.now(),
    );

    colorsGameNotifier.addColorsGame(colorsGame);
  }
}

Future<Uint8List> _getSilhouette(String path) async {
  // Load the image from network

  http.Response response = await http.get(Uri.parse(path));

  img.Image? image = img.decodeImage(response.bodyBytes);

  // Convert to grayscale
  image = img.grayscale(image!);

  // Apply thresholding to obtain silhouette
  img.contrast(image, contrast: 0);

  // Convert to bytes
  return Uint8List.fromList(img.encodePng(image));
}

Future<Uint8List> _getShadow(String path) async {
  // Load the image from network
  img.Image? image =
      img.decodeImage((await rootBundle.load(path)).buffer.asUint8List());

  // Convert to grayscale
  image = img.grayscale(image!);

  // Apply thresholding to obtain silhouette
  img.luminanceThreshold(image);

  // Convert to bytes
  return Uint8List.fromList(img.encodePng(image));
}
