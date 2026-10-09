class ExamFormat {
  static const zoneLabel = 'PKT · UTC+05:00';
  static const offset = Duration(hours: 5);
  static const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static DateTime local(DateTime value) => value.toUtc().add(offset);
  static String two(int value) => value.toString().padLeft(2, '0');
  static String date(DateTime value) {
    final time = local(value);
    return '${two(time.day)} ${months[time.month - 1]} ${time.year}';
  }

  static String time(DateTime value) {
    final time = local(value);
    return '${two(time.hour % 12 == 0 ? 12 : time.hour % 12)}:${two(time.minute)} ${time.hour >= 12 ? 'PM' : 'AM'}';
  }

  static String range(DateTime start, DateTime end) =>
      '${time(start)} – ${time(end)}${local(start).day == local(end).day ? '' : ' (+1 day)'}';
  static DateTime fromLocal(
    int year,
    int month,
    int day,
    int hour,
    int minute,
  ) => DateTime.utc(year, month, day, hour, minute).subtract(offset);
}
