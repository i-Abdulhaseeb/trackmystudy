import '../models/gpa_scenario.dart';

class GpaResult {
  const GpaResult({
    required this.credits,
    required this.qualityPoints,
    required this.errors,
    this.semesterGpa,
    this.predictedCgpa,
  });

  final int credits;
  final double qualityPoints;
  final List<String> errors;
  final double? semesterGpa;
  final double? predictedCgpa;
}

class GpaTargetPlan {
  const GpaTargetPlan(this.message, {this.requiredGpa, this.grades = const {}});

  final String message;
  final double? requiredGpa;
  final Map<String, UcpGrade> grades;
}

class GpaCalculator {
  static String? cgpaError(GpaScenario scenario) {
    final credits = int.tryParse(scenario.priorCredits.trim());
    final cgpa = double.tryParse(scenario.cgpa.trim());
    if (credits == 0 && scenario.cgpa.trim().isEmpty) return null;
    if (cgpa == null || !cgpa.isFinite || cgpa < 0 || cgpa > 4) {
      return 'Enter a current CGPA from 0.00 to 4.00.';
    }
    if (credits == 0 && cgpa != 0) {
      return 'Use 0.00 CGPA when there are no prior GPA-bearing credits.';
    }
    return null;
  }

  static String? creditsError(String value) {
    final credits = int.tryParse(value.trim());
    return credits == null || credits < 0 || credits > 1000
        ? 'Enter a whole number of credits from 0 to 1000.'
        : null;
  }

  static List<String> baselineErrors(GpaScenario scenario) => [
    if (cgpaError(scenario) case final String error) error,
    if (creditsError(scenario.priorCredits) case final String error) error,
    if (scenario.degreeCredits.trim().isNotEmpty &&
        creditsError(scenario.degreeCredits) != null)
      'Degree credits must be a whole number from 0 to 1000.',
  ];

  static GpaResult calculate(GpaScenario scenario) {
    final errors = baselineErrors(scenario);
    final courses = scenario.courses
        .where((course) => course.included)
        .toList();
    final credits = courses.fold(0, (sum, course) => sum + course.credits);
    var validCourses = true;
    var qualityPoints = 0.0;
    for (final course in scenario.courses) {
      final label = course.name.trim().isEmpty
          ? 'Untitled course'
          : course.name;
      if (course.kind == GpaCourseKind.repeat) {
        errors.add(
          '$label: repeat-course calculations need a confirmed UCP replacement policy.',
        );
        validCourses = false;
      } else if (course.included) {
        final grade = course.grade;
        if (grade == null || course.credits < 1 || course.credits > 3) {
          errors.add(
            '$label: select a grade or enter a percentage from 0 to 100.',
          );
          validCourses = false;
        } else {
          qualityPoints += grade.points * course.credits;
        }
      }
    }
    final semesterGpa = validCourses && credits > 0
        ? qualityPoints / credits
        : null;
    double? predictedCgpa;
    if (errors.isEmpty && semesterGpa != null) {
      final prior = int.parse(scenario.priorCredits.trim());
      final cgpa = double.tryParse(scenario.cgpa.trim()) ?? 0;
      predictedCgpa = (cgpa * prior + qualityPoints) / (prior + credits);
    }
    return GpaResult(
      credits: credits,
      qualityPoints: qualityPoints,
      errors: errors,
      semesterGpa: semesterGpa,
      predictedCgpa: predictedCgpa,
    );
  }

  static GpaTargetPlan planTarget(GpaScenario scenario) {
    final target = double.tryParse(scenario.target.trim());
    if (target == null || !target.isFinite || target < 0 || target > 4) {
      return const GpaTargetPlan('Enter a target CGPA from 0.00 to 4.00.');
    }
    if (baselineErrors(scenario).isNotEmpty) {
      return const GpaTargetPlan('Complete your academic baseline first.');
    }
    if (scenario.courses.any((course) => course.kind == GpaCourseKind.repeat)) {
      return const GpaTargetPlan(
        'Remove repeat courses until the UCP replacement policy is confirmed.',
      );
    }
    final courses = scenario.courses
        .where((course) => course.included)
        .toList();
    if (courses.isEmpty) {
      return const GpaTargetPlan('Add GPA-bearing courses to plan a target.');
    }
    if (courses.length > 30 ||
        courses.any((course) => course.credits < 1 || course.credits > 3)) {
      return const GpaTargetPlan(
        'Use up to 30 courses with 1, 2 or 3 credits each.',
      );
    }
    final credits = courses.fold(0, (sum, course) => sum + course.credits);
    final prior = int.parse(scenario.priorCredits.trim());
    final cgpa = double.tryParse(scenario.cgpa.trim()) ?? 0;
    final requiredPoints = target * (prior + credits) - cgpa * prior;
    final requiredGpa = requiredPoints / credits;
    if (requiredGpa > 4 + 1e-10) {
      final maximum = (cgpa * prior + credits * 4) / (prior + credits);
      return GpaTargetPlan(
        'This target is not possible this semester. All A grades reach ${maximum.toStringAsFixed(2)} CGPA.',
        requiredGpa: requiredGpa,
      );
    }
    var possibilities = <int, List<UcpGrade>>{0: []};
    for (final course in courses) {
      final next = <int, List<UcpGrade>>{};
      for (final entry in possibilities.entries) {
        for (final grade in UcpGrade.scale.reversed) {
          final points =
              entry.key + (grade.points * 100).round() * course.credits;
          next.putIfAbsent(points, () => [...entry.value, grade]);
        }
      }
      possibilities = next;
    }
    final minimum = (requiredPoints * 100 - 1e-7).ceil();
    final totals =
        possibilities.keys.where((points) => points >= minimum).toList()
          ..sort();
    if (totals.isEmpty) {
      return const GpaTargetPlan('No grade combination reaches this target.');
    }
    final selected = possibilities[totals.first]!;
    return GpaTargetPlan(
      requiredGpa <= 0
          ? 'The target is retained even with zero semester quality points. Passing and degree completion still require passing grades.'
          : 'One minimum-quality-point combination that reaches your target. Other grade combinations may also work.',
      requiredGpa: requiredGpa < 0 ? 0 : requiredGpa,
      grades: {
        for (var i = 0; i < courses.length; i++) courses[i].id: selected[i],
      },
    );
  }
}
