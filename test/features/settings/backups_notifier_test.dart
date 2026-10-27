import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
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
