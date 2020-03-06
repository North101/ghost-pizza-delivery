import 'package:pizza_ghost_delivery/actions.dart';
import 'package:pizza_ghost_delivery/game.dart';
import 'package:pizza_ghost_delivery/grid.dart';
import 'package:pizza_ghost_delivery/player.dart';
import 'package:pizza_ghost_delivery/reports.dart';
import 'package:pizza_ghost_delivery/topping.dart';

class GameCli extends Game {
  GameCli(List<Player> players, Set<Topping> toppings, Grid grid, Deck<Special> specials, {int maxRounds = 20})
      : super(players, toppings, grid, specials, maxRounds: maxRounds);

  Future<void> sendPlayerReport(Report report) async {
    if (report is PlayerReport) {
      await report.player.receiveReport(report);
    } else {
      throw StateError(report.toString());
    }
  }
}
