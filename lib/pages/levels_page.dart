import 'package:cognitiveroulletegame/constans.dart';
import 'package:flutter/material.dart';

class LevelsPage extends StatefulWidget {
  LevelsPage({Key? key}) : super(key: key);

  @override
  State<LevelsPage> createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Image.asset(
            'assets/niveles.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          Column(
            children: [
              Center(
                child: Text('Hola'),
              ),
              IconButton(
                color: kColorSecondary,
                onPressed: () {},
                icon: Icon(
                  Icons.home,
                  color: kColorPrimary,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
