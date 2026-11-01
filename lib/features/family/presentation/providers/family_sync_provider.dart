import 'dart:async';
import 'dart:convert';

import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/identity_provider.dart';
import 'package:ourtree_app/features/family/data/repositories/cloud_family_state_store.dart';
import 'package:ourtree_app/features/family/domain/family_sync_merge.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/cloud_family_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/settings/domain/models/sync_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'family_sync_provider.g.dart';

/// Хранилище текстового состояния семьи; подменяется в тестах.
@Riverpod(keepAlive: true)
CloudFamilyStateStore cloudFamilyStateStore(Ref ref) =>
    FirestoreFamilyStateStore();

/// Синхронизация архива с Firestore по сущностям.
///
/// При подключении семьи забираем серверную копию и **сливаем** её с локальной:
/// для каждого человека, события и медиафайла побеждает более свежая отметка
/// времени. Удаления передаются через tombstones (`entityDeletedAt`), поэтому
/// удалённое на телефоне не «воскресает» на планшете.
@Riverpod(keepAlive: true)
class FamilySyncController extends _$FamilySyncController {
  static const Duration pushDebounce = Duration(seconds: 2);
  static const String _metaPrefix = 'family_sync_stamps_';

  /// Ключ-маркер «локальный архив восстановлен из бэкапа».
  ///
  /// Пока семья не подключена, отметок времени у сущностей нет. Без маркера
  /// восстановленный архив при подключении по коду считался бы демо-архивом
  /// и был бы заменён серверной копией.
  static const String restoredArchiveKey = 'family_archive_restored';

  Timer? _debounce;
  String? _familyId;

  /// Данные, которые контроллер только что записал сам (результат серверного
  /// слияния). Их нельзя помечать как локальные правки, иначе следующий push
  /// объявит серверные сущности «своими» и перетрёт чужие изменения.
  ///
  /// Флаг-булево здесь не работает: если записанные данные совпали с уже
  /// имевшимися, слушатель не вызывается и флаг остаётся висеть — тогда
  /// следующее настоящее изменение (например, восстановление из бэкапа)
  /// пропускалось.
  FamilyData? _silentChange;

  /// Отметки времени живущих сущностей (ключ → мс эпохи).
  Map<String, int> _stamps = <String, int>{};

  /// Отметки удаления сущностей (ключ → мс эпохи).
  Map<String, int> _tombstones = <String, int>{};

  /// Отпечатки содержимого: по ним определяем, что именно изменилось.
  Map<String, String> _fingerprints = <String, String>{};

  /// Счётчик локальных записей архива.
  ///
  /// `pull` запоминает его перед сетевым запросом: если за время запроса архив
  /// менялся (восстановление из бэкапа, правка), серверную копию не применяем —
  /// иначе ответ, прочитанный до этих изменений, перетрёт их.
  int _archiveVersion = 0;

  /// Пауза серверного слияния на время восстановления из бэкапа: применять
  /// серверную копию в этот момент нельзя — она перетрёт снимок.
  bool _suspended = false;

  @override
  SyncStatus build() {
    final family = ref.watch(activeFamilyControllerProvider).value;
    if (family == null) {
      // Семья отключена: забываем её метаданные, синхронизация выключена.
      _familyId = null;
      _stamps = <String, int>{};
      _tombstones = <String, int>{};
      _fingerprints = <String, String>{};
      return SyncStatus.saved;
    }

    if (_familyId != family.id) {
      _familyId = family.id;
      _loadMeta(family.id);
      unawaited(Future<void>.microtask(() => pull(family.id)));
    }

    ref.listen(familyDataProvider, (previous, next) {
      final data = next.value;
      if (data == null) return;
      if (previous?.value == data) return;

      _archiveVersion++;

      // Свежее серверное слияние не является правкой пользователя.
      final silent = _silentChange;
      _silentChange = null;
      if (silent != null && silent == data) return;

      _markChanges(data);
      _schedulePush(family.id, data);
    });

    return SyncStatus.saved;
  }

