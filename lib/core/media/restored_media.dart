import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

/// Возвращает встроенные в сборку фото по ссылкам `hive://restored-…`.
///
/// Импорт резервной копии переписывает пути встроенных файлов
/// (`/photos/…`) в `hive://restored-<sha256(путь)[:24]>`, а сами байты кладёт
/// в Hive. После переустановки, очистки данных или на другом устройстве этих
/// байтов уже нет — и фото пропадает из таймлайна и медиатеки, хотя снимок
/// по-прежнему лежит в сборке приложения.
///
/// Здесь мы повторяем ту же формулу хеша для всех файлов `assets/photos/` и
/// находим исходный ассет. Это позволяет и показать фото, и выгрузить его в
/// Firebase Storage кнопкой «Загрузить всё локальное».
class RestoredMedia {
  RestoredMedia._();

  static final RestoredMedia instance = RestoredMedia._();

  /// Префикс идентификатора, созданного при восстановлении архива.
  static const String idPrefix = 'restored-';

  static const String _sourcePrefix = 'hive://';
  static const String _assetFolder = 'assets/photos/';

  Future<Map<String, String>>? _index;
  final Map<String, Uint8List> _bytes = <String, Uint8List>{};

  /// `storedId` ссылки `hive://restored-…` или `null` для остальных путей.
  static String? restoredId(String? source) {
    final value = source?.trim();
    if (value == null || !value.startsWith(_sourcePrefix)) return null;
    final id = value.substring(_sourcePrefix.length);
    return id.startsWith(idPrefix) ? id : null;
  }

  /// Ключ ассета (`assets/photos/…`) для восстановленного идентификатора.
  Future<String?> assetKeyFor(String id) async {
    if (!id.startsWith(idPrefix)) return null;
    final index = await (_index ??= _buildIndex());
    return index[id];
  }

  /// Байты встроенного файла для восстановленного идентификатора.
  Future<Uint8List?> bytesFor(String id) async {
    if (!id.startsWith(idPrefix)) return null;
    final cached = _bytes[id];
    if (cached != null) return cached;
    final key = await assetKeyFor(id);
    if (key == null) return null;
    try {
      final data = await rootBundle.load(key);
      final value =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      _bytes[id] = value;
      return value;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> _buildIndex() async {
    final index = <String, String>{};
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      for (final key in manifest.listAssets()) {
        if (!key.startsWith(_assetFolder)) continue;
        // `_sourceAliases` при восстановлении использует путь в трёх видах.
        final relative = key.substring('assets/'.length);
        for (final alias in <String>{'/$relative', relative, key}) {
          final digest = sha256.convert(utf8.encode(alias)).toString();
          index['$idPrefix${digest.substring(0, 24)}'] = key;
        }
      }
    } catch (_) {
      // Без манифеста восстановление просто не сработает — это не критично.
    }
    return index;
  }
}
