import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/storage/app_migrations.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/family/data/repositories/family_repository.dart';
import 'package:ourtree_app/features/family/domain/family_sync_merge.dart';

/// UUID v4: `xxxxxxxx-xxxx-4xxx-[89ab]xxx-xxxxxxxxxxxx`.
final RegExp _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  final storage = MediaStorage.instance;

  /// До версии схемы 2 архив лежал в языковом ключе — его и проверяет v1.
  final legacyFamilyKey = FamilyRepository.legacyStorageKeyFor('ru');

  setUp(() async {
    await storage.clearForTests();
  });

  List<Map<String, dynamic>> readAccounts() {
    final raw = storage.getString(accountsStorageKey);
    if (raw == null) return const <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const <Map<String, dynamic>>[];
    return [
      for (final item in decoded)
        if (item is Map) item.cast<String, dynamic>(),
    ];
  }

  Map<String, dynamic> readFamily() {
    final raw = storage.getString(FamilyRepository.storageKey);
    return (jsonDecode(raw!) as Map).cast<String, dynamic>();
  }

  Future<void> seedLegacyData() async {
    await storage.putString(
      accountsStorageKey,
      jsonEncode([
        {
          'id': 'account-1712345678901234',
          'login': 'mama',
          'name': 'Mama',
          'role': 'admin',
          'createdAt': 1712345678901,
        },
        {
          'id': 'account-1712345678901999',
          'login': 'papa',
          'name': 'Papa',
          'role': 'viewer',
        },
      ]),
    );
    await storage.putString(
      currentAccountStorageKey,
      'account-1712345678901999',
    );
    await storage.putString(
      legacyFamilyKey,
      jsonEncode({
        'familyName': 'Семья',
        'members': <dynamic>[],
        'timelineEvents': [
          {
            'id': 'event-1',
            'title': 'Поездка',
            'hiddenFrom': ['account-1712345678901234'],
          },
          {
            'id': 'event-2',
            'title': 'Ужин',
          },
        ],
      }),
    );
  }

  group('AppMigrations v0 → v1', () {
    test('replaces legacy account ids with UUID v4 and keeps legacyId',
        () async {
      await seedLegacyData();

      expect(await AppMigrations().run(), isTrue);

      final accounts = readAccounts();
      expect(accounts, hasLength(2));
      for (final account in accounts) {
        expect(account['id'], matches(_uuidV4));
        expect(account['legacyId'], startsWith('account-'));
      }
      expect(accounts.first['login'], 'mama');
      expect(accounts.last['role'], 'viewer');
    });

    test('rewrites the active account id', () async {
      await seedLegacyData();

      await AppMigrations().run();

      final currentId = storage.getString(currentAccountStorageKey);
      expect(currentId, matches(_uuidV4));
      expect(
        readAccounts().map((account) => account['id']),
        contains(currentId),
      );
    });

    test('remaps account ids inside timeline event hiddenFrom', () async {
      await seedLegacyData();

      await AppMigrations().run();

      final mamaId = readAccounts()
          .firstWhere((account) => account['login'] == 'mama')['id'];
      final events = readFamily()['timelineEvents'] as List;

      expect((events.first as Map)['hiddenFrom'], [mamaId]);
      expect((events.last as Map).containsKey('hiddenFrom'), isFalse);
    });

    test('is idempotent', () async {
      await seedLegacyData();
      final migrations = AppMigrations();

      expect(await migrations.run(), isTrue);
      final firstAccounts = storage.getString(accountsStorageKey);

      expect(await migrations.run(), isFalse);
      expect(storage.getString(accountsStorageKey), firstAccounts);
      expect(
        storage.getString(storageSchemaVersionKey),
        '$currentStorageSchemaVersion',
      );
    });

    test('creates a backup before changing anything', () async {
      await seedLegacyData();

      await AppMigrations().run();

      expect(
        storage.backupNames().where((name) => name.startsWith('schema-v0-')),
        isNotEmpty,
      );
    });

    test('does not throw on a broken accounts payload', () async {
      await storage.putString(accountsStorageKey, 'not a json');

      await expectLater(AppMigrations().run(), completes);
      expect(
        storage.getString(storageSchemaVersionKey),
        '$currentStorageSchemaVersion',
      );
    });
  });

  group('AppMigrations v2 to v3', () {
    Future<void> seedArchive(Map<String, dynamic> archive) async {
      await storage.putString(storageSchemaVersionKey, '2');
      await storage.putString(
        FamilyRepository.storageKey,
        jsonEncode(archive),
      );
    }

    Map<String, dynamic> archiveWith(List<Map<String, dynamic>> events) => {
          'familyName': 'Наша семья',
          'members': [
            {
              'id': 'child-4',
              'role': 'Дочь',
              'name': 'Марианна',
              'gallery': [
                {
                  'media': [
                    {
                      'id': 'media-1',
                      'source': '/photos/media-1.jpg',
                      'eventIds': ['birth-danya', 'event-keep'],
                    },
                  ],
                },
              ],
            },
          ],
          'timelineEvents': events,
        };

    test('удаляет демо-событие рождения и его связи', () async {
      await seedArchive(
        archiveWith([
          {
            'id': 'birth-danya',
            'date': '2018-09-27',
            'title': 'Рождение Даниила',
            'kind': 'birth',
            'memberId': 'child-4',
          },
          {
            'id': 'event-keep',
            'date': '2020-01-01',
            'title': 'Поездка',
            'kind': 'trip',
          },
        ]),
      );

      expect(await AppMigrations().run(), isTrue);

      final events = readFamily()['timelineEvents'] as List;
      expect(events.map((event) => (event as Map)['id']), ['event-keep']);

      final media =
          ((readFamily()['members'] as List).first as Map)['gallery'] as List;
      final eventIds =
          ((media.first as Map)['media'] as List).first['eventIds'];
      expect(eventIds, ['event-keep']);
    });

    test('запоминает удаление для отправки в облако', () async {
      await seedArchive(
        archiveWith([
          {
            'id': 'birth-danya',
            'date': '2018-09-27',
            'title': 'Рождение Даниила',
            'kind': 'birth',
            'memberId': 'child-4',
          },
        ]),
      );

      await AppMigrations().run();

      final raw = storage.getString(pendingTombstonesStorageKey);
      expect(raw, isNotNull);
      expect(
        (jsonDecode(raw!) as Map)['event:birth-danya'],
        isA<int>(),
      );
    });

    test('не трогает отредактированное событие с тем же id', () async {
      await seedArchive(
        archiveWith([
          {
            'id': 'birth-danya',
            'date': '2019-01-01',
            'title': 'Рождение сына',
            'kind': 'birth',
            'memberId': 'child-4',
          },
        ]),
      );

      await AppMigrations().run();

      final events = readFamily()['timelineEvents'] as List;
      expect(events, hasLength(1));
    });

    test('оставляет события текущего демо-архива', () async {
      await seedArchive(
        archiveWith([
          {
            'id': 'birth-masha',
            'date': '2013-06-21',
            'title': 'Родилась Маша',
            'kind': 'birth',
            'memberId': 'masha',
          },
        ]),
      );

      await AppMigrations().run();

      expect((readFamily()['timelineEvents'] as List), hasLength(1));
      expect(storage.getString(pendingTombstonesStorageKey), isNull);
    });

    test('повторный запуск ничего не меняет', () async {
      await seedArchive(
        archiveWith([
          {
            'id': 'birth-danya',
            'date': '2018-09-27',
            'title': 'Рождение Даниила',
            'kind': 'birth',
            'memberId': 'child-4',
          },
        ]),
      );

      final migrations = AppMigrations();
      expect(await migrations.run(), isTrue);
      final first = storage.getString(FamilyRepository.storageKey);

      expect(await migrations.run(), isFalse);
      expect(storage.getString(FamilyRepository.storageKey), first);
    });
  });

  group('AppMigrations v1 to v2', () {
    test('переносит архив в единый ключ и удаляет языковые', () async {
      await seedLegacyData();

      await AppMigrations().run();

      expect(storage.getString(FamilyRepository.storageKey), isNotNull);
      for (final localeName in FamilyRepository.demoArchives.keys) {
        expect(
          storage.getString(
            FamilyRepository.legacyStorageKeyFor(localeName),
          ),
          isNull,
        );
      }
    });
  });
}
