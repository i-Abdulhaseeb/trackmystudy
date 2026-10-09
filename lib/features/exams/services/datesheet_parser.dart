import 'dart:math' as math;

import '../models/exam.dart';
import '../models/ocr_word.dart';
import 'exam_format.dart';

class DatesheetParser {
  const DatesheetParser();

  List<Exam> parse(List<OcrWord> rawWords) {
    final words = _deduplicate(
      rawWords
          .where((word) => word.text.trim().isNotEmpty && word.height > 0)
          .toList(),
    );
    if (words.isEmpty) {
      throw const FormatException(
        'No text could be read. Upload a clear image of the full table.',
      );
    }
    final lines = _lines(words);
    Map<String, OcrWord>? header;
    for (final line in lines) {
      final found = <String, OcrWord>{};
      for (final word in line) {
        final label = _header(word.text);
        if (label != null) found.putIfAbsent(label, () => word);
      }
      if ([
        'subject',
        'teacher',
        'date',
        'time',
        'venue',
      ].every(found.containsKey)) {
        header = found;
        break;
      }
    }
    if (header == null) {
      throw const FormatException(
        'The Class, Teacher, Date, Time and Venue headers were not read. Include the entire header row in a sharper image.',
      );
    }
    final columns = ['subject', 'teacher', 'date', 'time', 'venue'];
    final starts = columns.map((name) => header![name]!.left).toList();
    for (var i = 1; i < starts.length; i++) {
      if (starts[i] <= starts[i - 1]) {
        throw const FormatException(
          'Unsupported table layout. Expected order: Class, Teacher, Date, Time, Venue.',
        );
      }
    }
    final headerBottom = header.values
        .map((word) => word.top + word.height)
        .reduce(math.max);
    final tolerance =
        header.values.map((word) => word.height).reduce(math.min) * 0.45;
    final body = words
        .where((word) => word.centerY > headerBottom + 1)
        .toList();
    final dateLines = _lines(
      body
          .where(
            (word) =>
                word.left >= starts[2] - tolerance &&
                word.left < starts[3] - tolerance,
          )
          .toList(),
    );
    final anchors = dateLines.map((line) {
      final top = line.map((word) => word.top).reduce(math.min);
      final bottom = line
          .map((word) => word.top + word.height)
          .reduce(math.max);
      return OcrWord(
        text: line.map((word) => word.text).join(' '),
        left: starts[2],
        top: top,
        width: starts[3] - starts[2],
        height: bottom - top,
      );
    }).toList();
    if (anchors.isEmpty) {
      throw const FormatException(
        'No exam dates were read. Include the complete table and its headers.',
      );
    }
    final timeLines = _lines(
      body
          .where(
            (word) =>
                word.left >= starts[3] - tolerance &&
                word.left < starts[4] - tolerance,
          )
          .toList(),
    );
    for (final line in timeLines) {
      final center =
          line.map((word) => word.centerY).reduce((a, b) => a + b) /
          line.length;
      if (!anchors.any(
        (anchor) => (anchor.centerY - center).abs() <= anchor.height,
      )) {
        throw const FormatException(
          'An exam time has no readable date. Upload the complete table with all dates visible.',
        );
      }
    }
    final serials = body
        .where(
          (word) =>
              word.left < starts.first - tolerance &&
              RegExp(r'^\d{1,3}[.)]?$').hasMatch(word.text.trim()),
        )
        .toList();
    for (final serial in serials) {
      final matches = anchors.indexWhere(
        (anchor) =>
            (anchor.centerY - serial.centerY).abs() <=
            math.max(anchor.height, serial.height),
      );
      if (matches < 0 ||
          int.parse(serial.text.replaceAll(RegExp(r'\D'), '')) != matches + 1) {
        throw const FormatException(
          'A readable row number does not match the exam rows. Check that every date and time is visible.',
        );
      }
    }
    final exams = <Exam>[];
    final failures = <String>[];
    for (var i = 0; i < anchors.length; i++) {
      final anchor = anchors[i];
      final order = i + 1;
      final lower = i == 0
          ? headerBottom
          : (anchors[i - 1].centerY + anchor.centerY) / 2;
      final typicalGap = anchors.length > 1
          ? (i == 0
                ? anchors[1].centerY - anchor.centerY
                : anchor.centerY - anchors[i - 1].centerY)
          : anchor.height * 3;
      final upper = i + 1 < anchors.length
          ? (anchor.centerY + anchors[i + 1].centerY) / 2
          : anchor.centerY + math.max(typicalGap / 2, anchor.height * 1.2);
      final cells = List.generate(5, (_) => <OcrWord>[]);
      for (final word in body) {
        if (word.centerY < lower ||
            word.centerY >= upper ||
            word.left < starts.first - tolerance) {
          continue;
        }
        var column = 0;
        while (column + 1 < starts.length &&
            word.left >= starts[column + 1] - tolerance) {
          column++;
        }
        cells[column].add(word);
      }
      final values = cells
          .map(
            (cell) =>
                _lines(cell)
                    .map((line) => line.map((word) => word.text).join(' '))
                    .join(' ')
                    .trim(),
          )
          .toList();
      try {
        exams.add(
          parseRow(
            order: order,
            subject: values[0],
            teacher: values[1],
            date: values[2],
            time: values[3],
            venue: values[4],
          ),
        );
      } on FormatException catch (error) {
        failures.add('Row $order: ${error.message}');
      }
    }
    if (failures.isNotEmpty) {
      throw FormatException(
        '${failures.join('\n')}\nThe previous datesheet is unchanged. Re-upload a sharper image.',
      );
    }
    final dateWordsBelowRows = body.where(
      (word) =>
          word.centerY > anchors.last.centerY + anchors.last.height * 2 &&
          RegExp(r'^20\d{2}[-/]\d').hasMatch(word.text),
    );
    if (dateWordsBelowRows.isNotEmpty) {
      throw const FormatException(
        'Additional exam dates were found without readable row numbers. Re-upload the complete, clear table.',
      );
    }
    exams.sort(ExamClock.compare);
    return List.unmodifiable(exams);
  }

