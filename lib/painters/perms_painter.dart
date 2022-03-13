import 'package:frame/constants.dart';
import 'package:flutter/material.dart';

const List<Color> _permColors = [
  Color(0xFF0000FF),
  Color(0xFFFF0000),
  Color(0xFF00FF00),
  Color(0xFF00FFFF),
  Color(0xFFFF00FF),
  Color(0xFFFFFF00),
  Color(0xFF400080),
  Color(0xFF800000),
  Color(0xFF808000),
  Color(0xFF008000),
  Color(0xFF008080),
  Color(0xFF000080),
  Color(0xFF800080),
  Color(0xFFFF0080),
  Color(0xFF804000),
  Color(0xFFFF8000),
  Color(0xFF4AA22D),
  Color(0xFF1AE64D),
  Color(0xFF800040),
  Color(0xFF282060),
  Color(0xFF005400),
  Color(0xFF7DA6BD),
  Color(0xFFD59B24),
  Color(0xFF562929),
  Color(0xFF156A62),
  Color(0xFFAB2950),
  Color(0xFFA0E898),
  Color(0xFF2E84B8),
  Color(0xFF7035C0),
  Color(0xFF6075D6),
  Color(0xFF325060),
  Color(0xFFACCA35),
  Color(0xFFFFFF00),
  Color(0xFF648040),
  Color(0xFFCC6868),
  Color(0xFF008040),
  Color(0xFF4E80F8),
  Color(0xFF3058A4),
  Color(0xFFEC9A20),
  Color(0xFF005050),
  Color(0xFFB4DE20),
  Color(0xFFF44B50),
  Color(0xFF204020),
  Color(0xFF80FF00),
  Color(0xFF1EAC68),
  Color(0xFFBE7640),
  Color(0xFFE4D61C),
  Color(0xFF30D8A0),
  Color(0xFF14ECA5),
  Color(0xFF804040),
  Color(0xFF804000),
  Color(0xFFE4F874),
  Color(0xFFC8AC38),
  Color(0xFF3EC064),
  Color(0xFF70962C),
  Color(0xFF804000),
  Color(0xFF02FFFF),
  Color(0xFFBC0AC0),
  Color(0xFF346916),
  Color(0xFFF4F05C),
  Color(0xFF5454AC),
  Color(0xFF4470DA),
  Color(0xFF38C692),
  Color(0xFF1A665A),
];

class PermsPainter extends CustomPainter {
  final int width;
  final int height;
  final List<int> permissions;
  final double zoom;
  final double opacity;

  const PermsPainter(
      {required this.width,
      required this.height,
      required this.permissions,
      required this.opacity,
      required this.zoom});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    var tps = Iterable<int>.generate(_permColors.length).map((i) {
      var tp = TextPainter(
        text: TextSpan(
          text: i.toRadixString(16).toUpperCase(),
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Comic Sans MS',
            fontSize: 11 * zoom,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      return tp;
    }).toList();
    permissions.asMap().entries.forEach((entry) {
      var i = entry.key;
      var perm = entry.value;
      var dx = (i % width).toDouble();
      var dy = (i ~/ width).toDouble();
      canvas.drawRect(
          Offset(dx * zoom * SIZE_BLOCK, dy * zoom * SIZE_BLOCK) &
              Size(zoom * SIZE_BLOCK, zoom * SIZE_BLOCK),
          Paint()
            ..color = _permColors[perm].withOpacity(opacity)
            ..strokeWidth = 0);
      var tp = tps[perm];
      tp.paint(
          canvas,
          Offset(
            dx * zoom * SIZE_BLOCK + (zoom * SIZE_BLOCK - tp.width) * 0.5,
            dy * zoom * SIZE_BLOCK + (zoom * SIZE_BLOCK - tp.height) * 0.5,
          ));
    });
  }

  @override
  bool shouldRepaint(PermsPainter oldDelegate) => true;
}
