import 'dart:io';

import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/data/colors_game_notifier.dart';
import 'package:cognitiveroulletegame/data/player_progress_notifier.dart';
import 'package:cognitiveroulletegame/data/user_notifier.dart';
import 'package:cognitiveroulletegame/models/user_data.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:cognitiveroulletegame/widgets/custom_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  void Function()? onPressed;

  RegisterPage({super.key, this.onPressed});

  @override
  State<RegisterPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userPreferences = UserPreferences();

  final emailController = TextEditingController();
  final displayNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  User? _user;

  void signUserUp() async {
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

    // try creating user
    try {
      if (passwordController.text == confirmPasswordController.text) {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
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

          await user.updateDisplayName(displayNameController.text);
          await user.reload();

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
      } else {
        Navigator.pop(context);
        showErrorMessage('Las contraseñas no coinciden');
      }
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

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

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
                  const Text(
                    'Cognitive Game',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Vamos a crear una cuenta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  CustomTextFormField(
                    controller: displayNameController,
                    labelText: 'Nombre de usuario',
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    controller: confirmPasswordController,
                    labelText: 'Confirmar contraseña',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  const Padding(
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
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: kColorPrimary,
                    ),
                    onPressed: signUserUp,
                    child: Text(
                      'Registrarse',
                      style: TextStyle(color: kColorSecondary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          side: BorderSide(width: 1.0, color: kColorPrimary),
                        ),
                        onPressed: signUserWithGoogle,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/google.png',
                                height: 25, width: 25),
                            const SizedBox(width: 10),
                            const Text(
                              'Ingresar con Google',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          side: BorderSide(width: 1.0, color: kColorPrimary),
                        ),
                        onPressed: signInAnonymously,
                        child: const Text(
                          'Ingresar como invitado',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Ya tienes cuenta?'),
                      const SizedBox(height: 4),
                      CupertinoButton(
                        onPressed: widget.onPressed,
                        child: const Text('Inicia sesión ahora'),
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
