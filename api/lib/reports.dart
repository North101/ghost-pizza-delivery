import 'actions.dart';
import 'directions.dart';
import 'player.dart';
import 'topping.dart';

class Report {}

abstract class PlayerReport implements Report {
  final Player player;

  const PlayerReport(this.player);
}

class TurnStartReport extends PlayerReport {
  final int round;
  final int maxRounds;

  const TurnStartReport(Player player, this.round, this.maxRounds) : super(player);
}

class TurnEndReport extends PlayerReport {
  final int round;
  final int maxRounds;
  final Set<Direction> walls;
  final bool nearGhosts;
  final Set<Direction> ghosts;
  final bool nearPizza;
  final Set<Direction> pizza;
  final bool nearHouses;
  final Set<Direction> houses;

  const TurnEndReport(
    Player player,
    this.round,
    this.maxRounds,
    this.walls,
    this.nearGhosts,
    this.ghosts,
    this.nearPizza,
    this.pizza,
    this.nearHouses,
    this.houses,
  ) : super(player);
}

class WinReport extends PlayerReport {
  final int round;
  final int maxRounds;

  const WinReport(Player player, this.round, this.maxRounds) : super(player);
}

class ReceiveSpecialReport extends PlayerReport {
  final Special special;

  const ReceiveSpecialReport(Player player, this.special) : super(player);
}

class UseSpecialReport extends PlayerReport {
  final Special special;

  const UseSpecialReport(Player player, this.special) : super(player);
}

abstract class ActionReport extends PlayerReport {
  const ActionReport(Player player) : super(player);
}

class AttackActionReport extends ActionReport {
  final Direction direction;

  const AttackActionReport(Player player, this.direction) : super(player);
}

class MoveActionReport extends ActionReport {
  final Direction direction;

  const MoveActionReport(Player player, this.direction) : super(player);
}

class TeleportMoveActionReport extends ActionReport {
  final Direction direction;
  final int count;

  const TeleportMoveActionReport(Player player, this.direction, this.count) : super(player);
}

class DiagonalMoveActionReport extends ActionReport {
  final Direction direction;

  const DiagonalMoveActionReport(Player player, this.direction) : super(player);
}

class BackToStartTeleportActionReport extends ActionReport {
  const BackToStartTeleportActionReport(Player player) : super(player);
}

class TeleporterPlayerReport extends PlayerReport {
  const TeleporterPlayerReport(Player player) : super(player);
}

class TeleportPlayerReport extends PlayerReport {
  const TeleportPlayerReport(Player player) : super(player);
}

class FoundPizzaPlayerReport extends PlayerReport {
  final Topping topping;

  const FoundPizzaPlayerReport(Player player, this.topping) : super(player);
}

class FoundHousePlayerReport extends PlayerReport {
  const FoundHousePlayerReport(Player player) : super(player);
}

class BumpedIntoWallPlayerReport extends PlayerReport {
  const BumpedIntoWallPlayerReport(Player player) : super(player);
}

class BumpedIntoGhostPlayerReport extends PlayerReport {
  const BumpedIntoGhostPlayerReport(Player player) : super(player);
}

class ChaseAwayGhostPlayerReport extends PlayerReport {
  const ChaseAwayGhostPlayerReport(Player player) : super(player);
}

class GhostNotFoundPlayerReport extends PlayerReport {
  const GhostNotFoundPlayerReport(Player player) : super(player);
}

class PigFoundPlayerReport extends PlayerReport {
  final bool parent;

  const PigFoundPlayerReport(Player player, this.parent) : super(player);
}

class MonkeyFoundPlayerReport extends PlayerReport {
  const MonkeyFoundPlayerReport(Player player) : super(player);
}

class CrowAttackedPlayerReport extends PlayerReport {
  const CrowAttackedPlayerReport(Player player) : super(player);
}

class CrowTeleportPlayerReport extends PlayerReport {
  const CrowTeleportPlayerReport(Player player) : super(player);
}

class ManholeCoverPlayerReport extends PlayerReport {
  const ManholeCoverPlayerReport(Player player) : super(player);
}
