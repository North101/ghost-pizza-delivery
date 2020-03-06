import 'dart:collection';
import 'dart:math';

import 'package:tuple/tuple.dart';

import 'directions.dart';
import 'game.dart';
import 'player.dart';
import 'tiles.dart';

class Grid {
  final items = Map<int, Tile>();
  final int width;
  final int height;
  final Random random;
  final BorderTile border = BorderTile();

  Grid(this.random, {this.width = 7, this.height = 7}) {
    for (var i = 0; i < width * height; i++) {
      this.items[i] = EmptyTile();
    }
  }

  int pointFromXY(int x, int y) {
    if (x < 0 || y < 0 || x >= this.width || y >= this.height) return null;

    return (y * this.width) + x;
  }

  Tuple2<int, int> pointToXY(int point) {
    final y = (point / this.width).floor();
    final x = point - (y * this.width);

    return Tuple2(x, y);
  }

  int offsetPoint(int point, Direction direction, {int offset = 1}) {
    final entry = this.pointToXY(point);
    final x = entry.item1;
    final y = entry.item2;
    switch (direction) {
      case Direction.North:
        return this.pointFromXY(x, y - offset);
      case Direction.NorthEast:
        return this.pointFromXY(x + offset, y - offset);
      case Direction.East:
        return this.pointFromXY(x + offset, y);
      case Direction.SouthEast:
        return this.pointFromXY(x + offset, y + offset);
      case Direction.South:
        return this.pointFromXY(x, y + offset);
      case Direction.SouthWest:
        return this.pointFromXY(x - offset, y + offset);
      case Direction.West:
        return this.pointFromXY(x - offset, y);
      case Direction.NorthWest:
        return this.pointFromXY(x - offset, y - offset);
    }

    return null;
  }

  Map<Direction, int> adjacentPoints(int point) {
    return {
      Direction.North: this.offsetPoint(point, Direction.North),
      Direction.East: this.offsetPoint(point, Direction.East),
      Direction.South: this.offsetPoint(point, Direction.South),
      Direction.West: this.offsetPoint(point, Direction.West),
    };
  }

  Map<Direction, Tile> adjacentTiles(int point) {
    return this
        .adjacentPoints(point)
        .map((direction, adjacentPoint) => MapEntry(direction, this.getOrBorder(adjacentPoint)));
  }

  Map<Direction, int> surroundingPoints(int point) {
    return {
      Direction.North: this.offsetPoint(point, Direction.North),
      Direction.NorthEast: this.offsetPoint(point, Direction.NorthEast),
      Direction.East: this.offsetPoint(point, Direction.East),
      Direction.SouthEast: this.offsetPoint(point, Direction.SouthEast),
      Direction.South: this.offsetPoint(point, Direction.South),
      Direction.SouthWest: this.offsetPoint(point, Direction.SouthWest),
      Direction.West: this.offsetPoint(point, Direction.West),
      Direction.NorthWest: this.offsetPoint(point, Direction.NorthWest),
    };
  }

  Map<Direction, Tile> surroundingTiles(int point) {
    return this
        .surroundingPoints(point)
        .map((direction, surroundingPoint) => MapEntry(direction, this.getOrBorder(surroundingPoint)));
  }

  Tile getOrBorder(int point) {
    if (point == null || !this.items.containsKey(point)) return this.border;
    return this.items[point];
  }

  int randomPoint(bool condition(MapEntry<int, Tile> entry)) {
    final randomPoint = (this.items.entries.toList()..shuffle(this.random)).firstWhere(condition, orElse: () => null);
    if (randomPoint == null) throw StateError("Could not place tile");

    return randomPoint.key;
  }

  bool isValid(List<Player> players) {
    final startTiles = this.items.values.whereType<StartTile>().map((tile) => tile.player);

    return this.items.entries.every((item) => item.value.isValid(this, item.key)) &&
        players.every((player) => startTiles.contains(player));
  }
}

extension<T> on Iterable<T> {
  Map<K, V> toMap<K, V>(MapEntry<K, V> Function(T value) predicate) => Map<K, V>.fromEntries(this.map(predicate));
}

