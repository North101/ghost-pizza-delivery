import 'dart:async';
import 'dart:math';

import 'package:app/report_widget.dart';
import 'package:flutter/material.dart';
import 'package:pizza_ghost_delivery/actions.dart' as actions;
import 'package:pizza_ghost_delivery/directions.dart';
import 'package:pizza_ghost_delivery/game.dart';
import 'package:pizza_ghost_delivery/grid.dart';
import 'package:pizza_ghost_delivery/player.dart';
import 'package:pizza_ghost_delivery/reports.dart';
import 'package:pizza_ghost_delivery/topping.dart';

class AppGame extends Game {
  AppGame(List<Player> players, Set<Topping> toppings, Grid grid, Deck<actions.Special> specials, {int maxRounds = 20})
      : super(players, toppings, grid, specials, maxRounds: maxRounds);

  @override
  Future<void> sendPlayerReport(Report report) async {
    if (report is PlayerReport) {
      return await report.player.receiveReport(report);
    }
  }
}

abstract class AppPlayerHandler {
  Future<bool> handleAntiGhostBarrierSpecial(AppPlayer player);

  Future<actions.Action> handleBackToStartAction(AppPlayer player);

  Future<actions.Action> handleTurn(AppPlayer player);

  Future<void> receiveReport(AppPlayer appPlayer, Report report);
}

class AppPlayer extends Player {
  final AppPlayerHandler handler;

  AppPlayer(List<actions.Special> specials, this.handler) {
    this.specials.addAll(specials);
  }

  @override
  Future<bool> handleAntiGhostBarrierSpecial() {
    return this.handler.handleAntiGhostBarrierSpecial(this);
  }

  @override
  Future<actions.Action> handleBackToStartAction() {
    return this.handler.handleBackToStartAction(this);
  }

  @override
  Future<actions.Action> handleTurn() async {
    return this.handler.handleTurn(this);
  }

  @override
  Future<void> receiveReport(Report report) async {
    return this.handler.receiveReport(this, report);
  }
}

abstract class GameState implements Widget {}

class InitGameState extends StatelessWidget implements GameState {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      MyButton(
        text: const Text('Start'),
        onPressed: () {
          final gamePage = GamePage.of(context);

          gamePage.setReports(List());

          final player = gamePage.game.currentPlayer();
          gamePage.game.loop().then((value) {
            gamePage.setGameState(PlayerEndTurnGameState(player));
          });
        },
      ),
    ]);
  }
}

abstract class PlayerGameState implements GameState {
  final AppPlayer player;

  PlayerGameState(this.player);
}

class PlayerTurnGameState extends StatelessWidget implements PlayerGameState {
  final AppPlayer player;
  final Completer<actions.Action> completer = Completer();

  PlayerTurnGameState(this.player);

  move(Direction direction) {
    this.completer.complete(actions.MoveAction(this.player, direction));
  }

  attack(Direction direction) {
    this.completer.complete(actions.AttackAction(this.player, direction));
  }

  special(actions.Action action) {
    this.completer.complete(action);
  }

  skip() {
    this.completer.complete(actions.SkipAction(this.player));
  }

  @override
  Widget build(BuildContext context) {
    final gamePage = GamePage.of(context);

    return Column(children: <Widget>[
      MyButton(
        text: const Text('Move'),
        onPressed: () {
          gamePage.setGameState(PlayerOrthagonalDirectionGameState(
            this.player,
            this.move,
            () => gamePage.setGameState(this),
          ));
        },
      ),
      MyButton(
        text: const Text('Attack'),
        onPressed: () {
          gamePage.setGameState(PlayerOrthagonalDirectionGameState(
            this.player,
            this.attack,
            () => gamePage.setGameState(this),
          ));
        },
      ),
      MyButton(
          text: const Text('Special'),
          onPressed: () {
            gamePage.setGameState(PlayerSpecialGameState(
              this.player,
              this.special,
              () => gamePage.setGameState(this),
            ));
          }),
      MyButton(
        text: const Text('Skip'),
        onPressed: this.skip,
        color: Colors.red,
      ),
    ]);
  }
}

class PlayerAntiBarrierSpecialGameState extends StatelessWidget implements PlayerGameState {
  final AppPlayer player;
  final Completer<bool> completer = Completer();

  PlayerAntiBarrierSpecialGameState(this.player);

  yes() {
    this.completer.complete(true);
  }

  no() {
    this.completer.complete(false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      MyButton(
        text: const Text('Yes'),
        onPressed: this.yes,
      ),
      MyButton(
        text: const Text('No'),
        onPressed: this.no,
      ),
    ]);
  }
}

