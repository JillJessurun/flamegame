import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame/rendering.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:my_flame_game/audio.dart';
import 'package:my_flame_game/bomb.dart';
import 'package:my_flame_game/bonus.dart';
import 'package:my_flame_game/munchylax.dart';
import 'package:flutter/services.dart';
import 'package:flame/collisions.dart';
import 'package:my_flame_game/food.dart';
import 'dart:math';

class Player extends SpriteAnimationComponent
    with HasGameRef<Munchylax>, CollisionCallbacks {
  final double playerWidth = 100;
  final double playerHeight = 110;
  final double playerSizeThreshold = 50;
  final double bobbingHeight = 3;
  final double bobbingSpeed = 50;
  double timeElapsed = 0; // tracks time for sine wave (bobbing effect)

  //jump and frontflip
  final double jumpStrength = -900; // negative value for upward force
  final double rotationSpeed = 5 * pi; // full frontflip
  double gravity = 2500; // positive value to simulate gravity
  double velocityY = 0; // velocity of the player on the y-axis
  double rotationAngle = 0;
  bool isJumping = false;
  bool isFrontFlipping = false;
  bool changeFlipAround = false;
  bool down = false;

  // audio effects
  late Audio eatingAudio;
  late Audio explosionAudio;
  late Audio flipAudio;
  late Audio hitAudio;
  late Audio jumpAudio;
  late Audio beepAudio;
  late Audio bonusAudio;

  late SpriteAnimationComponent playerAnimation;
  late Munchylax munchylaxInstance;
  late SpriteAnimation idleAnimation;
  late SpriteAnimation walkAnimation;

  // decorators for when taking damage
  final decoratorPlayerTrans = PaintDecorator.tint(
    Color.fromARGB(0, 255, 60, 0),
  );
  final decoratorPlayerRed = PaintDecorator.tint(
    Color.fromARGB(136, 255, 60, 0),
  );

  // constructor
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

    // decorator
    decorator.addLast(decoratorPlayerTrans);

    // sprite animation setup
    size = Vector2(47.0 * 2.5, 60.0 * 2.5);
    await loadAnimations();

    // audio instances
    eatingAudio = Audio('eating.wav');
    explosionAudio = Audio('explosion.wav');
    jumpAudio = Audio('jump.wav');
    flipAudio = Audio('flip.wav');
    beepAudio = Audio('beep.wav');
    bonusAudio = Audio('eating.wav');
    hitAudio = Audio('hit.mp3');
  }

  // player animation
  Future<void> loadAnimations() async {
    // srcSize -> width is 188 pixels so then do 188 / 4 = 47 (four sprites in the sheet)

    // idle
    SpriteSheet idleSheet = SpriteSheet(
      image: await gameRef.images.load('idlespritesheet.png'),
      srcSize: Vector2(47, 60),
    );
    idleAnimation = idleSheet.createAnimation(
      row: 0,
      stepTime: 0.1,
      from: 1,
      to: 7,
    );

    // walking
    SpriteSheet walkSheet = SpriteSheet(
      image: await gameRef.images.load('spritesheet.png'),
      srcSize: Vector2(47, 60),
    );
    walkAnimation = walkSheet.createAnimation(
      row: 0,
      stepTime: 0.1,
      from: 1,
      to: 4,
    );

    // set idle
    animation = idleAnimation;
  }

  @override
  void update(double dt) {
    super.update(dt);

    bool isMoving = false;

    // jump physics
    if (isJumping) {
      // change to idle
      animation = idleAnimation;

      // apply gravity
      if (!down) {
        velocityY += gravity * dt;
      } else {
        velocityY += gravity * dt * 2;
      }

      // update vertical position
      position.y += velocityY * dt;

      // prevent the player from falling through the ground
      if (position.y >= gameRef.size.y - (playerHeight / 2)) {
        position.y = gameRef.size.y - (playerHeight / 2); // reset to ground
        isJumping = false;
        velocityY = 0; // stop downward velocity
      }
    }

    // frontflip physics
    if (isFrontFlipping) {
      if (changeFlipAround) {
        // when moving left
        rotationAngle -= rotationSpeed * dt; // 360-degree frontflip over time

        // limit rotation to one full frontflip
        if (rotationAngle <= -2 * pi) {
          rotationAngle = 0;
          isFrontFlipping = false; // end frontflip
        }
      } else {
        // when moving right
        rotationAngle += rotationSpeed * dt; // 360-degree frontflip over time

        // limit rotation to one full frontflip
        if (rotationAngle >= 2 * pi) {
          rotationAngle = 0;
          isFrontFlipping = false; // end frontflip
        }
      }

      // apply rotation to the player (around the center)
      angle = rotationAngle;
    }

    // move left
    if (munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.keyA)) {
      munchylaxInstance.player.position.x -= munchylaxInstance.speed; // left
      if (scale.x < 0) scale.x = 1; // mirror left
      isMoving = true;
      if (!isFrontFlipping) {
        // only change when not frontflipping yet, every frontflip must be finished
        changeFlipAround = true;
      }

      // change animation
      if (!isJumping) {
        animation = walkAnimation;
      }

      // dust
      if (!isJumping) {
        spawnDustTrail(
          Vector2(position.x + 30, position.y + (size.y / 2) - 20),
        );
      }
    }

    // move right
    if (munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.keyD)) {
      munchylaxInstance.player.position.x += munchylaxInstance.speed; // right
      if (scale.x > 0) scale.x = -1; // mirror right
      isMoving = true;
      if (!isFrontFlipping) {
        // only change when not frontflipping yet, every frontflip must be finished
        changeFlipAround = false;
      }

      // change animation
      if (!isJumping) {
        animation = walkAnimation;
      }

      // dust
      if (!isJumping) {
        spawnDustTrail(
          Vector2(position.x - 30, position.y + (size.y / 2) - 20),
        );
      }
    }

    // jump
    if (munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.space) ||
        munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.keyW) ||
        munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      jump();
    }

    // down
    if (munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.keyS) ||
        munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      down = true;
    } else {
      down = false;
    }

    // frontflip
    if (munchylaxInstance.keysPressed.contains(LogicalKeyboardKey.enter)) {
      frontflip();
    }

    // bobbing and dust effect when moving
    if (isMoving) {
      timeElapsed += dt * bobbingSpeed; // speed
      position.y += sin(timeElapsed) * bobbingHeight;
    } else {
      animation = idleAnimation;
    }

    // warp to the other side
    if (position.x > gameRef.size.x) {
      position.x = 0;
    }
    if (position.x < 0) {
      position.x = gameRef.size.x;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    // collission with food
    if (other is Food) {
      // eat particles
      spawnFoodParticles(Vector2(10, 60)); // mouth position

      // shake effect
      final effect = MoveByEffect(
        Vector2(10, 10), // move 10 pixels right
        EffectController(duration: 0.05, reverseDuration: 0.05, repeatCount: 3),
      );

      add(effect);

      // eat
      gameRef.hud.updateScore(1);
      other.removeFromParent();

      // eat sound
      eatingAudio.playSound();
    }

    if (other is Bomb) {
      // game over
      gameRef.reset();

      // explosion sound
      explosionAudio.playSound();
    }

    if (other is Bonus) {
      if (isFrontFlipping) {
        // 5 bonus points
        gameRef.hud.updateScore(5);
        other.removeFromParent();

        // eat sound
        bonusAudio.playSound();
      } else {
        // beep sound
        beepAudio.playSound();
      }
    }
  }

  // food crumbs from players mouth
  void spawnFoodParticles(Vector2 position) {
    final particle = ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: 20, // number of particles
        lifespan: 0.5, // how long they last
        generator:
            (i) => AcceleratedParticle(
              acceleration: Vector2(-40, 200),
              speed: Vector2.random() * 100,
              child: CircleParticle(
                radius: 2,
                paint: Paint()..color = const Color.fromARGB(255, 194, 143, 4),
              ),
            ),
      ),
    );

    add(particle);
  }

  // dust trail when walking
  Future<void> spawnDustTrail(Vector2 position) async {
    final dustSprite = await gameRef.loadSprite('dust.png');

    final dust = ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: 1,
        lifespan: 0.05,
        generator:
            (i) => MovingParticle(
              to: Vector2(0, 0),
              child: SpriteParticle(sprite: dustSprite, size: Vector2(50, 50)),
            ),
      ),
    );
    gameRef.add(dust);
  }

  // jump function
  void jump() {
    if (!isJumping) {
      isJumping = true;
      velocityY = jumpStrength;

      // jump sound
      jumpAudio.playSound();
    }
  }

  // frontflip function
  void frontflip() {
    if (isJumping && !isFrontFlipping) {
      isFrontFlipping = true;
      rotationAngle = 0;

      // flip sound
      flipAudio.playSound();
    }
  }
}
