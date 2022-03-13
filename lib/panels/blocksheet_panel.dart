import 'package:frame/constants.dart';
import 'package:frame/models/map_block.dart';
import 'package:frame/models/map_selection.dart';
import 'package:frame/notifiers/editor.dart';
import 'package:frame/painters/map_painter.dart';
import 'package:frame/widgets/if_rom_loaded_widget.dart';
import 'package:frame/widgets/persistent_bar_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BlocksheetPanel extends StatelessWidget {
  final double _blocksheetZoomLevel = 1.5;

  const BlocksheetPanel({Key? key}) : super(key: key);

  void _selectFromBlocksheet(TapDownDetails details, BuildContext context) {
    var editor = Provider.of<Editor>(context, listen: false);
    var x = details.localPosition.dx ~/ (_blocksheetZoomLevel * SIZE_BLOCK);
    var y = details.localPosition.dy ~/ (_blocksheetZoomLevel * SIZE_BLOCK);
    var blockId = y * 8 + x;
    if (blockId >= editor.mapInfo!.numBlocks) return;

    editor.setMapSelection(MapSelection(width: 1, height: 1, mapBlocks: [MapBlock(blockId, -1)]));
  }

  @override
  Widget build(BuildContext context) {
    return IfRomLoadedWidget(
      loadedBuilder: (editor) {
        var mapInfo = editor.mapInfo!;
        return Column(
          children: [
            const Text('Selection'),
            PersistentBarScrollView(
              constraints: BoxConstraints(maxHeight: 6 * _blocksheetZoomLevel * SIZE_BLOCK),
              child: CustomPaint(
                painter: MapPainter(
                    width: editor.mapSelection.width,
                    height: editor.mapSelection.height,
                    mapBlocks: editor.mapSelection.mapBlocks,
                    blocksheet: mapInfo.blocksheet,
                    zoom: _blocksheetZoomLevel),
                size: Size(
                  editor.mapSelection.width * _blocksheetZoomLevel * SIZE_BLOCK,
                  editor.mapSelection.height * _blocksheetZoomLevel * SIZE_BLOCK,
                ),
              ),
            ),
            const Text('Blocksheet'),
            Expanded(
              child: PersistentBarScrollView(
                child: GestureDetector(
                  onTapDown: (details) => _selectFromBlocksheet(details, context),
                  onSecondaryTapDown: (details) => _selectFromBlocksheet(details, context),
                  onTertiaryTapDown: (details) => _selectFromBlocksheet(details, context),
                  child: CustomPaint(
                    painter: MapPainter(
                        width: 8,
                        height: (mapInfo.numBlocks / 8).ceil(),
                        mapBlocks: Iterable<int>.generate(mapInfo.numBlocks)
                            .map((i) => MapBlock(i, 0))
                            .toList(),
                        blocksheet: mapInfo.blocksheet,
                        zoom: _blocksheetZoomLevel),
                    size: Size(8 * _blocksheetZoomLevel * SIZE_BLOCK,
                        (mapInfo.numBlocks / 8).ceil() * _blocksheetZoomLevel * SIZE_BLOCK),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
