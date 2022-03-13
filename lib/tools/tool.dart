import 'package:frame/constants.dart';
import 'package:frame/models/map_block.dart';
import 'package:frame/models/map_selection.dart';
import 'package:frame/notifiers/editor.dart';
import 'package:frame/panels/map_panel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

abstract class Tool {
  String get name;
  void onPointerDown(PointerDownEvent details, BuildContext context, MapPanelType panelType);
  void onPointerMove(PointerMoveEvent details, BuildContext context, MapPanelType panelType);
  void onPointerUp(PointerUpEvent details, BuildContext context, MapPanelType panelType);

  @protected
  MapSelection getSelection(Editor editor, MapPanelType panelType) {
    switch (panelType) {
      case MapPanelType.Map:
        return editor.mapSelection;
      case MapPanelType.Permission:
        return MapSelection(width: 1, height: 1, mapBlocks: [MapBlock(-1, editor.permSelection)]);
      default:
        return MapSelection(width: 0, height: 0, mapBlocks: []);
    }
  }

  @protected
  int getMapBlockId(PointerEvent details, Editor editor) {
    var x = details.localPosition.dx ~/ (SIZE_BLOCK * editor.zoomLevel);
    var y = details.localPosition.dy ~/ (SIZE_BLOCK * editor.zoomLevel);
    return y * editor.mapInfo!.width + x;
  }

  @protected
  bool isLeftClick(PointerEvent details) => (details.buttons & kPrimaryMouseButton) != 0;

  @protected
  bool isRightClick(PointerEvent details) => (details.buttons & kSecondaryMouseButton) != 0;

  @protected
  bool isMiddleClick(PointerEvent details) => (details.buttons & kMiddleMouseButton) != 0;
}
