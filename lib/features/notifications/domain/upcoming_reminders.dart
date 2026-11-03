import 'package:ourtree_app/core/utils/dates.dart';
import 'package:ourtree_app/features/family/domain/models/family_data.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';

/// Одно ближайшее напоминание (день рождения или событие календаря).
class UpcomingReminder {
  const UpcomingReminder({
    required this.date,
    required this.title,
    this.isBirthday = false,
  });

  /// День, в который напоминание актуально (без времени).
  final DateTime date;

  final String title;

  /// День рождения участника (а не событие из архива).
  final bool isBirthday;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpcomingReminder &&
          date == other.date &&
          title == other.title &&
          isBirthday == other.isBirthday;

  @override
  int get hashCode => Object.hash(date, title, isBirthday);
}

/// Что напомнить в ближайшие [days] дней начиная с [from].
///
/// Зеркалит правила календаря: ежегодные события сравниваются по месяцу и дню,
/// обычные — по полной дате; день рождения из профиля не дублируется, если на
/// этот день уже есть событие рождения участника.
List<UpcomingReminder> upcomingReminders({
  required FamilyData family,
  required DateTime from,
  required String Function(FamilyMember member) birthdayTitle,
  int days = 7,
}) {
  final start = DateTime(from.year, from.month, from.day);
  final result = <UpcomingReminder>[];

  for (var offset = 0; offset < days; offset++) {
    final day = start.add(Duration(days: offset));
    final dayEvents = <TimelineEvent>[];

    for (final event in family.timelineEvents) {
      if (event.showInCalendar == false) continue;
      final date = event.eventDate;
      if (date == null) continue;

      final matches = event.isRecurringYearly
          ? isSameMonthDay(date, day)
          : date.year == day.year &&
              date.month == day.month &&
              date.day == day.day;
      if (!matches) continue;

      dayEvents.add(event);
      result.add(
        UpcomingReminder(
          date: day,
          title: event.title,
          isBirthday: event.kind == EventKind.birth,
        ),
      );
    }

    for (final member in family.members) {
      if (member.showInCalendar == false) continue;
      if (!isSameMonthDay(member.birthdayDate, day)) continue;

      final hasBirthEvent = dayEvents.any(
        (event) => event.kind == EventKind.birth && event.memberId == member.id,
      );
      if (hasBirthEvent) continue;

      result.add(
        UpcomingReminder(
          date: day,
          title: birthdayTitle(member),
          isBirthday: true,
        ),
      );
    }
  }

  return List<UpcomingReminder>.unmodifiable(result);
}
