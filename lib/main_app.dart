import 'package:frame/tabs/tabbed_view_controller.dart';
import 'package:frame/tabs/tabbed_view_theme.dart';
import 'package:frame/panels/banks_panel.dart';
import 'package:frame/menu/menu.dart';
import 'package:frame/status_bar.dart';
import 'package:flutter/material.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:split_view/split_view.dart';
import 'package:tabbed_view/tabbed_view.dart';

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicSizedBox(
      intrinsicWidth: 400,
      intrinsicHeight: 300,
      child: Scaffold(
        body: Column(children: [
          MyMenuBar(),
          Expanded(
            child: SplitView(
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
              controller: SplitViewController(weights: [0.2, 0.8]),
              children: [
                BanksPanel(),
                TabbedViewTheme(
                  data: getTabbedViewThemeData(),
                  child: TabbedView(controller: tabbedViewController),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          StatusBar(),
        ]),
      ),
    );
  }
}
