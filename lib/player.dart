import 'package:flame/components.dart';
import 'package:my_flame_game/munchylax.dart';  // Correct game reference

class Player extends SpriteComponent with HasGameRef<Munchylax> {
  Player(Vector2 position) {
    this.position = position;
    size = Vector2(100.0, 110.0); // Set the player size
    anchor = Anchor.center; // Set anchor point
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // load player
    sprite = await gameRef.loadSprite('player.png');
   
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update logic for the player
  }
}
