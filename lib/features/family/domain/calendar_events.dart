import 'package:ourtree_app/core/utils/dates.dart';
import 'package:ourtree_app/features/family/domain/models/family_data.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';

/// Префикс идентификатора «виртуального» дня рождения, который календарь
/// строит из профиля участника.
const String calendarBirthdayPrefix = 'calendar-birthday-';

/// События и дни рождения, которые нужно показать в конкретный день.
///
/// Вынесено из виджета, чтобы правила дат можно было покрыть тестами:
/// обычные события, ежегодные даты и дни рождения из профилей.
List<TimelineEvent> calendarEventsForDay({
  required DateTime day,
  required FamilyData family,
  required String Function(FamilyMember member) birthdayTitle,
}) {
  bool matches(TimelineEvent event) {
    final date = event.eventDate;
    if (date == null) return false;
    if (event.isRecurringYearly) return isSameMonthDay(date, day);
    return date.year == day.year &&
        date.month == day.month &&
        date.day == day.day;
  }

  final events = family.timelineEvents
      .where((event) => event.showInCalendar != false && matches(event))
      .toList(growable: false);

  final birthdays = <TimelineEvent>[];
  for (final member in family.members) {
    if (member.showInCalendar == false) continue;
    if (!isSameMonthDay(member.birthdayDate, day)) continue;
    // Если на этот день уже есть событие рождения участника, второй
    // «День рождения» не создаём.
    final hasBirthEvent = events.any(
      (event) => event.kind == EventKind.birth && event.memberId == member.id,
    );
    if (hasBirthEvent) continue;

    birthdays.add(
      TimelineEvent(
        id: '$calendarBirthdayPrefix${member.id}',
        date: member.birthday,
        title: birthdayTitle(member),
        kind: EventKind.birth,
        memberId: member.id,
      ),
    );
  }

  return <TimelineEvent>[...events, ...birthdays];
}

/// Это день рождения, построенный календарём, а не запись из архива.
bool isGeneratedBirthday(TimelineEvent event) =>
    event.id.startsWith(calendarBirthdayPrefix);
