import 'package:frame/panels/encounters_panel.dart';
import 'package:frame/panels/map_panel.dart';
import 'package:flutter/material.dart';
import 'package:tabbed_view/tabbed_view.dart';

TabbedViewController get tabbedViewController => _controller;

final _controller = TabbedViewController([
  TabData(
    text: 'Map',
    closable: false,
    content: MapPanel(panelType: MapPanelType.Map),
    keepAlive: true,
    buttons: [
      TabButton(
        icon: IconProvider.data(Icons.map),
        disabledColor: Colors.grey.shade800,
        iconSize: 20,
      )
    ],
  ),
  TabData(
    text: 'Permissions',
    closable: false,
    content: MapPanel(panelType: MapPanelType.Permission),
    keepAlive: true,
    buttons: [
      TabButton(
        icon: IconProvider.data(Icons.border_horizontal),
        disabledColor: Colors.grey.shade800,
        iconSize: 20,
      )
    ],
  ),
  TabData(
    text: 'Wild Encounters ',
    closable: false,
    content: EncountersPanel(),
    keepAlive: true,
    buttons: [
      TabButton(
        icon: IconProvider.data(Icons.grass),
        disabledColor: Colors.grey.shade800,
        iconSize: 20,
      )
    ],
  ),
]);