  Future<void> pull(String familyId) async {
    state = SyncStatus.loading;
    // Пока идёт восстановление из бэкапа, серверную копию не применяем.
    if (_suspended) {
      state = SyncStatus.saved;
      return;
    }
    final version = _archiveVersion;
    // Локальный архив запоминаем ДО запроса: если за время запроса он
    // изменится, ответ уже неактуален.
    final localBefore = ref.read(familyDataProvider).value;
    try {
      final remote =
          await ref.read(cloudFamilyStateStoreProvider).pull(familyId);
      var local = localBefore;
      if (local == null) {
        // Архив ещё грузится из Hive: без ожидания слияние пропускалось бы,
        // а демо-данные оставались в подключённой семье.
        try {
          local = await ref.read(familyDataProvider.future);
        } catch (_) {
          local = null;
        }
      }

      if (remote == null) {
        // В облаке ещё нет содержимого. Владелец новой семьи отдаёт свой
        // локальный архив, иначе второму устройству нечего забирать и оно
        // остаётся с демо-архивом.
        if (await _isOwnerOfActiveFamily()) {
          await seedFamily(familyId);
        } else {
          state = SyncStatus.saved;
        }
        return;
      }

      if (local == null) {
        state = SyncStatus.saved;
        return;
      }

      // Архив восстановлен из бэкапа, пока семья не была подключена: считаем
      // его содержимое правками этого устройства, иначе слияние отбросит его
      // как «демо» и серверная копия победит.
      final restoredLocally = _takeRestoredMarker();
      if (restoredLocally) {
        final now = DateTime.now().millisecondsSinceEpoch;
        for (final key in entityFingerprints(local).keys) {
          _stamps[key] = now;
        }
        // Снимок — источник истины: записи, которых в нём нет (например,
        // демо-люди, попавшие в облако старой версией), помечаем удалёнными.
        _tombstoneRemoteOnly(local, remote, now);
      }

      final remoteHasContent = remote.stamps.isNotEmpty ||
          remote.tombstones.isNotEmpty ||
          remote.data.members.isNotEmpty ||
          remote.data.timelineEvents.isNotEmpty ||
          remote.data.mediaLibrary.isNotEmpty;

      final merged = mergeSyncPayloads(
        local: local,
        localStamps: _stamps,
        localTombstones: _tombstones,
        remote: remote,
        // Сущности без локальной отметки — демо-архив или архив другой семьи:
        // при подключении по коду их место занимает серверная копия.
        dropUnstampedLocal: remoteHasContent && _stamps.isEmpty,
      );

      // Пока шёл запрос, архив мог измениться (восстановление из бэкапа,
      // правка): серверную копию не применяем, чтобы не потерять данные.
      final current = ref.read(familyDataProvider).value;
      if (_archiveVersion != version ||
          (current != null && current != local)) {
        state = SyncStatus.saved;
        return;
      }

      _silentChange = merged.data;
      ref.read(familyDataProvider.notifier).replaceData(merged.data);
      _stamps = merged.stamps;
      _tombstones = merged.tombstones;
      _fingerprints = entityFingerprints(merged.data);
      await _saveMeta(familyId);
      // Архив из бэкапа только что получил отметки — выгружаем его сразу,
      // иначе он остался бы только на этом устройстве.
      if (restoredLocally) await _push(familyId, merged.data);
      state = SyncStatus.saved;
    } catch (_) {
      state = SyncStatus.error;
    }
  }

  /// Применяет архив семьи при подключении по коду.
  ///
  /// Не сливает демо-архив: если у устройства ещё нет отметок синхронизации
  /// для этой семьи, локальные люди, события и файлы считаются демо-контентом
  /// и заменяются серверной копией целиком. Если архив восстановлен из
  /// бэкапа (есть маркер [restoredArchiveKey]), выполняется обычное слияние.
  Future<void> adoptFamilyArchive(String familyId) async {
    if (_suspended) return;

    if (_hasRestoredMarker()) {
      await pull(familyId);
      return;
    }

    final remote =
        await ref.read(cloudFamilyStateStoreProvider).pull(familyId);
    if (remote == null) return;

    _debounce?.cancel();
    _familyId = familyId;
    _stamps = Map<String, int>.of(remote.stamps);
    _tombstones = Map<String, int>.of(remote.tombstones);
    _fingerprints = entityFingerprints(remote.data);

    // Серверная копия уже объединена: не помечаем её как локальную правку.
    _silentChange = remote.data;
    ref.read(familyDataProvider.notifier).replaceData(remote.data);
    await _saveMeta(familyId);
    state = SyncStatus.saved;
  }

