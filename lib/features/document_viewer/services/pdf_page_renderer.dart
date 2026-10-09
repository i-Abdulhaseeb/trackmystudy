import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:syncfusion_pdfviewer_platform_interface/pdfviewer_platform_interface.dart';

class PdfPageRenderer {
  late final String _id =
      'study-${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(this)}';
  final _platform = PdfViewerPlatform.instance;
  List<num> _widths = [];
  List<num> _heights = [];
  bool _open = false;

  int get pageCount => _widths.length;

  Future<void> open(Uint8List bytes, {String? password}) async {
    if (!Platform.isWindows) {
      throw UnsupportedError(
        'Page previews and printing currently target Windows.',
      );
    }
    final result = await _platform.initializePdfRenderer(bytes, _id, password);
    _open = true;
    if (int.tryParse(result ?? '') == null) {
      await dispose();
      throw const FormatException('Could not initialize page rendering.');
    }
    _widths = (await _platform.getPagesWidth(_id))!.cast<num>();
    _heights = (await _platform.getPagesHeight(_id))!.cast<num>();
  }

  Future<Uint8List> render(int page, {double dpi = 24}) async {
    if (!_open || page < 1 || page > pageCount) {
      throw const FormatException('Invalid page.');
    }
    final scale = math.min(
      dpi / 72,
      math.min(6000 / _widths[page - 1], 6000 / _heights[page - 1]),
    );
    final width = (_widths[page - 1] * scale).round().clamp(1, 6000);
    final height = (_heights[page - 1] * scale).round().clamp(1, 6000);
    final pixels = await _platform.getPage(page, width, height, _id);
    if (pixels == null) throw const FormatException('Could not render page.');
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    final image = await completer.future;
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw const FormatException('Could not encode page.');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image.dispose();
    }
  }

  Future<void> dispose() async {
    if (!_open) return;
    _open = false;
    await _platform.closeDocument(_id);
  }
}
