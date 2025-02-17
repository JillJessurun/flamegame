import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:my_flame_game/munchylax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame/text.dart';

class HUD extends PositionComponent with HasGameRef<Munchylax> {
  late TextComponent scoreText;
  late List<SpriteComponent> hearts;
  int score = 0;
  int health = 5; // 5 hearts for full health

  HUD() {
    // textpaint to configure text appearance
    final textPaint = TextPaint(
      style: TextStyle(
        fontSize: 24,
        fontFamily: 'pokemon',
        letterSpacing: 5.0,
        color: Colors.white,
      ),
    );

    scoreText = TextComponent(
      text: "Score: 0",
      position: Vector2(10, 50), // position at top-left
      textRenderer: textPaint,
    );

    hearts = List.generate(5, (index) => SpriteComponent());
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final heartSprite = await gameRef.loadSprite('heart.png');

    // preload audio to avoid lag
    await FlameAudio.audioCache.load('gameover.mp3');
    await FlameAudio.audioCache.load('hit.mp3');

    // set up the heart sprites
    for (int i = 0; i < 5; i++) {
      hearts[i]
        ..sprite = heartSprite
        ..size = Vector2(30, 30)
        ..position = Vector2(10 + i * 35, 10);

      add(hearts[i]);
    }

    add(scoreText);
  }

  // score update
  void updateScore(int addScore) {
    score = score + addScore;
    scoreText.text = "Score: $score";
  }

  void decreaseHealth() {
    if (health > 1) {
      health--;

      // change decorator
      gameRef.player.decorator.removeLast();
      gameRef.player.decorator.addLast(gameRef.player.decoratorPlayerRed);

      // wait before changing back
      Future.delayed(Duration(milliseconds: 100), () {
        gameRef.player.decorator.removeLast();
        gameRef.player.decorator.addLast(gameRef.player.decoratorPlayerTrans);
      });

      hearts[health].removeFromParent(); // remove a heart
      FlameAudio.play('hit.mp3', volume: 1);
    } else {
      // game over
      gameRef.reset();

      // sound
      FlameAudio.play('gameover.mp3', volume: 1);
    }
  }
}
