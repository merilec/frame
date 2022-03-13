import 'package:frame/api/api.dart';
import 'package:frame/commands/base_command.dart';
import 'package:frame/models/bank_map.dart';
import 'package:frame/models/map_block.dart';
import 'package:frame/notifiers/editor.dart';

class SetMapBlocksCommand extends BaseCommand {
  @override
  final String name;
  final BankMap bankMap;
  final Map<int, MapBlock> oldMapBlocks;
  final Map<int, MapBlock> newMapBlocks;

  SetMapBlocksCommand({
    required this.name,
    required this.bankMap,
    required this.oldMapBlocks,
    required this.newMapBlocks,
  });

  @override
  void execute(Editor editor) async {
    await Api.setMapBlocks(bankMap, newMapBlocks);
    editor.updateCurrentMap();
  }

  @override
  void undo(Editor editor) async {
    await Api.setMapBlocks(bankMap, oldMapBlocks);
    editor.updateCurrentMap();
  }

  @override
  void redo(Editor editor) async {
    await Api.setMapBlocks(bankMap, newMapBlocks);
    editor.updateCurrentMap();
  }
}
