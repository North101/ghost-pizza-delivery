import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'options.g.dart';

@CliOptions()
class Options {
  @CliOption(
    name: 'seed',
    abbr: 's',
    nullable: true,
    help: 'Game seed',
  )
  final String seed;

  @CliOption(
    name: 'players',
    abbr: 'p',
    defaultsTo: 3,
    help: 'Number of players',
  )
  final int players;

  @CliOption(
    name: 'map',
    abbr: 'm',
    defaultsTo: false,
    help: 'Show debug map',
  )
  final bool map;

  @CliOption(
    name: 'rounds',
    defaultsTo: 20,
    help: 'rounds',
  )
  final int rounds;

  @CliOption(
    name: 'width',
    defaultsTo: 7,
    help: 'width of the map',
  )
  final int width;

  @CliOption(
    name: 'height',
    defaultsTo: 7,
    help: 'height of the map',
  )
  final int height;

  @CliOption(
    name: 'walls',
    defaultsTo: 4,
    help: 'number of walls',
  )
  final int walls;
  
  @CliOption(
    name: 'graves',
    defaultsTo: 6,
    help: 'number of graves',
  )
  final int graves;
  
  @CliOption(
    name: 'teleporters',
    defaultsTo: 3,
    help: 'number of teleporters',
  )
  final int teleporters;
  
  @CliOption(
    name: 'crows',
    defaultsTo: 0,
    help: 'number of crows',
  )
  final int crows;
  
  @CliOption(
    name: 'monkeys',
    defaultsTo: 0,
    help: 'number of monkeys',
  )
  final int monkeys;
  
  @CliOption(
    name: 'pigs',
    defaultsTo: 0,
    help: 'number of pigs',
  )
  final int pigs;
  
  @CliOption(
    name: 'manholes',
    defaultsTo: 0,
    help: 'number of manholes',
  )
  final int manholes;

  Options(this.seed, this.players, this.map, this.rounds, this.width, this.height, this.walls, this.graves, this.teleporters, this.crows, this.monkeys, this.pigs, this.manholes);
}