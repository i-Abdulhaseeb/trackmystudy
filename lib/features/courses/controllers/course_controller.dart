import 'package:get/get.dart';

import '../../file_manager/controllers/file_manager_controller.dart';
import '../../file_manager/models/app_file_model.dart';
import '../models/course_workspace.dart';
import '../services/course_store.dart';

class CourseController extends GetxController {
  CourseController({CourseStore? store}) : _store = store ?? CourseStore();

  final CourseStore _store;
  final semesters = <Semester>[].obs;
  final courses = <StudyCourse>[].obs;
  final folders = <TopicFolder>[].obs;
  final links = <CourseFileLink>[].obs;
  final collapsed = <String>{}.obs;
  final selectedCourseId = RxnString();
  final selectedFolderId = RxnString();
  final isLoading = true.obs;
  final isSaving = false.obs;
  final loadError = RxnString();
  final saveError = RxnString();
  late final Future<void> ready;
  late final FileManagerController library;
  Worker? _fileWorker;
  Map<String, String> _fileNames = {};
  Future<void> _saveQueue = Future.value();
  int _sequence = 0;

  @override
  void onInit() {
    super.onInit();
    library = Get.find<FileManagerController>();
    ready = _restore();
  }

  Future<void> _restore() async {
    try {
      await library.ready;
      if (library.restoreFailed) throw StateError('Library restore failed.');
      final data = await _store.read();
      if (data != null) {
        final terms = (data['semesters'] as List)
            .map((e) => Semester.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        final subjects = (data['courses'] as List)
            .map(
              (e) => StudyCourse.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
        final topics = (data['folders'] as List)
            .map(
              (e) => TopicFolder.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
        final files = (data['links'] as List)
            .map(
              (e) =>
                  CourseFileLink.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
        semesters.assignAll(terms);
        courses.assignAll(subjects);
        folders.assignAll(topics);
        links.assignAll(files);
      }
      _fileNames = {for (final file in library.files) file.id: file.name};
      _fileWorker = ever(library.files, (_) => _reconcileFiles());
      library.isFileReadOnly = isFileArchived;
      library.courseLabel = (file) {
        final names = links
            .where((link) => link.fileId == file.id)
            .map((link) => course(link.courseId)?.name)
            .whereType<String>()
            .toSet();
        return names.isEmpty ? file.course : names.join(', ');
      };
      _reconcileFiles();
    } catch (_) {
      loadError.value = 'Your saved workspace could not be loaded. Restart the app to retry. Saved data has not been overwritten.';
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> get snapshot => {
    'semesters': semesters.map((e) => e.toJson()).toList(),
    'courses': courses.map((e) => e.toJson()).toList(),
    'folders': folders.map((e) => e.toJson()).toList(),
    'links': links.map((e) => e.toJson()).toList(),
  };

  Future<void> save() {
    final data = snapshot;
    isSaving.value = true;
    _saveQueue = _saveQueue.then((_) async {
      try {
        await _store.write(data);
        saveError.value = null;
      } catch (_) {
        saveError.value = 'Changes are in memory only. Free disk space and select Retry save before closing.';
      }
    });
    final pending = _saveQueue;
    return pending.whenComplete(() {
      if (identical(pending, _saveQueue)) isSaving.value = false;
    });
  }

  String _id() => '${DateTime.now().microsecondsSinceEpoch}_${_sequence++}';

  Semester? semester(String id) =>
      semesters.firstWhereOrNull((e) => e.id == id);
  StudyCourse? course(String id) => courses.firstWhereOrNull((e) => e.id == id);
  StudyCourse? get selectedCourse => course(selectedCourseId.value ?? '');
  bool isArchived(String courseId) =>
      semester(course(courseId)?.semesterId ?? '')?.isArchived ?? false;
  bool isFileArchived(String fileId) =>
      links.any((e) => e.fileId == fileId && isArchived(e.courseId));

  List<Semester> get sortedSemesters => semesters.toList()
    ..sort((a, b) {
      if (a.isArchived != b.isArchived) return a.isArchived ? 1 : -1;
      return semesters.indexOf(b).compareTo(semesters.indexOf(a));
    });

  List<StudyCourse> coursesFor(String semesterId) =>
      courses.where((e) => e.semesterId == semesterId).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<TopicFolder> foldersAt(String courseId, String? parentId) =>
      folders
          .where((e) => e.courseId == courseId && e.parentId == parentId)
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  List<AppFileModel> filesAt(String courseId, String? folderId) {
    final ids = links
        .where((e) => e.courseId == courseId && e.folderId == folderId)
        .map((e) => e.fileId)
        .toSet();
    return library.files.where((e) => ids.contains(e.id)).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  int fileCount(String courseId) => links
      .where((e) => e.courseId == courseId)
      .map((e) => e.fileId)
      .toSet()
      .length;
  int folderCount(String courseId) =>
      folders.where((e) => e.courseId == courseId).length;

  List<TopicFolder> get breadcrumbs {
    final result = <TopicFolder>[];
    var id = selectedFolderId.value;
    final seen = <String>{};
    while (id != null && seen.add(id)) {
      final folder = folders.firstWhereOrNull((e) => e.id == id);
      if (folder == null) break;
      result.insert(0, folder);
      id = folder.parentId;
    }
    return result;
  }

  void openCourse(String id) {
    selectedCourseId.value = id;
    selectedFolderId.value = null;
  }

  void showOverview() {
    selectedCourseId.value = null;
    selectedFolderId.value = null;
  }

  void toggleSemester(String id) {
    if (!collapsed.remove(id)) collapsed.add(id);
  }

  void _checkReady() {
    if (isLoading.value || loadError.value != null) {
      throw StateError('The workspace is not ready.');
    }
  }

  void _editable(String courseId) {
    _checkReady();
    if (course(courseId) == null) {
      throw StateError('This course no longer exists.');
    }
    if (isArchived(courseId)) {
      throw StateError('Restore this semester before making changes.');
    }
  }

  String _name(String value) {
    final name = value.trim();
    if (name.isEmpty) throw ArgumentError('Enter a name.');
    if (name.length > 120) throw ArgumentError('Use at most 120 characters.');
    return name;
  }

  String addSemester(String name) {
    _checkReady();
    final value = _name(name);
    _unique(value, semesters.map((e) => e.name));
    final id = _id();
    semesters.add(Semester(id: id, name: value));
    save();
    return id;
  }

  void renameSemester(String id, String name) {
    _checkReady();
    final index = semesters.indexWhere((e) => e.id == id);
    if (index < 0) return;
    if (semesters[index].isArchived) {
      throw StateError('Restore this semester before renaming.');
    }
    final value = _name(name);
    _unique(value, semesters.where((e) => e.id != id).map((e) => e.name));
    semesters[index] = Semester(id: id, name: value);
    save();
  }

  void setArchived(String id, bool archived) {
    _checkReady();
    final index = semesters.indexWhere((e) => e.id == id);
    if (index < 0) return;
    semesters[index] = Semester(
      id: id,
      name: semesters[index].name,
      archivedAt: archived ? DateTime.now() : null,
    );
    save();
  }

  void _unique(String name, Iterable<String> existing) {
    if (existing.any((e) => e.toLowerCase() == name.toLowerCase())) {
      throw ArgumentError('This name already exists here.');
    }
  }

  void saveCourse({
    String? id,
    required String semesterId,
    required String name,
    String code = '',
    String instructor = '',
    String credits = '',
    String status = '',
  }) {
    _checkReady();
    if (id != null) _editable(id);
    final term = semester(semesterId);
    if (term == null || term.isArchived) {
      throw StateError('Select an active semester.');
    }
    final value = _name(name);
    _unique(
      value,
      courses
          .where((e) => e.semesterId == semesterId && e.id != id)
          .map((e) => e.name),
    );
    if (credits.trim().isNotEmpty &&
        (double.tryParse(credits) == null ||
            double.parse(credits) <= 0 ||
            !double.parse(credits).isFinite)) {
      throw ArgumentError('Credit hours must be a positive number.');
    }
    final item = StudyCourse(
      id: id ?? _id(),
      semesterId: semesterId,
      name: value,
      code: code.trim(),
      instructor: instructor.trim(),
      credits: credits.trim(),
      status: status.trim(),
      updatedAt: DateTime.now(),
    );
    final index = courses.indexWhere((e) => e.id == item.id);
    if (index < 0) {
      courses.add(item);
    } else {
      courses[index] = item;
    }
    save();
  }

  void saveFolder({
    String? id,
    required String courseId,
    String? parentId,
    required String name,
  }) {
    _editable(courseId);
    _checkFolder(courseId, parentId);
    final value = _name(name);
    _unique(
      value,
      foldersAt(courseId, parentId).where((e) => e.id != id).map((e) => e.name),
    );
    final item = TopicFolder(
      id: id ?? _id(),
      courseId: courseId,
      parentId: parentId,
      name: value,
    );
    final index = folders.indexWhere((e) => e.id == item.id);
    if (index < 0) {
      folders.add(item);
    } else {
      folders[index] = item;
    }
    _touch({courseId});
    save();
  }

  void _checkFolder(String courseId, String? folderId) {
    if (folderId != null &&
        !folders.any((e) => e.id == folderId && e.courseId == courseId)) {
      throw StateError('This folder no longer exists.');
    }
  }

  void addFiles(String courseId, String? folderId, Iterable<String> fileIds) {
    _editable(courseId);
    _checkFolder(courseId, folderId);
    var changed = false;
    for (final id in fileIds.toSet()) {
      if (!library.files.any((e) => e.id == id)) continue;
      if (links.any(
        (e) =>
            e.courseId == courseId && e.folderId == folderId && e.fileId == id,
      )) {
        continue;
      }
      links.add(
        CourseFileLink(courseId: courseId, folderId: folderId, fileId: id),
      );
      changed = true;
    }
    if (changed) {
      _touch({courseId});
      save();
    }
  }

  Future<void> importFiles(String courseId, String? folderId) async {
    _editable(courseId);
    _checkFolder(courseId, folderId);
    final ids = await library.importFiles();
    if (ids.isNotEmpty) addFiles(courseId, folderId, ids);
  }

  void removeLink(String courseId, String? folderId, String fileId) {
    _editable(courseId);
    links.removeWhere(
      (e) =>
          e.courseId == courseId &&
          e.folderId == folderId &&
          e.fileId == fileId,
    );
    _touch({courseId});
    save();
  }

  void removeFolder(TopicFolder folder) {
    _editable(folder.courseId);
    final ids = <String>{folder.id};
    var previous = 0;
    while (previous != ids.length) {
      previous = ids.length;
      ids.addAll(
        folders
            .where(
              (e) => e.courseId == folder.courseId && ids.contains(e.parentId),
            )
            .map((e) => e.id),
      );
    }
    links.removeWhere(
      (e) => e.courseId == folder.courseId && ids.contains(e.folderId),
    );
    folders.removeWhere((e) => ids.contains(e.id));
    if (ids.contains(selectedFolderId.value)) {
      selectedFolderId.value = folder.parentId;
    }
    _touch({folder.courseId});
    save();
  }

  void removeCourse(String id) {
    _editable(id);
    links.removeWhere((e) => e.courseId == id);
    folders.removeWhere((e) => e.courseId == id);
    courses.removeWhere((e) => e.id == id);
    if (selectedCourseId.value == id) showOverview();
    save();
  }

  void _touch(Set<String> ids) {
    final now = DateTime.now();
    for (var index = 0; index < courses.length; index++) {
      if (ids.contains(courses[index].id)) {
        courses[index] = courses[index].touched(now);
      }
    }
  }

  void _reconcileFiles() {
    final current = {for (final file in library.files) file.id: file.name};
    final changed = links
        .where(
          (e) =>
              !current.containsKey(e.fileId) ||
              (_fileNames.containsKey(e.fileId) &&
                  current[e.fileId] != _fileNames[e.fileId]),
        )
        .map((e) => e.courseId)
        .toSet();
    _fileNames = current;
    if (changed.isEmpty) return;
    links.removeWhere((e) => !current.containsKey(e.fileId));
    _touch(changed);
    save();
  }

  @override
  void onClose() {
    _fileWorker?.dispose();
    library.isFileReadOnly = null;
    library.courseLabel = null;
    super.onClose();
  }
}
