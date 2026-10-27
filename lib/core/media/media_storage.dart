import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';

/// Локальное хранилище медиа и состояния приложения.
///
/// Hive даёт файловое хранилище на мобильных/desktop и IndexedDB в вебе.
/// Если Hive не инициализирован (например, в юнит-тестах), сервис работает
/// как in-memory-хранилище — тесты не требуют файловой системы.
class MediaStorage {
  MediaStorage._();

  static final MediaStorage instance = MediaStorage._();

  Box<dynamic>? _mediaBox;
  Box<dynamic>? _appBox;
  Box<dynamic>? _backupBox;

  final Map<String, Uint8List> _memoryMedia = <String, Uint8List>{};
  final Map<String, String> _memoryApp = <String, String>{};
  final Map<String, Map<String, dynamic>> _memoryBackups =
      <String, Map<String, dynamic>>{};

  bool get isPersistent => _mediaBox != null;

  /// Инициализирует Hive и открывает боксы. Вызывается один раз в `main`.
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _mediaBox = await Hive.openBox<dynamic>('media_bytes');
      _appBox = await Hive.openBox<dynamic>('app_state');
      _backupBox = await Hive.openBox<dynamic>('backups');
    } catch (_) {
      // В тестах/на платформах без файловой системы остаёмся в памяти.
      _mediaBox = null;
      _appBox = null;
      _backupBox = null;
    }
  }

  /// Сохраняет байты файла и возвращает идентификатор.
  Future<String> saveBytes(Uint8List bytes, {String? name}) async {
    final id = 'media-${DateTime.now().microsecondsSinceEpoch}';
    if (_mediaBox != null) {
      await _mediaBox!.put(id, bytes);
    } else {
      _memoryMedia[id] = bytes;
    }
    return id;
  }

  /// Кладёт байты под существующий id (восстановление резервной копии).
  Future<void> putBytes(String id, Uint8List bytes) async {
    if (_mediaBox != null) {
      await _mediaBox!.put(id, bytes);
    } else {
      _memoryMedia[id] = bytes;
    }
  }

  Future<Uint8List?> loadBytes(String id) async {
    final raw = _mediaBox != null ? await _mediaBox!.get(id) : _memoryMedia[id];
    if (raw is Uint8List) return raw;
    if (raw is List<int>) return Uint8List.fromList(raw);
    return null;
  }

  Future<void> deleteBytes(String id) async {
    if (_mediaBox != null) {
      await _mediaBox!.delete(id);
    } else {
      _memoryMedia.remove(id);
    }
  }

  Future<void> putString(String key, String value) async {
    if (_appBox != null) {
      await _appBox!.put(key, value);
    } else {
      _memoryApp[key] = value;
    }
  }

  String? getString(String key) {
    final value = _appBox?.get(key) ?? _memoryApp[key];
    return value is String ? value : null;
  }

  Future<void> removeString(String key) async {
    if (_appBox != null) {
      await _appBox!.delete(key);
    } else {
      _memoryApp.remove(key);
    }
  }

  Future<void> putBackup(String name, Map<String, dynamic> bundle) async {
    if (_backupBox != null) {
      await _backupBox!.put(name, bundle);
    } else {
      _memoryBackups[name] = bundle;
    }
  }

  Map<String, dynamic>? getBackup(String name) {
    final value = _backupBox?.get(name) ?? _memoryBackups[name];
    if (value is Map) return value.cast<String, dynamic>();
    return null;
  }

  List<String> backupNames() {
    final names = _backupBox?.keys.whereType<String>().toList() ??
        _memoryBackups.keys.toList();
    return names;
  }

  /// Полностью очищает локальное хранилище. Используется в тестах.
  Future<void> clearForTests() async {
    _memoryMedia.clear();
    _memoryApp.clear();
    _memoryBackups.clear();
    await _mediaBox?.clear();
    await _appBox?.clear();
    await _backupBox?.clear();
  }

  Future<void> deleteBackup(String name) async {
    if (_backupBox != null) {
      await _backupBox!.delete(name);
    } else {
      _memoryBackups.remove(name);
    }
  }
}
