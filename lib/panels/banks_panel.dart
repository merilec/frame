import 'package:frame/models/bank_map.dart';
import 'package:frame/notifiers/editor.dart';
import 'package:frame/notifiers/status.dart';
import 'package:frame/widgets/if_rom_loaded_widget.dart';
import 'package:flutter/material.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:provider/provider.dart';

class BanksPanel extends StatelessWidget {
  const BanksPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IfRomLoadedWidget(
      loadedBuilder: (editor) => ListView(
          shrinkWrap: true,
          children: editor.romInfo.banks.asMap().entries.map((bankEntry) {
            var bankNum = bankEntry.key;
            var bank = bankEntry.value;
            return _BankTile(
              bankNum: bankNum,
              bank: bank,
              currBankMap: editor.mapInfo!.bankMap,
            );
          }).toList()),
    );
  }
}

class _BankTile extends StatefulWidget {
  final int bankNum;
  final List<String> bank;
  final BankMap currBankMap;

  const _BankTile({
    Key? key,
    required this.bankNum,
    required this.bank,
    required this.currBankMap,
  }) : super(key: key);

  @override
  _BankTileState createState() => _BankTileState();
}

class _BankTileState extends State<_BankTile> {
  bool _tileExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        controlAffinity: ListTileControlAffinity.leading,
        tilePadding: const EdgeInsets.fromLTRB(4, 0, 8, 0),
        leading: Icon(_tileExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right),
        title: Transform.translate(
          offset: const Offset(-24, 0),
          child: Text(
            'Bank ${widget.bankNum}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: (widget.bankNum == widget.currBankMap.bankNum)
                    ? FontWeight.bold
                    : FontWeight.normal),
          ),
        ),
        trailing: Text(
          widget.bank.length == 1 ? '(1 map)' : '(${widget.bank.length} maps)',
          overflow: TextOverflow.ellipsis,
        ),
        onExpansionChanged: (isExpanded) {
          setState(() => _tileExpanded = isExpanded);
        },
        children: widget.bank.asMap().entries.map((entry) {
          var mapNum = entry.key;
          var mapName = entry.value;
          return ListTile(
            leading: Text(
              '${widget.bankNum}.$mapNum',
              overflow: TextOverflow.ellipsis,
            ),
            title: Transform.translate(
              offset: const Offset(-12, 0),
              child: Text(
                mapName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: (widget.bankNum == widget.currBankMap.bankNum &&
                            mapNum == widget.currBankMap.mapNum)
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
            ),
            onTap: () async {
              var editor = Provider.of<Editor>(context, listen: false);
              var status = Provider.of<Status>(context, listen: false);
              await editor.setAsCurrentMap(
                  BankMap(widget.bankNum, mapNum), Window.of(context), status);
            },
          );
        }).toList());
  }
}
