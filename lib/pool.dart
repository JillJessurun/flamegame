import 'package:flame/components.dart';

class ObjectPool<T extends SpriteComponent> {
  final List<T> _available = [];
  final List<T> _inUse = [];
  final T Function() _create;

  ObjectPool(this._create, {int initialSize = 10}) {
    // Pre-fill the pool
    for (int i = 0; i < initialSize; i++) {
      _available.add(_create());
    }
  }

  /// Get an object from the pool
  T getObject() {
    if (_available.isEmpty) {
      _available.add(_create()); // Expand pool if necessary
    }
    T obj = _available.removeLast();
    _inUse.add(obj);
    return obj;
  }

  /// Return an object to the pool
  void releaseObject(T obj) {
    _inUse.remove(obj);
    _available.add(obj);
  }
}
