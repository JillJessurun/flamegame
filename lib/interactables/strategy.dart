import 'package:flame/components.dart';

abstract class AnimationStrategy {
  void animate(SpriteComponent component, double dt);
}

class PulsateAnimation implements AnimationStrategy {
  double _scaleFactor = 1.0;
  bool _growing = true;
  double scaleSpeed = 0.5;
  double minScale = 0.9;
  double maxScale = 1.1;

  PulsateAnimation(this.scaleSpeed);

  @override
  void animate(SpriteComponent component, double dt) {
    // update scale factor
    if (_growing) {
      _scaleFactor += scaleSpeed * dt;
      if (_scaleFactor >= maxScale) _growing = false;
    } else {
      _scaleFactor -= scaleSpeed * dt;
      if (_scaleFactor <= minScale) _growing = true;
    }

    // apply scaling
    component.scale = Vector2.all(_scaleFactor);
  }
}
