class RomInfo {
  final String filepath;
  final List<List<String>> banks;

  const RomInfo({
    required this.filepath,
    required this.banks,
  });

  factory RomInfo.emptyRom() => RomInfo(
        filepath: '',
        banks: [],
      );
}
