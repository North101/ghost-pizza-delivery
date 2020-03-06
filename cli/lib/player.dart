import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:prompts/prompts.dart' as prompts;
import 'package:tuple/tuple.dart';

import 'package:pizza_ghost_delivery/actions.dart';
import 'package:pizza_ghost_delivery/directions.dart';
import 'package:pizza_ghost_delivery/player.dart';
import 'package:pizza_ghost_delivery/reports.dart';

final green = AnsiPen()..green();
final bgGreen = AnsiPen()..green(bg: true);
final red = AnsiPen()..red();
final bgRed = AnsiPen()..red(bg: true);
final blue = AnsiPen()..blue();
final bgBlue = AnsiPen()..blue(bg: true);
final magenta = AnsiPen()..magenta();
final bgMagenta = AnsiPen()..magenta(bg: true);
final cyan = AnsiPen()..cyan();
final bgCyan = AnsiPen()..cyan(bg: true);

class CancelAction extends Error {}

class PlayerCli extends Player {
  final String emoji;

  PlayerCli(List<Special> specials, this.emoji, {Direction rotate, bool reverseRotate = false}) {
    this.specials.addAll(specials);
    this.rotate = rotate;
    this.reverseRotate = reverseRotate;
  }

  // remove specials
  Future<Action> handleTurn() async {
    while (true) {
      try {
        final input =
            await prompts.choose("What would you like to do?", ['move', 'attack', 'special', 'skip', 'end game']);
        switch (input) {
          case 'move':
            return MoveAction(this, await this.handleOrthologicalDirection());
          case 'attack':
            return AttackAction(this, await this.handleOrthologicalDirection());
          case 'special':
            return await this.handleSpecial();
          case 'skip':
            return SkipAction(this);
          case 'end game':
            return EndGameAction(this);
          default:
            print('Invalid choice: ${input}');
        }
      } on CancelAction {
        continue;
      }
    }
  }

  Future<Action> handleSpecial() async {
    while (true) {
      final List<Tuple2<String, bool>> items = [
        Tuple2('bishop', this.hasSpecialType<BishopSpecial>()),
        Tuple2('rook', this.hasSpecialType<RookSpecial>()),
        Tuple2('diagonal', this.hasSpecialType<DiagonalSpecial>()),
        Tuple2('hopstep', this.hasSpecialType<HopStepSpecial>()),
        Tuple2('rotate', this.hasSpecialType<PointSymmetricSpecial>()),
        Tuple2('start', this.hasSpecialType<BackToStartSpecial>()),
        Tuple2('cancel', true),
      ];
      final input =
          await prompts.choose("Which special", items.where((value) => value.item2).map((value) => value.item1));

      switch (input) {
        case 'bishop':
          return BishopAction(this, await this.handleDiagonalDirection());
        case 'rook':
          return RookAction(this, await this.handleOrthologicalDirection());
        case 'diagonal':
          return DiagonalAction(this, await this.handleDiagonalDirection());
        case 'hopstep':
          return HopStepAction(this, await this.handleOrthologicalDirection());
        case 'rotate':
          return PointSymmetricAction(this);
        case 'start':
          return BackToStartAction(this);
        case 'cancel':
          throw CancelAction();
        default:
          print('Invalid choice: ${input}');
      }
    }
  }

  Future<Direction> handleOrthologicalDirection() async {
    while (true) {
      final input = await prompts.choose('Which direction?', ['north', 'east', 'south', 'west', 'cancel']);
      switch (input) {
        case 'north':
          return this.direction(Direction.North);
        case 'east':
          return this.direction(Direction.East);
        case 'south':
          return this.direction(Direction.South);
        case 'west':
          return this.direction(Direction.West);
        case 'cancel':
          throw CancelAction();
        default:
          print('Invalid choice: ${input}');
      }
    }
  }

  Future<Direction> handleDiagonalDirection() async {
    while (true) {
      final input =
          await prompts.choose('Which direction?', ['northeast', 'southeast', 'southwest', 'northwest', 'cancel']);
      switch (input) {
        case 'northeast':
          return this.direction(Direction.NorthEast);
        case 'southeast':
          return this.direction(Direction.SouthEast);
        case 'southwest':
          return this.direction(Direction.SouthWest);
        case 'northwest':
          return this.direction(Direction.NorthWest);
        case 'cancel':
          throw CancelAction();
        default:
          print('Invalid choice: ${input}');
      }
    }
  }

  // remove special if used
  Future<bool> handleAntiGhostBarrierSpecial() async {
    return await prompts.getBool('Use Anti-Ghost Barrier?');
  }

  Future<Action> handleBackToStartAction() async {
    while (true) {
      try {
        final input = await prompts.choose('What would you like to do?', ['move', 'attack', 'skip']);
        switch (input) {
          case 'move':
            return MoveAction(this, await this.handleOrthologicalDirection());
          case 'attack':
            return AttackAction(this, await this.handleOrthologicalDirection());
          case 'skip':
            return SkipAction(this);
          default:
            print('Invalid choice: ${input}');
        }
      } on CancelAction {
        continue;
      }
    }
  }

  toString() {
    return this.emoji;
  }

