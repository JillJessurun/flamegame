import 'package:flame/components.dart';
import 'package:my_flame_game/game_class/munchylax.dart';
import 'package:flame/collisions.dart';
import 'dart:math';

import 'package:my_flame_game/interactables/strategy.dart';

class Bomb extends SpriteComponent with HasGameRef<Munchylax> {
  final double bombSize = 50;
  final double min = 140;
  final double max = 210;
  double fallSpeed = 10; // pixels per second
  final double scaleSpeed = 0.5;

  static final Random _random = Random();
  late AnimationStrategy animationStrategy;

  Bomb() {
    final random = Random();
    animationStrategy = PulsateAnimation(scaleSpeed);
    fallSpeed = min + random.nextDouble() * (max - min);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // slowly increase difficulty
    fallSpeed += gameRef.addSpeed;

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

  /// reset method to reuse the object
  void reset() {
    position = Vector2(
      _random.nextDouble() * gameRef.size.x - bombSize,
      -bombSize,
    );
    size = Vector2(bombSize, bombSize);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // animate bomb
    animationStrategy.animate(this, dt);

    // falling bomb
    position.y += fallSpeed * dt;

    // avoided bomb
    if (position.y > gameRef.size.y) {
      removeFromParent();
      gameRef.poolManager.releaseBomb(this); // return to the pool
    }
  }
}
