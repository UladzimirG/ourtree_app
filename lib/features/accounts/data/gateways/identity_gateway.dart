import 'package:firebase_auth/firebase_auth.dart';

/// Абстракция над Firebase Auth.
///
/// Нужна, чтобы логику входа можно было покрыть тестами без плагинов Firebase:
/// в тестах подставляется фейковая реализация.
abstract class IdentityGateway {
  /// UID текущей анонимной сессии; `null`, если вход ещё не выполнен.
  String? get currentAuthUid;

  /// Изменения сессии (выход, смена пользователя).
  Stream<String?> get authUidChanges;

  /// Анонимный вход: пользователь ничего не вводит, но получает проверяемый
  /// `request.auth.uid` для Security Rules.
  Future<String> signInAnonymously();

  Future<void> signOut();
}

/// Реализация на Firebase Auth (anonymous provider).
class FirebaseIdentityGateway implements IdentityGateway {
  FirebaseIdentityGateway({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  String? get currentAuthUid => _auth.currentUser?.uid;

  @override
  Stream<String?> get authUidChanges =>
      _auth.authStateChanges().map((user) => user?.uid);

  @override
  Future<String> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    final uid = credential.user?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('Firebase Auth не вернул uid анонимного пользователя');
    }
    return uid;
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
