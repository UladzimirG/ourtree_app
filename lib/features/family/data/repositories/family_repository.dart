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
    'en': 'assets/data/family_en.json',
  };

  /// Язык, который используется, если локаль не поддерживается.
  static const String fallbackLocale = 'ru';

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
    final saved = MediaStorage.instance.getString(storageKeyFor(localeName));
    if (saved != null && saved.trim().isNotEmpty) {
      final decoded = jsonDecode(saved);
      if (decoded is Map) {
        return FamilyData.fromJson(decoded.cast<String, dynamic>())
            .normalizeMediaLibrary();
      }
    }

    final raw = await rootBundle.loadString(assetFor(localeName));

    // Некоторые редакторы добавляют BOM в начало файла — jsonDecode его не ест.
    final normalized = raw.replaceFirst('\uFEFF', '');
    final decoded = jsonDecode(normalized);

    if (decoded is! Map) {
      throw const FormatException(
        'Family demo archive must contain a JSON object.',
      );
    }

    return FamilyData.fromJson(decoded.cast<String, dynamic>())
        .normalizeMediaLibrary();
  }

  /// Сохраняет архив локально, чтобы правки и медиатека пережили перезапуск.
  Future<void> saveFamilyData(FamilyData data, {String? localeName}) {
    return MediaStorage.instance.putString(
      storageKeyFor(localeName),
      jsonEncode(data.toJson()),
    );
  }
}
