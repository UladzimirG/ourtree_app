import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';

/// Репозиторий семейного древа.
///
/// Демо-архив выбирается по языку интерфейса: `family_ru.json` или
/// `family_en.json`. Но сохранённый архив один на все языки: данные семьи
/// (люди, события, фото, кадрирование) не должны зависеть от того, на каком
/// языке сейчас открыт интерфейс, — иначе после смены языка пользователь
/// видел бы демо-архив вместо своих правок, а восстановленная из бэкапа копия
/// «пропадала».
///
/// Формат JSON тот же, что использовал React-проект (`familyName`, `members`,
/// `timelineEvents` и т.д.), поэтому парсинг выполняют наши доменные модели.
class FamilyRepository {
  const FamilyRepository();

  /// Демо-архивы по языку интерфейса.
  static const Map<String, String> demoArchives = <String, String>{
    'ru': 'assets/data/family_ru.json',
    'be': 'assets/data/family_be.json',
    'uk': 'assets/data/family_uk.json',
    'en': 'assets/data/family_en.json',
  };

  /// Язык, который используется, если локаль не поддерживается.
  ///
  /// По умолчанию это английский: при незнакомом языке системы приложение
  /// открывается на английском вместе с английским содержимым семьи.
  static const String fallbackLocale = 'en';

  /// Единый ключ сохранённого архива (не зависит от языка интерфейса).
  static const String storageKey = 'family_data';

  /// Путь к демо-архиву для языка [localeName].
  static String assetFor(String? localeName) =>
      demoArchives[_supported(localeName)]!;

  /// Прежний ключ архива для языка [localeName].
  ///
  /// Остаётся для миграции: до версии схемы 2 архив хранился отдельно для
  /// каждого языка.
  static String legacyStorageKeyFor(String? localeName) =>
      'family_data_${_supported(localeName)}';

  /// Поддерживаемый язык: `en`, `ru` или [fallbackLocale].
  static String _supported(String? localeName) {
    final code = localeName?.trim().toLowerCase() ?? '';
    return demoArchives.containsKey(code) ? code : fallbackLocale;
  }

  Future<FamilyData> loadFamilyData({String? localeName}) async {
    final demo = await _loadDemoArchive(_supported(localeName));
    final saved = _readSaved(localeName);
    if (saved == null || saved.trim().isEmpty) {
      return demo.normalizeMediaLibrary();
    }

    final decoded = jsonDecode(saved);
    if (decoded is! Map) return demo.normalizeMediaLibrary();

    return _withDemoIdentity(
      FamilyData.fromJson(decoded.cast<String, dynamic>()),
      demo,
    ).normalizeMediaLibrary();
  }

  /// Читает сохранённый архив: сначала единый ключ, затем — прежние языковые.
  ///
  /// Старые ключи читаются «лениво»: миграция схемы обычно переносит данные
  /// раньше, но если её пропустили (например, архив восстановили вручную),
  /// пользовательские правки всё равно не потеряются.
  String? _readSaved(String? localeName) {
    final storage = MediaStorage.instance;
    final current = storage.getString(storageKey);
    if (current != null && current.trim().isNotEmpty) return current;

    final preferred = _supported(localeName);
    final ordered = <String>[
      preferred,
      ...demoArchives.keys.where((code) => code != preferred),
    ];
    for (final code in ordered) {
      final legacy = storage.getString(legacyStorageKeyFor(code));
      if (legacy != null && legacy.trim().isNotEmpty) {
        unawaited(storage.putString(storageKey, legacy));
        return legacy;
      }
    }
    return null;
  }

  /// Читает демо-архив языка из ассетов.
  Future<FamilyData> _loadDemoArchive(String localeName) async {
    final raw = await rootBundle.loadString(demoArchives[localeName]!);

    // Некоторые редакторы добавляют BOM в начало файла — jsonDecode его не ест.
    final normalized = raw.replaceFirst('\uFEFF', '');
    final decoded = jsonDecode(normalized);

    if (decoded is! Map) {
      throw const FormatException(
        'Family demo archive must contain a JSON object.',
      );
    }

    return FamilyData.fromJson(decoded.cast<String, dynamic>());
  }

  /// Подставляет название и подзаголовок демо-архива текущего языка.
  ///
  /// Сохранённая копия может быть сделана на другом языке, поэтому
  /// локализованные демо-значения берём из ассета — но только пока
  /// пользователь не переименовал семью сам.
  FamilyData _withDemoIdentity(FamilyData data, FamilyData demo) {
    final settings = data.settings;
    if (settings.nameIsCustom && settings.subtitleIsCustom) return data;

    return data.copyWith(
      settings: settings.copyWith(
        familyName: settings.nameIsCustom ? null : demo.settings.familyName,
        familySubtitle:
            settings.subtitleIsCustom ? null : demo.settings.familySubtitle,
      ),
    );
  }

  /// Удаляет локально сохранённый архив, чтобы вернуться к демо-данным.
  ///
  /// Чистим и прежние языковые ключи: иначе после отката они снова попали бы
  /// в единый ключ при чтении.
  Future<void> clearSaved({String? localeName}) async {
    final storage = MediaStorage.instance;
    await storage.removeString(storageKey);
    for (final code in demoArchives.keys) {
      await storage.removeString(legacyStorageKeyFor(code));
    }
  }

  /// Сохраняет архив локально, чтобы правки и медиатека пережили перезапуск.
  ///
  /// [localeName] больше не участвует в ключе: параметр оставлен, чтобы не
  /// менять вызовы в провайдерах и тестах.
  Future<void> saveFamilyData(FamilyData data, {String? localeName}) {
    return MediaStorage.instance.putString(
      storageKey,
      jsonEncode(data.toJson()),
    );
  }
}