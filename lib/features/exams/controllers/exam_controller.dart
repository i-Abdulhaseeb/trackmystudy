import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/exam.dart';
import '../models/exam_datesheet.dart';
import '../services/exam_format.dart';
import '../services/exam_ocr_service.dart';
import '../services/exam_print_service.dart';
import '../services/exam_store.dart';

enum ExamFilter { all, upcoming, completed }

class ExamController extends GetxController with WidgetsBindingObserver {
  ExamController({ExamStore? store, ExamOcrService? ocr})
    : _store =
          store ??
          ExamStore(
            () async => Directory(
              p.join(
                (await getApplicationSupportDirectory()).path,
                'exam_datesheets',
              ),
            ),
          ),
      _ocr = ocr ?? ExamOcrService();
  final ExamStore _store;
  final ExamOcrService _ocr;
  final sheets = <ExamDatesheet>[].obs;
  final activeId = RxnString();
  final now = DateTime.now().toUtc().obs;
  final statusTime = DateTime.now().toUtc().obs;
  final loading = true.obs;
  final importing = false.obs;
  final saving = false.obs;
  final printing = false.obs;
  final error = ''.obs;
  final importStatus = ''.obs;
  final filter = ExamFilter.all.obs;
  final calendar = false.obs;
  final month = DateTime(
    ExamFormat.local(DateTime.now().toUtc()).year,
    ExamFormat.local(DateTime.now().toUtc()).month,
  ).obs;
  Timer? _timer;

  ExamDatesheet? get activeSheet =>
      sheets.firstWhereOrNull((sheet) => sheet.id == activeId.value);
  List<Exam> get exams => activeSheet?.exams ?? const [];
  ExamClock get clock => ExamClock.at(exams, now.value);
  bool get busy => loading.value || importing.value || saving.value;
  List<Exam> get visibleExams => exams
      .where(
        (exam) => switch (filter.value) {
          ExamFilter.all => true,
          ExamFilter.upcoming =>
            exam.phaseAt(statusTime.value) != ExamPhase.completed,
          ExamFilter.completed =>
            exam.phaseAt(statusTime.value) == ExamPhase.completed,
        },
      )
      .toList();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    unawaited(reload());
  }

  void _tick() {
    final instant = DateTime.now().toUtc();
    now.value = instant;
    if (ExamFormat.date(instant) != ExamFormat.date(statusTime.value) ||
        exams.any(
          (exam) => exam.phaseAt(instant) != exam.phaseAt(statusTime.value),
        )) {
      statusTime.value = instant;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tick();
  }

  Future<void> reload() async {
    loading.value = true;
    error.value = '';
    try {
      final data = await _store.load();
      sheets.assignAll(data.sheets);
      activeId.value = data.activeId;
      _focusMonth();
    } catch (_) {
      error.value = 'Saved datesheets could not be loaded. Check access to the application data folder and retry.';
    } finally {
      loading.value = false;
    }
  }

  Future<void> importImage() async {
    if (busy) return;
    importing.value = true;
    error.value = '';
    File? source;
    var committed = false;
    try {
      importStatus.value = 'Choose a datesheet image';
      final selected = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'bmp'],
      );
      if (selected.isEmpty) return;
      final image = selected.single;
      if ((await image.length() ?? 0) > 25 * 1024 * 1024) {
        throw const FormatException('Choose an image smaller than 25 MB.');
      }
      final extension = p.extension(image.name).toLowerCase();
      if (!['.png', '.jpg', '.jpeg', '.bmp'].contains(extension)) {
        throw const FormatException('Use a PNG, JPG or BMP image.');
      }
      final bytes = await image.readAsBytes();
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      final imageName = 'sheet_$id$extension';
      source = await _store.writeSource(imageName, bytes);
      importStatus.value = 'Reading the datesheet on your device…';
      final parsed = await _ocr.readDatesheet(source.path);
      importStatus.value = 'Saving your datesheet…';
      final sheet = ExamDatesheet(
        id: id,
        name: p.basenameWithoutExtension(image.name),
        imageName: imageName,
        importedAt: DateTime.now().toUtc(),
        exams: parsed,
      );
      final updated = [sheet, ...sheets];
      await _store.save(updated, id);
      committed = true;
      sheets.assignAll(updated);
      activeId.value = id;
      filter.value = ExamFilter.all;
      _tick();
      _focusMonth();
    } catch (exception) {
      error.value = _message(exception);
    } finally {
      if (!committed && source != null) {
        try {
          if (await source.exists()) await source.delete();
        } catch (_) {}
      }
      importing.value = false;
      importStatus.value = '';
    }
  }

  Future<void> selectSheet(String? id) async {
    if (id == null ||
        id == activeId.value ||
        busy ||
        !sheets.any((sheet) => sheet.id == id)) {
      return;
    }
    saving.value = true;
    try {
      await _store.save(sheets.toList(), id);
      activeId.value = id;
      filter.value = ExamFilter.all;
      _focusMonth();
      error.value = '';
    } catch (exception) {
      error.value = _message(exception);
    } finally {
      saving.value = false;
    }
  }

  Future<File?> sourceImage() async {
    final sheet = activeSheet;
    if (sheet == null) return null;
    final file = await _store.source(sheet.imageName);
    if (!await file.exists()) {
      error.value = 'The original image is missing. Upload the datesheet again to restore it.';
      return null;
    }
    return file;
  }

  Future<void> printDatesheet() async {
    final sheet = activeSheet;
    if (sheet == null || printing.value) return;
    printing.value = true;
    try {
      await ExamPrintService().printSheet(sheet);
    } catch (exception) {
      error.value = _message(exception);
    } finally {
      printing.value = false;
    }
  }

  void moveMonth(int delta) =>
      month.value = DateTime(month.value.year, month.value.month + delta);

  void _focusMonth() {
    statusTime.value = DateTime.now().toUtc();
    final target = clock.exam ?? exams.firstOrNull;
    final date = ExamFormat.local(target?.startsAt ?? now.value);
    month.value = DateTime(date.year, date.month);
  }

  String _message(Object exception) => switch (exception) {
    FormatException() => exception.message,
    PlatformException() =>
      exception.message ?? 'Image recognition failed. Try a clearer image.',
    UnsupportedError() =>
      exception.message ?? 'This platform is not supported.',
    StateError() => exception.message,
    FileSystemException() => 'The datesheet could not be saved. Check folder access and available disk space.',
    _ => 'The datesheet could not be processed. Try a clearer image of the complete table.',
  };

  @override
  void onClose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
