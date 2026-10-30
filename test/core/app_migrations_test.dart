import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/storage/app_migrations.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/family/data/repositories/family_repository.dart';

/// UUID v4: `xxxxxxxx-xxxx-4xxx-[89ab]xxx-xxxxxxxxxxxx`.
final RegExp _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  final storage = MediaStorage.instance;
  final familyKey = FamilyRepository.storageKeyFor('ru');

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
    final raw = storage.getString(familyKey);
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
      familyKey,
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
}
