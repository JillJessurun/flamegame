import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'munchylax.dart';

void main() {
  final game = Munchylax();

  runApp(
    GameWidget(
      game: game,
      overlayBuilderMap: {
        'Start':
            (context, game) => StartTextOverlay(
              onStart: () {
                (game as Munchylax).overlays.remove('Start');
                game.startGame();
              },
            ),
      },
      initialActiveOverlays: const ['Start'],
    ),
  );
}

class StartTextOverlay extends StatelessWidget {
  final VoidCallback onStart;

  const StartTextOverlay({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/backgroundhome.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 250),
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                padding: EdgeInsets.symmetric(horizontal: 64, vertical: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Start",
                style: TextStyle(
                  fontSize: 36,
                  fontFamily: 'pokemon',
                  letterSpacing: 7.0,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 350, left: 150),
            child: Text(
              "Munchylax",
              style: TextStyle(
                fontSize: 80,
                fontFamily: 'pokemon',
                letterSpacing: 7.0,
                color: Color.fromARGB(255, 255, 254, 223),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 400, left: 278),
            child: Text(
              "GAME CONTROLS\n\n\t\tJump = W\n\t\tLeft = A\n\t\tDown = S\n\t\tRight = D\n\t\tFlip = Enter",
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'pokemon',
                letterSpacing: 5.0,
                color: Color.fromARGB(255, 255, 254, 223),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
