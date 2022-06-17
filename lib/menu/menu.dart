import 'dart:io';
import 'dart:ui';

import 'package:frame/constants.dart';
import 'package:frame/notifiers/editor.dart';
import 'package:frame/notifiers/is_shortcut_enabled.dart';
import 'package:frame/painters/map_painter.dart';
import 'package:frame/tools/bucket.dart';
import 'package:frame/tools/eyedropper.dart';
import 'package:frame/tools/pencil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter/services.dart';
import 'package:nativeshell/accelerators.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:provider/provider.dart';

void _exportMapPicture(BuildContext context) async {
  var editor = Provider.of<Editor>(context, listen: false);
  var mapInfo = editor.mapInfo!;

  var filepath = await FilePicker.platform.saveFile(
    dialogTitle: 'Export Map Picture',
    type: FileType.image,
    lockParentWindow: true,
    fileName: '${editor.romInfo.banks[mapInfo.bankMap.bankNum][mapInfo.bankMap.mapNum]}.png',
  );
  if (filepath == null) return;

  var recorder = PictureRecorder();
  var size = Size(mapInfo.width * SIZE_BLOCK, mapInfo.height * SIZE_BLOCK);
  var painter = MapPainter(
    width: mapInfo.width,
    height: mapInfo.height,
    blocksheet: mapInfo.blocksheet,
    mapBlocks: mapInfo.mapBlocks,
    zoom: 1.0,
  );
  painter.paint(Canvas(recorder), size);
  var image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
  var bytes = await image.toByteData(format: ImageByteFormat.png);
  return File(filepath).writeAsBytesSync(bytes!.buffer.asUint8List());
}

class MyMenuBar extends StatelessWidget {
  const MyMenuBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var editor = Provider.of<Editor>(context, listen: false);
    var isShortcutEnabled = Provider.of<IsShortcutEnabled>(context, listen: false);
    void Function()? ifRomLoaded(void Function()? cb) => editor.mapInfo != null ? cb : null;
    void Function()? ifShortcutEnabled(void Function()? cb) => isShortcutEnabled.value ? cb : null;

    return Align(
      alignment: Alignment.centerLeft,
      child: Consumer2<Editor, IsShortcutEnabled>(
        builder: (context, editor, isShortcutEnabled, child) => MenuBar(
          menu: Menu(() => [
                MenuItem.children(
                  title: '&File',
                  children: [
                    MenuItem(
                      title: 'Load...',
                      accelerator: cmdOrCtrl + 'o',
                      action: () => editor.loadRom(context),
                    ),
                    MenuItem(
                      title: 'Save',
                      accelerator: cmdOrCtrl + 's',
                      action: ifRomLoaded(() => editor.saveRom(context)),
                    ),
                    MenuItem(
                      title: 'Save As...',
                      accelerator: cmdOrCtrl + shift + 's',
                      action: ifRomLoaded(() => editor.saveAsRom(context)),
                    ),
                    MenuItem.separator(),
                    MenuItem(
                      title: 'Export Map Picture',
                      action: ifRomLoaded(() => _exportMapPicture(context)),
                    ),
                    MenuItem.separator(),
                    MenuItem(
                      title: 'Exit',
                      action: () => exit(0),
                    ),
                  ],
                ),
                MenuItem.children(
                  title: '&Edit',
                  children: [
                    MenuItem(
                        title: 'Undo' +
                            (editor.commandToUndo == null ? '' : ' ' + editor.commandToUndo!.name),
                        accelerator: cmdOrCtrl + 'z',
                        action: ifShortcutEnabled(editor.commandToUndo == null ? null : editor.undo)),
                    MenuItem(
                        title: 'Redo' +
                            (editor.commandToRedo == null ? '' : ' ' + editor.commandToRedo!.name),
                        accelerator: cmdOrCtrl + 'y',
                        action: ifShortcutEnabled(editor.commandToRedo == null ? null : editor.redo)),
                  ],
                ),
                MenuItem.children(
                  title: '&View',
                  children: [
                    MenuItem(
                      title: editor.showGrid ? 'Hide grid' : 'Show grid',
                      accelerator: Accelerator(key: LogicalKeyboardKey.keyG),
                      action: ifRomLoaded(editor.toggleGrid),
                    ),
                    MenuItem.separator(),
                    MenuItem.children(
                      title: 'Zoom',
                      children: [
                        MenuItem(
                          title: 'Zoom In',
                          accelerator: cmdOrCtrl + '=',
                          action: ifRomLoaded(editor.canZoomIn ? editor.zoomIn : null),
                        ),
                        MenuItem(
                          title: 'Zoom Out',
                          accelerator: cmdOrCtrl + '_',
                          action: ifRomLoaded(editor.canZoomOut ? editor.zoomOut : null),
                        ),
                        MenuItem(
                          title: 'Reset Default Zoom',
                          accelerator: cmdOrCtrl + '0',
                          action: ifRomLoaded(editor.resetZoom),
                        ),
                      ],
                    ),
                  ],
                ),
                MenuItem.children(
                  title: '&Tools',
                  children: [
                    MenuItem(
                      title: 'Pencil',
                      checkStatus:
                          editor.tool.name == 'Pencil' ? CheckStatus.radioOn : CheckStatus.radioOff,
                      accelerator: Accelerator(key: LogicalKeyboardKey.keyP),
                      action: ifShortcutEnabled(() => editor.setTool(Pencil())),
                    ),
                    MenuItem(
                      title: 'Eyedropper',
                      checkStatus: editor.tool.name == 'Eyedropper'
                          ? CheckStatus.radioOn
                          : CheckStatus.radioOff,
                      accelerator: Accelerator(key: LogicalKeyboardKey.keyI),
                      action: ifShortcutEnabled(() => editor.setTool(Eyedropper())),
                    ),
                    MenuItem(
                      title: 'Bucket',
                      checkStatus: editor.tool.name == 'Bucket'
                          ? CheckStatus.radioOn
                          : CheckStatus.radioOff,
                      accelerator: Accelerator(key: LogicalKeyboardKey.keyB),
                      action: ifShortcutEnabled(() => editor.setTool(Bucket())),
                    ),
                  ],
                ),
              ]),
          itemBuilder: _buildMenuBarItem,
        ),
      ),
    );
  }
}

Widget _buildMenuBarItem(BuildContext buildContext, Widget child, MenuItemState itemState) {
  Color background;
  Color foreground;

  switch (itemState) {
    case MenuItemState.regular:
      background = Colors.transparent;
      foreground = Colors.grey.shade800;
      break;
    case MenuItemState.hovered:
      background = Colors.grey.shade300;
      foreground = Colors.grey.shade800;
      break;
    case MenuItemState.selected:
      background = Colors.grey.shade400;
      foreground = Colors.black;
      break;
    case MenuItemState.disabled:
      background = Colors.transparent;
      foreground = Colors.grey.shade800.withOpacity(0.5);
      break;
  }
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    color: background,
    child: DefaultTextStyle.merge(
      style: TextStyle(color: foreground, fontSize: 13),
      child: child,
    ),
  );
}