class PlayerBackToStartSpecialGameState extends StatelessWidget implements PlayerGameState {
  final AppPlayer player;
  final Completer<actions.Action> completer = Completer();

  PlayerBackToStartSpecialGameState(this.player);

  move(Direction direction) {
    this.completer.complete(actions.MoveAction(this.player, direction));
  }

  attack(Direction direction) {
    this.completer.complete(actions.AttackAction(this.player, direction));
  }

  skip() {
    this.completer.complete(actions.SkipAction(this.player));
  }

  @override
  Widget build(BuildContext context) {
    final gamePage = GamePage.of(context);

    return Column(children: <Widget>[
      MyButton(
        text: const Text('Move'),
        onPressed: () {
          gamePage.setGameState(PlayerOrthagonalDirectionGameState(
            this.player,
            this.move,
            () => gamePage.setGameState(this),
          ));
        },
      ),
      MyButton(
        text: const Text('Attack'),
        onPressed: () {
          gamePage.setGameState(PlayerOrthagonalDirectionGameState(
            this.player,
            this.attack,
            () => gamePage.setGameState(this),
          ));
        },
      ),
      MyButton(
        text: const Text('Skip'),
        onPressed: this.skip,
        color: Colors.red,
      ),
    ]);
  }
}

class PlayerEndTurnGameState extends StatelessWidget implements PlayerGameState {
  final AppPlayer player;

  PlayerEndTurnGameState(this.player);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      MyButton(
        text: const Text('Next Player'),
        onPressed: () {
          final gamePage = GamePage.of(context);

          gamePage.setReports(List());

          final player = gamePage.game.currentPlayer();
          gamePage.game.loop().then((value) {
            gamePage.setGameState(PlayerEndTurnGameState(player));
          });
        },
      ),
    ]);
  }
}

class PlayerOrthagonalDirectionGameState extends StatelessWidget implements PlayerGameState {
  final AppPlayer player;
  final Function(Direction direction) callback;
  final Function() cancel;

  PlayerOrthagonalDirectionGameState(this.player, this.callback, this.cancel);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      MyButton(
        text: const Text('North'),
        onPressed: () => this.callback(Direction.North),
      ),
      MyButton(
        text: const Text('East'),
        onPressed: () => this.callback(Direction.East),
      ),
      MyButton(
        text: const Text('South'),
        onPressed: () => this.callback(Direction.South),
      ),
      MyButton(
        text: const Text('West'),
        onPressed: () => this.callback(Direction.West),
      ),
      MyButton(
        text: const Text('Cancel'),
        onPressed: this.cancel,
        color: Colors.red,
      ),
    ]);
  }
}

class PlayerDiagonalDirectionGameState extends StatelessWidget implements PlayerGameState {
  final AppPlayer player;
  final Function(Direction direction) callback;
  final Function() cancel;

  PlayerDiagonalDirectionGameState(this.player, this.callback, this.cancel);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      MyButton(
        text: const Text('North East'),
        onPressed: () => this.callback(Direction.NorthEast),
      ),
      MyButton(
        text: const Text('South East'),
        onPressed: () => this.callback(Direction.SouthEast),
      ),
      MyButton(
        text: const Text('South West'),
        onPressed: () => this.callback(Direction.SouthWest),
      ),
      MyButton(
        text: const Text('North West'),
        onPressed: () => this.callback(Direction.NorthWest),
      ),
      MyButton(
        text: const Text('Cancel'),
        onPressed: this.cancel,
        color: Colors.red,
      ),
    ]);
  }
}

class PlayerSpecialGameState extends StatelessWidget implements PlayerGameState {
  final AppPlayer player;
  final Function(actions.Action) callback;
  final Function() cancel;

  PlayerSpecialGameState(this.player, this.callback, this.cancel);

