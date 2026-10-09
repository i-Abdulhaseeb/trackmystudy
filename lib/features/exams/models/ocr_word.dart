import 'dart:convert';

class OcrWord {
  const OcrWord({
    required this.text,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
  final String text;
  final double left;
  final double top;
  final double width;
  final double height;
  double get centerY => top + height / 2;

  factory OcrWord.fromMap(Map<Object?, Object?> map) => OcrWord(
    text: map['text'] as String,
    left: (map['left'] as num).toDouble(),
    top: (map['top'] as num).toDouble(),
    width: (map['width'] as num).toDouble(),
    height: (map['height'] as num).toDouble(),
  );
  static List<OcrWord> parseTsv(String tsv) {
    final words = <OcrWord>[];
    for (final line in const LineSplitter().convert(tsv)) {
      final cells = line.split('\t');
      if (cells.length < 12 || cells[0] != '5') continue;
      final text = cells.sublist(11).join('\t').trim();
      if (text.isEmpty) continue;
      final coordinates = [
        6,
        7,
        8,
        9,
      ].map((index) => double.tryParse(cells[index])).toList();
      if (coordinates.any((value) => value == null)) continue;
      words.add(
        OcrWord(
          text: text,
          left: coordinates[0]!,
          top: coordinates[1]!,
          width: coordinates[2]!,
          height: coordinates[3]!,
        ),
      );
    }
    return words;
  }
}
