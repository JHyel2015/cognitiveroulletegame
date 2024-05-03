import 'package:flutter/material.dart';

import 'package:cognitiveroulletegame/constans.dart';

class GameCard extends StatelessWidget {
  final Color color;
  final String name;
  final Function() onPressed;

  const GameCard({
    required this.color,
    required this.name,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: onPressed,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: this.color,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(this.name),
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: kColorPrimary,
            ),
            onPressed: onPressed,
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: kColorSecondary,
                  ),
                  Text(
                    'Jugar',
                    style: TextStyle(color: kColorSecondary),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
