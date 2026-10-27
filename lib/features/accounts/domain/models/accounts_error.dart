/// Ошибки учётных записей и гостевых ссылок (`AccountsError`).
enum AccountsError {
  badLogin('bad-login'),
  badRole('bad-role'),
  weakPassword('weak-password'),
  loginTaken('login-taken'),
  cannotDeleteSelf('cannot-delete-self'),
  cannotChangeOwnRole('cannot-change-own-role'),
  notFound('not-found'),
  forbidden('forbidden'),
  unauthenticated('unauthenticated'),
  offline('offline'),
  unknown('unknown');

  const AccountsError(this.wireName);

  /// Код ошибки, которым отвечает сервер.
  final String wireName;

  /// Приводит ответ сервера к известному коду — та же логика, что в
  /// `normalizeError` из `src/lib/accounts.ts`.
  static AccountsError fromServerCode(Object? code, {int? status}) {
    final value = code is String ? code : '';
    if (value == 'account-not-found' || value == 'link-not-found') {
      return AccountsError.notFound;
    }
    if (status == 404) return AccountsError.notFound;
    if (status == 403) return AccountsError.forbidden;
    if (status == 401) return AccountsError.unauthenticated;
    for (final error in values) {
      if (error.wireName == value) return error;
    }
    return AccountsError.unknown;
  }
}
