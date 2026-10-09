import 'exam.dart';

class ExamDatesheet {
  const ExamDatesheet({
    required this.id,
    required this.name,
    required this.imageName,
    required this.importedAt,
    required this.exams,
  });
  final String id;
  final String name;
  final String imageName;
  final DateTime importedAt;
  final List<Exam> exams;

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'image': imageName,
    'imported': importedAt.toUtc().toIso8601String(),
    'exams': exams.map((exam) => exam.toJson()).toList(),
  };

  factory ExamDatesheet.fromJson(Map<String, dynamic> json) {
    final exams =
        (json['exams'] as List)
            .map(
              (value) => Exam.fromJson(Map<String, dynamic>.from(value as Map)),
            )
            .toList()
          ..sort(ExamClock.compare);
    if (exams.isEmpty) throw const FormatException('Empty datesheet.');
    final imageName = json['image'] as String;
    if (!RegExp(r'^sheet_[0-9]+\.(png|jpg|jpeg|bmp)$').hasMatch(imageName)) {
      throw const FormatException('Invalid source image.');
    }
    return ExamDatesheet(
      id: json['id'] as String,
      name: json['name'] as String,
      imageName: imageName,
      importedAt: DateTime.parse(json['imported'] as String).toUtc(),
      exams: List.unmodifiable(exams),
    );
  }
}
