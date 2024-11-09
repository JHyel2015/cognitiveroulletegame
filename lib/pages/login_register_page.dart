import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/services/snackbar_services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cognitiveroulletegame/pages/login_page.dart';
import 'package:cognitiveroulletegame/pages/register_page.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  String _connectionStatus = 'Desconocido';
  String _connectionStatusPrev = 'Desconocido';
  bool showLoginPage = true;

  @override
  void initState() {
    super.initState();

    _initConnectivity();
    _subscribeToConnectivityChanges();
  }

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
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
    if (_connectionStatus != _connectionStatusPrev) {
      snackbarService.showSnackbar(
        _connectionStatus,
        backgroundColor: kColorPrimary,
      );
    }
    _connectionStatusPrev = _connectionStatus;
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onPressed: togglePages,
      );
    } else {
      return RegisterPage(
        onPressed: togglePages,
      );
    }
  }
}
