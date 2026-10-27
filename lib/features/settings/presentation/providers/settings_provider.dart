import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';

/// Редактируемые настройки семьи.
final familySettingsNotifierProvider =
    AsyncNotifierProvider<FamilySettingsNotifier, FamilySettings>(
  FamilySettingsNotifier.new,
);

/// Хранит [FamilySettings], начиная с данных, загруженных репозиторием.
class FamilySettingsNotifier extends AsyncNotifier<FamilySettings> {
  @override
  Future<FamilySettings> build() async {
    final family = await ref.read(familyDataProvider.future);
    return family.settings;
  }

  void updateFamilyName(String name) {
    _update((settings) => settings.copyWith(familyName: name));
  }

  void updateFamilyPhoto(String path) {
    final value = path.trim();
    _update(
      (settings) => settings.copyWith(
        familyPhoto: () => value.isEmpty ? null : value,
      ),
    );
  }

  void updateShowFamilyPhotoInHeader(bool value) {
    _update(
      (settings) => settings.copyWith(showFamilyPhotoInHeader: value),
    );
  }

  void updateShowEventPhotos(bool value) {
    _update((settings) => settings.copyWith(showEventPhotos: value));
  }

  Future<void> save() async {
    final current = state.valueOrNull;
    if (current == null) return;

    // Архив пока является read-only asset. Сохраняем изменения в состоянии
    // приложения; запись в API/локальное хранилище — следующий шаг.
    ref.read(familyDataProvider.notifier).updateSettings(current);
    state = AsyncData(current);
  }

  void _update(FamilySettings Function(FamilySettings) transform) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(transform(current));
  }
}
