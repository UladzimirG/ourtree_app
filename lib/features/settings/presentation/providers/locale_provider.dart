import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_provider.g.dart';

/// Ключ выбранного языка в локальном хранилище (бокс `app_state` в Hive).
const String appLocaleStorageKey = 'app_locale';

/// Значение «язык как в системе».
///
/// У [Locale] нет такого состояния, поэтому в хранилище и в UI используем
/// отдельную строку-маркер, а сам провайдер держит `null`.
const String systemLocaleCode = 'system';

/// Выбранный язык интерфейса.
///
/// `null` означает «следовать языку системы»: тогда `MaterialApp` получает
/// `locale: null` и Flutter сам выбирает первый подходящий из
/// `AppLocalizations.supportedLocales`.
///
/// Выбор живёт в Hive, поэтому переживает перезапуск приложения и
/// восстанавливается до первого кадра — без «мигания» языка.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Locale? build() {
    final saved = MediaStorage.instance.getString(appLocaleStorageKey);
    if (saved == null || saved.isEmpty || saved == systemLocaleCode) {
      return null;
    }
    return Locale(saved);
  }

  /// Запоминает язык: `null` — вернуться к языку системы.
  Future<void> select(Locale? locale) async {
    state = locale;
    await MediaStorage.instance.putString(
      appLocaleStorageKey,
      locale?.languageCode ?? systemLocaleCode,
    );
  }
}

/// Итоговый язык интерфейса: выбранный вручную или разрешённый из системы.
///
/// Именно его используют провайдеры данных, чтобы выбрать демо-архив и ключ
/// хранения. Благодаря этому вариант «как в системе» работает и для контента,
/// а не только для подписей интерфейса.
@Riverpod(keepAlive: true)
Locale appLocale(Ref ref) {
  final chosen = ref.watch(localeControllerProvider);
  if (chosen != null) return chosen;
  return basicLocaleListResolution(
    PlatformDispatcher.instance.locales,
    AppLocalizations.supportedLocales,
  );
}
