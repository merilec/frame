import 'package:flutter/material.dart';
import 'package:frame/api/api.dart';
import 'package:frame/models/bank_map.dart';
import 'package:frame/models/encounters.dart';
import 'package:frame/tabs/tabbed_view_theme.dart';
import 'package:frame/widgets/if_rom_loaded_widget.dart';
import 'package:frame/widgets/int_range_text_field.dart';
import 'package:tabbed_view/tabbed_view.dart';

class EncountersPanel extends StatelessWidget {
  const EncountersPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IfRomLoadedWidget(
      loadedBuilder: (editor) => Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
        child: TabbedViewTheme(
          data: getTabbedViewThemeData(),
          child: TabbedView(
              controller: TabbedViewController(
                  editor.mapInfo!.encounterTables.asMap().entries.map((mapEntry) {
            var encounterType = mapEntry.key;
            var table = mapEntry.value;
            return TabData(
              text: encounterTypes[encounterType],
              closable: false,
              content: table == null
                  ? const Text('no table')
                  : _EncounterTab(
                      encounterTable: table,
                      encounterType: encounterType,
                      bankMap: editor.mapInfo!.bankMap,
                    ),
              keepAlive: true,
            );
          }).toList())),
        ),
      ),
    );
  }
}

class _EncounterTab extends StatefulWidget {
  final EncounterTable encounterTable;
  final int encounterType;
  final BankMap bankMap;

  const _EncounterTab({
    Key? key,
    required this.encounterTable,
    required this.encounterType,
    required this.bankMap,
  }) : super(key: key);

  @override
  State<_EncounterTab> createState() => _EncounterTabState();
}

class _EncounterTabState extends State<_EncounterTab> {
  final _controllers = <String, TextEditingController>{};

  void update(int entryNum) => Api.setWildEncounters(
        widget.bankMap,
        widget.encounterType,
        entryNum,
        EncounterEntry(
          int.parse(_controllers['${entryNum}_minLevel']!.text),
          int.parse(_controllers['${entryNum}_maxLevel']!.text),
          int.parse(_controllers['${entryNum}_species']!.text),
        ),
      );

  @override
  void initState() {
    super.initState();
    widget.encounterTable.entries.asMap().forEach((entryNum, entry) {
      _controllers['${entryNum}_minLevel'] = TextEditingController(text: entry.minLevel.toString());
      _controllers['${entryNum}_maxLevel'] = TextEditingController(text: entry.maxLevel.toString());
      _controllers['${entryNum}_species'] = TextEditingController(text: entry.species.toString());
    });
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(label: const Text('Slot')),
            DataColumn(label: const Text('Pok\u00e9mon')),
            DataColumn(label: const Text('Min Level')),
            DataColumn(label: const Text('Max Level')),
          ],
          rows: widget.encounterTable.entries
              .asMap()
              .map((entryNum, entry) => MapEntry(
                  entryNum,
                  DataRow(
                      cells: [
                    Text((entryNum + 1).toString()),
                    IntRangeTextField(
                      controller: _controllers['${entryNum}_species'],
                      min: () => 1,
                      max: () => 151,
                      onChanged: (_) => update(entryNum),
                    ),
                    IntRangeTextField(
                      controller: _controllers['${entryNum}_minLevel'],
                      min: () => 1,
                      max: () => int.parse(_controllers['${entryNum}_maxLevel']!.text),
                      onChanged: (_) => update(entryNum),
                    ),
                    IntRangeTextField(
                      controller: _controllers['${entryNum}_maxLevel'],
                      min: () => int.parse(_controllers['${entryNum}_minLevel']!.text),
                      max: () => 100,
                      onChanged: (_) => update(entryNum),
                    ),
                  ].map((widget) => DataCell(widget)).toList())))
              .values
              .toList(),
        ),
      ),
    );
  }
}
