import 'package:frame/api/api.dart';
import 'package:frame/commands/set_map_blocks.dart';
import 'package:frame/models/map_block.dart';
import 'package:frame/models/position.dart';
import 'package:frame/notifiers/editor.dart';
import 'package:frame/panels/map_panel.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/gestures/events.dart';
import 'package:frame/tools/tool.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:provider/provider.dart';

class Bucket extends Tool {
  @override
  String get name => 'Bucket';

  void fillBlocks(PointerEvent details, BuildContext context, MapPanelType panelType) async {
    var _oldMapBlocks = <int, MapBlock>{};
    var _newMapBlocks = <int, MapBlock>{};

    var editor = Provider.of<Editor>(context, listen: false);
    var mapInfo = editor.mapInfo!;
    var mapWidth = mapInfo.width;
    var mapHeight = mapInfo.height;

    var selection = getSelection(editor, panelType);
    if (selection.mapBlocks.isEmpty) return;

    var srcMapBlockId = getMapBlockId(details, editor);
    var srcPosition = Position(srcMapBlockId % mapWidth, srcMapBlockId ~/ mapWidth);

    bool isSameBlock(MapBlock oldMapBlock, MapBlock neighborMapBlock, MapPanelType panelType) {
      switch (panelType) {
        case MapPanelType.Map:
          return oldMapBlock.blockId == neighborMapBlock.blockId;
        case MapPanelType.Permission:
          return oldMapBlock.permission == neighborMapBlock.permission;
        default:
          return false;
      }
    }

    void dfs(int mapBlockId) {
      var xy = Position(mapBlockId % mapWidth, mapBlockId ~/ mapWidth);

      var index = ((xy.y - srcPosition.y) % selection.height) * selection.width +
          ((xy.x - srcPosition.x) % selection.width);

      var oldMapBlock = mapInfo.mapBlocks[mapBlockId];
      var mapBlock = selection.mapBlocks[index];
      var newMapBlock = MapBlock(
        mapBlock.blockId < 0 ? oldMapBlock.blockId : mapBlock.blockId,
        mapBlock.permission < 0 ? oldMapBlock.permission : mapBlock.permission,
      );
      _oldMapBlocks[mapBlockId] = oldMapBlock;
      _newMapBlocks[mapBlockId] = newMapBlock;

      for (var neighbor in [
        [xy.x - 1, xy.y],
        [xy.x + 1, xy.y],
        [xy.x, xy.y - 1],
        [xy.x, xy.y + 1]
      ]) {
        var nxy = Position(neighbor[0], neighbor[1]);
        var neighborMapBlockId = nxy.y * mapWidth + nxy.x;
        if (_newMapBlocks.containsKey(neighborMapBlockId) ||
            (nxy.x < 0 || nxy.x >= mapWidth || nxy.y < 0 || nxy.y >= mapHeight) ||
            !isSameBlock(oldMapBlock, mapInfo.mapBlocks[neighborMapBlockId], panelType)) {
          continue;
        }
        dfs(neighborMapBlockId);
      }
    }

    dfs(srcMapBlockId);
    await Api.setMapBlocks(mapInfo.bankMap, _newMapBlocks);
    editor.execute(
        SetMapBlocksCommand(
            name: {
              MapPanelType.Map: 'Bucket Fill Blocks',
              MapPanelType.Permission: 'Bucket Fill Permissions',
            }[panelType]!,
            bankMap: editor.mapInfo!.bankMap,
            oldMapBlocks: _oldMapBlocks,
            newMapBlocks: _newMapBlocks),
        Window.of(context));
  }

  @override
  void onPointerDown(PointerEvent details, BuildContext context, MapPanelType panelType) {
    if (panelType == MapPanelType.Map || panelType == MapPanelType.Permission) {
      return fillBlocks(details, context, panelType);
    }
  }

  @override
  void onPointerMove(PointerEvent details, BuildContext context, MapPanelType panelType) {}

  @override
  void onPointerUp(PointerEvent details, BuildContext context, MapPanelType panelType) {}
}
