import 'package:ourtree_app/core/utils/json_reader.dart';

/// Какие уведомления хочет получать это устройство.
///
/// Настройки хранятся и локально (Hive), и в документе устройства в Firestore:
/// серверная функция отправляет пуши по ним.
class NotificationPrefs {
  const NotificationPrefs({
    this.birthdays = true,
    this.calendar = true,
    this.familyUpdates = true,
  });

  /// Дни рождения участников.
  final bool birthdays;

  /// События календаря.
  final bool calendar;

  /// Кто-то из семьи обновил архив.
  final bool familyUpdates;

  /// Включены ли хоть какие-то уведомления.
  bool get anyEnabled => birthdays || calendar || familyUpdates;

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) =>
      NotificationPrefs(
        birthdays: readBool(json['birthdays']) ?? true,
        calendar: readBool(json['calendar']) ?? true,
        familyUpdates: readBool(json['familyUpdates']) ?? true,
      );

  Map<String, dynamic> toJson() => {
        'birthdays': birthdays,
        'calendar': calendar,
        'familyUpdates': familyUpdates,
      };

  NotificationPrefs copyWith({
    bool? birthdays,
    bool? calendar,
    bool? familyUpdates,
  }) =>
      NotificationPrefs(
        birthdays: birthdays ?? this.birthdays,
        calendar: calendar ?? this.calendar,
        familyUpdates: familyUpdates ?? this.familyUpdates,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPrefs &&
          birthdays == other.birthdays &&
          calendar == other.calendar &&
          familyUpdates == other.familyUpdates;

  @override
  int get hashCode => Object.hash(birthdays, calendar, familyUpdates);
}
