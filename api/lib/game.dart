import 'dart:math';

import 'actions.dart';
import 'directions.dart';
import 'grid.dart';
import 'player.dart';
import 'reports.dart';
import 'tiles.dart';
import 'token.dart';
import 'topping.dart';

class Deck<T> {
  final List<T> drawPile;
  final List<T> discardPile;
  final Random random;

  Deck(this.drawPile, this.discardPile, this.random);

  T draw() {
    if (this.drawPile.isEmpty) {
      this.shuffle();
    }
    final card = this.drawPile.removeLast();
    return card;
  }

  void discard(T item) {
    this.discardPile.add(item);
  }

  void shuffle() {
    this.drawPile.addAll(this.discardPile);
    this.discardPile.clear();
    this.drawPile.shuffle(this.random);
  }
}

abstract class GameOverError extends Error {}

class AllPlayersWonError extends GameOverError {}

class ReachedLastRound extends GameOverError {}

class EndGameError extends GameOverError {}

abstract class Game {
  final List<Player> players;
  final Set<Topping> toppings;
  final Grid grid;
  final Deck<Special> specials;
  int turn = 0;
  int maxRounds;

  Game(this.players, this.toppings, this.grid, this.specials, {this.maxRounds = 20});

  currentPlayer() => this.players[this.turn % this.players.length];
  round() => ((this.turn / this.players.length) + 1).floor();
  checkAllPlayersWon() => this.players.every((player) => player.won != null);
  isLastRound() => this.maxRounds != null ? this.round() > this.maxRounds : false;

  Future<void> loop() async {
    if (this.checkAllPlayersWon()) {
      throw AllPlayersWonError();
    } else if (this.isLastRound()) {
      throw ReachedLastRound();
    }

    final player = this.currentPlayer();
    if (player.won == null) {
      await this.sendPlayerReport(TurnStartReport(player, this.round(), this.maxRounds));

      final action = await player.handleTurn();
      await action.resolve(this);

      await this.sendPlayerTurnEndReport(player);
    }

    this.turn++;
  }

  Future<void> sendPlayerTurnEndReport(Player player) async {
    final point = player.point;
    final adjacentTiles = this.grid.adjacentTiles(point);
    final surroundingTiles = this.grid.surroundingTiles(point);

    final walls = Set<Direction>.from(
        adjacentTiles.entries.where((entry) => entry.value.reportAsWall()).map((entry) => entry.key));
    final ghosts = Set<Direction>.from(
        surroundingTiles.entries.where((entry) => entry.value.reportAsGhost()).map((entry) => entry.key));
    final pizza = Set<Direction>.from(
        surroundingTiles.entries.where((entry) => entry.value.reportAsPizza()).map((entry) => entry.key));
    final houses = Set<Direction>.from(
        surroundingTiles.entries.where((entry) => entry.value.reportAsHouse()).map((entry) => entry.key));

    await this.sendPlayerReport(TurnEndReport(
      player,
      this.round(),
      this.maxRounds,
      walls,
      ghosts.isNotEmpty,
      null,
      pizza.isNotEmpty,
      player.hasTokenType<MonkeyToken>() ? pizza : null,
      houses.isNotEmpty,
      null,
    ));
  }

  Future<void> sendPlayerReport(Report report);

  Future<void> givePlayerSpecial(Player player) async {
    final special = this.specials.draw();
    if (special != null) {
      player.addSpecial(special);
      await this.sendPlayerReport(ReceiveSpecialReport(player, special));
    }
  }

  void spawnHouse(List<Player> players, PizzaTile pizzaTile) {
    if (pizzaTile.found) throw Error();
    pizzaTile.found = true;

    final house = this
        .grid
        .items
        .entries
        .where((entry) => entry.value is HouseTile)
        .map((entry) => MapEntry(entry.key, entry.value as HouseTile))
        .singleWhere((entry) => entry.value.topping == pizzaTile.topping);

    final housePoint = house.key;
    final houseTile = house.value;
    if (houseTile.spawned) throw Error();

    this.grid.surroundingPoints(housePoint).forEach((direction, point) {
      if (point == null) return;

      final hasPlayer = players.any((Player p) => p.point == point);
      if (hasPlayer) return;

      final tile = this.grid.getOrBorder(point);
      tile.ghost = true;
    });
    houseTile.spawned = true;
  }
}
