import 'package:cognitiveroulletegame/constans.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  void Function()? onPressed;

  RegisterPage({super.key, this.onPressed});

  @override
  State<RegisterPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final displayNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUserUp() async {
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
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        User? user = userCredential.user;
        Navigator.pop(context);

        if (user != null) {
          await user.updateDisplayName(displayNameController.text);
          await user.reload();
          user = FirebaseAuth.instance.currentUser;
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
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithProvider(googleProvider);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      showErrorMessage(e.code);
    }
  }

  void signInAnonymously() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInAnonymously();
      Navigator.pop(context);
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset('assets/splash.gif', height: 99, width: 99),
                const SizedBox(height: 25),
                Text(
                  'Cognitive Game',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Vamos a crear una cuenta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: displayNameController,
                  decoration: InputDecoration(
                    hintText: 'Nombre de usuario',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: 'Confirmar contraseña',
                  ),
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
                    Text('¿Ya tienes cuenta?'),
                    const SizedBox(height: 4),
                    CupertinoButton(
                      onPressed: widget.onPressed,
                      child: Text('Inicia sesión ahora'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
