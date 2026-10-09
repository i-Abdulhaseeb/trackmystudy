import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../models/exam.dart';
import '../models/ocr_word.dart';
import 'datesheet_parser.dart';

class ExamOcrService {
  static const _channel = MethodChannel('trackmystudy/exam_ocr');
  static const _parser = DatesheetParser();

  Future<List<Exam>> readDatesheet(String path) async {
    if (!Platform.isWindows) {
      throw UnsupportedError(
        'Datesheet image recognition is available on Windows.',
      );
    }
    try {
      final result = await _channel.invokeListMethod<dynamic>(
        'recognize',
        path,
      );
      final words = (result ?? [])
          .map(
            (value) => OcrWord.fromMap(Map<String, dynamic>.from(value as Map)),
          )
          .toList();
      return _parser.parse(words);
    } on MissingPluginException {
      return _fallback(path);
    } on PlatformException {
      return _fallback(path);
    } on FormatException {
      return _fallback(path);
    }
  }

  Future<List<Exam>> _fallback(String path) async {
    final assets = Directory(
      p.join(p.dirname(Platform.resolvedExecutable), 'ocr'),
    );
    final executable = File(p.join(assets.path, 'tesseract.exe'));
    final model = File(p.join(assets.path, 'tessdata', 'eng.traineddata'));
    if (!await executable.exists() || !await model.exists()) {
      throw StateError(
        'OCR files are missing. Rebuild the Windows application with the included windows/ocr folder.',
      );
    }
    final temporary = await Directory.systemTemp.createTemp(
      'trackmystudy_ocr_',
    );
    try {
      await model.copy(p.join(temporary.path, 'eng.traineddata'));
      await _prepareImage(path, p.join(temporary.path, 'image.png'));
      FormatException? failure;
      for (final mode in [6, 11]) {
        final process = await Process.start(
          executable.path,
          [
            'image.png',
            'stdout',
            '--tessdata-dir',
            '.',
            '-l',
            'eng',
            '--psm',
            '$mode',
            '-c',
            'tessedit_create_tsv=1',
          ],
          workingDirectory: temporary.path,
          runInShell: false,
          environment: {'OMP_THREAD_LIMIT': '2'},
        );
        final output = process.stdout
            .transform(const Utf8Decoder(allowMalformed: true))
            .join();
        final diagnostic = process.stderr
            .transform(const Utf8Decoder(allowMalformed: true))
            .join();
        final completion = Future.wait<Object>([
          process.exitCode,
          output,
          diagnostic,
        ]);
        late final List<Object> results;
        try {
          results = await completion.timeout(const Duration(seconds: 90));
        } on TimeoutException {
          process.kill();
          await completion;
          throw const FormatException(
            'Recognition took too long. Upload a cropped, clearer image of the table.',
          );
        }
        if (results[0] != 0) {
          throw StateError(
            'The local OCR engine could not read this image. Check the Windows Visual C++ runtime and try a PNG image.',
          );
        }
        try {
          return _parser.parse(OcrWord.parseTsv(results[1] as String));
        } on FormatException catch (exception) {
          failure = exception;
        }
      }
      throw failure ??
          const FormatException('No readable exam table was found.');
    } finally {
      await temporary.delete(recursive: true);
    }
  }

  Future<void> _prepareImage(String source, String destination) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(
      await File(source).readAsBytes(),
    );
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? image;
    try {
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      final pixels = descriptor.width * descriptor.height;
      if (pixels > 60000000) {
        throw const FormatException('Use an image smaller than 60 megapixels.');
      }
      final scale = math.min(3.0, math.sqrt(16000000 / pixels));
      codec = await descriptor.instantiateCodec(
        targetWidth: math.max(1, (descriptor.width * scale).round()),
        targetHeight: math.max(1, (descriptor.height * scale).round()),
      );
      image = (await codec.getNextFrame()).image;
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw const FormatException('The image could not be decoded.');
      }
      await File(destination).writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer.dispose();
    }
  }
}
