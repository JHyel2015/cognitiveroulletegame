// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/pages/auth_page.dart';
import 'package:cognitiveroulletegame/pages/home_page.dart';
import 'package:cognitiveroulletegame/services/speaker_service.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

import 'package:image/image.dart' as img;
import 'package:flutter_image_filters/flutter_image_filters.dart';

class GamePage extends StatefulWidget {
  String title;
  String textToSpeak;
  GamePage({
    required this.title,
    required this.textToSpeak,
    super.key,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Color _currentColor = Colors.blue; // Color inicial
  Timer? _timer;
  String _connectionStatus = 'Unknown';
  int nElements = 3;
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

  bool _btnActive = false;

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

    Future.delayed(Duration(seconds: 15), () {
      print('Se cumplio el tiempo');
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelar el temporizador al salir de la pantalla
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
                              future: _getSilhouette(randomFileURLs[randomNum]),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                            ),
                            ...randomFileURLs.map(
                              (e) {
                                return Image.network(e);
                              },
                            ),
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
                child: IconButton(
                  style: TextButton.styleFrom(
                    backgroundColor: kColorPrimary,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.home_outlined,
                    color: kColorSecondary,
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
