class MapBlock {
  final int blockId;
  final int permission;

  const MapBlock(this.blockId, this.permission);

  factory MapBlock.fromJson(Map<String, dynamic> json) => MapBlock(
        json['block_id'],
        json['permission'],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'block_id': blockId,
        'permission': permission,
      };

  int get value => blockId | (permission << 0xA);

  @override
  bool operator ==(Object other) =>
      other is MapBlock &&
      runtimeType == other.runtimeType &&
      blockId == other.blockId &&
      permission == other.permission;

  @override
  int get hashCode => value;

  @override
  String toString() {
    return 'MapBlock(${blockId.toRadixString(16)}, ${permission.toRadixString(16)})';
  }
}
