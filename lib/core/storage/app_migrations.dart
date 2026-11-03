import 'dart:convert';

import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/utils/json_reader.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/family/data/repositories/family_repository.dart';
import 'package:ourtree_app/features/family/domain/family_sync_merge.dart';
import 'package:uuid/uuid.dart';

/// Ключ версии локальной схемы в боксе `app_state`.
const String storageSchemaVersionKey = 'storage_schema_version';

/// Текущая версия локальной схемы.
const int currentStorageSchemaVersion = 3;

/// Ключ выбранного языка интерфейса (ppLocaleStorageKey в locale_provider).
const String _appLocaleKey = 'app_locale';

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

  /// Демо-события рождения из первой версии архива (`assets/data/family.json`).
  ///
  /// Их убрали из демо-ассетов, но копии успели сохраниться в Hive и уехать в
  /// облако (`seedFamily` отправляет локальный архив целиком). Событие
  /// считается демо-остатком, только если совпадает всё: id, дата, тип и
  /// участник — отредактированную пользователем запись не трогаем.
  static const List<_LegacyDemoEvent> _legacyDemoEvents = <_LegacyDemoEvent>[
    _LegacyDemoEvent(
      id: 'birth-sofia',
      date: '2011-03-08',
      memberId: 'child-1',
    ),
    _LegacyDemoEvent(
      id: 'birth-misha',
      date: '2013-11-19',
      memberId: 'child-2',
    ),
    _LegacyDemoEvent(
      id: 'birth-anya',
      date: '2016-05-02',
      memberId: 'child-3',
    ),
    _LegacyDemoEvent(
      id: 'birth-danya',
      date: '2018-09-27',
      memberId: 'child-4',
    ),
  ];

  /// Возвращает `true`, если что-то изменилось.
  Future<bool> run() async {
    final stored = _storage.getString(storageSchemaVersionKey);
    final version = int.tryParse(stored ?? '') ?? 0;
    if (version >= currentStorageSchemaVersion) return false;

    await _backupBefore(version);
    if (version < 1) await _migrateToV1();
    if (version < 2) await _migrateToV2();
    if (version < 3) await _migrateToV3();

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
      FamilyRepository.storageKey:
          _storage.getString(FamilyRepository.storageKey),
      for (final localeName in FamilyRepository.demoArchives.keys)
        FamilyRepository.legacyStorageKeyFor(localeName): _storage
            .getString(FamilyRepository.legacyStorageKeyFor(localeName)),
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
      final key = FamilyRepository.legacyStorageKeyFor(localeName);
      final data = _storage.getString(key);
      if (data == null || data.trim().isEmpty) continue;
      final remapped = _remapFamilyArchive(data, idMap);
      if (remapped != null) await _storage.putString(key, remapped);
    }
  }

  /// v2: архив семьи переехал из ключей по языку в единый `family_data`.
  ///
  /// До этой версии правки хранились отдельно для каждого языка: после смены
  /// языка пользователь видел демо-архив, а восстановленная из бэкапа копия
  /// «пропадала». Переносим первый непустой архив (приоритет — выбранный язык
  /// интерфейса) и удаляем старые ключи, чтобы они не «воскрешали» устаревшие
  /// копии.
  Future<void> _migrateToV2() async {
    final existing = _storage.getString(FamilyRepository.storageKey);
    final preferred = _localeFromStorage();
    final ordered = <String>[
      preferred,
      ...FamilyRepository.demoArchives.keys.where((code) => code != preferred),
    ];

    if (existing == null || existing.trim().isEmpty) {
      for (final code in ordered) {
        final legacy =
            _storage.getString(FamilyRepository.legacyStorageKeyFor(code));
        if (legacy != null && legacy.trim().isNotEmpty) {
          await _storage.putString(FamilyRepository.storageKey, legacy);
          break;
        }
      }
    }

    for (final code in FamilyRepository.demoArchives.keys) {
      await _storage.removeString(FamilyRepository.legacyStorageKeyFor(code));
    }
  }

  /// v3: удаляет из сохранённого архива демо-события рождения, которых больше
  /// нет в демо-ассетах (например, «Рождение Даниила»).
  ///
  /// Удаление записывается в отложенные надгробия: при следующем подключении
  /// семьи синхронизация отправит его в облако, поэтому событие исчезнет и на
  /// остальных устройствах, а не «воскреснет» при слиянии.
  Future<void> _migrateToV3() async {
    final raw = _storage.getString(FamilyRepository.storageKey);
    if (raw == null || raw.trim().isEmpty) return;

    final cleanup = _removeLegacyDemoEvents(raw);
    if (cleanup == null) return;

    await _storage.putString(
      FamilyRepository.storageKey,
      jsonEncode(cleanup.data),
    );
    if (cleanup.removedIds.isEmpty) return;

    final pending = _decodeTombstones(
      _storage.getString(pendingTombstonesStorageKey),
    );
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final id in cleanup.removedIds) {
      pending[eventKey(id)] = now;
    }
    await _storage.putString(
      pendingTombstonesStorageKey,
      jsonEncode(pending),
    );
  }

  /// Вырезает демо-события рождения и ссылки на них из архива.
  ///
  /// Возвращает `null`, если менять нечего.
  _ArchiveCleanup? _removeLegacyDemoEvents(String raw) {
    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      data = decoded.cast<String, dynamic>();
    } catch (_) {
      // Битый архив не должен блокировать запуск приложения.
      return null;
    }

    final events = data['timelineEvents'];
    if (events is! List) return null;

    final removed = <String>{};
    final nextEvents = <Map<String, dynamic>>[];
    for (final item in events) {
      if (item is! Map) continue;
      final event = item.cast<String, dynamic>();
      if (_isLegacyDemoEvent(event)) {
        removed.add(readString(event['id']));
        continue;
      }
      nextEvents.add(event);
    }
    if (removed.isEmpty) return null;

    data['timelineEvents'] = nextEvents;
    final cleaned = _stripEventIds(data, removed);
    return _ArchiveCleanup(
      data: cleaned is Map<String, dynamic>
          ? cleaned
          : (cleaned as Map).cast<String, dynamic>(),
      removedIds: removed,
    );
  }

  bool _isLegacyDemoEvent(Map<String, dynamic> event) {
    final id = readString(event['id']);
    if (id.isEmpty) return false;
    for (final legacy in _legacyDemoEvents) {
      if (legacy.id != id) continue;
      return readString(event['date']) == legacy.date &&
          readString(event['kind']) == 'birth' &&
          readString(event['memberId']) == legacy.memberId;
    }
    return false;
  }

  /// Убирает ссылки на удалённые события из всех вложенных списков `eventIds`.
  Object? _stripEventIds(Object? node, Set<String> removedIds) {
    if (node is List) {
      return <Object?>[
        for (final item in node) _stripEventIds(item, removedIds),
      ];
    }
    if (node is Map) {
      return <String, dynamic>{
        for (final entry in node.entries)
          entry.key.toString(): entry.key == 'eventIds' && entry.value is List
              ? <Object?>[
                  for (final id in entry.value as List)
                    if (!(id is String && removedIds.contains(id))) id,
                ]
              : _stripEventIds(entry.value, removedIds),
      };
    }
    return node;
  }

  Map<String, int> _decodeTombstones(String? raw) {
    final result = <String, int>{};
    if (raw == null || raw.trim().isEmpty) return result;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return result;
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is num) result[entry.key.toString()] = value.toInt();
      }
    } catch (_) {
      // Битые надгробия не должны блокировать миграцию.
    }
    return result;
  }

  /// Выбранный язык интерфейса из локального хранилища.
  ///
  /// Ключ продублирован, чтобы миграции не зависели от Riverpod-провайдеров.
  String _localeFromStorage() {
    final saved = _storage.getString(_appLocaleKey);
    if (saved == null || saved.isEmpty || saved == 'system') {
      return FamilyRepository.fallbackLocale;
    }
    return saved;
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

/// Описание демо-события рождения из первой версии архива.
class _LegacyDemoEvent {
  const _LegacyDemoEvent({
    required this.id,
    required this.date,
    required this.memberId,
  });

  final String id;
  final String date;
  final String memberId;
}

/// Результат чистки архива: новые данные и id удалённых событий.
class _ArchiveCleanup {
  const _ArchiveCleanup({required this.data, required this.removedIds});

  final Map<String, dynamic> data;
  final Set<String> removedIds;
}
