import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/family/domain/family_sync_merge.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';

void main() {
  FamilyMember member(String id, String name) {
    return FamilyMember(
      id: id,
      role: 'Роль',
      name: name,
      nickname: '',
      birthday: '2000-01-01',
    );
  }

  TimelineEvent event(String id, String date, String title) {
    return TimelineEvent(id: id, date: date, title: title);
  }

  MediaAsset asset(String id, {String? downloadUrl, int updatedAt = 0}) {
    return MediaAsset(
      id: id,
      source: 'hive://$id',
      downloadUrl: downloadUrl,
      updatedAt: updatedAt,
    );
  }

  FamilyData data({
    String familyName = 'Дерево',
    List<FamilyMember> members = const [],
    List<TimelineEvent> events = const [],
    List<MediaAsset> assets = const [],
  }) {
    return FamilyData(
      settings: FamilySettings(familyName: familyName),
      members: members,
      timelineEvents: events,
      mediaLibrary: assets,
    );
  }

  test('Payload читает отметки, записанные JSON-строкой', () {
    final payload = FamilySyncPayload(
      data: data(members: [member('papa', 'Папа')]),
      stamps: {'member:papa': 777},
    );

    final restored = FamilySyncPayload.fromJson({
      ...payload.data.toJson(),
      // Ранние версии клиента писали карту отметок строкой — такие документы
      // обязаны читаться, иначе серверные правки молча игнорируются.
      'entityUpdatedAt': jsonEncode(payload.stamps),
      'entityDeletedAt': jsonEncode({'member:mama': 555}),
      'updatedAt': 1,
    });

    expect(restored.stamps['member:papa'], 777);
    expect(restored.tombstones['member:mama'], 555);
  });

  test('Медиатека не сериализует путь к локальному файлу', () {
    final local = MediaAsset(
      id: 'asset-1',
      source: 'hive://media-1',
      localPath: r'C:\Users\user\media\asset-1.jpg',
    );
    final family = data(assets: [local]);

    expect(family.toJson()['mediaLibrary'], isNotEmpty);
    final withPath =
        (family.toJson()['mediaLibrary'] as List).first as Map<String, dynamic>;
    expect(withPath['localPath'], isNotNull);

    final withoutPath =
        (family.toJson(includeLocalMediaPaths: false)['mediaLibrary'] as List)
            .first as Map<String, dynamic>;
    expect(withoutPath.containsKey('localPath'), isFalse);
    expect(withoutPath['source'], 'hive://media-1');
  });

  test('Entities merged by timestamps', () {
    final local = data(
      members: [member('papa', 'Папа (локально)'), member('mama', 'Мама')],
      events: [event('e1', '2020-01-01', 'Событие')],
    );
    final remote = FamilySyncPayload(
      data: data(
        members: [
          member('papa', 'Папа (сервер)'), // старая правка
          member('son', 'Сын'), // новая сущность с сервера
        ],
        events: [event('e2', '2021-05-05', 'Новое событие')],
      ),
      stamps: {
        'member:papa': 100,
        'member:son': 500,
        'event:e2': 400,
      },
    );

    final merged = mergeSyncPayloads(
      local: local,
      localStamps: {'member:papa': 900, 'event:e1': 100},
      remote: remote,
    );

    final names = {for (final m in merged.data.members) m.id: m.name};
    expect(names['papa'], 'Папа (локально)');
    expect(names['son'], 'Сын');
    expect(names['mama'], 'Мама');
    expect(
        merged.data.timelineEvents.map((e) => e.id), containsAll(['e1', 'e2']));
    expect(merged.stamps['member:papa'], 900);
    expect(merged.stamps['member:son'], 500);
  });

  test('Newer remote edit wins', () {
    final merged = mergeSyncPayloads(
      local: data(members: [member('papa', 'Старое')]),
      localStamps: {'member:papa': 10},
      remote: FamilySyncPayload(
        data: data(members: [member('papa', 'Новое')]),
        stamps: {'member:papa': 20},
      ),
    );

    expect(merged.data.members.single.name, 'Новое');
    expect(merged.stamps['member:papa'], 20);
  });

  test('Settings merged by its own timestamp', () {
    final local = data(familyName: 'Локальное имя');
    final remote = FamilySyncPayload(
      data: data(familyName: 'Серверное имя'),
      stamps: {'settings': 50},
    );

    expect(
      mergeSyncPayloads(local: local, localStamps: {}, remote: remote)
          .data
          .settings
          .familyName,
      'Серверное имя',
    );
    expect(
      mergeSyncPayloads(
        local: local,
        localStamps: {'settings': 80},
        remote: remote,
      ).data.settings.familyName,
      'Локальное имя',
    );
  });

  test('Media library merged by id', () {
    final merged = mergeSyncPayloads(
      local: data(assets: [
        asset('a1', downloadUrl: 'local://a1', updatedAt: 30),
      ]),
      localStamps: {'media:a1': 30},
      remote: FamilySyncPayload(
        data: data(assets: [
          asset('a1', downloadUrl: 'https://cdn/a1', updatedAt: 40),
          asset('a2', downloadUrl: 'https://cdn/a2', updatedAt: 40),
        ]),
        stamps: {'media:a1': 40, 'media:a2': 40},
      ),
    );

    final byId = {for (final a in merged.data.mediaLibrary) a.id: a};
    expect(byId.keys, containsAll(['a1', 'a2']));
    expect(byId['a1']!.downloadUrl, 'https://cdn/a1');
  });

  test('Events stay sorted by date after merge', () {
    final merged = mergeSyncPayloads(
      local: data(events: [event('e2', '2022-02-02', 'Позже')]),
      localStamps: {'event:e2': 10},
      remote: FamilySyncPayload(
        data: data(events: [event('e1', '2019-09-09', 'Раньше')]),
        stamps: {'event:e1': 10},
      ),
    );

    expect(merged.data.timelineEvents.map((e) => e.date),
        ['2019-09-09', '2022-02-02']);
  });

  test('Fingerprints change only for edited entity', () {
    final before = entityFingerprints(
      data(members: [member('papa', 'Папа'), member('mama', 'Мама')]),
    );
    final after = entityFingerprints(
      data(members: [member('papa', 'Папа'), member('mama', 'Мамочка')]),
    );

    expect(before['member:papa'], after['member:papa']);
    expect(before['member:mama'], isNot(after['member:mama']));
    expect(before['settings'], after['settings']);
  });

  test('Payload survives JSON round-trip', () {
    final payload = FamilySyncPayload(
      data: data(members: [member('papa', 'Папа')]),
      stamps: {'member:papa': 123},
    );

    final restored = FamilySyncPayload.fromJson({
      ...payload.data.toJson(),
      'entityUpdatedAt': payload.stamps,
      'updatedAt': 1,
    });

    expect(restored.stamps['member:papa'], 123);
    expect(restored.data.members.single.name, 'Папа');
  });

  // Метки времени — мс эпохи, поэтому берём реальное «сейчас»: надгробия
  // старше [tombstoneRetention] намеренно вычищаются при слиянии.
  final now = DateTime.now().millisecondsSinceEpoch;

  test('Remote tombstone removes the entity locally', () {
    final merged = mergeSyncPayloads(
      local: data(
        members: [member('papa', 'Папа'), member('mama', 'Мама')],
        events: [event('e1', '2020-01-01', 'Событие')],
      ),
      localStamps: {
        'member:papa': now - 5000,
        'member:mama': now - 5000,
        'event:e1': now - 5000,
      },
      remote: FamilySyncPayload(
        data: data(),
        tombstones: {'member:mama': now - 1000, 'event:e1': now - 1000},
      ),
    );

    expect(merged.data.members.map((m) => m.id), ['papa']);
    expect(merged.data.timelineEvents, isEmpty);
    expect(merged.tombstones['member:mama'], now - 1000);
  });

  test('Local tombstone is not overridden by an older remote edit', () {
    final merged = mergeSyncPayloads(
      local: data(),
      localStamps: const {},
      localTombstones: {'member:papa': now - 1000},
      remote: FamilySyncPayload(
        data: data(members: [member('papa', 'Папа')]),
        stamps: {'member:papa': now - 5000},
      ),
    );

    expect(merged.data.members, isEmpty);
    expect(merged.tombstones['member:papa'], now - 1000);
  });

  test('Entity re-created after deletion is restored', () {
    final merged = mergeSyncPayloads(
      local: data(),
      localStamps: const {},
      localTombstones: {'member:papa': now - 5000},
      remote: FamilySyncPayload(
        data: data(members: [member('papa', 'Папа снова')]),
        stamps: {'member:papa': now - 1000},
      ),
    );

    expect(merged.data.members.single.name, 'Папа снова');
    expect(merged.tombstones.containsKey('member:papa'), isFalse);
  });

  test('Expired tombstones are pruned', () {
    final merged = mergeSyncPayloads(
      local: data(),
      localStamps: const {},
      localTombstones: {'member:mama': 1},
      remote: FamilySyncPayload(
        data: data(members: [member('papa', 'Папа')]),
        stamps: {'member:papa': now},
      ),
    );

    expect(merged.tombstones, isEmpty);
  });

  test('Tombstones survive payload round-trip', () {
    final payload = FamilySyncPayload.fromJson({
      ...data(members: [member('papa', 'Папа')]).toJson(),
      'entityUpdatedAt': {'member:papa': now},
      'entityDeletedAt': {'member:mama': now},
    });

    expect(payload.stamps['member:papa'], now);
    expect(payload.tombstones['member:mama'], now);
  });

  // Подключение по коду: демо-архив устройства не должен просачиваться в семью.
  test('Unstamped demo entities are dropped when joining a family', () {
    final merged = mergeSyncPayloads(
      local: data(
        familyName: 'Демо-имя',
        members: [member('papa', 'Демо-папа'), member('mama', 'Демо-мама')],
        events: [event('demo-event', '2001-01-01', 'Демо-событие')],
        assets: [asset('demo-asset')],
      ),
      localStamps: const {},
      remote: FamilySyncPayload(
        data: data(
          familyName: 'Наша семья',
          members: [member('papa', 'Папа')],
          events: [event('real-event', '2024-02-02', 'Настоящее событие')],
        ),
        stamps: {
          'settings': now - 3000,
          'member:papa': now - 3000,
          'event:real-event': now - 3000,
        },
      ),
      dropUnstampedLocal: true,
    );

    // Демо-архив заменён серверной копией целиком: ни «мамы», ни демо-события
    // и ни одного демо-файла в семье не остаётся.
    expect(merged.data.members.map((m) => m.id), ['papa']);
    expect(merged.data.members.single.name, 'Папа');
    expect(merged.data.timelineEvents.map((e) => e.id), ['real-event']);
    expect(merged.data.mediaLibrary, isEmpty);
    expect(merged.data.settings.familyName, 'Наша семья');
  });

  test('Local edits with stamps survive while unstamped demo is dropped', () {
    final merged = mergeSyncPayloads(
      local: data(
        members: [
          member('papa', 'Папа (правка телефона)'),
          member('mama', 'Демо')
        ],
        events: [event('local-event', '2023-03-03', 'Своё событие')],
      ),
      localStamps: {'member:papa': now - 1000, 'event:local-event': now - 1000},
      remote: FamilySyncPayload(
        data: data(
          members: [member('papa', 'Папа (сервер)'), member('son', 'Сын')],
          events: [event('real-event', '2024-02-02', 'Настоящее событие')],
        ),
        stamps: {
          'settings': now - 5000,
          'member:papa': now - 5000,
          'member:son': now - 5000,
          'event:real-event': now - 5000,
        },
      ),
      dropUnstampedLocal: true,
    );

    final names = {for (final m in merged.data.members) m.id: m.name};
    expect(names['papa'], 'Папа (правка телефона)');
    expect(names['son'], 'Сын');
    expect(names.containsKey('mama'), isFalse);
    expect(
      merged.data.timelineEvents.map((e) => e.id),
      containsAll(<String>['local-event', 'real-event']),
    );
  });
}
