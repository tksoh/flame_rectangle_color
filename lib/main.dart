import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

Color invert(Color color) {
  final r = 255 - color.red;
  final g = 255 - color.green;
  final b = 255 - color.blue;

  return Color.fromARGB((color.opacity * 255).round(), r, g, b);
}

extension ComponentEx on ShapeComponent {
  Color getColor() {
    return getPaint().color;
  }
}

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
    debugPrint('shield: original color = ${getColor()}');
    size = gameRef.size;
    setColor(Colors.green);
    debugPrint('shield: new color = ${getColor()}');
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

    // toggle shield color
    setColor(invert(getColor()));

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
