// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

extension PositionComponentExt on PositionComponent {
  Vector2 relativePositionTo(PositionComponent other) {
    final otherPos = other.absolutePositionOfAnchor(Anchor.topLeft);
    final thisPos = absolutePosition;

    final relativePos = Vector2(thisPos.x - otherPos.x, thisPos.y - otherPos.y);
    return relativePos;
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
  // runApp(GameWidget(game: game));
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraint) {
            debugPrint('layout builder');
            return GameWidget(game: MyGame());
          },
        ),
      ),
    );
  }
}

class MyGame extends FlameGame with HasTappables {
  @override
  FutureOr<void>? onLoad() {
    final center = RectangleComponent(
      position: Vector2(size.x / 2, size.y / 2),
      size: Vector2(50, 50),
      anchor: Anchor.center,
    )..setColor(Colors.orange);
    add(center);

    final parent = RectangleComponent(
      position: Vector2(150, 150),
      size: Vector2(100, 100),
      anchor: Anchor.center,
    )..setColor(Colors.blue);
    add(parent);

    final child = RectangleComponent(
      position: Vector2(10, 10),
      size: Vector2(30, 30),
    )..setColor(Colors.yellow);
    parent.add(child);

    final child2 = RectangleComponent(
      position: Vector2(50, 50),
      size: Vector2(10, 10),
      anchor: Anchor.center,
    )..setColor(Colors.red);
    parent.add(child2);

    final grandChild = RectangleComponent(
      position: Vector2(17, 17),
      size: Vector2(10, 10),
      anchor: Anchor.center,
    )..setColor(Colors.green);
    child.add(grandChild);

    final parentPos = getTopLeftPosition(parent);
    final childPos1 = getTopLeftPosition(child);
    final childPos2 = getTopLeftPosition(child2);
    final childRelPos1 = child.relativePositionTo(parent);
    final childRelPos2 = child2.relativePositionTo(parent);
    final childRelPos3 = child2.relativePositionTo(child);
    final grandChildPos = grandChild.relativePositionTo(parent);
    final grandChildPos3 = getChildPosition(grandChild, parent);

    return super.onLoad();
  }
}

Vector2 getTopLeftPosition(PositionComponent component) {
  var adjust = Vector2(0.0, 0.0);

  if (component.anchor == Anchor.topLeft) {
    adjust = Vector2(0.0, 0.0);
  } else if (component.anchor == Anchor.center) {
    adjust = Vector2(-0.5, -0.5);
  } else if (component.anchor == Anchor.bottomCenter) {
    adjust = Vector2(-0.5, -1.0);
  } else if (component.anchor == Anchor.topCenter) {
    adjust = Vector2(-0.5, 0.0);
  } else if (component.anchor == Anchor.topRight) {
    adjust = Vector2(-1.0, 0.0);
  } else if (component.anchor == Anchor.bottomRight) {
    adjust = Vector2(-1.0, -1.0);
  } else if (component.anchor == Anchor.bottomLeft) {
    adjust = Vector2(0.0, -1.0);
  } else if (component.anchor == Anchor.centerLeft) {
    adjust = Vector2(-0.5, 0.0);
  } else if (component.anchor == Anchor.centerRight) {
    adjust = Vector2(-0.5, -1.0);
  }

  final xAdjust = component.x + component.size.x * adjust.x;
  final yAdjust = component.y + component.size.y * adjust.y;

  return Vector2(xAdjust, yAdjust);
}

Vector2 getChildPosition(PositionComponent child, Component root,
    {showMarker = false}) {
  assert(child.parent != null);

  var ancestor = child.parent as PositionComponent;
  var pos = Vector2(child.x, child.y);
  while (ancestor != root) {
    final topLeft = getTopLeftPosition(ancestor);
    pos = Vector2(topLeft.x + pos.x, topLeft.y + pos.y);
    ancestor = ancestor.parent as PositionComponent;
  }

  // debugPrint('getChildPosition: child pos =  $pos');

  if (showMarker) {
    final marker = PositionMarker(position: pos, lifeSpan: 1);
    root.add(marker);
  }

  return pos;
}
