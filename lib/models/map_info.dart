import 'dart:ui' as ui;

import 'package:frame/models/bank_map.dart';
import 'package:frame/models/encounters.dart';
import 'package:frame/models/map_block.dart';

class MapInfo {
  final BankMap bankMap;
  final int width;
  final int height;
  final ui.Image blocksheet;
  final int numBlocks;
  final List<MapBlock> mapBlocks;
  final List<EncounterTable?> encounterTables;

  const MapInfo._({
    required this.bankMap,
    required this.width,
    required this.height,
    required this.blocksheet,
    required this.numBlocks,
    required this.mapBlocks,
    required this.encounterTables,
  });

  factory MapInfo.create(BankMap bankMap, Map<String, dynamic> partialMap, ui.Image blocksheet) =>
      MapInfo._(
        bankMap: bankMap,
        width: partialMap['width'],
        height: partialMap['height'],
        blocksheet: blocksheet,
        numBlocks: partialMap['num_blocks'],
        mapBlocks: partialMap['map_blocks'].map<MapBlock>((obj) => MapBlock.fromJson(obj)).toList(),
        encounterTables: _encounterTablesFromJson(partialMap['encounter_tables']),
      );

  MapInfo update(Map<String, dynamic> partialMap) => MapInfo._(
        bankMap: bankMap,
        width: partialMap['width'],
        height: partialMap['height'],
        blocksheet: blocksheet,
        numBlocks: partialMap['num_blocks'],
        mapBlocks: partialMap['map_blocks'].map<MapBlock>((obj) => MapBlock.fromJson(obj)).toList(),
        encounterTables: _encounterTablesFromJson(partialMap['encounter_tables']),
      );
}

List<EncounterTable?> _encounterTablesFromJson(List<dynamic>? json) => json == null
    ? List.filled(encounterTypes.length, null)
    : json.map((table) => table == null ? null : EncounterTable.fromJson(table)).toList();
