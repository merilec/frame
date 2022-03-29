import 'dart:ui';

import 'package:flutter/foundation.dart';

final encounterTypes =
    List<String>.unmodifiable(['Grass', 'Surf', 'Rock Smash', 'Old Rod', 'Good Rod', 'Super Rod']);

class EncounterEntry {
  final int minLevel;
  final int maxLevel;
  final int species;

  const EncounterEntry(this.minLevel, this.maxLevel, this.species);

  factory EncounterEntry.fromJson(Map<String, dynamic> json) => EncounterEntry(
        json['min_level'],
        json['max_level'],
        json['species'],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'min_level': minLevel,
        'max_level': maxLevel,
        'species': species,
      };

  @override
  bool operator ==(Object other) =>
      other is EncounterEntry &&
      runtimeType == other.runtimeType &&
      minLevel == other.minLevel &&
      maxLevel == other.maxLevel &&
      species == other.species;

  @override
  int get hashCode => hashValues(minLevel, maxLevel, species);

  @override
  String toString() {
    return '(min: $minLevel, max: $maxLevel, species: $species)';
  }
}

class EncounterTable {
  final int encounterRate;
  final List<EncounterEntry> entries;

  const EncounterTable(this.encounterRate, this.entries);

  factory EncounterTable.fromJson(Map<String, dynamic> json) => EncounterTable(
        json['encounter_rate'],
        json['entries'].map<EncounterEntry>((obj) => EncounterEntry.fromJson(obj)).toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'encounter_rate': encounterRate,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      other is EncounterTable &&
      runtimeType == other.runtimeType &&
      encounterRate == other.encounterRate &&
      listEquals(entries, other.entries);

  @override
  int get hashCode => hashValues(encounterRate, entries);

  @override
  String toString() {
    return '(encounterRate: $encounterRate, entries: $entries)';
  }
}
