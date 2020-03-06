import 'package:tuple/tuple.dart';

import 'actions.dart';
import 'game.dart';
import 'grid.dart';
import 'player.dart';
import 'reports.dart';
import 'token.dart';
import 'topping.dart';

abstract class Tile {
  bool ghost = false;
  bool isValid(Grid grid, int point);
  bool canMoveTo(Game game, Player player, int point, bool teleport);
  Future<void> onMoveTo(Game game, Player player, int point, bool teleport);
  Future<void> onAttackAt(Game game, Player player, int point);
  bool reportAsWall();
  bool reportAsGhost();
  bool reportAsPizza();
  bool reportAsHouse();
}

abstract class BaseTile extends Tile {
  bool get ghost => false;
  set ghost(bool value) => null;

  bool canMoveTo(Game game, Player player, int point, bool teleport) {
    return point != null;
  }

  Future<void> onMoveTo(Game game, Player player, int point, bool teleport) async {
    if (point == null || player.point == point) return null;

    if (teleport) {
      this.ghost = false;
    } else if (this.ghost) {
      await game.sendPlayerReport(BumpedIntoGhostPlayerReport(player));

      if (!player.hasSpecialType<AntiGhostBarrierSpecial>()) return null;

      final useSpecial = await player.handleAntiGhostBarrierSpecial();
      if (!useSpecial) return null;

      player.removeSpecialType<AntiGhostBarrierSpecial>();
      await game.sendPlayerReport(UseSpecialReport(player, AntiGhostBarrierSpecial()));

      this.ghost = false;
      await game.sendPlayerReport(ChaseAwayGhostPlayerReport(player));
    }
    player.point = point;
  }

  Future<void> onAttackAt(Game game, Player player, int point) async {
    if (this.ghost) {
      this.ghost = false;
      await game.sendPlayerReport(ChaseAwayGhostPlayerReport(player));
      await game.givePlayerSpecial(player);
    } else {
      await game.sendPlayerReport(GhostNotFoundPlayerReport(player));
    }
  }

  bool reportAsWall() => false;

  bool reportAsGhost() => this.ghost;

  bool reportAsPizza() => false;

  bool reportAsHouse() => false;
}

class EmptyTile extends BaseTile {
  bool ghost = false;
  bool safe = false;
  bool isValid(Grid grid, int point) => true;
}

class StartTile extends BaseTile {
  final Player player;

  StartTile(this.player);

  bool isValid(Grid grid, int point) {
    return grid.adjacentPoints(point).values.every((adjacentPoint) => grid.getOrBorder(adjacentPoint) is EmptyTile);
  }
}

class WallTile extends BaseTile {
  bool isValid(Grid grid, int point) => true;

  bool canMoveTo(Game game, Player player, int point, bool teleport) => false;

  Future<void> onMoveTo(Game game, Player player, int point, bool teleport) async {
    await game.sendPlayerReport(BumpedIntoWallPlayerReport(player));
  }

  bool reportAsWall() => true;
}

class BorderTile extends WallTile {}

class PizzaTile extends BaseTile {
  final Topping topping;
  bool found = false;

  PizzaTile(this.topping);

  bool isValid(Grid grid, int point) {
    return !grid.adjacentPoints(point).values.any((adjacentPoint) {
      final adjacentTile = grid.getOrBorder(adjacentPoint);

      return (adjacentTile is HouseTile) && adjacentTile.topping == this.topping;
    });
  }

  Future<void> onMoveTo(Game game, Player player, int point, bool teleport) async {
    if (point == null || player.point == point) return;

    player.point = point;
    if (!this.found) {
      if (player.topping == null) {
        player.topping = this.topping;
        game.spawnHouse(game.players, this);

        await game.sendPlayerReport(FoundPizzaPlayerReport(player, this.topping));
      } else {
        await game.sendPlayerReport(FoundPizzaPlayerReport(player, null));
      }
    }
  }

  bool reportAsPizza() => !this.found;
}

class HouseTile extends BaseTile {
  final Topping topping;
  bool spawned = false;

  HouseTile(this.topping);

