import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/app_file_model.dart';
// import '../../document_viewer/views/document_viewer_view.dart';
import '../../dashboard/models/recent_document.dart';

class FileManagerController extends GetxController {
  final RxList<AppFileModel> files = <AppFileModel>[
    AppFileModel(
      id: '1',
      name: "Lecture 05 - Rolle's Theorem.pdf",
      path: '/documents/math204/lecture_05.pdf',
      sizeInBytes: 3420000,
      extension: 'PDF',
      dateAdded: DateTime.now().subtract(const Duration(hours: 3)),
      course: 'Calculus',
    ),
    AppFileModel(
      id: '2',
      name: 'Database Normalization.pptx',
      path: '/documents/cs302/normalization.pptx',
      sizeInBytes: 12580000,
      extension: 'PPTX',
      dateAdded: DateTime.now().subtract(const Duration(days: 1)),
      course: 'Database Systems',
    ),
    AppFileModel(
      id: '3',
      name: 'Automata Assignment 02.docx',
      path: '/documents/cs305/assignment_02.docx',
      sizeInBytes: 1840000,
      extension: 'DOCX',
      dateAdded: DateTime.now().subtract(const Duration(days: 2)),
      course: 'Theory of Automata',
    ),
    AppFileModel(
      id: '4',
      name: 'Virtual Memory & Paging.pdf',
      path: '/documents/cs307/virtual_memory.pdf',
      sizeInBytes: 5120000,
      extension: 'PDF',
      dateAdded: DateTime.now().subtract(const Duration(days: 3)),
      course: 'Operating Systems',
    ),
    AppFileModel(
      id: '5',
      name: 'Calculus_Formula_Sheet_v3.pdf',
      path: '/documents/math204/formula_sheet.pdf',
      sizeInBytes: 890000,
      extension: 'PDF',
      dateAdded: DateTime.now().subtract(const Duration(days: 5)),
      course: 'Calculus',
      isPinned: true,
    ),
    AppFileModel(
      id: '6',
      name: 'Relational_Algebra_Cheatsheet.md',
      path: '/documents/cs302/relational_algebra.md',
      sizeInBytes: 45000,
      extension: 'MD',
      dateAdded: DateTime.now().subtract(const Duration(days: 6)),
      course: 'Database Systems',
      isPinned: true,
    ),
  ].obs;

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
            course: file.course,
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
  final RxString selectedFilter = 'ALL'.obs;
  final RxString sortBy = 'date'.obs;
  final RxBool sortAscending = false.obs;
  final RxString selectedFileId = ''.obs;

  List<AppFileModel> get filteredFiles {
    return files.where((file) {
      final matchesSearch =
          searchQuery.value.isEmpty ||
          file.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          file.course.toLowerCase().contains(searchQuery.value.toLowerCase());

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
    if (isImporting.value) return;
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
      if (pickedFiles.isEmpty) return;
      final root = await getApplicationSupportDirectory();
      final failed = <String>[];
      for (final picked in pickedFiles) {
        final source = picked.path;
        if (source != null && _sourcePaths.containsValue(p.normalize(source))) {
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
              course: _guessCourseFromName(picked.name),
            ),
          );
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
  }

  String _guessCourseFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('math') ||
        lower.contains('calc') ||
        lower.contains('theorem')) {
      return 'Calculus';
    } else if (lower.contains('db') ||
        lower.contains('sql') ||
        lower.contains('normal')) {
      return 'Database Systems';
    } else if (lower.contains('automata') ||
        lower.contains('cfg') ||
        lower.contains('chomsky')) {
      return 'Theory of Automata';
    } else if (lower.contains('os') ||
        lower.contains('thread') ||
        lower.contains('memory')) {
      return 'Operating Systems';
    }
    return 'General';
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
    //  await Get.to<void>(
    //   () =>
    // DocumentViewerView(file: file, onTogglePin: () => togglePin(file.id)),
    // );
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

  void removeFile(String id) {
    files.removeWhere((file) => file.id == id);
    _sourcePaths.remove(id);
    lastOpened.remove(id);
    _saveFiles();
  }

  void togglePin(String id) {
    final index = files.indexWhere((file) => file.id == id);
    if (index != -1) {
      final current = files[index];
      files[index] = current.copyWith(isPinned: !current.isPinned);
      _saveFiles();
    }
  }
}
