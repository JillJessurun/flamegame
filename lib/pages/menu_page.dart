import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flame_game/bloc/app_bloc.dart';
import 'package:my_flame_game/bloc/bloc_events.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appBloc = context.read<AppBloc>();

    return Scaffold(
      body: Stack(
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
              padding: const EdgeInsets.only(bottom: 250, left: 150),
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
              padding: const EdgeInsets.only(top: 200, left: 278),
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
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 80,
              height: 50,
              child: FloatingActionButton(
                onPressed: () {
                  appBloc.add(GoToGame());
                },
                backgroundColor: const Color.fromARGB(255, 7, 101, 129),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Go!',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'pokemon',
                    letterSpacing: 5.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
