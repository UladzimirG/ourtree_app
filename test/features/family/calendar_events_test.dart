import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/family/domain/calendar_events.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';

FamilyMember _member({
  required String id,
  required String birthday,
  bool? showInCalendar,
}) =>
    FamilyMember(
      id: id,
      role: 'Роль',
      name: id,
      nickname: '',
      birthday: birthday,
      showInCalendar: showInCalendar,
    );

void main() {
  final family = FamilyData(
    settings: const FamilySettings(familyName: 'Family'),
    members: [
      _member(id: 'm1', birthday: '1990-05-01'),
      _member(id: 'm2', birthday: '1991-05-01', showInCalendar: false),
      _member(id: 'm3', birthday: '1995-07-15'),
    ],
    timelineEvents: const [
      TimelineEvent(id: 'e1', date: '2026-05-01', title: 'Обычное'),
      TimelineEvent(
          id: 'e2',
          date: '2020-06-10',
          title: 'Ежегодное',
          recurringYearly: true),
      TimelineEvent(
        id: 'e3',
        date: '2026-05-01',
        title: 'Скрыто из календаря',
        showInCalendar: false,
      ),
      TimelineEvent(
        id: 'e4',
        date: '2026-05-01',
        title: 'Только календарь',
        showInTimeline: false,
      ),
      TimelineEvent(
        id: 'e5',
        date: '2026-05-01',
        title: 'Рождение m1',
        kind: EventKind.birth,
        memberId: 'm1',
      ),
    ],
  );

  String title(FamilyMember member) => 'BD ${member.name}';

  test('показывает обычные, календарные и повторяющиеся события', () {
    final events = calendarEventsForDay(
      day: DateTime(2026, 5, 1),
      family: family,
      birthdayTitle: title,
    );

    final ids = events.map((event) => event.id).toList();
    expect(ids, contains('e1'));
    expect(ids, contains('e4'));
    expect(ids, contains('e5'));
    expect(ids, isNot(contains('e2')));
    expect(ids, isNot(contains('e3')));
  });

  test('повторяющееся событие видно в другом году', () {
    final events = calendarEventsForDay(
      day: DateTime(2027, 6, 10),
      family: family,
      birthdayTitle: title,
    );

    expect(events.map((event) => event.id), contains('e2'));
    expect(events.map((event) => event.id), isNot(contains('e1')));
  });

  test('день рождения из профиля скрывается, если он отключён', () {
    final events = calendarEventsForDay(
      day: DateTime(2026, 5, 1),
      family: family,
      birthdayTitle: title,
    );

    expect(events.map((event) => event.id), isNot(contains('m2')));
    // m1 уже представлен настоящим birth-событием, дубль не создаётся.
    expect(
      events.where((event) => event.id == 'calendar-birthday-m1'),
      isEmpty,
    );
  });

  test('обычный день рождения строится из профиля', () {
    final events = calendarEventsForDay(
      day: DateTime(2026, 7, 15),
      family: family,
      birthdayTitle: title,
    );

    final birthday = events.singleWhere(
      (event) => isGeneratedBirthday(event),
    );
    expect(birthday.memberId, 'm3');
    expect(birthday.title, 'BD m3');
  });
}
