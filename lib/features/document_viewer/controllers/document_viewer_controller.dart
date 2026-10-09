import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../file_manager/models/app_file_model.dart';
import '../models/viewer_note.dart';
import '../services/docx_preview_service.dart';
import '../services/pdf_page_renderer.dart';
import '../services/document_print_service.dart';

class ViewerOutlineEntry {
  const ViewerOutlineEntry(this.bookmark, this.depth, this.page);
  final PdfBookmark bookmark;
  final int depth;
  final int? page;
}

class DocumentViewerController extends GetxController {
  DocumentViewerController({required this.file, required this.onTogglePin});

  final AppFileModel file;
  final VoidCallback onTogglePin;
  final pdf = PdfViewerController();
  final pageInput = TextEditingController(text: '1');
  final searchInput = TextEditingController();
  final searchFocus = FocusNode();
  final busy = true.obs;
  final printing = false.obs;
  final error = ''.obs;
  final status = 'Loading document…'.obs;
  final page = 1.obs;
  final pageCount = 0.obs;
  final zoom = 1.0.obs;
  final showThumbnails = true.obs;
  final showInspector = true.obs;
  final showSearch = false.obs;
  final focusMode = false.obs;
  final singlePage = true.obs;
  final darkPaper = false.obs;
  final inspectorTab = 0.obs;
  final searchCurrent = 0.obs;
  final searchTotal = 0.obs;
  final searching = false.obs;
  final notes = <ViewerNote>[].obs;
  final outline = <ViewerOutlineEntry>[].obs;
  final pointer = Offset.zero.obs;
  late final pinned = file.isPinned.obs;
  Uint8List? bytes;
  PdfDocument? document;
  PdfTextSearchResult? _search;
  SharedPreferences? _preferences;
  File? _annotationFile;
  Timer? _searchTimer;
  Timer? _saveTimer;
  bool _closed = false;
  bool _dirty = false;
  int _generation = 0;
  Future<void> _writes = Future.value();
  Future<void> _rasterQueue = Future.value();
  final _thumbnails = <int, Uint8List>{};
  PdfPageRenderer? _renderer;
  final _pendingThumbnails = <int, Future<Uint8List?>>{};

