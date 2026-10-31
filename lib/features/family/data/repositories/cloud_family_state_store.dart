import 'dart:convert';

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
  });
}

/// Реализация поверх Cloud Firestore.
class FirestoreFamilyStateStore implements CloudFamilyStateStore {
  FirestoreFamilyStateStore({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String stateCollection = 'state';
  static const String stateDocument = 'current';
  static const int schemaVersion = 1;

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
  }) {
    // updatedAt обязателен: правило `freshTimestamp()` сверяет его с временем
    // сервера, чтобы клиент не мог «перебить» чужие правки старой датой.
    return _doc(familyId).set({
      ...data.toJson(),
      'entityUpdatedAt': jsonEncode(stamps),
      'entityDeletedAt': jsonEncode(tombstones),
      'updatedAt': updatedAt,
      'schemaVersion': schemaVersion,
    });
  }
}