  @override
  Widget build(BuildContext context) {
    final gamePage = GamePage.of(context);

    return Column(children: <Widget>[
      player.hasSpecialType<actions.BishopSpecial>()
          ? MyButton(
              text: const Text('Bishop'),
              onPressed: () {
                gamePage.setGameState(PlayerDiagonalDirectionGameState(
                  this.player,
                  this.bishop,
                  () => gamePage.setGameState(this),
                ));
              },
            )
          : Container(),
      player.hasSpecialType<actions.RookSpecial>()
          ? MyButton(
              text: const Text('Rook'),
              onPressed: () {
                gamePage.setGameState(PlayerOrthagonalDirectionGameState(
                  this.player,
                  this.rook,
                  () => gamePage.setGameState(this),
                ));
              },
            )
          : Container(),
      player.hasSpecialType<actions.DiagonalSpecial>()
          ? MyButton(
              text: const Text('Diagonal'),
              onPressed: () {
                gamePage.setGameState(PlayerDiagonalDirectionGameState(
                  this.player,
                  this.diagonal,
                  () => gamePage.setGameState(this),
                ));
              },
            )
          : Container(),
      player.hasSpecialType<actions.HopStepSpecial>()
          ? MyButton(
              text: const Text('Hop Step'),
              onPressed: () {
                gamePage.setGameState(PlayerOrthagonalDirectionGameState(
                  this.player,
                  this.hopStep,
                  () => gamePage.setGameState(this),
                ));
              },
            )
          : Container(),
      player.hasSpecialType<actions.PointSymmetricSpecial>()
          ? MyButton(
              text: const Text('Point Symmetric'),
              onPressed: this.pointSymmetric,
            )
          : Container(),
      player.hasSpecialType<actions.BackToStartSpecial>()
          ? MyButton(
              text: const Text('Back To Start'),
              onPressed: this.backToStart,
            )
          : Container(),
      MyButton(
        text: const Text('Cancel'),
        onPressed: this.cancel,
        color: Colors.red,
      ),
    ]);
  }

  bishop(Direction direction) {
    this.callback(actions.BishopAction(player, direction));
  }

  rook(Direction direction) {
    this.callback(actions.RookAction(player, direction));
  }

  diagonal(Direction direction) {
    this.callback(actions.DiagonalAction(player, direction));
  }

  hopStep(Direction direction) {
    this.callback(actions.HopStepAction(player, direction));
  }

  pointSymmetric() {
    this.callback(actions.PointSymmetricAction(player));
  }

  backToStart() {
    this.callback(actions.BackToStartAction(player));
  }
}

final maxInt = 4294967296;
Random nextRandom(Random random) {
  return Random(random.nextInt(maxInt));
}

