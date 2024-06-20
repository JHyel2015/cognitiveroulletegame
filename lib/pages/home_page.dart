// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/pages/auth_page.dart';
import 'package:cognitiveroulletegame/pages/discovery_page.dart';
import 'package:cognitiveroulletegame/pages/diviner_page.dart';
import 'package:cognitiveroulletegame/pages/settings_page.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

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
  final UserPreferences _userPreferences = UserPreferences();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  bool _btnActive = false;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  @override
  void initState() {
    super.initState();

    _getCurrentUser();
    _initConnectivity();
    _subscribeToConnectivityChanges();

    // FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
    // // Get current state
    // FlutterBluetoothSerial.instance.state.then((state) {
    //   setState(() {
    //     _bluetoothState = state;
    //   });
    // });

    // Future.doWhile(() async {
    //   // Wait if adapter not enabled
    //   var isOn = await FlutterBluetoothSerial.instance.isEnabled;
    //   if (isOn != null && isOn) {
    //     return false;
    //   }
    //   await Future.delayed(Duration(milliseconds: 0xDD));
    //   return true;
    // }).then((_) {
    //   // Update the address field
    //   FlutterBluetoothSerial.instance.address.then((address) {
    //     setState(() {
    //       if (address != null) {
    //         _address = address;
    //       }
    //     });
    //   });
    // });

    // FlutterBluetoothSerial.instance.name.then((name) {
    //   setState(() {
    //     if (name != null) {
    //       _name = name;
    //     }
    //   });
    // });

    // // Listen for futher state changes
    // FlutterBluetoothSerial.instance
    //     .onStateChanged()
    //     .listen((BluetoothState state) {
    //   setState(() {
    //     _bluetoothState = state;
    //   });
    // });
  }

  // @override
  // void dispose() {
  //   FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
  //   super.dispose();
  // }

  void _getCurrentUser() {
    User? user = _auth.currentUser;
    setState(() {
      _user = user;
    });
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

  void signUserOut() {
    FirebaseAuth.instance.signOut();
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
                      // () async {
                      //   final BluetoothDevice selectedDevice =
                      //       await Navigator.of(context).push(
                      //     MaterialPageRoute(
                      //       builder: (context) {
                      //         return DiscoveryPage();
                      //       },
                      //     ),
                      //   );

                      //   if (selectedDevice != null) {
                      //     print('Discovery -> selected ' +
                      //         selectedDevice.address);
                      //   } else {
                      //     print('Discovery -> no device selected');
                      //   }
                      // },
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
                left: (MediaQuery.of(context).size.width / 2) - 50,
                top: 10,
                child: Image.asset(
                  'assets/EPN.png',
                  height: 100,
                  width: 100,
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: Image.asset(
                  'assets/polhibou.png',
                  height: 100,
                  width: 100,
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Image.asset(
                  'assets/FIS.png',
                  height: 100,
                  width: 100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
