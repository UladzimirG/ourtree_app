import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ourtree_app/core/utils/ids.dart';
import 'package:ourtree_app/features/family/domain/models/family_membership.dart';
import 'package:ourtree_app/features/family/domain/models/family_model.dart';

/// Хранилище семьи в облаке (абстракция для тестов и для будущего REST-канала).
abstract class CloudFamilyStore {
  /// Создаёт семью и документ владельца.
  Future<FamilyModel> create({
    required String userId,
    required String authUid,
    required String name,
  });

  Future<FamilyModel?> find(String familyId);

  /// Поток изменений документа семьи (для будущего sync-движка).
  Stream<FamilyModel?> watch(String familyId);
}

/// Реализация поверх Cloud Firestore.
class FirestoreCloudFamilyStore implements CloudFamilyStore {
  FirestoreCloudFamilyStore({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String familiesCollection = 'families';
  static const String membersCollection = 'members';

  CollectionReference<Map<String, dynamic>> get _families =>
      _db.collection(familiesCollection);

  @override
  Future<FamilyModel> create({
    required String userId,
    required String authUid,
    required String name,
  }) async {
    final familyId = newFamilyId();
    final now = DateTime.now().millisecondsSinceEpoch;
    final family = FamilyModel.created(
      id: familyId,
      name: name,
      ownerUserId: userId,
      ownerAuthUid: authUid,
      now: now,
    );
    final membership = FamilyMembership.owner(
      userId: userId,
      authUid: authUid,
      now: now,
    );

    // Две записи строго по порядку: правила проверяют членство по документу
    // семьи, а внутри batch этот документ ещё не существует (get() не видит
    // незакоммиченные изменения).
    final familyRef = _families.doc(familyId);
    await familyRef.set(family.toJson());
    await familyRef.collection(membersCollection).doc(userId).set(
          membership.toJson(),
        );

    return family;
  }

  @override
  Future<FamilyModel?> find(String familyId) async {
    final snapshot = await _families.doc(familyId).get();
    return _toFamily(familyId, snapshot.data());
  }

  @override
  Stream<FamilyModel?> watch(String familyId) {
    return _families.doc(familyId).snapshots().map(
          (snapshot) => _toFamily(familyId, snapshot.data()),
        );
  }

  FamilyModel? _toFamily(String familyId, Map<String, dynamic>? data) {
    if (data == null) return null;
    return FamilyModel.fromJson({...data, 'id': familyId});
  }
}
