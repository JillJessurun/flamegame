import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'go_green.dart';

void main() {
  final game = GoGreen();
  runApp(GameWidget(game: game));
}