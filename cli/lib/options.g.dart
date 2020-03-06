// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

T _$badNumberFormat<T extends num>(
        String source, String type, String argName) =>
    throw FormatException(
        'Cannot parse "$source" into `$type` for option "$argName".');

Options _$parseOptionsResult(ArgResults result) => Options(
    result['seed'] as String,
    int.tryParse(result['players'] as String) ??
        _$badNumberFormat(result['players'] as String, 'int', 'players'),
    result['map'] as bool,
    int.tryParse(result['rounds'] as String) ??
        _$badNumberFormat(result['rounds'] as String, 'int', 'rounds'),
    int.tryParse(result['width'] as String) ??
        _$badNumberFormat(result['width'] as String, 'int', 'width'),
    int.tryParse(result['height'] as String) ??
        _$badNumberFormat(result['height'] as String, 'int', 'height'),
    int.tryParse(result['walls'] as String) ??
        _$badNumberFormat(result['walls'] as String, 'int', 'walls'),
    int.tryParse(result['graves'] as String) ??
        _$badNumberFormat(result['graves'] as String, 'int', 'graves'),
    int.tryParse(result['teleporters'] as String) ??
        _$badNumberFormat(
            result['teleporters'] as String, 'int', 'teleporters'),
    int.tryParse(result['crows'] as String) ??
        _$badNumberFormat(result['crows'] as String, 'int', 'crows'),
    int.tryParse(result['monkeys'] as String) ??
        _$badNumberFormat(result['monkeys'] as String, 'int', 'monkeys'),
    int.tryParse(result['pigs'] as String) ??
        _$badNumberFormat(result['pigs'] as String, 'int', 'pigs'),
    int.tryParse(result['manholes'] as String) ??
        _$badNumberFormat(result['manholes'] as String, 'int', 'manholes'));

ArgParser _$populateOptionsParser(ArgParser parser) => parser
  ..addOption('seed', abbr: 's', help: 'Game seed')
  ..addOption('players', abbr: 'p', help: 'Number of players', defaultsTo: '3')
  ..addFlag('map', abbr: 'm', help: 'Show debug map', defaultsTo: false)
  ..addOption('rounds', help: 'rounds', defaultsTo: '20')
  ..addOption('width', help: 'width of the map', defaultsTo: '7')
  ..addOption('height', help: 'height of the map', defaultsTo: '7')
  ..addOption('walls', help: 'number of walls', defaultsTo: '4')
  ..addOption('graves', help: 'number of graves', defaultsTo: '6')
  ..addOption('teleporters', help: 'number of teleporters', defaultsTo: '3')
  ..addOption('crows', help: 'number of crows', defaultsTo: '0')
  ..addOption('monkeys', help: 'number of monkeys', defaultsTo: '0')
  ..addOption('pigs', help: 'number of pigs', defaultsTo: '0')
  ..addOption('manholes', help: 'number of manholes', defaultsTo: '0');

final _$parserForOptions = _$populateOptionsParser(ArgParser());

Options parseOptions(List<String> args) {
  final result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
