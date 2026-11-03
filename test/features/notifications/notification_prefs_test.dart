import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/notifications/domain/notification_prefs.dart';

void main() {
  test('по умолчанию включены все категории', () {
    const prefs = NotificationPrefs();
    expect(prefs.birthdays, isTrue);
    expect(prefs.calendar, isTrue);
    expect(prefs.familyUpdates, isTrue);
    expect(prefs.anyEnabled, isTrue);
  });

  test('отсутствующие поля считаются включёнными', () {
    final prefs = NotificationPrefs.fromJson({'birthdays': false});
    expect(prefs.birthdays, isFalse);
    expect(prefs.calendar, isTrue);
    expect(prefs.familyUpdates, isTrue);
  });

  test('JSON переживает круговой обход', () {
    final prefs = const NotificationPrefs(
      birthdays: false,
      calendar: true,
      familyUpdates: false,
    );
    expect(NotificationPrefs.fromJson(prefs.toJson()), prefs);
  });

  test('все выключенные категории дают anyEnabled = false', () {
    const prefs = NotificationPrefs(
      birthdays: false,
      calendar: false,
      familyUpdates: false,
    );
    expect(prefs.anyEnabled, isFalse);
    expect(prefs.copyWith(calendar: true).anyEnabled, isTrue);
  });
}
