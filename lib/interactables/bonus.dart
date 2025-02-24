import 'dart:math';
import 'package:flame/components.dart';
import 'package:my_flame_game/game_class/munchylax.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:my_flame_game/interactables/strategy.dart';

class Bonus extends SpriteComponent with HasGameRef<Munchylax> {
  final double foodSize = 40;
  final double min = 140;
  final double max = 210;
  double spawnHeight = 0;
  final double scaleSpeed = 0.4;

  static final Random _random = Random();
  late AnimationStrategy animationStrategy;

  Bonus() {
    animationStrategy = PulsateAnimation(scaleSpeed);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    sprite = await gameRef.loadSprite('donut.png');

    // set spawn height for the bonus food 1.7 times the player height
    spawnHeight = gameRef.size.y - (gameRef.player.size.y * 1.7);

    // set random x position
    position = Vector2(
      _random.nextDouble() * gameRef.size.x - foodSize,
      spawnHeight,
    );

    size = Vector2(foodSize, foodSize);

    // move effect
    final effect = MoveByEffect(
      Vector2(0, -20),
      EffectController(duration: 0.5, reverseDuration: 0.5, infinite: true),
    );

    add(effect);

    // collision hitbox
    add(CircleHitbox());
  }

  /// reset method to reuse the object
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

    // animate bonus
    animationStrategy.animate(this, dt);
  }
}
