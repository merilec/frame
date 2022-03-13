import 'package:flutter/material.dart';

class PersistentBarScrollView extends StatelessWidget {
  final Widget child;
  final BoxConstraints constraints;
  final _horizontalScrollController = ScrollController();
  final _verticalScrollController = ScrollController();
  final _thickness = 8.0;

  double get _padding => _thickness * 2;

  PersistentBarScrollView({
    Key? key,
    required this.child,
    this.constraints = const BoxConstraints(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scrollbar(
        controller: _verticalScrollController,
        thickness: _thickness,
        isAlwaysShown: true,
        trackVisibility: true,
        child: Scrollbar(
          controller: _horizontalScrollController,
          thickness: _thickness,
          notificationPredicate: (notification) => notification.depth == 1,
          isAlwaysShown: true,
          trackVisibility: true,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth + _padding,
              maxHeight: constraints.maxHeight + _padding,
            ),
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: Row(children: [
                  Column(children: [
                    child,
                    SizedBox(height: _padding),
                  ]),
                  SizedBox(width: _padding),
                ]),
              ),
            ),
          ),
        ),
      );
}
