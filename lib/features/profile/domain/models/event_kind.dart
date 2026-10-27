/// Вид события таймлайна (`EventKind` из `src/data/family.ts`).
enum EventKind {
  meeting('meeting'),
  date('date'),
  wedding('wedding'),
  church('church'),
  birth('birth'),
  trip('trip'),
  milestone('milestone');

  const EventKind(this.wireName);

  /// Значение, которое приходит в JSON.
  final String wireName;

  /// Неизвестный вид не должен ломать таймлайн — считаем его вехой.
  static EventKind fromWire(Object? value) {
    for (final kind in values) {
      if (kind.wireName == value) return kind;
    }
    return EventKind.milestone;
  }
}
