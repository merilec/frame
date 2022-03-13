import 'dart:math';

import 'package:frame/constants.dart';
import 'package:frame/models/map_block.dart';
import 'package:frame/models/map_selection.dart';
import 'package:frame/models/position.dart';
import 'package:frame/notifiers/editor.dart';
import 'package:frame/panels/map_panel.dart';
import 'package:frame/tools/tool.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Eyedropper extends Tool {
  int _startingSelectPos = -1;

  @override
  String get name => 'Eyedropper';

  void pickPerm(PointerEvent details, BuildContext context) {
    var editor = Provider.of<Editor>(context, listen: false);
    var mapInfo = editor.mapInfo!;
    var mapBlockId = getMapBlockId(details, editor);
    editor.setPermSelection(mapInfo.mapBlocks[mapBlockId].permission);
  }

  void startPickBlocks(PointerEvent details, BuildContext context) {
    var editor = Provider.of<Editor>(context, listen: false);
    _startingSelectPos = getMapBlockId(details, editor);
    doPickBlocks(details, context);
  }

  void doPickBlocks(PointerEvent details, BuildContext context) {
    if (_startingSelectPos < 0) return;
    var editor = Provider.of<Editor>(context, listen: false);
    var mapInfo = editor.mapInfo!;
    var mapWidth = mapInfo.width;
    var mapHeight = mapInfo.height;
    if (details.localPosition.dx < 0 ||
        details.localPosition.dx >= mapWidth * editor.zoomLevel * SIZE_BLOCK ||
        details.localPosition.dy < 0 ||
        details.localPosition.dy >= mapHeight * editor.zoomLevel * SIZE_BLOCK) {
      endPickBlocks(details, context);
      return;
    }
    var mapBlockId = getMapBlockId(details, editor);

    var xy = Position(mapBlockId % mapWidth, mapBlockId ~/ mapWidth);
    var initial = Position(_startingSelectPos % mapWidth, _startingSelectPos ~/ mapWidth);
    var start = Position(min(initial.x, xy.x), min(initial.y, xy.y));
    var end = Position(max(initial.x, xy.x), max(initial.y, xy.y));
    var mapBlocks = <MapBlock>[];
    for (var y = start.y; y <= end.y; y++) {
      for (var x = start.x; x <= end.x; x++) {
        mapBlocks.add(mapInfo.mapBlocks[y * mapWidth + x]);
      }
    }
    editor.setMapSelection(MapSelection(
      width: end.x - start.x + 1,
      height: end.y - start.y + 1,
      mapBlocks: mapBlocks,
    ));
  }

  void endPickBlocks(PointerEvent details, BuildContext context) {
    _startingSelectPos = -1;
  }

  @override
  void onPointerDown(PointerEvent details, BuildContext context, MapPanelType panelType) {
    switch (panelType) {
      case MapPanelType.Map:
        return startPickBlocks(details, context);
      case MapPanelType.Permission:
        return pickPerm(details, context);
      default:
        return;
    }
  }

  @override
  void onPointerMove(PointerEvent details, BuildContext context, MapPanelType panelType) async {
    if (panelType == MapPanelType.Map) doPickBlocks(details, context);
  }

  @override
  void onPointerUp(PointerEvent details, BuildContext context, MapPanelType panelType) {
    if (panelType == MapPanelType.Map) endPickBlocks(details, context);
  }
}
