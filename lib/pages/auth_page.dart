import 'package:cognitiveroulletegame/pages/players_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cognitiveroulletegame/pages/home_page.dart';
import 'package:cognitiveroulletegame/pages/login_register_page.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userPreferences = UserPreferences();

    userPreferences.firstTime = false;
    userPreferences.isMute = false;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const PlayersPage();
        } else {
          return const LoginRegisterPage();
        }
      },
    );
  }
}
