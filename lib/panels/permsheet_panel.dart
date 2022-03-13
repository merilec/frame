import 'package:frame/constants.dart';
import 'package:frame/notifiers/editor.dart';
import 'package:frame/painters/perms_painter.dart';
import 'package:frame/widgets/if_rom_loaded_widget.dart';
import 'package:flutter/material.dart';
import 'package:frame/widgets/persistent_bar_scroll_view.dart';
import 'package:provider/provider.dart';

class PermsheetPanel extends StatelessWidget {
  final double _zoomLevel = 2.0;

  const PermsheetPanel({Key? key}) : super(key: key);

  void _selectFromPermsheet(TapDownDetails details, BuildContext context) {
    var editor = Provider.of<Editor>(context, listen: false);
    var x = details.localPosition.dx ~/ (_zoomLevel * SIZE_BLOCK);
    var y = details.localPosition.dy ~/ (_zoomLevel * SIZE_BLOCK);
    editor.setPermSelection(y * 4 + x);
  }

  @override
  Widget build(BuildContext context) => IfRomLoadedWidget(loadedBuilder: (editor) {
        return Column(children: [
          const Text('Selection'),
          CustomPaint(
            painter: PermsPainter(
                width: editor.mapSelection.width,
                height: editor.mapSelection.height,
                permissions: [editor.permSelection],
                opacity: 1.0,
                zoom: _zoomLevel),
            size: Size(_zoomLevel * SIZE_BLOCK, _zoomLevel * SIZE_BLOCK),
          ),
          const Text('Permissions'),
          Expanded(
            child: PersistentBarScrollView(
              child: GestureDetector(
                onTapDown: (details) => _selectFromPermsheet(details, context),
                onSecondaryTapDown: (details) => _selectFromPermsheet(details, context),
                onTertiaryTapDown: (details) => _selectFromPermsheet(details, context),
                child: CustomPaint(
                  painter: PermsPainter(
                      width: 4,
                      height: 4,
                      permissions: Iterable<int>.generate(0x40).toList(),
                      opacity: 1.0,
                      zoom: _zoomLevel),
                  size: Size(4 * _zoomLevel * SIZE_BLOCK, (0x40 / 4) * _zoomLevel * SIZE_BLOCK),
                ),
              ),
            ),
          ),
        ]);
      });
}
