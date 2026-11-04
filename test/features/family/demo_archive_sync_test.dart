import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/accounts/domain/models/identity_state.dart';
import 'package:ourtree_app/features/accounts/domain/models/user_model.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/identity_provider.dart';
import 'package:ourtree_app/features/family/data/repositories/cloud_family_state_store.dart';
import 'package:ourtree_app/features/family/data/repositories/family_repository.dart';
import 'package:ourtree_app/features/family/domain/family_sync_merge.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/cloud_family_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_sync_provider.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';

/// Хранилище состояния в памяти.
class _MemoryStateStore implements CloudFamilyStateStore {
  _MemoryStateStore(this.payload);

  FamilySyncPayload? payload;
  int pushes = 0;

  @override
  Future<FamilySyncPayload?> pull(String familyId) async => payload;

  @override
  Future<void> push({
    required String familyId,
    required FamilyData data,
    required Map<String, int> stamps,
    required Map<String, int> tombstones,
    required int updatedAt,
    String? writerId,
  }) async {
    pushes++;
    payload = FamilySyncPayload(
      data: data,
      stamps: stamps,
      tombstones: tombstones,
    );
  }
}

class _FakeActiveFamily extends ActiveFamilyController {
  _FakeActiveFamily(this.family);

  final FamilyModel family;

  @override
  Future<FamilyModel?> build() async => family;
}

class _FakeIdentity extends IdentityController {
  @override
  Future<IdentityState> build() async => IdentityState(
        user: UserModel(id: 'user-1', createdAt: 0),
        authUid: 'auth-1',
      );
}

/// Архив читается из Hive — как в настоящем репозитории.
class _StoredFamilyData extends FamilyDataNotifier {
  @override
  Future<FamilyData> build() async {
    final raw = MediaStorage.instance.getString(FamilyRepository.storageKey);
    if (raw == null || raw.trim().isEmpty) return FamilyData.empty;
    return FamilyData.fromJson(
      (jsonDecode(raw) as Map).cast<String, dynamic>(),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final storage = MediaStorage.instance;

  setUp(() async {
    // Даём завершиться отложенным записям предыдущего контейнера, иначе они
    // могут попасть в хранилище уже после очистки.
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await storage.clearForTests();
  });

  final family = FamilyModel.created(
    id: 'family-1',
    name: 'Наша семья',
    ownerUserId: 'user-1',
    ownerAuthUid: 'auth-1',
    now: 1700000000000,
  );

  /// Демо-архив в хранилище: те же id, что и в настоящей семье.
  Future<void> seedDemoArchive() async {
    await storage.putString(
      FamilyRepository.storageKey,
      jsonEncode({
        'familyName': 'Наше древо',
        'familyPhoto': '/photos/demo.jpg',
        'members': [
          {
            'id': 'papa',
            'role': 'Папа',
            'name': 'Артём',
            'birthday': '1985-04-12',
          },
        ],
        'timelineEvents': <dynamic>[],
        'mediaLibrary': [
          {
            'id': 'cover-demo',
            'source': '/photos/demo.jpg',
            'type': 'image',
          },
        ],
      }),
    );
  }

  /// Старые отметки времени демо-сущностей — главная причина «просачивания».
  Future<void> seedStaleStamps(int stamp) async {
    await storage.putString(
      'family_sync_stamps_family-1',
      jsonEncode({
        'stamps': {'member:papa': stamp, 'settings': stamp},
        'tombs': <String, int>{},
      }),
    );
  }

  ProviderContainer createContainer(_MemoryStateStore store) {
    final container = ProviderContainer(
      overrides: [
        activeFamilyControllerProvider
            .overrideWith(() => _FakeActiveFamily(family)),
        identityControllerProvider.overrideWith(_FakeIdentity.new),
        cloudFamilyStateStoreProvider.overrideWithValue(store),
        familyDataProvider.overrideWith(_StoredFamilyData.new),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  FamilySyncPayload remotePayload() => FamilySyncPayload(
        data: FamilyData(
          settings: const FamilySettings(
            familyName: 'Наша семья',
            familyPhoto: '/photos/real.jpg',
          ),
          members: [
            FamilyMember(
              id: 'papa',
              role: 'Папа',
              name: 'ВГ',
              nickname: '',
              birthday: '1980-09-17',
            ),
          ],
          mediaLibrary: [
            const MediaAsset(id: 'cover-real', source: '/photos/real.jpg'),
          ],
        ),
        stamps: const {
          'member:papa': 100,
          'settings': 100,
          'media:cover-real': 100,
        },
      );

  /// Дожидается подключения семьи и построения контроллера синхронизации.
  ///
  /// Без этого `pull` вызывался бы до того, как `build()` прочитает отметки
  /// времени из Hive, и демо-сущности считались бы «без отметок».
  Future<void> warmUp(ProviderContainer container) async {
    await container.read(activeFamilyControllerProvider.future);
    container.read(familySyncControllerProvider);
    await Future<void>.delayed(Duration.zero);
  }

  test('демо-архив целиком заменяется семейным даже при старых отметках',
      () async {
    await seedDemoArchive();
    await seedStaleStamps(DateTime.now().millisecondsSinceEpoch);
    await storage.putString(FamilySyncController.demoArchiveKey, '1');

    final container = createContainer(_MemoryStateStore(remotePayload()));
    await warmUp(container);
    await container
        .read(familySyncControllerProvider.notifier)
        .pull('family-1');

    final data = await container.read(familyDataProvider.future);
    expect(data.memberById('papa')?.name, 'ВГ');
    expect(data.settings.familyPhoto, '/photos/real.jpg');
    expect(data.settings.familyName, 'Наша семья');
    // Демо-маркер снят: архив больше не демонстрационный.
    expect(storage.getString(FamilySyncController.demoArchiveKey), isNull);
  });

  test('без демо-маркера более свежие локальные правки остаются', () async {
    await seedDemoArchive();
    await seedStaleStamps(DateTime.now().millisecondsSinceEpoch);

    final container = createContainer(_MemoryStateStore(remotePayload()));
    await warmUp(container);
    await container
        .read(familySyncControllerProvider.notifier)
        .pull('family-1');

    final data = await container.read(familyDataProvider.future);
    expect(data.memberById('papa')?.name, 'Артём');
  });
}