  bool get isDocx => file.extension.toLowerCase() == 'docx';
  bool get ready =>
      !busy.value &&
      error.value.isEmpty &&
      pageCount.value > 0 &&
      document != null;
  String get _key =>
      'viewer.v1.${base64Url.encode(utf8.encode(p.normalize(file.path)))}';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final generation = ++_generation;
    busy.value = true;
    error.value = '';
    status.value = 'Loading document…';
    pageCount.value = 0;
    _searchTimer?.cancel();
    _clearSearch();
    _thumbnails.clear();
    _pendingThumbnails.clear();
    outline.clear();
    document = null;
    bytes = null;
    try {
      await _rasterQueue;
      await _renderer?.dispose();
      _renderer = null;
      final source = File(file.path);
      if (!await source.exists()) {
        throw const FileSystemException(
          'The file was moved, deleted, or is a sample placeholder. Import the real file from your computer.',
        );
      }
      final stat = await source.stat();
      if (stat.size > 128 * 1024 * 1024) {
        throw const FormatException(
          'This document exceeds the 128 MB preview limit. Use Open externally.',
        );
      }
      if (stat.size == 0) {
        throw const FormatException('The selected document is empty.');
      }
      final preferences = await SharedPreferences.getInstance();
      final support = await getApplicationSupportDirectory();
      final directory = await Directory(p.join(support.path, 'viewer'))
          .create(recursive: true);
      final safeId = base64Url.encode(utf8.encode(file.id));
      final annotationFile = File(p.join(directory.path, '$safeId.pdf'));
      final stamp = '${stat.size}:${stat.modified.microsecondsSinceEpoch}';
      Uint8List data;
      if (preferences.getString('$_key.stamp') == stamp &&
          await annotationFile.exists()) {
        data = await annotationFile.readAsBytes();
      } else {
        if (await annotationFile.exists()) await annotationFile.delete();
        data = await source.readAsBytes();
        if (isDocx) {
          status.value = 'Preparing DOCX reading preview…';
          data = await DocxPreviewService().convert(data);
          await annotationFile.writeAsBytes(data, flush: true);
        }
      }
      if (_closed || generation != _generation) return;
      _preferences = preferences;
      _annotationFile = annotationFile;
      await preferences.setString('$_key.stamp', stamp);
      if (_closed || generation != _generation) return;
      final stored = preferences.getString('$_key.notes');
      try {
        notes.assignAll(
          stored == null
              ? <ViewerNote>[]
              : (jsonDecode(stored) as List).map(
                  (n) =>
                      ViewerNote.fromJson(Map<String, dynamic>.from(n as Map)),
                ),
        );
      } catch (_) {
        notes.clear();
      }
      page.value = preferences.getInt('$_key.page') ?? 1;
      pageInput.text = page.value.toString();
      bytes = data;
      busy.value = false;
      status.value = 'Rendering document…';
    } catch (failure) {
      if (_closed || generation != _generation) return;
      error.value = failure is FileSystemException
          ? failure.message
          : failure.toString().replaceFirst('FormatException: ', '');
      busy.value = false;
      status.value = 'Unable to open document';
    }
  }

  void onLoaded(PdfDocumentLoadedDetails details) {
    if (_closed) return;
    document = details.document;
    pageCount.value = details.document.pages.count;
    final entries = <ViewerOutlineEntry>[];
    void visit(PdfBookmarkBase bookmarks, int depth) {
      for (var i = 0; i < bookmarks.count; i++) {
        final bookmark = bookmarks[i];
        final destination = bookmark.destination;
        final index = destination == null
            ? -1
            : details.document.pages.indexOf(destination.page);
        entries.add(
          ViewerOutlineEntry(bookmark, depth, index < 0 ? null : index + 1),
        );
        visit(bookmark, depth + 1);
      }
    }

    visit(details.document.bookmarks, 0);
    outline.assignAll(entries);
    goToPage(page.value.clamp(1, pageCount.value));
    status.value = 'READY';
    update(['canvas', 'thumbnails']);
  }

  void onFailed(PdfDocumentLoadFailedDetails details) {
    error.value = '${details.error}\n${details.description}';
    status.value = 'Unable to render document';
  }

  void onPageChanged(PdfPageChangedDetails details) {
    page.value = details.newPageNumber;
    pageInput.text = page.value.toString();
    _preferences?.setInt('$_key.page', page.value);
  }

  void goToPage(int value) {
    if (pageCount.value == 0) return;
    final target = value.clamp(1, pageCount.value);
    pdf.jumpToPage(target);
    page.value = target;
    pageInput.text = '$target';
  }

  void submitPage(String value) {
    final number = int.tryParse(value);
    if (number != null) goToPage(number);
    pageInput.text = page.value.toString();
  }

  void changeZoom(double delta) {
    if (!ready) return;
    pdf.zoomLevel = (pdf.zoomLevel + delta).clamp(1.0, 3.0);
    zoom.value = pdf.zoomLevel;
  }

  void fitPage() {
    singlePage.value = true;
    pdf.zoomLevel = 1;
    zoom.value = 1;
  }

  void fitWidth() {
    singlePage.value = false;
    pdf.zoomLevel = 1;
    zoom.value = 1;
  }

  void togglePin() {
    onTogglePin();
    pinned.toggle();
  }

  void toggleSearch() {
    showSearch.toggle();
    if (showSearch.value) {
      searchFocus.requestFocus();
    } else {
      _searchTimer?.cancel();
      searchInput.clear();
      _clearSearch();
    }
  }

  void search(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 280), () {
      if (_closed) return;
      _clearSearch();
      if (value.trim().isEmpty || !ready) return;
      searching.value = true;
      _search = pdf.searchText(value.trim());
      _search!.addListener(_syncSearch);
      _syncSearch();
    });
  }

  void _syncSearch() {
    if (_closed || _search == null) return;
    searchCurrent.value = _search!.currentInstanceIndex;
    searchTotal.value = _search!.totalInstanceCount;
    searching.value = !_search!.isSearchCompleted;
  }

  void _clearSearch() {
    _search?.removeListener(_syncSearch);
    _search?.clear();
    _search = null;
    searchCurrent.value = 0;
    searchTotal.value = 0;
    searching.value = false;
  }

  void nextMatch() => _search?.nextInstance();
  void previousMatch() => _search?.previousInstance();

  Future<Uint8List?> thumbnail(int number) {
    final cached = _thumbnails.remove(number);
    if (cached != null) {
      _thumbnails[number] = cached;
      return Future.value(cached);
    }
    return _pendingThumbnails.putIfAbsent(number, () {
      final completer = Completer<Uint8List?>();
      final data = bytes;
      final generation = _generation;
      _rasterQueue = _rasterQueue.then((_) async {
        try {
          if (_closed ||
              generation != _generation ||
              data == null ||
              document?.security.userPassword.isNotEmpty == true) {
            completer.complete(null);
            return;
          }
          if (_renderer == null) {
            final renderer = PdfPageRenderer();
            try {
              await renderer.open(data);
              _renderer = renderer;
            } catch (_) {
              await renderer.dispose();
              rethrow;
            }
          }
          final png = await _renderer!.render(number);
          if (!_closed && generation == _generation) {
            _thumbnails[number] = png;
            while (_thumbnails.length > 32) {
              _thumbnails.remove(_thumbnails.keys.first);
            }
          }
          completer.complete(png);
        } catch (_) {
          completer.complete(null);
        } finally {
          if (generation == _generation) _pendingThumbnails.remove(number);
        }
      });
      return completer.future;
    });
  }

  Future<void> addNote(String text, {bool bookmark = false}) async {
    final value = text.trim();
    if (!ready || value.isEmpty) return;
    if (bookmark && notes.any((n) => n.bookmark && n.page == page.value)) {
      return;
    }
    notes.add(
      ViewerNote(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        page: page.value,
        text: value,
        bookmark: bookmark,
      ),
    );
    inspectorTab.value = 1;
    showInspector.value = true;
    await _saveNotes();
  }

  Future<void> removeNote(ViewerNote note) async {
    notes.removeWhere((n) => n.id == note.id);
    await _saveNotes();
  }

  Future<void> _saveNotes() async {
    final payload = jsonEncode(notes.map((n) => n.toJson()).toList());
    final saved = await _preferences?.setString('$_key.notes', payload);
    if (saved == false && !_closed) status.value = 'Notes could not be saved';
  }

  void annotationChanged(Annotation annotation) => markDocumentChanged();

  void markDocumentChanged() {
    _dirty = true;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 700), saveAnnotations);
  }

  Future<bool> saveAnnotations() async {
    if (!_dirty || !ready || _annotationFile == null) return true;
    _dirty = false;
    try {
      final data = await pdf.saveDocument();
      final file = _annotationFile!;
      final write = _writes.then((_) async {
        final temporary = File('${file.path}.tmp');
        await temporary.writeAsBytes(data, flush: true);
        if (Platform.isWindows && await file.exists()) {
          await file.writeAsBytes(data, flush: true);
          await temporary.delete();
        } else {
          await temporary.rename(file.path);
        }
      });
      _writes = write.catchError((Object _) {});
      await write;
      return true;
    } catch (_) {
      _dirty = true;
      if (!_closed) {
        status.value =
            'Could not save PDF annotations. Export a copy before closing.';
      }
      return false;
    }
  }

  Future<bool> flush() async {
    _saveTimer?.cancel();
    final saved = await saveAnnotations();
    await _writes;
    return saved;
  }

  Future<void> runAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (failure) {
      if (!_closed) {
        Get.snackbar(
          'Document viewer',
          failure.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> printDocument() => runAction(() async {
    if (!ready || printing.value) return;
    printing.value = true;
    try {
      final data = Uint8List.fromList(await pdf.saveDocument());
      await DocumentPrintService().printDocument(
        data,
        file.name,
        password: document?.security.userPassword,
        onProgress: (current, total) {
          if (!_closed) status.value = 'Preparing print: $current / $total';
        },
      );
    } finally {
      if (!_closed) {
        printing.value = false;
        status.value = 'READY';
      }
    }
  });

  Future<void> exportPdf() => runAction(() async {
    if (!ready) return;
    await FilePicker.saveFile(
      fileName: '${p.basenameWithoutExtension(file.name)}-copy.pdf',
      bytes: Uint8List.fromList(await pdf.saveDocument()),
      mimeType: 'application/pdf',
    );
  });

  Future<void> exportNotes() => runAction(() async {
    final text = StringBuffer('# ${file.name}\n\n');
    for (final note in notes) {
      text.writeln(
        '## ${note.bookmark ? 'Bookmark' : 'Note'} — page ${note.page}\n\n${note.text}\n',
      );
    }
    await FilePicker.saveFile(
      fileName: '${p.basenameWithoutExtension(file.name)}-notes.md',
      bytes: Uint8List.fromList(utf8.encode(text.toString())),
      mimeType: 'text/markdown',
    );
  });

  Future<void> openExternally() => runAction(() async {
    if (!await File(file.path).exists()) {
      throw const FileSystemException('The original file no longer exists.');
    }
    if (!await launchUrl(
      Uri.file(file.path),
      mode: LaunchMode.externalApplication,
    )) {
      throw const FileSystemException(
        'No application is registered to open this document.',
      );
    }
  });

  @override
  void onClose() {
    _closed = true;
    _generation++;
    _searchTimer?.cancel();
    _saveTimer?.cancel();
    _clearSearch();
    pdf.dispose();
    pageInput.dispose();
    searchInput.dispose();
    searchFocus.dispose();
    _thumbnails.clear();
    _rasterQueue.then((_) => _renderer?.dispose()).catchError((Object _) {});
    super.onClose();
  }
}
