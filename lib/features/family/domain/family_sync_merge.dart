import 'dart:convert';

import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';

/// Сколько живут «надгробия» удалённых сущностей.
///
/// Пока метка жива, удаление доезжает до других устройств. Через 60 дней её
/// можно забыть: к этому моменту устройства уже синхронизировались.
const Duration tombstoneRetention = Duration(days: 60);

/// Единица синхронизации: архив + отметки времени сущностей.
///
/// Ключи: `settings`, `member:<id>`, `event:<id>`, `media:<id>`.
class FamilySyncPayload {
  const FamilySyncPayload({
    required this.data,
    this.stamps = const <String, int>{},
    this.tombstones = const <String, int>{},
  });

  final FamilyData data;

  /// Время последнего изменения живой сущности (мс эпохи).
  final Map<String, int> stamps;

  /// Время удаления сущности (мс эпохи) — tombstone.
  final Map<String, int> tombstones;

  factory FamilySyncPayload.fromJson(Map<String, dynamic> json) {
    return FamilySyncPayload(
      data: FamilyData.fromJson(json),
      stamps: _readMap(json['entityUpdatedAt']),
      tombstones: _readMap(json['entityDeletedAt']),
    );
  }

  /// Читает карту отметок.
  ///
  /// Ранние версии клиента писали её JSON-строкой (`jsonEncode`), поэтому
  /// строковый формат тоже разбираем — иначе серверные отметки считались бы
  /// пустыми и правки с другого устройства никогда не применялись.
  static Map<String, int> _readMap(Object? raw) {
    final result = <String, int>{};
    Object? value = raw;
    if (value is String && value.trim().isNotEmpty) {
      try {
        value = jsonDecode(value);
      } catch (_) {
        return result;
      }
    }
    if (value is Map) {
      for (final entry in value.entries) {
        final item = entry.value;
        if (item is num) result[entry.key.toString()] = item.toInt();
      }
    }
    return result;
  }
}

String memberKey(String id) => 'member:$id';

String eventKey(String id) => 'event:$id';

String mediaKey(String id) => 'media:$id';

const String settingsKey = 'settings';

/// Ключ локального хранилища с надгробиями, которые ещё не доехали до облака.
///
/// Их пишут миграции (например, удаление демо-событий): так удаление уезжает
/// в облако при следующем подключении семьи, а не отменяется серверной копией.
const String pendingTombstonesStorageKey = 'family_sync_pending_tombstones';

/// Отпечатки содержимого сущностей: по ним видно, что именно изменилось.
///
/// Путь к локальному файлу в отпечаток не входит: он не синхронизируется и не
/// должен считаться правкой.
Map<String, String> entityFingerprints(FamilyData data) => {
      settingsKey: jsonEncode(data.settings.toJson()),
      for (final member in data.members)
        memberKey(member.id): jsonEncode(member.toJson()),
      for (final event in data.timelineEvents)
        eventKey(event.id): jsonEncode(event.toJson()),
      for (final asset in data.mediaLibrary)
        mediaKey(asset.id): jsonEncode(asset.toJson(includeLocalPath: false)),
    };

/// Объединение локального и серверного архива **по сущностям**.
///
/// Для каждой сущности побеждает сторона с более свежей отметкой, а удаления
/// учитываются через [FamilySyncPayload.tombstones]: если метка удаления новее
/// последней правки, сущность исчезает из объединённого архива. Так удаление
/// на одном устройстве доезжает до остальных, а правки разных людей и событий
/// не перетирают друг друга.
/// [dropUnstampedLocal] нужен при подключении к семье: сущность без локальной
/// отметки времени не является правкой этого устройства — это демо-архив или
/// архив другой семьи. Такие записи не переносим в семью, иначе после
/// присоединения по коду в общем альбоме появлялись бы демо-люди, события и
/// фотографии (и уезжали бы обратно в облако при первой же правке).
FamilySyncPayload mergeSyncPayloads({
  required FamilyData local,
  required Map<String, int> localStamps,
  required FamilySyncPayload remote,
  Map<String, int> localTombstones = const <String, int>{},
  bool dropUnstampedLocal = false,
}) {
  final stamps = _mergeMaps(localStamps, remote.stamps);
  final tombstones = _mergeMaps(localTombstones, remote.tombstones);

  final now = DateTime.now().millisecondsSinceEpoch;
  tombstones.removeWhere(
    (_, deletedAt) => now - deletedAt > tombstoneRetention.inMilliseconds,
  );

  int liveStamp(String key) => stamps[key] ?? 0;

  bool isDeleted(String key) => (tombstones[key] ?? 0) > liveStamp(key);

  bool remoteWins(String key) =>
      (remote.stamps[key] ?? 0) > (localStamps[key] ?? 0);

  /// Принадлежит ли локальная сущность этой семье.
  bool belongsToFamily(String key) =>
      !dropUnstampedLocal || localStamps.containsKey(key);

  final settings =
      (dropUnstampedLocal && !localStamps.containsKey(settingsKey)) ||
              remoteWins(settingsKey)
          ? remote.data.settings
          : local.settings;

  final members = <String, FamilyMember>{
    for (final member in local.members)
      if (belongsToFamily(memberKey(member.id))) member.id: member,
  };
  for (final member in remote.data.members) {
    if (remoteWins(memberKey(member.id)) || !members.containsKey(member.id)) {
      members[member.id] = member;
    }
  }
  members.removeWhere((id, _) => isDeleted(memberKey(id)));

  final events = <String, TimelineEvent>{
    for (final event in local.timelineEvents)
      if (belongsToFamily(eventKey(event.id))) event.id: event,
  };
  for (final event in remote.data.timelineEvents) {
    if (remoteWins(eventKey(event.id)) || !events.containsKey(event.id)) {
      events[event.id] = event;
    }
  }
  events.removeWhere((id, _) => isDeleted(eventKey(id)));

  final assets = <String, MediaAsset>{
    for (final asset in local.mediaLibrary)
      if (belongsToFamily(mediaKey(asset.id))) asset.id: asset,
  };
  for (final asset in remote.data.mediaLibrary) {
    if (remoteWins(mediaKey(asset.id)) || !assets.containsKey(asset.id)) {
      assets[asset.id] = asset;
    }
  }
  assets.removeWhere((id, _) => isDeleted(mediaKey(id)));

  // Если сущность пересоздана позже удаления, надгробие больше не нужно.
  tombstones.removeWhere((key, deletedAt) => liveStamp(key) > deletedAt);

  final mergedEvents = events.values.toList(growable: false)
    ..sort((a, b) => a.date.compareTo(b.date));

  return FamilySyncPayload(
    data: local.copyWith(
      settings: settings,
      members: members.values.toList(growable: false),
      timelineEvents: mergedEvents,
      mediaLibrary: assets.values.toList(growable: false),
    ),
    stamps: stamps,
    tombstones: tombstones,
  );
}

/// Объединение двух карт отметок: по каждому ключу берём максимум.
Map<String, int> _mergeMaps(Map<String, int> a, Map<String, int> b) {
  final result = <String, int>{...a};
  for (final entry in b.entries) {
    final existing = result[entry.key];
    if (existing == null || entry.value > existing) {
      result[entry.key] = entry.value;
    }
  }
  return result;
}
