import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/utils/dates.dart';
import 'package:ourtree_app/l10n/app_localizations_ru.dart';

void main() {
  group('display date', () {
    test('formats ISO as DD.MM.YYYY', () {
      expect(formatDisplayDateFromIso('1984-04-11'), '11.04.1984');
      expect(formatDisplayDate(DateTime(2024, 1, 5)), '05.01.2024');
    });

    test('masks input while typing', () {
      expect(maskDisplayDate('1'), '1');
      expect(maskDisplayDate('1104'), '11.04');
      expect(maskDisplayDate('11041984'), '11.04.1984');
      expect(maskDisplayDate('11/04/1984'), '11.04.1984');
      expect(maskDisplayDate('1104198499'), '11.04.1984');
    });

    test('converts display date back to ISO', () {
      expect(isoFromDisplayDate('11.04.1984'), '1984-04-11');
      expect(isoFromDisplayDate('05.01.2024'), '2024-01-05');
    });

    test('rejects impossible dates', () {
      expect(isoFromDisplayDate('31.02.2024'), '');
      expect(isoFromDisplayDate('11.04'), '');
      expect(parseIsoDate('2024-02-31'), isNull);
    });

    test('keeps invalid ISO text unchanged for display', () {
      expect(formatDisplayDateFromIso('not-a-date'), 'not-a-date');
      expect(formatDisplayDateFromIso(''), '');
    });
  });

  group('annual birthday', () {
    test('matches month and day in any year', () {
      final birthday = DateTime(1986, 9, 3);

      expect(isSameMonthDay(birthday, DateTime(2026, 9, 3)), isTrue);
      expect(isSameMonthDay(birthday, DateTime(2026, 9, 4)), isFalse);
      expect(isSameMonthDay(birthday, DateTime(2026, 8, 3)), isFalse);
      expect(isSameMonthDay(null, DateTime(2026, 9, 3)), isFalse);
    });
  });

  group('elapsedSince', () {
    test('returns full years, months and days', () {
      final elapsed = elapsedSince(
        '2000-01-15',
        now: DateTime(2013, 3, 20),
      );

      expect(elapsed.years, 13);
      expect(elapsed.months, 2);
      expect(elapsed.days, 5);
      expect(elapsed.isZero, isFalse);
    });

    test('borrows days from the previous month', () {
      final elapsed = elapsedSince(
        '2024-01-31',
        now: DateTime(2024, 3, 1),
      );

      expect(elapsed.years, 0);
      expect(elapsed.months, 1);
      // 31 января → 1 марта: ровно один месяц и ноль дней.
      expect(elapsed.days, 0);
    });

    test('handles a future or invalid date as zero', () {
      expect(
        elapsedSince('2030-01-01', now: DateTime(2024, 1, 1)).isZero,
        isTrue,
      );
      expect(elapsedSince('nonsense').isZero, isTrue);
    });
  });

  group('Russian plural labels', () {
    final l10n = AppLocalizationsRu();

    test('days follow the last digit', () {
      expect(l10n.timelineElapsedDays(1), '1 день');
      expect(l10n.timelineElapsedDays(2), '2 дня');
      expect(l10n.timelineElapsedDays(5), '5 дней');
      expect(l10n.timelineElapsedDays(11), '11 дней');
      expect(l10n.timelineElapsedDays(21), '21 день');
      expect(l10n.timelineElapsedDays(0), '0 дней');
    });

    test('months and years are pluralised too', () {
      expect(l10n.timelineElapsedMonths(1), '1 месяц');
      expect(l10n.timelineElapsedMonths(3), '3 месяца');
      expect(l10n.timelineElapsedMonths(7), '7 месяцев');
      expect(l10n.timelineElapsedYears(13), '13 лет');
      expect(l10n.timelineElapsedYears(21), '21 год');
    });
  });
}
