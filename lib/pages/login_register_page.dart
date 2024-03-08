import 'package:flutter/material.dart';
import 'package:cognitiveroulletegame/pages/login_page.dart';
import 'package:cognitiveroulletegame/pages/register_page.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
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
