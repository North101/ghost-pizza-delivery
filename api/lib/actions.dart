import 'dart:math';

import 'directions.dart';
import 'game.dart';
import 'player.dart';
import 'reports.dart';
import 'tiles.dart';

abstract class Action {
  final Player player;

  const Action(this.player);

  Future<void> resolve(Game game);
}

class SkipAction extends Action {
  const SkipAction(Player player) : super(player);

  Future<void> resolve(Game game) async => null;
}

class EndGameAction extends Action {
  const EndGameAction(Player player) : super(player);

  Future<void> resolve(Game game) async {
    throw EndGameError();
  }
}

class AttackAction extends Action {
  final Direction direction;

  const AttackAction(Player player, this.direction) : super(player);

  Future<void> resolve(Game game) async {
    await game.sendPlayerReport(AttackActionReport(this.player, this.direction));

    final attackPoint = game.grid.offsetPoint(this.player.point, this.direction);
    if (attackPoint == null) return;

    final tile = game.grid.getOrBorder(attackPoint);
    await tile.onAttackAt(game, this.player, attackPoint);
  }
}

class MoveAction extends Action {
  final Direction direction;

  const MoveAction(Player player, this.direction) : super(player);

  Future<void> resolve(Game game) async {
    await game.sendPlayerReport(MoveActionReport(this.player, this.direction));

    final newPoint = game.grid.offsetPoint(this.player.point, this.direction);
    final newTile = game.grid.getOrBorder(newPoint);
    await newTile.onMoveTo(game, this.player, newPoint, false);
  }
}

class Special {
  const Special();
}

// move as many spaces as possible. report spaces
// remove ghost. do not report
// fail if unable to move. report
class BishopAction extends Action {
  final Direction direction;

  const BishopAction(Player player, this.direction) : super(player);

  Future<void> resolve(Game game) async {
    this.player.removeSpecialType<BishopSpecial>();

    var offset = max(game.grid.height, game.grid.width);
    var newPoint = this.movePoint(game, offset);
    var newTile = game.grid.getOrBorder(newPoint);
    while (!newTile.canMoveTo(game, this.player, newPoint, true) && offset > 0) {
      offset -= 1;
      newPoint = this.movePoint(game, offset);
      newTile = game.grid.getOrBorder(newPoint);
    }

    await game.sendPlayerReport(TeleportMoveActionReport(this.player, this.direction, offset));
    if (offset == 0) return;

    await newTile.onMoveTo(game, this.player, newPoint, true);
  }

  int movePoint(Game game, int offset) {
    return game.grid.offsetPoint(this.player.point, this.direction, offset: offset);
  }
}

class BishopSpecial extends Special {
  const BishopSpecial();

  action(Player player, Direction direction) => BishopAction(player, direction);
}

// move as many spaces as possible. report spaces
// remove ghost. do not report
// fail if unable to move. report
class RookAction extends Action {
  final Direction direction;

  const RookAction(Player player, this.direction) : super(player);

  Future<void> resolve(Game game) async {
    this.player.removeSpecialType<RookSpecial>();

    var offset = max(game.grid.height, game.grid.width);
    var newPoint = this.movePoint(game, offset);
    var newTile = game.grid.getOrBorder(newPoint);
    while (!newTile.canMoveTo(game, this.player, newPoint, true) && offset > 0) {
      offset -= 1;
      newPoint = this.movePoint(game, offset);
      newTile = game.grid.getOrBorder(newPoint);
    }

    await game.sendPlayerReport(TeleportMoveActionReport(this.player, this.direction, offset));
    if (offset == 0) return;

    await newTile.onMoveTo(game, this.player, newPoint, true);
  }

  movePoint(Game game, int offset) {
    return game.grid.offsetPoint(this.player.point, this.direction, offset: offset);
  }
}

class RookSpecial extends Special {
  const RookSpecial();

  action(Player player, Direction direction) => RookAction(player, direction);
}

// move diagonal
// remove ghost. do not report
// fail if wall. report
class DiagonalAction extends Action {
  final Direction direction;

  const DiagonalAction(Player player, this.direction) : super(player);

  Future<void> resolve(Game game) async {
    this.player.removeSpecialType<DiagonalSpecial>();

    await game.sendPlayerReport(DiagonalMoveActionReport(this.player, this.direction));

    final newPoint = game.grid.offsetPoint(this.player.point, this.direction);
    final newTile = game.grid.getOrBorder(newPoint);
    await newTile.onMoveTo(game, this.player, newPoint, true);
  }
}

class DiagonalSpecial extends Special {
  const DiagonalSpecial();

  action(Player player, Direction direction) => DiagonalAction(player, direction);
}

// teleport 2 spaces
// remove ghost. do not report
// fail if wall. report
class HopStepAction extends Action {
  final Direction direction;
  final int distance;

  const HopStepAction(Player player, this.direction, {this.distance = 2}) : super(player);

  Future<void> resolve(Game game) async {
    this.player.removeSpecialType<HopStepSpecial>();

    await game.sendPlayerReport(TeleportMoveActionReport(this.player, this.direction, this.distance));

    final newPoint = game.grid.offsetPoint(this.player.point, this.direction, offset: this.distance);
    final newTile = game.grid.getOrBorder(newPoint);
    await newTile.onMoveTo(game, this.player, newPoint, true);
  }
}

class HopStepSpecial extends Special {
  const HopStepSpecial();

  action(Player player, Direction direction) => HopStepAction(player, direction);
}

// move 180 around map
// remove ghost. do not report
// fail if unable to move. report
class PointSymmetricAction extends Action {
  const PointSymmetricAction(Player player) : super(player);

  Future<void> resolve(Game game) async {
    this.player.removeSpecialType<PointSymmetricSpecial>();

    await game.sendPlayerReport(TeleportPlayerReport(this.player));

    final newPoint = this.movePoint(game);
    final newTile = game.grid.getOrBorder(newPoint);
    await newTile.onMoveTo(game, this.player, newPoint, true);
  }

  movePoint(Game game) {
    final entry = game.grid.pointToXY(this.player.point);
    final x = entry.item1;
    final y = entry.item2;
    final width = game.grid.width;
    final height = game.grid.height;

    return game.grid.pointFromXY(width - x - 1, height - y - 1);
  }
}

class PointSymmetricSpecial extends Special {
  const PointSymmetricSpecial();

  action(Player player) => PointSymmetricAction(player);
}

// move to starting space
// do additional move OR attack
class BackToStartAction extends Action {
  const BackToStartAction(Player player) : super(player);

  Future<void> resolve(Game game) async {
    this.player.removeSpecialType<BackToStartSpecial>();

    final newPoint = this.movePoint(game);
    final newTile = game.grid.getOrBorder(newPoint);
    await newTile.onMoveTo(game, this.player, newPoint, true);

    await game.sendPlayerReport(BackToStartTeleportActionReport(this.player));
    final action = await this.player.handleBackToStartAction();
    await action.resolve(game);
  }

  int movePoint(Game game) {
    final entry = game.grid.items.entries
        .where((entry) => entry.value is StartTile)
        .map((entry) => MapEntry(entry.key, entry.value as StartTile))
        .singleWhere((entry) => entry.value.player == this.player);

    return entry.key;
  }
}

class BackToStartSpecial extends Special {
  const BackToStartSpecial();

  action(Player player) => BackToStartAction(player);
}

// can only be used when bumping into ghost
class AntiGhostBarrierSpecial extends Special {
  const AntiGhostBarrierSpecial();
}
