class AppFileModel {
  final String id;
  final String name;
  final String path;
  final int sizeInBytes;
  final String extension;
  final DateTime dateAdded;
  final String course;
  final bool isPinned;

  const AppFileModel({
    required this.id,
    required this.name,
    required this.path,
    required this.sizeInBytes,
    required this.extension,
    required this.dateAdded,
    this.course = 'General',
    this.isPinned = false,
  });

  String get formattedSize {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  String get formattedDate {
    final year = dateAdded.year.toString();
    final month = dateAdded.month.toString().padLeft(2, '0');
    final day = dateAdded.day.toString().padLeft(2, '0');
    final hour = dateAdded.hour.toString().padLeft(2, '0');
    final min = dateAdded.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$min';
  }

  AppFileModel copyWith({
    String? id,
    String? name,
    String? path,
    int? sizeInBytes,
    String? extension,
    DateTime? dateAdded,
    String? course,
    bool? isPinned,
  }) {
    return AppFileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      extension: extension ?? this.extension,
      dateAdded: dateAdded ?? this.dateAdded,
      course: course ?? this.course,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
