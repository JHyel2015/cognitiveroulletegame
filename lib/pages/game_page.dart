// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/pages/diviner_page.dart';
import 'package:cognitiveroulletegame/pages/home_page.dart';
import 'package:cognitiveroulletegame/services/speaker_service.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import 'package:image/image.dart' as img;
import 'package:flutter_image_filters/flutter_image_filters.dart';
import 'package:intl/intl.dart';

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

class _GamePageState extends State<GamePage> {
  Stopwatch _stopwatch = Stopwatch();
  Color _currentColor = Colors.blue; // Color inicial
  Timer? _timer;
  String _connectionStatus = 'Unknown';
  int nElements = 3;
  final commentController = TextEditingController();
  // PageController
  final _controller = PageController(viewportFraction: 0.8);
  // TextController
  final UserPreferences userPreferences = UserPreferences();

  final user = FirebaseAuth.instance.currentUser;
  final SpeakerService speakerService = SpeakerService();
  int isTappedOut = 0;
  int isCorrect = 0;
  int randomNum = 0;
  int scoreMax = 4;
  int currentScore = 0;
  int selectedItem = -1;

  int intentos = 0;
  int aciertos = 0;
  int fallos = 0;

  bool _btnActive = false;
  bool _visible = false;
  bool _firstTime = true;

  late Duration elapsedTime;

  int time = 0;

  List<String> fileURLs = [];
  List<String> randomFileURLs = [];

  List<Color> colorList = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
  ];

  late TextureSource texture;
  late BrightnessShaderConfiguration configuration;
  bool textureLoaded = false;

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
        fileURLs.add(downloadURL);
      }
      randomFileURLs = getRandomElements(fileURLs, nElements);
      setState(() {});
    } catch (e) {
      print('Error al obtener los archivos del bucket de Firebase Storage: $e');
    }
  }

  List<T> getRandomElements<T>(List<T> list, int n) {
    list.shuffle();
    return list.take(n).toList();
  }

  @override
  void initState() {
    super.initState();

    _speak();
    _getFiles();
    _initConnectivity();
    _subscribeToConnectivityChanges();
    // Iniciar el temporizador
    // _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    //   _changeColor(); // Cambiar el color cada n segundos
    // });

    configuration = BrightnessShaderConfiguration();
    configuration.brightness = 0.5;
    TextureSource.fromAsset('assets/roulette.png')
        .then((value) => texture = value)
        .whenComplete(
          () => setState(() {
            textureLoaded = true;
          }),
        );

    getRandomInt();
    _stopwatch.start();
    time = userPreferences.time;
    Future.delayed(Duration(seconds: time), () {
      print('Se cumplio el tiempo');
      openBox();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelar el temporizador al salir de la pantalla
    _stopwatch.stop();
    super.dispose();
  }

  void _changeColor() {
    setState(() {
      // Cambiar el color a un color aleatorio
      _currentColor = _getRandomColor();
    });
  }

  Color _getRandomColor() {
    // Generar un color aleatorio
    final Random random = Random();
    return colorList[random.nextInt(4)];
  }

  Future<void> _initConnectivity() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _subscribeToConnectivityChanges() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      switch (result) {
        case ConnectivityResult.wifi:
          _connectionStatus = 'Conectado a Wi-Fi';
          break;
        case ConnectivityResult.mobile:
          _connectionStatus = 'Conectado a datos móviles';
          break;
        case ConnectivityResult.none:
          _connectionStatus = 'Sin conexión a Internet';
          break;
        default:
          _connectionStatus = 'Desconocido';
          break;
      }
    });
  }

  void getRandomInt() {
    final random = Random();
    int number = random.nextInt(3);
    setState(() {
      randomNum = number;
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

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
                    const SizedBox(height: 15),
                    if (randomFileURLs.isNotEmpty)
                      Expanded(
                        child: GridView.count(
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 5,
                          crossAxisCount: 2,
                          children: [
                            FutureBuilder<Uint8List>(
                              future: _loadIamges(randomFileURLs[randomNum]),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                            ...randomFileURLs.asMap().map(
                              (i, e) {
                                return MapEntry(
                                  i,
                                  Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _visible = true;
                                            if (randomNum == i) {
                                              aciertos++;
                                            } else {
                                              fallos++;
                                            }
                                            selectedItem = i;
                                            intentos++;
                                          });
                                          Future.delayed(Duration(seconds: 1),
                                              () {
                                            print('siguiente imagen');
                                            randomFileURLs = getRandomElements(
                                                fileURLs, nElements);
                                            getRandomInt();
                                            _visible = false;
                                            selectedItem = -1;
                                            setState(() {});
                                            // openBox();
                                          });
                                        },
                                        child: CachedNetworkImage(
                                          imageUrl: e,
                                        ),
                                      ),
                                      Visibility(
                                        visible: _visible && selectedItem == i,
                                        child: Image.asset(i == randomNum
                                            ? 'assets/check.png'
                                            : 'assets/fail.webp'),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ).values,
                          ],
                        ),
                      ),
                  ],
                ),
              ),
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
              Positioned(
                bottom: 10,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: kColorPrimary,
                  ),
                  onPressed: () {
                    elapsedTime = _stopwatch.elapsed;
                    time = elapsedTime.inSeconds;
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
                                  'Tiempo ${Duration(seconds: time).toString().split('.')[0].substring(2)}'),
                            ),
                            Chip(
                              //avatar: Icon(Icons.sunny),
                              label: Text('Aciertos ${aciertos.toString()}'),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Chip(
                              //avatar: Icon(Icons.sunny),
                              label: Text('Intentos ${intentos.toString()}'),
                            ),
                            Chip(
                              //avatar: Icon(Icons.sunny),
                              label: Text('Fallos ${fallos.toString()}'),
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
