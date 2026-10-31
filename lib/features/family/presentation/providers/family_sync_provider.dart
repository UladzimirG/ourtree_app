import 'dart:async';
import 'dart:convert';

import 'package:ourtree_app/core/media/media_storage.dart';
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

  Timer? _debounce;
  String? _familyId;
  bool _skipNextChange = false;

  /// Отметки времени живущих сущностей (ключ → мс эпохи).
  Map<String, int> _stamps = <String, int>{};

  /// Отметки удаления сущностей (ключ → мс эпохи).
  Map<String, int> _tombstones = <String, int>{};

  /// Отпечатки содержимого: по ним определяем, что именно изменилось.
  Map<String, String> _fingerprints = <String, String>{};

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
      if (_skipNextChange) {
        _skipNextChange = false;
        return;
      }
      _markChanges(data);
      _schedulePush(family.id, data);
    });

    return SyncStatus.saved;
  }

  Future<void> pull(String familyId) async {
    state = SyncStatus.loading;
    try {
      final remote =
          await ref.read(cloudFamilyStateStoreProvider).pull(familyId);
      final local = ref.read(familyDataProvider).value;
      if (remote == null || local == null) {
        state = SyncStatus.saved;
        return;
      }

      final merged = mergeSyncPayloads(
        local: local,
        localStamps: _stamps,
        localTombstones: _tombstones,
        remote: remote,
      );

      _skipNextChange = true;
      ref.read(familyDataProvider.notifier).replaceData(merged.data);
      _stamps = merged.stamps;
      _tombstones = merged.tombstones;
      _fingerprints = entityFingerprints(merged.data);
      await _saveMeta(familyId);
      state = SyncStatus.saved;
    } catch (_) {
      state = SyncStatus.error;
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