  bool isValid(Grid grid, int point) {
    return !grid.adjacentPoints(point).values.any((adjacentPoint) {
          final adjacentTile = grid.getOrBorder(adjacentPoint);

          return adjacentTile is PizzaTile && adjacentTile.topping == this.topping;
        }) &&
        grid.items.values.where((tile) => tile is PizzaTile && tile.topping == this.topping).length == 1;
  }

  Future<void> onMoveTo(Game game, Player player, int point, bool teleport) async {
    if (point == null || player.point == point) return;

    player.point = point;
    if (this.spawned) {
      await game.sendPlayerReport(FoundHousePlayerReport(player));
      if (this.topping == player.topping) {
        player.won = game.round();

        await game.sendPlayerReport(WinReport(player, game.round(), game.maxRounds));
      }
    }
  }

  bool reportAsHouse() => this.spawned;
}

class TeleporterTile extends BaseTile {
  final int nextPoint;

  TeleporterTile(this.nextPoint);

  bool isValid(Grid grid, int point) {
    return point != this.nextPoint && grid.getOrBorder(this.nextPoint) is TeleporterTile;
  }

  Future<void> onMoveTo(Game game, Player player, int point, bool _teleport) async {
    player.point = this.nextPoint;

    await game.sendPlayerReport(TeleporterPlayerReport(player));
    await game.sendPlayerReport(TeleportPlayerReport(player));
  }
}

class GraveTile extends BaseTile {
  bool _ghost = true;
  bool get ghost => this._ghost;
  set ghost(bool value) {
    // don't respawn ghosts
    if (this._ghost && !value) {
      this._ghost = value;
    }
  }

  bool isValid(Grid grid, int point) => true;
}

class PigTile extends BaseTile {
  final bool parent;

  PigTile(this.parent);

  isValid(Grid grid, int point) => true;

  Future<void> onMoveTo(Game game, Player player, int point, bool teleport) async {
    await super.onMoveTo(game, player, point, teleport);
    await game.sendPlayerReport(PigFoundPlayerReport(player, this.parent));
  }
}

class MonkeyTile extends BaseTile {
  bool found = false;

  isValid(Grid _grid, int _point) => true;

  Future<void> onMoveTo(Game game, Player player, int point, bool teleport) async {
    await super.onMoveTo(game, player, point, teleport);
    if (this.found) return;

    this.found = true;
    player.addToken(MonkeyToken());
    await game.sendPlayerReport(MonkeyFoundPlayerReport(player));
  }
}

class CrowTile extends BaseTile {
  bool found = false;

  isValid(Grid _grid, int _point) => true;

  Future<void> onAttackAt(Game game, Player player, int point) async {
    if (this.found || point == null) {
      await super.onAttackAt(game, player, point);
      return;
    }

    await game.sendPlayerReport(CrowAttackedPlayerReport(player));

    this.found = true;
    player.addToken(CrowToken());

    final pointXY = game.grid.pointToXY(point);
    final houses = game.grid.items.entries
        .where((entry) => entry.value is HouseTile)
        .map((entry) => MapEntry(entry.key, entry.value as HouseTile))
        .map((entry) {
      final housePointXY = game.grid.pointToXY(entry.key);
      return Tuple3(entry.key, entry.value,
          (pointXY.item1 - housePointXY.item1).abs() + (pointXY.item2 - housePointXY.item2).abs());
    }).toList();

    if (houses.isEmpty) return;

    houses.sort((a, b) {
      final distance = a.item3.compareTo(b.item3);
      if (distance != 0) return distance;

      final topping = a.item2.topping.toString().compareTo(b.item2.topping.toString());
      if (topping != 0) return topping;

      return a.item1.compareTo(b.item1);
    });

    player.point = houses.first.item1;
    await game.sendPlayerReport(CrowTeleportPlayerReport(player));
  }
}

class ManholeCoverTile extends BaseTile {
  isValid(Grid _grid, int _point) => true;

  Future<void> onMoveTo(Game game, Player player, int point, bool teleport) async {
    await super.onMoveTo(game, player, point, teleport);
    await game.sendPlayerReport(ManholeCoverPlayerReport(player));
  }

  reportAsPizza() => true;
}
