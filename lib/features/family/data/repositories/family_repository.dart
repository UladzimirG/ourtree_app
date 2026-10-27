import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';

/// Репозиторий семейного древа.
///
/// Данные читаются из JSON-архива, лежащего в ассетах приложения. Это тот же
/// формат, который использовал React-проект (`familyName`, `members`,
/// `timelineEvents` и т.д.), поэтому парсинг выполняют наши доменные модели.
class FamilyRepository {
  const FamilyRepository();

  /// Путь к архиву внутри Flutter-ассетов.
  static const String familyDataAsset = 'assets/data/family.json';

  /// Ключ сохранённого состояния в локальном хранилище.
  static const String storageKey = 'family_data';

  Future<FamilyData> loadFamilyData() async {
    final saved = MediaStorage.instance.getString(storageKey);
    if (saved != null && saved.trim().isNotEmpty) {
      final decoded = jsonDecode(saved);
      if (decoded is Map) {
        return FamilyData.fromJson(decoded.cast<String, dynamic>())
            .normalizeMediaLibrary();
      }
    }

    final raw = await rootBundle.loadString(familyDataAsset);

    // Некоторые редакторы добавляют BOM в начало файла — jsonDecode его не ест.
    final normalized = raw.replaceFirst('\uFEFF', '');
    final decoded = jsonDecode(normalized);

    if (decoded is! Map) {
      throw const FormatException(
        'assets/data/family.json must contain a JSON object.',
      );
    }

    return FamilyData.fromJson(decoded.cast<String, dynamic>())
        .normalizeMediaLibrary();
  }

  /// Сохраняет архив локально, чтобы правки и медиатека пережили перезапуск.
  Future<void> saveFamilyData(FamilyData data) {
    return MediaStorage.instance.putString(storageKey, jsonEncode(data.toJson()));
  }
}
