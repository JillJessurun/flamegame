import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:my_flame_game/player.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

class Munchylax extends FlameGame with KeyboardEvents {
  late Player player;
  Set<LogicalKeyboardKey> keysPressed = {};  // Track keys that are pressed

  @override
  Future<void> onLoad() async {
    super.onLoad();
    player = Player(Vector2(size.x / 2, size.y - 55)); // Center bottom of the screen
    add(player); // Add player to the game
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move the player based on the keys currently pressed
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyA)) {
      player.position.x -= 15; // Move left
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD)) {
      player.position.x += 15; // Move right
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      // Add only the key that was pressed
      this.keysPressed.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      // Remove only the key that was released
      this.keysPressed.remove(event.logicalKey);
    }

    return KeyEventResult.handled; // Handle the event
  }
}
