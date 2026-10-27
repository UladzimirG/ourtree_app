import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/accounts/domain/models/accounts_models.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';
import 'package:ourtree_app/features/settings/presentation/providers/backup_provider.dart';

/// Подменяет загрузку ассета: тестам нужен предсказуемый архив без I/O.
class _FakeFamilyDataNotifier extends FamilyDataNotifier {
  @override
  Future<FamilyData> build() async => FamilyData.empty;
}

void main() {
  late ProviderContainer container;

  setUp(() async {
    await MediaStorage.instance.clearForTests();
    container = ProviderContainer(
      overrides: [
        familyDataProvider.overrideWith(_FakeFamilyDataNotifier.new),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Future<BackupsNotifier> backups() async {
    await container.read(familyDataProvider.future);
    await container.read(backupsNotifierProvider.future);
    return container.read(backupsNotifierProvider.notifier);
  }

  FamilyMember member(String id) => FamilyMember(
        id: id,
        role: 'Член семьи',
        name: id,
        nickname: '',
        birthday: '2000-01-01',
      );

  group('BackupsNotifier', () {
    test('creates a snapshot with a size and total', () async {
      final notifier = await backups();

      final entry = await notifier.create();

      expect(entry, isNotNull);
      expect(entry!.revision, 1);
      expect(entry.size, greaterThan(0));
      final list = container.read(backupsNotifierProvider).value!;
      expect(list.backups, hasLength(1));
      expect(list.totalSize, entry.size);
      expect(list.dirExists, isTrue);
    });

    test('throttles automatic snapshots but not manual ones', () async {
      final notifier = await backups();

      final first = await notifier.create(automatic: true);
      final second = await notifier.create(automatic: true);
      final manual = await notifier.create();

      expect(first, isNotNull);
      expect(second, isNull);
      expect(manual, isNotNull);
      expect(
        container.read(backupsNotifierProvider).value!.backups,
        hasLength(2),
      );
    });

    test('restore rolls family data back to the snapshot', () async {
      final notifier = await backups();
      final family = container.read(familyDataProvider.notifier);
      final snapshot = await notifier.create();
      family.addMember(member('member-1'));
      expect(container.read(familyDataProvider).value!.members, hasLength(1));

      final restored = await notifier.restore(snapshot!.name);

      expect(restored, isTrue);
      expect(container.read(familyDataProvider).value!.members, isEmpty);
    });

    test('restore returns false for an unknown snapshot', () async {
      final notifier = await backups();

      expect(await notifier.restore('missing.json'), isFalse);
    });

    test('snapshot keeps media bytes and restore brings them back', () async {
      final notifier = await backups();
      final storedId = 'stored-media-1';
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      await MediaStorage.instance.putBytes(storedId, bytes);

      container.read(familyDataProvider.notifier).replaceData(
            FamilyData(
              settings: const FamilySettings(familyName: 'Family'),
              mediaLibrary: [
                MediaAsset(
                  id: 'asset-1',
                  source: 'hive://$storedId',
                  size: bytes.length,
                ),
              ],
            ),
          );
      final snapshot = await notifier.create();
      expect(snapshot, isNotNull);

      await MediaStorage.instance.deleteBytes(storedId);
      expect(await MediaStorage.instance.loadBytes(storedId), isNull);

      expect(await notifier.restore(snapshot!.name), isTrue);
      expect(await MediaStorage.instance.loadBytes(storedId), bytes);
    });

    test('export contains data and media; import restores it', () async {
      final notifier = await backups();
      const storedId = 'stored-media-export';
      final bytes = Uint8List.fromList([10, 20, 30]);
      await MediaStorage.instance.putBytes(storedId, bytes);
      container.read(familyDataProvider.notifier).replaceData(
            FamilyData(
              settings: const FamilySettings(familyName: 'Family'),
              mediaLibrary: [
                MediaAsset(
                  id: 'asset-export',
                  source: 'hive://$storedId',
                  size: bytes.length,
                ),
              ],
            ),
          );

      final export = await notifier.createExport(includeMedia: true);
      expect(export, isNotNull);
      final decoded =
          jsonDecode(utf8.decode(export!.bytes)) as Map<String, dynamic>;
      expect(decoded['format'], 'ourtree-backup');
      expect(decoded['data'], isA<Map>());
      expect((decoded['media'] as Map)[storedId], isNotNull);
      expect(export.entry.size, greaterThan(0));

      container.read(familyDataProvider.notifier).addMember(
            const FamilyMember(
              id: 'temp',
              role: 'Роль',
              name: 'Temp',
              nickname: '',
              birthday: '2000-01-01',
            ),
          );
      expect(container.read(familyDataProvider).value!.members, hasLength(1));

      expect(await notifier.importBytes(export.bytes), isTrue);
      expect(container.read(familyDataProvider).value!.members, isEmpty);
    });

    test('import restores bundled assets into Hive and rewrites links', () async {
      final notifier = await backups();
      final payload = {
        'format': 'ourtree-backup',
        'version': 1,
        'includeMedia': true,
        'data': FamilyData(
          settings: const FamilySettings(familyName: 'Family'),
          members: [
            const FamilyMember(
              id: 'papa',
              role: 'Папа',
              name: 'Papa',
              nickname: '',
              birthday: '1980-01-01',
              photo: '/photos/legacy.jpg',
            ),
          ],
        ).toJson(),
        'assets': {
          '/photos/legacy.jpg': base64Encode([9, 8, 7]),
        },
      };

      expect(await notifier.importBytes(Uint8List.fromList(utf8.encode(
        jsonEncode(payload),
      ))), isTrue);

      final source =
          container.read(familyDataProvider).value!.members.single.photo!;
      expect(source, startsWith('hive://'));
      final storedId = source.substring('hive://'.length);
      expect(
        await MediaStorage.instance.loadBytes(storedId),
        Uint8List.fromList([9, 8, 7]),
      );
    });

    test('import restores accounts with a working password hash', () async {
      final notifier = await backups();
      await container.read(accountsNotifierProvider.future);
      final accounts = container.read(accountsNotifierProvider.notifier);
      accounts.create(
        const AccountInput(
          login: 'grandma',
          name: 'Grandma',
          password: 'secret',
          role: UserRole.editor,
        ),
      );

      final export = await notifier.createExport(includeMedia: false);
      accounts.replaceAll(const []);
      expect(container.read(accountsNotifierProvider).value, isEmpty);

      expect(await notifier.importBytes(export!.bytes), isTrue);
      final restored = container.read(accountsNotifierProvider).value!.single;
      expect(restored.login, 'grandma');
      expect(
        accounts.authenticate('grandma', 'secret')?.id,
        restored.id,
      );
    });

    test('delete removes only the chosen snapshot', () async {
      final notifier = await backups();
      final first = await notifier.create();
      final second = await notifier.create();

      await notifier.delete(first!.name);

      final list = container.read(backupsNotifierProvider).value!;
      expect(list.backups, hasLength(1));
      expect(list.backups.single.name, second!.name);
      expect(list.totalSize, second.size);
    });
  });
}
