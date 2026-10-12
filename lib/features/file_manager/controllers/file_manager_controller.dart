import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/app_file_model.dart';
import '../../document_viewer/views/document_viewer_view.dart';
import '../../dashboard/models/recent_document.dart';

class FileManagerController extends GetxController {
  final RxList<AppFileModel> files = <AppFileModel>[].obs;
  Future<void> get ready => _restored;
  bool restoreFailed = false;
  bool Function(String)? isFileReadOnly;
  String Function(AppFileModel)? courseLabel;

  String courseFor(AppFileModel file) => courseLabel?.call(file) ?? file.course;

  SharedPreferences? _preferences;
  late final Future<void> _restored;
  Future<void> _saveQueue = Future.value();
  final isImporting = false.obs;
  final _sourcePaths = <String, String>{};
  final lastOpened = <String, DateTime>{}.obs;

  List<RecentDocument> get recentFiles {
    final recent =
        files.where((file) => lastOpened.containsKey(file.id)).toList()
          ..sort((a, b) => lastOpened[b.id]!.compareTo(lastOpened[a.id]!));
    return recent
        .take(8)
        .map(
          (file) => RecentDocument(
            fileId: file.id,
            name: file.name,
            course: courseFor(file),
            type: file.extension,
            lastOpened: 'Recently',
          ),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    _restored = _restoreFiles();
  }

  Future<void> _restoreFiles() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      final data = _preferences!.getString('library.files.v1');
      if (data == null) return;
      final decoded = jsonDecode(data) as List;
      final restored = <AppFileModel>[];
      for (final item in decoded) {
        final map = Map<String, dynamic>.from(item as Map);
        if (['1', '2', '3', '4', '5', '6'].contains(map['id']) &&
            RegExp(r'^/documents/(math204|cs302|cs305|cs307)/')
                .hasMatch(map['path'] as String) &&
            !await File(map['path'] as String).exists()) {
          continue;
        }
        restored.add(
          AppFileModel(
            id: map['id'] as String,
            name: map['name'] as String,
            path: map['path'] as String,
            sizeInBytes: map['size'] as int,
            extension: map['extension'] as String,
            dateAdded: DateTime.parse(map['date'] as String),
            course: map['course'] as String,
            isPinned: map['pinned'] as bool? ?? false,
          ),
        );
        if (map['opened'] is String) {
          final opened = DateTime.tryParse(map['opened'] as String);
          if (opened != null) lastOpened[map['id'] as String] = opened;
        }
        if (map['source'] is String) {
          _sourcePaths[map['id'] as String] = map['source'] as String;
        }
      }
      files.assignAll(restored);
    } catch (_) {
      restoreFailed = true;
      Get.snackbar(
        'Library',
        'The saved file list could not be restored. Your original documents have not been changed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _saveFiles() async {
    final data = jsonEncode(
      files
          .map(
            (file) => {
              'id': file.id,
              'name': file.name,
              'path': file.path,
              'size': file.sizeInBytes,
              'extension': file.extension,
              'date': file.dateAdded.toIso8601String(),
              'course': file.course,
              'pinned': file.isPinned,
              'source': _sourcePaths[file.id],
              'opened': lastOpened[file.id]?.toIso8601String(),
            },
          )
          .toList(),
    );
    _saveQueue = _saveQueue
        .then((_) async {
          final saved = await _preferences?.setString('library.files.v1', data);
          if (saved != true) {
            throw const FileSystemException(
              'The library list could not be saved.',
            );
          }
        })
        .catchError((Object _) {
          Get.snackbar(
            'Library',
            'The library list could not be saved. Check available disk space.',
            snackPosition: SnackPosition.BOTTOM,
          );
        });
    await _saveQueue;
  }

  final RxString searchQuery = ''.obs;
  final filterResetVersion = 0.obs;
  final RxString selectedFilter = 'ALL'.obs;
  final RxString sortBy = 'date'.obs;
  final RxBool sortAscending = false.obs;
  final RxString selectedFileId = ''.obs;

  List<AppFileModel> get favoriteFiles =>
      files.where((file) => file.isPinned).toList();

  List<AppFileModel> get filteredFiles => visibleFiles();

  List<AppFileModel> visibleFiles({bool favoritesOnly = false}) {
    return files.where((file) {
      if (favoritesOnly && !file.isPinned) return false;
      final matchesSearch =
          searchQuery.value.isEmpty ||
          file.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          courseFor(file)
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());

      final matchesFilter =
          selectedFilter.value == 'ALL' ||
          file.extension.toUpperCase() == selectedFilter.value.toUpperCase();

      return matchesSearch && matchesFilter;
    }).toList()..sort((a, b) {
      int comparison = 0;
      switch (sortBy.value) {
        case 'name':
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case 'size':
          comparison = a.sizeInBytes.compareTo(b.sizeInBytes);
          break;
        case 'date':
        default:
          comparison = a.dateAdded.compareTo(b.dateAdded);
          break;
      }
      return sortAscending.value ? comparison : -comparison;
    });
  }

  int get totalFilesCount => files.length;

