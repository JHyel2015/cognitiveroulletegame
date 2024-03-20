// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';

import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/pages/auth_page.dart';
import 'package:cognitiveroulletegame/pages/home_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

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

  @override
  void initState() {
    super.initState();

    _initConnectivity();
    _subscribeToConnectivityChanges();
    // Iniciar el temporizador
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _changeColor(); // Cambiar el color cada n segundos
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

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    void getRandomInt() {
      final random = Random();
      int number = random.nextInt(4);
      setState(() {
        randomNum = number;
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 25),
            Text(
              'Puntaje',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '${currentScore}/${scoreMax}',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text('Seleccionaste'),
                    InkWell(
                      onTap: () {
                        isTappedOut = 1;

                        if (colorList[randomNum] == _currentColor) {
                          setState(() {
                            isCorrect = 1;
                            currentScore += 1;
                            if (currentScore == scoreMax) {
                              currentScore = 0;
                            }
                          });
                          getRandomInt();
                        }
                      },
                      child: Container(
                        width: 125.0,
                        height: 125.0,
                        decoration: BoxDecoration(
                          color: _currentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 15),
                Container(
                  width: 150.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    color: colorList[randomNum],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            // if (isCorrect == 1)
            //   Center(
            //     child: Text('CORRECTO'),
            //   ),
            const SizedBox(height: 15),
            Image.asset('assets/robot.gif'),
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
