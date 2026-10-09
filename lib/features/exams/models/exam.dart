enum ExamPhase { upcoming, ongoing, completed }

class Exam {
  const Exam({
    required this.order,
    required this.subject,
    required this.teacher,
    required this.startsAt,
    required this.endsAt,
    required this.venue,
  });

  final int order;
  final String subject;
  final String teacher;
  final DateTime startsAt;
  final DateTime endsAt;
  final String venue;

  ExamPhase phaseAt(DateTime now) {
    if (!now.isBefore(endsAt)) return ExamPhase.completed;
    return now.isBefore(startsAt) ? ExamPhase.upcoming : ExamPhase.ongoing;
  }

  Map<String, Object> toJson() => {
    'order': order,
    'subject': subject,
    'teacher': teacher,
    'start': startsAt.toUtc().toIso8601String(),
    'end': endsAt.toUtc().toIso8601String(),
    'venue': venue,
  };

  factory Exam.fromJson(Map<String, dynamic> json) {
    final exam = Exam(
      order: json['order'] as int,
      subject: json['subject'] as String,
      teacher: json['teacher'] as String,
      startsAt: DateTime.parse(json['start'] as String).toUtc(),
      endsAt: DateTime.parse(json['end'] as String).toUtc(),
      venue: json['venue'] as String,
    );
    if (exam.order < 1 ||
        exam.subject.trim().isEmpty ||
        exam.teacher.trim().isEmpty ||
        exam.venue.trim().isEmpty ||
        !exam.endsAt.isAfter(exam.startsAt)) {
      throw const FormatException('Invalid saved exam.');
    }
    return exam;
  }
}

class ExamClock {
  const ExamClock({
    required this.exam,
    required this.remaining,
    required this.phase,
  });
  final Exam? exam;
  final Duration remaining;
  final ExamPhase? phase;

  factory ExamClock.at(List<Exam> exams, DateTime now) {
    Exam? next;
    for (final exam in exams) {
      if (exam.phaseAt(now) != ExamPhase.completed &&
          (next == null || compare(exam, next) < 0)) {
        next = exam;
      }
    }
    if (next == null) {
      return const ExamClock(exam: null, remaining: Duration.zero, phase: null);
    }
    final phase = next.phaseAt(now);
    final target = phase == ExamPhase.ongoing ? next.endsAt : next.startsAt;
    return ExamClock(
      exam: next,
      remaining: Duration(
        seconds:
            (target.difference(now).inMicroseconds /
                    Duration.microsecondsPerSecond)
                .ceil(),
      ),
      phase: phase,
    );
  }

  static int compare(Exam a, Exam b) {
    final byDate = a.startsAt.compareTo(b.startsAt);
    return byDate == 0 ? a.order.compareTo(b.order) : byDate;
  }

  int get days => remaining.inDays;
  int get hours => remaining.inHours.remainder(24);
  int get minutes => remaining.inMinutes.remainder(60);
  int get seconds => remaining.inSeconds.remainder(60);
}
