import 'package:cli/cli.dart';
import 'package:cli/options.dart';

main(List<String> args) async {
  var options = parseOptions(args);

  await startGame(
    options.players,
    seed: options.seed,
    showMap: options.map,
    rounds: options.rounds,
    width: options.width,
    height: options.height,
    walls: options.walls,
    graves: options.graves,
    teleporters: options.teleporters,
    crows: options.crows,
    monkeys: options.monkeys,
    pigs: options.pigs,
    manholes: options.manholes,
  );
}
