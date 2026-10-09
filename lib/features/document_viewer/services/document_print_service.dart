import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'pdf_page_renderer.dart';

class DocumentPrintService {
  Future<void> printDocument(
    Uint8List bytes,
    String name, {
    String? password,
    void Function(int, int)? onProgress,
  }) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('Use Open externally to print on this platform.');
    }
    final directory = await Directory.systemTemp.createTemp(
      'trackmystudy_print_',
    );
    final renderer = PdfPageRenderer();
    try {
      final printCopy = PdfDocument(inputBytes: bytes, password: password);
      late final Uint8List flattened;
      try {
        printCopy.form.flattenAllFields();
        for (var i = 0; i < printCopy.pages.count; i++) {
          printCopy.pages[i].annotations.flattenAllAnnotations();
        }
        flattened = Uint8List.fromList(await printCopy.save());
      } finally {
        printCopy.dispose();
      }
      await renderer.open(flattened, password: password);
      for (var page = 1; page <= renderer.pageCount; page++) {
        onProgress?.call(page, renderer.pageCount);
        final image = await renderer.render(page, dpi: 150);
        await File(
          p.join(directory.path, '${page.toString().padLeft(6, '0')}.png'),
        ).writeAsBytes(image);
      }
      await renderer.dispose();
      final result = await Process.run(
        'powershell.exe',
        ['-NoProfile', '-STA', '-Command', _script],
        environment: {
          'TRACKMYSTUDY_PRINT_DIR': directory.path,
          'TRACKMYSTUDY_PRINT_NAME': name,
        },
      );
      if (result.exitCode != 0) {
        throw ProcessException(
          'Windows print dialog',
          [],
          result.stderr.toString(),
          result.exitCode,
        );
      }
    } finally {
      await renderer.dispose();
      if (await directory.exists()) await directory.delete(recursive: true);
    }
  }

  static const _script = r'''
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Printing;
using System.IO;
using System.Windows.Forms;
public static class StudyPrinter {
  public static void Print(string directory, string name) {
    string[] pages = Directory.GetFiles(directory, "*.png");
    Array.Sort(pages, StringComparer.Ordinal);
    using (PrintDocument document = new PrintDocument())
    using (PrintDialog dialog = new PrintDialog()) {
      document.DocumentName = name;
      dialog.Document = document;
      dialog.AllowSomePages = true;
      dialog.UseEXDialog = true;
      document.PrinterSettings.MinimumPage = 1;
      document.PrinterSettings.MaximumPage = pages.Length;
      document.PrinterSettings.FromPage = 1;
      document.PrinterSettings.ToPage = pages.Length;
      if (dialog.ShowDialog() != DialogResult.OK) return;
      bool range = document.PrinterSettings.PrintRange == PrintRange.SomePages;
      int current = range ? document.PrinterSettings.FromPage - 1 : 0;
      int last = range ? document.PrinterSettings.ToPage : pages.Length;
      document.PrintPage += (sender, args) => {
        using (Image image = Image.FromFile(pages[current])) {
          Rectangle bounds = args.MarginBounds;
          float scale = Math.Min((float)bounds.Width / image.Width, (float)bounds.Height / image.Height);
          float width = image.Width * scale;
          float height = image.Height * scale;
          args.Graphics.DrawImage(image, bounds.X + (bounds.Width - width) / 2, bounds.Y, width, height);
        }
        current++;
        args.HasMorePages = current < last;
      };
      document.Print();
    }
  }
}
'@
[StudyPrinter]::Print($env:TRACKMYSTUDY_PRINT_DIR, $env:TRACKMYSTUDY_PRINT_NAME)
''';
}
