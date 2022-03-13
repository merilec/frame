import 'dart:math';

import 'package:frame/constants.dart';
import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final double zoom;

  const GridPainter({
    required this.zoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    var paint = Paint()..strokeWidth = 1.0 * min(zoom, 1.0);

    for (var x = 0.0; x <= size.width; x += zoom * SIZE_BLOCK) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += zoom * SIZE_BLOCK) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}
