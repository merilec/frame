import 'dart:ui' as ui;

import 'package:frame/constants.dart';
import 'package:frame/models/map_block.dart';
import 'package:flutter/material.dart';

class MapPainter extends CustomPainter {
  final int width;
  final int height;
  final List<MapBlock> mapBlocks;
  final ui.Image blocksheet;
  final double zoom;

  const MapPainter({
    required this.width,
    required this.height,
    required this.mapBlocks,
    required this.blocksheet,
    required this.zoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var transforms = Iterable<int>.generate(mapBlocks.length).map((i) {
      var dx = (i % width).toDouble();
      var dy = (i ~/ width).toDouble();
      return RSTransform.fromComponents(
        rotation: 0,
        scale: zoom,
        anchorX: 0,
        anchorY: 0,
        translateX: dx * zoom * SIZE_BLOCK,
        translateY: dy * zoom * SIZE_BLOCK,
      );
    }).toList();

    var rects = mapBlocks.map((mapBlock) {
      var sx = (mapBlock.blockId % 8).toDouble();
      var sy = (mapBlock.blockId ~/ 8).toDouble();
      return Rect.fromLTWH(sx * SIZE_BLOCK, sy * SIZE_BLOCK, SIZE_BLOCK, SIZE_BLOCK);
    }).toList();

    canvas.drawAtlas(blocksheet, transforms, rects, null, null, null, Paint());
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) => true;
}
