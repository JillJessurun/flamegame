import 'package:flame/components.dart';
import 'package:my_flame_game/game_class/munchylax.dart';
import 'package:my_flame_game/player/player.dart';
import 'package:my_flame_game/player_states/player_state.dart';

class RunningRightState extends PlayerState {
  @override
  void enterState(Munchylax munchylax) {
    // TODO: implement enterState
  }

  @override
  void exitState(Munchylax munchylax) {
    // TODO: implement exitState
  }

  @override
  void updateState(Munchylax munchylax) {
    munchylax.player.munchylaxInstance.player.position.x +=
        munchylax.player.munchylaxInstance.speed; // right
    if (munchylax.player.scale.x > 0) {
      munchylax.player.scale.x = -1; // mirror right
    }

    if (!munchylax.player.playerStateManager.activeStates.contains(
      PlayerStateType.isFrontFlipping,
    )) {
      // only change when not frontflipping yet, every frontflip must be finished
      munchylax.player.changeFlipAround = false;
    }

    // change animation
    if (!munchylax.player.playerStateManager.activeStates.contains(
      PlayerStateType.isJumping,
    )) {
      munchylax.player.animation = munchylax.player.walkAnimation;
    }

    // dust
    if (!munchylax.player.playerStateManager.activeStates.contains(
      PlayerStateType.isJumping,
    )) {
      munchylax.player.spawnDustTrail(
        Vector2(
          munchylax.player.position.x - 30,
          munchylax.player.position.y + (munchylax.player.size.y / 2) - 20,
        ),
      );
    }
  }
}
