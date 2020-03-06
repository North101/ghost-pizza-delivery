import 'actions.dart';
import 'directions.dart';
import 'reports.dart';
import 'token.dart';
import 'topping.dart';

abstract class Player {
  int point = -1;
  Topping topping;
  final specials = List<Special>();
  final tokens = List<Token>();
  int won;
  Direction rotate;
  bool reverseRotate = false;

  // remove specials
  Future<Action> handleTurn();

  // remove special if used
  Future<bool> handleAntiGhostBarrierSpecial();

  Future<Action> handleBackToStartAction();

  Future<void> receiveReport(Report report);

  Direction direction(Direction direction, [bool reverse = false]) {
    final rotate = this.rotate;
    if (rotate == null) {
      return direction;
    }

    if (reverse == this.reverseRotate) {
      return Direction.values[((direction.index - rotate.index) % 8).abs()];
    }

    return Direction.values[((direction.index + rotate.index) % 8).abs()];
  }

  bool hasSpecial(Special special) {
    return this.specials.contains(special);
  }

  bool hasSpecialType<T extends Special>() {
    return this.specials.whereType<T>().isNotEmpty;
  }

  void addSpecial(Special special) {
    this.specials.add(special);
  }

  bool removeSpecial(Special special) {
    return this.specials.remove(special);
  }

  bool removeSpecialType<T extends Special>() {
    return this.removeSpecial(this.specials.whereType<T>().first);
  }

  bool hasToken(Token token) {
    return this.tokens.contains(token);
  }

  bool hasTokenType<T extends Token>() {
    return this.tokens.whereType<T>().isNotEmpty;
  }

  void addToken(Token token) {
    this.tokens.add(token);
  }

  bool removeToken(Token token) {
    return this.tokens.remove(token);
  }

  bool removeTokenType<T extends Token>() {
    return this.removeToken(this.tokens.whereType<T>().first);
  }
}
