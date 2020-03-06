import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import 'game_page.dart';

class SetupPage extends StatefulWidget {
  final String title;

  SetupPage(this.title, Key key) : super(key: key);

  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  int players = 2;
  int rounds = 20;

  void navigateStart() {
    Navigator.push<GamePage>(
      this.context,
      MaterialPageRoute(
        builder: (context) => GamePage(
          Key('game'),
          'Pizza Ghost Delivery',
          this.players,
          this.rounds,
        ),
      ),
    );
  }

  void showPlayersDialog() async {
    final value = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return NumberPickerDialog.integer(
          minValue: 2,
          maxValue: 5,
          title: Text("Number of Players"),
          initialIntegerValue: this.players,
        );
      },
    );
    if (value != null) {
      setState(() => this.players = value);
    }
  }

  void showRoundsDialog() async {
    final value = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return NumberPickerDialog.integer(
          minValue: 1,
          maxValue: 100,
          title: Text("Number of Rounds"),
          initialIntegerValue: this.rounds,
        );
      },
    );
    if (value != null) {
      setState(() => this.rounds = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Column(children: <Widget>[
                ListTile(
                  leading: Icon(Icons.people),
                  title: Text("Number of Players"),
                  subtitle: Text('${this.players}'),
                  onTap: showPlayersDialog,
                ),
                ListTile(
                  leading: Icon(Icons.timer),
                  title: Text("Number of Rounds"),
                  subtitle: Text('${this.rounds}'),
                  onTap: showRoundsDialog,
                ),
              ]),
            ),
          ),
          MyButton(
            text: const Text('Start'),
            onPressed: this.navigateStart,
          ),
        ],
      ),
    );
  }
}
