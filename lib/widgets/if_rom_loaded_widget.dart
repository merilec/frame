import 'package:frame/notifiers/editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IfRomLoadedWidget extends StatelessWidget {
  final Widget Function(Editor) loadedBuilder;
  final Widget Function(Editor)? notLoadedBuilder;

  IfRomLoadedWidget({
    Key? key,
    required this.loadedBuilder,
    this.notLoadedBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Editor>(
      builder: (context, editor, _) => editor.mapInfo == null
          ? (notLoadedBuilder == null ? const SizedBox() : notLoadedBuilder!(editor))
          : loadedBuilder(editor),
    );
  }
}
