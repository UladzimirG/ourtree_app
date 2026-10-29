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
