import 'package:frame/constants.dart';
import 'package:flutter/material.dart';

class RectPainter extends CustomPainter {
  final int x;
  final int y;
  final int width;
  final int height;
  final double zoom;

  const RectPainter({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.zoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    var outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * zoom
      ..color = Colors.black;

    var innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * zoom
      ..color = Colors.white;

    var rect = Rect.fromLTWH(
      (x * SIZE_BLOCK - 0.5) * zoom,
      (y * SIZE_BLOCK - 0.5) * zoom,
      (width * SIZE_BLOCK + 1) * zoom,
      (height * SIZE_BLOCK + 1) * zoom,
    );

    canvas.drawRect(rect, outerPaint);
    canvas.drawRect(rect, innerPaint);
  }

  @override
  bool shouldRepaint(RectPainter oldDelegate) => true;
}
