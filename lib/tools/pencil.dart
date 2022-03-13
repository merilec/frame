import 'package:frame/api/api.dart';
import 'package:frame/commands/set_map_blocks.dart';
import 'package:frame/constants.dart';
import 'package:frame/models/map_block.dart';
import 'package:frame/models/position.dart';
import 'package:frame/notifiers/editor.dart';
import 'package:frame/panels/map_panel.dart';
import 'package:frame/tools/eyedropper.dart';
import 'package:frame/tools/tool.dart';
import 'package:flutter/material.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:provider/provider.dart';

class Pencil extends Tool {
  Map<int, MapBlock> _oldMapBlocks = {};
  Map<int, MapBlock> _newMapBlocks = {};
  int _startingPaintPos = -1;

  final Eyedropper _eyedropper = Eyedropper();

  @override
  String get name => 'Pencil';

  void startPaint(PointerEvent details, BuildContext context, MapPanelType panelType) {
    var editor = Provider.of<Editor>(context, listen: false);
    _oldMapBlocks = {};
    _newMapBlocks = {};
    _startingPaintPos = getMapBlockId(details, editor);
    doPaint(details, context, panelType);
  }

  void doPaint(PointerEvent details, BuildContext context, MapPanelType panelType) async {
    if (_startingPaintPos < 0) return;
    var editor = Provider.of<Editor>(context, listen: false);
    var mapInfo = editor.mapInfo!;
    var mapWidth = mapInfo.width;
    var mapHeight = mapInfo.height;
    if (details.localPosition.dx < 0 ||
        details.localPosition.dx >= mapWidth * editor.zoomLevel * SIZE_BLOCK ||
        details.localPosition.dy < 0 ||
        details.localPosition.dy >= mapHeight * editor.zoomLevel * SIZE_BLOCK) {
      endPaint(details, context, panelType);
      return;
    }
    var mapBlockId = getMapBlockId(details, editor);
    if (_newMapBlocks[mapBlockId] != null) return;

    var selection = getSelection(editor, panelType);
    var xy = Position(mapBlockId % mapWidth, mapBlockId ~/ mapWidth);
    var initial = Position(_startingPaintPos % mapWidth, _startingPaintPos ~/ mapWidth);
    var start = Position(
        initial.x + ((xy.x - initial.x) / selection.width).floor() * selection.width,
        initial.y + ((xy.y - initial.y) / selection.height).floor() * selection.height);
    selection.mapBlocks.asMap().forEach((i, mapBlock) {
      var current = Position(start.x + (i % selection.width), start.y + (i ~/ selection.width));
      if (current.x < 0 || current.x >= mapWidth || current.y < 0 || current.y >= mapHeight) return;
      var currentMapBlockId = current.y * mapWidth + current.x;
      var oldMapBlock = mapInfo.mapBlocks[currentMapBlockId];
      var newMapBlock = MapBlock(
        mapBlock.blockId < 0 ? oldMapBlock.blockId : mapBlock.blockId,
        mapBlock.permission < 0 ? oldMapBlock.permission : mapBlock.permission,
      );
      _oldMapBlocks[currentMapBlockId] = oldMapBlock;
      _newMapBlocks[currentMapBlockId] = newMapBlock;
    });

    await Api.setMapBlocks(mapInfo.bankMap, _newMapBlocks);
    editor.updateCurrentMap();
  }

  void endPaint(PointerEvent details, BuildContext context, MapPanelType panelType) {
    if (_startingPaintPos < 0) return;

    var editor = Provider.of<Editor>(context, listen: false);
    editor.execute(
        SetMapBlocksCommand(
            name: panelType == MapPanelType.Map ? 'Paint Blocks' : 'Paint Permissions',
            bankMap: editor.mapInfo!.bankMap,
            oldMapBlocks: _oldMapBlocks,
            newMapBlocks: _newMapBlocks),
        Window.of(context));
    _startingPaintPos = -1;
  }

  @override
  void onPointerDown(PointerEvent details, BuildContext context, MapPanelType panelType) {
    if (isLeftClick(details)) return startPaint(details, context, panelType);
    if (isMiddleClick(details)) return;
    if (isRightClick(details)) {
      return _eyedropper.onPointerDown(details, context, panelType);
    }
  }

  @override
  void onPointerMove(PointerEvent details, BuildContext context, MapPanelType panelType) {
    if (isLeftClick(details)) return doPaint(details, context, panelType);
    if (isMiddleClick(details)) return;
    if (isRightClick(details)) {
      return _eyedropper.onPointerMove(details, context, panelType);
    }
  }

  @override
  void onPointerUp(PointerEvent details, BuildContext context, MapPanelType panelType) {
    // cannot determine button press from PointerUpEvent,
    // so simply end all operations
    if (_startingPaintPos > 0) endPaint(details, context, panelType);
    _eyedropper.onPointerUp(details, context, panelType);
  }
}
