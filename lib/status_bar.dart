import 'package:frame/notifiers/status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Consumer<Status>(builder: (context, status, child) => Text(status.value)),
      ),
    );
  }
}
