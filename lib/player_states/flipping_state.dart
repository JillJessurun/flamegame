import 'package:my_flame_game/game_class/munchylax.dart';
import 'package:my_flame_game/player_states/player_state.dart';

class FlippingState extends StatePlayer {
  @override
  void enterState(Munchylax munchylax) {
    // set rotation angle
    munchylax.player.rotationAngle = 0;

    // flip sound
    munchylax.player.audioFlip.start();
  }

  @override
  void exitState(Munchylax munchylax) {}

  @override
  void updateState(Munchylax munchylax) {}
}
