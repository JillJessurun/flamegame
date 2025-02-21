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
  //late PlayerState _currentState;
  //PlayerStateType _currentStateType = PlayerStateType.isIdle;

  //PlayerStateManager() {
  //  _currentState = IdleState();
  //}

  Set<PlayerStateType> activeStates = {}; // stores multiple active states
  final Map<PlayerStateType, PlayerState> stateInstances = {
    PlayerStateType.isIdle: IdleState(),
    PlayerStateType.isRunningLeft: RunningLeftState(),
    PlayerStateType.isRunningRight: RunningRightState(),
    PlayerStateType.isJumping: JumpingState(),
    PlayerStateType.isFrontFlipping: FlippingState(),
    PlayerStateType.isGoingDown: GoingDownState(),
  };

  /*
  void changeState(PlayerStateType newState) {
    _currentState.exitState(); // exit current state

    // switch to the new state
    _currentStateType = newState;
    switch (newState) {
      case PlayerStateType.isIdle:
        _currentState = IdleState();
        break;
      case PlayerStateType.isRunningLeft:
        _currentState = RunningLeftState();
        break;
      case PlayerStateType.isRunningRight:
        _currentState = RunningRightState();
        break;
      case PlayerStateType.isFrontFlipping:
        _currentState = FlippingState();
        break;
      case PlayerStateType.isJumping:
        _currentState = JumpingState();
        break;
      case PlayerStateType.isGoingDown:
        _currentState = GoingDownState();
        break;
    }

    _currentState.enterState(); // enter the new state
  }
  */

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

  //PlayerStateType get currentStateType => _currentStateType;
}
