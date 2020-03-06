import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ansicolor/ansicolor.dart';
import 'package:prompts/prompts.dart' as prompts;
import 'package:console/console.dart';

import 'package:pizza_ghost_delivery/actions.dart';
import 'package:pizza_ghost_delivery/game.dart';
import 'package:pizza_ghost_delivery/grid.dart';
import 'package:pizza_ghost_delivery/tiles.dart';
import 'package:pizza_ghost_delivery/topping.dart';

import 'player.dart';
import 'game.dart';

final bgNone = AnsiPen();
final bgGreen = AnsiPen()..green(bg: true);
final bgRed = AnsiPen()..red(bg: true);
final bgBlue = AnsiPen()..blue(bg: true);
final bgMagenta = AnsiPen()..magenta(bg: true);
final bgYellow = AnsiPen()..yellow(bg: true);
final bgCyan = AnsiPen()..cyan(bg: true);
final bgGray = AnsiPen()..gray(bg: true);
final bgOrange = AnsiPen()..rgb(r: 1, g: 0.64, b: 0, bg: true);
final bgBrown = AnsiPen()..rgb(r: 165 / 255, g: 42 / 255, b: 42 / 255, bg: true);
final bgPink = AnsiPen()..rgb(r: 255 / 255, g: 182 / 255, b: 193 / 255, bg: true);

AnsiPen colorTopping(Topping topping) {
  if (topping is ShrimpTopping) {
    return bgRed;
  } else if (topping is VegtableTopping) {
    return bgGreen;
  } else if (topping is CheeseTopping) {
    return bgYellow;
  } else if (topping is PepporoniTopping) {
    return bgRed;
  } else if (topping is AnchovyTopping) {
    return bgGray;
  } else if (topping is PineappleTopping) {
    return bgOrange;
  } else if (topping is MushroomTopping) {
    return bgBrown;
  } else if (topping is JalapenoTopping) {
    return bgGreen;
  } else if (topping is PlainTopping) {
    return bgNone;
  }

  return bgNone;
}

String asciiGrid(Grid grid, List<PlayerCli> players) {
  final playerPoints = Map.fromEntries(players.map((player) => MapEntry(player.point, player)));

  return List.generate(grid.height * grid.width, (point) => MapEntry(point, grid.items[point])).map((entry) {
    final point = entry.key;
    final tile = entry.value;
    final player = playerPoints[point];

    if (player != null) {
      return MapEntry(point, colorTopping(player.topping)(player.emoji));
    } else if (tile.ghost) {
      return MapEntry(point, '👻');
    } else if (tile is EmptyTile) {
      return MapEntry(point, '🆓');
    } else if (tile is StartTile) {
      return MapEntry(point, '👣');
    } else if (tile is TeleporterTile) {
      return MapEntry(point, '🌀');
    } else if (tile is GraveTile) {
      return MapEntry(point, '⚰️ ');
    } else if (tile is HouseTile) {
      return MapEntry(point, colorTopping(tile.topping)(tile.spawned ? '🏠' : '🚧'));
    } else if (tile is PizzaTile) {
      return MapEntry(point, colorTopping(tile.topping)(tile.found ? '🥡' : '🍕'));
    } else if (tile is WallTile) {
      return MapEntry(point, '⛔');
    } else if (tile is CrowTile) {
      return MapEntry(point, tile.found ? '🆓' : '🦜');
    } else if (tile is MonkeyTile) {
      return MapEntry(point, tile.found ? '🆓' : '🐒');
    } else if (tile is PigTile) {
      return MapEntry(point, '🐖');
    } else if (tile is ManholeCoverTile) {
      return MapEntry(point, 'Ⓜ️ ');
    }
    throw StateError(tile.toString());
  }).fold("", (curr, next) {
    curr += next.value;
    if (next.key % grid.width == (grid.width - 1)) {
      curr += '\n';
    }
    return curr;
  });
}

void clearLines(int count) {
  for (var i = 0; i < count; i++) {
    Console.previousLine();
    Console.eraseLine();
  }
}

void printReplay(String seed, String subtitle, String map) {
  print('Seed: $seed');
  print('Replay');
  print(subtitle);
  print(' ');
  print(map);
}

final maxInt = 4294967296;
Random nextRandom(Random random) {
  return Random(random.nextInt(maxInt));
}

final playerEmojis = [
  '🐵',
  '🐶',
  '🐺',
  '🦊',
  '🐱',
  '🦁',
  '🐯',
  '🐴',
  '🦄',
  '🐮',
  '🐷',
  '🐭',
  '🐹',
  '🐰',
  '🐻',
  '🐼',
  '🐸',
  '🐲',
];

