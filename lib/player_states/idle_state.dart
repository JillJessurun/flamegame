import 'package:my_flame_game/game_class/munchylax.dart';
import 'package:my_flame_game/player_states/player_state.dart';

class IdleState extends StatePlayer {
  @override
  void enterState(Munchylax munchylax) {}

  @override
  void exitState(Munchylax munchylax) {}

  @override
  void updateState(Munchylax munchylax) {
    print("\nIDLE\n");
  }
}
