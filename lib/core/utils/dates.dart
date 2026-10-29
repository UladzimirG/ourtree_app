/// Работа с датами семейного архива.
///
/// В JSON даты хранятся в ISO-формате `YYYY-MM-DD`, а пользователь видит и
/// вводит их в формате своего языка: `17.09.1980` для ru, `09/17/1980` для en.
library;

import 'package:intl/intl.dart';

/// Язык по умолчанию, если формат запрошен без локали.
const String defaultDateLocale = 'en';

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

/// Числовой формат даты, привязанный к языку интерфейса.
///
/// Порядок компонентов и разделитель берутся из шаблона `DateFormat.yMd`
/// пакета `intl`, а день и месяц всегда печатаются двумя цифрами. Благодаря
/// этому отображение и маска ввода совпадают:
///
/// * ru — `17.09.1980`
/// * en — `09/17/1980`
class DisplayDatePattern {
  const DisplayDatePattern({
    required this.dayFirst,
    required this.separator,
  });

  /// Формат для языка [localeName]; неизвестный язык даёт русский порядок.
  factory DisplayDatePattern.forLocale(String? localeName) {
    final pattern = _patternFor(_normalize(localeName));
    final dayIndex = pattern.indexOf('d');
    final monthIndex = pattern.indexOf('M');
    return DisplayDatePattern(
      dayFirst: dayIndex >= 0 && (monthIndex < 0 || dayIndex < monthIndex),
      separator: _separatorOf(pattern),
    );
  }

  /// Сначала день (`17.09.1980`), иначе — сначала месяц (`09/17/1980`).
  final bool dayFirst;

  /// Разделитель компонентов: `.`, `/` и т.п.
  final String separator;

  /// `17.09.1980` или `09/17/1980`.
  String format(DateTime date) {
    final day = _twoDigits(date.day);
    final month = _twoDigits(date.month);
    final year = date.year.toString().padLeft(4, '0');
    return dayFirst
        ? '$day$separator$month$separator$year'
        : '$month$separator$day$separator$year';
  }

  /// Подсказка для пустого поля: `DD.MM.YYYY` или `MM/DD/YYYY`.
  String get hint => dayFirst
      ? 'DD${separator}MM${separator}YYYY'
      : 'MM${separator}DD${separator}YYYY';

  /// Расставляет разделители по мере ввода, оставляя только цифры.
  String mask(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '').split('').take(8).join();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index == 2 || index == 4) buffer.write(separator);
      buffer.write(digits[index]);
    }
    return buffer.toString();
  }

  /// `17.09.1980` → `1980-09-17`; некорректная дата → пустая строка.
  String toIso(String value) {
    final match =
        RegExp(r'^(\d{2})\D(\d{2})\D(\d{4})$').firstMatch(value.trim());
    if (match == null) return '';

    final first = int.parse(match.group(1)!);
    final second = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    final day = dayFirst ? first : second;
    final month = dayFirst ? second : first;

    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return '';
    }
    return '$year-${_twoDigits(month)}-${_twoDigits(day)}';
  }

  /// ISO-дата → строка для отображения; некорректную строку возвращает как есть.
  String fromIso(String? iso) {
    final date = parseIsoDate(iso);
    return date == null ? (iso?.trim() ?? '') : format(date);
  }

  static String _normalize(String? localeName) {
    final value = localeName?.trim() ?? '';
    return value.isEmpty ? defaultDateLocale : value;
  }

  /// Шаблоны для языков, которые поддерживает приложение.
  ///
  /// Держим их явно: `DateFormat` требует предварительной инициализации данных
  /// локали, а формат даты нужен в том числе в чистых unit-тестах.
  static const Map<String, String> _patterns = <String, String>{
    'ru': 'dd.MM.yyyy',
    'be': 'dd.MM.yyyy',
    'uk': 'dd.MM.yyyy',
    'en': 'M/d/y',
  };

  static String _patternFor(String localeName) {
    final known = _patterns[localeName];
    if (known != null) return known;
    try {
      return DateFormat.yMd(localeName).pattern ?? _patterns[defaultDateLocale]!;
    } catch (_) {
      // Для языка без данных intl остаёмся на безопасном порядке «день.месяц».
      return _patterns[defaultDateLocale]!;
    }
  }

  static String _separatorOf(String pattern) {
    final separators = pattern.replaceAll(RegExp('[dMy]'), '');
    return separators.isEmpty ? '.' : separators[0];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisplayDatePattern &&
          dayFirst == other.dayFirst &&
          separator == other.separator;

  @override
  int get hashCode => Object.hash(dayFirst, separator);
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

/// Форматирует дату в формате языка [localeName].
String formatDisplayDate(DateTime date, {String? localeName}) =>
    DisplayDatePattern.forLocale(localeName).format(date);

/// Форматирует ISO-дату; некорректную строку возвращает как есть.
String formatDisplayDateFromIso(String? iso, {String? localeName}) =>
    DisplayDatePattern.forLocale(localeName).fromIso(iso);

/// Маска ввода: оставляет только цифры и расставляет разделители языка.
String maskDisplayDate(String value, {String? localeName}) =>
    DisplayDatePattern.forLocale(localeName).mask(value);

/// Переводит введённую дату в ISO `YYYY-MM-DD`.
///
/// Возвращает пустую строку, если дата неполная или несуществующая.
String isoFromDisplayDate(String value, {String? localeName}) =>
    DisplayDatePattern.forLocale(localeName).toIso(value);

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
