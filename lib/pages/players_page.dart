import 'package:cognitiveroulletegame/constans.dart';
import 'package:cognitiveroulletegame/data/colors_game_notifier.dart';
import 'package:cognitiveroulletegame/data/player_progress_notifier.dart';
import 'package:cognitiveroulletegame/data/user_notifier.dart';
import 'package:cognitiveroulletegame/pages/auth_page.dart';
import 'package:cognitiveroulletegame/pages/diviner_page.dart';
import 'package:cognitiveroulletegame/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  List<Widget> players = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    players.add(
      Dismissible(
        key: Key('User1'),
        child: ListTile(
          title: Text('User1'),
          trailing: Icon(Icons.delete),
          onTap: () {},
        ),
        onDismissed: (direction) {
          setState(() {});
          players.removeWhere((item) => item.key.toString().contains('User1'));
        },
      ),
    );

    players.add(
      Dismissible(
        key: Key('User2'),
        child: ListTile(
          title: Text('User2'),
          trailing: Icon(Icons.delete),
          onTap: () {},
        ),
        onDismissed: (direction) {
          setState(() {});
          players.removeWhere((item) => item.key.toString().contains('User2'));
        },
      ),
    );
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
                    ...List.from(players),
                    SizedBox(height: 10),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: kColorPrimary,
                      ),
                      onPressed: () {
                        setState(() {});
                        String key = 'User${players.length + 1}';
                        players.add(
                          Dismissible(
                            key: Key(key),
                            child: ListTile(
                              title: Text(key),
                              trailing: Icon(Icons.delete),
                              onTap: () {},
                            ),
                            onDismissed: (direction) {
                              players.removeWhere(
                                  (item) => item.key.toString().contains(key));
                              setState(() {});
                            },
                          ),
                        );
                      },
                      label: Text(
                        'Agregar usuario',
                        style: TextStyle(color: kColorSecondary),
                      ),
                      icon: Icon(
                        Icons.add,
                        color: kColorSecondary,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: kColorPrimary,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
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
            ],
          ),
        ),
      ),
    );
  }
}
