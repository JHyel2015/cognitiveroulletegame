// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/pages/auth_page.dart';
import 'package:cognitiveroulletegame/pages/home_page.dart';
import 'package:cognitiveroulletegame/shared/function.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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
  // PageController
  final _controller = PageController(viewportFraction: 0.8);
  // TextController

  final user = FirebaseAuth.instance.currentUser;
  final DataSource dataSource = DataSource();
  int isTappedOut = 0;
  int isCorrect = 0;
  int randomNum = 0;
  int scoreMax = 4;
  int currentScore = 0;

  bool _btnActive = false;

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
    await dataSource.speak(widget.textToSpeak);
  }

  @override
  void initState() {
    super.initState();

    _speak();
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    void getRandomInt() {
      final random = Random();
      int number = random.nextInt(4);
      setState(() {
        randomNum = number;
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      body: SafeArea(
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
            Text(
              'Puntaje',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '${currentScore}/${scoreMax}',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 15),
            FutureBuilder<Uint8List>(
              future: _getSilhouette('assets/dress.webp'),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(
                    snapshot.data!,
                    width: 150,
                    height: 150,
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            const SizedBox(height: 15),
            Expanded(
              child: GridView.count(
                crossAxisSpacing: 5,
                crossAxisCount: 2,
                children: [
                  InkWell(
                    onTap: () {},
                    child: Image.asset(
                      'assets/roulette.png',
                      width: width * .5,
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Image.asset(
                      'assets/dress.webp',
                      width: width * .5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Column(
            //       children: [
            //         Text('Seleccionaste'),
            //         InkWell(
            //           onTap: () {
            //             // isTappedOut = 1;

            //             // if (colorList[randomNum] == _currentColor) {
            //             //   setState(() {
            //             //     isCorrect = 1;
            //             //     currentScore += 1;
            //             //     if (currentScore == scoreMax) {
            //             //       currentScore = 0;
            //             //     }
            //             //   });
            //             //   getRandomInt();
            //             // }
            //           },
            //           child: Container(
            //             width: 125.0,
            //             height: 125.0,
            //             decoration: BoxDecoration(
            //               color: _currentColor,
            //               shape: BoxShape.circle,
            //             ),
            //           ),
            //         )
            //       ],
            //     ),
            //     const SizedBox(width: 15),
            //     Container(
            //       width: 150.0,
            //       height: 150.0,
            //       decoration: BoxDecoration(
            //         color: colorList[randomNum],
            //         shape: BoxShape.circle,
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 25),
            // if (isCorrect == 1)
            //   Center(
            //     child: Text('CORRECTO'),
            //   ),
            const SizedBox(height: 15),
            Image.asset(
              'assets/robot.gif',
              width: width * .25,
            ),
            const SizedBox(height: 15),
            IconButton(
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
            )
          ],
        ),
      ),
    );
  }
}

Future<Uint8List> _getSilhouette(String path) async {
  // Load the image from network
  img.Image? image =
      img.decodeImage((await rootBundle.load(path)).buffer.asUint8List());

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
