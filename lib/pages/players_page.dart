import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/data/colors_game_notifier.dart';
import 'package:cognitiveroulletegame/data/player_notifier.dart';
import 'package:cognitiveroulletegame/data/player_progress_notifier.dart';
import 'package:cognitiveroulletegame/data/user_notifier.dart';
import 'package:cognitiveroulletegame/models/player_data.dart';
import 'package:cognitiveroulletegame/pages/auth_page.dart';
import 'package:cognitiveroulletegame/pages/diviner_page.dart';
import 'package:cognitiveroulletegame/pages/historial_page.dart';
import 'package:cognitiveroulletegame/pages/home_page.dart';
import 'package:cognitiveroulletegame/pages/settings_page.dart';
import 'package:cognitiveroulletegame/services/snackbar_services.dart';
import 'package:cognitiveroulletegame/services/speaker_service.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  final playerNameController = TextEditingController();
  final playerAgeController = TextEditingController();
  final UserPreferences userPreferences = UserPreferences();
  final SpeakerService speakerService = SpeakerService();

  List<PlayerData> players = [];

  final String _textToSpeak =
      'Hola, soy Ruleto, estás en la pantalla jugadores. Puedes crear varios perfiles de jugador con el boton agregar jugador';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _speak(textToSpeak: _textToSpeak);
    _getCurrentUser();
  }

  @override
  void dispose() {
    super.dispose();
    _stop();
  }

  Future<void> _speak({textToSpeak}) async {
    await speakerService.stop();
    await speakerService.speak(textToSpeak ?? _textToSpeak);
  }

  Future _stop() async {
    await speakerService.stop();
    // setState(() => ttsState = TtsState.stopped);
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

    if (_user != null && _user!.isAnonymous) {
      await _user?.delete();
    }

    _auth.signOut();

    colorsGameNotifier.clearData();
    playerProgressNotifier.clearData();
    userNotifier.clearData();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
    );
  }

  void openBox() {
    BuildContext dialogContext;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Dialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Container(
                height: 300, // Alto del diálogo
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Ingresa el nombre del jugador',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: playerNameController,
                      decoration: InputDecoration(
                        hintText: 'Nombre de jugador',
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2, color: kColorPrimary),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2, color: kColorPrimary),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: playerAgeController,
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: false),
                      decoration: InputDecoration(
                        hintText: 'Edad del jugador',
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2, color: kColorPrimary),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2, color: kColorPrimary),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: kColorSecondary,
                            side: BorderSide(color: kColorPrimary),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          label: Text(
                            'Cancelar',
                            style: TextStyle(color: kColorPrimary),
                          ),
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 15),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: kColorPrimary,
                          ),
                          onPressed: () {
                            addPlayer();
                            Navigator.pop(context);
                          },
                          label: Text(
                            'Agregar',
                            style: TextStyle(color: kColorSecondary),
                          ),
                          icon: Icon(
                            Icons.check,
                            color: kColorSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void addPlayer() async {
    final playerNotifier = Provider.of<PlayerNotifier>(context, listen: false);
    setState(() {});
    PlayerData newPlayerData = PlayerData(
      name: playerNameController.text,
      age: int.tryParse(playerAgeController.text)!,
      userId: _user!.uid,
      timestamp: DateTime.now(),
    );
    String key = playerNameController.text;

    if (!players.any((item) => item.name.toString().contains(key))) {
      await playerNotifier.addPlayer(newPlayerData);
      playerNameController.clear();
      playerAgeController.clear();
      snackbarService.showSnackbar("Jugador $key creado exitosamente",
          backgroundColor: kColorPrimary);
    }
  }

  void deletePlayer(String name) async {
    final playerNotifier = Provider.of<PlayerNotifier>(context, listen: false);
    final colorsGameNotifier =
        Provider.of<ColorsGameNotifier>(context, listen: false);
    final playerProgressNotifier =
        Provider.of<PlayerProgressNotifier>(context, listen: false);
    PlayerData playerData = await playerNotifier.getPlayerByName(name);
    await colorsGameNotifier.deleteColorsGameByPlayerId(playerData.uid!);
    await playerNotifier.deletePlayer(playerData);
    await playerProgressNotifier
        .deletePlayerProgressByPlayerID(playerData.uid!);
    snackbarService.showSnackbar("Jugador $playerData eliminado con éxito",
        backgroundColor: kColorPrimary);
  }

  // Método para mostrar un diálogo de confirmación
  Future<bool> _showConfirmationDialog(BuildContext context, String key) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "¿Estás seguro de que deseas eliminar el jugador \"$key\"?"),
              content: const Text(
                "Recuerda que al eliminar este jugador todo el progreso también se eliminará",
              ),
              actions: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    side: BorderSide(color: kColorPrimary),
                  ),
                  label: Text(
                    "Cerrar",
                    style: TextStyle(color: kColorPrimary),
                  ),
                  icon: Icon(
                    Icons.cancel,
                    color: kColorPrimary,
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Cierra el diálogo y devuelve falso
                  },
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(backgroundColor: Colors.red),
                  label: const Text(
                    "Eliminar",
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Cierra el diálogo y devuelve verdadero
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // Función para mostrar el diálogo de confirmación
  void _showDeleteConfirmationDialog(BuildContext context, String key) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text("¿Estás seguro de que deseas eliminar el jugador \"$key\"?"),
          content: const Text(
            "Recuerda que al eliminar este jugador todo el progreso también se eliminará",
          ),
          actions: [
            TextButton.icon(
              style: TextButton.styleFrom(
                side: BorderSide(color: kColorPrimary),
              ),
              label: Text(
                "Cerrar",
                style: TextStyle(color: kColorPrimary),
              ),
              icon: Icon(
                Icons.cancel,
                color: kColorPrimary,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo sin eliminar
              },
            ),
            TextButton.icon(
              style: TextButton.styleFrom(backgroundColor: Colors.red),
              label: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () {
                // Elimina el item y cierra el diálogo
                setState(() {});
                deletePlayer(key);
                Navigator.of(context).pop();
                snackbarService.showSnackbar("Jugador $key eliminado");
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final playerNotifier = Provider.of<PlayerNotifier>(context);

    players = playerNotifier.players;

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
                    ...players.map(
                      (item) {
                        String key = item.name;
                        return Dismissible(
                          key: Key(key),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await _showConfirmationDialog(context, key);
                          },
                          onDismissed: (direction) {
                            // Elimina el item y cierra el diálogo
                            setState(() {});
                            deletePlayer(item.name);
                            snackbarService
                                .showSnackbar("Jugador $key eliminado");
                          },
                          background: Container(
                            color: Colors.red, // Color de fondo al deslizar
                            alignment:
                                Alignment.centerRight, // Alineado a la derecha
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete,
                                color: Colors.white,
                                size: 30), // Icono de eliminar
                          ),
                          child: Container(
                            width: width * .75,
                            margin: EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                              color: Colors.blue[50], // Otro fondo de ListTile
                              border:
                                  Border.all(color: kColorPrimary, width: 2),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.5), // Color de la sombra
                                  spreadRadius: 2, // Extensión de la sombra
                                  blurRadius: 5, // Difuminado de la sombra
                                  offset: const Offset(
                                      0, 3), // Dirección de la sombra
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                key,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kColorPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // Muestra el diálogo de confirmación
                                  _showDeleteConfirmationDialog(context, key);
                                },
                              ),
                              onTap: () {
                                playerNotifier.selectProfile(item);
                                userPreferences.playerName = item.name;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomePage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: width * .40,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: kColorPrimary,
                        ),
                        onPressed: () {
                          openBox();
                        },
                        label: Text(
                          'Agregar jugador',
                          style: TextStyle(color: kColorSecondary),
                        ),
                        icon: Icon(
                          Icons.add,
                          color: kColorSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: width * .4,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: kColorPrimary,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // builder: (context) => LevelsPage(),
                              builder: (context) => const SettingsPage(),
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
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: width * .4,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: kColorPrimary,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // builder: (context) => LevelsPage(),
                              builder: (context) => HistorialPage(
                                playerName: '',
                              ),
                            ),
                          );
                        },
                        label: Text(
                          'Historial',
                          style: TextStyle(color: kColorSecondary),
                        ),
                        icon: Icon(
                          Icons.list,
                          color: kColorSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: Image.asset(
                  'assets/EPN.png',
                  height: 150,
                  width: 150,
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Image.asset(
                  'assets/FIS.png',
                  height: 150,
                  width: 150,
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: InkWell(
                  onTap: _speak,
                  child: Hero(
                    tag: 'robot',
                    child: Image.asset(
                      'assets/robot.gif',
                      width: width * .40,
                    ),
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

// Formateador personalizado para convertir texto a mayúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
