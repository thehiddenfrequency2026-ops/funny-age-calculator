import 'package:flutter_test/flutter_test.dart';
import 'package:funny_age_calculator/age_logic.dart';

void main() {
  group('calculateAge', () {
    test('exact birthday gives whole years and a birthday flag', () {
      final r = calculateAge(DateTime(2000, 6, 15), now: DateTime(2025, 6, 15));
      expect(r.years, 25);
      expect(r.months, 0);
      expect(r.days, 0);
      expect(r.isBirthdayToday, isTrue);
      expect(r.daysToNextBirthday, 0);
    });

    test('borrows days from the previous month', () {
      // 31 Jan -> 1 Mar 2025: 1 month and 1 day (Feb has 28 days).
      final r = calculateAge(DateTime(2025, 1, 31), now: DateTime(2025, 3, 1));
      expect(r.years, 0);
      expect(r.months, 1);
      expect(r.days, 1);
    });

    test('borrows months across the year boundary', () {
      final r = calculateAge(DateTime(1990, 12, 25), now: DateTime(2025, 1, 10));
      expect(r.years, 34);
      expect(r.months, 0);
      expect(r.days, 16);
    });

    test('total days counts leap days', () {
      final r = calculateAge(DateTime(2024, 2, 28), now: DateTime(2024, 3, 1));
      expect(r.totalDays, 2); // 28 Feb -> 29 Feb -> 1 Mar
    });

    test('next birthday rolls to next year when already passed', () {
      final r = calculateAge(DateTime(2000, 1, 1), now: DateTime(2025, 6, 15));
      expect(r.nextBirthday, DateTime.utc(2026, 1, 1));
      expect(r.daysToNextBirthday, 200);
    });

    test('Feb 29 birthday is celebrated on Feb 28 in non-leap years', () {
      final r = calculateAge(DateTime(2000, 2, 29), now: DateTime(2025, 2, 1));
      expect(r.nextBirthday, DateTime.utc(2025, 2, 28));
    });

    test('future birth date throws', () {
      expect(
        () => calculateAge(DateTime(2030, 1, 1), now: DateTime(2025, 1, 1)),
        throwsArgumentError,
      );
    });

    test('weekday and zodiac', () {
      final r = calculateAge(DateTime(2000, 1, 1), now: DateTime(2025, 1, 1));
      expect(r.weekdayBorn, 'Saturday');
      expect(r.zodiac, 'Capricorn ♑');
    });
  });

  group('formatInt', () {
    test('adds thousands separators', () {
      expect(formatInt(0), '0');
      expect(formatInt(999), '999');
      expect(formatInt(1000), '1,000');
      expect(formatInt(1234567), '1,234,567');
    });
  });
}