void randomizeGameGrid(
  Game game, {
  int walls = 4,
  int graves = 6,
  int teleporters = 3,
  int monkeys = 0,
  int pigs = 0,
  int crows = 0,
  int manholes = 0,
}) {
  final grid = game.grid;
  final players = game.players;

  bool isAdjacentEmpty(int point) {
    final tile = grid.getOrBorder(point);

    return tile is EmptyTile &&
        !tile.safe &&
        grid.adjacentPoints(point).values.every((adjacentPoint) => grid.getOrBorder(adjacentPoint) is EmptyTile);
  }

  void initPlayers() {
    if (players.length <= 1) throw StateError('Not enough players');

    players.forEach((player) {
      final point = grid.randomPoint((entry) => isAdjacentEmpty(entry.key));
      player.point = point;

      grid.items[point] = StartTile(player);
      grid.adjacentTiles(point).forEach((direction, tile) {
        if (tile is EmptyTile) {
          tile.safe = true;
        } else {
          throw Error();
        }
      });
    });
  }

  void initPizza(int count) {
    final toppings = game.toppings.toList();
    if (toppings.length < count) throw StateError('Not enough toppings');

    (toppings..shuffle(grid.random)).take(count).forEach((topping) {
      final pizzaPoint = grid.randomPoint((entry) {
        final tile = entry.value;
        return tile is EmptyTile && !tile.safe;
      });
      grid.items[pizzaPoint] = PizzaTile(topping);

      final housePoint = grid.randomPoint((entry) {
        final tile = entry.value;
        return tile is EmptyTile && !tile.safe && !grid.adjacentPoints(entry.key).values.contains(pizzaPoint);
      });
      grid.items[housePoint] = HouseTile(topping);
    });
  }

  void initGhosts(int count) {
    for (var i = 0; i < count; i++) {
      final point = grid.randomPoint((entry) {
        final tile = entry.value;
        return tile is EmptyTile && !tile.safe;
      });
      ;
      grid.items[point] = GraveTile();
    }
  }

  bool areAllNodesVisitable(int point) {
    // find all visitable nodes
    final visitableNodes = grid.items.entries
      // remove all walls and the current point (as we are trying to set that as a new Wall)
      .where((entry) => !(entry.value is WallTile || entry.key == point))
      .toMap((entry) => MapEntry(entry.key, false));

    if (visitableNodes.isEmpty) return false;

    // find our starting node
    final node = visitableNodes.keys.first;
    // mark as visited
    visitableNodes[node] = true;

    // queue of nodes to visit
    final checkAdjacentNodes = Queue.of([node]);
    // keep checking until no more nodes can be found
    while (checkAdjacentNodes.isNotEmpty) {
      // remove the node (so we don't check it again)
      final node = checkAdjacentNodes.removeFirst();
      grid.adjacentPoints(node).values.forEach((adjacentPoint) {
        // if we haven't visited an adjacent node
        if (visitableNodes[adjacentPoint] == false) {
          // mark as visited
          visitableNodes[adjacentPoint] = true;
          // add it to our queue
          checkAdjacentNodes.add(adjacentPoint);
        }
      });
    }

    // check if any node hasn't been visited
    return !visitableNodes.containsValue(false);
  }

  void initWalls(int count) {
    Stopwatch stopwatch = Stopwatch()..start();
    for (var _ = 0; _ < count; _++) {
      final point = grid.randomPoint((entry) {
        final tile = entry.value;
        return tile is EmptyTile && !tile.safe && areAllNodesVisitable(entry.key);
      });
      grid.items[point] = WallTile();
    }
    print('initWalls(int $count) executed in ${stopwatch.elapsed}');
  }

  void initTeleporters(int count) {
    if (count <= 0) {
      return;
    } else if (count == 1) throw StateError('Can\'t have only 1 teleporter');

    final firstPoint = grid.randomPoint((entry) {
      final randomTile = entry.value;
      return randomTile is EmptyTile && !randomTile.safe;
    });
    var nextPoint = firstPoint;
    for (var i = 0; i < count - 1; i++) {
      final point = nextPoint;
      nextPoint = grid.randomPoint((entry) {
        final randomPoint = entry.key;
        final randomTile = entry.value;
        return randomTile is EmptyTile && !randomTile.safe && randomPoint != point;
      });
      grid.items[point] = TeleporterTile(nextPoint);
    }
    grid.items[nextPoint] = TeleporterTile(firstPoint);
  }

  void initMonkey(int count) {
    for (var i = 0; i < count; i++) {
      final point = grid.randomPoint((entry) {
        final tile = entry.value;
        return tile is EmptyTile && !tile.safe;
      });
      grid.items[point] = MonkeyTile();
    }
  }

  void initCrow(int count) {
    for (var i = 0; i < count; i++) {
      final point = grid.randomPoint((entry) {
        final tile = entry.value;
        return tile is EmptyTile && !tile.safe;
      });
      grid.items[point] = CrowTile();
    }
  }

  void initPigs(int count) {
    if (count == 0) return;

    {
      final point = grid.randomPoint((entry) {
        final tile = entry.value;
        return tile is EmptyTile && !tile.safe;
      });
      grid.items[point] = PigTile(true);
    }
    for (var i = 0; i < count; i++) {
      final point = grid.randomPoint((entry) {
        final tile = entry.value;
        return tile is EmptyTile && !tile.safe;
      });
      grid.items[point] = PigTile(false);
    }
  }

  void initManhole(int count) {
    for (var i = 0; i < count; i++) {
      final point = grid.randomPoint((entry) {
        final tile = entry.value;
        return tile is EmptyTile && !tile.safe;
      });
      grid.items[point] = ManholeCoverTile();
    }
  }

  initPlayers();
  initPizza(players.length);
  initGhosts(graves);
  initWalls(walls);
  initTeleporters(teleporters);
  initMonkey(monkeys);
  initCrow(crows);
  initPigs(pigs);
  initManhole(manholes);
}
