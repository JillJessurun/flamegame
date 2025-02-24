import 'package:flame/components.dart';
import 'package:my_flame_game/game_class/munchylax.dart';
import 'package:my_flame_game/interactables/bomb.dart';
import 'package:my_flame_game/interactables/bonus.dart';
import 'package:my_flame_game/interactables/food.dart';

class PoolManager extends Component with HasGameRef<Munchylax> {
  // pools
  final List<Food> foodPool = [];
  final List<Bomb> bombPool = [];
  final List<Bonus> bonusPool = [];

  // maximums
  final int maxFood = 30;
  final int maxBombs = 20;
  final int maxBonus = 10;

  /// get a Food object from the pool or create a new one
  Food getFood() {
    if (foodPool.isNotEmpty) {
      return foodPool.removeLast();
    } else if (foodPool.length + bombPool.length + bonusPool.length < maxFood) {
      return Food(); // create new one if under max limit
    } else {
      print("Food limit reached! Reusing oldest.");
      return foodPool.first; // reuse the oldest one
    }
  }

  /// get a Bomb object from the pool or create a new one
  Bomb getBomb() {
    if (bombPool.isNotEmpty) {
      return bombPool.removeLast();
    } else if (foodPool.length + bombPool.length + bonusPool.length <
        maxBombs) {
      return Bomb();
    } else {
      print("Bomb limit reached! Reusing oldest.");
      return bombPool.first;
    }
  }

  /// get a Bonus object from the pool or create a new one
  Bonus getBonus() {
    if (bonusPool.isNotEmpty) {
      return bonusPool.removeLast();
    } else if (foodPool.length + bombPool.length + bonusPool.length <
        maxBonus) {
      return Bonus();
    } else {
      print("Bonus limit reached! Reusing oldest.");
      return bonusPool.first;
    }
  }

  /// return Food to the pool
  void releaseFood(Food food) {
    foodPool.add(food);
  }

  /// return Bomb to the pool
  void releaseBomb(Bomb bomb) {
    bombPool.add(bomb);
  }

  /// return Bonus to the pool
  void releaseBonus(Bonus bonus) {
    bonusPool.add(bonus);
  }

  /// spawn Food
  void spawnFood() {
    Food food = getFood();
    if (!food.isMounted) {
      add(food);
    }
    food.reset();
  }

  /// spawn Bomb
  void spawnBomb() {
    Bomb bomb = getBomb();
    if (!bomb.isMounted) {
      add(bomb);
    }
    bomb.reset();
  }

  /// spawn Bomb
  void spawnBonus() {
    Bonus bonus = getBonus();
    if (!bonus.isMounted) {
      add(bonus);
    }
    bonus.reset();
  }
}
