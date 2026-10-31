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

  Future<FamilyModel?> find(String familyId, {bool fromServer = false});

  /// Поток изменений документа семьи (для будущего sync-движка).
  Stream<FamilyModel?> watch(String familyId);

  /// Присоединяется к семье по коду приглашения.
  ///
  /// Код кладётся в документ участника: Security Rules проверяют его
  /// существование и срок действия, поэтому «придумать» вход нельзя.
  Future<FamilyModel> joinWithInvite({
    required String familyId,
    required String userId,
    required String authUid,
    required String inviteCode,
    FamilyRole role,
  });
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
    // Ключ документа участника — auth.uid: по нему работают правила
    // (Firestore и Storage), локальный userId хранится внутри полем.
    await familyRef.collection(membersCollection).doc(authUid).set(
          membership.toJson(),
        );

    // Подтверждаем запись чтением с сервера: при офлайне Firestore молча
    // ставит операцию в очередь, и без этой проверки UI соврал бы об успехе.
    final persisted = await find(familyId, fromServer: true);
    if (persisted == null) {
      throw StateError('Семья не сохранилась в облаке: $familyId');
    }
    return persisted;
  }

  @override
  Future<FamilyModel?> find(String familyId, {bool fromServer = false}) async {
    final snapshot = await _families.doc(familyId).get(
          fromServer
              ? const GetOptions(source: Source.server)
              : const GetOptions(),
        );
    return _toFamily(familyId, snapshot.data());
  }

  @override
  Stream<FamilyModel?> watch(String familyId) {
    return _families.doc(familyId).snapshots().map(
          (snapshot) => _toFamily(familyId, snapshot.data()),
        );
  }

  @override
  Future<FamilyModel> joinWithInvite({
    required String familyId,
    required String userId,
    required String authUid,
    required String inviteCode,
    FamilyRole role = FamilyRole.editor,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final membership = FamilyMembership(
      userId: userId,
      authUid: authUid,
      role: role,
      status: FamilyMembershipStatus.active,
      joinedAt: now,
      updatedAt: now,
    );

    final familyRef = _families.doc(familyId);
    await familyRef.collection(membersCollection).doc(authUid).set({
      ...membership.toJson(),
      // Проверяется правилами: код существует, не отозван и не истёк.
      'inviteCode': inviteCode,
    });

    final family = await find(familyId, fromServer: true);
    if (family == null) {
      throw StateError('Семья не найдена после присоединения: $familyId');
    }
    return family;
  }

  FamilyModel? _toFamily(String familyId, Map<String, dynamic>? data) {
    if (data == null) return null;
    return FamilyModel.fromJson({...data, 'id': familyId});
  }
}
