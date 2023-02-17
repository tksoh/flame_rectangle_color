import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class PositionMarker extends CircleComponent {
  double? lifeSpan;

  PositionMarker({
    Vector2? position,
    double radius = 5.0,
    color = Colors.red,
    this.lifeSpan,
  }) : super(
          position: position,
          radius: radius,
          anchor: Anchor.center,
        ) {
    setColor(color);
  }

  @override
  Future<void> onLoad() {
    if (lifeSpan != null) {
      add(RemoveEffect(delay: lifeSpan!));
    }
    return super.onLoad();
  }
}

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
    final marker = PositionMarker(
      position: info.eventPosition.game,
      radius: 10,
      lifeSpan: 2,
    );
    gameRef.add(marker);
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

    final version = TextComponent(text: 'Flame 1.6.0')
      ..position = Vector2(10, 80);
    add(version);

    return super.onLoad();
  }
}
