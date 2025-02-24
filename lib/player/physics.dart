import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:my_flame_game/game_class/munchylax.dart';
import 'package:my_flame_game/player/player.dart';

class Physics extends Component with HasGameRef<Munchylax> {
  void playerPhysics(double dt) {
    // jump physics
    if (gameRef.player.playerStateManager.activeStates.contains(
      PlayerStateType.isJumping,
    )) {
      // change to idle
      gameRef.player.animation = gameRef.player.idleAnimation;

      // apply gravity
      if (gameRef.player.playerStateManager.activeStates.contains(
        PlayerStateType.isGoingDown,
      )) {
        gameRef.player.velocityY += gameRef.player.gravity * dt * 2;
      } else {
        gameRef.player.velocityY += gameRef.player.gravity * dt;
      }

      // update vertical position
      gameRef.player.position.y += gameRef.player.velocityY * dt;

      // prevent the player from falling through the ground
      if (gameRef.player.position.y >=
          gameRef.size.y - (gameRef.player.playerHeight / 2)) {
        gameRef.player.position.y =
            gameRef.size.y -
            (gameRef.player.playerHeight / 2); // reset to ground
        gameRef.player.velocityY = 0; // stop downward velocity

        // remove states from list
        gameRef.player.playerStateManager.removeState(
          PlayerStateType.isJumping,
          gameRef,
        );
        if (gameRef.player.playerStateManager.activeStates.contains(
          PlayerStateType.isGoingDown,
        )) {
          gameRef.player.playerStateManager.removeState(
            PlayerStateType.isGoingDown,
            gameRef,
          );
        }
      }
    }

    // frontflip physics
    if (gameRef.player.playerStateManager.activeStates.contains(
      PlayerStateType.isFrontFlipping,
    )) {
      if (gameRef.player.changeFlipAround) {
        // when moving left
        gameRef.player.rotationAngle -=
            gameRef.player.rotationSpeed * dt; // 360-degree frontflip over time

        // limit rotation to one full frontflip
        if (gameRef.player.rotationAngle <= -2 * pi) {
          gameRef.player.rotationAngle = 0;

          // remove states from list
          if (gameRef.player.playerStateManager.activeStates.contains(
            PlayerStateType.isFrontFlipping,
          )) {
            gameRef.player.playerStateManager.removeState(
              PlayerStateType.isFrontFlipping,
              gameRef,
            );
          }
        }
      } else {
        // when moving right
        gameRef.player.rotationAngle +=
            gameRef.player.rotationSpeed * dt; // 360-degree frontflip over time

        // limit rotation to one full frontflip
        if (gameRef.player.rotationAngle >= 2 * pi) {
          gameRef.player.rotationAngle = 0;

          // remove states from list
          if (gameRef.player.playerStateManager.activeStates.contains(
            PlayerStateType.isFrontFlipping,
          )) {
            gameRef.player.playerStateManager.removeState(
              PlayerStateType.isFrontFlipping,
              gameRef,
            );
          }
        }
      }

      // apply rotation to the player (around the center)
      gameRef.player.angle = gameRef.player.rotationAngle;
    }

    // move left
    if (gameRef.player.munchylaxInstance.keysPressed.contains(
          LogicalKeyboardKey.arrowLeft,
        ) ||
        gameRef.player.munchylaxInstance.keysPressed.contains(
          LogicalKeyboardKey.keyA,
        )) {
      if (!gameRef.player.playerStateManager.activeStates.contains(
        PlayerStateType.isRunningLeft,
      )) {
        gameRef.player.playerStateManager.addState(
          PlayerStateType.isRunningLeft,
          gameRef,
        );
      }
    }
    // move right
    if (gameRef.player.munchylaxInstance.keysPressed.contains(
          LogicalKeyboardKey.arrowRight,
        ) ||
        gameRef.player.munchylaxInstance.keysPressed.contains(
          LogicalKeyboardKey.keyD,
        )) {
      if (!gameRef.player.playerStateManager.activeStates.contains(
        PlayerStateType.isRunningRight,
      )) {
        gameRef.player.playerStateManager.addState(
          PlayerStateType.isRunningRight,
          gameRef,
        );
      }
    }
    // jump
    if (gameRef.player.munchylaxInstance.keysPressed.contains(
          LogicalKeyboardKey.space,
        ) ||
        gameRef.player.munchylaxInstance.keysPressed.contains(
          LogicalKeyboardKey.keyW,
        ) ||
        gameRef.player.munchylaxInstance.keysPressed.contains(
          LogicalKeyboardKey.arrowUp,
        )) {
      if (!gameRef.player.playerStateManager.activeStates.contains(
        PlayerStateType.isJumping,
      )) {
        gameRef.player.playerStateManager.addState(
          PlayerStateType.isJumping,
          gameRef,
        );
      }
    }
    // down
    if (gameRef.player.munchylaxInstance.keysPressed.contains(
          LogicalKeyboardKey.keyS,
        ) ||
        gameRef.player.munchylaxInstance.keysPressed.contains(
          LogicalKeyboardKey.arrowDown,
        )) {
      if (!gameRef.player.playerStateManager.activeStates.contains(
        PlayerStateType.isGoingDown,
      )) {
        gameRef.player.playerStateManager.addState(
          PlayerStateType.isGoingDown,
          gameRef,
        );
      }
    } else {
      if (gameRef.player.playerStateManager.activeStates.contains(
        PlayerStateType.isGoingDown,
      )) {
        gameRef.player.playerStateManager.removeState(
          PlayerStateType.isGoingDown,
          gameRef,
        );
      }
    }
    // frontflip
    if (gameRef.player.munchylaxInstance.keysPressed.contains(
      LogicalKeyboardKey.enter,
    )) {
      if (gameRef.player.playerStateManager.activeStates.contains(
        PlayerStateType.isJumping,
      )) {
        if (!gameRef.player.playerStateManager.activeStates.contains(
          PlayerStateType.isFrontFlipping,
        )) {
          gameRef.player.playerStateManager.addState(
            PlayerStateType.isFrontFlipping,
            gameRef,
          );
        }
      }
    }
    // idle
    //else {
    //playerStateManager.addState(PlayerStateType.isIdle, gameRef);
    //}

    // bobbing and dust effect when moving
    if (gameRef.player.playerStateManager.activeStates.contains(
          PlayerStateType.isRunningRight,
        ) ||
        gameRef.player.playerStateManager.activeStates.contains(
          PlayerStateType.isRunningLeft,
        )) {
      gameRef.player.timeElapsed += dt * gameRef.player.bobbingSpeed; // speed
      gameRef.player.position.y +=
          sin(gameRef.player.timeElapsed) * gameRef.player.bobbingHeight;
    } else {
      gameRef.player.animation = gameRef.player.idleAnimation;
    }

    // warp to the other side
    if (gameRef.player.position.x > gameRef.size.x) {
      gameRef.player.position.x = 0;
    }
    if (gameRef.player.position.x < 0) {
      gameRef.player.position.x = gameRef.size.x;
    }
  }
}
