import 'package:my_flame_game/game_class/munchylax.dart';

abstract class StatePlayer {
  void enterState(Munchylax munchylax);
  void updateState(Munchylax munchylax);
  void exitState(Munchylax munchylax);
}
