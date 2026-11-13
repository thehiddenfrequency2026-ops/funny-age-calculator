/// Pure Dart age maths. No Flutter imports so it is trivial to unit test.

const List<String> kWeekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> kMonthsShort = [
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

class AgeResult {
  const AgeResult({
    required this.birthDate,
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
    required this.nextBirthday,
    required this.daysToNextBirthday,
    required this.isBirthdayToday,
    required this.weekdayBorn,
    required this.zodiac,
  });

  /// Local midnight of the birth date.
  final DateTime birthDate;
  final int years;
  final int months;
  final int days;
  final int totalDays;
  final DateTime nextBirthday;
  final int daysToNextBirthday;
  final bool isBirthdayToday;
  final String weekdayBorn;
  final String zodiac;

  // Ballpark "fun" numbers (resting heart rate ~72 bpm, ~16 breaths/min).
  int get heartbeats => totalDays * 103680;
  int get breaths => totalDays * 23040;
  int get sleepDays => totalDays ~/ 3;
  int get fullMoons => (totalDays / 29.53).floor();

  /// Earth moves ~107,000 km/h around the Sun, so ~2.57 million km per day.
  int get kmAroundSun => totalDays * 2570000;
}

DateTime _dateOnlyUtc(DateTime d) => DateTime.utc(d.year, d.month, d.day);

bool isLeapYear(int y) => (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;

int daysInMonth(int year, int month) => DateTime.utc(year, month + 1, 0).day;

/// [d] plus [months] calendar months, clamping the day to the month's length.
DateTime _addMonths(DateTime d, int months) {
  final total = d.year * 12 + (d.month - 1) + months;
  final y = total ~/ 12;
  final m = total % 12 + 1;
  final maxDay = daysInMonth(y, m);
  return DateTime.utc(y, m, d.day > maxDay ? maxDay : d.day);
}

/// Feb 29 babies celebrate on Feb 28 in non-leap years.
DateTime _birthdayInYear(DateTime birth, int year) {
  if (birth.month == 2 && birth.day == 29 && !isLeapYear(year)) {
    return DateTime.utc(year, 2, 28);
  }
  return DateTime.utc(year, birth.month, birth.day);
}

/// Calculates everything about [birth] relative to [now] (defaults to today).
/// Throws [ArgumentError] if [birth] is after [now].
AgeResult calculateAge(DateTime birth, {DateTime? now}) {
  final today = _dateOnlyUtc(now ?? DateTime.now());
  final born = _dateOnlyUtc(birth);

  if (born.isAfter(today)) {
    throw ArgumentError('Birth date cannot be in the future.');
  }

  // Largest number of whole months that fits between birth and today, where
  // "birth + n months" clamps to the end of shorter months (31 Jan + 1 month
  // = 28 Feb). Whatever is left over is the day count.
  var totalMonths = (today.year - born.year) * 12 + today.month - born.month;
  if (_addMonths(born, totalMonths).isAfter(today)) totalMonths -= 1;

  final years = totalMonths ~/ 12;
  final months = totalMonths % 12;
  final days = today.difference(_addMonths(born, totalMonths)).inDays;

  var next = _birthdayInYear(born, today.year);
  if (next.isBefore(today)) {
    next = _birthdayInYear(born, today.year + 1);
  }
  final daysToNext = next.difference(today).inDays;

  return AgeResult(
    birthDate: DateTime(birth.year, birth.month, birth.day),
    years: years,
    months: months,
    days: days,
    totalDays: today.difference(born).inDays,
    nextBirthday: next,
    daysToNextBirthday: daysToNext,
    isBirthdayToday: daysToNext == 0,
    weekdayBorn: kWeekdays[born.weekday - 1],
    zodiac: zodiacFor(born),
  );
}

String zodiacFor(DateTime d) {
  final m = d.month;
  final day = d.day;
  if ((m == 3 && day >= 21) || (m == 4 && day <= 19)) return 'Aries ♈';
  if ((m == 4 && day >= 20) || (m == 5 && day <= 20)) return 'Taurus ♉';
  if ((m == 5 && day >= 21) || (m == 6 && day <= 20)) return 'Gemini ♊';
  if ((m == 6 && day >= 21) || (m == 7 && day <= 22)) return 'Cancer ♋';
  if ((m == 7 && day >= 23) || (m == 8 && day <= 22)) return 'Leo ♌';
  if ((m == 8 && day >= 23) || (m == 9 && day <= 22)) return 'Virgo ♍';
  if ((m == 9 && day >= 23) || (m == 10 && day <= 22)) return 'Libra ♎';
  if ((m == 10 && day >= 23) || (m == 11 && day <= 21)) return 'Scorpio ♏';
  if ((m == 11 && day >= 22) || (m == 12 && day <= 21)) return 'Sagittarius ♐';
  if ((m == 12 && day >= 22) || (m == 1 && day <= 19)) return 'Capricorn ♑';
  if ((m == 1 && day >= 20) || (m == 2 && day <= 18)) return 'Aquarius ♒';
  return 'Pisces ♓';
}

/// 1234567 -> "1,234,567"
String formatInt(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return n < 0 ? '-$buf' : buf.toString();
}

String formatDate(DateTime d) => '${d.day} ${kMonthsShort[d.month - 1]} ${d.year}';
