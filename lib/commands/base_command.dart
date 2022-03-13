import 'package:frame/notifiers/editor.dart';

abstract class BaseCommand {
  String get name;
  void execute(Editor editor);
  void undo(Editor editor);
  void redo(Editor editor);
}
