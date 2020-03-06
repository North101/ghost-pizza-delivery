
void main() => readMap();

const MAP = 
'ww  t1  ww    \n'
'  t2  s1  ww  \n'
'gggg      h1t3\n'
'gg  gg  s2  p1\n'
'  p2ggp3      \n'
'gg  h2  s3    \n'
'ww    h3      ';

void readMap() async {
  final tiles = [];

  final map = MAP;
  int lineCount = 0;
  int lineLength;
  for (final row in map.split('\n')) {
    if (row.isEmpty) {
      throw 'Row $lineCount is empty';
    } else if (!row.length.isEven) {
      throw 'Row length should be even';
    } else if (lineLength == null) {
      lineLength = row.length;
    } else if (lineLength != row.length) {
      throw 'Row $lineCount length inconsistent with previous lines. Expected: $lineLength. Got: ${row.length}';
    }

    for (int column = 0; column < lineLength; column += 2) {
      final cell = row.substring(column, column + 2);
      if (cell == '  ') {
        tiles.add(EmptyTile());
      } else if (cell == 'ww') {
        tiles.add(WallTile());
      } else if (cell == 'gg') {
        tiles.add(GhostTile());
      } else if (cell[0] == 's') {
        final index = int.tryParse(cell[1]);
        if (index == null) {
          throw '[Ln ${lineCount}, Col ${column}] Invalid tile: $cell';
        }
        tiles.add(StartTile(index));
      } else if (cell[0] == 'p') {
        final index = int.tryParse(cell[1]);
        if (index == null) {
          throw '[Ln ${lineCount}, Col ${column}] Invalid tile: $cell';
        }
        tiles.add(PizzaTile(index));
      } else if (cell[0] == 'h') {
        final index = int.tryParse(cell[1]);
        if (index == null) {
          throw '[Ln ${lineCount}, Col ${column}] Invalid tile: $cell';
        }
        tiles.add(HouseTile(index));
      } else if (cell[0] == 't') {
        final index = int.tryParse(cell[1]);
        if (index == null) {
          throw '[Ln ${lineCount}, Col ${column}] Invalid tile: $cell';
        }
        tiles.add(TeleporterTile(index));
      } else {
        throw '[Ln ${lineCount}, Col ${column}] Invalid tile: $cell';
      }

      lineCount++;
    }
  }

  final startTiles = tiles.whereType<StartTile>().toList();
  if (startTiles.isEmpty) {
    throw 'No starting tiles';
  }
  startTiles.sort((a, b) => a.index.compareTo(b.index));
  startTiles.fold<int>(1, (value, tile) {
    if (value == tile.index) return tile.index + 1;
    throw 'Expected $value. Got ${tile.index}';
  });

  final pizzaTiles = tiles.whereType<PizzaTile>().toList();
  pizzaTiles.sort((a, b) => a.index.compareTo(b.index));
  pizzaTiles.fold<int>(1, (value, tile) {
    if (value == tile.index) return tile.index + 1;
    throw 'Expected $value. Got ${tile.index}';
  });

  final houseTiles = tiles.whereType<HouseTile>().toList();
  houseTiles.sort((a, b) => a.index.compareTo(b.index));
  houseTiles.fold<int>(1, (value, tile) {
    if (value == tile.index) return tile.index + 1;
    throw 'Expected $value. Got ${tile.index}';
  });

  if (![pizzaTiles.length, houseTiles.length].every((tiles) => tiles == startTiles.length)) {
    throw 'Need same number of players, pizzas and houses';
  }

  final teleporterTiles = tiles.whereType<TeleporterTile>().toList();
  teleporterTiles.sort((a, b) => a.index.compareTo(b.index));
  teleporterTiles.fold<int>(1, (value, tile) {
    if (value == tile.index) return tile.index + 1;
    throw 'Expected $value. Got ${tile.index}';
  });
  if (teleporterTiles.length == 1) {
    throw 'Teleporter Error';
  }
}

abstract class Tile {
  const Tile();
}

class EmptyTile extends Tile {}

class WallTile extends Tile {}

class GhostTile extends Tile {}

class IndexTile extends Tile {
  final int index;
  const IndexTile(this.index);
}

class StartTile extends IndexTile {
  const StartTile(int index) : super(index);
}

class TeleporterTile extends IndexTile {
  const TeleporterTile(int index) : super(index);
}

class PizzaTile extends IndexTile {
  const PizzaTile(int index) : super(index);
}

class HouseTile extends IndexTile {
  const HouseTile(int index) : super(index);
}
