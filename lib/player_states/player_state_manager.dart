import 'package:flame/components.dart';
import 'package:my_flame_game/game_class/munchylax.dart';
import 'package:my_flame_game/player/player.dart';
import 'package:my_flame_game/player_states/player_state.dart';
import 'package:my_flame_game/player_states/down_state.dart';
import 'package:my_flame_game/player_states/flipping_state.dart';
import 'package:my_flame_game/player_states/idle_state.dart';
import 'package:my_flame_game/player_states/jumping_state.dart';
import 'package:my_flame_game/player_states/running_left_state.dart';
import 'package:my_flame_game/player_states/running_right_state.dart';

class PlayerStateManager extends Component with HasGameRef<Munchylax> {
  Set<PlayerStateType> activeStates = {}; // stores multiple active states
  final Map<PlayerStateType, StatePlayer> stateInstances = {
    PlayerStateType.isIdle: IdleState(),
    PlayerStateType.isRunningLeft: RunningLeftState(),
    PlayerStateType.isRunningRight: RunningRightState(),
    PlayerStateType.isJumping: JumpingState(),
    PlayerStateType.isFrontFlipping: FlippingState(),
    PlayerStateType.isGoingDown: GoingDownState(),
  };

  void addState(PlayerStateType state, Munchylax munchylax) {
    activeStates.add(state);
    stateInstances[state]?.enterState(munchylax);
  }

  void removeState(PlayerStateType state, Munchylax munchylax) {
    activeStates.remove(state);
    stateInstances[state]?.exitState(munchylax);
  }

  bool isStateActive(PlayerStateType state) {
    return activeStates.contains(state);
  }

  void updateAllStates(Munchylax munchylax) {
    for (var stateType in activeStates) {
      stateInstances[stateType]?.updateState(munchylax);
    }
  }
}
