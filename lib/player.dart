import 'package:flame/components.dart';
import 'package:my_flame_game/bomb.dart';
import 'package:my_flame_game/munchylax.dart';
import 'package:flutter/services.dart';
import 'package:flame/collisions.dart';
import 'package:my_flame_game/food.dart';
import 'package:flame_audio/flame_audio.dart';
import 'dart:math';

class Player extends SpriteComponent with HasGameRef<Munchylax>, CollisionCallbacks {
  final double playerWidth = 100;
  final double playerHeight = 110;
  final double playerSizeThreshold = 50;
  final double bobbingHeight = 3;
  final double bobbingSpeed = 50;
  double timeElapsed = 0; // tracks time for sine wave

  late Munchylax munchylaxInstance;

  Player(Vector2 position, Munchylax munchylax) {
    this.position = position;
    munchylaxInstance = munchylax;
    size = Vector2(playerWidth, playerHeight);
    anchor = Anchor.center;
    add(CircleHitbox());
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    //debugMode = true;

    // load player
    sprite = await gameRef.loadSprite('player.png');

    // preload audio to avoid lag
    await FlameAudio.audioCache.load('eating.mp3');
    await FlameAudio.audioCache.load('explosion.mp3');
  }

  @override
  void update(double dt) {
    super.update(dt);

    bool isMoving = false;
    
    // move the player based on the keys currently pressed
    if (munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.arrowLeft) || munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.keyA)) {
      munchylaxInstance.player.position.x -= munchylaxInstance.speed; // left
      if (scale.x > 0) scale.x = -1; // Flip left
      isMoving = true;
    }
    if (munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.arrowRight) || munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.keyD)) {
      munchylaxInstance.player.position.x += munchylaxInstance.speed; // right
      if (scale.x < 0) scale.x = 1; // Flip right
      isMoving = true;
    }

    // bobbing effect when moving
    if (isMoving) {
      timeElapsed += dt * bobbingSpeed; // speed
      position.y += sin(timeElapsed) * bobbingHeight;
    }

    // clamp position so it doesn't go off-screen
    position.x = position.x.clamp(0 + playerSizeThreshold, (gameRef.size.x - width) + playerSizeThreshold);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Food){
      // eat
      gameRef.hud.updateScore(1);
      other.removeFromParent();

      // eat sound
      FlameAudio.play('eating.mp3', volume: 1);
    }

    if (other is Bomb){
      // game over
      gameRef.reset();

      // explosion sound
      FlameAudio.play('explosion.mp3', volume: 1);
    }
  }
}
