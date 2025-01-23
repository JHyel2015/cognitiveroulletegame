import 'package:flutter/material.dart';

import 'package:cognitiveroulletegame/constans.dart';

class GameCard extends StatelessWidget {
  final Color color;
  final String? name;
  final String image;
  final Function() onPressed;

  const GameCard({
    super.key,
    required this.color,
    this.name,
    required this.image,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name ?? '',
            style: TextStyle(fontSize: 25, color: kColorSecondary),
          ),
          InkWell(
            onTap: onPressed,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.fitWidth,
                ),
                color: color,
                borderRadius: BorderRadius.circular(25),
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
