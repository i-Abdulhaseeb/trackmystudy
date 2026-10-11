class Semester {
  final String id;
  final String name;
  final DateTime? archivedAt;

  const Semester({required this.id, required this.name, this.archivedAt});

  bool get isArchived => archivedAt != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'archivedAt': archivedAt?.toIso8601String(),
  };

  factory Semester.fromJson(Map<String, dynamic> json) => Semester(
    id: json['id'] as String,
    name: json['name'] as String,
    archivedAt: DateTime.tryParse(json['archivedAt'] as String? ?? ''),
  );
}

class StudyCourse {
  final String id;
  final String semesterId;
  final String name;
  final String code;
  final String instructor;
  final String credits;
  final String status;
  final DateTime updatedAt;

  const StudyCourse({
    required this.id,
    required this.semesterId,
    required this.name,
    this.code = '',
    this.instructor = '',
    this.credits = '',
    this.status = '',
    required this.updatedAt,
  });

  StudyCourse touched(DateTime time) => StudyCourse(
    id: id,
    semesterId: semesterId,
    name: name,
    code: code,
    instructor: instructor,
    credits: credits,
    status: status,
    updatedAt: time,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'semesterId': semesterId,
    'name': name,
    'code': code,
    'instructor': instructor,
    'credits': credits,
    'status': status,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory StudyCourse.fromJson(Map<String, dynamic> json) => StudyCourse(
    id: json['id'] as String,
    semesterId: json['semesterId'] as String,
    name: json['name'] as String,
    code: json['code'] as String? ?? '',
    instructor: json['instructor'] as String? ?? '',
    credits: json['credits'] as String? ?? '',
    status: json['status'] as String? ?? '',
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

class TopicFolder {
  final String id;
  final String courseId;
  final String? parentId;
  final String name;

  const TopicFolder({
    required this.id,
    required this.courseId,
    this.parentId,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'courseId': courseId,
    'parentId': parentId,
    'name': name,
  };

  factory TopicFolder.fromJson(Map<String, dynamic> json) => TopicFolder(
    id: json['id'] as String,
    courseId: json['courseId'] as String,
    parentId: json['parentId'] as String?,
    name: json['name'] as String,
  );
}

class CourseFileLink {
  final String courseId;
  final String? folderId;
  final String fileId;

  const CourseFileLink({
    required this.courseId,
    this.folderId,
    required this.fileId,
  });

  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    'folderId': folderId,
    'fileId': fileId,
  };

  factory CourseFileLink.fromJson(Map<String, dynamic> json) => CourseFileLink(
    courseId: json['courseId'] as String,
    folderId: json['folderId'] as String?,
    fileId: json['fileId'] as String,
  );
}
