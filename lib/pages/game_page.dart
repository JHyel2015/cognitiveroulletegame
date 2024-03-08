// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';

import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/pages/auth_page.dart';
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
    return colorList[random.nextInt(5)];
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
    int randomNum = 0;
    int randomNum2 = 0;

    void getRandomInt() {
      final random = Random();
      int number = random.nextInt(5);
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
              'Puntaje',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Column(
                  children: [
                    Text('Seleccionaste'),
                    InkWell(
                      onTap: () {
                        getRandomInt();

                        print(colorList[randomNum] == _currentColor);
                      },
                      child: Container(
                        color: _currentColor,
                        width: 100.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 15),
                Container(
                  color: colorList[randomNum],
                  width: 120.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Image.asset('assets/robot.gif'),
            const SizedBox(height: 25),
            IconButton(
              style: TextButton.styleFrom(
                backgroundColor: kColorPrimary,
              ),
              onPressed: () {},
              icon: Icon(
                Icons.list,
                color: kColorSecondary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
