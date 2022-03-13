import 'dart:ui';

class BankMap {
  final int bankNum;
  final int mapNum;

  const BankMap(this.bankNum, this.mapNum);

  @override
  bool operator ==(Object other) =>
      other is BankMap &&
      runtimeType == other.runtimeType &&
      bankNum == other.bankNum &&
      mapNum == other.mapNum;

  @override
  int get hashCode => hashValues(bankNum, mapNum);

  @override
  String toString() => '($bankNum.$mapNum)';
}
