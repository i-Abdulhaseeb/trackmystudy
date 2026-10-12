enum GpaInputMode { letter, percentage }

enum GpaCourseKind {
  regular,
  repeat,
  withdrawn,
  incomplete,
  transfer,
  passFail,
}

class UcpGrade {
  const UcpGrade(this.letter, this.points, this.minimum);

  final String letter;
  final double points;
  final double minimum;

  static const scale = [
    UcpGrade('A', 4, 86),
    UcpGrade('A-', 3.67, 82),
    UcpGrade('B+', 3.33, 78),
    UcpGrade('B', 3, 74),
    UcpGrade('B-', 2.67, 70),
    UcpGrade('C+', 2.33, 66),
    UcpGrade('C', 2, 62),
    UcpGrade('C-', 1.67, 58),
    UcpGrade('D+', 1.33, 54),
    UcpGrade('D', 1, 50),
    UcpGrade('F', 0, 0),
  ];

  static UcpGrade? fromLetter(String value) {
    for (final grade in scale) {
      if (grade.letter == value) return grade;
    }
    return null;
  }

  static UcpGrade? fromPercentage(String value) {
    final marks = double.tryParse(value.trim());
    if (marks == null || !marks.isFinite || marks < 0 || marks > 100) {
      return null;
    }
    return scale.firstWhere((grade) => marks >= grade.minimum);
  }
}

class GpaCourse {
  const GpaCourse({
    required this.id,
    this.name = '',
    this.credits = 3,
    this.mode = GpaInputMode.letter,
    this.letter = '',
    this.percentage = '',
    this.kind = GpaCourseKind.regular,
  });

  final String id;
  final String name;
  final int credits;
  final GpaInputMode mode;
  final String letter;
  final String percentage;
  final GpaCourseKind kind;

  bool get included => kind == GpaCourseKind.regular;
  UcpGrade? get grade => mode == GpaInputMode.letter
      ? UcpGrade.fromLetter(letter)
      : UcpGrade.fromPercentage(percentage);

  GpaCourse copyWith({
    String? name,
    int? credits,
    GpaInputMode? mode,
    String? letter,
    String? percentage,
    GpaCourseKind? kind,
  }) => GpaCourse(
    id: id,
    name: name ?? this.name,
    credits: credits ?? this.credits,
    mode: mode ?? this.mode,
    letter: letter ?? this.letter,
    percentage: percentage ?? this.percentage,
    kind: kind ?? this.kind,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'credits': credits,
    'mode': mode.name,
    'letter': letter,
    'percentage': percentage,
    'kind': kind.name,
  };

  factory GpaCourse.fromJson(Map<String, dynamic> json) {
    final credits = json['credits'] as int;
    final letter = json['letter'] as String;
    if (letter.isNotEmpty && UcpGrade.fromLetter(letter) == null) {
      throw const FormatException('Invalid saved grade.');
    }
    if (credits < 1 || credits > 3) {
      throw const FormatException('Invalid course credits.');
    }
    return GpaCourse(
      id: json['id'] as String,
      name: json['name'] as String,
      credits: credits,
      mode: GpaInputMode.values.byName(json['mode'] as String),
      letter: json['letter'] as String,
      percentage: json['percentage'] as String,
      kind: GpaCourseKind.values.byName(json['kind'] as String),
    );
  }
}

class GpaScenario {
  const GpaScenario({
    required this.id,
    this.name = 'New semester',
    this.cgpa = '',
    this.priorCredits = '',
    this.degreeCredits = '',
    this.target = '',
    this.courses = const [],
    this.baselineRevision = 0,
    this.finalized = false,
  });

  final String id;
  final String name;
  final String cgpa;
  final String priorCredits;
  final String degreeCredits;
  final String target;
  final List<GpaCourse> courses;
  final int baselineRevision;
  final bool finalized;

  GpaScenario copyWith({
    String? id,
    String? name,
    String? cgpa,
    String? priorCredits,
    String? degreeCredits,
    String? target,
    List<GpaCourse>? courses,
    int? baselineRevision,
    bool? finalized,
  }) => GpaScenario(
    id: id ?? this.id,
    name: name ?? this.name,
    cgpa: cgpa ?? this.cgpa,
    priorCredits: priorCredits ?? this.priorCredits,
    degreeCredits: degreeCredits ?? this.degreeCredits,
    target: target ?? this.target,
    courses: List.unmodifiable(courses ?? this.courses),
    baselineRevision: baselineRevision ?? this.baselineRevision,
    finalized: finalized ?? this.finalized,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cgpa': cgpa,
    'priorCredits': priorCredits,
    'degreeCredits': degreeCredits,
    'target': target,
    'courses': courses.map((course) => course.toJson()).toList(),
    'baselineRevision': baselineRevision,
    'finalized': finalized,
  };

  factory GpaScenario.fromJson(Map<String, dynamic> json) => GpaScenario(
    id: json['id'] as String,
    name: json['name'] as String,
    cgpa: json['cgpa'] as String,
    priorCredits: json['priorCredits'] as String,
    degreeCredits: json['degreeCredits'] as String,
    target: json['target'] as String,
    courses: (json['courses'] as List)
        .map(
          (item) => GpaCourse.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false),
    baselineRevision: json['baselineRevision'] as int,
    finalized: json['finalized'] as bool,
  );
}