String encodeSeed(int seed) => base64Url.encode(Uint8List.view(Int64List.fromList([seed]).buffer));
int decodeSeed(String seed) => Uint8List.fromList(base64Url.decode(seed)).buffer.asInt64List().first;

Future<void> startGame(
  int playerCount, {
  String seed,
  bool showMap = false,
  int rounds = 20,
  int width = 7,
  int height = 7,
  int walls = 4,
  int graves = 6,
  int teleporters = 3,
  int crows = 0,
  int monkeys = 0,
  int pigs = 0,
  int manholes = 0,
}) async {
  if (seed == null) {
    seed = encodeSeed(Random().nextInt(maxInt));
  }
  final random = Random(decodeSeed(seed));
  print('Seed: ${seed}');

  final starterDeck = Deck<Special>([
    BishopSpecial(),
    RookSpecial(),
    DiagonalSpecial(),
    HopStepSpecial(),
    PointSymmetricSpecial(),
    BackToStartSpecial(),
    AntiGhostBarrierSpecial(),
  ], List(), nextRandom(random))
    ..shuffle();

  final playerEmojiDeck = Deck<String>(playerEmojis, List(), nextRandom(random))..shuffle();

  final players = List<PlayerCli>();
  for (var i = 0; i < playerCount; i++) {
    players.add(PlayerCli([starterDeck.draw(), starterDeck.draw()], playerEmojiDeck.draw()));
  }

  final toppings = const {
    ShrimpTopping(),
    VegtableTopping(),
    CheeseTopping(),
    PepporoniTopping(),
    AnchovyTopping(),
    PineappleTopping(),
    MushroomTopping(),
    JalapenoTopping(),
    PlainTopping(),
  };

  final deck = Deck<Special>([
    BishopSpecial(),
    RookSpecial(),
    DiagonalSpecial(),
    HopStepSpecial(),
    PointSymmetricSpecial(),
    BackToStartSpecial(),
    AntiGhostBarrierSpecial(),
    BishopSpecial(),
    RookSpecial(),
    DiagonalSpecial(),
    HopStepSpecial(),
    PointSymmetricSpecial(),
    BackToStartSpecial(),
    AntiGhostBarrierSpecial(),
  ], List(), nextRandom(random))
    ..shuffle();

  final game =
      GameCli(players, toppings, Grid(nextRandom(random), width: width, height: height), deck, maxRounds: rounds);
  randomizeGameGrid(
    game,
    walls: walls,
    graves: graves,
    teleporters: teleporters,
    crows: crows,
    monkeys: monkeys,
    pigs: pigs,
    manholes: manholes,
  );

  print('Players: ${players.map((player) => player.emoji).join(' ')}\n');
  final replay = List<String>();
  {
    final map = asciiGrid(game.grid, players);
    replay.add(map);
    if (showMap) {
      print(map);
      print(' ');
    }
  }
  while (true) {
    try {
      await game.loop();
      print(' ');

      final map = asciiGrid(game.grid, players);
      replay.add(map);
      if (showMap) {
        print(map);
        print(' ');
      }

      if (!game.isLastRound()) {
        print(' ');
        await prompts.get('Next Player', conceal: true, validate: (value) => true);
      }
    } on GameOverError catch (exception) {
      if (exception is ReachedLastRound) {
        final response = await prompts.getBool('You\'ve reached the last round. Continue?');
        if (response) {
          game.maxRounds = null;
          continue;
        }
      }
      print(' ');
      while (true) {
        for (final entry in replay.asMap().entries) {
          final index = entry.key;
          final map = entry.value;

          var subtitle;
          if (index == 0) {
            subtitle = 'Start';
          } else {
            final playerLength = game.players.length;
            final turn = (index - 1);
            final player = players[turn % playerLength];
            final currentRound = ((turn / playerLength) + 1).floor();
            final totalRounds = (((game.turn - 1) / playerLength) + 1).floor();
            subtitle = '${player.emoji} round ${currentRound} / ${totalRounds}';
          }
          printReplay(seed, subtitle, map);
          await sleep(Duration(seconds: 1));
          clearLines(game.grid.height + 5);
        }
        printReplay(seed, 'Finished', replay[replay.length - 1]);
        await sleep(Duration(seconds: 1));
        clearLines(game.grid.height + 5);
      }
    }
  }
}
