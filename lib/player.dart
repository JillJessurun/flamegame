import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:my_flame_game/bomb.dart';
import 'package:my_flame_game/munchylax.dart';
import 'package:flutter/services.dart';
import 'package:flame/collisions.dart';
import 'package:my_flame_game/food.dart';
import 'package:flame_audio/flame_audio.dart';
import 'dart:math';

class Player extends SpriteAnimationComponent with HasGameRef<Munchylax>, CollisionCallbacks {
  final double playerWidth = 100;
  final double playerHeight = 110;
  final double playerSizeThreshold = 50;
  final double bobbingHeight = 3;
  final double bobbingSpeed = 50;
  double timeElapsed = 0; // tracks time for sine wave

  late SpriteAnimationComponent playerAnimation;
  late Munchylax munchylaxInstance;
  late SpriteAnimation idleAnimation;
  late SpriteAnimation walkAnimation;

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

    //sprite animation setup
    size = Vector2(47.0 * 2.5, 60.0 * 2.5);
    await loadAnimations();

    // preload audio to avoid lag
    await FlameAudio.audioCache.load('eating.mp3');
    await FlameAudio.audioCache.load('explosion.mp3');
  }

  // animations
  Future<void> loadAnimations() async{
    // srcSize -> width is 188 pixels so then do 188 / 4 = 47 (four sprites in the sheet)

    // idle
    SpriteSheet idleSheet = SpriteSheet(image: await gameRef.images.load('idlespritesheet.png'), srcSize: Vector2(47, 60));
    idleAnimation = idleSheet.createAnimation(row: 0, stepTime: 0.1, from: 1, to: 7);

    // walking
    SpriteSheet walkSheet = SpriteSheet(image: await gameRef.images.load('spritesheet.png'), srcSize: Vector2(47, 60));
    walkAnimation = walkSheet.createAnimation(row: 0, stepTime: 0.1, from: 1, to: 4);

    // set idle
    animation = idleAnimation;
  }


  @override
  void update(double dt) {
    super.update(dt);

    bool isMoving = false;
    
    // move the player based on the keys currently pressed
    if (munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.arrowLeft) || munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.keyA)) {
      munchylaxInstance.player.position.x -= munchylaxInstance.speed; // left
      if (scale.x < 0) scale.x = 1; // Flip left
      isMoving = true;
      animation = walkAnimation;

      // dust
      spawnDustTrail(Vector2(position.x+30, position.y+(size.y/2)));
    }
    if (munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.arrowRight) || munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.keyD)) {
      munchylaxInstance.player.position.x += munchylaxInstance.speed; // right
      if (scale.x > 0) scale.x = -1; // Flip right
      isMoving = true;
      animation = walkAnimation;

      // dust
      spawnDustTrail(Vector2(position.x-30, position.y+(size.y/2)));
    }

    // bobbing and dust effect when moving
    if (isMoving) {
      timeElapsed += dt * bobbingSpeed; // speed
      position.y += sin(timeElapsed) * bobbingHeight;
    }else{
      animation = idleAnimation;
    }

    // clamp position so it doesn't go off-screen
    position.x = position.x.clamp(0 + playerSizeThreshold, (gameRef.size.x - width) + playerSizeThreshold);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Food){
      // eat particles
      spawnFoodParticles(Vector2(10, 60)); // mouth position

      // shake effect
      final effect = MoveByEffect(
        Vector2(10, 0), // move 10 pixels right
        EffectController(duration: 0.05, reverseDuration: 0.05, repeatCount: 3),
      );

      add(effect);

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

  void spawnFoodParticles(Vector2 position) {
    final particle = ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: 20, // Number of particles
        lifespan: 0.5, // How long they last
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(-40, 200), // Random spread
          speed: Vector2.random() * 100, // Random speed
          child: CircleParticle(
            radius: 2,
            paint: Paint()..color = const Color.fromARGB(255, 194, 143, 4), // Sparkle color
          ),
        ),
      ),
    );

    add(particle);
  }

  Future<void> spawnDustTrail(Vector2 position) async {
    // Load the dust sprite (ensure this is loaded before using in the effect)
    final dustSprite = await gameRef.loadSprite('dust.png');  // Replace with your dust image
    
    final dust = ParticleSystemComponent(
      position: position, // Position of Munchylax
      particle: Particle.generate(
        count: 1, // Number of dust particles
        lifespan: 0.05, // Duration before particles disappear
        generator: (i) => MovingParticle(
          to: Vector2(0, 0), // Moves upward (dust trail moves upward)
          child: SpriteParticle(
            sprite: dustSprite, // Use the loaded sprite
            size: Vector2(50, 50), // Size of the dust particles
          ),
        ),
      ),
    );
    gameRef.add(dust); // Add to the game
  }

  void spawnMissedFoodParticles(Vector2 position) {
    final particle = ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: 10, // Number of particles
        lifespan: 0.5, // How long they last
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2.random() * 100, // Random spread
          speed: Vector2.random() * 70, // Random speed
          child: CircleParticle(
            radius: 2,
            paint: Paint()..color = const Color.fromARGB(255, 255, 0, 0), // Sparkle color
          ),
        ),
      ),
    );

    add(particle);
  }
}
