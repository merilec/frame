import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frame/notifiers/is_shortcut_enabled.dart';
import 'package:provider/provider.dart';

class DisableShortcutTextField extends StatefulWidget {
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final InputDecoration decoration;
  final TextStyle? style;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  DisableShortcutTextField({
    Key? key,
    this.controller,
    this.inputFormatters,
    this.keyboardType,
    this.decoration = const InputDecoration(),
    this.style,
    this.readOnly = false,
    this.onChanged,
  }) : super(key: key);

  @override
  State<DisableShortcutTextField> createState() => _DisableShortcutTextFieldState();
}

class _DisableShortcutTextFieldState extends State<DisableShortcutTextField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      var isShortcutEnabled = Provider.of<IsShortcutEnabled>(context, listen: false);
      isShortcutEnabled.value = !_focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    focusNode: _focusNode,
    controller: widget.controller,
    inputFormatters: widget.inputFormatters,
    keyboardType: widget.keyboardType,
    decoration: widget.decoration,
    style: widget.style,
    readOnly: widget.readOnly,
    onChanged: widget.onChanged,
  );
}
