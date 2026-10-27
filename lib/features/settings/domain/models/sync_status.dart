/// Состояние синхронизации семейных данных с сервером.
///
/// Повторяет `syncStatus` из `FamilyDataContext.tsx`.
enum SyncStatus {
  loading('loading'),
  saved('saved'),
  saving('saving'),
  error('error');

  const SyncStatus(this.wireName);

  /// Значение, которым статус обозначен в исходном приложении.
  final String wireName;

  bool get isBusy => this == SyncStatus.loading || this == SyncStatus.saving;

  static SyncStatus fromWire(Object? value) {
    for (final status in values) {
      if (status.wireName == value) return status;
    }
    return SyncStatus.loading;
  }
}
