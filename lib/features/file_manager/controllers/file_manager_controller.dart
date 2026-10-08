import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../models/app_file_model.dart';

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

  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'ALL'.obs;
  final RxString sortBy = 'date'.obs;
  final RxBool sortAscending = false.obs;
  final RxString selectedFileId = ''.obs;

  List<AppFileModel> get filteredFiles {
    return files.where((file) {
      final matchesSearch = searchQuery.value.isEmpty ||
          file.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          file.course.toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchesFilter = selectedFilter.value == 'ALL' ||
          file.extension.toUpperCase() == selectedFilter.value.toUpperCase();

      return matchesSearch && matchesFilter;
    }).toList()
      ..sort((a, b) {
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

  int get totalSizeBytes => files.fold(0, (sum, item) => sum + item.sizeInBytes);

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
    try {
      final pickedFiles = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'ppt', 'pptx', 'txt', 'md', 'xlsx', 'csv'],
      );

      if (pickedFiles.isNotEmpty) {
        for (final file in pickedFiles) {
          final fileName = file.name;
          final filePath = file.path ?? '/local/imports/$fileName';
          final fileSize = file.lengthSync() ?? (await file.length()) ?? 1024;
          final fileExt = (file.extension ?? 'FILE').toUpperCase();

          final exists = files.any((f) => f.name == fileName && f.path == filePath);
          if (!exists) {
            files.insert(
              0,
              AppFileModel(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                name: fileName,
                path: filePath,
                sizeInBytes: fileSize,
                extension: fileExt,
                dateAdded: DateTime.now(),
                course: _guessCourseFromName(fileName),
              ),
            );
          }
        }
      }
    } catch (_) {}
  }

  String _guessCourseFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('math') || lower.contains('calc') || lower.contains('theorem')) {
      return 'Calculus';
    } else if (lower.contains('db') || lower.contains('sql') || lower.contains('normal')) {
      return 'Database Systems';
    } else if (lower.contains('automata') || lower.contains('cfg') || lower.contains('chomsky')) {
      return 'Theory of Automata';
    } else if (lower.contains('os') || lower.contains('thread') || lower.contains('memory')) {
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

  void selectFile(String id) {
    selectedFileId.value = id;
  }

  void removeFile(String id) {
    files.removeWhere((file) => file.id == id);
  }

  void togglePin(String id) {
    final index = files.indexWhere((file) => file.id == id);
    if (index != -1) {
      final current = files[index];
      files[index] = current.copyWith(isPinned: !current.isPinned);
    }
  }
}