Game initGame(AppPlayerHandler playerHandler, int players, int rounds) {
  final random = Random();

  final starterDeck = Deck<actions.Special>([
    actions.BishopSpecial(),
    actions.RookSpecial(),
    actions.DiagonalSpecial(),
    actions.HopStepSpecial(),
    actions.PointSymmetricSpecial(),
    actions.BackToStartSpecial(),
    actions.AntiGhostBarrierSpecial(),
  ], List(), nextRandom(random))
    ..shuffle();

  final playerList = List<AppPlayer>();
  for (var i = 0; i < players; i++) {
    playerList.add(AppPlayer([starterDeck.draw(), starterDeck.draw()], playerHandler));
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

  final deck = Deck<actions.Special>([
    actions.BishopSpecial(),
    actions.RookSpecial(),
    actions.DiagonalSpecial(),
    actions.HopStepSpecial(),
    actions.PointSymmetricSpecial(),
    actions.BackToStartSpecial(),
    actions.AntiGhostBarrierSpecial(),
    actions.BishopSpecial(),
    actions.RookSpecial(),
    actions.DiagonalSpecial(),
    actions.HopStepSpecial(),
    actions.PointSymmetricSpecial(),
    actions.BackToStartSpecial(),
    actions.AntiGhostBarrierSpecial(),
  ], List(), nextRandom(random))
    ..shuffle();

  final game = AppGame(playerList, toppings, Grid(nextRandom(random)), deck, maxRounds: rounds);
  randomizeGameGrid(
    game,
  );

  return game;
}

class MyButton extends StatelessWidget {
  final Widget text;
  final Function onPressed;
  final Color color;

  const MyButton({Key key, this.text, this.onPressed, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Container(
        width: double.infinity,
        child: RaisedButton(
          child: this.text,
          onPressed: this.onPressed,
          color: this.color,
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  final String title;
  final int players;
  final int rounds;

  GamePage(Key key, this.title, this.players, this.rounds) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState(players, rounds);

  static _GamePageState of(BuildContext context) {
    final _GamePageState navigator = context.findAncestorStateOfType<_GamePageState>();

    return navigator;
  }
}

class _GamePageState extends State<GamePage> implements AppPlayerHandler {
  Game game;
  GameState gameState = InitGameState();
  List<Report> reports = List();

  _GamePageState(int players, int rounds) {
    this.game = initGame(this, players, rounds);
  }

  @override
  Future<bool> handleAntiGhostBarrierSpecial(AppPlayer player) {
    final gameState = PlayerAntiBarrierSpecialGameState(player);
    this.setGameState(gameState);

    return gameState.completer.future;
  }

  @override
  Future<actions.Action> handleBackToStartAction(AppPlayer player) {
    final gameState = PlayerBackToStartSpecialGameState(player);
    this.setGameState(gameState);

    return gameState.completer.future;
  }

  @override
  Future<actions.Action> handleTurn(AppPlayer player) {
    final gameState = PlayerTurnGameState(player);
    this.setGameState(gameState);

    return gameState.completer.future;
  }

  @override
  Future<void> receiveReport(AppPlayer player, Report report) async {
    setState(() {
      reports.add(report);
    });
  }

  void setReports(List<Report> reports) {
    this.reports = reports;
  }

  void setGameState(GameState gameState) {
    this.setState(() {
      this.gameState = gameState;
    });
  }

  Widget buildReportsWidget() {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.subtitle1,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: reports.map((report) {
            if (report is TurnStartReport) {
              return TurnStartReportWidget(report: report);
            } else if (report is TurnEndReport) {
              return TurnEndReportWidget(report: report);
            } else if (report is WinReport) {
              return WinReportWidget(report: report);
            } else if (report is ReceiveSpecialReport) {
              return ReceiveSpecialReportWidget(report: report);
            } else if (report is UseSpecialReport) {
              return UseSpecialReportWidget(report: report);
            } else if (report is AttackActionReport) {
              return AttackActionReportWidget(report: report);
            } else if (report is ChaseAwayGhostPlayerReport) {
              return ChaseAwayGhostPlayerReportWidget(report: report);
            } else if (report is GhostNotFoundPlayerReport) {
              return GhostNotFoundPlayerReportWidget(report: report);
            } else if (report is MoveActionReport) {
              return MoveActionReportWidget(report: report);
            } else if (report is DiagonalMoveActionReport) {
              return DiagonalMoveActionReportWidget(report: report);
            } else if (report is BumpedIntoWallPlayerReport) {
              return BumpedIntoWallPlayerReportWidget(report: report);
            } else if (report is BumpedIntoGhostPlayerReport) {
              return BumpedIntoGhostPlayerReportWidget(report: report);
            } else if (report is TeleportMoveActionReport) {
              return TeleportMoveActionReportWidget(report: report);
            } else if (report is BackToStartTeleportActionReport) {
              return BackToStartTeleportActionReportWidget(report: report);
            } else if (report is TeleportPlayerReport) {
              return TeleportPlayerReportWidget(report: report);
            } else if (report is FoundPizzaPlayerReport) {
              return FoundPizzaPlayerReportWidget(report: report);
            } else if (report is FoundHousePlayerReport) {
              return FoundHousePlayerReportWidget(report: report);
            } else if (report is TeleporterPlayerReport) {
              return TeleporterPlayerReportWidget(report: report);
            } else if (report is PigFoundPlayerReport) {
              return PigFoundPlayerReportWidget(report: report);
            } else if (report is MonkeyFoundPlayerReport) {
              return MonkeyFoundPlayerReportWidget(report: report);
            } else if (report is CrowAttackedPlayerReport) {
              return CrowAttackedPlayerReportWidget(report: report);
            } else if (report is CrowTeleportPlayerReport) {
              return CrowTeleportPlayerReportWidget(report: report);
            } else if (report is ManholeCoverPlayerReport) {
              return ManholeCoverPlayerReportWidget(report: report);
            } else {
              return Container();
            }
          }).map((widget) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: widget,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildPlayerInfoWidget(Player player) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.people),
          title: Text('Player ${game.players.indexOf(player) + 1}'),
          subtitle: Text('Round ${game.round()} / ${game.maxRounds ?? 'Infinity'}'),
        ),
        ListTile(
          leading: Icon(Icons.local_pizza),
          title: Text(player.topping?.name ?? 'None'),
        ),
        buildReportsWidget(),
      ],
    );
  }

  Widget buildPlayersWidget() {
    return Column(
        children: game.players.map((player) {
      return ListTile(
        leading: Icon(Icons.people),
        title: Text('Player ${game.players.indexOf(player) + 1}'),
      );
    }).toList());
  }

  Widget buildGameStateWidgets(GameState gameState) {
    return gameState;
  }

  @override
  Widget build(BuildContext context) {
    AppPlayer player;
    if (this.gameState is PlayerGameState) {
      player = (this.gameState as PlayerGameState).player;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: player == null ? buildPlayersWidget() : buildPlayerInfoWidget(player)),
          this.buildGameStateWidgets(this.gameState),
        ],
      ),
    );
  }
}
