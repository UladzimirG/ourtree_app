/// Работа с датами семейного архива.
///
/// В JSON даты хранятся в ISO-формате `YYYY-MM-DD`, а пользователь видит и
/// вводит их как `ДД.ММ.ГГГГ`.
library;

/// Сколько полных лет, месяцев и дней прошло с даты.
class Elapsed {
  const Elapsed({
    required this.years,
    required this.months,
    required this.days,
  });

  final int years;
  final int months;
  final int days;

  bool get isZero => years == 0 && months == 0 && days == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Elapsed &&
          years == other.years &&
          months == other.months &&
          days == other.days;

  @override
  int get hashCode => Object.hash(years, months, days);

  @override
  String toString() => 'Elapsed($years, $months, $days)';
}

/// Разбирает ISO-дату `YYYY-MM-DD`; возвращает `null` для некорректной строки.
DateTime? parseIsoDate(String? value) {
  final raw = value?.trim();
  if (raw == null || raw.isEmpty) return null;
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(raw);
  if (match == null) return null;

  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return date;
}

/// Форматирует дату как `ДД.ММ.ГГГГ`.
String formatDisplayDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

/// Форматирует ISO-дату как `ДД.ММ.ГГГГ`; некорректную строку возвращает как есть.
String formatDisplayDateFromIso(String? iso) {
  final date = parseIsoDate(iso);
  return date == null ? (iso?.trim() ?? '') : formatDisplayDate(date);
}

/// Маска ввода: оставляет только цифры и расставляет точки `ДД.ММ.ГГГГ`.
String maskDisplayDate(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '').split('').take(8).join();
  if (digits.length <= 2) return digits;
  if (digits.length <= 4) {
    return '${digits.substring(0, 2)}.${digits.substring(2)}';
  }
  return '${digits.substring(0, 2)}.${digits.substring(2, 4)}.'
      '${digits.substring(4)}';
}

/// Переводит введённую `ДД.ММ.ГГГГ` в ISO `YYYY-MM-DD`.
///
/// Возвращает пустую строку, если дата неполная или несуществующая.
String isoFromDisplayDate(String value) {
  final match = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$').firstMatch(value.trim());
  if (match == null) return '';

  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return '';
  }

  final isoMonth = month.toString().padLeft(2, '0');
  final isoDay = day.toString().padLeft(2, '0');
  return '$year-$isoMonth-$isoDay';
}

/// Совпадают ли месяц и день — для ежегодных дней рождения.
bool isSameMonthDay(DateTime? date, DateTime day) =>
    date != null && date.month == day.month && date.day == day.day;

/// Сколько полных лет, месяцев и дней прошло с [iso] до [now].
Elapsed elapsedSince(String? iso, {DateTime? now}) {
  final from = parseIsoDate(iso);
  if (from == null) return const Elapsed(years: 0, months: 0, days: 0);

  final moment = now ?? DateTime.now();
  final today = DateTime(moment.year, moment.month, moment.day);
  if (today.isBefore(from)) {
    return const Elapsed(years: 0, months: 0, days: 0);
  }

  var years = today.year - from.year;
  var months = today.month - from.month;
  var days = today.day - from.day;

  if (days < 0) {
    months -= 1;
    final previousMonth = DateTime(today.year, today.month, 0).day;
    days += previousMonth;
  }
  if (months < 0) {
    years -= 1;
    months += 12;
  }

  return Elapsed(
    years: years < 0 ? 0 : years,
    months: months < 0 ? 0 : months,
    days: days < 0 ? 0 : days,
  );
}