  int get totalSizeBytes =>
      files.fold(0, (sum, item) => sum + item.sizeInBytes);

  String get formattedTotalStorage {
    if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (totalSizeBytes < 1024 * 1024 * 1024) {
      return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(totalSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  Future<void> pickAndImportFiles() async {
    await importFiles();
  }

  Future<List<String>> importFiles() async {
    if (isImporting.value) return [];
    final imported = <String>[];
    isImporting.value = true;
    try {
      await _restored;
      final pickedFiles = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'docx',
          'doc',
          'ppt',
          'pptx',
          'txt',
          'md',
          'xlsx',
          'csv',
        ],
      );
      if (pickedFiles.isEmpty) return imported;
      final root = await getApplicationSupportDirectory();
      final failed = <String>[];
      for (final picked in pickedFiles) {
        final source = picked.path;
        if (source != null && _sourcePaths.containsValue(p.normalize(source))) {
          final existingId = _sourcePaths.entries
              .firstWhere((entry) => entry.value == p.normalize(source))
              .key;
          imported.add(existingId);
          continue;
        }
        final id = DateTime.now().microsecondsSinceEpoch.toString();
        Directory? directory;
        try {
          directory = await Directory(p.join(root.path, 'imports', id))
              .create(recursive: true);
          final target = File(p.join(directory.path, p.basename(picked.name)));
          if (source != null && await File(source).exists()) {
            await File(source).copy(target.path);
          } else {
            await target.writeAsBytes(await picked.readAsBytes(), flush: true);
          }
          files.insert(
            0,
            AppFileModel(
              id: id,
              name: picked.name,
              path: target.path,
              sizeInBytes: await target.length(),
              extension: p
                  .extension(picked.name)
                  .replaceFirst('.', '')
                  .toUpperCase(),
              dateAdded: DateTime.now(),
              course: 'General',
            ),
          );
          imported.add(id);
          if (source != null) _sourcePaths[id] = p.normalize(source);
        } catch (_) {
          failed.add(picked.name);
          if (directory != null && await directory.exists()) {
            await directory.delete(recursive: true);
          }
        }
      }
      await _saveFiles();
      if (failed.isNotEmpty) {
        Get.snackbar(
          'Some files were not imported',
          failed.join(', '),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (error) {
      Get.snackbar(
        'Import failed',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isImporting.value = false;
    }
    return imported;
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedFilter.value = 'ALL';
    filterResetVersion.value++;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setSortBy(String field) {
    if (sortBy.value == field) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortBy.value = field;
      sortAscending.value = false;
    }
  }

  Future<void> openFile(AppFileModel file) async {
    if (!['PDF', 'DOCX'].contains(file.extension.toUpperCase())) {
      Get.snackbar(
        'Preview unavailable',
        'In-app viewing supports PDF and DOCX files.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (await File(file.path).exists()) {
      lastOpened[file.id] = DateTime.now();
      await _saveFiles();
    }
    selectedFileId.value = file.id;
    await Get.to<void>(
      () => DocumentViewerView(
        file: file.copyWith(course: courseFor(file)),
        onTogglePin: () => togglePin(file.id),
      ),
    );
  }

  void openFileById(String id) {
    final file = files.firstWhereOrNull((file) => file.id == id);
    if (file != null) openFile(file);
  }

  void openFileByName(String name) {
    final matches = files.where((file) => file.name == name).toList();
    if (matches.length == 1) {
      openFile(matches.single);
    } else {
      Get.snackbar(
        'Open from Library',
        matches.isEmpty ? 'Import this document first.' : 'Several files have this name. Select the correct file from Library.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void selectFile(String id) {
    selectedFileId.value = id;
  }

  bool _canEdit(String id) {
    if (isFileReadOnly?.call(id) != true) return true;
    Get.snackbar(
      'Archived file',
      'Restore the semester before renaming or removing this file.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return false;
  }

  Future<void> renameFile(String id, String name) async {
    await _restored;
    if (!_canEdit(id)) return;
    final index = files.indexWhere((file) => file.id == id);
    if (index < 0) return;
    final value = name.trim();
    if (value.isEmpty ||
        value.length > 180 ||
        RegExp(r'[<>:"/\\|?*\x00-\x1F]').hasMatch(value)) {
      throw ArgumentError('Enter a valid file name without path characters.');
    }
    final file = files[index];
    if (p.extension(value).toLowerCase() !=
        p.extension(file.name).toLowerCase()) {
      throw ArgumentError('Keep the original file extension.');
    }
    files[index] = file.copyWith(name: value);
    await _saveFiles();
  }

  void removeFile(String id) {
    if (!_canEdit(id)) return;
    files.removeWhere((file) => file.id == id);
    _sourcePaths.remove(id);
    lastOpened.remove(id);
    _saveFiles();
  }

  Future<void> togglePin(String id) async {
    await _restored;
    if (restoreFailed) return;
    final index = files.indexWhere((file) => file.id == id);
    if (index != -1) {
      final current = files[index];
      files[index] = current.copyWith(isPinned: !current.isPinned);
      await _saveFiles();
    }
  }
}
