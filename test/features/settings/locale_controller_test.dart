import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/settings/presentation/providers/locale_provider.dart';

void main() {
  setUp(() async {
    await MediaStorage.instance.clearForTests();
  });

  test('по умолчанию следует языку системы', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(localeControllerProvider), isNull);
    expect(MediaStorage.instance.getString(appLocaleStorageKey), isNull);
  });

  test('сохраняет выбранный язык и восстанавливает его после перезапуска',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(localeControllerProvider.notifier)
        .select(const Locale('en'));

    expect(container.read(localeControllerProvider), const Locale('en'));
    expect(MediaStorage.instance.getString(appLocaleStorageKey), 'en');

    // Новый контейнер имитирует следующий запуск приложения.
    final restored = ProviderContainer();
    addTearDown(restored.dispose);

    expect(restored.read(localeControllerProvider), const Locale('en'));
  });

  test('возврат к языку системы сбрасывает сохранённый выбор', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(localeControllerProvider.notifier)
        .select(const Locale('ru'));
    await container.read(localeControllerProvider.notifier).select(null);

    expect(container.read(localeControllerProvider), isNull);
    expect(
      MediaStorage.instance.getString(appLocaleStorageKey),
      systemLocaleCode,
    );
  });
}
