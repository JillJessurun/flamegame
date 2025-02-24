import 'dart:ui';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame/rendering.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flame_game/bloc/app_bloc.dart';
import 'package:my_flame_game/bloc/bloc_events.dart';
import 'package:my_flame_game/interactables/bomb.dart';
import 'package:my_flame_game/interactables/bonus.dart';
import 'package:my_flame_game/game_class/munchylax.dart';
import 'package:flame/collisions.dart';
import 'package:my_flame_game/interactables/food.dart';
import 'package:my_flame_game/player/physics.dart';
import 'package:my_flame_game/player_states/player_state_manager.dart';

enum PlayerStateType {
  isJumping,
  isFrontFlipping,
  isGoingDown,
  isIdle,
  isRunningLeft,
  isRunningRight,
}

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
  bool changeFlipAround = false;

  // player states
  bool isJumping = false;
  bool isFrontFlipping = false;
  bool isGoingDown = false;
  bool isRunning = false;
  bool isIdle = false;

  // instances
  late SpriteAnimationComponent playerAnimation;
  late Munchylax munchylaxInstance;
  late SpriteAnimation idleAnimation;
  late SpriteAnimation walkAnimation;
  late PlayerStateManager playerStateManager;
  late Physics physics;

  // audiopools for the sound effects
  late AudioPool audioEating;
  late AudioPool audioJump;
  late AudioPool audioExplosion;
  late AudioPool audioBeep;
  late AudioPool audioHit;
  late AudioPool audioFlip;
  late AudioPool audioGameOver;

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
    playerStateManager = PlayerStateManager();
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

    // add physics
    physics = Physics();
    add(physics);

    // sprite animation setup
    size = Vector2(47.0 * 2.5, 60.0 * 2.5);
    await loadAnimations();

    // audiopools
    audioEating = await FlameAudio.createPool('eating.wav', maxPlayers: 5);
    audioJump = await FlameAudio.createPool('jump.wav', maxPlayers: 5);
    audioExplosion = await FlameAudio.createPool(
      'explosion.wav',
      maxPlayers: 5,
    );
    audioHit = await FlameAudio.createPool('hit.mp3', maxPlayers: 5);
    audioBeep = await FlameAudio.createPool('beep.wav', maxPlayers: 5);
    audioFlip = await FlameAudio.createPool('flip.wav', maxPlayers: 5);
    audioGameOver = await FlameAudio.createPool('gameover.mp3', maxPlayers: 5);
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

    // player state manager
    playerStateManager.updateAllStates(gameRef);
    playerStateManager.removeState(PlayerStateType.isRunningLeft, gameRef);
    playerStateManager.removeState(PlayerStateType.isRunningRight, gameRef);

    // physics
    physics.playerPhysics(dt);
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
      audioEating.start();
    }

    if (other is Bomb) {
      // game over
      gameRef.context.read<AppBloc>().add(GoToMenu());

      // explosion sound
      audioExplosion.start();
    }

    if (other is Bonus) {
      if (playerStateManager.activeStates.contains(
        PlayerStateType.isFrontFlipping,
      )) {
        // 5 bonus points
        gameRef.hud.updateScore(5);
        other.removeFromParent();
        gameRef.poolManager.releaseBonus(other); // return to the pool

        // eat sound
        audioEating.start();
      } else {
        // beep sound
        audioBeep.start();
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
}
