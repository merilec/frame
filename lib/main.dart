import 'package:frame/constants.dart';
import 'package:frame/main_app.dart';
import 'package:frame/notifiers/editor.dart';
import 'package:frame/notifiers/is_shortcut_enabled.dart';
import 'package:frame/notifiers/status.dart';
import 'package:flutter/material.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:provider/provider.dart';

const String _defaultTitle = '$APP_NAME';
const Size _defaultWindowSize = Size(1000, 600);

void main() async {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<Editor>(create: (context) => Editor()),
      ChangeNotifierProvider<IsShortcutEnabled>(create: (context) => IsShortcutEnabled(true)),
      ChangeNotifierProvider<Status>(create: (context) => Status('')),
    ],
    child: WindowWidget(onCreateState: (initState) => MainWindowState()),
  ));
}

class MainWindowState extends WindowState {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WindowLayoutProbe(
        child: DefaultTextStyle(
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          child: MainApp(),
        ),
      ),
    );
  }

  @override
  WindowSizingMode get windowSizingMode => WindowSizingMode.manual;

  @override
  Future<void> initializeWindow(Size _contentSize) async {
    await window.setTitle(_defaultTitle);
    return super.initializeWindow(_defaultWindowSize);
  }
}
