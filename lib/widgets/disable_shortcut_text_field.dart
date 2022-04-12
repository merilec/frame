import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frame/notifiers/is_shortcut_enabled.dart';
import 'package:provider/provider.dart';

class DisableShortcutTextField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (receivedFocus) {
        var isShortcutEnabled = Provider.of<IsShortcutEnabled>(context, listen: false);
        isShortcutEnabled.value = !receivedFocus;
      },
      child: TextField(
        controller: controller,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        decoration: decoration,
        style: style,
        readOnly: readOnly,
        onChanged: onChanged,
      ),
    );
  }
}