  bool _hasRestoredMarker() =>
      MediaStorage.instance.getString(restoredArchiveKey) != null;

  /// Загружает локальный архив в только что созданную семью.
  ///
  /// Пока документ `families/{fid}/state/current` не создан, семья в облаке
  /// пуста: второе устройство после подключения по коду показывает свой
  /// демо-архив. Все сущности получают отметку «сейчас» — чтобы более старая
  /// копия с другого устройства не перетёрла их при слиянии.
  Future<void> seedFamily(String familyId) async {
    FamilyData? data;
    try {
      data = await ref.read(familyDataProvider.future);
    } catch (_) {
      return;
    }
    if (data == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final fresh = entityFingerprints(data);

    _debounce?.cancel();
    _familyId = familyId;
    _stamps = {for (final key in fresh.keys) key: now};
    _tombstones = <String, int>{};
    _fingerprints = fresh;
    await _clearRestoredMarker();
    await _saveMeta(familyId);
    await _push(familyId, data);
  }

  /// Снимает и возвращает маркер «архив восстановлен вне семьи».
  bool _takeRestoredMarker() {
    final storage = MediaStorage.instance;
    if (storage.getString(restoredArchiveKey) == null) return false;
    unawaited(storage.removeString(restoredArchiveKey));
    return true;
  }

  Future<void> _clearRestoredMarker() =>
      MediaStorage.instance.removeString(restoredArchiveKey);

  /// Приостанавливает применение серверной копии на время замены архива.
  void beginReplace() => _suspended = true;

  /// Возвращает синхронизацию в обычный режим.
  void endReplace() => _suspended = false;

  /// Помечает весь текущий архив как локальные правки и отправляет его в облако.
  ///
  /// Нужно после восстановления из бэкапа: сущности из снимка не имеют отметок
  /// времени, поэтому без этого они считались бы «чужими» и следующий `pull`
  /// заменил бы их серверной копией (а на других устройствах остался бы
  /// демо-архив).
  Future<void> adoptLocalArchive() async {
    FamilyModel? family;
    try {
      family = await ref.read(activeFamilyControllerProvider.future);
    } catch (_) {
      return;
    }
    if (family == null) return;

    // Снимок — источник истины. Всё, что есть в облаке, но отсутствует в нём
    // (демо-люди, события и файлы, попавшие туда старой версией), помечаем
    // удалённым: иначе следующий pull вернёт их обратно и архивы смешаются.
    try {
      final remote =
          await ref.read(cloudFamilyStateStoreProvider).pull(family.id);
      final data = await ref.read(familyDataProvider.future);
      if (remote != null) {
        _tombstoneRemoteOnly(
          data,
          remote,
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    } catch (_) {
      // Без сети обойдёмся отметками: локальный архив всё равно победит.
    }

    await _stampCurrentArchive(family.id);
  }

  /// Помечает текущий архив своими правками и выгружает его, сохраняя
  /// надгробия: сущности, исчезнувшие при восстановлении снимка, должны
  /// удалиться и на остальных устройствах.
  Future<void> _stampCurrentArchive(String familyId) async {
    FamilyData? data;
    try {
      data = await ref.read(familyDataProvider.future);
    } catch (_) {
      return;
    }
    if (data == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final fresh = entityFingerprints(data);

    _debounce?.cancel();
    _familyId = familyId;
    _stamps = {for (final key in fresh.keys) key: now};
    _fingerprints = fresh;
    // Архив уже отдан семье — маркер «восстановлен вне семьи» больше не нужен.
    await _clearRestoredMarker();
    await _saveMeta(familyId);
    await _push(familyId, data);
  }

  /// Помечает удалёнными серверные сущности, которых нет в локальном архиве.
  void _tombstoneRemoteOnly(
    FamilyData local,
    FamilySyncPayload remote,
    int now,
  ) {
    final localKeys = entityFingerprints(local).keys.toSet();
    final remoteKeys = <String>{
      for (final member in remote.data.members) memberKey(member.id),
      for (final event in remote.data.timelineEvents) eventKey(event.id),
      for (final asset in remote.data.mediaLibrary) mediaKey(asset.id),
    };
    for (final key in remoteKeys) {
      if (!localKeys.contains(key)) _tombstones[key] = now;
    }
  }

  /// Владелец ли этот (анонимный) пользователь для активной семьи.
  Future<bool> _isOwnerOfActiveFamily() async {
    FamilyModel? family;
    try {
      family = await ref.read(activeFamilyControllerProvider.future);
    } catch (_) {
      return false;
    }
    if (family == null) return false;
    try {
      final identity = await ref.read(identityControllerProvider.future);
      return family.ownerAuthUid == identity.authUid;
    } catch (_) {
      return false;
    }
  }

  /// Принудительная отправка (например, кнопка «Синхронизировать»).
  Future<void> pushNow() async {
    final family = ref.read(activeFamilyControllerProvider).value;
    final data = ref.read(familyDataProvider).value;
    if (family == null || data == null) return;
    _debounce?.cancel();
    await _push(family.id, data);
  }

  /// Забывает метаданные семьи: вызывается при отключении и удалении данных.
  ///
  /// Локальный архив остаётся, но отметки стираются — иначе после повторного
  /// подключения той же семьи старые правки «переехали» бы на пустое облако.
  Future<void> forgetFamily(String familyId) async {
    _debounce?.cancel();
    await MediaStorage.instance.removeString('$_metaPrefix$familyId');
    if (_familyId == familyId) {
      _familyId = null;
      _stamps = <String, int>{};
      _tombstones = <String, int>{};
      _fingerprints = <String, String>{};
    }
    state = SyncStatus.saved;
  }

  void _loadMeta(String familyId) {
    final raw = MediaStorage.instance.getString('$_metaPrefix$familyId');
    _stamps = <String, int>{};
    _tombstones = <String, int>{};
    if (raw == null || raw.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      // Новый формат: {'stamps': {...}, 'tombs': {...}}.
      // Старый (v1) — плоская карта отметок; такие данные читаем как stamps.
      if (decoded.containsKey('stamps') || decoded.containsKey('tombs')) {
        _stamps = _toIntMap(decoded['stamps']);
        _tombstones = _toIntMap(decoded['tombs']);
      } else {
        _stamps = _toIntMap(decoded);
      }
    } catch (_) {
      // Битые метаданные не должны мешать синхронизации.
      _stamps = <String, int>{};
      _tombstones = <String, int>{};
    }
  }

  Future<void> _saveMeta(String familyId) => MediaStorage.instance.putString(
        '$_metaPrefix$familyId',
        jsonEncode({'stamps': _stamps, 'tombs': _tombstones}),
      );

  static Map<String, int> _toIntMap(Object? raw) {
    final result = <String, int>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        final value = entry.value;
        if (value is num) result[entry.key.toString()] = value.toInt();
      }
    }
    return result;
  }

  void _markChanges(FamilyData data) {
    final fresh = entityFingerprints(data);
    final now = DateTime.now().millisecondsSinceEpoch;
    var changed = false;

    for (final entry in fresh.entries) {
      if (_fingerprints[entry.key] != entry.value) {
        _stamps[entry.key] = now;
        // Сущность вернулась (правка новее удаления) — метку снимаем.
        _tombstones.remove(entry.key);
        changed = true;
      }
    }
    // Исчезнувшие сущности превращаются в tombstone: так удаление доедет
    // до других устройств и не будет отменено их «старой» копией.
    for (final key in _fingerprints.keys) {
      if (!fresh.containsKey(key)) {
        _tombstones[key] = now;
        _stamps.remove(key);
        changed = true;
      }
    }

    _fingerprints = fresh;
    final familyId = _familyId;
    if (changed && familyId != null) unawaited(_saveMeta(familyId));
  }

  void _schedulePush(String familyId, FamilyData data) {
    _debounce?.cancel();
    _debounce = Timer(pushDebounce, () => unawaited(_push(familyId, data)));
  }

  Future<void> _push(String familyId, FamilyData data) async {
    state = SyncStatus.saving;
    try {
      await ref.read(cloudFamilyStateStoreProvider).push(
            familyId: familyId,
            data: data,
            stamps: _stamps,
            tombstones: _tombstones,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          );
      state = SyncStatus.saved;
    } catch (_) {
      state = SyncStatus.error;
    }
  }
}
