import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/notifications/domain/upcoming_reminders.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';

void main() {
  FamilyMember member(String id, String name, String birthday) => FamilyMember(
        id: id,
        role: 'Роль',
        name: name,
        nickname: '',
        birthday: birthday,
      );

  FamilyData family({
    List<FamilyMember> members = const [],
    List<TimelineEvent> events = const [],
  }) =>
      FamilyData(
        settings: const FamilySettings(familyName: 'Дерево'),
        members: members,
        timelineEvents: events,
      );

  String birthdayTitle(FamilyMember member) => 'День рождения: ${member.name}';

  final from = DateTime(2026, 3, 10);

  test('день рождения попадает в список в свой день', () {
    final reminders = upcomingReminders(
      family: family(members: [member('masha', 'Маша', '2013-03-11')]),
      from: from,
      days: 7,
      birthdayTitle: birthdayTitle,
    );

    expect(reminders, hasLength(1));
    expect(reminders.single.title, 'День рождения: Маша');
    expect(reminders.single.date, DateTime(2026, 3, 11));
    expect(reminders.single.isBirthday, isTrue);
  });

  test('ежегодное событие сравнивается по месяцу и дню', () {
    final reminders = upcomingReminders(
      family: family(
        events: [
          TimelineEvent(
            id: 'wedding',
            date: '2011-08-20',
            title: 'Свадьба',
            recurringYearly: true,
          ),
        ],
      ),
      from: DateTime(2026, 8, 15),
      days: 7,
      birthdayTitle: birthdayTitle,
    );

    expect(reminders.map((item) => item.title), ['Свадьба']);
  });

  test('обычное событие в прошлом году не попадает в список', () {
    final reminders = upcomingReminders(
      family: family(
        events: [
          TimelineEvent(
            id: 'trip',
            date: '2025-03-11',
            title: 'Поездка',
          ),
        ],
      ),
      from: from,
      days: 7,
      birthdayTitle: birthdayTitle,
    );

    expect(reminders, isEmpty);
  });

  test('событие с отметкой «не показывать в календаре» пропускается', () {
    final reminders = upcomingReminders(
      family: family(
        events: [
          TimelineEvent(
            id: 'trip',
            date: '2026-03-11',
            title: 'Поездка',
            showInCalendar: false,
          ),
        ],
      ),
      from: from,
      days: 7,
      birthdayTitle: birthdayTitle,
    );

    expect(reminders, isEmpty);
  });

  test('событие рождения не дублируется днём рождения из профиля', () {
    final reminders = upcomingReminders(
      family: family(
        members: [member('masha', 'Маша', '2013-03-11')],
        events: [
          TimelineEvent(
            id: 'birth-masha',
            date: '2013-03-11',
            title: 'Родилась Маша',
            kind: EventKind.birth,
            memberId: 'masha',
            recurringYearly: true,
          ),
        ],
      ),
      from: from,
      days: 7,
      birthdayTitle: birthdayTitle,
    );

    expect(reminders.map((item) => item.title), ['Родилась Маша']);
  });

  test('всё, что дальше недели, не показывается', () {
    final reminders = upcomingReminders(
      family: family(members: [member('vanya', 'Ваня', '2015-03-20')]),
      from: from,
      days: 7,
      birthdayTitle: birthdayTitle,
    );

    expect(reminders, isEmpty);
  });
}
