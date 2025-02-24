import 'package:flame_audio/flame_audio.dart';
import 'package:my_flame_game/game_class/munchylax.dart';
import 'package:my_flame_game/player_states/player_state.dart';

class FlippingState extends StatePlayer {
  @override
  void enterState(Munchylax munchylax) {
    // set rotation angle
    munchylax.player.rotationAngle = 0;

    // flip sound
    FlameAudio.play('flip.wav');
  }

  @override
  void exitState(Munchylax munchylax) {}

  @override
  void updateState(Munchylax munchylax) {}
}
