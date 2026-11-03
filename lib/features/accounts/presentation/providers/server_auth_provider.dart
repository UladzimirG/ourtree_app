import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/accounts/data/gateways/accounts_api.dart';
import 'package:ourtree_app/features/accounts/data/gateways/identity_gateway.dart';
import 'package:ourtree_app/features/accounts/domain/models/accounts_models.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/identity_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_auth_provider.g.dart';

/// Клиент серверного API аккаунтов (подменяется в тестах).
@Riverpod(keepAlive: true)
AccountsApi accountsApi(Ref ref) => FirebaseAccountsApi();

/// Итог серверного входа.
enum ServerSignInStatus {
  success,

  /// Неверный пароль.
  invalidCredentials,

  /// Такого логина на сервере нет — возможно, аккаунт ещё локальный.
  accountNotFound,

  /// Сервер недоступен (нет сети или функции не задеплоены).
  unavailable,

  /// Сервер ответил, но завершить вход не удалось (например, Firebase Auth
  /// отклонил custom token). Причина пишется в консоль.
  serverError,
}

class ServerSignInResult {
  const ServerSignInResult(
    this.status, {
    this.account,
    this.migrated = false,
  });

  final ServerSignInStatus status;
  final Account? account;

  /// Локальный аккаунт перенесён на сервер при этом входе.
  final bool migrated;

  bool get isSuccess => status == ServerSignInStatus.success && account != null;
}

/// Серверная авторизация по логину и паролю.
///
/// Жизненный цикл входа: Cloud Function проверяет пароль → возвращает
/// custom token → Firebase Auth делает `uid` равным id аккаунта →
/// членство в семьях переносится на этот uid на сервере.
@Riverpod(keepAlive: true)
class ServerAuth extends _$ServerAuth {
  @override
  void build() {}

  AccountsApi get _api => ref.read(accountsApiProvider);

  IdentityGateway get _gateway => ref.read(identityGatewayProvider);

  Future<ServerSignInResult> signIn(String login, String password) async {
    try {
      final result = await _api.login(login: login, password: password);
      await _applyLogin(result, password);
      return ServerSignInResult(
        ServerSignInStatus.success,
        account: result.account,
      );
    } on AccountsApiException catch (error) {
      return ServerSignInResult(_statusFor(error));
    } catch (error) {
      // Сервер ответил, но Firebase Auth не принял токен (или сломался разбор
      // ответа). Показываем это как ошибку сервера, а не «нет сети».
      debugPrint('ServerAuth: не удалось завершить вход: $error');
      return const ServerSignInResult(ServerSignInStatus.serverError);
    }
  }

  /// Переносит локальный аккаунт на сервер и сразу входит им.
  ///
  /// Нужен для аккаунтов, созданных до появления серверной авторизации:
  /// пароль уже проверен локально, поэтому им можно создать серверную запись.
  Future<ServerSignInResult> claimLocal(
    Account local,
    String password,
  ) async {
    try {
      await _api.register(
        AccountInput(
          login: local.login,
          name: local.name,
          password: password,
          role: local.role,
        ),
        id: local.id,
      );
      final result = await _api.login(
        login: local.login,
        password: password,
      );
      await _applyLogin(result, password);
      return ServerSignInResult(
        ServerSignInStatus.success,
        account: result.account,
        migrated: true,
      );
    } on AccountsApiException catch (error) {
      if (error.kind == AccountsApiErrorKind.loginTaken) {
        // Логин уже принадлежит другому серверному аккаунту.
        return signIn(local.login, password);
      }
      return ServerSignInResult(_statusFor(error));
    } catch (error) {
      debugPrint('ServerAuth: не удалось перенести аккаунт на сервер: $error');
      return const ServerSignInResult(ServerSignInStatus.serverError);
    }
  }

  /// Создаёт аккаунт на сервере. `AccountsError.offline` означает, что
  /// сервер недоступен и вызывающий может создать локальную запись.
  Future<AccountsError?> create(AccountInput input) async {
    try {
      final account = await _api.register(input);
      _upsertWithPassword(account, input.password);
      return null;
    } on AccountsApiException catch (error) {
      return _errorFor(error);
    }
  }

  /// Сохраняет изменения серверного аккаунта.
  Future<AccountsError?> update(
    Account account,
    AccountPatch patch,
  ) async {
    if (!account.serverBacked) return null;
    try {
      final updated = await _api.update(
        id: account.id,
        name: patch.name,
        role: patch.role,
        password: patch.password,
      );
      if (patch.password != null && patch.password!.isNotEmpty) {
        _upsertWithPassword(updated, patch.password!);
      } else {
        ref.read(accountsProvider.notifier).upsert(updated);
      }
      return null;
    } on AccountsApiException catch (error) {
      return _errorFor(error);
    }
  }

