import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flame_game/bloc/app_bloc.dart';
import 'package:my_flame_game/bloc/bloc_events.dart';
import 'package:my_flame_game/game_class/munchylax.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Munchylax _game;

  @override
  void initState() {
    super.initState();
    _game = Munchylax(context);
    _game.startGame(); // call the startGame method when entering the page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          // exit Button
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 20),
            child: Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 50,
                height: 50,
                child: FloatingActionButton(
                  onPressed: () {
                    context.read<AppBloc>().add(GoToMenu());
                  },
                  backgroundColor: const Color.fromARGB(255, 7, 101, 129),
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
