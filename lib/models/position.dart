import 'dart:ui';

class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is Position && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => hashValues(x, y);

  @override
  String toString() => '($x, $y)';
}
