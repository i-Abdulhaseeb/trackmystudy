import 'dart:typed_data';

import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../document_viewer/services/document_print_service.dart';
import '../models/exam_datesheet.dart';
import 'exam_format.dart';

class ExamPrintService {
  Future<void> printSheet(ExamDatesheet sheet) async {
    final document = PdfDocument();
    try {
      document.pageSettings.orientation = PdfPageOrientation.landscape;
      final page = document.pages.add();
      final grid = PdfGrid();
      grid.columns.add(count: 6);
      grid.headers.add(1);
      final titles = [
        '#',
        'Subject / Class',
        'Teacher',
        'Date',
        'Time (PKT)',
        'Venue',
      ];
      for (var i = 0; i < titles.length; i++) {
        grid.headers[0].cells[i].value = titles[i];
      }
      grid.style = PdfGridStyle(
        font: PdfStandardFont(PdfFontFamily.helvetica, 10),
        cellPadding: PdfPaddings(left: 8, right: 8, top: 10, bottom: 10),
      );
      grid.columns[0].width = 32;
      for (final exam in sheet.exams) {
        final row = grid.rows.add();
        final values = [
          '${exam.order}',
          exam.subject,
          exam.teacher,
          ExamFormat.date(exam.startsAt),
          ExamFormat.range(exam.startsAt, exam.endsAt),
          exam.venue,
        ];
        for (var i = 0; i < values.length; i++) {
          row.cells[i].value = values[i];
        }
      }
      grid.repeatHeader = true;
      grid.draw(page: page);
      await DocumentPrintService().printDocument(
        Uint8List.fromList(await document.save()),
        '${sheet.name}.pdf',
      );
    } finally {
      document.dispose();
    }
  }
}
