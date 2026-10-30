import 'dart:convert';

import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/family/data/repositories/family_repository.dart';
import 'package:uuid/uuid.dart';

/// Ключ версии локальной схемы в боксе `app_state`.
const String storageSchemaVersionKey = 'storage_schema_version';

/// Текущая версия локальной схемы.
const int currentStorageSchemaVersion = 1;

/// Пошаговые миграции локального хранилища.
///
/// Запускается один раз в `main()` после `MediaStorage.init()`. Каждый шаг
/// идемпотентен: повторный запуск ничего не меняет.
class AppMigrations {
  AppMigrations({MediaStorage? storage, Uuid? uuid})
      : _storage = storage ?? MediaStorage.instance,
        _uuid = uuid ?? const Uuid();

  final MediaStorage _storage;
  final Uuid _uuid;

  /// Старый формат идентификатора аккаунта: `account-1712345678901234`.
  static final RegExp _legacyAccountId = RegExp(r'^account-\d+$');

  /// Возвращает `true`, если что-то изменилось.
  Future<bool> run() async {
    final stored = _storage.getString(storageSchemaVersionKey);
    final version = int.tryParse(stored ?? '') ?? 0;
    if (version >= currentStorageSchemaVersion) return false;

    await _backupBefore(version);
    if (version < 1) await _migrateToV1();

    await _storage.putString(
      storageSchemaVersionKey,
      '$currentStorageSchemaVersion',
    );
    return true;
  }

  /// Снимок «до миграции»: если что-то пойдёт не так, данные можно вернуть.
  Future<void> _backupBefore(int version) async {
    final backup = <String, dynamic>{
      'fromVersion': version,
      'createdAt': DateTime.now().toIso8601String(),
      'accounts': _storage.getString(accountsStorageKey),
      'currentAccountId': _storage.getString(currentAccountStorageKey),
      for (final localeName in FamilyRepository.demoArchives.keys)
        FamilyRepository.storageKeyFor(localeName):
            _storage.getString(FamilyRepository.storageKeyFor(localeName)),
    };
    await _storage.putBackup(
      'schema-v$version-${DateTime.now().millisecondsSinceEpoch}',
      backup,
    );
  }

  /// v1: `account-<micros>` → UUID v4 + перенос ссылок на аккаунты.
  Future<void> _migrateToV1() async {
    final raw = _storage.getString(accountsStorageKey);
    final accounts = _decodeAccounts(raw);
    if (accounts.isEmpty) return;

    final idMap = <String, String>{};
    final migrated = <Map<String, dynamic>>[];
    for (final entry in accounts) {
      final legacyId = entry['id'] as String? ?? '';
      final nextId =
          _legacyAccountId.hasMatch(legacyId) ? _uuid.v4() : legacyId;
      if (nextId != legacyId) idMap[legacyId] = nextId;
      migrated.add(<String, dynamic>{
        ...entry,
        'id': nextId,
        if (nextId != legacyId) 'legacyId': legacyId,
      });
    }

    await _storage.putString(accountsStorageKey, jsonEncode(migrated));

    // Активная сессия указывает на id аккаунта — его тоже надо переписать.
    final currentId = _storage.getString(currentAccountStorageKey);
    if (currentId != null && idMap.containsKey(currentId)) {
      await _storage.putString(currentAccountStorageKey, idMap[currentId]!);
    }

    if (idMap.isEmpty) return;

    // `TimelineEvent.hiddenFrom` хранит id аккаунтов, а не людей.
    for (final localeName in FamilyRepository.demoArchives.keys) {
      final key = FamilyRepository.storageKeyFor(localeName);
      final data = _storage.getString(key);
      if (data == null || data.trim().isEmpty) continue;
      final remapped = _remapFamilyArchive(data, idMap);
      if (remapped != null) await _storage.putString(key, remapped);
    }
  }

  List<Map<String, dynamic>> _decodeAccounts(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const <Map<String, dynamic>>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <Map<String, dynamic>>[];
      return [
        for (final item in decoded)
          if (item is Map) item.cast<String, dynamic>(),
      ];
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }

  /// Переписывает `hiddenFrom` во всех событиях архива.
  /// Возвращает `null`, если менять нечего.
  String? _remapFamilyArchive(String raw, Map<String, String> idMap) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final data = decoded.cast<String, dynamic>();
      final events = data['timelineEvents'];
      if (events is! List) return null;

      var changed = false;
      final nextEvents = <Map<String, dynamic>>[];
      for (final event in events) {
        if (event is! Map) continue;
        final map = event.cast<String, dynamic>();
        final hidden = map['hiddenFrom'];
        if (hidden is List) {
          final nextHidden = <dynamic>[
            for (final id in hidden)
              if (id is String) idMap[id] ?? id else id,
          ];
          if (!_sameList(hidden, nextHidden)) {
            changed = true;
            map['hiddenFrom'] = nextHidden;
          }
        }
        nextEvents.add(map);
      }
      if (!changed) return null;
      data['timelineEvents'] = nextEvents;
      return jsonEncode(data);
    } catch (_) {
      // Битый архив не должен блокировать запуск приложения.
      return null;
    }
  }

  bool _sameList(List<dynamic> first, List<dynamic> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }
}
