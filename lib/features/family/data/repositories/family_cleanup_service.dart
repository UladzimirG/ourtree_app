import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Удаление данных семьи из облака.
///
/// Нужно для двух вещей: приватность (пользователь вправе стереть свои данные)
/// и гигиена хранилища — после удаления семьи её файлы и документы перестают
/// занимать место в Firebase.
abstract class FamilyCleanupService {
  /// Выход из семьи: удаляется только собственный документ участника.
  ///
  /// Остальные данные остаются — семья продолжает жить для других участников.
  Future<void> leaveFamily({
    required String familyId,
    required String authUid,
  });

  /// Полное удаление данных семьи из облака (только владелец).
  ///
  /// Порядок важен из-за Security Rules: сначала файлы (нужно активное
  /// членство), затем коды приглашений и содержимое, затем документ семьи,
  /// и последним — собственный документ участника.
  Future<void> deleteFamilyData({
    required String familyId,
    required String authUid,
  });

  /// Удаляет все файлы семьи из Storage; возвращает число удалённых объектов.
  Future<int> deleteFamilyFiles(String familyId);

  /// Сколько в семье активных участников, кроме [authUid].
  ///
  /// Нужно владельцу перед выходом: если в семье остаются люди, он не может
  /// просто «отключиться» — иначе семья осталась бы без владельца и без
  /// возможности что-либо удалить.
  Future<int> countOtherActiveMembers({
    required String familyId,
    required String authUid,
  });
}

/// Реализация поверх Firestore и Firebase Storage.
class FirebaseFamilyCleanupService implements FamilyCleanupService {
  FirebaseFamilyCleanupService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  /// Firestore разрешает не больше 500 операций в batch — берём с запасом.
  static const int _batchLimit = 400;

  /// Коллекции, которые могут встретиться внутри документа семьи.
  static const List<String> _subcollections = <String>[
    'state',
    'content',
    'people',
    'events',
    'media',
    'audit',
  ];

  static const String _families = 'families';
  static const String _members = 'members';
  static const String _inviteCodes = 'inviteCodes';

  @override
  Future<void> leaveFamily({
    required String familyId,
    required String authUid,
  }) async {
    await _db
        .collection(_families)
        .doc(familyId)
        .collection(_members)
        .doc(authUid)
        .delete();
  }

  @override
  Future<void> deleteFamilyData({
    required String familyId,
    required String authUid,
  }) async {
    // 1. Файлы: пока мы ещё активный участник, Storage Rules разрешают удаление.
    await deleteFamilyFiles(familyId);

    // 2. Коды приглашений — до удаления семьи, иначе правило потеряет доступ
    //    к документу семьи и не подтвердит владение.
    await _deleteInvites(familyId);

    // 3. Содержимое и чужие документы участников.
    for (final name in _subcollections) {
      await _deleteSubcollection(familyId, name);
    }
    await _deleteSubcollection(familyId, _members, keep: <String>{authUid});

    // 4. Документ семьи (правило проверяет владение через наш документ).
    await _db.collection(_families).doc(familyId).delete();

    // 5. И только теперь собственный документ участника.
    await leaveFamily(familyId: familyId, authUid: authUid);
  }

  @override
  Future<int> deleteFamilyFiles(String familyId) async {
    var deleted = 0;

    Future<void> deleteAll(Reference ref) async {
      final result = await ref.listAll();
      for (final prefix in result.prefixes) {
        await deleteAll(prefix);
      }
      for (final item in result.items) {
        try {
          await item.delete();
          deleted++;
        } on FirebaseException catch (error) {
          // Файл уже удалён другим устройством — это не ошибка.
          if (error.code != 'object-not-found') rethrow;
        }
      }
    }

    try {
      await deleteAll(_storage.ref('families/$familyId'));
    } on FirebaseException {
      // Пустая папка или отсутствующий путь — удалять нечего.
    }
    return deleted;
  }

  @override
  Future<int> countOtherActiveMembers({
    required String familyId,
    required String authUid,
  }) async {
    final snapshot = await _db
        .collection(_families)
        .doc(familyId)
        .collection(_members)
        .where('status', isEqualTo: 'active')
        .get();
    return snapshot.docs.where((doc) => doc.id != authUid).length;
  }

  Future<void> _deleteInvites(String familyId) async {
    final snapshot = await _db
        .collection(_inviteCodes)
        .where('familyId', isEqualTo: familyId)
        .get();
    await _deleteDocs(snapshot.docs);
  }

  Future<void> _deleteSubcollection(
    String familyId,
    String name, {
    Set<String> keep = const <String>{},
  }) async {
    final snapshot = await _db
        .collection(_families)
        .doc(familyId)
        .collection(name)
        .get();
    final docs = snapshot.docs
        .where((doc) => !keep.contains(doc.id))
        .toList(growable: false);
    await _deleteDocs(docs);
  }

  /// Удаляет документы пачками, чтобы не упереться в лимит batch.
  Future<void> _deleteDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    var batch = _db.batch();
    var pending = 0;

    for (final doc in docs) {
      batch.delete(doc.reference);
      pending++;
      if (pending == _batchLimit) {
        await batch.commit();
        batch = _db.batch();
        pending = 0;
      }
    }
    if (pending > 0) await batch.commit();
  }
}
