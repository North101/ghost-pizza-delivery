import 'package:flutter/material.dart';
import 'package:pizza_ghost_delivery/reports.dart';
import 'package:pizza_ghost_delivery/directions.dart';

abstract class ReportWidget<T extends Report> implements Widget {
  final T report;

  ReportWidget(this.report);
}

class TurnStartReportWidget extends StatelessWidget implements ReportWidget<TurnStartReport> {
  final TurnStartReport report;

  const TurnStartReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class TurnEndReportWidget extends StatelessWidget implements ReportWidget<TurnEndReport> {
  final TurnEndReport report;

  const TurnEndReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Adjacent Walls: ${report.walls.isNotEmpty ? report.walls.map((direction) => report.player.direction(direction, true).name).join(", ") : 'None'}',
        ),
        if (report.ghosts != null)
          Text(
            'Near Ghosts: ${report.ghosts.isNotEmpty ? (report.ghosts.map((direction) => report.player.direction(direction, true).name).join(', ')) : ('None')}',
          )
        else
          Text('Near Ghosts: ${report.nearGhosts ? ('Yes') : ('No')}'),
        if (report.pizza != null)
          Text(
            'Near Pizza: ${report.pizza.isNotEmpty ? (report.pizza.map((direction) => report.player.direction(direction, true).name).join(', ')) : ('None')}',
          )
        else
          Text('Near Pizza: ${report.nearPizza ? ('Yes') : ('No')}'),
        if (report.houses != null)
          Text(
            'Near Houses: ${report.houses.isNotEmpty ? (report.houses.map((direction) => report.player.direction(direction, true).name).join(', ')) : ('None')}',
          )
        else
          Text('Near Houses: ${report.nearHouses ? ('Yes') : ('No')}'),
      ],
    );
  }
}

class WinReportWidget extends StatelessWidget implements ReportWidget<WinReport> {
  final WinReport report;

  const WinReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('Congratulations! You delivered your pizza on turn ${report.round}!');
  }
}

class ReceiveSpecialReportWidget extends StatelessWidget implements ReportWidget<ReceiveSpecialReport> {
  final ReceiveSpecialReport report;

  const ReceiveSpecialReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You received ${report.special}');
  }
}

class UseSpecialReportWidget extends StatelessWidget implements ReportWidget<UseSpecialReport> {
  final UseSpecialReport report;

  const UseSpecialReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You used ${report.special}');
  }
}

class AttackActionReportWidget extends StatelessWidget implements ReportWidget<AttackActionReport> {
  final AttackActionReport report;

  const AttackActionReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You attacked ${report.player.direction(report.direction, true)}');
  }
}

class ChaseAwayGhostPlayerReportWidget extends StatelessWidget implements ReportWidget<ChaseAwayGhostPlayerReport> {
  final ChaseAwayGhostPlayerReport report;

  const ChaseAwayGhostPlayerReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You chased away a ghost');
  }
}

class GhostNotFoundPlayerReportWidget extends StatelessWidget implements ReportWidget<GhostNotFoundPlayerReport> {
  final GhostNotFoundPlayerReport report;

  const GhostNotFoundPlayerReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('Your attack failed. There is no ghost in that square');
  }
}

class MoveActionReportWidget extends StatelessWidget implements ReportWidget<MoveActionReport> {
  final MoveActionReport report;

  const MoveActionReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You moved ${report.player.direction(report.direction, true).name}');
  }
}

class DiagonalMoveActionReportWidget extends StatelessWidget implements ReportWidget<DiagonalMoveActionReport> {
  final DiagonalMoveActionReport report;

  const DiagonalMoveActionReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You moved ${report.player.direction(report.direction, true).name}');
  }
}

class BumpedIntoWallPlayerReportWidget extends StatelessWidget implements ReportWidget<BumpedIntoWallPlayerReport> {
  final BumpedIntoWallPlayerReport report;

  const BumpedIntoWallPlayerReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You bumped into a wall and were sent back');
  }
}

class BumpedIntoGhostPlayerReportWidget extends StatelessWidget implements ReportWidget<BumpedIntoGhostPlayerReport> {
  final BumpedIntoGhostPlayerReport report;

  const BumpedIntoGhostPlayerReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You bumped into a ghost and were sent back');
  }
}

class TeleportMoveActionReportWidget extends StatelessWidget implements ReportWidget<TeleportMoveActionReport> {
  final TeleportMoveActionReport report;

  const TeleportMoveActionReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You teleported ${report.count} spaces ${report.player.direction(report.direction, true).name}');
  }
}

class BackToStartTeleportActionReportWidget extends StatelessWidget
    implements ReportWidget<BackToStartTeleportActionReport> {
  final BackToStartTeleportActionReport report;

  const BackToStartTeleportActionReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You teleported to your starting space');
  }
}

class TeleportPlayerReportWidget extends StatelessWidget implements ReportWidget<TeleportPlayerReport> {
  final TeleportPlayerReport report;

  const TeleportPlayerReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You were teleported!!');
  }
}

class FoundPizzaPlayerReportWidget extends StatelessWidget implements ReportWidget<FoundPizzaPlayerReport> {
  final FoundPizzaPlayerReport report;

  const FoundPizzaPlayerReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (report.topping != null) {
      return Text('You found a pizza! It\'s the ${report.topping.name} pizza!');
    } else if (report.player.topping != null) {
      return Text('You found a pizza! But you must deliver the ${report.player.topping.name} pizza first!');
    } else {
      return Text('You found a pizza! But you already have something strange in your hands...');
    }
  }
}

class FoundHousePlayerReportWidget extends StatelessWidget implements ReportWidget<FoundHousePlayerReport> {
  final FoundHousePlayerReport report;

  const FoundHousePlayerReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You found a house!');
  }
}

class TeleporterPlayerReportWidget extends StatelessWidget implements ReportWidget<TeleporterPlayerReport> {
  final TeleporterPlayerReport report;

  const TeleporterPlayerReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You were teleported!!');
  }
}

class PigFoundPlayerReportWidget extends StatelessWidget implements ReportWidget<PigFoundPlayerReport> {
  final PigFoundPlayerReport report;

  const PigFoundPlayerReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You found a ${report.parent ? 'rather large' : 'little'} Pig. OINK!');
  }
}

class MonkeyFoundPlayerReportWidget extends StatelessWidget implements ReportWidget<MonkeyFoundPlayerReport> {
  final MonkeyFoundPlayerReport report;

  const MonkeyFoundPlayerReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You found a monkey. yack-yack!');
  }
}

class CrowAttackedPlayerReportWidget extends StatelessWidget implements ReportWidget<CrowAttackedPlayerReport> {
  final CrowAttackedPlayerReport report;

  const CrowAttackedPlayerReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You attacked a crow.');
  }
}

class CrowTeleportPlayerReportWidget extends StatelessWidget implements ReportWidget<CrowTeleportPlayerReport> {
  final CrowTeleportPlayerReport report;

  const CrowTeleportPlayerReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('You were teleported to the nearest signboard.');
  }
}

class ManholeCoverPlayerReportWidget extends StatelessWidget implements ReportWidget<ManholeCoverPlayerReport> {
  final ManholeCoverPlayerReport report;

  const ManholeCoverPlayerReportWidget({Key key, this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('You found a pizza! It\'s the Metal pizza!'),
        Text('... on closer inspection, it\'s just a manhole cover'),
      ],
    );
  }
}
