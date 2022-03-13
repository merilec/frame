import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:frame/models/bank_map.dart';
import 'package:frame/models/map_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _channel = MethodChannel('platform_channel');

class Api {
  Api._();

  static Future<List<List<String>>> loadRom(String filepath) async {
    var result = (await _channel.invokeListMethod<List<Object?>>('load_rom', filepath))!;
    var mapBankNames =
        result.map((bank) => bank.map((mapName) => mapName!.toString()).toList()).toList();
    return mapBankNames;
  }

  static Future<bool> saveRom(String filepath) async {
    return (await _channel.invokeMethod<bool>('save_rom', filepath))!;
  }

  static Future<Map<String, dynamic>> getPartialMapInfo(BankMap bankMap) async {
    return jsonDecode(
        (await _channel.invokeMethod<String>('get_map_info', [bankMap.bankNum, bankMap.mapNum]))!);
  }

  static Future<ui.Image> getMapBlocksheet(BankMap bankMap) async {
    var imageString = (await _channel
        .invokeMethod<String>('get_map_blocksheet', [bankMap.bankNum, bankMap.mapNum]))!;
    return decodeImageFromList(base64Decode(imageString));
  }

  static Future<void> setMapBlocks(BankMap bankMap, Map<int, MapBlock> mapBlocksToPaint) {
    return _channel.invokeMethod('set_map_blocks', [
      bankMap.bankNum.toString(),
      bankMap.mapNum.toString(),
      jsonEncode(mapBlocksToPaint.map((key, value) => MapEntry(key.toString(), value)))
    ]);
  }
}
