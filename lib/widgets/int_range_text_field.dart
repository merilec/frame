import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntRangeTextField extends StatelessWidget {
  final TextEditingController? controller;
  final int Function() min;
  final int Function() max;
  final InputDecoration decoration;
  final TextStyle? style;
  final bool readOnly;
  final ValueChanged<String?>? onChanged;

  IntRangeTextField({
    Key? key,
    required this.controller,
    required this.min,
    required this.max,
    this.decoration = const InputDecoration(),
    this.style,
    this.readOnly = false,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _IntRangeFormatter(min: min, max: max),
      ],
      keyboardType: TextInputType.number,
      decoration: decoration,
      style: style,
      readOnly: readOnly,
      onChanged: onChanged,
    );
  }
}

class _IntRangeFormatter extends TextInputFormatter {
  final int Function() min;
  final int Function() max;

  _IntRangeFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      (!newValue.text.startsWith('0') &&
              int.tryParse(newValue.text) != null &&
              min() <= int.parse(newValue.text) &&
              int.parse(newValue.text) <= max())
          ? newValue
          : oldValue;
}
