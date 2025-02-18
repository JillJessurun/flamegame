import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:my_flame_game/bomb.dart';
import 'package:my_flame_game/player.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:my_flame_game/food.dart';
import 'package:my_flame_game/hud.dart';
import 'package:flame_audio/flame_audio.dart';

class Munchylax extends FlameGame
    with KeyboardEvents, HasCollisionDetection, TapDetector {
  final double speed = 15;
  final double positionThreshold = 55;
  final double groundHeight = 25;
  final double fallingFoodAmount = 1.2; // the higher the less food
  final double fallingBombAmount = 3; // the higher the less bomb
  bool isGameStarted = false; // start in a paused state
  double addSpeed = 0;

  late Timer spawnTimer;
  late Timer bombTimer;
  late SpriteComponent background;
  late Player player;
  late HUD hud;
  Set<LogicalKeyboardKey> keysPressed = {}; // track keys that are pressed

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // preload audio to avoid lag
    await FlameAudio.audioCache.load('Cynthia theme.mp3');

    // load background image
    background =
        SpriteComponent()
          ..sprite = await loadSprite('backgroundmunchylax.jpg')
          ..size = size
          ..position = Vector2.zero();

    add(background);

    // show the start button overlay
    overlays.add('Start');

    // load ground
    RectangleComponent ground = RectangleComponent(
      size: Vector2(size.x, groundHeight),
      position: Vector2(0, size.y - groundHeight), // positioned at the bottom
      paint: Paint()..color = const Color.fromARGB(255, 32, 49, 56),
    );

    add(ground);

    // load HUD
    hud = HUD();
    add(hud);

    // load player
    player = Player(Vector2(size.x / 2, size.y - positionThreshold), this);
    add(player);

    // load food spawning timer
    spawnTimer = Timer(
      fallingFoodAmount,
      repeat: true,
      onTick: () {
        addSpeed += 3; // make food fall faster each time
        add(Food()); // new food
      },
    );
    spawnTimer.start();

    // load bomb spawning timer
    bombTimer = Timer(
      fallingBombAmount,
      repeat: true,
      onTick: () {
        add(Bomb()); // new bomb
      },
    );
    bombTimer.start();
  }

  void startGame() {
    isGameStarted = true;
    overlays.remove('Start'); // remove the overlay text
    FlameAudio.bgm.play('Cynthia theme.mp3', volume: 0.5);
  }

  @override
  void onDetach() {
    // stop background music when the game is closed
    FlameAudio.bgm.stop();
    super.onDetach();
  }

  @override
  void update(double dt) {
    // check if game started
    if (!isGameStarted) return;

    super.update(dt);

    //update food timer
    if (!spawnTimer.isRunning()) {
      spawnTimer.start();
    } else {
      spawnTimer.update(dt);
    }

    //update bomb timer
    if (!bombTimer.isRunning()) {
      bombTimer.start();
    } else {
      bombTimer.update(dt);
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        reset(); // homescreen when "R" is pressed
        return KeyEventResult.handled;
      } else {
        // add the key that was pressed
        this.keysPressed.add(event.logicalKey);
      }
    } else if (event is KeyUpEvent) {
      // remove the key that was released
      this.keysPressed.remove(event.logicalKey);
    }

    return KeyEventResult.handled;
  }

  void reset() async {
    // stop the game
    isGameStarted = false;

    // show the start overlay again
    overlays.add('Start');

    // reset score
    hud.score = 0;
    hud.scoreText.text = "Score: ${hud.score}";

    // reset health
    hud.health = 5;
    for (var heart in hud.hearts) {
      add(heart);
    } // add hearts back if removed

    // reset food/bomb speed
    addSpeed = 0;

    // remove all food/bomb components
    children.whereType<Food>().forEach((food) => food.removeFromParent());
    children.whereType<Bomb>().forEach((bomb) => bomb.removeFromParent());

    // reset player position
    player.position = Vector2(size.x / 2, size.y - positionThreshold);

    // stop timers
    spawnTimer.stop();
    bombTimer.stop();

    // stop background music
    FlameAudio.bgm.stop();
  }
}
