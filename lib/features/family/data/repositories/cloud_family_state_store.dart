import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ourtree_app/features/family/domain/family_sync_merge.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';

/// Текстовая синхронизация архива (люди, события, медиатека).
///
/// Архив лежит одним документом `families/{fid}/state/current`, но каждая
/// сущность имеет собственную отметку времени в `entityUpdatedAt` — поэтому
/// слияние идёт **по сущностям**, а не «весь архив целиком».
abstract class CloudFamilyStateStore {
  Future<FamilySyncPayload?> pull(String familyId);

  Future<void> push({
    required String familyId,
    required FamilyData data,
    required Map<String, int> stamps,
    required Map<String, int> tombstones,
    required int updatedAt,
    String? writerId,
  });
}

/// Хранилище, которое умеет отдавать поток изменений документа состояния.
///
/// Отдельный интерфейс (а не метод в [CloudFamilyStateStore]), чтобы тестовые
/// дублёры не обязаны были его реализовывать: синхронизация подписывается на
/// поток только при наличии этой возможности.
abstract interface class WatchableCloudFamilyStateStore {
  /// Поток серверных версий архива: нужен, чтобы правки с другого устройства
  /// доезжали без перезапуска приложения.
  Stream<FamilySyncPayload?> watch(String familyId);
}

/// Реализация поверх Cloud Firestore.
class FirestoreFamilyStateStore
    implements CloudFamilyStateStore, WatchableCloudFamilyStateStore {
  FirestoreFamilyStateStore({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String stateCollection = 'state';
  static const String stateDocument = 'current';
  static const int schemaVersion = 2;

  DocumentReference<Map<String, dynamic>> _doc(String familyId) => _db
      .collection('families')
      .doc(familyId)
      .collection(stateCollection)
      .doc(stateDocument);

  @override
  Future<FamilySyncPayload?> pull(String familyId) async {
    final snapshot = await _doc(familyId).get();
    final data = snapshot.data();
    if (data == null) return null;
    return FamilySyncPayload.fromJson(data);
  }

  @override
  Future<void> push({
    required String familyId,
    required FamilyData data,
    required Map<String, int> stamps,
    required Map<String, int> tombstones,
    required int updatedAt,
    String? writerId,
  }) async {
    final doc = _doc(familyId);

    // Сливаем с тем, что уже лежит в облаке: два устройства могли править
    // разные сущности, и запись «как есть» затёрла бы чужие изменения.
    FamilySyncPayload? remote;
    try {
      final snapshot = await doc.get();
      final raw = snapshot.data();
      if (raw != null) remote = FamilySyncPayload.fromJson(raw);
    } catch (_) {
      // Офлайн: пишем локальную версию, слияние произойдёт при следующем pull.
    }

    final outgoing = remote == null
        ? FamilySyncPayload(
            data: data,
            stamps: stamps,
            tombstones: tombstones,
          )
        : mergeSyncPayloads(
            local: data,
            localStamps: stamps,
            localTombstones: tombstones,
            remote: remote,
          );

    // updatedAt обязателен: правило `freshTimestamp()` сверяет его с временем
    // сервера, чтобы клиент не мог «перебить» чужие правки старой датой.
    await doc.set({
      // Пути к файлам на этом устройстве в облако не уезжают.
      ...outgoing.data.toJson(includeLocalMediaPaths: false),
      // Отметки пишем картой: строковый JSON ранних версий клиент читать
      // умеет, но сам больше так не пишет.
      'entityUpdatedAt': outgoing.stamps,
      'entityDeletedAt': outgoing.tombstones,
      'updatedAt': updatedAt,
      'schemaVersion': schemaVersion,
      // Кто записал: Cloud Function не шлёт пуш тому же устройству.
      if (writerId != null && writerId.isNotEmpty) 'writerId': writerId,
    });
  }

  @override
  Stream<FamilySyncPayload?> watch(String familyId) =>
      _doc(familyId).snapshots().map((snapshot) {
        final data = snapshot.data();
        return data == null ? null : FamilySyncPayload.fromJson(data);
      });
}
