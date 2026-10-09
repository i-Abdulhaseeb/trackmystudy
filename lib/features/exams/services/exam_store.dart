import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../models/exam_datesheet.dart';

class ExamStoreSnapshot {
  const ExamStoreSnapshot(this.sheets, this.activeId);
  final List<ExamDatesheet> sheets;
  final String? activeId;
}

class ExamStore {
  ExamStore(this._locate);
  final Future<Directory> Function() _locate;
  Directory? _directory;
  Future<Directory> get directory async =>
      _directory ??= await (await _locate()).create(recursive: true);

  Future<File> source(String name) async =>
      File(p.join((await directory).path, name));

  Future<ExamStoreSnapshot> load() async {
    final root = await directory;
    final file = File(p.join(root.path, 'schedules.json'));
    final backup = File('${file.path}.bak');
    for (final candidate in [file, backup]) {
      if (!await candidate.exists()) continue;
      try {
        final json =
            jsonDecode(await candidate.readAsString()) as Map<String, dynamic>;
        if (json['version'] != 1) {
          throw const FormatException('Unsupported datesheet data version.');
        }
        final sheets = (json['sheets'] as List)
            .map(
              (item) => ExamDatesheet.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
        final active = json['active'] as String?;
        if (sheets.map((sheet) => sheet.id).toSet().length != sheets.length) {
          throw const FormatException('Duplicate datesheet identifiers.');
        }
        if (candidate == backup) await backup.copy(file.path);
        return ExamStoreSnapshot(
          sheets,
          sheets.any((sheet) => sheet.id == active)
              ? active
              : sheets.firstOrNull?.id,
        );
      } catch (_) {
        if (candidate == backup || !await backup.exists()) rethrow;
      }
    }
    return const ExamStoreSnapshot([], null);
  }

  Future<void> save(List<ExamDatesheet> sheets, String activeId) async {
    final root = await directory;
    final file = File(p.join(root.path, 'schedules.json'));
    final temporary = File('${file.path}.tmp');
    final backup = File('${file.path}.bak');
    await temporary.writeAsString(
      jsonEncode({
        'version': 1,
        'active': activeId,
        'sheets': sheets.map((sheet) => sheet.toJson()).toList(),
      }),
      flush: true,
    );
    if (await file.exists()) {
      if (await backup.exists()) await backup.delete();
      await file.rename(backup.path);
    }
    try {
      await temporary.rename(file.path);
    } catch (_) {
      if (await backup.exists() && !await file.exists()) {
        await backup.copy(file.path);
      }
      rethrow;
    }
  }

  Future<File> writeSource(String name, Uint8List bytes) async =>
      (await source(name)).writeAsBytes(bytes, flush: true);
}
