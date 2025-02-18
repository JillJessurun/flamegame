import 'package:flame/components.dart';
import 'package:my_flame_game/munchylax.dart';
import 'package:flame/collisions.dart';
import 'dart:math';

class Food extends SpriteComponent with HasGameRef<Munchylax> {
  double fallSpeed = 10; // pixels per second
  final double foodSize = 40;
  final double min = 140;
  final double max = 210;
  static final Random _random = Random();

  Food(){
    final random = Random();
    fallSpeed = min + random.nextDouble() * (max - min);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    //debugMode = true;

    sprite = await gameRef.loadSprite('hotdog.png');

    // initialize within onLoad function instead of constructor because
    // gameRef must be used to get the width of the screen

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

      // change decorator
      gameRef.player.decorator.removeLast();
      gameRef.player.decorator.addLast(gameRef.player.decoratorPlayerRed);

      // wait before changing back
      Future.delayed(Duration(milliseconds: 100), () {
        gameRef.player.decorator.removeLast();
        gameRef.player.decorator.addLast(gameRef.player.decoratorPlayerTrans);
      });

      // remove food
      removeFromParent();
    }
  }
}
