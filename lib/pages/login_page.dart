import 'dart:io';

import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/data/colors_game_notifier.dart';
import 'package:cognitiveroulletegame/data/player_progress_notifier.dart';
import 'package:cognitiveroulletegame/data/user_notifier.dart';
import 'package:cognitiveroulletegame/models/player_progress.dart';
import 'package:cognitiveroulletegame/models/user_data.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:cognitiveroulletegame/widgets/custom_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  void Function()? onPressed;

  LoginPage({super.key, this.onPressed});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userPreferences = UserPreferences();

  User? _user;

  void signUserIn() async {
    String? storedUID = userPreferences.storedUID;
    final userNotifier = Provider.of<UserNotifier>(context, listen: false);
    final colorsGameNotifier = Provider.of<ColorsGameNotifier>(
      context,
      listen: false,
    );
    final playerProgressNotifier = Provider.of<PlayerProgressNotifier>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      User? user = userCredential.user;

      Navigator.pop(context);

      if (user != null) {
        if (storedUID != user.uid && !userPreferences.isAnonymous) {
          colorsGameNotifier.clearData();
          playerProgressNotifier.clearData();
        }
        setState(() {
          _user = _auth.currentUser;
        });
        userPreferences.storedUID = _user!.uid;
        userPreferences.isAnonymous = _user!.isAnonymous;

        UserData userData = UserData(
          uid: _user!.uid,
          name: _user!.displayName ?? '',
          displayName: _user!.displayName ?? '',
          email: _user!.email!,
          phoneNumber: _user!.phoneNumber ?? '',
          photoURL: _user!.photoURL ?? '',
          timestamp: DateTime.now(),
        );
        userNotifier.addUser(userData);
      }
      print(_user!.isAnonymous);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      showErrorMessage(e.code);
    }
  }

  void signUserWithGoogle() async {
    String? storedUID = userPreferences.storedUID;
    final userNotifier = Provider.of<UserNotifier>(context, listen: false);
    final colorsGameNotifier = Provider.of<ColorsGameNotifier>(
      context,
      listen: false,
    );
    final playerProgressNotifier = Provider.of<PlayerProgressNotifier>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await InternetAddress.lookup('google.com');

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      // GoogleAuthProvider googlePxrovider = GoogleAuthProvider();

      // UserCredential userCredential =
      //     await _auth.signInWithProvider(googleProvider);

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      User? user = userCredential.user;

      Navigator.pop(context);

      if (user != null) {
        if (storedUID != user.uid && !userPreferences.isAnonymous) {
          colorsGameNotifier.clearData();
          playerProgressNotifier.clearData();
        }
        setState(() {
          _user = _auth.currentUser;
        });
        userPreferences.storedUID = _user!.uid;
        userPreferences.isAnonymous = _user!.isAnonymous;

        UserData userData = UserData(
          uid: _user!.uid,
          name: _user!.displayName ?? '',
          displayName: _user!.displayName ?? '',
          email: _user!.email!,
          phoneNumber: _user!.phoneNumber ?? '',
          photoURL: _user!.photoURL ?? '',
          timestamp: DateTime.now(),
        );
        userNotifier.addUser(userData);
      }
      print(_user!.isAnonymous);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      showErrorMessage(e.code);
    }
  }

  void signInAnonymously() async {
    String? storedUID = userPreferences.storedUID;
    final colorsGameNotifier = Provider.of<ColorsGameNotifier>(
      context,
      listen: false,
    );
    final playerProgressNotifier = Provider.of<PlayerProgressNotifier>(
      context,
      listen: false,
    );

    print(storedUID);

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      Navigator.pop(context);

      User? user = userCredential.user;
      print(user);

      if (user != null) {
        if (storedUID != user.uid) {
          colorsGameNotifier.clearData();
          playerProgressNotifier.clearData();
        }
        setState(() {
          _user = _auth.currentUser;
        });
        userPreferences.storedUID = _user!.uid;
        userPreferences.isAnonymous = _user!.isAnonymous;
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      showErrorMessage(e.code);
    }
  }

  showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Center(
            child: Text(
              message,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kColorSecondary,
      child: SafeArea(
        child: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Image.asset('assets/splash.gif', height: 99, width: 99),
                  const SizedBox(height: 20),
                  Text(
                    'Cognitive Game',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Text(
                    'Bienvenido de vuelta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  CustomTextFormField(
                    controller: emailController,
                    labelText: 'Correo electrónico',
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    controller: passwordController,
                    labelText: 'Contraseña',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('¿Olvidaste tu contraseña?'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                      backgroundColor: kColorPrimary,
                    ),
                    onPressed: signUserIn,
                    child: Text(
                      'Iniciar sesión',
                      style: TextStyle(color: kColorSecondary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        style: TextButton.styleFrom(
                          minimumSize: Size.fromHeight(50),
                          side: BorderSide(width: 1.0, color: kColorPrimary),
                        ),
                        onPressed: signUserWithGoogle,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/google.png',
                                height: 25, width: 25),
                            const SizedBox(width: 10),
                            Text(
                              'Ingresar con Google',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        style: TextButton.styleFrom(
                          minimumSize: Size.fromHeight(50),
                          side: BorderSide(width: 1.0, color: kColorPrimary),
                        ),
                        onPressed: signInAnonymously,
                        child: Text(
                          'Ingresar como invitado',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('¿No tienes cuenta?'),
                      const SizedBox(height: 4),
                      CupertinoButton(
                        onPressed: widget.onPressed,
                        child: Text('Regístrate ahora'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
