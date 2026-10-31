import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ourtree_app/features/accounts/domain/models/user_model.dart';

/// Хранилище профиля пользователя (`users/{authUid}`).
///
/// Ключ документа — `auth.uid` анонимной сессии: именно его проверяют
/// Security Rules. Локальный идентификатор хранится внутри полем `id`.
abstract class UserStore {
  /// [fromServer] заставляет прочитать документ с сервера, минуя локальный кэш.
  Future<UserModel?> find(String authUid, {bool fromServer = false});

  /// Создаёт или обновляет документ (merge — не затираем чужие поля).
  Future<void> upsert(UserModel user);

  /// Запоминает активную семью на этом устройстве.
  Future<void> setActiveFamily(String authUid, String? familyId);
}

/// Реализация поверх Cloud Firestore.
class FirestoreUserStore implements UserStore {
  FirestoreUserStore({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  @override
  Future<UserModel?> find(String authUid, {bool fromServer = false}) async {
    if (authUid.isEmpty) return null;
    final snapshot = await _users.doc(authUid).get(
          fromServer
              ? const GetOptions(source: Source.server)
              : const GetOptions(),
        );
    final data = snapshot.data();
    if (data == null) return null;
    // Документ может содержать служебные поля (serverUpdatedAt), которых нет
    // в модели — fromJson читает только известные ключи.
    return UserModel.fromJson({...data, 'authUid': authUid});
  }

  @override
  Future<void> upsert(UserModel user) {
    if (user.authUid.isEmpty) {
      throw StateError('Нельзя сохранить профиль без auth.uid');
    }
    return _users.doc(user.authUid).set(
      {
        ...user.toJson(),
        // Серверное время для диагностики рассинхрона (в модель не входит).
        'serverUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> setActiveFamily(String authUid, String? familyId) {
    if (authUid.isEmpty) {
      throw StateError('Нельзя обновить профиль без auth.uid');
    }
    return _users.doc(authUid).set(
      {
        'activeFamilyId': familyId,
        'serverUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
