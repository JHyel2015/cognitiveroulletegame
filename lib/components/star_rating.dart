import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int attempts;
  final int correctAnswers;

  StarRating({required this.attempts, required this.correctAnswers});

  int getStarCount() {
    if (attempts == 0) {
      return 0;
    }
    if (correctAnswers == attempts) {
      return 3; // Todas las estrellas
    } else if (correctAnswers >= attempts / 2) {
      return 2; // Dos estrellas
    } else if (correctAnswers > 0) {
      return 1; // Una estrella
    } else {
      return 0; // Cero estrellas
    }
  }

  @override
  Widget build(BuildContext context) {
    int starCount = getStarCount();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Icon(
              index < starCount
                  ? Icons.star_rounded
                  : ((starCount == 0 && index == starCount)
                      ? Icons.star_half_rounded
                      : Icons.star_border_rounded), // Rellena según el puntaje
              color: Colors.yellow,
              size: 100,
            ),
            Icon(
              Icons.star_outline_rounded, // Rellena según el puntaje
              color: Colors.amber[900],
              size: 100,
            ),
          ],
        );
      }),
    );
  }
}
