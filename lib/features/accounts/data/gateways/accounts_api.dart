import 'package:cloud_functions/cloud_functions.dart';
import 'package:ourtree_app/features/accounts/domain/models/accounts_models.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';

/// Причина ошибки серверного API аккаунтов.
enum AccountsApiErrorKind {
  /// Сервер недоступен (нет сети, функции не задеплоены).
  unavailable,

  /// Такого логина на сервере нет (возможно, аккаунт ещё локальный).
  accountNotFound,

  /// Неверный пароль.
  badPassword,

  /// Логин уже занят.
  loginTaken,

  /// Недостаточно прав.
  forbidden,

  /// Некорректные данные запроса.
  invalid,

  /// Прочая ошибка сервера.
  serverError,
}

class AccountsApiException implements Exception {
  const AccountsApiException(this.kind, [this.message = '']);

  final AccountsApiErrorKind kind;
  final String message;

  /// Можно ли обработать вход локальной копией аккаунта:
  /// сервер недоступен или аккаунт ещё не перенесён на сервер.
  bool get canFallbackToLocal =>
      kind == AccountsApiErrorKind.unavailable ||
      kind == AccountsApiErrorKind.accountNotFound;

  @override
  String toString() => 'AccountsApiException($kind, $message)';
}

/// Результат успешного серверного входа.
class ServerLoginResult {
  const ServerLoginResult({required this.token, required this.account});

  final String token;
  final Account account;
}

/// API серверных аккаунтов (Cloud Functions).
abstract class AccountsApi {
  Future<Account> register(AccountInput input, {String? id});

  Future<ServerLoginResult> login({
    required String login,
    required String password,
  });

  Future<List<Account>> list();

  Future<Account> update({
    required String id,
    String? name,
    UserRole? role,
    String? password,
    bool? allMembersVisible,
    List<String>? visibleMemberIds,
  });

  Future<void> delete(String id);
}

/// Реализация поверх HTTPS-callable функций Firebase.
class FirebaseAccountsApi implements AccountsApi {
  FirebaseAccountsApi({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: functionsRegion);

  /// Регион совпадает с `FUNCTIONS_REGION` в `functions/src/region.ts`.
  static const String functionsRegion = 'europe-west3';

  static const Duration _timeout = Duration(seconds: 20);

  final FirebaseFunctions _functions;

  HttpsCallable _callable(String name) => _functions.httpsCallable(
        name,
        options: HttpsCallableOptions(timeout: _timeout),
      );

  @override
  Future<Account> register(AccountInput input, {String? id}) async {
    final data = await _invoke('accountRegister', {
      'login': input.login,
      'name': input.name,
      'password': input.password,
      'role': input.role.wireName,
      if (id != null && id.isNotEmpty) 'id': id,
    });
    return _account(data);
  }

  @override
  Future<ServerLoginResult> login({
    required String login,
    required String password,
  }) async {
    final data = await _invoke('accountLogin', {
      'login': login,
      'password': password,
    });
    final map = data is Map ? data : const <String, dynamic>{};
    final token = map['token'];
    if (token is! String || token.isEmpty) {
      throw const AccountsApiException(
        AccountsApiErrorKind.serverError,
        'token',
      );
    }
    return ServerLoginResult(
      token: token,
      account: _account(map['account']),
    );
  }

  @override
  Future<List<Account>> list() async {
    final data = await _invoke('accountList', const <String, dynamic>{});
    if (data is! List) return const <Account>[];
    return [
      for (final item in data)
        if (item is Map) _account(item),
    ];
  }

  @override
  Future<Account> update({
    required String id,
    String? name,
    UserRole? role,
    String? password,
    bool? allMembersVisible,
    List<String>? visibleMemberIds,
  }) async {
    final data = await _invoke('accountUpdate', {
      'id': id,
      if (name != null) 'name': name,
      if (role != null) 'role': role.wireName,
      if (password != null && password.isNotEmpty) 'password': password,
      if (allMembersVisible != null) 'allMembersVisible': allMembersVisible,
      if (visibleMemberIds != null) 'visibleMemberIds': visibleMemberIds,
    });
    return _account(data);
  }

  @override
  Future<void> delete(String id) async {
    await _invoke('accountDelete', {'id': id});
  }

  Account _account(Object? raw) {
    if (raw is! Map) {
      throw const AccountsApiException(
        AccountsApiErrorKind.serverError,
        'account',
      );
    }
    return Account.fromJson(raw.cast<String, dynamic>()).copyWith(
      serverBacked: true,
    );
  }

  Future<Object?> _invoke(
    String name,
    Map<String, dynamic> payload,
  ) async {
    try {
      final result = await _callable(name).call<Object?>(payload);
      return result.data;
    } on FirebaseFunctionsException catch (error) {
      throw _mapError(error);
    } catch (error) {
      throw AccountsApiException(
        AccountsApiErrorKind.serverError,
        error.toString(),
      );
    }
  }

  AccountsApiException _mapError(FirebaseFunctionsException error) {
    final message = error.message ?? '';
    switch (error.code) {
      case 'unavailable':
      case 'deadline-exceeded':
      case 'cancelled':
      case 'resource-exhausted':
        return AccountsApiException(AccountsApiErrorKind.unavailable, message);
      case 'not-found':
        return message.contains('account/not-found')
            ? AccountsApiException(AccountsApiErrorKind.accountNotFound, message)
            : AccountsApiException(AccountsApiErrorKind.unavailable, message);
      case 'permission-denied':
        return message.contains('account/bad-password')
            ? AccountsApiException(AccountsApiErrorKind.badPassword, message)
            : AccountsApiException(AccountsApiErrorKind.forbidden, message);
      case 'already-exists':
        return AccountsApiException(AccountsApiErrorKind.loginTaken, message);
      case 'invalid-argument':
        return AccountsApiException(AccountsApiErrorKind.invalid, message);
      case 'failed-precondition':
        return message.contains('account/custom-token-failed')
            ? AccountsApiException(AccountsApiErrorKind.serverError, message)
            : AccountsApiException(AccountsApiErrorKind.forbidden, message);
      default:
        return AccountsApiException(AccountsApiErrorKind.serverError, message);
    }
  }
}

