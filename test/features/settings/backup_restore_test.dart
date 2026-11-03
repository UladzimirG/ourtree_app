import 'dart:convert';
import 'dart:typed_data';

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
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';
import 'package:ourtree_app/features/settings/presentation/providers/backup_provider.dart';

/// Хранилище состояния семьи в памяти: фиксирует последний `push`.
class _MemoryStateStore implements CloudFamilyStateStore {
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

/// Архив из локального хранилища — как у настоящего репозитория.
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

/// Режим «семья ещё не подключена».
class _NoFamily extends ActiveFamilyController {
  @override
  Future<FamilyModel?> build() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Каждый тест начинает с чистого хранилища: иначе архив предыдущего теста
    // влияет на следующий (ключ архива теперь один на все языки).
    await MediaStorage.instance.clearForTests();
  });

  final family = FamilyModel.created(
    id: 'family-1',
    name: 'Наша семья',
    ownerUserId: 'user-1',
    ownerAuthUid: 'auth-1',
    now: 1700000000000,
  );

  final photoBytes = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);

  Map<String, dynamic> backupBundle() => <String, dynamic>{
        'format': 'ourtree-backup',
        'version': 1,
        'includeMedia': true,
        'entry': <String, dynamic>{
          'name': 'family-1-1.json',
          'savedAt': 1,
          'revision': 1,
          'size': 1,
        },
        'data': <String, dynamic>{
          'familyName': 'Семья из бэкапа',
          'members': <dynamic>[
            <String, dynamic>{
              'id': 'papa',
              'role': 'Папа',
              'name': 'ВГ',
              'photo': '/photos/own.jpg',
            },
          ],
          'timelineEvents': <dynamic>[
            <String, dynamic>{
              'id': 'event-1',
              'date': '2020-01-01',
              'title': 'Своё событие',
              'photo': '/photos/own.jpg',
            },
          ],
          'mediaLibrary': <dynamic>[
            <String, dynamic>{
              'id': 'asset-1',
              'source': '/photos/own.jpg',
              'type': 'image',
              'name': 'own.jpg',
            },
          ],
        },
        'media': <String, dynamic>{},
        'assets': <String, dynamic>{
          '/photos/own.jpg': base64Encode(photoBytes),
        },
        'accounts': <dynamic>[],
        'guestLinks': <dynamic>[],
      };

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

  /// Контейнер в режиме «семья не подключена» (демо).
  ProviderContainer createDemoContainer(_MemoryStateStore store) {
    final container = ProviderContainer(
      overrides: [
        activeFamilyControllerProvider.overrideWith(_NoFamily.new),
        identityControllerProvider.overrideWith(_FakeIdentity.new),
        cloudFamilyStateStoreProvider.overrideWithValue(store),
        familyDataProvider.overrideWith(_StoredFamilyData.new),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('бэкап восстанавливается и выгружается в облако', () async {
    final store = _MemoryStateStore();
    final container = createContainer(store);
    await container.read(familyDataProvider.future);

    final imported = await container.read(backupsProvider.notifier).importBytes(
          Uint8List.fromList(utf8.encode(jsonEncode(backupBundle()))),
        );

    expect(imported, isTrue);

    final data = container.read(familyDataProvider).value!;
    expect(data.familyName, 'Семья из бэкапа');
    expect(data.settings.nameIsCustom, isTrue);
    expect(data.members.single.name, 'ВГ');
    expect(data.timelineEvents.single.title, 'Своё событие');

    // Файл из снимка переехал в локальное хранилище, ссылка переписана.
    final photo = data.members.single.photo!;
    expect(photo, startsWith('hive://'));
    final bytes = await MediaStorage.instance
        .loadBytes(photo.substring('hive://'.length));
    expect(bytes, photoBytes);

    // Архив ушёл в облако вместе с отметками времени.
    final pushed = store.payload;
    expect(pushed, isNotNull);
    expect(pushed!.data.members.single.name, 'ВГ');
    expect(pushed.stamps.containsKey('member:papa'), isTrue);
    expect(pushed.data.mediaLibrary.single.downloadUrl, isNull);
  });

  test('серверный демо-архив не возвращается после восстановления', () async {
    final store = _MemoryStateStore();
    final container = createContainer(store);
    await container.read(familyDataProvider.future);

    await container.read(backupsProvider.notifier).importBytes(
          Uint8List.fromList(utf8.encode(jsonEncode(backupBundle()))),
        );

    // В облаке «старый» демо-архив: следующий pull не должен его применить.
    store.payload = FamilySyncPayload(
      data: FamilyData(
        settings: const FamilySettings(familyName: 'Демо'),
        members: const <FamilyMember>[
          FamilyMember(
            id: 'papa',
            role: 'Роль',
            name: 'Демо-папа',
            nickname: '',
            birthday: '2000-01-01',
            photo: '/photos/media-023_portrait.jpg',
          ),
        ],
      ),
      stamps: const <String, int>{'settings': 1, 'member:papa': 1},
    );

    await container
        .read(familySyncControllerProvider.notifier)
        .pull('family-1');

    final data = container.read(familyDataProvider).value!;
    expect(data.familyName, 'Семья из бэкапа');
    expect(data.members.single.name, 'ВГ');
    expect(data.members.single.photo, startsWith('hive://'));
  });

  test('бэкап, восстановленный до подключения семьи, уезжает в облако',
      () async {
    final store = _MemoryStateStore();

    // 1. Демо-режим: восстанавливаем бэкап.
    final demo = createDemoContainer(store);
    await demo.read(familyDataProvider.future);
    final imported = await demo.read(backupsProvider.notifier).importBytes(
          Uint8List.fromList(utf8.encode(jsonEncode(backupBundle()))),
        );
    expect(imported, isTrue);
    expect(
      MediaStorage.instance.getString(FamilySyncController.restoredArchiveKey),
      '1',
    );

    // 2. Подключение к семье, в облаке пока демо-архив.
    final joined = createContainer(store);
    await joined.read(familyDataProvider.future);
    store.payload = FamilySyncPayload(
      data: FamilyData(
        settings: const FamilySettings(familyName: 'Демо'),
        members: const <FamilyMember>[
          FamilyMember(
            id: 'papa',
            role: 'Роль',
            name: 'Демо-папа',
            nickname: '',
            birthday: '2000-01-01',
          ),
        ],
      ),
      stamps: const <String, int>{'settings': 1, 'member:papa': 1},
    );

    await joined.read(familySyncControllerProvider.notifier).pull('family-1');

    final data = joined.read(familyDataProvider).value!;
    expect(data.members.single.name, 'ВГ');
    // Восстановленный архив победил и ушёл на сервер.
    expect(store.payload!.data.members.single.name, 'ВГ');
    expect(store.payload!.stamps.containsKey('member:papa'), isTrue);
  });

  test('снимок удаляет из облака лишние (демо) записи', () async {
    final store = _MemoryStateStore();
    final container = createContainer(store);
    await container.read(familyDataProvider.future);

    // В облаке — смесь: «папа» и лишняя демо-«мама».
    store.payload = FamilySyncPayload(
      data: FamilyData(
        settings: const FamilySettings(familyName: 'Демо'),
        members: const <FamilyMember>[
          FamilyMember(
            id: 'papa',
            role: 'Роль',
            name: 'Демо-папа',
            nickname: '',
            birthday: '2000-01-01',
          ),
          FamilyMember(
            id: 'mama',
            role: 'Роль',
            name: 'Демо-мама',
            nickname: '',
            birthday: '2000-01-01',
          ),
        ],
      ),
      stamps: const <String, int>{
        'settings': 1,
        'member:papa': 1,
        'member:mama': 1
      },
    );
    await container
        .read(familySyncControllerProvider.notifier)
        .pull('family-1');
    expect(
      container.read(familyDataProvider).value!.members.map((m) => m.id),
      containsAll(<String>['papa', 'mama']),
    );

    // Восстанавливаем снимок, где «мамы» нет: она должна исчезнуть и в облаке.
    final imported = await container.read(backupsProvider.notifier).importBytes(
          Uint8List.fromList(utf8.encode(jsonEncode(backupBundle()))),
        );
    expect(imported, isTrue);

    final data = container.read(familyDataProvider).value!;
    expect(data.members.map((m) => m.id), <String>['papa']);
    expect(store.payload!.data.members.map((m) => m.id), <String>['papa']);
    expect(store.payload!.tombstones.containsKey('member:mama'), isTrue);
  });

  test('снимок сохраняет кадрирование и не зависит от языка', () async {
    final store = _MemoryStateStore();
    final container = createDemoContainer(store);
    await container.read(familyDataProvider.future);

    final bundle = backupBundle();
    final data = bundle['data'] as Map<String, dynamic>;
    data['familyPhoto'] = '/photos/own.jpg';
    data['familyPhotoPosition'] = <String, dynamic>{'x': 12.0, 'y': 88.0};
    data['familyPhotoZoom'] = 2.5;
    data['familySubtitle'] = 'Подзаголовок из снимка';
    (data['members'] as List).first.addAll(<String, dynamic>{
      'photoPosition': <String, dynamic>{'x': 30.0, 'y': 70.0},
      'photoZoom': 1.75,
    });
    (data['timelineEvents'] as List).first.addAll(<String, dynamic>{
      'photoPosition': <String, dynamic>{'x': 20.0, 'y': 60.0},
      'photoZoom': 3.2,
    });

    final imported = await container
        .read(backupsProvider.notifier)
        .importBytes(Uint8List.fromList(utf8.encode(jsonEncode(bundle))));
    expect(imported, isTrue);

    final restored = container.read(familyDataProvider).value!;
    // Кадрирование всех снимков возвращается вместе с архивом.
    expect(
      restored.settings.familyPhotoPosition,
      const PhotoPosition(x: 12, y: 88),
    );
    expect(restored.settings.familyPhotoZoom, 2.5);
    expect(
      restored.members.single.photoPosition,
      const PhotoPosition(x: 30, y: 70),
    );
    expect(restored.members.single.photoZoom, 1.75);
    expect(
      restored.timelineEvents.single.photoPosition,
      const PhotoPosition(x: 20, y: 60),
    );
    expect(restored.timelineEvents.single.photoZoom, 3.2);

    // Тексты снимка не перекрываются демо-архивом языка.
    expect(restored.settings.nameIsCustom, isTrue);
    expect(restored.settings.subtitleIsCustom, isTrue);
    expect(restored.settings.familySubtitle, 'Подзаголовок из снимка');

    // Архив лежит в едином ключе, а не в языковом.
    expect(
      MediaStorage.instance.getString(FamilyRepository.storageKey),
      isNotNull,
    );
    expect(MediaStorage.instance.getString('family_data_en'), isNull);
    expect(MediaStorage.instance.getString('family_data_ru'), isNull);

    // Новый контейнер (перезапуск или другой язык) видит тот же кадр.
    final reopened = createDemoContainer(store);
    final loaded = await reopened.read(familyDataProvider.future);
    expect(
      loaded.members.single.photoPosition,
      const PhotoPosition(x: 30, y: 70),
    );
    expect(loaded.members.single.photoZoom, 1.75);
    expect(loaded.settings.familyPhotoZoom, 2.5);
  });
}
