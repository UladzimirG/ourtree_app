import 'package:ourtree_app/features/accounts/domain/models/user_model.dart';

/// Состояние входа: локальная личность и подтверждённый Firebase `auth.uid`.
class IdentityState {
  const IdentityState({
    required this.user,
    required this.authUid,
  });

  final UserModel user;

  /// `auth.uid` анонимной сессии; пустая строка — вход не выполнен.
  final String authUid;

  bool get isSignedIn => authUid.isNotEmpty;

  String get userId => user.id;

  String? get activeFamilyId => user.activeFamilyId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdentityState &&
          user == other.user &&
          authUid == other.authUid;

  @override
  int get hashCode => Object.hash(user, authUid);

  @override
  String toString() =>
      'IdentityState(userId: $userId, authUid: $authUid, '
      'activeFamilyId: $activeFamilyId)';
}
