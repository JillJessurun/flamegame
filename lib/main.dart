import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:my_flame_game/munchylax.dart';

void main() {
   runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(game: Munchylax()),
      ),
    ),
  );
}