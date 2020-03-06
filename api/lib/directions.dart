enum Direction {
  North,
  NorthEast,
  East,
  SouthEast,
  South,
  SouthWest,
  West,
  NorthWest,
}

extension MyDirection on Direction {
  String get name => this.toString().split('.').last;
}