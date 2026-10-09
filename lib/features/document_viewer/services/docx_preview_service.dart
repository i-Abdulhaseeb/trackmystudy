import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

class DocxPreviewService {
  Future<Uint8List> convert(Uint8List bytes) async {
    final fonts = <String, Uint8List>{};
    final root = Platform.environment['WINDIR'] ?? r'C:\Windows';
    final candidates = Platform.isWindows
        ? [
            p.join(root, 'Fonts', 'arial.ttf'),
            p.join(root, 'Fonts', 'arialbd.ttf'),
          ]
        : [
            '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
            '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
          ];
    for (var i = 0; i < candidates.length; i++) {
      final file = File(candidates[i]);
      if (await file.exists()) {
        fonts[i == 0 ? 'regular' : 'bold'] = await file.readAsBytes();
      }
    }
    return compute(_convert, (bytes, fonts));
  }

  static Uint8List _convert((Uint8List, Map<String, Uint8List>) input) {
    final archive = ZipDecoder().decodeBytes(input.$1);
    final source = archive.findFile('word/document.xml');
    if (source == null) {
      throw const FormatException('This file is not a valid DOCX document.');
    }
    if (archive.files.fold<int>(0, (sum, file) => sum + file.size) >
        256 * 1024 * 1024) {
      throw const FormatException(
        'The expanded document exceeds the 256 MB preview limit.',
      );
    }
    final xml = XmlDocument.parse(utf8.decode(source.content));
    final body = xml.descendants
        .whereType<XmlElement>()
        .where((e) => e.name.local == 'body')
        .first;
    final relationships = <String, String>{};
    final rels = archive.findFile('word/_rels/document.xml.rels');
    if (rels != null) {
      for (final node in XmlDocument.parse(
        utf8.decode(rels.content),
      ).descendants.whereType<XmlElement>()) {
        final id = node.getAttribute('Id');
        final target = node.getAttribute('Target');
        if (id != null &&
            target != null &&
            node.getAttribute('TargetMode') != 'External') {
          relationships[id] = target.startsWith('/')
              ? target.substring(1)
              : p.posix.normalize(p.posix.join('word', target));
        }
      }
    }
    final document = PdfDocument();
    try {
      document.pageSettings.margins.all = 48;
      var page = document.pages.add();
      var y = 0.0;
      final fonts = <String, PdfFont>{};
      PdfFont font(double size, bool bold) {
        final key = '$size/$bold';
        return fonts.putIfAbsent(key, () {
          final data =
              input.$2[bold ? 'bold' : 'regular'] ?? input.$2['regular'];
          return data == null
              ? PdfStandardFont(
                  PdfFontFamily.helvetica,
                  size,
                  style: bold ? PdfFontStyle.bold : PdfFontStyle.regular,
                )
              : PdfTrueTypeFont(data, size);
        });
      }

      void ensureSpace(double height) {
        if (y + height > page.getClientSize().height) {
          page = document.pages.add();
          y = 0;
        }
      }

      for (final block in _blocks(body)) {
        if (block.name.local == 'tbl') {
          final rows = block.childElements
              .where((e) => e.name.local == 'tr')
              .toList();
          final count = rows.fold<int>(
            0,
            (n, row) => math.max(
              n,
              row.childElements.where((e) => e.name.local == 'tc').length,
            ),
          );
          if (count == 0) continue;
          ensureSpace(32);
          final grid = PdfGrid()..columns.add(count: count);
          grid.style.font = font(10, false);
          grid.style.cellPadding = PdfPaddings(
            left: 5,
            right: 5,
            top: 5,
            bottom: 5,
          );
          for (final row in rows) {
            final result = grid.rows.add();
            final cells = row.childElements
                .where((e) => e.name.local == 'tc')
                .toList();
            for (var i = 0; i < cells.length; i++) {
              result.cells[i].value = cells[i].childElements
                  .where((e) => e.name.local == 'p')
                  .map(_text)
                  .join('\n');
            }
          }
          final result = grid.draw(
            page: page,
            bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 0),
            format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
          );
          if (result != null) {
            page = result.page;
            y = result.bounds.bottom + 12;
          }
          continue;
        }
        if (block.name.local != 'p') continue;
        final elements = block.descendants.whereType<XmlElement>().toList();
        if (elements.any((e) => e.name.local == 'pageBreakBefore')) {
          if (y > 0) {
            page = document.pages.add();
            y = 0;
          }
        }
        final style = elements
            .where((e) => e.name.local == 'pStyle')
            .firstOrNull;
        final styleName = _attribute(style, 'val') ?? '';
        final heading = RegExp(
          r'heading\s*(\d)',
          caseSensitive: false,
        ).firstMatch(styleName);
        final level = int.tryParse(heading?.group(1) ?? '');
        final segments = _text(block).split('\f');
        for (var segment = 0; segment < segments.length; segment++) {
          if (segment > 0) {
            page = document.pages.add();
            y = 0;
          }
          var text = segments[segment];
          if (elements.any((e) => e.name.local == 'numPr')) text = '• $text';
          final size = level == null ? 11.0 : math.max(12.0, 22.0 - level * 2);
          if (text.trim().isNotEmpty) {
            ensureSpace(size * 3);
            final startPage = page;
            final startY = y;
            final alignment = _attribute(
              elements.where((e) => e.name.local == 'jc').firstOrNull,
              'val',
            );
            final format = PdfStringFormat(
              alignment: switch (alignment) {
                'center' => PdfTextAlignment.center,
                'right' => PdfTextAlignment.right,
                'both' => PdfTextAlignment.justify,
                _ => PdfTextAlignment.left,
              },
              lineSpacing: 3,
            );
            final element = PdfTextElement(
              text: text,
              font: font(size, level != null),
              format: format,
            );
            final result = element.draw(
              page: page,
              bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 0),
              format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
            );
            if (level != null) {
              document.bookmarks.add(text).destination = PdfDestination(
                startPage,
                Offset(0, startY),
              );
            }
            if (result != null) {
              page = result.page;
              y = result.bounds.bottom + 10;
            }
          } else {
            y += 8;
          }
        }
        for (final blip in elements.where((e) => e.name.local == 'blip')) {
          final target = relationships[_attribute(blip, 'embed')];
          final data = target == null ? null : archive.findFile(target);
          if (data == null) continue;
          try {
            final bitmap = PdfBitmap(data.content);
            final scale = math.min(
              1.0,
              math.min(
                page.getClientSize().width / bitmap.width,
                (page.getClientSize().height - 16) / bitmap.height,
              ),
            );
            final width = bitmap.width * scale;
            final height = bitmap.height * scale;
            ensureSpace(height + 12);
            page.graphics.drawImage(bitmap, Rect.fromLTWH(0, y, width, height));
            y += height + 12;
          } catch (_) {
            throw const FormatException(
              'An embedded image cannot be previewed. Export this DOCX to PDF in Word for a complete view.',
            );
          }
        }
      }
      return Uint8List.fromList(document.saveSync());
    } finally {
      document.dispose();
    }
  }

  static Iterable<XmlElement> _blocks(XmlElement parent) sync* {
    for (final child in parent.childElements) {
      if (child.name.local == 'p' || child.name.local == 'tbl') {
        yield child;
      } else if (child.name.local != 'sectPr' && child.name.local != 'del') {
        yield* _blocks(child);
      }
    }
  }

  static String? _attribute(XmlElement? element, String local) => element
      ?.attributes
      .where((a) => a.name.local == local)
      .firstOrNull
      ?.value;

  static String _text(XmlElement element) {
    final buffer = StringBuffer();
    for (final node in element.descendants.whereType<XmlElement>()) {
      switch (node.name.local) {
        case 't':
          buffer.write(node.innerText);
        case 'tab':
          buffer.write('    ');
        case 'br':
          buffer.write(_attribute(node, 'type') == 'page' ? '\f' : '\n');
      }
    }
    return buffer.toString();
  }
}