  Future<void> receiveReport(Report report) async {
    if (report is TurnStartReport) {
      print('${this.emoji} round ${report.round} / ${report.maxRounds ?? 'Infinity'}');

      final specials = this.specials.isEmpty
          ? 'None'
          : Set.from(this.specials)
              .map((special) => '${special.runtimeType} x${this.specials.where((y) => y == special).length}')
              .join(', ');
      print('Specials: ${specials}');

      final tokens = this.tokens.isEmpty
          ? 'None'
          : Set.from(this.tokens)
              .map((token) => '${token.runtimeType} x${this.tokens.where((y) => y == token).length}')
              .join(', ');
      print('Tokens: ${tokens}');

      print('Pizza: ${this.topping?.name ?? 'None'}');
      print(' ');
    } else if (report is TurnEndReport) {
      print(' ');

      print('${this.emoji} report:');
      final specials = this.specials.isEmpty
          ? 'None'
          : Set.from(this.specials)
              .map((special) => '${special.runtimeType} x${this.specials.where((y) => y == special).length}')
              .join(', ');
      print('Specials: ${specials}');

      final tokens = this.tokens.isEmpty
          ? 'None'
          : Set.from(this.tokens)
              .map((token) => '${token.runtimeType} x${this.tokens.where((y) => y == token).length}')
              .join(', ');
      print('Tokens: ${tokens}');

      print('Pizza: ${this.topping?.name ?? 'None'}');
      print(' ');

      print(
          'Adjacent Walls: ${report.walls.isNotEmpty ? green(report.walls.map((direction) => this.direction(direction, true).name).join(", ")) : red('None')}');
      if (report.ghosts != null) {
        print(
            'Near Ghosts: ${report.ghosts.isNotEmpty ? green(report.ghosts.map((direction) => this.direction(direction, true).name).join(', ')) : red('None')}');
      } else {
        print('Near Ghosts: ${report.nearGhosts ? green('Yes') : red('No')}');
      }
      if (report.pizza != null) {
        print(
            'Near Pizza: ${report.pizza.isNotEmpty ? green(report.pizza.map((direction) => this.direction(direction, true).name).join(', ')) : red('None')}');
      } else {
        print('Near Pizza: ${report.nearPizza ? green('Yes') : red('No')}');
      }
      if (report.houses != null) {
        print(
            'Near Houses: ${report.houses.isNotEmpty ? green(report.houses.map((direction) => this.direction(direction, true).name).join(', ')) : red('None')}');
      } else {
        print('Near Houses: ${report.nearHouses ? green('Yes') : red('No')}');
      }
    } else if (report is WinReport) {
      print('Congratulations! ${this.emoji} delivered their pizza on turn ${report.round}!');
    } else if (report is ReceiveSpecialReport) {
      print((magenta('${this.emoji} received ${report.special}')));
    } else if (report is UseSpecialReport) {
      print((magenta('${this.emoji} used ${report.special}')));
    } else if (report is AttackActionReport) {
      print('${this.emoji} attacked ${this.direction(report.direction, true).name}');
    } else if (report is ChaseAwayGhostPlayerReport) {
      print((red('${this.emoji} chased away a ghost')));
    } else if (report is GhostNotFoundPlayerReport) {
      print((bgRed('${this.emoji} attack failed. There is no ghost in that square')));
    } else if (report is MoveActionReport) {
      print('${this.emoji} moved ${this.direction(report.direction, true).name}');
    } else if (report is DiagonalMoveActionReport) {
      print('${this.emoji} moved ${this.direction(report.direction, true).name}');
    } else if (report is BumpedIntoWallPlayerReport) {
      print((bgRed('${this.emoji} bumped into a wall and was sent back')));
    } else if (report is BumpedIntoGhostPlayerReport) {
      print((bgRed('${this.emoji} bumped into a ghost and was sent back')));
    } else if (report is TeleportMoveActionReport) {
      print(
          (magenta('${this.emoji} teleported ${report.count} spaces ${this.direction(report.direction, true).name}')));
    } else if (report is BackToStartTeleportActionReport) {
      print((magenta('${this.emoji} teleported to their starting space')));
    } else if (report is TeleportPlayerReport) {
      print(bgMagenta('${this.emoji} was teleported!!'));
    } else if (report is FoundPizzaPlayerReport) {
      if (report.topping != null) {
        print(bgBlue('${this.emoji} found a pizza! It\'s the ${report.topping.name} pizza!'));
      } else if (report.player.topping != null) {
        print((blue('${this.emoji} found a pizza! But they already have the ${report.player.topping.name} pizza...')));
      } else {
        print((red('${this.emoji} found a pizza! But they already have something strange in their hands...')));
      }
    } else if (report is FoundHousePlayerReport) {
      print((blue('${this.emoji} found a house!')));
    } else if (report is TeleporterPlayerReport) {
      print('${this.emoji} entered a teleporter');
    } else if (report is PigFoundPlayerReport) {
      print((cyan('${this.emoji} found a ${report.parent ? 'rather large' : 'little'} Pig. OINK!')));
    } else if (report is MonkeyFoundPlayerReport) {
      print((cyan('${this.emoji} found a monkey. yack-yack!')));
    } else if (report is CrowAttackedPlayerReport) {
      print((cyan('${this.emoji} attacked a crow.')));
    } else if (report is CrowTeleportPlayerReport) {
      print('${this.emoji} was teleported to the nearest signboard.');
    } else if (report is ManholeCoverPlayerReport) {
      print(bgBlue('${this.emoji} found a pizza! It\'s the...'));
      await sleep(Duration(seconds: 1));
      print(bgRed('... on closer inspection, it\'s just a manhole cover'));
    } else {
      print(report);
    }
  }
}
