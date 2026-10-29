import 'dart:async';

import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

/// Редактируемые настройки семьи.
@Riverpod(keepAlive: true)
class FamilySettingsNotifier extends _$FamilySettingsNotifier {
  @override
  Future<FamilySettings> build() async {
    // Настройки — это «шапка» архива, поэтому они пересчитываются вместе с
    // данными (например, при смене языка интерфейса).
    final family = await ref.watch(familyDataProvider.future);
    return family.settings;
  }

  void updateFamilyName(String name) {
    _update(
      (settings) => settings.copyWith(
        familyName: name,
        // Как только значение отличается от загруженного, это правка
        // пользователя и её больше не перекрывает демо-название.
        nameIsCustom: settings.nameIsCustom || name.trim() != settings.familyName,
      ),
    );
  }

  /// Подзаголовок главной страницы; пустая строка скрывает его.
  void updateFamilySubtitle(String subtitle) {
    final value = subtitle.trim();
    _update(
      (settings) => settings.copyWith(
        familySubtitle: value,
        subtitleIsCustom:
            settings.subtitleIsCustom || value != settings.familySubtitle,
      ),
    );
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
    final current = state.value;
    if (current == null) return;

    // Архив пока является read-only asset. Сохраняем изменения в состоянии
    // приложения; запись в API/локальное хранилище — следующий шаг.
    ref.read(familyDataProvider.notifier).updateSettings(current);
    state = AsyncData(current);
  }

  void _update(FamilySettings Function(FamilySettings) transform) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(transform(current));
  }
}
