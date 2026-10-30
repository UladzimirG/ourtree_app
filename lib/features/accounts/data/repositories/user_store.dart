import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ourtree_app/features/accounts/domain/models/user_model.dart';

/// Хранилище профиля пользователя (`users/{userId}`).
///
/// Абстракция нужна для тестов: контроллер личности не должен требовать
/// запущенного Firestore.
abstract class UserStore {
  Future<UserModel?> find(String userId);

  /// Создаёт или обновляет документ (merge — не затираем чужие поля).
  Future<void> upsert(UserModel user);

  /// Запоминает активную семью на этом устройстве.
  Future<void> setActiveFamily(String userId, String? familyId);
}

/// Реализация поверх Cloud Firestore.
class FirestoreUserStore implements UserStore {
  FirestoreUserStore({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  @override
  Future<UserModel?> find(String userId) async {
    final snapshot = await _users.doc(userId).get();
    final data = snapshot.data();
    if (data == null) return null;
    // Документ может содержать служебные поля (например, serverUpdatedAt),
    // которых нет в модели — fromJson читает только известные ключи.
    return UserModel.fromJson({...data, 'id': userId});
  }

  @override
  Future<void> upsert(UserModel user) {
    return _users.doc(user.id).set(
      {
        ...user.toJson(),
        // Серверное время для диагностики рассинхрона (в модель не входит).
        'serverUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> setActiveFamily(String userId, String? familyId) {
    return _users.doc(userId).set(
      {
        'activeFamilyId': familyId,
        'serverUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
