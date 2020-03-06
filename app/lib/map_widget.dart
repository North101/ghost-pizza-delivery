import 'package:flutter/material.dart';
import 'package:pizza_ghost_delivery/game.dart';
import 'package:pizza_ghost_delivery/tiles.dart';

List<Widget> gridToWidgets(Game game) {
  final grid = game.grid;
  final playerPoints = Map.fromEntries(game.players.map((player) => MapEntry(player.point, player)));

  return List.generate(grid.height * grid.width, (point) => MapEntry(point, grid.items[point])).map<Widget>((entry) {
    final point = entry.key;
    final tile = entry.value;
    final player = playerPoints[point];

    if (player != null) {
      return Text('P');
    } else if (tile.ghost) {
      return Text('👻');
    } else if (tile is EmptyTile) {
      return Text('🆓');
    } else if (tile is StartTile) {
      return Text('👣');
    } else if (tile is TeleporterTile) {
      return Text('🌀');
    } else if (tile is GraveTile) {
      return Text('⚰️ ');
    } else if (tile is HouseTile) {
      return Text((tile.spawned ? '🏠' : '🚧'));
    } else if (tile is PizzaTile) {
      return Text((tile.found ? '🥡' : '🍕'));
    } else if (tile is WallTile) {
      return Text('⛔');
    } else if (tile is CrowTile) {
      return Text(tile.found ? '🆓' : '🦜');
    } else if (tile is MonkeyTile) {
      return Text(tile.found ? '🆓' : '🐒');
    } else if (tile is PigTile) {
      return Text('🐖');
    } else if (tile is ManholeCoverTile) {
      return Text('Ⓜ️ ');
    }
    return Text('?');
  });
}

class MapWidget extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;

  const MapWidget({Key key, this.crossAxisCount, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: this.crossAxisCount,
      children: this.children,
    );
  }
}
