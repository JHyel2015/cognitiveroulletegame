// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/data/colors_game_notifier.dart';
import 'package:cognitiveroulletegame/data/player_progress_notifier.dart';
import 'package:cognitiveroulletegame/data/user_notifier.dart';
import 'package:cognitiveroulletegame/pages/auth_page.dart';
import 'package:cognitiveroulletegame/pages/diviner_page.dart';
import 'package:cognitiveroulletegame/pages/settings_page.dart';
import 'package:cognitiveroulletegame/services/sync_service.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // PageController
  final _controller = PageController(viewportFraction: 0.8);
  // TextController
  final UserPreferences _userPreferences = UserPreferences();
  final SyncService syncService = SyncService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late FirebaseApp _secondaryApp;
  late FirebaseDatabase _databaseReference;
  late StreamSubscription<DatabaseEvent> _ledOnSubscription;
  late DatabaseReference _ledOnRef;
  User? _user;

  bool _ledOn = false;

  bool _btnActive = false;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  @override
  void initState() {
    super.initState();

    init();
    _getCurrentUser();
    if (!_user!.isAnonymous) {
      syncService.syncPlayerProgressData();
      syncService.syncColorsGameData();
    }
  }

  Future<void> init() async {
    _secondaryApp = Firebase.app('esp32colores');
    _databaseReference = FirebaseDatabase.instanceFor(
      app: _secondaryApp,
      databaseURL: 'https://esp32colores-default-rtdb.firebaseio.com',
    );

    _ledOnRef = _databaseReference.ref('EstadoLED');

    _databaseReference.setPersistenceEnabled(true);
    _databaseReference.setPersistenceCacheSizeBytes(10000000);

    await _ledOnRef.keepSynced(true);

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
          _userPreferences.isLedOn = _ledOn;
          print(event.snapshot.value);
        });
      },
    );
    final userNotifier = Provider.of<UserNotifier>(context, listen: false);
  }

  void _getCurrentUser() {
    User? user = _auth.currentUser;
    setState(() {
      _user = user;
    });
  }

  Future<void> signUserOut() async {
    final colorsGameNotifier = Provider.of<ColorsGameNotifier>(
      context,
      listen: false,
    );
    final playerProgressNotifier = Provider.of<PlayerProgressNotifier>(
      context,
      listen: false,
    );
    final userNotifier = Provider.of<UserNotifier>(context, listen: false);

    if (_user!.isAnonymous) {
      await _user?.delete();
    }

    _auth.signOut();

    colorsGameNotifier.clearData();
    playerProgressNotifier.clearData();
    userNotifier.clearData();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    _userPreferences.isAnonymous = _user != null ? _user!.isAnonymous : false;

    return Container(
      color: kColorSecondary,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: signUserOut,
                icon: Icon(
                  Icons.logout,
                  color: kColorPrimary,
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Cognitive Game',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    Image.asset('assets/splash.gif', height: 300, width: 300),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: kColorPrimary,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // builder: (context) => LevelsPage(),
                            builder: (context) => DivinerPage(),
                          ),
                        );
                      },
                      label: Text(
                        'Jugar',
                        style: TextStyle(color: kColorSecondary),
                      ),
                      icon: Icon(
                        Icons.play_arrow,
                        color: kColorSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: kColorPrimary,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // builder: (context) => LevelsPage(),
                            builder: (context) => SettingsPage(),
                          ),
                        );
                      },
                      label: Text(
                        'Ajustes',
                        style: TextStyle(color: kColorSecondary),
                      ),
                      icon: Icon(
                        Icons.settings,
                        color: kColorSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: kColorPrimary,
                      ),
                      onPressed: () {},
                      label: Text(
                        'Historial',
                        style: TextStyle(color: kColorSecondary),
                      ),
                      icon: Icon(
                        Icons.list,
                        color: kColorSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: (MediaQuery.of(context).size.width / 2) - 75,
                top: 10,
                child: Image.asset(
                  'assets/EPN.png',
                  height: 150,
                  width: 150,
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: Image.asset(
                  'assets/polhibou.png',
                  height: 150,
                  width: 150,
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Image.asset(
                  'assets/FIS.png',
                  height: 150,
                  width: 150,
                ),
              ),
              Positioned(
                left: (MediaQuery.of(context).size.width / 2) - 50,
                bottom: 10,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(
                      color: _ledOn ? Colors.green : Colors.orange,
                      width: 2.0,
                    ),
                  ),
                  child: Text(
                    'Prototipo \n${_ledOn ? 'CONECTADO' : 'DESCONECTADO'}',
                    textAlign: TextAlign.center,
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
