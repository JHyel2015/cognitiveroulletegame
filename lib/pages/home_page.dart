// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cognitiveroulletegame/constans.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _connectionStatus = 'Unknown';
  // PageController
  final _controller = PageController(viewportFraction: 0.8);
  // TextController

  final user = FirebaseAuth.instance.currentUser;

  bool _btnActive = false;

  @override
  void initState() {
    super.initState();

    _initConnectivity();
    _subscribeToConnectivityChanges();
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 25),
            Text(
              'Cognitive Game',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            Image.asset('assets/splash.gif'),
            Text(
              'Puntaje más alto',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              '10',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: kColorPrimary,
              ),
              onPressed: () {},
              child: Text(
                'JUGAR',
                style: TextStyle(color: kColorSecondary),
              ),
            ),
            const SizedBox(height: 10),
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
