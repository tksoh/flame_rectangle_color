import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';

class Shield extends RectangleComponent with Tappable, HasGameRef<MyGame> {
  Shield();

  @override
  FutureOr<void>? onLoad() {
    size = gameRef.size;
    setColor(Colors.green);
    return super.onLoad();
  }

  @override
  bool onTapDown(TapDownInfo info) {
    debugPrint('Sheild: onTapDown');
    return false; // stop tap event propagation
  }

  @override
  bool onTapUp(TapUpInfo info) {
    debugPrint('Sheild: onTapUp');
    return false; // stop tap event propagation
  }
}

void main() {
  final game = MyGame();
  runApp(GameWidget(game: game));
}

class MyGame extends FlameGame with HasTappables {
  @override
  FutureOr<void>? onLoad() {
    add(Shield());

    final dot = CircleComponent(radius: 50)
      ..setColor(Colors.blue)
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 2, size.y / 2);
    add(dot);

    final version = TextComponent(text: 'Flame 1.6.0')
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 2, size.y / 2);
    add(version);

    return super.onLoad();
  }
}
