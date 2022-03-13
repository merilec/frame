import 'package:frame/models/map_block.dart';

class MapSelection {
  final int width;
  final int height;
  final List<MapBlock> mapBlocks;

  MapSelection({
    required this.width,
    required this.height,
    required this.mapBlocks,
  });
}
