import 'package:flame_audio/flame_audio.dart';
import 'package:my_flame_game/game_class/munchylax.dart';
import 'package:my_flame_game/player_states/player_state.dart';

class JumpingState extends StatePlayer {
  @override
  void enterState(Munchylax munchylax) {
    // jump sound
    FlameAudio.play('jump.wav');

    // change velocity
    munchylax.player.velocityY = munchylax.player.jumpStrength;
  }

  @override
  void exitState(Munchylax munchylax) {}

  @override
  void updateState(Munchylax munchylax) {}
}