  /// Сохраняет права видимости серверного аккаунта (best effort).
  Future<void> updateAccess(
    String id, {
    required bool allMembersVisible,
    required List<String> visibleMemberIds,
  }) async {
    final account = ref.read(accountsProvider.notifier).byId(id);
    if (account == null || !account.serverBacked) return;
    try {
      final updated = await _api.update(
        id: id,
        allMembersVisible: allMembersVisible,
        visibleMemberIds: visibleMemberIds,
      );
      ref.read(accountsProvider.notifier).upsert(updated);
    } on AccountsApiException {
      // Офлайн: локальная копия уже обновлена и уйдёт при следующей правке.
    }
  }

  /// Удаляет серверный аккаунт.
  Future<AccountsError?> delete(Account account) async {
    if (!account.serverBacked) {
      ref.read(accountsProvider.notifier).remove(account.id);
      return null;
    }
    try {
      await _api.delete(account.id);
      ref.read(accountsProvider.notifier).remove(account.id);
      return null;
    } on AccountsApiException catch (error) {
      return _errorFor(error);
    }
  }

  /// Выход: Firebase снова становится анонимным, локальная личность —
  /// новой. Аккаунт остаётся на сервере и доступен по паролю.
  Future<void> signOut() async {
    await _gateway.signOut();
    // Убираем сохранённую личность до пересборки провайдеров, иначе
    // анонимная сессия унаследует id аккаунта.
    await MediaStorage.instance.removeString(localUserIdStorageKey);
    ref.read(currentAccountIdProvider.notifier).signOut();
    ref.invalidate(localUserIdProvider);
    ref.invalidate(identityControllerProvider);
  }

  Future<void> _applyLogin(ServerLoginResult result, String password) async {
    await _gateway.signInWithCustomToken(result.token);
    _upsertWithPassword(result.account, password);
    ref.read(currentAccountIdProvider.notifier).setAccount(result.account.id);
    await MediaStorage.instance.putString(
      localUserIdStorageKey,
      result.account.id,
    );

    // Аккаунт уже состоит в семье: запоминаем её до пересборки личности,
    // чтобы синхронизация сразу подтянула семейный архив.
    final familyId = result.familyId;
    if (familyId != null && familyId.isNotEmpty) {
      try {
        await ref
            .read(userStoreProvider)
            .setActiveFamily(result.account.id, familyId);
      } catch (error) {
        debugPrint('ServerAuth: не удалось сохранить активную семью: $error');
      }
    }

    ref.invalidate(localUserIdProvider);
    ref.invalidate(identityControllerProvider);
    if (result.account.isAdmin) {
      unawaited(_syncRoster());
    }
  }

  /// Сохраняет локальную копию с хешем пароля: без сети вход продолжает
  /// работать, а сам пароль на устройстве не хранится.
  void _upsertWithPassword(Account account, String password) {
    if (password.isEmpty) {
      ref.read(accountsProvider.notifier).upsert(account);
      return;
    }
    final salt = newPasswordSalt();
    ref.read(accountsProvider.notifier).upsert(
          account.copyWith(
            passwordSalt: salt,
            passwordHash: hashAccountPassword(password, salt),
          ),
        );
  }

  /// Подтягивает список аккаунтов, чтобы на новом устройстве появились
  /// все профили семьи, а не только текущий.
  Future<void> _syncRoster() async {
    try {
      final accounts = await _api.list();
      ref.read(accountsProvider.notifier).replaceServerAccounts(accounts);
    } on AccountsApiException {
      // Без сети остаётся локальная копия.
    }
  }

  ServerSignInStatus _statusFor(AccountsApiException error) {
    return switch (error.kind) {
      AccountsApiErrorKind.badPassword => ServerSignInStatus.invalidCredentials,
      AccountsApiErrorKind.accountNotFound =>
        ServerSignInStatus.accountNotFound,
      _ => ServerSignInStatus.unavailable,
    };
  }

  AccountsError? _errorFor(AccountsApiException error) {
    return switch (error.kind) {
      AccountsApiErrorKind.loginTaken => AccountsError.loginTaken,
      AccountsApiErrorKind.badPassword => AccountsError.unauthenticated,
      AccountsApiErrorKind.accountNotFound => AccountsError.notFound,
      AccountsApiErrorKind.forbidden => AccountsError.forbidden,
      AccountsApiErrorKind.unavailable => AccountsError.offline,
      AccountsApiErrorKind.invalid => _invalidInputError(error.message),
      AccountsApiErrorKind.serverError => AccountsError.unknown,
    };
  }

  AccountsError _invalidInputError(String message) {
    if (message.contains('account/weak-password')) {
      return AccountsError.weakPassword;
    }
    if (message.contains('account/bad-login')) {
      return AccountsError.badLogin;
    }
    if (message.contains('account/bad-role')) {
      return AccountsError.badRole;
    }
    return AccountsError.unknown;
  }
}
