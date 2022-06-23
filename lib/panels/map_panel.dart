import 'package:frame/constants.dart';
import 'package:frame/notifiers/editor.dart';
import 'package:frame/painters/grid_painter.dart';
import 'package:frame/painters/map_painter.dart';
import 'package:frame/painters/perms_painter.dart';
import 'package:frame/panels/blocksheet_panel.dart';
import 'package:frame/panels/permsheet_panel.dart';
import 'package:frame/widgets/if_rom_loaded_widget.dart';
import 'package:frame/widgets/persistent_bar_scroll_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nativeshell/src/key_interceptor.dart';
import 'package:split_view/split_view.dart';

enum MapPanelType {
  Map,
  Permission,
  Events,
  Others,
}

class MapPanel extends StatefulWidget {
  final MapPanelType panelType;

  MapPanel({
    Key? key,
    required this.panelType,
  }) : super(key: key);

  @override
  State<MapPanel> createState() => _MapPanelState();
}

class _MapPanelState extends State<MapPanel> {
  late final KeyInterceptorHandler _keyInterceptorHandler;
  var _isControlPressed = false;

  @override
  void initState() {
    super.initState();
    _keyInterceptorHandler = (event) {
      _isControlPressed = event.isControlPressed;
      return false;
    };
    KeyInterceptor.instance.registerHandler(_keyInterceptorHandler, stage: InterceptorStage.pre);
  }

  @override
  void dispose() {
    KeyInterceptor.instance.unregisterHandler(_keyInterceptorHandler, stage: InterceptorStage.pre);
    super.dispose();
  }

  List<CustomPaint> _constructPaints(Editor editor) {
    var mapInfo = editor.mapInfo!;
    var size = Size(mapInfo.width * editor.zoomLevel * SIZE_BLOCK,
        mapInfo.height * editor.zoomLevel * SIZE_BLOCK);
    var paints = <CustomPaint>[];
    paints.add(CustomPaint(
      painter: MapPainter(
          width: mapInfo.width,
          height: mapInfo.height,
          mapBlocks: mapInfo.mapBlocks,
          blocksheet: mapInfo.blocksheet,
          zoom: editor.zoomLevel),
      size: size,
    ));
    if (widget.panelType == MapPanelType.Permission) {
      paints.add(CustomPaint(
        painter: PermsPainter(
            width: mapInfo.width,
            height: mapInfo.height,
            permissions: mapInfo.mapBlocks.map((mapBlock) => mapBlock.permission).toList(),
            opacity: editor.opacityLevel,
            zoom: editor.zoomLevel),
        size: size,
      ));
    }
    if (widget.panelType == MapPanelType.Events) {
      // some kind of events painter
    }
    if (editor.showGrid) {
      paints.add(CustomPaint(
        painter: GridPainter(zoom: editor.zoomLevel),
        size: size,
      ));
    }
    return paints;
  }

  @override
  Widget build(BuildContext context) => SplitView(
          viewMode: SplitViewMode.Horizontal,
          indicator: SplitIndicator(
            viewMode: SplitViewMode.Horizontal,
            color: Colors.grey.shade600,
          ),
          activeIndicator: SplitIndicator(
            viewMode: SplitViewMode.Horizontal,
            color: Colors.black,
          ),
          gripSize: 10.0,
          gripColor: Colors.grey.shade200,
          gripColorActive: Colors.grey[350]!,
          controller: SplitViewController(weights: [0.75, 0.25]),
          children: [
            IfRomLoadedWidget(
              notLoadedBuilder: (editor) => Center(
                child: ElevatedButton(
                  onPressed: () => editor.loadRom(context),
                  child: const Text('Load ROM...'),
                ),
              ),
              loadedBuilder: (editor) {
                return PersistentBarScrollView(
                  child: Listener(
                      onPointerSignal: (PointerSignalEvent event) {
                        if (event is PointerScrollEvent && _isControlPressed) {
                          event.scrollDelta.dy < 0 ? editor.zoomIn() : editor.zoomOut();
                        }
                      },
                      child: Listener(
                          onPointerDown: (details) =>
                              editor.tool.onPointerDown(details, context, widget.panelType),
                          onPointerMove: (details) =>
                              editor.tool.onPointerMove(details, context, widget.panelType),
                          onPointerUp: (details) =>
                              editor.tool.onPointerUp(details, context, widget.panelType),
                          child: Stack(children: _constructPaints(editor)))),
                );
              },
            ),
            (panelType) {
              switch (panelType) {
                case MapPanelType.Map:
                  return BlocksheetPanel();
                case MapPanelType.Permission:
                  return PermsheetPanel();
                default:
                  return const SizedBox();
              }
            }(widget.panelType),
          ]);
}
