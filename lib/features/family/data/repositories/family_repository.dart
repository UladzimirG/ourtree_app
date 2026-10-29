import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';

/// Репозиторий семейного древа.
///
/// Демо-архив выбирается по языку интерфейса: `family_ru.json` или
/// `family_en.json`. Правки сохраняются в Hive отдельно для каждого языка,
/// поэтому после переключения языка показываются данные на нужном языке.
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

  /// Путь к демо-архиву для языка [localeName].
  static String assetFor(String? localeName) =>
      demoArchives[_supported(localeName)]!;

  /// Ключ сохранённого состояния для языка [localeName].
  static String storageKeyFor(String? localeName) =>
      'family_data_${_supported(localeName)}';

  /// Поддерживаемый язык: `en`, `ru` или [fallbackLocale].
  static String _supported(String? localeName) {
    final code = localeName?.trim().toLowerCase() ?? '';
    return demoArchives.containsKey(code) ? code : fallbackLocale;
  }

  Future<FamilyData> loadFamilyData({String? localeName}) async {
    final demo = await _loadDemoArchive(_supported(localeName));
    final saved = MediaStorage.instance.getString(storageKeyFor(localeName));
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
  Future<void> clearSaved({String? localeName}) {
    return MediaStorage.instance.removeString(storageKeyFor(localeName));
  }

  /// Сохраняет архив локально, чтобы правки и медиатека пережили перезапуск.
  Future<void> saveFamilyData(FamilyData data, {String? localeName}) {
    return MediaStorage.instance.putString(
      storageKeyFor(localeName),
      jsonEncode(data.toJson()),
    );
  }
}
