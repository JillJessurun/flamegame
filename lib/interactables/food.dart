import 'package:flame/components.dart';
import 'package:my_flame_game/game_class/munchylax.dart';
import 'package:flame/collisions.dart';
import 'dart:math';
import 'package:my_flame_game/interactables/strategy.dart';

class Food extends SpriteComponent with HasGameRef<Munchylax> {
  final double foodSize = 40;
  final double min = 140;
  final double max = 210;
  double fallSpeed = 10; // pixels per second
  final double scaleSpeed = 0.5;

  static final Random _random = Random();
  late AnimationStrategy animationStrategy;

  Food() {
    final random = Random();
    animationStrategy = PulsateAnimation(scaleSpeed);
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

  /// reset properties instead of creating a new object
  void reset() {
    position = Vector2(
      _random.nextDouble() * gameRef.size.x - foodSize,
      -foodSize,
    );

    size = Vector2(foodSize, foodSize);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // animate food
    animationStrategy.animate(this, dt);

    // falling food
    position.y += fallSpeed * dt;

    // missed food
    if (position.y > gameRef.size.y) {
      // remove 1 heart
      gameRef.hud.decreaseHealth();

      // remove food
      removeFromParent();
      gameRef.poolManager.releaseFood(this); // Return to the pool
    }
  }
}