  Exam parseRow({
    required int order,
    required String subject,
    required String teacher,
    required String date,
    required String time,
    required String venue,
  }) {
    if (subject.trim().isEmpty ||
        teacher.trim().isEmpty ||
        venue.trim().isEmpty) {
      throw const FormatException(
        'A subject, teacher or venue could not be read.',
      );
    }
    final normalizedDate = date
        .replaceAll(RegExp(r'\s'), '')
        .replaceAll(RegExp('[–—−]'), '-');
    final iso = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$')
        .firstMatch(normalizedDate);
    final dayFirst = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})$')
        .firstMatch(normalizedDate);
    if (iso == null && dayFirst == null) {
      throw FormatException(
        'Unreadable date "$date". Use YYYY-MM-DD or DD-MM-YYYY.',
      );
    }
    final match = iso ?? dayFirst!;
    final year = int.parse(match.group(iso == null ? 3 : 1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(iso == null ? 1 : 3)!);
    final calendarDate = DateTime.utc(year, month, day);
    if (year < 2000 ||
        year > 2100 ||
        calendarDate.year != year ||
        calendarDate.month != month ||
        calendarDate.day != day) {
      throw FormatException('Invalid date "$date".');
    }
    final normalizedTime = time
        .toUpperCase()
        .replaceAll(RegExp('[–—−]'), '-')
        .replaceAll(RegExp(r'\bTO\b'), '-')
        .replaceAllMapped(
          RegExp(r'\b([AP])\s*\.?\s*M\.?'),
          (match) => '${match.group(1)}M',
        );
    final pattern = RegExp(
      r'^\s*(\d{1,2})\s*[:.]\s*(\d{2})\s*(AM|PM)?\s*-\s*(\d{1,2})\s*[:.]\s*(\d{2})\s*(AM|PM)?\s*$',
    );
    final clock = pattern.firstMatch(normalizedTime);
    if (clock == null) throw FormatException('Unreadable time range "$time".');
    if ((clock.group(3) == null) != (clock.group(6) == null)) {
      throw FormatException('Ambiguous AM/PM range "$time".');
    }
    int hour(String raw, String? period) {
      final value = int.parse(raw);
      if (period == null) {
        if (value > 23) throw const FormatException('Invalid 24-hour time.');
        return value;
      }
      if (value < 1 || value > 12) {
        throw const FormatException('Invalid 12-hour time.');
      }
      return value % 12 + (period == 'PM' ? 12 : 0);
    }

    final startMinute = int.parse(clock.group(2)!);
    final endMinute = int.parse(clock.group(5)!);
    if (startMinute > 59 || endMinute > 59) {
      throw const FormatException('Invalid minutes.');
    }
    final start = ExamFormat.fromLocal(
      year,
      month,
      day,
      hour(clock.group(1)!, clock.group(3)),
      startMinute,
    );
    var end = ExamFormat.fromLocal(
      year,
      month,
      day,
      hour(clock.group(4)!, clock.group(6)),
      endMinute,
    );
    if (end.isBefore(start)) end = end.add(const Duration(days: 1));
    if (end.difference(start) <= Duration.zero ||
        end.difference(start) > const Duration(hours: 12)) {
      throw FormatException('Invalid exam duration "$time".');
    }
    return Exam(
      order: order,
      subject: subject.trim(),
      teacher: teacher.trim(),
      startsAt: start,
      endsAt: end,
      venue: venue.replaceAll(RegExp(r'\s*-\s*'), '-').trim(),
    );
  }

  String? _header(String text) =>
      switch (text.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '')) {
        'class' || 'subject' || 'course' => 'subject',
        'teacher' || 'instructor' => 'teacher',
        'date' => 'date',
        'time' => 'time',
        'venue' || 'room' => 'venue',
        _ => null,
      };

  List<OcrWord> _deduplicate(List<OcrWord> words) {
    final sorted = [...words]..sort((a, b) => a.top.compareTo(b.top));
    final result = <OcrWord>[];
    for (final word in sorted) {
      final duplicate = result.reversed
          .takeWhile((previous) => word.top - previous.top < 5)
          .any(
            (previous) =>
                previous.text == word.text &&
                (previous.left - word.left).abs() < 3 &&
                (previous.centerY - word.centerY).abs() < 3,
          );
      if (!duplicate) result.add(word);
    }
    return result;
  }

  List<List<OcrWord>> _lines(List<OcrWord> words) {
    final sorted = [...words]..sort((a, b) => a.centerY.compareTo(b.centerY));
    final lines = <List<OcrWord>>[];
    for (final word in sorted) {
      if (lines.isEmpty ||
          (word.centerY - lines.last.first.centerY).abs() >
              math.max(word.height, lines.last.first.height) * 0.6) {
        lines.add([word]);
      } else {
        lines.last.add(word);
      }
    }
    for (final line in lines) {
      line.sort((a, b) => a.left.compareTo(b.left));
    }
    return lines;
  }
}
