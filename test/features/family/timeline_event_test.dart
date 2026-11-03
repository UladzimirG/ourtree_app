import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';

void main() {
  test('новые флаги календаря переживают JSON round-trip', () {
    const event = TimelineEvent(
      id: 'calendar-1',
      date: '2026-05-01',
      title: 'День рождения',
      showInTimeline: false,
      recurringYearly: true,
    );

    final json = event.toJson();
    expect(json['showInTimeline'], isFalse);
    expect(json['recurringYearly'], isTrue);

    final restored = TimelineEvent.fromJson(json);
    expect(restored.showsInTimeline, isFalse);
    expect(restored.isCalendarOnly, isTrue);
    expect(restored.isRecurringYearly, isTrue);
  });

  test('старые события без флагов остаются обычными', () {
    final event = TimelineEvent.fromJson(const {
      'id': 'old',
      'date': '2020-01-01',
      'title': 'Старое',
    });

    expect(event.showsInTimeline, isTrue);
    expect(event.isRecurringYearly, isFalse);
    expect(event.toJson().containsKey('showInTimeline'), isFalse);
    expect(event.toJson().containsKey('recurringYearly'), isFalse);
  });

  test('copyWith меняет флаги, не теряя остальные поля', () {
    const event = TimelineEvent(
      id: 'e1',
      date: '2026-01-01',
      title: 'Событие',
      kind: EventKind.trip,
    );

    final updated = event.copyWith(
      showInTimeline: false,
      recurringYearly: true,
    );

    expect(updated.kind, EventKind.trip);
    expect(updated.id, 'e1');
    expect(updated.isCalendarOnly, isTrue);
    expect(updated.isRecurringYearly, isTrue);
  });
}
