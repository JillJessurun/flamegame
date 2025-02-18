import 'package:flame/components.dart';
import 'package:my_flame_game/munchylax.dart';
import 'package:flame/collisions.dart';
import 'dart:math';

class Food extends SpriteComponent with HasGameRef<Munchylax> {
  final double foodSize = 40;
  final double min = 140;
  final double max = 210;
  double fallSpeed = 10; // pixels per second

  static final Random _random = Random();

  Food() {
    final random = Random();
    fallSpeed = min + random.nextDouble() * (max - min);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // slowly increase difficulty
    fallSpeed += gameRef.addSpeed;

    sprite = await gameRef.loadSprite('hotdog.png');

    // set random x position
    position = Vector2(
      _random.nextDouble() * gameRef.size.x - foodSize,
      -foodSize, // start above the screen
    );

    size = Vector2(foodSize, foodSize);

    // collision hitbox
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // falling food
    position.y += fallSpeed * dt;

    // missed food
    if (position.y > gameRef.size.y) {
      // remove 1 heart
      gameRef.hud.decreaseHealth();

      // remove food
      removeFromParent();
    }
  }
}
