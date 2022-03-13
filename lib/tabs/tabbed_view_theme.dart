import 'package:flutter/material.dart';
import 'package:tabbed_view/tabbed_view.dart';

TabbedViewThemeData getTabbedViewThemeData() {
  var themeData = TabbedViewThemeData();

  var tabBorder = Border(
    left: BorderSide(width: 0.7, color: Colors.grey.shade600),
    top: BorderSide(width: 0.7, color: Colors.grey.shade600),
    right: BorderSide(width: 0.7, color: Colors.grey.shade600),
  );

  themeData.tab
    ..padding = EdgeInsets.fromLTRB(10, 4, 10, 4)
    ..buttonsOffset = 8
    ..textStyle = TextStyle(color: Colors.grey.shade800, fontSize: 14)
    ..decoration =
        BoxDecoration(shape: BoxShape.rectangle, color: Colors.grey.shade200, border: tabBorder)
    ..selectedStatus.decoration = BoxDecoration(color: Colors.white, border: tabBorder)
    ..highlightedStatus.decoration = BoxDecoration(color: Colors.grey.shade300, border: tabBorder);

  themeData.tabsArea
    ..border = Border(bottom: BorderSide(width: 1, color: Colors.grey.shade600))
    ..initialGap = 8
    ..middleGap = 2;

  themeData.menu
    ..dividerColor = Colors.grey.shade600
    ..dividerThickness = 1.0
    ..ellipsisOverflowText = true
    ..color = Colors.grey.shade200
    ..hoverColor = Colors.grey.shade300
    ..maxWidth = 120
    ..border = Border(left: BorderSide(width: 1, color: Colors.grey.shade600))
    ..textStyle = TextStyle(color: Colors.grey.shade800, fontSize: 14)
    ..menuItemPadding = EdgeInsets.fromLTRB(10, 4, 10, 4)
    ..blur = false;

  return themeData;
}
