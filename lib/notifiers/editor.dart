import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:frame/api/api.dart';
import 'package:frame/commands/base_command.dart';
import 'package:frame/constants.dart';
import 'package:frame/models/bank_map.dart';
import 'package:frame/models/history.dart';
import 'package:frame/models/map_block.dart';
import 'package:frame/models/map_info.dart';
import 'package:frame/models/map_selection.dart';
import 'package:frame/models/rom_info.dart';
import 'package:frame/notifiers/status.dart';
import 'package:frame/tools/pencil.dart';
import 'package:frame/tools/tool.dart';
import 'package:flutter/material.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:provider/provider.dart';

final _defaultBankMap = BankMap(1, 0);
final _zoomLevels = <double>[0.25, 1 / 3, 0.5, 2 / 3, 0.75, 1, 1.5, 2, 2.5, 3, 4];
final _opacityLevels = <double>[0.1, 1 / 6, 2 / 3, 0.5, 0.7, 5 / 6, 1.0];

class Editor extends ChangeNotifier {
  RomInfo _romInfo = RomInfo.emptyRom();
  var _zoomLevelIndex = 5;
  var _opacityLevelIndex = 4;
  var _showGrid = false;
  MapInfo? _mapInfo;
  MapSelection _mapSelection = MapSelection(width: 1, height: 1, mapBlocks: [MapBlock(0x0, -1)]);
  int _permSelection = 0xC;
  final Map<BankMap, History> _history = {};
  Tool _tool = Pencil();

  RomInfo get romInfo => _romInfo;
  double get zoomLevel => _zoomLevels[_zoomLevelIndex];
  double get opacityLevel => _opacityLevels[_opacityLevelIndex];
  bool get showGrid => _showGrid;
  MapInfo? get mapInfo => _mapInfo;
  MapSelection get mapSelection => _mapSelection;
  int get permSelection => _permSelection;
  Tool get tool => _tool;

  Future<void> loadRom(BuildContext context) async {
    var filepath = (await FilePicker.platform.pickFiles(
      dialogTitle: 'Load',
      type: FileType.custom,
      allowedExtensions: ['gba'],
    ))
        ?.files
        .single
        .path;
    if (filepath == null) return;

    var banks = await Api.loadRom(filepath);
    var status = Provider.of<Status>(context, listen: false);
    _romInfo = RomInfo(filepath: filepath, banks: banks);
    _mapInfo = MapInfo.create(_defaultBankMap, await Api.getPartialMapInfo(_defaultBankMap),
        await Api.getMapBlocksheet(_defaultBankMap));

    await Window.of(context).setTitle('$_defaultBankMap - $APP_NAME');
    status.value = 'Loaded ROM from $filepath';
    notifyListeners();
  }

  Future<void> saveRom(BuildContext context) => _saveRom(context, false);

  Future<void> saveAsRom(BuildContext context) => _saveRom(context, true);

  Future<void> _saveRom(BuildContext context, bool promptFilepath) async {
    if (promptFilepath) {
      var filepath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save As',
        type: FileType.custom,
        allowedExtensions: ['gba'],
        lockParentWindow: true,
        fileName: File(romInfo.filepath).uri.pathSegments.last,
      );
      if (filepath == null) return;
      _romInfo = RomInfo(filepath: filepath, banks: _romInfo.banks);
    }

    var status = Provider.of<Status>(context, listen: false);
    if (await Api.saveRom(_romInfo.filepath)) {
      status.value = 'Saved ROM to ${_romInfo.filepath}';
      await Window.of(context).setTitle('${_mapInfo!.bankMap} - $APP_NAME');
    } else {
      print('Error saving ROM to ${_romInfo.filepath}!');
    }
  }

  bool get canZoomIn => _zoomLevelIndex < _zoomLevels.length - 1;
  bool get canZoomOut => _zoomLevelIndex > 0;

  void zoomIn() {
    if (!canZoomIn) return;
    _zoomLevelIndex++;
    notifyListeners();
  }

  void zoomOut() {
    if (!canZoomOut) return;
    _zoomLevelIndex--;
    notifyListeners();
  }

  void resetZoom() {
    _zoomLevelIndex = _zoomLevels.length ~/ 2;
    notifyListeners();
  }

  void increaseOpacity() {
    if (_opacityLevelIndex >= _opacityLevels.length - 1) return;
    _opacityLevelIndex++;
    notifyListeners();
  }

  void decreaseOpacity() {
    if (_opacityLevelIndex <= 0) return;
    _opacityLevelIndex--;
    notifyListeners();
  }

  void toggleGrid() {
    _showGrid = !_showGrid;
    notifyListeners();
  }

  Future<void> setAsCurrentMap(BankMap bankMap, Window window, Status status) async {
    if (mapInfo != null && mapInfo!.bankMap == bankMap) return;
    status.value = 'Loading map $bankMap...';
    _mapInfo = MapInfo.create(
        bankMap, await Api.getPartialMapInfo(bankMap), await Api.getMapBlocksheet(bankMap));
    status.value = 'Map $bankMap';
    await window.setTitle('$bankMap - $APP_NAME');
    notifyListeners();
  }

  void updateCurrentMap() async {
    var bankMap = mapInfo!.bankMap;
    _mapInfo = mapInfo!.update(await Api.getPartialMapInfo(bankMap));
    notifyListeners();
  }

  void setMapSelection(MapSelection mapSelection) {
    _mapSelection = MapSelection(
        width: mapSelection.width,
        height: mapSelection.height,
        mapBlocks:
            mapSelection.mapBlocks.map((mapBlock) => MapBlock(mapBlock.blockId, -1)).toList());
    notifyListeners();
  }

  void setPermSelection(int permSelection) {
    _permSelection = permSelection;
    notifyListeners();
  }

  void setTool(Tool tool) {
    _tool = tool;
    notifyListeners();
  }

  BaseCommand? get commandToUndo {
    var mapHistory = _history[mapInfo?.bankMap];
    if (mapHistory == null || mapHistory.position < 0) return null;
    return mapHistory.commands[mapHistory.position];
  }

  BaseCommand? get commandToRedo {
    var mapHistory = _history[mapInfo?.bankMap];
    if (mapHistory == null || mapHistory.position + 1 >= mapHistory.commands.length) return null;
    return mapHistory.commands[mapHistory.position + 1];
  }

  void execute(BaseCommand command, Window window) {
    var bankMap = mapInfo!.bankMap;
    if (_history[bankMap] == null) {
      _history[bankMap] = History();
    }
    var mapHistory = _history[bankMap]!;
    mapHistory.position++;
    mapHistory.commands.removeRange(mapHistory.position, mapHistory.commands.length);
    mapHistory.commands.add(command);
    command.execute(this);
    unawaited(window.setTitle('*$bankMap - $APP_NAME'));
  }

  void undo() {
    var command = commandToUndo;
    if (command == null) return;
    _history[mapInfo!.bankMap]!.position--;
    command.undo(this);
  }

  void redo() {
    var command = commandToRedo;
    if (command == null) return;
    _history[mapInfo!.bankMap]!.position++;
    command.redo(this);
  }
}
