import 'package:flame/components.dart';
import 'package:my_flame_game/munchylax.dart';
import 'package:flame/collisions.dart';
import 'dart:math';

class Bomb extends SpriteComponent with HasGameRef<Munchylax> {
  double fallSpeed = 10; // pixels per second
  final double bombSize = 50;
  final double min = 140;
  final double max = 210;
  static final Random _random = Random();

  Bomb(){
    final random = Random();
    fallSpeed = min + random.nextDouble() * (max - min);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    //debugMode = true;

    sprite = await gameRef.loadSprite('bomb.png');

    // initialize within onLoad function instead of constructor because
    // gameRef must be used to get the width of the screen

    // set random x position
    position = Vector2(
      _random.nextDouble() * gameRef.size.x - bombSize,
      -bombSize, // start above the screen
    );

    size = Vector2(bombSize, bombSize);

    // collision hitbox
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // falling bomb
    position.y += fallSpeed * dt;

    // avoided bomb
    if (position.y > gameRef.size.y) {
      removeFromParent();
    }
  }
}
